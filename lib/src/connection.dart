import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'message.dart';
import 'consumer.dart';
import 'constants.dart';
import 'connection_monitor.dart';
import 'subscriptions.dart';
import 'utils/logger.dart';

/// Encapsulate the cable connection held by the consumer. This is an internal class not intended for direct user manipulation.
class Connection {
  WebSocket webSocket;

  Consumer consumer;
  Subscriptions subscriptions;
  ConnectionMonitor monitor;
  bool connected;

  static int reopenDelay = 500;

  Connection(this.consumer) {
    subscriptions = consumer.subscriptions;
    monitor = new ConnectionMonitor(this);
    connected = false;
  }

  Future<bool> open() async {
    if (isActive()) {
      Logger.log(
          'Attempted to open WebSocket, but existing socket is ${_getState()}');
      return false;
    } else {
      Logger.log(
          'Opening WebSocket, current state is ${_getState()}, subprotocols: ${protocols}');

      Logger.log('Creating connection with ${consumer.host}');
      webSocket = await _createSocket();
      Logger.log(
          "WebSocket onopen event, using '${getProtocol()}' subprotocol");
      connected = true;
      if (!_isProtocolSupported()) {
        Logger.log(
            "Protocol is unsupported. Stopping monitor and disconnecting.");
        return close(allowReconnect: false);
      }
      _installEventHandlers();
      monitor.start();
      return true;
    }
  }

  bool send(data) {
    if (isOpen()) {
      Logger.log('Sending $data');
      webSocket.add(json.encode(data));
      return true;
    } else {
      throw Exception(
          'Trying to send data while connection is not opened. Data: ${data}');
    }
  }

  Future<bool> close({bool allowReconnect = true}) async {
    if (!allowReconnect) {
      monitor.stop();
    }
    if (isActive()) {
      await webSocket.close();
      return true;
    }
    return false;
  }

  Future<bool> reopen() async {
    Logger.log('Reopening WebSocket, current state is ${_getState()}');
    if (isActive()) {
      try {
        return await close();
      } catch (error) {
        Logger.log('Failed to reopen WebSocket $error');
      } finally {
        Logger.log('Reopening WebSocket in ${reopenDelay}ms');
        return await new Future.delayed(
            new Duration(milliseconds: reopenDelay), open);
      }
    } else {
      return await open();
    }
  }

  String getProtocol() {
    if (webSocket != null) {
      return webSocket.protocol;
    } else {
      throw Exception('Trying to get protocol on null websocket');
    }
  }

  bool isOpen() {
    return _isState(["open"]);
  }

  bool isActive() {
    return _isState(["open", "connecting"]);
  }

  Future<WebSocket> _createSocket() async {
    Random r = new Random();
    String key = base64.encode(List<int>.generate(8, (_) => r.nextInt(255)));

    HttpClient client = HttpClient(context: SecurityContext());
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);

    bool isHttps = consumer.port == 443;
    bool isPortCustom = !(consumer.port == 80 || isHttps);

    String port = isPortCustom ? ':${consumer.port}' : '';
    String origin = 'http${isHttps ? 's' : ''}://${consumer.host}$port';
    String fullAddress = '$origin/${consumer.cablePath}';

    HttpClientRequest request = await client.getUrl(Uri.parse(fullAddress));

    request.headers.add('Connection', 'upgrade');
    request.headers.add('Upgrade', 'websocket');
    request.headers.add('sec-websocket-version', '13');
    request.headers.add('sec-websocket-key', key);
    request.headers.add('ORIGIN', origin);

    HttpClientResponse response = await request.close();

    // Expected status code 1xx, (exactly 101 - successfully switched protocol)
    if (response.statusCode ~/ 100 != 1) {
      throw Exception(
        'Failed to connect to the server. Status code ${response.statusCode}',
      );
    }

    Socket socket = await response.detachSocket();

    // I'm not able to pass more then one protocol (as it's possible in JS or in a WebSocket from dart:html),
    // so for now i pass only 'actioncable-v1-json'
    webSocket = WebSocket.fromUpgradedSocket(socket,
        serverSide: false, protocol: protocols[0]);

    return webSocket;
  }

  /// Check if websocket's subprotocol is supported
  bool _isProtocolSupported() {
    return protocols.indexOf(getProtocol()) >= 0;
  }

  /// Check if current websocket's state is in list of passed states
  bool _isState(List states) {
    return states.indexOf(_getState()) >= 0;
  }

  /// Return current state of websocket
  String _getState() {
    if (webSocket != null) {
      for (String state in wsStates.keys) {
        if (wsStates[state] == webSocket.readyState) {
          return state;
        }
      }
    }
    return null;
  }

  void _installEventHandlers() {
    webSocket.listen(onMessage,
        onDone: onClose, onError: onError, cancelOnError: false);
  }

  void onMessage(dynamic data) {
    if (!_isProtocolSupported()) {
      return null;
    }

    Map<String, dynamic> parsedJson = json.decode(data);

    String type = parsedJson['type'];
    dynamic identifier = parsedJson['identifier'];
    dynamic message = parsedJson['message'];
    dynamic reconnect = parsedJson['reconnect'];
    dynamic reason = parsedJson['reason'];

    if (type != MessageType.ping && message != null)
      Logger.log(message.toString());

    switch (type) {
      case MessageType.welcome:
        monitor.recordConnect();
        subscriptions.reload();
        subscriptions.notifyAll(SubscriptionEventType.connected, message);
        break;
      case MessageType.disconnect:
        Logger.log('Disconnecting. Reason: ${reason}');
        close(allowReconnect: reconnect);
        break;
      case MessageType.ping:
        monitor.recordPing();
        break;
      case MessageType.confirmation:
        Logger.log('Got confirmation: ${message}');
        subscriptions.confirmationStreamController.add(
          SubscriptionConfirmationMessage(
            type: type,
            identifier: identifier,
          ),
        );
        break;
      case MessageType.rejection:
        subscriptions.reject(identifier);
        break;
      default:
        subscriptions.notify(
            identifier, SubscriptionEventType.received, message);
    }
  }

  void onClose() {
    Logger.log('Connection closed');
    monitor.recordDisconnect();
    connected = false;
  }

  void onError(Object error, StackTrace st) {
    Logger.log('Error');
    Logger.log(error.toString());
  }
}

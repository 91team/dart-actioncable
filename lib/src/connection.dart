import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';

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
    this.subscriptions = consumer.subscriptions;
    this.monitor = new ConnectionMonitor(this);
    this.connected = false;
  }

  Future<bool> open() async {
    if (this.isActive()) {
      Logger.log(
          'Attempted to open WebSocket, but existing socket is ${this._getState()}');
      return false;
    } else {
      Logger.log(
          'Opening WebSocket, current state is ${this._getState()}, subprotocols: ${protocols}');

      Logger.log('Creating connection with ${this.consumer.url}');
      this.webSocket = await this._createSocket(this.consumer.url);
      Logger.log(
          "WebSocket onopen event, using '${this.getProtocol()}' subprotocol");
      this.connected = true;
      if (!this._isProtocolSupported()) {
        Logger.log(
            "Protocol is unsupported. Stopping monitor and disconnecting.");
        return this.close(allowReconnect: false);
      }
      this._installEventHandlers();
      this.monitor.start();
      return true;
    }
  }

  bool send(data) {
    if (this.isOpen()) {
      Logger.log('Sending $data');
      this.webSocket.add(json.encode(data));
      return true;
    } else {
      throw Exception(
          'Trying to send data while connection is not opened. Data: ${data}');
    }
  }

  Future<bool> close({allowReconnect = true}) async {
    if (!allowReconnect) {
      this.monitor.stop();
    }
    if (this.isActive()) {
      await this.webSocket.close();
      return true;
    }
    return false;
  }

  Future<bool> reopen() async {
    Logger.log('Reopening WebSocket, current state is ${this._getState()}');
    if (this.isActive()) {
      try {
        return await this.close();
      } catch (error) {
        Logger.log('Failed to reopen WebSocket $error');
      } finally {
        Logger.log('Reopening WebSocket in ${reopenDelay}ms');
        return await new Future.delayed(
            new Duration(milliseconds: reopenDelay), this.open);
      }
    } else {
      return await this.open();
    }
  }

  String getProtocol() {
    if (this.webSocket != null) {
      return this.webSocket.protocol;
    } else {
      throw Exception('Trying to get protocol on null websocket');
    }
  }

  bool isOpen() {
    return this._isState(["open"]);
  }

  bool isActive() {
    return this._isState(["open", "connecting"]);
  }

  Future<WebSocket> _createSocket(String url) async {
    Random r = new Random();
    String key = base64.encode(List<int>.generate(8, (_) => r.nextInt(255)));

    HttpClient client = HttpClient();
    HttpClientRequest request = await client.get(
        'localhost', 3000, 'cable'); // TODO: form the correct url here
    request.headers.add('Connection', 'upgrade');
    request.headers.add('Upgrade', 'websocket');
    request.headers.add('sec-websocket-version', '13');
    request.headers.add('sec-websocket-key', key);
    request.headers.add('ORIGIN', 'http://localhost:3000');

    HttpClientResponse response = await request.close();
    Socket socket = await response.detachSocket();

    // I'm not able to pass more then one protocol (as it's possible in JS or in WebSocket from dart:html),
    // so for now i pass only 'actioncable-v1-json'
    this.webSocket = WebSocket.fromUpgradedSocket(socket,
        serverSide: false, protocol: protocols[0]);

    return this.webSocket;
  }

  /// Check if websocket's subprotocol is supported
  bool _isProtocolSupported() {
    return protocols.indexOf(this.getProtocol()) >= 0;
  }

  /// Check if current websocket's state is in list of passed states
  bool _isState(List states) {
    return states.indexOf(this._getState()) >= 0;
  }

  /// Return current state of websocket
  String _getState() {
    if (this.webSocket != null) {
      for (String state in wsStates.keys) {
        if (wsStates[state] == this.webSocket.readyState) {
          return state;
        }
      }
    }
    return null;
  }

  void _installEventHandlers() {
    this
        .webSocket
        .listen(this.onMessage, onError: this.onError, cancelOnError: false);
  }

  void onMessage(dynamic data) {
    if (!this._isProtocolSupported()) {
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
        this.monitor.recordConnect();
        this.subscriptions.reload();
        break;
      case MessageType.disconnect:
        Logger.log('Disconnecting. Reason: ${reason}');
        this.close(allowReconnect: reconnect);
        break;
      case MessageType.ping:
        this.monitor.recordPing();
        break;
      case MessageType.confirmation:
        this.subscriptions.notify(identifier, SubscriptionEventType.connected);
        break;
      case MessageType.rejection:
        this.subscriptions.reject(identifier);
        break;
      default:
        this
            .subscriptions
            .notify(identifier, SubscriptionEventType.received, message);
    }
  }

  void onError(Object error, StackTrace st) {
    Logger.log('Error');
    Logger.log(error.toString());
  }
}

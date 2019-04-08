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

    this.open().then((res) {
      print("   -> Open");
      print(res);
    });
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
      // this.webSocket = await WebSocket.connect(this.consumer.url);
      this._installEventHandlers();
      this.monitor.start();
      return true;
    }
  }

  bool send(data) {
    if (this.isOpen()) {
      Logger.log('Sending $data');
      // this.webSocket.send(JSON.stringify(data));
      return true;
    } else {
      return false;
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

    HttpClient client = HttpClient(/* optional security context here */);
    HttpClientRequest request = await client.get(
        'localhost', 3000, 'cable'); // form the correct url here
    request.headers.add('Connection', 'upgrade');
    request.headers.add('Upgrade', 'websocket');
    request.headers.add('sec-websocket-version', '13');
    request.headers.add('sec-websocket-key', key);
    request.headers.add('ORIGIN', 'http://localhost:3000');

    HttpClientResponse response = await request.close();
    // todo check the status code, key etc
    Socket socket = await response.detachSocket();

    this.webSocket = WebSocket.fromUpgradedSocket(
      socket,
      serverSide: false,
    );

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
    this.webSocket.listen(this.onMessage,
        onDone: this.onDone, onError: this.onError, cancelOnError: false);
  }

  void onMessage(dynamic data) {
    Logger.log(data);
  }

  void onDone() {
    this.webSocket.close();
    this.webSocket = null;
  }

  void onError(Object error, StackTrace st) {
    Logger.log('Error');
    print(error);
    print(st);
  }
}

// Connection.prototype.events = {
//   message(event) {
//     if (!this.isProtocolSupported()) { return }
//     const {identifier, message, reason, reconnect, type} = JSON.parse(event.data)
//     switch (type) {
//       case message_types.welcome:
//         this.monitor.recordConnect()
//         return this.subscriptions.reload()
//       case message_types.disconnect:
//         logger.log(`Disconnecting. Reason: ${reason}`)
//         return this.close({allowReconnect: reconnect})
//       case message_types.ping:
//         return this.monitor.recordPing()
//       case message_types.confirmation:
//         return this.subscriptions.notify(identifier, "connected")
//       case message_types.rejection:
//         return this.subscriptions.reject(identifier)
//       default:
//         return this.subscriptions.notify(identifier, "received", message)
//     }
//   },

//   open() {
//     logger.log(`WebSocket onopen event, using '${this.getProtocol()}' subprotocol`)
//     this.disconnected = false
//     if (!this.isProtocolSupported()) {
//       logger.log("Protocol is unsupported. Stopping monitor and disconnecting.")
//       return this.close({allowReconnect: false})
//     }
//   },

//   close(event) {
//     logger.log("WebSocket onclose event")
//     if (this.disconnected) { return }
//     this.disconnected = true
//     this.monitor.recordDisconnect()
//     return this.subscriptions.notifyAll("disconnected", {willAttemptReconnect: this.monitor.isRunning()})
//   },

//   error() {
//     logger.log("WebSocket onerror event")
//   }
// }

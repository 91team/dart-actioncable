import 'dart:io';
import 'dart:async';

import 'consumer.dart';
import 'constants.dart';
import 'connection_monitor.dart';
import 'utils/logger.dart';
import 'subscriptions.dart';

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

      this.webSocket = await WebSocket.connect(this.consumer.url);
      this._installEventHandlers();
      this.monitor.start();
      return true;
    }
  }

  bool send(data) {
    if (this.isOpen()) {
      // this.webSocket.send(JSON.stringify(data));
      return true;
    } else {
      return false;
    }
  }

  // define return type
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

  // define return type
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

  bool _isProtocolSupported() {
    // this line check if value of this.getProtocol() presented in supported protocols
    // return indexOf.call(supportedProtocols, this.getProtocol()) >= 0;
    return true; // delete
  }

  bool _isState(List states) {
    // return indexOf.call(states, this.getState()) >= 0;

    return true; // delete
  }

  // define return type
  _getState() {
    if (this.webSocket != null) {
      // for (let state in adapters.WebSocket) {
      //   if (adapters.WebSocket[state] == this.webSocket.readyState) {
      //     return state.toLowerCase();
      //   }
      // }
    }
    return null; // don't delete.
  }

  void _installEventHandlers() {
    this.webSocket.listen(this.onMessage,
        onDone: this.onDone, onError: this.onError, cancelOnError: false);
  }

  void onMessage(List<int> data) {
    String message = new String.fromCharCodes(data).trim();
    Logger.log(message);
  }

  void onDone() {
    this.webSocket.close();
    this.webSocket = null;
  }

  void onError(List<int> data) {}
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

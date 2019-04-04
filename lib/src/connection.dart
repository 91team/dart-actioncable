import 'adapters.dart';
import 'consumer.dart';
import 'constants.dart';
import 'connection_monitor.dart';
import 'logger.dart';
import 'subscriptions.dart';

/// Encapsulate the cable connection held by the consumer. This is an internal class not intended for direct user manipulation.

class Connection {
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

  bool send(data) {
    if (this.isOpen()) {
      // this.webSocket.send(JSON.stringify(data));
      return true;
    } else {
      return false;
    }
  }

  bool open() {
    if (this.isActive()) {
      // logger.log(`Attempted to open WebSocket, but existing socket is ${this.getState()}`);
      return false;
    } else {
      // logger.log(`Opening WebSocket, current state is ${this.getState()}, subprotocols: ${protocols}`);
      // if (this.webSocket) { this.uninstallEventHandlers(); }
      // this.webSocket = new adapters.WebSocket(this.consumer.url, protocols);
      // this.installEventHandlers();
      // this.monitor.start();
      return true;
    }
  }

  // define return type
  close({allowReconnect = true}) {
    if (!allowReconnect) {
      this.monitor.stop();
    }
    if (this.isActive()) {
      // return this.webSocket.close();
    }
  }

  // define return type
  reopen() {
    // logger.log(`Reopening WebSocket, current state is ${this.getState()}`)
    if (this.isActive()) {
      try {
        return this.close();
      } catch (error) {
        // logger.log("Failed to reopen WebSocket", error);
      } finally {
        // logger.log(`Reopening WebSocket in ${this.constructor.reopenDelay}ms`);
        // setTimeout(this.open, this.constructor.reopenDelay);
      }
    } else {
      return this.open();
    }
  }

  // define return type
  getProtocol() {
    // if (this.webSocket) {
    //   return this.webSocket.protocol;
    // }
    return 'wss'; // delete
  }

  bool isOpen() {
    // return this.isState("open");
    return false; // delete
  }

  bool isActive() {
    // return this.isState("open", "connecting");
    return false; // delete
  }

  // private part. replace func by _func later.

  bool isProtocolSupported() {
    // this line check if value of this.getProtocol() presented in supported protocols
    // return indexOf.call(supportedProtocols, this.getProtocol()) >= 0;
    return true; // delete
  }

  bool isState(List states) {
    // return indexOf.call(states, this.getState()) >= 0;
    return true; // delete
  }

  // define return type
  getState() {
    // if (this.webSocket) {
    //   for (let state in adapters.WebSocket) {
    //     if (adapters.WebSocket[state] == this.webSocket.readyState) {
    //       return state.toLowerCase();
    //     }
    //   }
    // }
    return null; // don't delete.
  }

  void installEventHandlers() {
    // for (let eventName in this.events) {
    //   const handler = this.events[eventName].bind(this);
    //   this.webSocket[`on${eventName}`] = handler;
    // }
  }

  void uninstallEventHandlers() {
    // for (let eventName in this.events) {
    //   this.webSocket[`on${eventName}`] = function() {};
    // }
  }
}

// What to do with this prorotype?

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

// export default Connection

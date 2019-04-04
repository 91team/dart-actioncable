import 'connection.dart';
import 'logger.dart';

// Responsible for ensuring the cable connection is in good health by validating the heartbeat pings sent from the server, and attempting
// revival reconnections if things go astray. Internal class, not intended for direct user manipulation.

class ConnectionMonitor {
  Connection connection;
  int reconnectAttempts;

  DateTime startedAt;
  DateTime stoppedAt;
  DateTime pingedAt;
  DateTime disconnectedAt;

  ConnectionMonitor(this.connection) : reconnectAttempts = 0;

  void start() {
    if (!this.isRunning()) {
      this.startedAt = new DateTime.now();
      this.stoppedAt = null;
      this.startPolling();
      // addEventListener("visibilitychange", this.visibilityDidChange);
      Logger.log(
          'ConnectionMonitor started. pollInterval = ${this.getPollInterval()} ms');
    }
  }

  void stop() {
    if (this.isRunning()) {
      this.stoppedAt = new DateTime.now();
      this.stopPolling();
      // removeEventListener("visibilitychange", this.visibilityDidChange);
      Logger.log('ConnectionMonitor stopped');
    }
  }

  bool isRunning() {
    return (this.startedAt != null) && (this.stoppedAt == null);
  }

  void recordPing() {
    this.pingedAt = new DateTime.now();
  }

  void recordConnect() {
    this.reconnectAttempts = 0;
    this.recordPing();
    this.disconnectedAt = null;
    Logger.log("ConnectionMonitor recorded connect");
  }

  void recordDisconnect() {
    this.disconnectedAt = new DateTime.now();
    Logger.log("ConnectionMonitor recorded disconnect");
  }

  // private part. Refactor func to _func

  void startPolling() {
    this.stopPolling();
    this.poll();
  }

  void stopPolling() {
    // clearTimeout(this.pollTimeout) // Add timeout for polling
  }

  void poll() {
    // this.pollTimeout = setTimeout(() {
    //   this.reconnectIfStale();
    //   this.poll();
    // }, this.getPollInterval());
  }

  getPollInterval() {
    // const {min, max, multiplier} = this.constructor.pollInterval
    // const interval = multiplier * Math.log(this.reconnectAttempts + 1)
    // return Math.round(clamp(interval, min, max) * 1000)
  }
}

// const secondsSince = time => (now() - time) / 1000

// const clamp = (number, min, max) => Math.max(min, Math.min(max, number))

// class ConnectionMonitor {

//   // Private

//   getPollInterval() {
//     const {min, max, multiplier} = this.constructor.pollInterval
//     const interval = multiplier * Math.log(this.reconnectAttempts + 1)
//     return Math.round(clamp(interval, min, max) * 1000)
//   }

//   reconnectIfStale() {
//     if (this.connectionIsStale()) {
//       logger.log(`ConnectionMonitor detected stale connection. reconnectAttempts = ${this.reconnectAttempts}, pollInterval = ${this.getPollInterval()} ms, time disconnected = ${secondsSince(this.disconnectedAt)} s, stale threshold = ${this.constructor.staleThreshold} s`)
//       this.reconnectAttempts++
//       if (this.disconnectedRecently()) {
//         logger.log("ConnectionMonitor skipping reopening recent disconnect")
//       } else {
//         logger.log("ConnectionMonitor reopening")
//         this.connection.reopen()
//       }
//     }
//   }

//   connectionIsStale() {
//     return secondsSince(this.pingedAt ? this.pingedAt : this.startedAt) > this.constructor.staleThreshold
//   }

//   disconnectedRecently() {
//     return this.disconnectedAt && (secondsSince(this.disconnectedAt) < this.constructor.staleThreshold)
//   }

//   visibilityDidChange() {
//     if (document.visibilityState === "visible") {
//       setTimeout(() => {
//         if (this.connectionIsStale() || !this.connection.isOpen()) {
//           logger.log(`ConnectionMonitor reopening stale connection on visibilitychange. visbilityState = ${document.visibilityState}`)
//           this.connection.reopen()
//         }
//       }
//       , 200)
//     }
//   }

// }

// ConnectionMonitor.pollInterval = {
//   min: 3,
//   max: 30,
//   multiplier: 5
// }

// ConnectionMonitor.staleThreshold = 6 // Server::Connections::BEAT_INTERVAL * 2 (missed two pings)

import 'dart:async';
import 'dart:math' as math;

import 'connection.dart';
import 'utils/logger.dart';
import 'utils/helpers.dart';

/// Responsible for ensuring the cable connection is in good health by validating the heartbeat pings sent
/// from the server, and attempting revival reconnections if things go astray. Internal class, not intended
/// for direct user manipulation.

class ConnectionMonitor {
  Connection connection;
  int reconnectAttempts;

  DateTime startedAt;
  DateTime stoppedAt;
  DateTime pingedAt;
  DateTime disconnectedAt;

  Timer pollTimeout;

  static const int staleThreshold = 6;
  static const int minPollInterval = 3;
  static const int maxPollInterval = 30;
  static const int pollIntervalMiltiplier = 5;

  ConnectionMonitor(this.connection) : reconnectAttempts = 0;

  void start() {
    if (!this.isRunning()) {
      this.startedAt = now();
      this.stoppedAt = null;
      this._startPolling();
      Logger.log(
          'ConnectionMonitor started. pollInterval = ${this._getPollInterval()} s');
    }
  }

  void stop() {
    if (this.isRunning()) {
      this.stoppedAt = now();
      this._stopPolling();
      Logger.log('ConnectionMonitor stopped');
    }
  }

  bool isRunning() {
    return (this.startedAt != null) && (this.stoppedAt == null);
  }

  void recordPing() {
    this.pingedAt = now();
  }

  void recordConnect() {
    this.reconnectAttempts = 0;
    this.recordPing();
    this.disconnectedAt = null;
    Logger.log("ConnectionMonitor recorded connect");
  }

  void recordDisconnect() {
    this.disconnectedAt = now();
    Logger.log("ConnectionMonitor recorded disconnect");
  }

  void _startPolling() {
    this._stopPolling();
    this._poll();
  }

  void _stopPolling() {
    if (this.pollTimeout != null) pollTimeout.cancel();
  }

  void _poll() {
    this.pollTimeout =
        new Timer(new Duration(seconds: this._getPollInterval()), () {
      this._reconnectIfStale();
      this._poll();
    });
  }

  int _getPollInterval() {
    int interval =
        pollIntervalMiltiplier * math.log(this.reconnectAttempts + 1) ~/ 1;
    return clamp(interval, minPollInterval, maxPollInterval);
  }

  void _reconnectIfStale() {
    if (this._connectionIsStale()) {
      Logger.log(
          'ConnectionMonitor detected stale connection. reconnectAttempts = ${this.reconnectAttempts}, pollInterval = ${this._getPollInterval()} ms, time disconnected = ${secondsSince(this.disconnectedAt)} s, stale threshold = ${staleThreshold} s');
      this.reconnectAttempts++;
      if (this._disconnectedRecently()) {
        Logger.log("ConnectionMonitor skipping reopening recent disconnect");
      } else {
        Logger.log("ConnectionMonitor reopening");
        this.connection.reopen();
      }
    }
  }

  bool _connectionIsStale() {
    return secondsSince(this.pingedAt ?? this.startedAt) > staleThreshold;
  }

  bool _disconnectedRecently() {
    return (this.disconnectedAt != null) &&
        (secondsSince(this.disconnectedAt) < staleThreshold);
  }
}

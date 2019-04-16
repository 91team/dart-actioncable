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
    if (!isRunning()) {
      startedAt = now();
      stoppedAt = null;
      _startPolling();
      Logger.log(
          'ConnectionMonitor started. pollInterval = ${_getPollInterval()} s');
    }
  }

  void stop() {
    if (isRunning()) {
      stoppedAt = now();
      _stopPolling();
      Logger.log('ConnectionMonitor stopped');
    }
  }

  bool isRunning() {
    return (startedAt != null) && (stoppedAt == null);
  }

  void recordPing() {
    pingedAt = now();
  }

  void recordConnect() {
    reconnectAttempts = 0;
    recordPing();
    disconnectedAt = null;
    Logger.log("ConnectionMonitor recorded connect");
  }

  void recordDisconnect() {
    disconnectedAt = now();
    Logger.log("ConnectionMonitor recorded disconnect");
  }

  void _startPolling() {
    _stopPolling();
    _poll();
  }

  void _stopPolling() {
    if (pollTimeout != null) pollTimeout.cancel();
  }

  void _poll() {
    pollTimeout = new Timer(new Duration(seconds: _getPollInterval()), () {
      _reconnectIfStale();
      _poll();
    });
  }

  int _getPollInterval() {
    int interval =
        pollIntervalMiltiplier * math.log(reconnectAttempts + 1) ~/ 1;
    return clamp(interval, minPollInterval, maxPollInterval);
  }

  void _reconnectIfStale() {
    if (_connectionIsStale()) {
      Logger.log(
          'ConnectionMonitor detected stale connection. reconnectAttempts = ${reconnectAttempts}, pollInterval = ${_getPollInterval()} ms, time disconnected = ${secondsSince(disconnectedAt)} s, stale threshold = ${staleThreshold} s');
      reconnectAttempts++;
      if (_disconnectedRecently()) {
        Logger.log("ConnectionMonitor skipping reopening recent disconnect");
      } else {
        Logger.log("ConnectionMonitor reopening");
        connection.reopen();
      }
    }
  }

  bool _connectionIsStale() {
    return secondsSince(pingedAt ?? startedAt) > staleThreshold;
  }

  bool _disconnectedRecently() {
    return (disconnectedAt != null) &&
        (secondsSince(disconnectedAt) < staleThreshold);
  }
}

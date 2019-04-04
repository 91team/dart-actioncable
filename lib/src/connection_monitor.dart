import 'connection.dart';

class ConnectionMonitor {
  Connection connection;

  ConnectionMonitor(this.connection);

  bool stop() {
    return true;
  }
}

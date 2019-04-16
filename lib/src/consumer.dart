import 'connection.dart';
import 'subscriptions.dart';

class Consumer {
  Subscriptions subscriptions;
  Connection connection;
  String host;
  int port;
  String cablePath;

  Consumer({this.host, this.port = 80, this.cablePath = 'cable'}) {
    subscriptions = new Subscriptions(this);
    connection = new Connection(this);
  }

  bool send(data) {
    return connection.send(data);
  }

  Future<bool> connect() async {
    return await connection.open();
  }

  Future<bool> disconnect() async {
    return await connection.close(allowReconnect: false);
  }

  Future<bool> ensureActiveConnection() async {
    if (!connection.isActive()) {
      return await connection.open();
    }
    return true;
  }
}

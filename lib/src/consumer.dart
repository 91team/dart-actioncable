import 'connection.dart';
import 'subscriptions.dart';

class Consumer {
  Subscriptions subscriptions;
  Connection connection;
  String host;
  int port;
  String cablePath;

  Consumer({this.host, this.port = 80, this.cablePath = 'cable'}) {
    this.subscriptions = new Subscriptions(this);
    this.connection = new Connection(this);
  }

  bool send(data) {
    return this.connection.send(data);
  }

  Future<bool> connect() async {
    return await this.connection.open();
  }

  Future<bool> disconnect() async {
    return await this.connection.close(allowReconnect: false);
  }

  Future<bool> ensureActiveConnection() async {
    if (!this.connection.isActive()) {
      return await this.connection.open();
    }
    return true;
  }
}

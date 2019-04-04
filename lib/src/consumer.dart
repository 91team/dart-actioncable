import 'connection.dart';
import 'subscriptions.dart';

class Consumer {
  String url;
  Subscriptions subscriptions;
  Connection connection;

  Consumer(this.url) {
    this.subscriptions = new Subscriptions(this);
    this.connection = new Connection(this);
  }

  bool send(data) {
    return this.connection.send(data);
  }

  Future<bool> connect() async {
    return await this.connection.open();
  }

  // define type
  disconnect() async {
    return await this.connection.close(allowReconnect: false);
  }

  Future<bool> ensureActiveConnection() async {
    if (!this.connection.isActive()) {
      return await this.connection.open();
    }
    return true;
  }
}

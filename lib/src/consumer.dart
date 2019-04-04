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

  bool connect() {
    return this.connection.open();
  }

  // define type
  disconnect() {
    return this.connection.close(allowReconnect: false);
  }

  bool ensureActiveConnection() {
    if (!this.connection.isActive()) {
      return this.connection.open();
    }
    return true;
  }
}

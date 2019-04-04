import 'connection.dart';
import 'subscriptions.dart';

class Consumer {
  String url;
  Subscriptions subscriptions;
  Connection conection;

  Consumer(this.url) {
    this.subscriptions = new Subscriptions(this);
    this.conection = new Connection(this);
  }

  getUrl() {
    // return createWebSocketURL(this.url);
  }

  send(data) {
    // return this.connection.send(data);
  }

  connect() {
    // return this.connection.open();
  }

  disconnect() {
    // return this.connection.close({allowReconnect: false});
  }

  ensureActiveConnection() {
    // if (!this.connection.isActive()) {
    //   return this.connection.open();
    // }
  }
}

// export function createWebSocketURL(url) {
//   if (typeof url === "function") {
//     url = url()
//   }

//   if (url && !/^wss?:/i.test(url)) {
//     const a = document.createElement("a")
//     a.href = url
//     // Fix populating Location properties in IE. Otherwise, protocol will be blank.
//     a.href = a.href
//     a.protocol = a.protocol.replace("http", "ws")
//     return a.href
//   } else {
//     return url
//   }
// }

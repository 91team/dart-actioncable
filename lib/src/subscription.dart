import 'dart:convert' as convert;
import 'consumer.dart';

class Subscription {
  Consumer consumer;
  String identifier;

  Subscription(this.consumer, dynamic params) {
    identifier = convert.jsonEncode(params);
  }

  // Perform a channel action with the optional data passed as an attribute
  bool perform(String action, [Map data]) {
    Map<String, dynamic> dataToSend = data ?? new Map();
    dataToSend['action'] = action;
    return this.send(dataToSend);
  }

  bool send(Map<String, dynamic> data) {
    Map params = {
      'command': "message",
      'identifier': this.identifier,
      'data': convert.jsonEncode(data)
    };
    return this.consumer.send(params);
  }

  Subscription unsubscribe() {
    return this.consumer.subscriptions.remove(this);
  }
}

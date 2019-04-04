import 'dart:convert' as convert;
import 'consumer.dart';

class Subscription {
  Consumer consumer;
  String identifier;

  // extend
  Subscription(this.consumer, dynamic params) {
    identifier = convert.jsonEncode(params);
  }

  // Perform a channel action with the optional data passed as an attribute
  perform(dynamic action, [Object data = '']) {
    // data.action = action
    // return this.send(data)
  }

  send(data) {
    Map params = {
      'command': "message",
      'identifier': this.identifier,
      'data': convert.jsonEncode(data)
    };
    return this.consumer.send(params);
  }

  unsubscribe() {
    return this.consumer.subscriptions.remove(this);
  }
}

// const extend = function(object, properties) {
//   if (properties != null) {
//     for (let key in properties) {
//       const value = properties[key]
//       object[key] = value
//     }
//   }
//   return object
// }

// export default class Subscription {
//   constructor(consumer, params = {}, mixin) {
//     this.consumer = consumer
//     this.identifier = JSON.stringify(params)
//     extend(this, mixin)
//   }
// }

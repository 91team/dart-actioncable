import 'consumer.dart';
import 'subscription.dart';

// Collection class for creating (and internally managing) channel subscriptions. The only method intended to be triggered by the user
// us ActionCable.Subscriptions#create, and it should be called through the consumer like so:
//
//   App = {}
//   App.cable = ActionCable.createConsumer("ws://example.com/accounts/1")
//   App.appearance = App.cable.subscriptions.create("AppearanceChannel")
//
// For more details on how you'd configure an actual channel subscription, see ActionCable.Subscription.

class Subscriptions {
  Consumer consumer;
  List<Subscription> subscriptions;

  Subscriptions(this.consumer) : subscriptions = [];

  Subscription create(String channelName) {
    String channel = channelName;
    // get params instead of channelName
    // const params = typeof channel === "object" ? channel : {channel};
    Subscription subscription = new Subscription(this.consumer, channel);
    return this.add(subscription);
  }

  Subscription add(subscription) {
    this.subscriptions.add(subscription);
    this.consumer.ensureActiveConnection();
    this.notify(subscription, "initialized");
    this.sendCommand(subscription, "subscribe");
    return subscription;
  }

  Subscription remove(Subscription subscription) {
    this.forget(subscription);
    if (this.findAll(subscription.identifier).length != 0) {
      this.sendCommand(subscription, "unsubscribe");
    }
    return subscription;
  }

  List<Subscription> reject(identifier) {
    return this.findAll(identifier).map((subscription) {
      this.forget(subscription);
      this.notify(subscription, "rejected");
      return subscription;
    });
  }

  Subscription forget(subscription) {
    this.subscriptions =
        (this.subscriptions.where((sub) => sub != subscription));
    return subscription;
  }

  List<Subscription> findAll(identifier) {
    return this.subscriptions.where((s) => s.identifier == identifier);
  }

  // define types
  reload() {
    return this
        .subscriptions
        .map((subscription) => this.sendCommand(subscription, "subscribe"));
  }

  // define types
  notifyAll(callbackName, args) {
    return this
        .subscriptions
        .map((subscription) => this.notify(subscription, callbackName, args));
  }

  // it may cause troubles
  // define types
  notify(Subscription subscription, String callbackName, [dynamic args]) {
    List subscriptions;
    if (subscription is String) {
      subscriptions = this.findAll(subscription);
    } else {
      subscriptions = [subscription];
    }
    return subscriptions.map((subscription) =>
        (subscription[callbackName] is Function
            ? subscription[callbackName](args)
            : null));
  }

  bool sendCommand(Subscription subscription, String command) {
    String identifier = subscription.identifier;
    return this.consumer.send({command, identifier});
  }
}

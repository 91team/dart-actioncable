import 'consumer.dart';
import 'subscription.dart';

/// Collection class for creating (and internally managing) channel subscriptions. The only method intended to be triggered by the user
/// us ActionCable.Subscriptions#create, and it should be called through the consumer like so:
///
///   App = {}
///   App.cable = ActionCable.createConsumer("ws://example.com/accounts/1")
///   App.appearance = App.cable.subscriptions.create("AppearanceChannel")
///
/// For more details on how you'd configure an actual channel subscription, see ActionCable.Subscription.

class Subscriptions {
  Consumer consumer;
  List<Subscription> subscriptions;

  Subscriptions(this.consumer) : subscriptions = [];

  Future<Subscription> create(String channelName) async {
    Map<String, dynamic> params = {'channel': channelName};

    Subscription subscription = new Subscription(this.consumer, params);
    return await this.add(subscription);
  }

  Future<Subscription> add(subscription) async {
    this.subscriptions.add(subscription);
    await this.consumer.ensureActiveConnection();
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

  List<Subscription> reject(String identifier) {
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
    return this.subscriptions.where((s) => s.identifier == identifier).toList();
  }

  void reload() {
    this
        .subscriptions
        .map((subscription) => this.sendCommand(subscription, "subscribe"));
  }

  void notifyAll(callbackName, notification) {
    this.subscriptions.map((subscription) =>
        this.notify(subscription, callbackName, notification));
  }

  void notify(dynamic subscription, String callbackName,
      [dynamic notification]) {
    if (subscription is! Subscription && subscription is! String) {
      throw Exception(
          'Expected Subscription or subscription identifier (string) as first param, but got ${subscription.runtimeType.toString()}');
    }
    List subscriptions;
    if (subscription is String) {
      subscriptions = this.findAll(subscription);
    } else {
      subscriptions = [subscription];
    }

    // TODO: implement it some another way
    subscriptions.map((subscription) => (subscription[callbackName] is Function
        ? subscription[callbackName](notification)
        : null));
  }

  bool sendCommand(Subscription subscription, String command) {
    String identifier = subscription.identifier;
    return this.consumer.send({'command': command, 'identifier': identifier});
  }
}

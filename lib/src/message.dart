abstract class Message {
  String type;
}

class WelcomeMessage extends Message {
  WelcomeMessage(String type) {
    this.type = type;
  }
}

class PingMessage extends Message {
  String message; // seems to be a timestamp

  PingMessage({String type, this.message}) {
    this.type = type;
  }
}

class SubscriptionConfirmationMessage extends Message {
  String identifier;

  SubscriptionConfirmationMessage({String type, this.identifier}) {
    this.type = type;
  }
}

typedef void InitializationHandler();
typedef void ConnectionHandler();
typedef void ReceptionHandler(Map<String, dynamic> message);
typedef void RejectionHandler(dynamic error);

class SubscriptionEventHandlers {
  InitializationHandler onInitialized;
  ConnectionHandler onConnected;
  ReceptionHandler onReceived;
  RejectionHandler onRejected;

  SubscriptionEventHandlers(
      {this.onInitialized, this.onConnected, this.onReceived, this.onRejected});

  bool get isInitializationHandled {
    return (this.onInitialized != null);
  }

  bool get isConnectionHandled {
    return (this.onConnected != null);
  }

  bool get isReceptionHandled {
    return (this.onReceived != null);
  }

  bool get isRejectionHandled {
    return (this.onRejected != null);
  }
}

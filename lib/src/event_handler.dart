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
    return (onInitialized != null);
  }

  bool get isConnectionHandled {
    return (onConnected != null);
  }

  bool get isReceptionHandled {
    return (onReceived != null);
  }

  bool get isRejectionHandled {
    return (onRejected != null);
  }
}

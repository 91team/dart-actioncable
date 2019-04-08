import 'dart:io';

class MessageType {
  static const welcome = 'welcome';
  static const disconnect = 'disconnect';
  static const ping = 'ping';
  static const confirmation = 'confirmation';
  static const rejection = 'rejection';
}

class DisconectReasons {
  static const unauthorized = 'unauthorized';
  static const invalid_request = 'invalid_request';
  static const server_restart = 'server_restart';
}

enum SubscriptionEventType { connected, received, initialized, rejected }

Map<String, int> wsStates = {
  'connecting': WebSocket.connecting,
  'open': WebSocket.open,
  'closing': WebSocket.closing,
  'closed': WebSocket.closed
};

List<String> protocols = ["actioncable-v1-json", "actioncable-unsupported"];

String defaultMauntPath = '/cable';

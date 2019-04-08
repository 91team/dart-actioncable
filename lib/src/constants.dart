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

Map<String, int> wsStates = {
  'connecting': 0,
  'open': 1,
  'closing': 2,
  'closed': 3
};

List<String> protocols = ["actioncable-v1-json", "actioncable-unsupported"];

String defaultMauntPath = '/cable';

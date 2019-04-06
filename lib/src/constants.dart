enum MessageType { welcome, disconnect, ping, confirmation, rejection }
enum DisconectReasons { unauthorized, invalid_request, server_restart }

Map<String, int> wsStates = {
  'connecting': 0,
  'open': 1,
  'closing': 2,
  'closed': 3
};

List<String> protocols = ["actioncable-v1-json", "actioncable-unsupported"];

String defaultMauntPath = '/cable';

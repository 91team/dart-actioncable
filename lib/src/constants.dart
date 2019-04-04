enum MessageType { welcome, disconnect, ping, confirmation, rejection }
enum DisconectReasons { unauthorized, invalid_request, server_restart }

List<String> protocols = ["actioncable-v1-json", "actioncable-unsupported"];

String defaultMauntPath = '/cable';

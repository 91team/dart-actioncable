export 'src/event_handler.dart';
export 'src/subscription.dart';
export 'src/consumer.dart';
import 'src/consumer.dart';
import 'src/utils/logger.dart';

Consumer createConsumer(
    {String host,
    int port = 80,
    String cablePath = 'cable',
    bool enableLogs = false}) {
  if (enableLogs) Logger.enable();
  return new Consumer(host: host, port: port, cablePath: cablePath);
}

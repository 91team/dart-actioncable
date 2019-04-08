export 'src/event_handler.dart';
export 'src/subscription.dart';
export 'src/consumer.dart';
import 'src/consumer.dart';
import 'src/utils/logger.dart';

Consumer createConsumer(String url, {bool enableLogs = false}) {
  if (enableLogs) Logger.enable();
  return new Consumer(url);
}

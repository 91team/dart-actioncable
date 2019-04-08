export 'src/event_handler.dart';
export 'src/subscription.dart';
export 'src/consumer.dart';
import 'src/consumer.dart';

Consumer createConsumer(String url) {
  return new Consumer(url);
}

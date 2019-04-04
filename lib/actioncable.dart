// export 'src/connection.dart';
export 'src/connection_monitor.dart';
export 'src/consumer.dart';
export 'src/subscription.dart';
export 'src/subscriptions.dart';
export 'src/adapters.dart';
export 'src/logger.dart';

import 'src/consumer.dart';

Consumer createConsumer(String url) {
  return new Consumer(url);
}

// export function getConfig(name) {
//   const element = document.head.querySelector(`meta[name='action-cable-${name}']`)
//   if (element) {
//     return element.getAttribute("content")
//   }
// }

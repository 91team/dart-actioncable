export 'src/consumer.dart';
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

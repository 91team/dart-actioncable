import 'dart:math' as math;

DateTime now() => new DateTime.now();

int secondsSince(DateTime time) =>
    (now().millisecond - time.millisecond) ~/ 1000;

int clamp(int number, int min, int max) => math.max(min, math.min(max, number));

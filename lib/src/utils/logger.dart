class Logger {
  static bool _isEnabled = false;

  static void log(String message) {
    if (_isEnabled) {
      print('[ActionCable] $message [${new DateTime.now()}]');
    }
  }

  static void enable() {
    _isEnabled = true;
  }

  static void disable() {
    _isEnabled = false;
  }
}

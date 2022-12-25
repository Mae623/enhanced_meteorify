import 'package:logger/logger.dart';

import 'reconnect_listener.dart';

class ReconnectListenersHolder implements ReconnectListener {
  List<ReconnectListener> _listeners = [];
  Logger l = Logger();

  void addReconnectListener(ReconnectListener? listener) {
    if (listener == null) {
      return;
    }

    removeReconnectListener(listener);
    _listeners.add(listener);
  }

  void removeReconnectListener(ReconnectListener? listener) {
    if (listener == null) {
      return;
    }
    _listeners.remove(listener);
  }

  void onReconnectBegin() {
    _listeners.forEach((listener) {
      try {
        listener.onReconnectBegin();
      } catch (exception) {
        l.v(exception);
      }
    });
  }

  void onReconnectDone() {
    _listeners.forEach((listener) {
      try {
        listener.onReconnectDone();
      } catch (exception) {
        l.v(exception);
      }
    });
  }

  void onConnected() {
    _listeners.forEach((listener) {
      try {
        listener.onConnected();
      } catch (exception) {
        l.v(exception);
      }
    });
  }
}

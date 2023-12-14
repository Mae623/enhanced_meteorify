import 'dart:convert';

class Message {
  static String connect(String? session, String version, List<String> support) {
    if (session != null) {
      return json.encode({
        "msg": "connect",
        "version": version,
        "support": support,
        "session": session
      });
    }

    return json.encode({
      "msg": "connect",
      "version": version,
      "support": support,
    });
  }

  static String sub(String id, String subName, List<dynamic> args) {
    return json.encode({
      'msg': 'sub',
      'name': subName,
      'params': args,
      'id': id,
    });
  }

  static String method(
      {required String id, required methodName, required List<dynamic> args}) {
    return json.encode({
      'msg': 'method',
      'method': methodName,
      'params': args,
      'id': id,
    });
  }

  static String unSub(String id) {
    return json.encode({'msg': 'unsub', 'id': id});
  }

  static String ping() {
    return json.encode({'msg': 'ping'});
  }

  static String pong() {
    return json.encode({'msg': 'pong'});
  }
}

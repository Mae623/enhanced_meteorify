import 'package:logger/logger.dart';
import 'package:tuple/tuple.dart';

final Logger l = Logger();

typedef UpdateListener = void Function(
  String collection,
  String operation,
  String id,
  Map<String, dynamic> doc,
);

Tuple2<String, Map<String, dynamic>> _parse(Map<String, dynamic> update) {
  if (update.containsKey('id')) {
    final String _id = update['id'] as String;
    if (_id.runtimeType == String) {
      Map? _cleared;
      dynamic _updates;

      if (update.containsKey('cleared')) {
        final List _updates = update['cleared'] as List;
        _cleared = {for (var e in _updates) e: null};
      }

      if (update.containsKey('fields')) {
        _updates = update['fields'];
      }

      if (_updates is Map) {
        if (_cleared != null) {
          _updates.addAll(Map<String, dynamic>.from(_cleared));
        }
        return Tuple2(_id, _updates as Map<String, dynamic>);
      } else {
        if (_cleared != null) {
          return Tuple2(_id, Map<String, dynamic>.from(_cleared));
        } else {
          return Tuple2(_id, Map<String, dynamic>.from({}));
        }
      }
    }
  }
  return Tuple2('', Map<String, dynamic>.from({}));
}

abstract class Collection {
  void notify(String operation, String id, Map<String, dynamic> doc);

  void added(Map<String, dynamic> doc);

  void changed(Map<String, dynamic> doc);

  void removed(Map<String, dynamic> doc);

  void reset();

  void init();

  void clear();

  void addUpdateListener(UpdateListener listener);

  void removeUpdateListeners();

  void removeSingleListener(UpdateListener listener);

  Map<String, Map<String, dynamic>> findAll();

  Map<String, dynamic> findOne(String id);

  factory Collection.mock() => _MockCache();

  factory Collection.key(String name) => KeyCache(name, {}, {});
}

class KeyCache implements Collection {
  String name;
  Map<String, Map<String, dynamic>> items;
  Set<UpdateListener> _listeners;

  KeyCache(this.name, this.items, this._listeners);

  @override
  void notify(String operation, String id, Map<String, dynamic> doc) {
    this._listeners.forEach((listener) {
      listener(this.name, operation, id, doc);
    });
  }

  @override
  void added(Map<String, dynamic> doc) {
    final Tuple2<String, Map<String, dynamic>> _pair = _parse(doc);
    if (_pair.item2.isNotEmpty) {
      this.items[_pair.item1] = _pair.item2;
      this.notify('create', _pair.item1, _pair.item2);
    }
  }

  @override
  void changed(Map<String, dynamic> doc) {
    final Tuple2<String, Map<String, dynamic>> _pair = _parse(doc);
    // ignore: unnecessary_null_comparison
    if (_pair.item2 != null) {
      if (this.items.containsKey((_pair.item1))) {
        final Map<String, dynamic>? _item = this.items[_pair.item1];
        _pair.item2.forEach((String key, value) {
          if (value == null) {
            _item!.remove(key);
          } else {
            _item![key] = value;
          }
        });
        this.items[_pair.item1] = _item as Map<String, dynamic>;
        this.notify('update', _pair.item1, _item);
      }
    }
  }

  @override
  void removed(Map<String, dynamic> doc) {
    final Tuple2<String, Map<String, dynamic>> _pair = _parse(doc);
    // ignore: unnecessary_null_comparison
    if (_pair.item1 != null) {
      final Map<String, dynamic>? _item = this.items[_pair.item1];
      this.items.remove(_pair.item1);
      this.notify('remove', _pair.item1, _item ?? Map<String, dynamic>());
    }
  }

  @override
  void reset() {
    this.notify('reset', '', Map<String, dynamic>());
  }

  @override
  void addUpdateListener(UpdateListener listener) {
    this._listeners.add(listener);
  }

  @override
  void removeUpdateListeners() {
    this._listeners.clear();
  }

  @override
  void init() {}

  @override
  Map<String, Map<String, dynamic>> findAll() => this.items;

  @override
  Map<String, dynamic> findOne(String id) => this.items[id]!;

  @override
  void removeSingleListener(UpdateListener listener) {
    this._listeners.remove(listener);
  }

  @override
  void clear() {
    items = {};
  }
}

class _MockCache implements Collection {
  @override
  void addUpdateListener(UpdateListener listener) {}

  @override
  void added(Map<String, dynamic> doc) {}

  @override
  void changed(Map<String, dynamic> doc) {}

  @override
  Map<String, Map<String, dynamic>> findAll() => {};

  @override
  Map<String, dynamic> findOne(String id) => {};

  @override
  void notify(String operation, String id, Map<String, dynamic> doc) {}

  @override
  void removeUpdateListeners() {}

  @override
  void removeSingleListener(UpdateListener listener) {}

  @override
  void removed(Map<String, dynamic> doc) {}

  @override
  void init() {}

  @override
  void reset() {}

  @override
  void clear() {}
}

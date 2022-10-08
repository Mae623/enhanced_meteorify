import 'package:logger/logger.dart';
import 'package:tuple/tuple.dart';

typedef UpdateListener = void Function(
  String collection,
  String operation,
  String id,
  Map<String, dynamic> doc,
);

Tuple2<String, Map<String, dynamic>> _parse(Map<String, dynamic> update) {
  final Logger l = Logger();
  l.v(update);
  if (update.containsKey('id')) {
    final _id = update['id'];
    l.v(_id);
    if (_id.runtimeType == String) {
      l.v('id is string');
      if (update.containsKey('fields')) {
        final _updates = update['fields'];
        l.v(_updates);
        if (_updates is Map) {
          l.v(Tuple2(_id, _updates as Map<String, dynamic>));
          return Tuple2(_id, _updates as Map<String, dynamic>);
        }
      }
      if (update.containsKey('cleared')) {
        final List cleared = update['cleared'];
        return Tuple2(_id, {cleared.first: null});
      }
      return Tuple2(_id, Map<String, dynamic>.from({}));
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
  Map<String, Map<String, dynamic>> _items;
  Set<UpdateListener> _listeners;

  KeyCache(this.name, this._items, this._listeners);

  @override
  void notify(String operation, String id, Map<String, dynamic> doc) {
    this._listeners.forEach((listener) {
      listener(this.name, operation, id, doc);
    });
  }

  @override
  void added(Map<String, dynamic> doc) {
    final _pair = _parse(doc);
    if (_pair.item2.isNotEmpty) {
      this._items[_pair.item1] = _pair.item2;
      this.notify('create', _pair.item1, _pair.item2);
    }
  }

  @override
  void changed(Map<String, dynamic> doc) {
    final l = Logger();
    final _pair = _parse(doc);
    l.v(_pair);
    // ignore: unnecessary_null_comparison
    if (_pair.item2 != null) {
      if (this._items.containsKey((_pair.item1))) {
        final _item = this._items[_pair.item1];
        l.v(_item);
        _pair.item2.forEach((key, value) {
          if (value == null) {
            _item!.remove(key);
            l.v(_item);
          } else {
            _item![key] = value;
          }
        });
        this._items[_pair.item1] = _item as Map<String, dynamic>;
        this.notify('update', _pair.item1, _item);
      }
    }
  }

  @override
  void removed(Map<String, dynamic> doc) {
    final _pair = _parse(doc);
    // ignore: unnecessary_null_comparison
    if (_pair.item1 != null) {
      this._items.remove(_pair.item1);
      this.notify('remove', _pair.item1, Map<String, dynamic>());
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
  Map<String, Map<String, dynamic>> findAll() => this._items;

  @override
  Map<String, dynamic> findOne(String id) => this._items[id]!;

  @override
  void removeSingleListener(UpdateListener listener) {
    this._listeners.remove(listener);
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
}

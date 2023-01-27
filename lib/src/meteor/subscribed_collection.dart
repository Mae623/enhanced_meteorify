import 'package:enhanced_meteorify/src/ddp/collection.dart';

/// Provides useful methods to read data from a collection on the frontend.
///
/// [SubscribedCollection] supports only read functionality useful in case of getting only the data subscribed by user and not any other data.
class SubscribedCollection {
  /// The internal collection instance.
  final Collection collection;

  /// Name of the collection.
  String name;

  /// Construct a subscribed collection.
  SubscribedCollection(this.collection, this.name);

  /// Returns a single object by matching the [id] of the object.
  Map<String, dynamic> findOne(String id) {
    return collection.findOne(id);
  }

  /// Returns all objects of the subscribed collection.
  Map<String, Map<String, dynamic>> findAll() {
    return collection.findAll();
  }

  void addUpdateListener(UpdateListener listener) {
    collection.addUpdateListener(listener);
  }

  void removeUpdateListeners() {
    collection.removeUpdateListeners();
  }

  void removeSingleListener(UpdateListener listener) {
    collection.removeSingleListener(listener);
  }

  void clear() {
    collection.clear();
  }

  /// Returns specific objects from a subscribed collection using a set of [selectors].
  Map<String, Map<String, dynamic>> find(Map<String, dynamic> selectors) {
    var filteredCollection = <String, Map<String, dynamic>>{};
    collection.findAll().forEach((key, document) {
      var shouldAdd = true;
      selectors.forEach((selector, value) {
        if (document[selector] != value) {
          shouldAdd = false;
        }
      });
      if (shouldAdd) {
        filteredCollection[key] = document;
      } else {
        print("Don't add");
      }
    });
    collection.init();
    return filteredCollection;
  }
}

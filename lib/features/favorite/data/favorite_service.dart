import 'package:flutter/foundation.dart';

import '../../home/presentation/models/shop_data.dart';

class FavoriteService extends ChangeNotifier {
  FavoriteService._();
  static final FavoriteService instance = FavoriteService._();

  final Map<String, Product> _items = {};

  List<Product> get items => List.unmodifiable(_items.values);

  int get count => _items.length;

  String _keyOf(Product product) =>
      product.id.isNotEmpty ? product.id : product.name;

  bool isFavorite(Product product) => _items.containsKey(_keyOf(product));

  void toggle(Product product) {
    final key = _keyOf(product);
    if (_items.containsKey(key)) {
      _items.remove(key);
    } else {
      _items[key] = product;
    }
    notifyListeners();
  }

  void remove(Product product) {
    if (_items.remove(_keyOf(product)) != null) notifyListeners();
  }
}

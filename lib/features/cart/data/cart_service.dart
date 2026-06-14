import 'package:flutter/material.dart';

import '../../home/presentation/models/shop_data.dart';
import '../presentation/models/cart_item.dart';

class CartService extends ChangeNotifier {
  CartService._();
  static final CartService instance = CartService._();

  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;
  int get distinctCount => _items.length;
  int get totalQuantity => _items.fold(0, (sum, i) => sum + i.quantity);

  void add(
    Product product, {
    int quantity = 1,
    Color? color,
    String colorName = 'Berown',
  }) {
    final swatch = color ?? product.swatch;
    final idx = _items.indexWhere(
      (i) => i.product.id == product.id && i.colorName == colorName,
    );
    if (idx >= 0) {
      _items[idx].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          product: product,
          quantity: quantity,
          color: swatch,
          colorName: colorName,
        ),
      );
    }
    notifyListeners();
  }

  void remove(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void increment(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  /// Decrements quantity; removes the line when it would drop below 1.
  void decrement(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  void toggleSelected(CartItem item) {
    item.selected = !item.selected;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  bool get hasSelection => _items.any((i) => i.selected);

  List<CartItem> get selectedItems =>
      _items.where((i) => i.selected).toList();

  double get subtotal => _items
      .where((i) => i.selected)
      .fold(0.0, (sum, i) => sum + i.lineTotal);

  double get shipping => hasSelection ? 6.0 : 0.0;

  double get total => subtotal + shipping;
}

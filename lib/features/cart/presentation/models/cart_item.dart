import 'package:flutter/material.dart';

import '../../../home/presentation/models/shop_data.dart';

class CartItem {
  final Product product;
  final Color color;
  final String colorName;
  int quantity;
  bool selected;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.color,
    this.colorName = 'Berown',
    this.selected = true,
  });

  double get lineTotal => product.price * quantity;
}

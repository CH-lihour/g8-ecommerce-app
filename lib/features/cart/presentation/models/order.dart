import 'package:flutter/material.dart';

import '../../../home/presentation/models/shop_data.dart';
import 'cart_item.dart';

enum OrderStatus { onProgress, completed }

extension OrderStatusLabel on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.onProgress:
        return 'On Progress';
      case OrderStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.onProgress:
        return const Color(0xFF2AD2C9);
      case OrderStatus.completed:
        return const Color(0xFF22C55E);
    }
  }
}

class OrderLine {
  final Product product;
  final String colorName;
  final Color color;
  final int quantity;
  final double total;
  OrderStatus status;

  OrderLine({
    required this.product,
    required this.colorName,
    required this.color,
    required this.quantity,
    required this.total,
    this.status = OrderStatus.onProgress,
  });

  factory OrderLine.fromCartItem(CartItem item) => OrderLine(
        product: item.product,
        colorName: item.colorName,
        color: item.color,
        quantity: item.quantity,
        total: item.lineTotal,
      );
}

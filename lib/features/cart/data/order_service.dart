import 'package:flutter/material.dart';

import '../presentation/models/cart_item.dart';
import '../presentation/models/order.dart';

class OrderService extends ChangeNotifier {
  OrderService._();
  static final OrderService instance = OrderService._();

  final List<OrderLine> _orders = [];

  List<OrderLine> get orders => List.unmodifiable(_orders);

  List<OrderLine> get active =>
      _orders.where((o) => o.status == OrderStatus.onProgress).toList();

  List<OrderLine> get history =>
      _orders.where((o) => o.status == OrderStatus.completed).toList();

  void placeOrder(List<CartItem> items) {
    _orders.insertAll(0, items.map(OrderLine.fromCartItem));
    notifyListeners();
  }

  void markCompleted(OrderLine line) {
    if (line.status == OrderStatus.completed) return;
    line.status = OrderStatus.completed;
    notifyListeners();
  }
}

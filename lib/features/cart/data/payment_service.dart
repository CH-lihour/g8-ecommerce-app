import 'package:flutter/material.dart';

import '../presentation/models/payment_method.dart';

class PaymentService extends ChangeNotifier {
  PaymentService._();
  static final PaymentService instance = PaymentService._();

  final List<PaymentMethod> _methods = [
    const PaymentMethod(
      id: 'paypal',
      brand: PaymentBrand.paypal,
      label: 'Paypall',
      detail: 'sask****@email.com',
    ),
    const PaymentMethod(
      id: 'mastercard',
      brand: PaymentBrand.mastercard,
      label: 'Mastercard',
      detail: '4827 8472 7424 ****',
    ),
  ];

  String _selectedId = 'mastercard';

  List<PaymentMethod> get methods => List.unmodifiable(_methods);

  String get selectedId => _selectedId;

  PaymentMethod get selected =>
      _methods.firstWhere((m) => m.id == _selectedId, orElse: () => _methods.first);

  void select(String id) {
    if (_selectedId == id) return;
    _selectedId = id;
    notifyListeners();
  }

  void addCard({required String holder, required String number}) {
    final digits = number.replaceAll(RegExp(r'\s+'), '');
    final last4 = digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
    final method = PaymentMethod(
      id: 'card_${DateTime.now().millisecondsSinceEpoch}',
      brand: PaymentBrand.visa,
      label: holder.trim().isEmpty ? 'New Card' : holder.trim(),
      detail: '**** **** **** $last4',
    );
    _methods.add(method);
    _selectedId = method.id;
    notifyListeners();
  }
}

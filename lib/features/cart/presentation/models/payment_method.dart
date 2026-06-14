import 'package:flutter/material.dart';

import '../../../home/presentation/models/shop_data.dart';

enum PaymentBrand { paypal, mastercard, visa }

class PaymentMethod {
  final String id;
  final PaymentBrand brand;
  final String label;

  final String detail;

  const PaymentMethod({
    required this.id,
    required this.brand,
    required this.label,
    required this.detail,
  });

  IconData get icon {
    switch (brand) {
      case PaymentBrand.paypal:
        return Icons.account_balance_wallet_outlined;
      case PaymentBrand.mastercard:
      case PaymentBrand.visa:
        return Icons.credit_card;
    }
  }

  Color get tint {
    switch (brand) {
      case PaymentBrand.paypal:
        return const Color(0xFF1565C0);
      case PaymentBrand.mastercard:
        return const Color(0xFFEB001B);
      case PaymentBrand.visa:
        return kPrimary;
    }
  }
}

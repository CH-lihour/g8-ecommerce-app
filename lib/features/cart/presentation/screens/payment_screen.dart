import 'package:flutter/material.dart';

import '../../../home/presentation/models/shop_data.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../data/cart_service.dart';
import '../../data/order_service.dart';
import '../../data/payment_service.dart';
import '../models/address.dart';
import '../models/cart_item.dart';
import '../models/payment_method.dart';
import 'address_screen.dart';
import 'order_success_sheet.dart';
import 'payment_method_sheet.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _cart = CartService.instance;
  final _payment = PaymentService.instance;
  Address _address = kDefaultAddress;

  Future<void> _editAddress() async {
    final picked = await Navigator.of(context).push<Address>(
      MaterialPageRoute(builder: (_) => AddressScreen(selected: _address)),
    );
    if (picked != null) setState(() => _address = picked);
  }

  Future<void> _choosePaymentMethod() async {
    await PaymentMethodSheet.show(context);
  }

  Future<void> _placeOrder() async {
    OrderService.instance.placeOrder(_cart.selectedItems);
    final track = await OrderSuccessSheet.show(context);
    if (!mounted) return;
    _cart.clear();
    if (track == true) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(initialIndex: 1),
        ),
        (route) => false,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: kDarkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: kDarkText,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _cart,
        builder: (context, _) {
          final items = _cart.selectedItems;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              _sectionHeader('Address', action: 'Edit', onAction: _editAddress),
              const SizedBox(height: 12),
              _AddressCard(address: _address),
              const SizedBox(height: 24),
              _sectionHeader('Products (${items.length})'),
              const SizedBox(height: 12),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ProductRow(item: item),
                ),
              ),
              const SizedBox(height: 8),
              _sectionHeader('Payment Method'),
              const SizedBox(height: 12),
              ListenableBuilder(
                listenable: _payment,
                builder: (context, _) => _PaymentMethodCard(
                  method: _payment.selected,
                  onTap: _choosePaymentMethod,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total amount',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  _PriceText(value: _cart.total, large: true),
                ],
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: ListenableBuilder(
          listenable: _cart,
          builder: (context, _) => SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _cart.hasSelection ? _placeOrder : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: kPrimary.withValues(alpha: 0.4),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Checkout Now',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, {String? action, VoidCallback? onAction}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: kDarkText,
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kPrimary,
              ),
            ),
          ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;

  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E4E8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.location_on, color: kPrimary, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address.label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kDarkText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address.details,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductRow extends StatelessWidget {
  final CartItem item;

  const _ProductRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Thumbnail(item: item),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: kDarkText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Color: ${item.colorName}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        _PriceText(value: item.lineTotal),
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final CartItem item;

  const _Thumbnail({required this.item});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 56,
      height: 56,
      color: item.color,
      child: const Icon(Icons.image_outlined, color: Colors.white54, size: 24),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: item.product.imageUrl.isEmpty
          ? placeholder
          : Image.network(
              item.product.imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: 56,
                  height: 56,
                  color: item.color,
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (context, error, stack) => placeholder,
            ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final VoidCallback onTap;

  const _PaymentMethodCard({required this.method, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(method.icon, size: 22, color: method.tint),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kDarkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method.detail,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

/// Price rendered as a small superscript `$` next to the amount, matching the
/// design's "$ 67.00" treatment.
class _PriceText extends StatelessWidget {
  final double value;
  final bool large;

  const _PriceText({required this.value, this.large = false});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '\$ ',
            style: TextStyle(
              fontSize: large ? 13 : 11,
              fontWeight: FontWeight.bold,
              color: kDarkText,
            ),
          ),
          TextSpan(
            text: value.toStringAsFixed(2),
            style: TextStyle(
              fontSize: large ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: kDarkText,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../home/presentation/models/shop_data.dart';
import '../../data/cart_service.dart';
import '../models/cart_item.dart';
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cart = CartService.instance;
  final _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
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
          'My Cart',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: kDarkText,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.shopping_bag_outlined, color: kDarkText),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _cart,
        builder: (context, _) {
          if (_cart.isEmpty) return _buildEmpty();
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: _cart.items.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 28,
                    color: Colors.grey.shade200,
                  ),
                  itemBuilder: (_, i) => _CartTile(item: _cart.items[i]),
                ),
              ),
              _buildSummary(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 56,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildPromoField(),
              const SizedBox(height: 20),
              _summaryRow('Subtotal', _cart.subtotal),
              const SizedBox(height: 12),
              _summaryRow('Shipping', _cart.shipping),
              const SizedBox(height: 12),
              _dashedDivider(),
              const SizedBox(height: 12),
              _summaryRow('Total amount', _cart.total),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _cart.hasSelection ? _checkout : null,
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
                    'Checkout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(Icons.confirmation_number_outlined,
              size: 20, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _promoController,
              style: const TextStyle(fontSize: 14, color: kDarkText),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Enter your promo code',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ),
          ),
          GestureDetector(
            onTap: _applyPromo,
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward,
                  size: 18, color: kDarkText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value) {
    final emphasized = label == 'Total amount';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: emphasized ? 15 : 14,
            fontWeight: emphasized ? FontWeight.bold : FontWeight.w500,
            color: emphasized ? kDarkText : Colors.grey.shade600,
          ),
        ),
        _PriceText(value: value, large: emphasized),
      ],
    );
  }

  Widget _dashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.grey.shade300),
              ),
            ),
          ),
        );
      },
    );
  }

  void _applyPromo() {
    final code = _promoController.text.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          code.isEmpty ? 'Enter a promo code first' : 'Promo "$code" applied',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _checkout() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PaymentScreen()),
    );
  }
}

class _CartTile extends StatelessWidget {
  final CartItem item;

  const _CartTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Checkbox(
          value: item.selected,
          onTap: () => cart.toggleSelected(item),
        ),
        const SizedBox(width: 12),
        _Thumbnail(item: item),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                maxLines: 2,
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
              const SizedBox(height: 12),
              Row(
                children: [
                  _Stepper(item: item),
                  const Spacer(),
                  _PriceText(value: item.lineTotal),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Checkbox extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;

  const _Checkbox({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: value ? kPrimary : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: value ? kPrimary : Colors.grey.shade400,
              width: 1.5,
            ),
          ),
          child: value
              ? const Icon(Icons.check, size: 15, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final CartItem item;

  const _Thumbnail({required this.item});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 70,
      height: 70,
      color: item.color,
      child: const Icon(Icons.image_outlined, color: Colors.white54, size: 28),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: item.product.imageUrl.isEmpty
          ? placeholder
          : Image.network(
              item.product.imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: 70,
                  height: 70,
                  color: item.color,
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (context, error, stack) => placeholder,
            ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final CartItem item;

  const _Stepper({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepButton(Icons.remove, () => cart.decrement(item)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${item.quantity}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kDarkText,
              ),
            ),
          ),
          _stepButton(Icons.add, () => cart.increment(item)),
        ],
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: kDarkText),
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

import 'package:flutter/material.dart';
import '../../../cart/data/cart_service.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import '../models/shop_data.dart';
import 'store_screen.dart';

const List<Color> _kDetailColors = [
  Color(0xFF8C5A3B),
  Color(0xFF1A1A2E),
  Color(0xFF1FA2A6),
  Color(0xFF2ECC71),
];

const List<String> _kDetailColorNames = ['Brown', 'Black', 'Teal', 'Green'];

const String _kLoremDescription =
    'Lorem Ipsum is simply dummy text of the printing and typesetting '
    'industry. Lorem Ipsum has been the industry\'s standard dummy text ever '
    'since the 1500s, when an unknown printer took a galley of type and '
    'scrambled it to make a type specimen book.';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  int _colorIndex = 0;
  bool _descExpanded = false;

  Product get _product => widget.product;

  @override
  Widget build(BuildContext context) {
    final imageHeight = MediaQuery.of(context).size.height * 0.46;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomBar(),
      body: Stack(
        children: [
          SizedBox(
            height: imageHeight,
            width: double.infinity,
            child: _buildImage(),
          ),
          SafeArea(child: _buildTopBar()),
          Positioned.fill(
            top: imageHeight - 28,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: _buildSheet(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          _circleButton(
            Icons.arrow_back_ios_new,
            onTap: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'Detail Product',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: kDarkText,
              ),
            ),
          ),
          _circleButton(Icons.shopping_bag_outlined, onTap: _openCart),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: kDarkText),
      ),
    );
  }

  Widget _buildSheet() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                _product.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kDarkText,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildQuantityOrFavorite(),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.star, color: Color(0xFFFFC107), size: 18),
            const SizedBox(width: 4),
            const Text(
              '4.8',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kDarkText,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(320 Review)',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'Color',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: kDarkText,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(_kDetailColors.length, (i) {
            final selected = _colorIndex == i;
            return Padding(
              padding: const EdgeInsets.only(right: 14),
              child: GestureDetector(
                onTap: () => setState(() => _colorIndex = i),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _kDetailColors[i],
                    shape: BoxShape.circle,
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 22),
        _buildStoreRow(),
        const SizedBox(height: 22),
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: kDarkText,
          ),
        ),
        const SizedBox(height: 10),
        _buildDescription(),
      ],
    );
  }

  Widget _buildQuantityOrFavorite() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _stepButton(Icons.remove, () {
                if (_quantity > 1) setState(() => _quantity--);
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: kDarkText,
                  ),
                ),
              ),
              _stepButton(Icons.add, () => setState(() => _quantity++)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Avaliable in stock',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
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

  Widget _buildStoreRow() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.storefront, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      _product.seller.isEmpty ? 'Upbox Bag' : _product.seller,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kDarkText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.verified, size: 14, color: kPrimary),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '104 Products   1.3k Followers',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => StoreScreen(
                storeName: _product.seller.isEmpty
                    ? 'Upbox Bag'
                    : _product.seller,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Follow',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: Text(
            _kLoremDescription,
            maxLines: _descExpanded ? null : 3,
            overflow: _descExpanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.grey.shade500,
            ),
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => setState(() => _descExpanded = !_descExpanded),
          child: Text(
            _descExpanded ? 'Read Less' : 'Read More',
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

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Price',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${(_product.price * _quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                  label: const Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  void _addToCart() {
    CartService.instance.add(
      _product,
      quantity: _quantity,
      color: _kDetailColors[_colorIndex],
      colorName: _kDetailColorNames[_colorIndex],
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $_quantity × ${_product.name} to cart'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: _openCart,
        ),
      ),
    );
  }

  Widget _buildImage() {
    final placeholder = Container(
      color: _product.swatch,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Colors.white54, size: 64),
    );

    if (_product.imageUrl.isEmpty) return placeholder;

    return Image.network(
      _product.imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: _product.swatch,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(strokeWidth: 2),
        );
      },
      errorBuilder: (context, error, stack) => placeholder,
    );
  }
}

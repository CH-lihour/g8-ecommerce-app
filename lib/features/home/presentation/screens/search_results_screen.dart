import 'package:flutter/material.dart';
import '../../data/product_service.dart';
import '../models/shop_data.dart';
import 'product_detail_screen.dart';
import 'store_screen.dart';

enum _SortBy { all, latest, mostPopular, cheapest }

extension on _SortBy {
  String get label => switch (this) {
    _SortBy.all => 'All',
    _SortBy.latest => 'Latest',
    _SortBy.mostPopular => 'Most Popular',
    _SortBy.cheapest => 'Cheapest',
  };
}

const List<Color> _kFilterColors = [
  Color(0xFF1A1A2E),
  Color(0xFFCFC6F2),
  Color(0xFFC9DCF0),
  Color(0xFFEAD9B8),
  Color(0xFFF0CBCB),
];

const List<String> _kFilterLocations = ['San Diego', 'New York', 'Amsterdam'];

class _ProductFilter {
  final RangeValues? priceRange;
  final int? colorIndex;
  final String? location;

  const _ProductFilter({this.priceRange, this.colorIndex, this.location});

  bool get isActive =>
      priceRange != null || colorIndex != null || location != null;
}

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final _productService = ProductService();
  late final TextEditingController _controller;

  String _query = '';
  _SortBy _sort = _SortBy.all;
  _ProductFilter _filter = const _ProductFilter();

  List<Product>? _matches; 
  Object? _error;

  @override
  void initState() {
    super.initState();
    _query = widget.query;
    _controller = TextEditingController(text: widget.query);
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _matches = null;
      _error = null;
    });
    try {
      final results = await _productService.searchProducts(_query);
      if (!mounted) return;
      setState(() => _matches = results);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  void _runSearch(String query) {
    _query = query;
    _load();
  }

  double get _maxPrice {
    final matches = _matches;
    if (matches == null || matches.isEmpty) return 100;
    final max = matches.map((p) => p.price).reduce((a, b) => a > b ? a : b);
    return max <= 0 ? 100 : max.ceilToDouble();
  }

  List<Product> _visibleProducts(List<Product> matches) {
    var products = matches;

    final range = _filter.priceRange;
    if (range != null) {
      products = products
          .where((p) => p.price >= range.start && p.price <= range.end)
          .toList();
    } else {
      products = List<Product>.of(products);
    }

    switch (_sort) {
      case _SortBy.latest:
        products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortBy.cheapest:
        products.sort((a, b) => a.price.compareTo(b.price));
      case _SortBy.mostPopular:
        break;
      case _SortBy.all:
        break;
    }
    return products;
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<_ProductFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FilterSheet(initial: _filter, maxPrice: _maxPrice),
    );
    if (result != null) {
      setState(() => _filter = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildSearchBar(),
            const SizedBox(height: 18),
            _buildFilterChips(),
            const SizedBox(height: 16),
            _buildStoreRow(),
            const SizedBox(height: 8),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            color: kDarkText,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 46,
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: _runSearch,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.tune,
                      color: _filter.isActive ? kPrimary : Colors.grey.shade500,
                    ),
                    onPressed: _openFilterSheet,
                  ),
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kPrimary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kPrimary, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: _SortBy.values.map((sort) {
          final selected = sort == _sort;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _sort = sort),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: selected ? kPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? kPrimary : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  sort.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStoreRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const StoreScreen()),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.storefront, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Upbox Bag',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: kDarkText,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, size: 15, color: kPrimary),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '104 Products   1.3k Followers',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
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

  Widget _buildResults() {
    if (_error != null) {
      return Center(
        child: Text(
          'Could not load results.\n$_error',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    final matches = _matches;
    if (matches == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final products = _visibleProducts(matches);
    if (products.isEmpty) {
      final filtered = matches.isNotEmpty; 
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              filtered
                  ? 'No products match your filters'
                  : 'No results for "$_query"',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 18,
        crossAxisSpacing: 16,
        childAspectRatio: 0.62,
      ),
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: products[i]),
          ),
        ),
        child: _ResultCard(product: products[i]),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final _ProductFilter initial;
  final double maxPrice;

  const _FilterSheet({required this.initial, required this.maxPrice});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late RangeValues _price;
  late int? _colorIndex;
  late String? _location;

  @override
  void initState() {
    super.initState();
    _price = widget.initial.priceRange ?? RangeValues(0, widget.maxPrice);
    _price = RangeValues(
      _price.start.clamp(0, widget.maxPrice),
      _price.end.clamp(0, widget.maxPrice),
    );
    _colorIndex = widget.initial.colorIndex;
    _location = widget.initial.location;
  }

  void _apply() {
    final fullRange = _price.start == 0 && _price.end == widget.maxPrice;
    Navigator.of(context).pop(
      _ProductFilter(
        priceRange: fullRange ? null : _price,
        colorIndex: _colorIndex,
        location: _location,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Filter By',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kDarkText,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _label(
            'Price',
            '\$${_price.start.round()}-\$${_price.end.round()}',
          ),
          RangeSlider(
            values: _price,
            min: 0,
            max: widget.maxPrice,
            activeColor: kPrimary,
            inactiveColor: Colors.grey.shade200,
            labels: RangeLabels(
              '\$${_price.start.round()}',
              '\$${_price.end.round()}',
            ),
            onChanged: (v) => setState(() => _price = v),
          ),
          const SizedBox(height: 16),
          _label(
            'Color',
            _colorIndex == null
                ? 'Any'
                : (_colorIndex == 0 ? 'Black' : 'Selected'),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(_kFilterColors.length, (i) {
              final selected = _colorIndex == i;
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: GestureDetector(
                  onTap: () => setState(
                    () => _colorIndex = selected ? null : i,
                  ),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _kFilterColors[i],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? kPrimary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          _label('Location', _location ?? 'Any'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _kFilterLocations.map((loc) {
              final selected = _location == loc;
              return GestureDetector(
                onTap: () => setState(
                  () => _location = selected ? null : loc,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? kPrimary : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? kPrimary : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    loc,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Apply Filter',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: kDarkText,
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Product product;

  const _ResultCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildImage(),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_border,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          product.name,
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
          product.seller,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 6),
        Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: kDarkText,
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    final placeholder = Container(
      width: double.infinity,
      height: double.infinity,
      color: product.swatch,
      child: const Icon(Icons.image_outlined, color: Colors.white54, size: 40),
    );

    if (product.imageUrl.isEmpty) return placeholder;

    return Image.network(
      product.imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: product.swatch,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stack) => placeholder,
    );
  }
}

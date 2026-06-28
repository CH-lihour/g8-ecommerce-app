import 'package:flutter/material.dart';

import '../../../home/presentation/models/shop_data.dart';
import '../../../home/presentation/screens/product_detail_screen.dart';
import '../../../message/presentation/screens/message_list_screen.dart';
import '../../data/favorite_service.dart';

enum _FavFilter { all, latest, mostPopular, cheapest }

extension _FavFilterLabel on _FavFilter {
  String get label {
    switch (this) {
      case _FavFilter.all:
        return 'All';
      case _FavFilter.latest:
        return 'Latest';
      case _FavFilter.mostPopular:
        return 'Most Popular';
      case _FavFilter.cheapest:
        return 'Cheapest';
    }
  }
}

class FavoriteView extends StatefulWidget {
  const FavoriteView({super.key});

  @override
  State<FavoriteView> createState() => _FavoriteViewState();
}

class _FavoriteViewState extends State<FavoriteView> {
  final _favorites = FavoriteService.instance;
  final _searchController = TextEditingController();
  _FavFilter _filter = _FavFilter.all;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _visible() {
    var list = _favorites.items;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    } else {
      list = List.of(list);
    }
    switch (_filter) {
      case _FavFilter.all:
      case _FavFilter.mostPopular:
        break;
      case _FavFilter.latest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case _FavFilter.cheapest:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildFilters(),
          const SizedBox(height: 8),
          Expanded(
            child: ListenableBuilder(
              listenable: _favorites,
              builder: (context, _) {
                final products = _visible();
                if (products.isEmpty) return _buildEmpty();
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  itemCount: products.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.66,
                  ),
                  itemBuilder: (_, i) => _FavoriteCard(product: products[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          const Spacer(),
          const Text(
            'My Favorite',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: kDarkText,
            ),
          ),
          const Spacer(),
          _NotificationBell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MessageListScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade400, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v.trim()),
                      decoration: const InputDecoration(
                        hintText: 'Search something...',
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                      style: const TextStyle(fontSize: 14, color: kDarkText),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          for (final f in _FavFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _FilterChip(
                label: f.label,
                selected: _filter == f,
                onTap: () => setState(() => _filter = f),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the heart on a product to save it here',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final VoidCallback onTap;

  const _NotificationBell({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none, color: kDarkText, size: 26),
          Positioned(
            right: 0,
            top: -2,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? kPrimary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? kPrimary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Product product;

  const _FavoriteCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        ),
      ),
      child: Column(
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
                  child: GestureDetector(
                    onTap: () => FavoriteService.instance.remove(product),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 16,
                        color: Color(0xFFF87171),
                      ),
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
      ),
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

import 'package:flutter/material.dart';
import '../../../auth/data/auth_service.dart';
import '../../data/product_service.dart';
import '../models/shop_data.dart';
import 'product_detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _ShopTab(),
      const _PlaceholderTab(
        label: 'My Order',
        icon: Icons.local_shipping_outlined,
      ),
      const _PlaceholderTab(label: 'Favorite', icon: Icons.favorite_border),
      const _PlaceholderTab(label: 'My Profile', icon: Icons.person_outline),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _navIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: kPrimary,
        unselectedItemColor: Colors.grey.shade400,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_outlined),
            label: 'My Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'My Profile',
          ),
        ],
      ),
    );
  }
}

/// The first bottom-nav tab: header + Home/Category sub-tabs.
class _ShopTab extends StatefulWidget {
  const _ShopTab();

  @override
  State<_ShopTab> createState() => _ShopTabState();
}

class _ShopTabState extends State<_ShopTab> {
  int _tab = 0; // 0 = Home, 1 = Category
  final _authService = AuthService();

  /// Name to greet the user with: the Auth display name, else the part of
  /// the email before the '@', else a friendly fallback.
  String _displayName() {
    final user = _authService.currentUser;
    final name = user?.displayName;
    if (name != null && name.trim().isNotEmpty) return name.trim();
    final email = user?.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'there';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context),
          _buildTabBar(),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                // Slide the incoming tab in from the side it sits on
                // (Home from the left, Category from the right), with a fade.
                final incoming = child.key == ValueKey(_tab);
                final begin = Offset(
                  incoming
                      ? (_tab == 0 ? -0.15 : 0.15)
                      : (_tab == 0 ? 0.15 : -0.15),
                  0,
                );
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: begin,
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _tab == 0
                  ? const _HomeContent(key: ValueKey(0))
                  : const _CategoryContent(key: ValueKey(1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFE0E0E0),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, ${_displayName()}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kDarkText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Let's go shopping",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          const Spacer(),
          _circleIcon(
            Icons.search,
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
          const SizedBox(width: 12),
          _circleIcon(Icons.notifications_none, badge: true),
        ],
      ),
    );
  }

  Widget _circleIcon(IconData icon, {VoidCallback? onTap, bool badge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: kDarkText, size: 26),
          if (badge)
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

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(children: [_tabItem('Home', 0), _tabItem('Category', 1)]),
    );
  }

  Widget _tabItem(String label, int index) {
    final selected = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: selected ? kDarkText : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 2.5,
              width: 90,
              color: selected ? kPrimary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent({super.key});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final _productService = ProductService();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BannerCarousel(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'New Arrifals 🔥',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: kDarkText,
                ),
              ),
              const Text(
                'See All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<Product>>(
            stream: _productService.watchProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'Could not load products.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                );
              }

              final products = snapshot.data ?? const [];
              if (products.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('No products yet.')),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
                      builder: (_) =>
                          ProductDetailScreen(product: products[i]),
                    ),
                  ),
                  child: _ProductCard(product: products[i]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Swipeable promo banner with a page-dot indicator. Kept as its own widget so
/// paging through slides only rebuilds the carousel, not the whole home tab.
class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel();

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final _controller = PageController();
  int _index = 0;

  /// Promo slides shown in the swipeable banner carousel.
  static const _banners = <_BannerData>[
    _BannerData(
      title: '24% off shipping today\non bag purchases',
      subtitle: 'By Kutuku Store',
      icon: Icons.shopping_bag_outlined,
    ),
    _BannerData(
      title: 'Buy 1 get 1 free\non selected sneakers',
      subtitle: 'By Footwear Hub',
      icon: Icons.directions_run,
    ),
    _BannerData(
      title: 'Flat 15% off\nyour first order',
      subtitle: 'By Kutuku Store',
      icon: Icons.local_offer_outlined,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _controller,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => _BannerCard(data: _banners[i]),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            final selected = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: selected ? 10 : 8,
              height: selected ? 10 : 8,
              decoration: BoxDecoration(
                color: selected ? kPrimary : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Promo content for a single banner slide.
class _BannerData {
  final String title;
  final String subtitle;
  final IconData icon;

  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _BannerCard extends StatelessWidget {
  final _BannerData data;

  const _BannerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kDarkText,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: kPrimary),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

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

  /// Shows the product photo from Firebase Storage, or a colored placeholder
  /// while it loads / when the product has no image.
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

class _CategoryContent extends StatelessWidget {
  const _CategoryContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: kCategories.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, i) => _CategoryCard(category: kCategories[i]),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: category.swatch,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _onColor(category.swatch),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${category.productCount} Product',
            style: TextStyle(
              fontSize: 12,
              color: _onColor(category.swatch).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Picks readable text color based on swatch brightness.
  Color _onColor(Color background) {
    return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? Colors.white
        : kDarkText;
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String label;
  final IconData icon;

  const _PlaceholderTab({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Coming soon',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}

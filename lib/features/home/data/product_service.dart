import 'package:cloud_firestore/cloud_firestore.dart';

import '../presentation/models/shop_data.dart';

/// Reads (and writes) products from the Firestore `products` collection.
///
/// Each document is expected to hold:
///   name      String
///   seller    String
///   price     num
///   imageUrl  String   (a hosted image URL, e.g. from Cloudinary)
///   createdAt Timestamp
class ProductService {
  ProductService({FirebaseFirestore? firestore})
      : _products = (firestore ?? FirebaseFirestore.instance)
            .collection('products');

  final CollectionReference<Map<String, dynamic>> _products;

  /// Live stream of products, newest first.
  ///
  /// We sort on the client instead of with `orderBy('createdAt')` so a
  /// document that is missing (or misspells) the timestamp still shows up.
  Stream<List<Product>> watchProducts() {
    return _products
        .snapshots()
        .map((snap) => _sortedNewestFirst(snap.docs));
  }

  /// One-off fetch of products, newest first.
  Future<List<Product>> fetchProducts() async {
    final snap = await _products.get();
    return _sortedNewestFirst(snap.docs);
  }

  /// Products whose name or seller contains [query] (case-insensitive).
  ///
  /// Firestore has no native substring search, so we fetch and filter on the
  /// client — fine for this catalogue's size. An empty query returns all.
  Future<List<Product>> searchProducts(String query) async {
    final all = await fetchProducts();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.seller.toLowerCase().contains(q))
        .toList();
  }

  /// Maps docs to [Product]s and sorts newest first by their creation time.
  List<Product> _sortedNewestFirst(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final products = docs.map(Product.fromFirestore).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return products;
  }

  /// Adds a product. [imageUrl] is a hosted image URL (e.g. a Cloudinary
  /// link you copied from the Media Library).
  Future<void> addProduct({
    required String name,
    required String seller,
    required double price,
    required String imageUrl,
  }) {
    return _products.add({
      'name': name,
      'seller': seller,
      'price': price,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

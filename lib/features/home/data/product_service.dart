import 'package:cloud_firestore/cloud_firestore.dart';

import '../presentation/models/shop_data.dart';

class ProductService {
  ProductService({FirebaseFirestore? firestore})
      : _products = (firestore ?? FirebaseFirestore.instance)
            .collection('products');

  final CollectionReference<Map<String, dynamic>> _products;

  Stream<List<Product>> watchProducts() {
    return _products
        .snapshots()
        .map((snap) => _sortedNewestFirst(snap.docs));
  }

  Future<List<Product>> fetchProducts() async {
    final snap = await _products.get();
    return _sortedNewestFirst(snap.docs);
  }

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

  List<Product> _sortedNewestFirst(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final products = docs.map(Product.fromFirestore).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return products;
  }

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

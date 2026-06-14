import 'package:cloud_firestore/cloud_firestore.dart';

import '../presentation/models/shop_data.dart';

class CategoryService {
  CategoryService({FirebaseFirestore? firestore})
      : _categories = (firestore ?? FirebaseFirestore.instance)
            .collection('categories');

  final CollectionReference<Map<String, dynamic>> _categories;

  Stream<List<Category>> watchCategories() {
    return _categories.snapshots().map((snap) => _activeSorted(snap.docs));
  }

  Future<List<Category>> fetchCategories() async {
    final snap = await _categories.get();
    return _activeSorted(snap.docs);
  }

  List<Category> _activeSorted(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs.map(Category.fromFirestore).where((c) => c.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const Color kPrimary = Color(0xFF5B4DE6);
const Color kDarkText = Color(0xFF1A1A2E);

class Product {
  final String id;
  final String name;
  final String seller;
  final double price;
  final String imageUrl;
  final Color swatch;
  final String categoryId;
  final DateTime createdAt;

  Product({
    this.id = '',
    required this.name,
    required this.seller,
    required this.price,
    this.imageUrl = '',
    this.swatch = const Color(0xFFE0E0E0),
    this.categoryId = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final ts = (data['createdAt'] ?? data['createAt']) as Timestamp?;
    return Product(
      id: doc.id,
      name: (data['name'] ?? '') as String,
      seller: (data['seller'] ?? '') as String,
      price: (data['price'] as num?)?.toDouble() ?? 0,
      imageUrl: (data['imageUrl'] ?? '') as String,
      categoryId: (data['categoryId'] ?? '') as String,
      createdAt: ts?.toDate(),
    );
  }
}

class Category {
  final String id;
  final String name;

  final String iconUrl;
  final bool isActive;

  final String parentId;
  final int sortOrder;

  final int productCount;
  final Color swatch;

  const Category({
    this.id = '',
    required this.name,
    this.iconUrl = '',
    this.isActive = true,
    this.parentId = '',
    this.sortOrder = 0,
    this.productCount = 0,
    this.swatch = const Color(0xFFE0E0E0),
  });

  String get displayName => name
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  factory Category.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final sortOrder = (data['sortOrder'] as num?)?.toInt() ?? 0;
    return Category(
      id: doc.id,
      name: (data['name'] ?? '') as String,
      iconUrl: (data['iconUrl'] ?? '') as String,
      isActive: (data['isActive'] ?? true) as bool,
      parentId: (data['parentId'] ?? '') as String,
      sortOrder: sortOrder,
      swatch: kCategorySwatches[sortOrder % kCategorySwatches.length],
    );
  }
}

const List<Color> kCategorySwatches = [
  Color(0xFF3A3A3A),
  Color(0xFFCDE8B5),
  Color(0xFFE8DCC9),
  Color(0xFFE0E4E8),
  Color(0xFF2E2E3A),
];

class PopularSearch {
  final String name;
  final String searches;
  final String tag;
  final Color tagColor;
  final Color swatch;

  const PopularSearch({
    required this.name,
    required this.searches,
    required this.tag,
    required this.tagColor,
    required this.swatch,
  });
}

const List<String> kLastSearch = [
  'Electronics',
  'Pants',
  'Three Second',
  'Long shirt',
];

const List<PopularSearch> kPopularSearch = [
  PopularSearch(
    name: 'Lunilo Hils jacket',
    searches: '1,6k Search today',
    tag: 'Hot',
    tagColor: Color(0xFFF87171),
    swatch: Color(0xFFE8C9A0),
  ),
  PopularSearch(
    name: 'Denim Jeans',
    searches: '1k Search today',
    tag: 'New',
    tagColor: Color(0xFFFB923C),
    swatch: Color(0xFFC9D6E8),
  ),
  PopularSearch(
    name: 'Redil Backpack',
    searches: '1,23k Search today',
    tag: 'Popular',
    tagColor: Color(0xFF4ADE80),
    swatch: Color(0xFF3A3A3A),
  ),
  PopularSearch(
    name: 'JBL Speakers',
    searches: '1,1k Search today',
    tag: 'New',
    tagColor: Color(0xFFFB923C),
    swatch: Color(0xFFE8D7A0),
  ),
];

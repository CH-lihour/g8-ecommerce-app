import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// App accent color, shared across the shop screens.
const Color kPrimary = Color(0xFF5B4DE6);
const Color kDarkText = Color(0xFF1A1A2E);

class Product {
  final String id;
  final String name;
  final String seller;
  final double price;

  /// Hosted URL for the product photo (e.g. a Cloudinary link). Empty when the
  /// product has no image yet (we fall back to the [swatch] placeholder).
  final String imageUrl;
  final Color swatch;

  /// When the product was added; used to sort newest-first.
  final DateTime createdAt;

  Product({
    this.id = '',
    required this.name,
    required this.seller,
    required this.price,
    this.imageUrl = '',
    this.swatch = const Color(0xFFE0E0E0),
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  /// Builds a [Product] from a Firestore `products` document.
  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    // Tolerate either spelling of the timestamp field.
    final ts = (data['createdAt'] ?? data['createAt']) as Timestamp?;
    return Product(
      id: doc.id,
      name: (data['name'] ?? '') as String,
      seller: (data['seller'] ?? '') as String,
      price: (data['price'] as num?)?.toDouble() ?? 0,
      imageUrl: (data['imageUrl'] ?? '') as String,
      createdAt: ts?.toDate(),
    );
  }
}

class Category {
  final String name;
  final int productCount;
  final Color swatch;

  const Category({
    required this.name,
    required this.productCount,
    required this.swatch,
  });
}

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

/// Mock catalogue used until a real backend is wired up.
final List<Product> kNewArrivals = [
  Product(
    name: 'The Mirac Jiz',
    seller: 'Lisa Robber',
    price: 195.00,
    swatch: Color(0xFFE8C9A0),
  ),
  Product(
    name: 'Meriza Kiles',
    seller: 'Gazuna Resika',
    price: 143.45,
    swatch: Color(0xFFCDD3DA),
  ),
  Product(
    name: 'Lemon Skirt',
    seller: 'Anna Kendrick',
    price: 89.99,
    swatch: Color(0xFFD9E8C9),
  ),
  Product(
    name: 'Blue Denim',
    seller: 'Rangga Saputra',
    price: 120.00,
    swatch: Color(0xFFC9D6E8),
  ),
];

const List<Category> kCategories = [
  Category(name: 'New Arrivals', productCount: 208, swatch: Color(0xFF3A3A3A)),
  Category(name: 'Clothes', productCount: 358, swatch: Color(0xFFCDE8B5)),
  Category(name: 'Bags', productCount: 160, swatch: Color(0xFFE8DCC9)),
  Category(name: 'Shoese', productCount: 230, swatch: Color(0xFFE0E4E8)),
  Category(name: 'Electronics', productCount: 130, swatch: Color(0xFF2E2E3A)),
];

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

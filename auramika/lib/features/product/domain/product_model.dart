import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Full product detail model
class ProductDetail {
  final String id;
  final String brandName;
  final String productName;
  final String description;
  final double price;
  final double? originalPrice;
  final String material; // 'Brass' | 'Copper'
  final String category; // 'Earrings' | 'Necklace' | 'Cuff' | 'Ring' | 'Anklet'
  final String vibe;
  final bool isExpressAvailable;
  final bool isInStock;
  final List<String> imageUrls; // empty = use placeholder
  final List<String> sizes;
  final List<ProductDetail> wearItWith;

  const ProductDetail({
    required this.id,
    required this.brandName,
    required this.productName,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.material,
    required this.category,
    required this.vibe,
    this.isExpressAvailable = true,
    this.isInStock = true,
    this.imageUrls = const [],
    this.sizes = const [],
    this.wearItWith = const [],
  });

  Color get materialColor {
    final mat = material.toLowerCase();
    if (mat.contains('gold')) return AppColors.gold;
    if (mat.contains('silver')) return const Color(0xFFC0C0C0);
    if (mat.contains('rose')) return const Color(0xFFB76E79);
    if (mat.contains('copper')) return AppColors.copper;
    if (mat.contains('brass')) return AppColors.brass;
    return AppColors.gold; // Default fallback
  }

  bool get hasDiscount =>
      originalPrice != null && originalPrice! > price;

  int get discountPercent => hasDiscount
      ? (((originalPrice! - price) / originalPrice!) * 100).round()
      : 0;
}

/// Mock product catalogue
abstract class ProductCatalogue {
  /// Dynamically fetch product detail by ID from HomeData
  static ProductDetail getProductById(String id) {
    // Find basic info from HomeData
    // We import HomeData here to avoid circular dependencies if possible, 
    // but since they are in different layers, we might need a direct look up or pass it in.
    // For now, let's assume we can map from the known static list in HomeData if available,
    // or just return a generic detail if not found.
    
    // NOTE: In a real app, this would come from an API. 
    // Here we generate plausible details based on the ID.
    
    // Defaults
    String name = 'Luxury Piece';
    double price = 999;
    String material = 'Gold Plated';
    String category = 'Jewelry';
    String vibe = 'Old Money';
    bool express = true;
    String imageUrl = '';

    // Simple lookup simulation (You would typically import HomeData, but to keep this file clean 
    // and avoid circular imports if HomeData imports this, we will rely on values passed or a shared source).
    // However, since HomeData uses HomeProduct and this is ProductDetail, let's just 
    // return a detailed object that matches the requested ID if we can hardcode the mapping 
    // OR just use the ID to generate deterministic mock data.
    
    if (id.startsWith('e')) category = 'Earrings';
    if (id.startsWith('n')) category = 'Necklace';
    if (id.startsWith('r')) category = 'Ring';
    if (id.startsWith('b')) category = 'Bracelet';

    return ProductDetail(
      id: id,
      brandName: 'AURAMIKA',
      productName: _mockName(id), 
      description:
          'Hand-crafted with precision, this piece embodies the Auramika philosophy of '
          'timeless elegance meeting modern design. Featuring high-quality ${material.toLowerCase()} '
          'finish and premium stones, it is designed to be a staple in your collection.',
      price: _mockPrice(id),
      originalPrice: _mockPrice(id) * 1.4,
      material: _mockMaterial(id),
      category: category,
      vibe: 'Old Money', // default
      isExpressAvailable: true,
      sizes: category == 'Ring' ? ['6', '7', '8', '9'] : [],
      imageUrls: [], // Will load placeholder/asset based on ID in UI
      wearItWith: [],
    );
  }

  static String _mockName(String id) {
    // A few overrides for demo, otherwise generic
    const names = {
      'e1': 'Chunky Gold Hoops',
      'n2': 'Diamond Tennis Necklace',
      'r1': 'Signet Ring',
      'b1': 'Tennis Bracelet',
    };
    return names[id] ?? 'Timeless $id Artifact';
  }

  static double _mockPrice(String id) {
    return (id.hashCode % 2000) + 500.0;
  }

  static String _mockMaterial(String id) {
    if (id.contains('silver') || id == 'n2' || id == 'b1') return 'Silver / Zircon';
    if (id.contains('gold')) return 'Gold Plated';
    return 'Gold Plated';
  }
}

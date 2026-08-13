// import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  Future<List<Product>> getAllProducts() async {
    // Return sample products for testing
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
    
    return [
      Product(
        id: 1,
        title: 'Wireless Earbuds Pro',
        description:
            'Premium wireless earbuds with active noise cancellation, 30-hour battery life, and crystal-clear sound quality. Perfect for music lovers and professionals.',
        category: 'Electronics',
        discountPercentage: 15.0,
        rating: 4.5,
        stock: 42,
        tags: ['audio', 'wireless', 'premium'],
        brand: 'SoundTech',
        sku: 'WEB-PRO-001',
        weight: 0.05,
        dimensions: ProductDimensions(width: 2, height: 2, depth: 2),
        warrantyInformation: '2 years',
        shippingInformation: 'Ships in 2-3 business days',
        availabilityStatus: 'In Stock',
        reviews: [],
        returnPolicy: '30 days return',
        minimumOrderQuantity: 1,
        meta: 'Latest model 2024',
        images: [],
        thumbnail:
            'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=400&fit=crop',
      ),
      Product(
        id: 2,
        title: 'Smart Watch Ultra',
        description:
            'Advanced smartwatch with heart rate monitoring, GPS tracking, sleep analysis, and 7-day battery life. Stay connected while tracking your fitness.',
        category: 'Wearables',
        discountPercentage: 20.0,
        rating: 4.7,
        stock: 28,
        tags: ['wearable', 'fitness', 'smart'],
        brand: 'TechFit',
        sku: 'SW-ULTRA-002',
        weight: 0.08,
        dimensions: ProductDimensions(width: 4, height: 4, depth: 1),
        warrantyInformation: '1 year',
        shippingInformation: 'Ships in 1-2 business days',
        availabilityStatus: 'In Stock',
        reviews: [],
        returnPolicy: '30 days return',
        minimumOrderQuantity: 1,
        meta: 'Latest fitness tracker',
        images: [],
        thumbnail:
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=400&fit=crop',
      ),
      Product(
        id: 3,
        title: 'USB-C Fast Charger',
        description:
            '65W USB-C power adapter with multiple device charging support. Compact design, fast charging for laptops, tablets, and phones.',
        category: 'Accessories',
        discountPercentage: 10.0,
        rating: 4.3,
        stock: 150,
        tags: ['charger', 'usb-c', 'fast-charge'],
        brand: 'PowerHub',
        sku: 'USB-FC-003',
        weight: 0.15,
        dimensions: ProductDimensions(width: 3, height: 3, depth: 1),
        warrantyInformation: '3 years',
        shippingInformation: 'Ships in 1 business day',
        availabilityStatus: 'In Stock',
        reviews: [],
        returnPolicy: '60 days return',
        minimumOrderQuantity: 1,
        meta: 'GaN technology',
        images: [],
        thumbnail:
            'https://images.unsplash.com/photo-1591663527359-cf61ee1da4e8?w=400&h=400&fit=crop',
      ),
      Product(
        id: 4,
        title: '4K Webcam',
        description:
            'Professional 4K webcam with auto-focus and built-in microphone. Ideal for streaming, video calls, and content creation.',
        category: 'Electronics',
        discountPercentage: 25.0,
        rating: 4.6,
        stock: 15,
        tags: ['webcam', '4k', 'streaming'],
        brand: 'VisionPro',
        sku: 'WC-4K-004',
        weight: 0.2,
        dimensions: ProductDimensions(width: 6, height: 6, depth: 4),
        warrantyInformation: '1 year',
        shippingInformation: 'Ships in 2-3 business days',
        availabilityStatus: 'In Stock',
        reviews: [],
        returnPolicy: '30 days return',
        minimumOrderQuantity: 1,
        meta: 'Professional grade',
        images: [],
        thumbnail:
            'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=400&h=400&fit=crop',
      ),
    ];
    
    /* if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    } */
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constant.dart';
import '../models/cart.dart';

// Enhancement 3: Retrieve the cart using the selected user's ID and support
// adding products to the cart through DummyJSON.
class CartService {
  final http.Client _client;

  CartService({http.Client? client}) : _client = client ?? http.Client();

  Future<Cart?> getCartByUser(int userId) async {
    try {
      final response = await _client.get(Uri.parse('$host/carts/user/$userId'));
      if (response.statusCode != 200) {
        throw Exception('Failed to load cart (${response.statusCode})');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final carts = data['carts'] as List<dynamic>? ?? [];
      if (carts.isEmpty) return null;
      return Cart.fromJson(carts.first as Map<String, dynamic>);
    } on FormatException {
      throw Exception('The cart response was not valid JSON');
    } catch (error) {
      throw Exception('Unable to load cart: $error');
    }
  }

  Future<Cart> addToCart({
    required int userId,
    required int productId,
    required int quantity,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$host/carts/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'products': [
            {'id': productId, 'quantity': quantity},
          ],
        }),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add product (${response.statusCode})');
      }
      return Cart.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } on FormatException {
      throw Exception('The add-to-cart response was not valid JSON');
    } catch (error) {
      throw Exception('Unable to add product to cart: $error');
    }
  }
}

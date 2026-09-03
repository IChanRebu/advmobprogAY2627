import 'package:flutter/material.dart';

import '../constant.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../widgets/custom_text.dart';
import 'product_detail_screen.dart';

// Enhancement 1: Cart screen displays the user's cart and allows cart
// products to navigate to the existing product detail screen.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<Cart?> _cartFuture;
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _cartFuture = _cartService.getCartByUser(selectedUserId);
  }

  void _reloadCart() {
    setState(() {
      _cartFuture = _cartService.getCartByUser(selectedUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(text: 'Cart', fontSize: 18),
        actions: [
          IconButton(
            tooltip: 'Refresh cart',
            icon: const Icon(Icons.refresh),
            onPressed: _reloadCart,
          ),
        ],
      ),
      body: FutureBuilder<Cart?>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _MessageState(
              message: 'Could not load your cart.',
              action: TextButton(
                onPressed: _reloadCart,
                child: const Text('Try again'),
              ),
            );
          }

          final cart = snapshot.data;
          if (cart == null || cart.products.isEmpty) {
            return const _MessageState(message: 'Your cart is empty.');
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              ...cart.products.map((item) => _CartProductTile(item: item)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${cart.totalProducts} products | ${cart.totalQuantity} items',
                      ),
                      const SizedBox(height: 8),
                      Text('Total: \$${cart.total.toStringAsFixed(2)}'),
                      Text(
                        'Discounted total: \$${cart.discountedTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartProductTile extends StatelessWidget {
  const _CartProductTile({required this.item});

  final CartProduct item;

  Product _productFromCartItem() => Product(
    id: item.id,
    title: item.title,
    description: 'Product details loaded from your cart.',
    category: 'Cart item',
    discountPercentage: item.discountPercentage,
    rating: 0,
    stock: item.quantity,
    tags: const [],
    brand: '',
    sku: '',
    weight: 0,
    dimensions: ProductDimensions(width: 0, height: 0, depth: 0),
    warrantyInformation: '',
    shippingInformation: '',
    availabilityStatus: '',
    reviews: const [],
    returnPolicy: '',
    minimumOrderQuantity: 1,
    meta: '',
    images: [item.thumbnail],
    thumbnail: item.thumbnail,
  );

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProductDetailScreen(product: _productFromCartItem()),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Image.network(
                item.thumbnail,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  width: 80,
                  height: 80,
                  child: Icon(Icons.image_not_supported),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text('Quantity: ${item.quantity}'),
                    Text('\$${item.price.toStringAsFixed(2)} each'),
                    Text(
                      'Discounted: \$${item.discountedTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, this.action});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text(message), ?action],
      ),
    );
  }
}

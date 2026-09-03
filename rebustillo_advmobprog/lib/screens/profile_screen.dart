import 'package:flutter/material.dart';

import '../models/cart.dart';
import '../services/cart_service.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  Map<String, dynamic> _user = {};
  bool _isLoading = true;
  Cart? _cart;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final userData = await _userService.getUserData();
      final userId = (userData['id'] as int?) ?? 0;

      Cart? cart;
      if (userId > 0) {
        cart = await CartService().getCartByUser(userId);
      }

      if (!mounted) return;
      setState(() {
        _user = userData;
        _cart = cart;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load profile: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = (_user['id'] as int?) ?? 0;
    final username = (_user['username'] as String?) ?? 'Guest';
    final email = (_user['email'] as String?) ?? 'No email saved';
    final firstName = (_user['firstName'] as String?) ?? '';
    final lastName = (_user['lastName'] as String?) ?? '';
    final fullName = [firstName, lastName].where((v) => v.isNotEmpty).join(' ');
    final image = (_user['image'] as String?) ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.indigo.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: Colors.white,
                          backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
                          child: image.isEmpty
                              ? const Icon(Icons.person, size: 40, color: Colors.blue)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName.isNotEmpty ? fullName : username,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '@$username',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                email,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Account details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(label: 'User ID', value: userId.toString()),
                  _InfoTile(label: 'Username', value: username),
                  _InfoTile(label: 'Email', value: email),
                  _InfoTile(label: 'Gender', value: (_user['gender'] as String?) ?? 'Not set'),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your cart',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (_cart != null)
                        Text(
                          'User #${_cart!.userId}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_cart == null)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Text('No cart found for this user.'),
                      ),
                    )
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cart total: \$${_cart!.total.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text('Products: ${_cart!.totalProducts}'),
                            Text('Items: ${_cart!.totalQuantity}'),
                            const SizedBox(height: 12),
                            ..._cart!.products.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      item.thumbnail,
                                      width: 52,
                                      height: 52,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) =>
                                          Container(
                                            width: 52,
                                            height: 52,
                                            color: Colors.grey.shade200,
                                            child: const Icon(Icons.image_not_supported),
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('Qty: ${item.quantity}'),
                                        Text('Subtotal: \$${item.discountedTotal.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

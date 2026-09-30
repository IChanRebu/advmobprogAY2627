import 'package:flutter/material.dart';

import '../models/cart.dart';
import '../models/login_type.dart';
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
  LoginType _loginType = LoginType.dummyJson;
  bool _isLoading = true;
  bool _isActionLoading = false;
  Cart? _cart;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final userData = await _userService.getUserData();
      final loginType = await _userService.getLoginType();
      final userId = (userData['id'] as int?) ?? 0;

      Cart? cart;
      if (userId > 0) {
        cart = await CartService().getCartByUser(userId);
      }

      if (!mounted) return;
      setState(() {
        _user = userData;
        _loginType = loginType;
        _cart = cart;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to load profile: $error')));
    }
  }

  Future<void> _logout() async {
    try {
      await _userService.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to log out: $error')));
    }
  }

  Future<void> _updateUsername() async {
    final controller = TextEditingController(
      text: _user['username'] as String? ?? '',
    );
    final formKey = GlobalKey<FormState>();
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update username'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Username'),
            validator: (value) =>
                value == null ||
                    !RegExp(r'^[A-Za-z0-9._-]{3,30}$').hasMatch(value.trim())
                ? 'Use 3-30 letters, numbers, dots, underscores, or hyphens'
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (shouldSave != true || !mounted) {
      controller.dispose();
      return;
    }
    setState(() => _isActionLoading = true);
    try {
      await _userService.updateUsername(controller.text);
      await _loadProfile();
      if (mounted) _showMessage('Username updated.');
    } catch (error) {
      if (mounted) _showMessage(_errorMessage(error));
    } finally {
      controller.dispose();
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _changePassword() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current password',
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter your current password'
                    : null,
              ),
              TextFormField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New password'),
                validator: (value) =>
                    value == null ||
                        value.length < 8 ||
                        !RegExp(r'[A-Za-z]').hasMatch(value) ||
                        !RegExp(r'\d').hasMatch(value)
                    ? 'Use 8+ characters, including a letter and a number'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (shouldSave != true || !mounted) {
      currentController.dispose();
      newController.dispose();
      return;
    }
    setState(() => _isActionLoading = true);
    try {
      await _userService.resetPasswordFromCurrentPassword(
        currentPassword: currentController.text,
        newPassword: newController.text,
      );
      if (mounted) _showMessage('Password updated.');
    } catch (error) {
      if (mounted) _showMessage(_errorMessage(error));
    } finally {
      currentController.dispose();
      newController.dispose();
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This action cannot be undone. Your account and local session will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isActionLoading = true);
    try {
      await _userService.deleteAccount();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    } catch (error) {
      if (mounted) _showMessage(_errorMessage(error));
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _errorMessage(Object error) =>
      error.toString().replaceFirst('Exception: ', '');

  @override
  Widget build(BuildContext context) {
    final userId = (_user['id'] as int?) ?? 0;
    final userIdLabel = _loginType == LoginType.firebase
        ? (_user['uid'] as String? ?? 'Not available')
        : userId.toString();
    final username = (_user['username'] as String?) ?? 'Guest';
    final email = (_user['email'] as String?) ?? 'No email saved';
    final firstName = (_user['firstName'] as String?) ?? '';
    final lastName = (_user['lastName'] as String?) ?? '';
    final fullName = [firstName, lastName].where((v) => v.isNotEmpty).join(' ');
    final image = (_user['image'] as String?) ?? '';
    final age = (_user['age'] as int?) ?? 0;
    final contactNo = (_user['contactNo'] as String?) ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
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
                          backgroundImage: image.isNotEmpty
                              ? NetworkImage(image)
                              : null,
                          child: image.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.blue,
                                )
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
                  _InfoTile(label: 'User ID', value: userIdLabel),
                  _InfoTile(label: 'First Name', value: firstName),
                  _InfoTile(label: 'Last Name', value: lastName),
                  _InfoTile(
                    label: 'Age',
                    value: age > 0 ? age.toString() : 'Not provided',
                  ),
                  _InfoTile(
                    label: 'Contact Number',
                    value: contactNo.isNotEmpty ? contactNo : 'Not provided',
                  ),
                  _InfoTile(label: 'Username', value: username),
                  _InfoTile(label: 'Email', value: email),
                  _InfoTile(label: 'Sign-in method', value: _loginType.label),
                  _InfoTile(
                    label: 'Gender',
                    value: (_user['gender'] as String?) ?? 'Not set',
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Account actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _isActionLoading ? null : _updateUsername,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Update username'),
                  ),
                  if (_loginType == LoginType.firebase)
                    OutlinedButton.icon(
                      onPressed: _isActionLoading ? null : _changePassword,
                      icon: const Icon(Icons.lock_reset),
                      label: const Text('Change password'),
                    ),
                  OutlinedButton.icon(
                    onPressed: _isActionLoading ? null : _deleteAccount,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete account'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your cart',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Products: ${_cart!.totalProducts}'),
                            Text('Items: ${_cart!.totalQuantity}'),
                            const SizedBox(height: 12),
                            ..._cart!.products.map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
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
                                              child: const Icon(
                                                Icons.image_not_supported,
                                              ),
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text('Qty: ${item.quantity}'),
                                          Text(
                                            'Subtotal: \$${item.discountedTotal.toStringAsFixed(2)}',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
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

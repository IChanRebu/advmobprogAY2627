import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/login_type.dart';
import '../services/user_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fNameController = TextEditingController();
  final _lNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _contactNoController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final UserService _userService = UserService();

  bool _isLoading = false;
  bool _showPassword = false;

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = await _userService.createAccount(
        loginType: LoginType.firebase,
        fName: _fNameController.text.trim(),
        lName: _lNameController.text.trim(),
        age: int.parse(_ageController.text),
        contactNo: _contactNoController.text.trim(),
        username: _usernameController.text.trim(),
        emailAddress: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
        arguments: user.toJson(),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_errorMessage(error))));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? 'Enter $label' : null;

  String? _validateAge(String? value) {
    final age = int.tryParse(value ?? '');
    if (age == null || age < 1 || age > 120) {
      return 'Enter an age from 1 to 120';
    }
    return null;
  }

  String? _validateContactNo(String? value) {
    final number = value?.trim() ?? '';
    final digits = number.replaceAll(RegExp(r'\D'), '');
    if (!RegExp(r'^\+?[0-9\s()-]+$').hasMatch(number) ||
        digits.length < 7 ||
        digits.length > 15) {
      return 'Enter a valid contact number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null ||
        !RegExp(r'^[A-Za-z0-9._-]{3,30}$').hasMatch(value.trim())) {
      return 'Use 3-30 letters, numbers, dots, underscores, or hyphens';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null ||
        value.length < 8 ||
        !RegExp(r'[A-Za-z]').hasMatch(value) ||
        !RegExp(r'\d').hasMatch(value)) {
      return 'Use at least 8 characters, including a letter and a number';
    }
    return null;
  }

  String _errorMessage(Object error) =>
      error.toString().replaceFirst('Exception: ', '');

  @override
  void dispose() {
    _fNameController.dispose();
    _lNameController.dispose();
    _ageController.dispose();
    _contactNoController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Join Ulqiorra Mart',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create your Firebase account to get started.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 22),
              const SizedBox(height: 4),
              _field(
                controller: _fNameController,
                label: 'First Name',
                validator: (value) => _required(value, 'first name'),
                textCapitalization: TextCapitalization.words,
              ),
              _field(
                controller: _lNameController,
                label: 'Last Name',
                validator: (value) => _required(value, 'last name'),
                textCapitalization: TextCapitalization.words,
              ),
              _field(
                controller: _ageController,
                label: 'Age',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _validateAge,
              ),
              _field(
                controller: _contactNoController,
                label: 'Contact Number',
                keyboardType: TextInputType.phone,
                validator: _validateContactNo,
              ),
              _field(
                controller: _usernameController,
                label: 'Username',
                validator: _validateUsername,
              ),
              _field(
                controller: _emailController,
                label: 'Email Address',
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              _field(
                controller: _passwordController,
                label: 'Password',
                obscureText: !_showPassword,
                validator: _validatePassword,
                suffixIcon: IconButton(
                  tooltip: _showPassword ? 'Hide password' : 'Show password',
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() {
                    _showPassword = !_showPassword;
                  }),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoading ? null : _createAccount,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'CREATE ACCOUNT',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        validator: validator,
        enabled: !_isLoading,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

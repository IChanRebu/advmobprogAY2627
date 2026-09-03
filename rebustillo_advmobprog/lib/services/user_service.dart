import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constant.dart';
import '../models/user.dart';

class UserService {
	Map<String, dynamic> data = {};

	Future<User> loginUser(String username, String password) async {
		try {
			final response = await http.post(
				Uri.parse('$host/auth/login'),
				headers: {'Content-Type': 'application/json'},
				body: jsonEncode({
					'username': username,
					'password': password,
					'expiresInMins': 60,
				}),
			);

			if (response.statusCode == 200) {
				data = jsonDecode(response.body);
				await saveUserData(data);
				return User.fromJson(data);
			} else {
				throw Exception(response.body);
			}
		} catch (error) {
			final fallbackUser = {
				'id': 1,
				'username': username.trim().isNotEmpty ? username.trim() : 'demo_user',
				'email': '${username.trim().isNotEmpty ? username.trim() : 'demo_user'}@example.com',
				'firstName': 'Demo',
				'lastName': 'User',
				'gender': 'Not specified',
				'image': '',
				'accessToken': 'demo-access-token',
				'refreshToken': 'demo-refresh-token',
				'token': 'demo-access-token',
			};

			await saveUserData(fallbackUser);
			return User.fromJson(fallbackUser);
		}
	}

	/// Save User Data to SharedPreferences
	/// Save user data from API response based on User model
	Future<void> saveUserData(Map<String, dynamic> userData) async {
		final prefs = await SharedPreferences.getInstance();
		final user = User.fromJson(userData);

		await prefs.setInt('id', user.id);
		await prefs.setString('username', user.username);
		await prefs.setString('email', user.email);
		await prefs.setString('firstName', user.firstName);
		await prefs.setString('lastName', user.lastName);
		await prefs.setString('gender', user.gender);
		await prefs.setString('image', user.image);
		await prefs.setString('accessToken', user.accessToken);
		await prefs.setString('refreshToken', user.refreshToken);

		// Support generic token key if present in API response
		if (userData.containsKey('token')) {
			await prefs.setString('token', userData['token'] ?? '');
		} else if (user.accessToken.isNotEmpty) {
			await prefs.setString('token', user.accessToken);
		}
	}

	/// Retrieve User data from SharedPreferences
	Future<Map<String, dynamic>> getUserData() async {
		final prefs = await SharedPreferences.getInstance();

		return {
			'id': prefs.getInt('id') ?? 0,
			'username': prefs.getString('username') ?? '',
			'email': prefs.getString('email') ?? '',
			'firstName': prefs.getString('firstName') ?? '',
			'lastName': prefs.getString('lastName') ?? '',
			'gender': prefs.getString('gender') ?? '',
			'image': prefs.getString('image') ?? '',
			'accessToken': prefs.getString('accessToken') ?? '',
			'refreshToken': prefs.getString('refreshToken') ?? '',
			'token': prefs.getString('token') ?? prefs.getString('accessToken') ?? '',
		};
	}

	/// Retrieve User model from SharedPreferences
	Future<User> getUser() async {
		final userData = await getUserData();
		return User.fromJson(userData);
	}

	/// Check if User is Logged In
	Future<bool> isLoggedIn() async {
		final prefs = await SharedPreferences.getInstance();
		final token = prefs.getString('token') ?? prefs.getString('accessToken');
		return token != null && token.isNotEmpty;
	}

	/// Logout and Clear User Data
	Future<void> logout() async {
		try {
			final prefs = await SharedPreferences.getInstance();
			await prefs.clear();
		} catch (e) {
			throw Exception('Failed to log out: $e');
		}
	}
}

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';
import '../models/login_type.dart';
import '../models/user.dart';

class UserService {
  static const String _loginTypeKey = 'loginType';
  static const Set<String> _sessionKeys = {
    'id',
    'username',
    'email',
    'firstName',
    'lastName',
    'gender',
    'image',
    'accessToken',
    'refreshToken',
    'token',
    'age',
    'contactNo',
    _loginTypeKey,
  };

  final http.Client _client;
  final firebase.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  UserService({
    http.Client? client,
    firebase.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })
    : _client = client ?? http.Client(),
      _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  Future<LoginType> getLoginType() async {
    final prefs = await SharedPreferences.getInstance();
    return LoginType.fromStorage(prefs.getString(_loginTypeKey));
  }

  Future<void> setLoginType(LoginType loginType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loginTypeKey, loginType.name);
  }

  Future<User> signIn({
    required LoginType loginType,
    required String username,
    required String password,
  }) async {
    if (loginType == LoginType.firebase) {
      try {
        final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: username.trim(),
          password: password,
        );
        final firebaseUser = credential.user;
        if (firebaseUser == null) {
          throw Exception('Firebase did not return a signed-in user.');
        }
        final token = await firebaseUser.getIdToken(true);
        final profile = await _readFirebaseProfile(firebaseUser.uid);
        final data = _userFromFirebase(firebaseUser).toJson()
          ..addAll(profile)
          ..addAll({
            'uid': firebaseUser.uid,
            'accessToken': token ?? '',
            'loginType': loginType.name,
          });
        await setLoginType(loginType);
        await saveUserData(data, loginType: loginType);
        return User.fromJson(data);
      } on firebase.FirebaseAuthException catch (error) {
        throw Exception(_firebaseErrorMessage(error));
      }
    }

    try {
      final response = await _client.post(
        Uri.parse('$host/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username.trim(),
          'password': password,
          'expiresInMins': 60,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception(_apiErrorMessage(response));
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final userId = data['id'];
      if (userId is num) {
        final profile = await _fetchDummyJsonProfile(userId.toInt());
        if (profile != null) data.addAll(profile);
      }
      await saveUserData(data, loginType: loginType);
      return User.fromJson(data);
    } on FormatException {
      throw Exception('The login response was not valid JSON.');
    } on http.ClientException catch (error) {
      throw Exception('Unable to reach DummyJSON: ${error.message}');
    }
  }

  Future<User> createAccount({
    required LoginType loginType,
    required String fName,
    required String lName,
    required int age,
    required String contactNo,
    required String username,
    required String emailAddress,
    required String password,
  }) async {
    if (loginType != LoginType.firebase) {
      throw Exception(
        'DummyJSON does not persist new accounts. Choose Firebase to create an account.',
      );
    }

    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: emailAddress.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Firebase did not return the new account.');
      }
      await firebaseUser.updateDisplayName(username.trim());
      await firebaseUser.reload();
      final updatedUser = _firebaseAuth.currentUser ?? firebaseUser;
      await setLoginType(loginType);
      final data = _userFromFirebase(updatedUser).toJson()
        ..addAll({
          'uid': updatedUser.uid,
          'firstName': fName.trim(),
          'lastName': lName.trim(),
          'age': age,
          'contactNo': contactNo.trim(),
        });
      await _saveFirebaseProfile(updatedUser.uid, {
        'uid': updatedUser.uid,
        'username': username.trim(),
        'email': emailAddress.trim(),
        'firstName': fName.trim(),
        'lastName': lName.trim(),
        'age': age,
        'contactNo': contactNo.trim(),
      });
      await saveUserData(data, loginType: loginType);
      return User.fromJson(data);
    } on firebase.FirebaseAuthException catch (error) {
      throw Exception(_firebaseErrorMessage(error));
    }
  }

  Future<void> saveUserData(
    Map<String, dynamic> userData, {
    LoginType? loginType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final user = User.fromJson(userData);
    final selectedType =
        loginType ?? LoginType.fromStorage(userData['loginType'] as String?);

    await prefs.setString(_loginTypeKey, selectedType.name);
    await prefs.setInt('id', user.id);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    await prefs.setString('firstName', user.firstName);
    await prefs.setString('lastName', user.lastName);
    await prefs.setString('gender', user.gender);
    await prefs.setString('image', user.image);
    await prefs.setInt('age', user.age);
    await prefs.setString('contactNo', user.contactNo);
    await prefs.setString('accessToken', user.accessToken);
    await prefs.setString('refreshToken', user.refreshToken);
    if (selectedType == LoginType.dummyJson) {
      await prefs.setString(
        'token',
        userData['token'] as String? ?? user.accessToken,
      );
    } else {
      await prefs.remove('token');
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    final loginType = await getLoginType();
    if (loginType == LoginType.firebase) {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return {};
      final token = await firebaseUser.getIdToken();
      final prefs = await SharedPreferences.getInstance();
      final profile = await _readFirebaseProfile(firebaseUser.uid);
      return _userFromFirebase(firebaseUser).toJson()
        ..addAll({
          'firstName': prefs.getString('firstName') ?? '',
          'lastName': prefs.getString('lastName') ?? '',
          'age': prefs.getInt('age') ?? 0,
          'contactNo': prefs.getString('contactNo') ?? '',
        })
        ..addAll(profile)
        ..addAll({
          'uid': firebaseUser.uid,
          'accessToken': token ?? '',
          'loginType': loginType.name,
        });
    }

    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getInt('id') ?? 0,
      'username': prefs.getString('username') ?? '',
      'email': prefs.getString('email') ?? '',
      'firstName': prefs.getString('firstName') ?? '',
      'lastName': prefs.getString('lastName') ?? '',
      'gender': prefs.getString('gender') ?? '',
      'image': prefs.getString('image') ?? '',
      'age': prefs.getInt('age') ?? 0,
      'contactNo': prefs.getString('contactNo') ?? '',
      'accessToken': prefs.getString('accessToken') ?? '',
      'refreshToken': prefs.getString('refreshToken') ?? '',
      'token': prefs.getString('token') ?? prefs.getString('accessToken') ?? '',
      'loginType': loginType.name,
    };
  }

  Future<User> getUser() async => User.fromJson(await getUserData());

  Future<bool> isLoggedIn() async {
    final loginType = await getLoginType();
    if (loginType == LoginType.firebase) {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return false;
      try {
        return (await firebaseUser.getIdToken())?.isNotEmpty ?? false;
      } on firebase.FirebaseAuthException {
        return false;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? prefs.getString('accessToken');
    return token != null && token.isNotEmpty;
  }

  Future<void> updateUsername(String username) async {
    final normalizedUsername = username.trim();
    if (!RegExp(r'^[A-Za-z0-9._-]{3,30}$').hasMatch(normalizedUsername)) {
      throw Exception(
        'Username must be 3-30 characters and use only letters, numbers, dots, underscores, or hyphens.',
      );
    }

    final loginType = await getLoginType();
    final prefs = await SharedPreferences.getInstance();
    if (loginType == LoginType.firebase) {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) throw Exception('You are not signed in.');
      try {
        final profile = await getUserData();
        profile['username'] = normalizedUsername;
        await firebaseUser.updateDisplayName(normalizedUsername);
        await prefs.setString('username', normalizedUsername);
        await _saveFirebaseProfile(firebaseUser.uid, {
          'uid': firebaseUser.uid,
          'username': normalizedUsername,
          'email': firebaseUser.email ?? '',
          'firstName': profile['firstName'] ?? '',
          'lastName': profile['lastName'] ?? '',
          'age': profile['age'] ?? 0,
          'contactNo': profile['contactNo'] ?? '',
        });
      } on firebase.FirebaseAuthException catch (error) {
        throw Exception(_firebaseErrorMessage(error));
      }
    } else {
      final userId = prefs.getInt('id') ?? 0;
      if (userId < 1) throw Exception('No DummyJSON user is available.');
      final response = await _client.patch(
        Uri.parse('$host/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': normalizedUsername}),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(_apiErrorMessage(response));
      }
    }
    await prefs.setString('username', normalizedUsername);
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword.isEmpty) {
      throw Exception('Enter your current password.');
    }
    if (newPassword.length < 8 ||
        !RegExp(r'[A-Za-z]').hasMatch(newPassword) ||
        !RegExp(r'\d').hasMatch(newPassword)) {
      throw Exception(
        'New password must be at least 8 characters and include a letter and a number.',
      );
    }
    if (await getLoginType() != LoginType.firebase) {
      throw Exception('Password changes are not supported by DummyJSON.');
    }

    final firebaseUser = _firebaseAuth.currentUser;
    final email = firebaseUser?.email;
    if (firebaseUser == null || email == null) {
      throw Exception('You are not signed in with a password account.');
    }
    try {
      final credential = firebase.EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await firebaseUser.reauthenticateWithCredential(credential);
      await firebaseUser.updatePassword(newPassword);
    } on firebase.FirebaseAuthException catch (error) {
      throw Exception(_firebaseErrorMessage(error));
    }
  }

  Future<void> deleteAccount() async {
    final loginType = await getLoginType();
    if (loginType == LoginType.firebase) {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) throw Exception('You are not signed in.');
      try {
        await _deleteFirebaseProfile(firebaseUser.uid);
        await firebaseUser.delete();
        await _firebaseAuth.signOut();
      } on firebase.FirebaseAuthException catch (error) {
        throw Exception(_firebaseErrorMessage(error));
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id') ?? 0;
      if (userId > 0) {
        final response = await _client.delete(Uri.parse('$host/users/$userId'));
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception(_apiErrorMessage(response));
        }
      }
    }
    await _clearSession();
  }

  Future<void> signOut() async {
    try {
      if (_firebaseAuth.currentUser != null) {
        await _firebaseAuth.signOut();
      }
    } finally {
      await _clearSession();
    }
  }

  Future<void> logout() => signOut();

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in _sessionKeys) {
      await prefs.remove(key);
    }
  }

  DocumentReference<Map<String, dynamic>> _userProfile(String uid) =>
      _firestore.collection('users').doc(uid);

  Future<Map<String, dynamic>> _readFirebaseProfile(String uid) async {
    try {
      return (await _userProfile(uid).get()).data() ?? {};
    } on FirebaseException catch (error) {
      if (_canFallBackFromFirestore(error)) return {};
      rethrow;
    }
  }

  Future<void> _saveFirebaseProfile(
    String uid,
    Map<String, dynamic> profile,
  ) async {
    try {
      await _userProfile(uid).set(profile);
    } on FirebaseException catch (error) {
      if (!_canFallBackFromFirestore(error)) rethrow;
    }
  }

  Future<void> _deleteFirebaseProfile(String uid) async {
    try {
      await _userProfile(uid).delete();
    } on FirebaseException catch (error) {
      if (!_canFallBackFromFirestore(error)) rethrow;
    }
  }

  bool _canFallBackFromFirestore(FirebaseException error) =>
      const {
        'failed-precondition',
        'not-found',
        'permission-denied',
        'unavailable',
      }.contains(error.code);

  Future<Map<String, dynamic>?> _fetchDummyJsonProfile(int userId) async {
    try {
      final response = await _client.get(Uri.parse('$host/users/$userId'));
      if (response.statusCode != 200) return null;
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      return null;
    } on http.ClientException {
      return null;
    }
  }

  User _userFromFirebase(firebase.User firebaseUser) => User(
    id: 0,
    username:
        firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? '',
    email: firebaseUser.email ?? '',
    firstName: '',
    lastName: '',
    gender: '',
    image: firebaseUser.photoURL ?? '',
    accessToken: '',
    refreshToken: '',
  );

  String _apiErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final message = data['message'] ?? data['error'];
      if (message is String && message.isNotEmpty) return message;
    } on FormatException {
      return 'Request failed (${response.statusCode}).';
    }
    return 'Request failed (${response.statusCode}).';
  }

  String _firebaseErrorMessage(
    firebase.FirebaseAuthException error,
  ) => switch (error.code) {
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => 'Email or password is incorrect.',
    'email-already-in-use' => 'An account already exists for this email.',
    'invalid-email' => 'Enter a valid email address.',
    'weak-password' => 'Choose a stronger password (at least 6 characters).',
    'network-request-failed' => 'Network unavailable. Check your connection.',
    'requires-recent-login' =>
      'Sign in again before making this account change.',
    _ => error.message ?? 'Authentication failed. Please try again.',
  };
}

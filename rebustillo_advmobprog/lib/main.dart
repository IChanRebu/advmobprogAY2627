// packages
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/splash_screen.dart';

import 'providers/theme_providers.dart';
import 'services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // await dotenv.load(fileName: 'assets/.env');
  runApp(const RebustilloAdvMobProg());
}

class RebustilloAdvMobProg extends StatelessWidget {
  const RebustilloAdvMobProg({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeModel, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'E-Commerce App',
          theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
          darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
          themeMode: themeModel.isDark ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/signin': (context) => const SignInScreen(),
            '/signup': (context) => const SignupScreen(),
            '/home': (context) => const _ProtectedRoute(child: HomeScreen()),
            '/profile': (context) =>
                const _ProtectedRoute(child: ProfileScreen()),
            '/cart': (context) => const _ProtectedRoute(child: CartScreen()),
            '/settings': (context) =>
                const _ProtectedRoute(child: SettingsScreen()),
          },
        ),
      ),
    );
  }
}

class _ProtectedRoute extends StatefulWidget {
  const _ProtectedRoute({required this.child});

  final Widget child;

  @override
  State<_ProtectedRoute> createState() => _ProtectedRouteState();
}

class _ProtectedRouteState extends State<_ProtectedRoute> {
  late final Future<bool> _authenticationCheck = UserService().isLoggedIn();
  bool _redirectStarted = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authenticationCheck,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == true) return widget.child;

        if (!_redirectStarted) {
          _redirectStarted = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/signin',
                (route) => false,
              );
            }
          });
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

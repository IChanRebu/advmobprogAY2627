// packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/splash_screen.dart';

// providers
import 'providers/theme_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    // await dotenv.load(fileName: 'assets/.env');
    runApp(const RebustilloAdvMobProg());
  });
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
            '/home': (context) => const HomeScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/cart': (context) => const CartScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        ),
      ),
    );
  }
}

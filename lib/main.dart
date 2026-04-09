import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/property_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/watchlist_provider.dart';
import 'providers/listing_provider.dart';
import 'theme/theme.dart';
import 'screens/main_shell.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WatchlistProvider()),
        ChangeNotifierProvider(create: (_) => ListingProvider()),
      ],
      child: MaterialApp(
        title: 'EstateIQ',
        theme: AppTheme.darkTheme,
        home: Consumer<AuthProvider>(
          builder: (ctx, auth, _) {
            if (!auth.isLoggedIn) return const LoginScreen();
            if (!auth.hasCompletedOnboarding) {
              return const OnboardingScreen();
            }
            return const MainShell();
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

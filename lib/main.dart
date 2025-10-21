import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/products/product_list_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/orders/order_tracking_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/dev_tools_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase (comentado para funcionar sin configuración)
  // await Firebase.initializeApp();
  
  runApp(
    const ProviderScope(
      child: SupermarketDeliveryApp(),
    ),
  );
}

class SupermarketDeliveryApp extends StatelessWidget {
  const SupermarketDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Supermarket Delivery',
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: const Color(0xFFE53935),
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE53935),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE53935),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/products/:storeId',
      builder: (context, state) => ListaProductosScreen(),
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/tracking/:orderId',
      builder: (context, state) => OrderTrackingScreen(
        orderId: state.pathParameters['orderId']!,
      ),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/dev-tools',
      builder: (context, state) => const DevToolsScreen(),
    ),
  ],
);
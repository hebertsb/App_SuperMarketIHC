import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasLaunched = prefs.getBool('hasLaunched') ?? false;

      // Si es la primera vez, esperamos 0.75s simulando carga
      if (!hasLaunched) {
        await Future.delayed(const Duration(milliseconds: 750));
        await prefs.setBool('hasLaunched', true);
      }

      if (!mounted) return;
      // Ir al Home
      context.go('/');
    } catch (_) {
      // En caso de cualquier error, continuar normalmente
      if (!mounted) return;
      context.go('/');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Intentar mostrar un logo de assets si existe; si no, usar un ícono
                SizedBox(
                  width: 96,
                  height: 96,
                  child: _LogoOrIcon(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Supermarket Delivery',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoOrIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Si el asset no existe, el errorBuilder muestra el ícono por defecto
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/images/app_logo.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_grocery_store,
              size: 56,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFE53935),
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0: // Inicio
            if (currentIndex != 0) context.go('/');
            break;
          case 1: // Buscar
            if (currentIndex != 1) context.push('/search');
            break;
          case 2: // Carrito
            if (currentIndex != 2) context.push('/cart');
            break;
          case 3: // Pedidos
            if (currentIndex != 3) context.push('/orders');
            break;
          case 4: // Perfil
            if (currentIndex != 4) context.push('/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Buscar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Carrito',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Pedidos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}
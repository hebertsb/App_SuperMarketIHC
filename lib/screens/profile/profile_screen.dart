import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFFE53935),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User info
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFE53935),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usuario Demo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'usuario@email.com',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Menu options
          _buildMenuOption(
            icon: Icons.receipt_long,
            title: 'Mis Pedidos',
            onTap: () {},
          ),
          _buildMenuOption(
            icon: Icons.location_on,
            title: 'Direcciones',
            onTap: () {},
          ),
          _buildMenuOption(
            icon: Icons.payment,
            title: 'Métodos de Pago',
            onTap: () {},
          ),
          _buildMenuOption(
            icon: Icons.notifications,
            title: 'Notificaciones',
            onTap: () {},
          ),
          _buildMenuOption(
            icon: Icons.help,
            title: 'Ayuda y Soporte',
            onTap: () {},
          ),
          _buildMenuOption(
            icon: Icons.settings,
            title: 'Configuración',
            onTap: () {},
          ),
          _buildMenuOption(
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            onTap: () {},
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFFE53935),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : null,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
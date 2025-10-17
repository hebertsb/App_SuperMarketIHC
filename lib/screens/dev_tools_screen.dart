import 'package:flutter/material.dart';
import '../data/db_utils.dart';

/// Pantalla de utilidades para desarrollo
/// Puedes acceder navegando a /dev-tools
class DevToolsScreen extends StatelessWidget {
  const DevToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Herramientas de Desarrollo'),
        backgroundColor: const Color(0xFFE53935),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Gestión de Base de Datos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () async {
                await DBUtils.checkDatabase();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Revisa la consola para ver el estado'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.info),
              label: const Text('Ver Estado de la BD'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: () async {
                await DBUtils.reseedDatabase();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Datos actualizados correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Recargar Datos de Semilla'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: () async {
                // Confirmación
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('⚠️ Confirmar Reset'),
                    content: const Text(
                      '¿Estás seguro de que quieres resetear toda la base de datos?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Resetear'),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true && context.mounted) {
                  await DBUtils.resetDatabase();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Base de datos reseteada'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.delete_forever),
              label: const Text('Resetear Base de Datos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Divider(),
            
            const SizedBox(height: 16),
            
            const Text(
              'Instrucciones:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Ver Estado: Muestra cuántos registros hay\n'
              '• Recargar Datos: Limpia y vuelve a insertar\n'
              '• Resetear: Borra toda la BD y la recrea',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

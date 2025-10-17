import 'local_db.dart';
import 'seed_data.dart';

/// Utilidades para gestionar la base de datos

class DBUtils {
  /// Limpia todas las tablas y vuelve a insertar los datos de semilla
  static Future<void> reseedDatabase() async {
    final db = LocalDB();
    
    // Limpiar datos existentes
    await db.clearAll();
    
    // Volver a insertar datos de semilla
    await seedDatabase();
    
    print('✅ Base de datos reseeded correctamente');
  }

  /// Borra completamente la base de datos y la recrea
  static Future<void> resetDatabase() async {
    final db = LocalDB();
    
    // Resetear BD
    await db.resetDatabase();
    
    // Insertar datos de semilla
    await seedDatabase();
    
    print('✅ Base de datos reseteada correctamente');
  }

  /// Verifica cuántos registros hay en cada tabla
  static Future<void> checkDatabase() async {
    final db = LocalDB();
    
    final stores = await db.query('stores');
    final products = await db.query('products');
    
    print('📊 Estado de la base de datos:');
    print('   Supermercados: ${stores.length}');
    print('   Productos: ${products.length}');
  }
}

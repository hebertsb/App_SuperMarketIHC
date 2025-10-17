# 📦 Gestión de Datos - Supermarket Delivery App

## 📍 Archivos Principales

### 1. **Datos de Semilla**
📄 `lib/data/seed_data.dart`

Contiene todos los datos iniciales:
- **5 Supermercados** (Hipermaxi, Ketal, Fidalga, IC Norte, Supermercado Familiar)
- **35 Productos** distribuidos entre las tiendas

### 2. **Base de Datos**
📄 `lib/data/local_db.dart`

Define las tablas SQLite:
- `stores`: Información de supermercados
- `products`: Catálogo de productos

### 3. **Utilidades**
📄 `lib/data/db_utils.dart`

Métodos para gestionar la BD:
- `checkDatabase()`: Ver cuántos registros hay
- `reseedDatabase()`: Limpiar y recargar datos
- `resetDatabase()`: Borrar completamente y recrear

## ✏️ Cómo Agregar Datos

### Agregar un Supermercado

Edita `lib/data/seed_data.dart` en el array `stores`:

```dart
{
  'id': '6', // Nuevo ID
  'name': 'Mi Supermercado',
  'logo': 'assets/images/mi_logo.png',
  'address': 'Av. Principal 123',
  'phone': '+591 2 111222',
  'openHours': jsonEncode({'mon-fri': '8:00-20:00', 'sat-sun': '9:00-18:00'}),
  'rating': 4.5,
  'deliveryTime': 30,
  'deliveryFee': 15.0,
  'isOpen': 1, // 1 = abierto, 0 = cerrado
  'categories': jsonEncode(['Frutas', 'Verduras', 'Lácteos']),
},
```

### Agregar un Producto

En el mismo archivo, en el array `products`:

```dart
{
  'id': '36', // Nuevo ID
  'storeId': '1', // ID del supermercado
  'name': 'Aguacate',
  'description': 'Aguacate Hass premium',
  'price': 18.50,
  'originalPrice': 22.00, // null si no hay descuento
  'images': jsonEncode(['assets/images/aguacate.jpg']),
  'category': 'Frutas',
  'unit': 'kg',
  'stock': 25,
  'isAvailable': 1, // 1 = disponible, 0 = no disponible
  'rating': 4.7,
  'reviewCount': 15,
},
```

## 🔄 Regenerar Datos

### Opción 1: Usando la Pantalla de Dev Tools

1. **Accede a**: `http://localhost:8080/#/dev-tools`
2. Opciones disponibles:
   - **Ver Estado**: Muestra cuántos registros hay
   - **Recargar Datos**: Limpia y vuelve a insertar los datos de seed_data.dart
   - **Resetear BD**: Borra completamente la base de datos y la recrea

### Opción 2: Programáticamente

Puedes llamar desde cualquier pantalla:

```dart
import '../data/db_utils.dart';

// Ver estado
await DBUtils.checkDatabase();

// Recargar datos
await DBUtils.reseedDatabase();

// Resetear completamente
await DBUtils.resetDatabase();
```

### Opción 3: Borrar manualmente la BD

En Flutter web, los datos se guardan en IndexedDB del navegador:
1. Abre DevTools del navegador (F12)
2. Ve a "Application" → "Storage" → "IndexedDB"
3. Borra las bases de datos relacionadas
4. Recarga la app

## 🎯 Flujo de Datos

```
1. App inicia → SplashScreen
                    ↓
2. Navega a HomeScreen
                    ↓
3. _loadStores() llama a seedDatabase()
                    ↓
4. seedDatabase() verifica si hay datos
   - Si NO hay → Inserta todos los datos
   - Si SÍ hay → No hace nada (evita duplicados)
                    ↓
5. Datos listos para usar
```

## 📊 Estructura de Datos Actual

### Supermercados (5)
| ID | Nombre | Delivery Time | Fee | Estado |
|----|--------|---------------|-----|--------|
| 1 | Hipermaxi | 30 min | Bs 15 | Abierto |
| 2 | Ketal | 25 min | Bs 12 | Abierto |
| 3 | Fidalga | 35 min | Bs 18 | Cerrado |
| 4 | IC Norte | 28 min | Bs 10 | Abierto |
| 5 | Supermercado Familiar | 40 min | Bs 20 | Abierto |

### Productos (35)
- **Hipermaxi**: 15 productos (Frutas, Verduras, Lácteos, Carnes, Panadería)
- **Ketal**: 10 productos (Frutas, Verduras, Bebidas, Snacks, Panadería)
- **Fidalga**: 4 productos (Carnes, Embutidos, Pollo)
- **IC Norte**: 3 productos (Frutas, Limpieza, Bebidas)
- **Supermercado Familiar**: 3 productos (Abarrotes)

### Categorías Disponibles
- Frutas
- Verduras
- Lácteos
- Carnes
- Pollo
- Embutidos
- Panadería
- Bebidas
- Snacks
- Abarrotes
- Limpieza

## 💡 Tips

1. **IDs únicos**: Asegúrate de que cada supermercado y producto tenga un ID único
2. **storeId correcto**: Los productos deben tener el storeId del supermercado al que pertenecen
3. **jsonEncode**: Los campos array/object deben usar `jsonEncode()` (openHours, categories, images)
4. **isOpen/isAvailable**: Usa 1 para true, 0 para false (SQLite no tiene booleanos nativos)
5. **Precios**: Usa double (15.0, no 15)

## 🚀 Próximos Pasos

Para agregar más funcionalidad:
- Implementar búsqueda de productos
- Filtros por categoría
- Ordenar por precio/rating
- Sistema de favoritos
- Historial de compras

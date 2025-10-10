# 🤝 Guía de Contribución

¡Gracias por tu interés en contribuir a SuperMarket Delivery App! Esta guía te ayudará a empezar.

## 🚀 Primeros Pasos

### Configurar el entorno de desarrollo

1. **Fork** el repositorio
2. **Clona** tu fork:
   ```bash
   git clone https://github.com/TU_USUARIO/App_SuperMarketIHC.git
   ```
3. **Instala** las dependencias:
   ```bash
   flutter pub get
   ```
4. **Verifica** que todo funcione:
   ```bash
   flutter doctor
   flutter test
   ```

## 📋 Proceso de Contribución

### 1. Crear una Issue
- Describe el bug o feature que quieres trabajar
- Incluye capturas de pantalla si aplica
- Espera feedback antes de empezar a programar

### 2. Crear una rama
```bash
git checkout -b feature/nombre-descriptivo
# o
git checkout -b bugfix/descripcion-del-bug
```

### 3. Desarrollar
- Escribe código limpio y comentado
- Sigue las convenciones de Dart/Flutter
- Agrega tests si es necesario
- Actualiza documentación si es relevante

### 4. Testing
```bash
# Ejecutar todos los tests
flutter test

# Verificar análisis de código
flutter analyze

# Formatear código
dart format .
```

### 5. Commit
```bash
git add .
git commit -m "tipo: descripción breve

Descripción más detallada del cambio
- Punto específico 1
- Punto específico 2

Fixes #123" # Si aplica
```

#### Tipos de commit:
- `feat`: Nueva característica
- `fix`: Corrección de bug
- `docs`: Cambios en documentación
- `style`: Cambios de formato (no afectan lógica)
- `refactor`: Refactorización de código
- `test`: Agregar o modificar tests
- `chore`: Tareas de mantenimiento

### 6. Pull Request
1. Push tu rama:
   ```bash
   git push origin feature/nombre-descriptivo
   ```
2. Abre un Pull Request en GitHub
3. Describe los cambios realizados
4. Vincula issues relacionadas
5. Solicita review

## 🎨 Estándares de Código

### Dart/Flutter
- Usa `dart format` para formateo automático
- Sigue las [convenciones de Dart](https://dart.dev/guides/language/effective-dart)
- Usa nombres descriptivos para variables y funciones
- Comenta código complejo
- Evita anidación excesiva

### Estructura de archivos
```
lib/
├── models/        # Modelos de datos
├── screens/       # Pantallas/páginas
├── widgets/       # Widgets reutilizables
├── services/      # Servicios (API, almacenamiento)
├── providers/     # Estados de Riverpod
└── utils/         # Utilidades y helpers
```

### Widgets
- Crea widgets pequeños y reutilizables
- Usa `const` siempre que sea posible
- Separa lógica de UI cuando sea complejo

## 🧪 Testing

### Agregar tests
- Tests unitarios para lógica de negocio
- Tests de widgets para UI crítica
- Tests de integración para flujos importantes

```dart
// Ejemplo de test de widget
testWidgets('should display store name', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: StoreCard(store: mockStore),
    ),
  );
  
  expect(find.text('Hipermaxi'), findsOneWidget);
});
```

## 📱 UI/UX Guidelines

### Diseño
- Sigue Material Design 3
- Usa la paleta de colores del proyecto
- Mantén consistencia visual
- Optimiza para diferentes tamaños de pantalla

### Accesibilidad
- Agrega `semanticsLabel` a widgets importantes
- Usa contraste suficiente
- Tamaños de texto legibles
- Soporte para lectores de pantalla

## 🐛 Reportar Bugs

### Información requerida:
- **Descripción**: ¿Qué esperabas vs qué pasó?
- **Pasos para reproducir**: Lista paso a paso
- **Entorno**: OS, versión de Flutter, dispositivo
- **Capturas**: Screenshots o videos si aplica
- **Logs**: Mensajes de error relevantes

### Template de bug:
```markdown
**Descripción del bug**
Descripción clara y concisa del bug.

**Pasos para reproducir**
1. Ve a '...'
2. Haz click en '...'
3. Scroll hasta '...'
4. Ver error

**Comportamiento esperado**
Descripción de lo que esperabas que pasara.

**Capturas**
Agrega capturas de pantalla si aplica.

**Entorno:**
- OS: [e.g. Windows 11]
- Flutter: [e.g. 3.35.6]
- Dart: [e.g. 3.9.2]
- Dispositivo: [e.g. Pixel 6, Chrome]
```

## ✨ Sugerir Features

### Información útil:
- **Problema**: ¿Qué problema resuelve?
- **Solución**: Describe tu propuesta
- **Alternativas**: ¿Consideraste otras opciones?
- **Mockups**: Diseños o wireframes si aplica

## 📞 Contacto

- **Issues**: Para bugs y features
- **Discussions**: Para preguntas generales
- **Email**: [tu-email@ejemplo.com] (si aplica)

## 🎯 Roadmap

### Próximas features prioritarias:
- [ ] Integración con Firebase Auth
- [ ] Sistema de pagos
- [ ] Notificaciones push
- [ ] Tracking GPS en tiempo real
- [ ] Chat de soporte
- [ ] Modo offline

### ¿Quieres contribuir?
¡Revisa las issues con label `good first issue` o `help wanted`!

---

¡Gracias por contribuir a SuperMarket Delivery App! 🚀
# 🔔 Sistema de Notificaciones del Admin - FashionMarket Flutter

## 📋 Descripción

Sistema completo de notificaciones en tiempo real para el panel de administración que permite tener control de:

- **🛒 Nuevos pedidos**: Notificación de pedidos creados en las últimas 24 horas
- **📦 Pedidos pendientes**: Pedidos pagados esperando ser enviados
- **⚠️ Stock bajo**: Productos con 5 o menos unidades
- **🚫 Sin stock**: Productos agotados

## ✨ Características

### 1. **Badge de Notificaciones**
- Icono de campana en el AppBar de todas las pantallas admin
- Contador con animación y glow effect
- Color dinámico según el tipo de notificación

### 2. **Resumen en Dashboard**
- Card colapsable con resumen de notificaciones pendientes
- Badges categorizados por tipo (pedidos, stock bajo, agotados)
- Actualización automática cada 30 segundos

### 3. **Pantalla Detallada**
- Lista completa de todas las notificaciones
- Timestamp con formato relativo ("hace 2 horas")
- Navegación directa al pedido o producto relacionado
- Swipe para marcar como leída
- Pull to refresh

### 4. **Auto-refresh**
- Polling automático cada 30 segundos
- Sin impacto en el rendimiento
- Se detiene cuando el notifier se destruye

## 📁 Archivos Creados

```
FashionMarketFlutter/lib/features/admin/
├── data/
│   ├── models/
│   │   └── admin_notification_model.dart          # Modelos de notificaciones
│   └── services/
│       └── admin_notification_service.dart        # Servicio de Supabase
└── presentation/
    ├── pages/
    │   └── admin_notifications_screen.dart        # Pantalla de notificaciones
    ├── providers/
    │   └── admin_notification_providers.dart      # Riverpod providers
    └── widgets/
        └── admin_notification_button.dart         # Widget del badge
```

## 🚀 Instalación

### 1. Instalar dependencia
```bash
cd FashionMarketFlutter
flutter pub get
```

La dependencia `timeago: ^3.8.0` ya está agregada en `pubspec.yaml`.

### 2. Estructura de Base de Datos

El sistema usa las siguientes tablas de Supabase:
- `orders`: Para detectar nuevos pedidos y pendientes
- `product_variants`: Para detectar stock bajo y agotados

**Consultas SQL utilizadas:**
```sql
-- Pedidos nuevos (últimas 24 horas, estado 'paid')
SELECT * FROM orders 
WHERE status = 'paid' 
AND created_at >= NOW() - INTERVAL '24 hours'

-- Pedidos pendientes de envío
SELECT * FROM orders WHERE status = 'paid'

-- Stock bajo (≤ 5 unidades)
SELECT pv.*, p.name 
FROM product_variants pv
JOIN products p ON pv.product_id = p.id
WHERE pv.stock <= 5 AND pv.stock > 0

-- Sin stock
SELECT pv.*, p.name 
FROM product_variants pv
JOIN products p ON pv.product_id = p.id
WHERE pv.stock = 0
```

## 💡 Uso

### Badge de Notificaciones

El badge aparece automáticamente en todas las pantallas admin que lo incluyan:

```dart
appBar: AppBar(
  title: const Text('Dashboard'),
  actions: [
    const AdminNotificationButton(),  // ← Badge con contador
    const SizedBox(width: 8),
  ],
),
```

### Resumen en Dashboard

```dart
Column(
  children: [
    // Tarjeta de resumen (solo se muestra si hay notificaciones)
    const AdminNotificationSummaryCard(),
    
    // Resto del contenido...
  ],
)
```

### Provider de Notificaciones

```dart
// Contador de notificaciones sin leer
final unreadCount = ref.watch(unreadNotificationCountProvider);

// Resumen completo
final summaryAsync = ref.watch(notificationSummaryProvider);

// Lista de notificaciones
final notificationsAsync = ref.watch(notificationsProvider);

// Refrescar manualmente
ref.read(notificationsProvider.notifier).refresh();

// Marcar como leída
ref.read(notificationsProvider.notifier).markAsRead(notificationId);

// Marcar todas como leídas
ref.read(notificationsProvider.notifier).markAllAsRead();
```

## 🎨 Personalización

### Colores de Notificaciones

Definidos en `AdminNotificationType`:
- `newOrder`: `#06b6d4` (cyan)
- `lowStock`: `#f59e0b` (amber)
- `outOfStock`: `#ef4444` (red)
- `pendingOrders`: `#d946ef` (fuchsia)

### Intervalo de Auto-refresh

En `admin_notification_providers.dart`:
```dart
_refreshTimer = Timer.periodic(
  const Duration(seconds: 30),  // ← Cambiar aquí
  (_) => _loadSummary(),
);
```

### Umbral de Stock Bajo

En `admin_notification_service.dart`:
```dart
final lowStockResponse = await _supabase
    .from('product_variants')
    .select('id')
    .lte('stock', 5)  // ← Cambiar umbral aquí
    .gt('stock', 0);
```

## 🔧 Configuración Avanzada

### Agregar Notificación a Nueva Pantalla

1. Importar el widget:
```dart
import '../widgets/admin_notification_button.dart';
```

2. Agregarlo al AppBar:
```dart
appBar: AppBar(
  actions: [
    const AdminNotificationButton(),
    const SizedBox(width: 8),
  ],
),
```

### Crear Nuevo Tipo de Notificación

1. Agregar enum en `admin_notification_model.dart`:
```dart
enum AdminNotificationType {
  newOrder,
  lowStock,
  outOfStock,
  pendingOrders,
  myNewType,  // ← Nuevo tipo
}
```

2. Agregar propiedades visuales:
```dart
extension AdminNotificationTypeExtension on AdminNotificationType {
  String get iconEmoji {
    switch (this) {
      case AdminNotificationType.myNewType:
        return '✨';
      // ... otros casos
    }
  }

  String get color {
    switch (this) {
      case AdminNotificationType.myNewType:
        return '#10b981'; // green
      // ... otros casos
    }
  }
}
```

3. Agregar lógica en `admin_notification_service.dart`:
```dart
// En getNotifications()
final myNewData = await _supabase
    .from('my_table')
    .select('*')
    .eq('condition', true);

for (var item in (myNewData as List)) {
  notifications.add(AdminNotification(
    id: 'mynew_${item['id']}',
    type: AdminNotificationType.myNewType,
    title: 'Mi nuevo tipo',
    message: 'Descripción...',
    createdAt: DateTime.now(),
  ));
}
```

## 📱 Navegación desde Notificación

En `admin_notifications_screen.dart`, la función `_handleNotificationTap` maneja la navegación:

```dart
void _handleNotificationTap(BuildContext context, AdminNotification notification) {
  // Marca como leída
  ref.read(notificationsProvider.notifier).markAsRead(notification.id);

  // Navega según el tipo
  switch (notification.type) {
    case AdminNotificationType.newOrder:
      context.push('${AppRoutes.adminOrders}/${notification.data?['orderId']}');
      break;
    // ... otros casos
  }
}
```

## 🐛 Debug

### Verificar carga de notificaciones
```dart
// En admin_notification_service.dart
Future<NotificationSummary> getNotificationSummary() async {
  print('📊 Cargando resumen de notificaciones...');
  // ...
  print('✅ Resumen: $newOrdersCount pedidos, $lowStockCount stock bajo');
  return NotificationSummary(...);
}
```

### Verificar auto-refresh
```dart
// En admin_notification_providers.dart
void _startAutoRefresh() {
  _refreshTimer?.cancel();
  _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
    print('🔄 Auto-refresh de notificaciones...');
    _loadSummary();
  });
}
```

## ✅ Testing

Para probar el sistema:

1. **Crear pedidos de prueba** en Supabase
2. **Reducir stock** de productos a ≤5 unidades
3. **Verificar** que aparecen en:
   - Badge del AppBar
   - Card de resumen en Dashboard
   - Pantalla de notificaciones

## 🎯 Próximas Mejoras

- [ ] Notificaciones push (Firebase Cloud Messaging)
- [ ] Sonido al recibir notificación nueva
- [ ] Filtros en pantalla de notificaciones
- [ ] Persistencia local de notificaciones leídas
- [ ] WebSocket en lugar de polling
- [ ] Notificaciones de devoluciones
- [ ] Notificaciones de reviews pendientes

## 🤝 Integración con FashionStore (Web)

El sistema está diseñado para complementar las notificaciones por email existentes en FashionStore:

- **Web**: Emails automáticos via Resend (`admin-notifications.ts`)
- **Flutter**: Notificaciones en tiempo real en la app

Ambos sistemas consultan la misma base de datos de Supabase.

---

**Desarrollado para FashionMarket** 🛍️
Sistema de notificaciones en tiempo real para control de pedidos y stock.

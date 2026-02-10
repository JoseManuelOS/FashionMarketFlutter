# 📋 Plan de Implementación — FashionMarketFlutter

> Análisis de gaps entre FashionStore (web) y FashionMarketFlutter (app móvil)  
> Generado tras análisis profundo de ambas bases de código

---

## 📊 Resumen Ejecutivo

| Estado | Cantidad |
|--------|----------|
| ✅ Implementado completo | 22 features |
| ⚠️ Parcialmente implementado | 3 features |
| ❌ No implementado | 12 features |

**Lo que YA funciona bien:** Home, productos, categorías, ofertas, carrito, checkout con Stripe real, perfil con direcciones, búsqueda, filtros, todo el panel admin (dashboard, productos, pedidos, usuarios, carrusel, descuentos, notificaciones).

---

## 🔴 FASE 1 — Prioridad ALTA (Core del e-commerce)

### 1.1 Pantalla de Pedidos del Cliente
**Estado:** ❌ Placeholder "Coming soon"  
**Lo que tiene la web:** Lista de pedidos, detalle con tracking, cancelar pedido, solicitar devolución  
**Lo que tiene Flutter:** `OrderModel` + `OrderItemModel` completos, `FashionStoreApiService` ya tiene `getMyOrders()`, `cancelOrder()`, `requestReturn()`  
**Archivos referencia web:**
- `FashionStore/src/pages/cuenta/pedidos.astro`  
- `FashionStore/src/pages/api/orders/my-orders.ts`  
- `FashionStore/src/pages/api/orders/cancel.ts`  
- `FashionStore/src/pages/api/orders/request-return.ts`

**Archivos a crear en Flutter:**
```
lib/features/orders/
├── data/
│   ├── models/order_model.dart          ← YA EXISTE
│   └── repositories/order_repository.dart
├── presentation/
│   ├── providers/orders_providers.dart
│   └── pages/
│       ├── orders_screen.dart            ← Lista de pedidos
│       └── order_detail_screen.dart      ← Detalle + tracking + acciones
```

**Tareas:**
- [ ] Crear `OrderRepository` que use `FashionStoreApiService`
- [ ] Crear providers Riverpod para lista y detalle de pedidos
- [ ] Crear `OrdersScreen` — lista con filtro por estado, pull-to-refresh
- [ ] Crear `OrderDetailScreen` — items, estado, tracking, botones cancelar/devolver
- [ ] Reemplazar placeholder en `app_router.dart` ruta `/cuenta/pedidos`
- [ ] Enlazar desde `ProfileScreen` y `CheckoutSuccessScreen`

**Complejidad:** Media | **Estimación:** 3-4 horas

---

### 1.2 Favoritos / Wishlist
**Estado:** ❌ Toggle local sin persistencia  
**Lo que tiene la web:** Página de favoritos en `/cuenta/favoritos`, persistido en `customer_favorites` (Supabase)  
**Lo que tiene Flutter:** `_isFavorite` como estado local en `ProductCard` y `ProductDetailScreen` con `TODO: Implementar favoritos con Hive`  
**Archivos referencia web:**
- `FashionStore/src/pages/cuenta/favoritos.astro`
- `FashionStore/supabase/customers-schema.sql` (tabla `customer_favorites`)

**Archivos a crear en Flutter:**
```
lib/features/favorites/
├── data/
│   ├── models/favorite_model.dart
│   └── repositories/favorites_repository.dart
├── presentation/
│   ├── providers/favorites_providers.dart
│   └── pages/favorites_screen.dart
```

**Tareas:**
- [ ] Crear `FavoritesRepository` — CRUD en Supabase `customer_favorites`
- [ ] Crear provider global de favoritos (cache en memoria + Supabase sync)
- [ ] Crear `FavoritesScreen` — grid de productos favoritos
- [ ] Conectar toggle en `ProductCard` y `ProductDetailScreen` al provider real
- [ ] Añadir ruta `/cuenta/favoritos` en `app_router.dart`
- [ ] Tab o acceso desde `ProfileScreen`

**Complejidad:** Media | **Estimación:** 2-3 horas

---

### 1.3 Pantalla Reset Password + Deep Link
**Estado:** ❌ Redirige a la web  
**Lo que tiene la web:** Formulario nueva contraseña en `/auth/nueva-contrasena`  
**Lo que tiene Flutter:** `forgot_password_screen.dart` envía email con `redirectTo` al web  

**Archivos a crear en Flutter:**
```
lib/features/auth/presentation/pages/reset_password_screen.dart
```

**Tareas:**
- [ ] Crear `ResetPasswordScreen` — formulario nueva contraseña + confirmar
- [ ] Cambiar `redirectTo` a deep link de Flutter: `fashionmarket://reset-password`
- [ ] Configurar deep linking en `app_router.dart` para recibir tokens
- [ ] Manejar `supabase.auth.verifyOTP(type: recovery, token: ...)` o `setSession`
- [ ] Configurar URL scheme en Android (`AndroidManifest.xml`) e iOS (`Info.plist`)
- [ ] Añadir ruta en `app_router.dart`

**Complejidad:** Media | **Estimación:** 2-3 horas

---

## 🟡 FASE 2 — Prioridad MEDIA (Mejoras UX)

### 2.1 Ordenación de Productos
**Estado:** ⚠️ Dropdown existe pero no funciona  
**Detalle:** `sortBy` en `filter_providers.dart` + dropdown en UI, pero `TODO: Ordenar productos`  
**Archivos a modificar:**
- `lib/features/products/presentation/pages/product_list_page.dart`
- `lib/features/products/data/repositories/product_repository.dart` (o provider)

**Tareas:**
- [ ] Conectar `sortBy` del provider al query de Supabase (`.order()`)
- [ ] Mapear opciones: precio ↑, precio ↓, más nuevos, nombre A-Z

**Complejidad:** Pequeña | **Estimación:** 30 min

---

### 2.2 Drawer de Navegación
**Estado:** ⚠️ Botón hamburguesa sin drawer  
**Detalle:** `TODO: Abrir drawer de navegación` en `home_screen.dart`  
**Archivos a crear/modificar:**
- `lib/shared/widgets/app_drawer.dart` (NUEVO)
- `lib/features/home/presentation/pages/home_screen.dart`

**Tareas:**
- [ ] Crear `AppDrawer` — navegación a categorías, ofertas, cuenta, admin, ajustes
- [ ] Conectar desde botón hamburguesa del `HomeScreen`

**Complejidad:** Pequeña | **Estimación:** 1 hora

---

### 2.3 Productos Relacionados
**Estado:** ❌ `TODO: Productos relacionados`  
**Detalle:** Sección en `ProductDetailScreen` que muestra productos de la misma categoría  
**Archivos a modificar:**
- `lib/features/products/presentation/pages/product_detail_screen.dart`

**Tareas:**
- [ ] Query productos por misma categoría (excluir actual), limit 6
- [ ] Sección horizontal con `ProductCard` reutilizados
- [ ] Añadir al final del `ProductDetailScreen`

**Complejidad:** Pequeña | **Estimación:** 45 min

---

### 2.4 Compartir Producto
**Estado:** ❌ No existe  
**Detalle:** Botón para compartir enlace del producto  
**Dependencia:** Paquete `share_plus`

**Tareas:**
- [ ] Añadir `share_plus` a `pubspec.yaml`
- [ ] Botón share en `ProductDetailScreen` (AppBar action)
- [ ] Compartir: nombre + precio + URL web del producto

**Complejidad:** Pequeña | **Estimación:** 20 min

---

### 2.5 Suscripción Newsletter
**Estado:** ❌ No existe en Flutter  
**Lo que tiene la web:** Popup newsletter + API `/api/newsletter/subscribe`  
**Archivos referencia:**
- `FashionStore/src/pages/api/newsletter/subscribe.ts`

**Tareas:**
- [ ] Modal/popup en `HomeScreen` (primera vez, o desde drawer)
- [ ] Campo email + botón suscribirse
- [ ] Llamar a API de FashionStore `/api/newsletter/subscribe`
- [ ] Guardar en Hive que ya se mostró el popup

**Complejidad:** Pequeña | **Estimación:** 45 min

---

### 2.6 Google / Apple Sign-In
**Estado:** ⚠️ Botón visual sin funcionalidad  
**Detalle:** `TODO: Añadir icono` en `login_screen.dart`, no hay paquetes OAuth  
**Dependencias:** `google_sign_in`, `sign_in_with_apple`

**Tareas:**
- [ ] Añadir paquetes a `pubspec.yaml`
- [ ] Configurar Google Sign-In (Firebase / Supabase OAuth)
- [ ] Configurar Apple Sign-In (iOS only)
- [ ] Implementar flujo OAuth → Supabase session
- [ ] Conectar botones en `LoginScreen` y `RegisterScreen`

**Complejidad:** Media | **Estimación:** 3-4 horas

---

## 🟠 FASE 3 — Prioridad BAJA (Features avanzadas)

### 3.1 Recomendador de Talla
**Estado:** ❌ No existe  
**Lo que tiene la web:** `SizeRecommender.tsx` — widget interactivo  
**Referencia:** `FashionStore/src/components/islands/SizeRecommender.tsx`

**Tareas:**
- [ ] Crear widget modal con preguntas (altura, peso, preferencia ajuste)
- [ ] Lógica de recomendación basada en tabla de tallas
- [ ] Integrar en `ProductDetailScreen` junto a selector de talla

**Complejidad:** Media | **Estimación:** 2 horas

---

### 3.2 Admin: Facturas
**Estado:** ❌ No existe  
**Lo que tiene la web:** CRUD facturas, generación PDF, envío por email  
**Referencia:**
- `FashionStore/src/pages/admin/facturas/index.astro`
- `FashionStore/src/pages/api/invoice/[orderId].ts`
- `FashionStore/src/pages/api/invoice/send.ts`

**Tareas:**
- [ ] Pantalla admin con lista de facturas
- [ ] Generar factura llamando al API existente `/api/invoice/{orderId}`
- [ ] Visualizar PDF en app (paquete `flutter_pdfview` o similar)
- [ ] Enviar factura por email vía API `/api/invoice/send`

**Complejidad:** Grande | **Estimación:** 4-5 horas

---

### 3.3 Admin: Newsletter / Comunicaciones
**Estado:** ❌ No existe  
**Lo que tiene la web:** Enviar newsletters, gestionar suscriptores  
**Referencia:**
- `FashionStore/src/pages/admin/comunicaciones.astro`
- `FashionStore/src/pages/api/email/send-newsletter.ts`

**Tareas:**
- [ ] Pantalla admin: lista suscriptores newsletter
- [ ] Formulario: asunto + contenido + enviar
- [ ] Llamar API existente `/api/email/send-newsletter`

**Complejidad:** Media | **Estimación:** 2-3 horas

---

### 3.4 Admin: Configuración Animaciones
**Estado:** ❌ No existe  
**Lo que tiene la web:** Panel para configurar animaciones GSAP  
**Referencia:** `FashionStore/src/pages/admin/animaciones.astro`  
**Relevancia para móvil:** Baja (las animaciones GSAP son del web)

**Tareas:**
- [ ] Pantalla admin: toggle on/off animaciones + intensidad
- [ ] Llamar API `/api/animations/config`

**Complejidad:** Pequeña | **Estimación:** 1 hora

---

## 🔵 FASE 4 — Mobile-Specific (Nuevas para app)

### 4.1 Push Notifications (FCM)
**Estado:** ❌ No existe (ni en web)  
**Importancia:** Alta para engagement móvil  
**Dependencias:** `firebase_core`, `firebase_messaging`

**Tareas:**
- [ ] Configurar proyecto Firebase (Android + iOS)
- [ ] Añadir `firebase_core`, `firebase_messaging` a `pubspec.yaml`
- [ ] Registrar token FCM en Supabase (`device_tokens` table)
- [ ] Manejar notificaciones en foreground/background/terminated
- [ ] Notificaciones: pedido confirmado, enviado, stock de favorito
- [ ] Cloud Functions o Edge Functions para enviar push

**Complejidad:** Grande | **Estimación:** 5-6 horas

---

## 📆 Roadmap Sugerido

```
SEMANA 1 — Core
├── 🔴 1.1 Pantalla Pedidos (3-4h)
├── 🔴 1.2 Favoritos (2-3h)
└── 🔴 1.3 Reset Password + Deep Link (2-3h)

SEMANA 2 — UX
├── 🟡 2.1 Ordenación productos (30min)
├── 🟡 2.2 Drawer navegación (1h)
├── 🟡 2.3 Productos relacionados (45min)
├── 🟡 2.4 Compartir producto (20min)
├── 🟡 2.5 Newsletter popup (45min)
└── 🟡 2.6 Google/Apple Sign-In (3-4h)

SEMANA 3 — Avanzado
├── 🟠 3.1 Recomendador talla (2h)
├── 🟠 3.2 Admin Facturas (4-5h)
└── 🟠 3.3 Admin Newsletter (2-3h)

SEMANA 4 — Mobile-first
├── 🔵 4.1 Push Notifications (5-6h)
└── 🟠 3.4 Admin Animaciones (1h)
```

---

## 🗂️ Tabla completa de features

| # | Feature | Web | Flutter | Estado | Fase | Complejidad |
|---|---------|-----|---------|--------|------|-------------|
| 1 | Home (carousel, categorías, destacados) | ✅ | ✅ | ✅ | — | — |
| 2 | Listado productos | ✅ | ✅ | ✅ | — | — |
| 3 | Detalle producto | ✅ | ✅ | ✅ | — | — |
| 4 | Categorías | ✅ | ✅ | ✅ | — | — |
| 5 | Ofertas | ✅ | ✅ | ✅ | — | — |
| 6 | Carrito | ✅ | ✅ | ✅ | — | — |
| 7 | Checkout (4 pasos + Stripe) | ✅ | ✅ | ✅ | — | — |
| 8 | Checkout success | ✅ | ✅ | ✅ | — | — |
| 9 | Login | ✅ | ✅ | ✅ | — | — |
| 10 | Registro | ✅ | ✅ | ✅ | — | — |
| 11 | Recuperar contraseña | ✅ | ✅ | ✅ | — | — |
| 12 | Perfil + direcciones | ✅ | ✅ | ✅ | — | — |
| 13 | Búsqueda | ✅ | ✅ | ✅ | — | — |
| 14 | Filtros (precio, talla, color...) | ✅ | ✅ | ✅ | — | — |
| 15 | Admin: login | ✅ | ✅ | ✅ | — | — |
| 16 | Admin: dashboard + KPIs | ✅ | ✅ | ✅ | — | — |
| 17 | Admin: productos CRUD + stock | ✅ | ✅ | ✅ | — | — |
| 18 | Admin: pedidos + estados | ✅ | ✅ | ✅ | — | — |
| 19 | Admin: usuarios | ✅ | ✅ | ✅ | — | — |
| 20 | Admin: carrusel | ✅ | ✅ | ✅ | — | — |
| 21 | Admin: códigos descuento | ✅ | ✅ | ✅ | — | — |
| 22 | Admin: notificaciones stock | ✅ | ✅ | ✅ | — | — |
| 23 | **Pedidos del cliente** | ✅ | ❌ | 🔴 | 1 | Media |
| 24 | **Favoritos / Wishlist** | ✅ | ❌ | 🔴 | 1 | Media |
| 25 | **Reset password screen** | ✅ | ❌ | 🔴 | 1 | Media |
| 26 | **Ordenación productos** | ✅ | ⚠️ | 🟡 | 2 | Pequeña |
| 27 | **Drawer navegación** | N/A | ⚠️ | 🟡 | 2 | Pequeña |
| 28 | **Productos relacionados** | ✅ | ❌ | 🟡 | 2 | Pequeña |
| 29 | **Compartir producto** | ✅ | ❌ | 🟡 | 2 | Pequeña |
| 30 | **Newsletter suscripción** | ✅ | ❌ | 🟡 | 2 | Pequeña |
| 31 | **Google/Apple Sign-In** | ✅ | ⚠️ | 🟡 | 2 | Media |
| 32 | **Recomendador de talla** | ✅ | ❌ | 🟠 | 3 | Media |
| 33 | **Admin: facturas** | ✅ | ❌ | 🟠 | 3 | Grande |
| 34 | **Admin: newsletter** | ✅ | ❌ | 🟠 | 3 | Media |
| 35 | **Admin: animaciones** | ✅ | ❌ | 🟠 | 3 | Pequeña |
| 36 | **Push notifications** | N/A | ❌ | 🔵 | 4 | Grande |

---

## ⚙️ Configuraciones pendientes (no código)

| Tarea | Dónde |
|-------|-------|
| Configurar Custom SMTP en Supabase (Resend) | Supabase Dashboard → Auth → SMTP |
| Pegar template HTML de reset password | Supabase Dashboard → Auth → Email Templates → Reset Password |
| Fix token handling en `nueva-contrasena.astro` | FashionStore (SOLO LECTURA — hacer manualmente) |
| Cambiar `from` en 12 archivos de Resend | FashionStore (SOLO LECTURA — hacer manualmente) |

<style>
@import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&family=Inter:wght@300;400;500;600&display=swap');

@page {
  size: A4;
  margin: 25mm 20mm 25mm 20mm;
}

body {
  font-family: 'Inter', sans-serif;
  font-size: 11pt;
  line-height: 1.7;
  color: #27272a;
  background: #ffffff;
}

/* ── PORTADA ── */
.cover {
  page-break-after: always;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  text-align: center;
  background: #0a0a0f;
  background-image:
    radial-gradient(ellipse at 20% 0%, rgba(6,182,212,0.12) 0%, transparent 60%),
    radial-gradient(ellipse at 80% 100%, rgba(217,70,239,0.08) 0%, transparent 60%);
  margin: -25mm -20mm;
  padding: 60px 40px;
  position: relative;
  overflow: hidden;
}

.cover::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: linear-gradient(90deg, #06b6d4, #d946ef);
}

.cover-badge {
  display: inline-block;
  padding: 8px 24px;
  border: 1px solid rgba(6,182,212,0.5);
  border-radius: 50px;
  color: #06b6d4;
  font-family: 'Space Grotesk', sans-serif;
  font-size: 11pt;
  font-weight: 500;
  letter-spacing: 2px;
  text-transform: uppercase;
  margin-bottom: 40px;
  backdrop-filter: blur(8px);
  background: rgba(6,182,212,0.06);
}

.cover h1 {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 52pt;
  font-weight: 700;
  color: #ffffff;
  margin: 0 0 8px 0;
  letter-spacing: -1px;
  line-height: 1.1;
}

.cover h1 .accent {
  color: #06b6d4;
}

.cover h2 {
  font-family: 'Inter', sans-serif;
  font-size: 14pt;
  font-weight: 300;
  color: #a1a1aa;
  margin: 0 0 40px 0;
  letter-spacing: 1px;
}

.cover-divider {
  width: 80px;
  height: 3px;
  background: linear-gradient(to right, #06b6d4, #d946ef);
  border-radius: 2px;
  margin: 0 auto 40px auto;
}

.cover-meta {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  max-width: 460px;
  width: 100%;
}

.cover-meta-item {
  text-align: center;
  padding: 14px 10px;
  background: rgba(255,255,255,0.04);
  border: 1px solid rgba(255,255,255,0.08);
  border-radius: 10px;
}

.cover-meta-label {
  display: block;
  font-size: 8pt;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 1.5px;
  color: #06b6d4;
  margin-bottom: 4px;
}

.cover-meta-value {
  display: block;
  font-size: 11pt;
  color: #e4e4e7;
  font-weight: 500;
}

/* ── INDICE ── */
.toc {
  page-break-after: always;
  padding: 40px 0;
}

.toc-title {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 22pt;
  font-weight: 700;
  color: #0a0a0f;
  text-align: center;
  margin-bottom: 36px;
  position: relative;
}

.toc-title::after {
  content: '';
  display: block;
  width: 50px;
  height: 3px;
  background: linear-gradient(to right, #06b6d4, #d946ef);
  margin: 12px auto 0;
  border-radius: 2px;
}

.toc ol {
  list-style: none;
  counter-reset: toc-counter;
  padding: 0;
  max-width: 520px;
  margin: 0 auto;
}

.toc ol li {
  counter-increment: toc-counter;
  padding: 10px 0;
  border-bottom: 1px solid #e4e4e7;
  font-size: 11pt;
  display: flex;
  align-items: center;
}

.toc ol li::before {
  content: counter(toc-counter, decimal-leading-zero);
  font-family: 'Space Grotesk', sans-serif;
  font-weight: 700;
  font-size: 13pt;
  color: #06b6d4;
  margin-right: 16px;
  min-width: 28px;
}

/* ── CONTENIDO ── */
h2 {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 20pt;
  font-weight: 700;
  color: #0a0a0f;
  margin-top: 40px;
  margin-bottom: 16px;
  padding-bottom: 8px;
  border-bottom: 2px solid #06b6d4;
}

h3 {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 13pt;
  font-weight: 600;
  color: #18181b;
  margin-top: 28px;
  margin-bottom: 10px;
}

table {
  width: 100%;
  border-collapse: collapse;
  margin: 16px 0 24px 0;
  font-size: 10pt;
}

thead {
  background: #0a0a0f;
  color: #ffffff;
}

th {
  padding: 10px 14px;
  text-align: left;
  font-weight: 600;
  font-family: 'Space Grotesk', sans-serif;
  font-size: 9pt;
  letter-spacing: 0.5px;
  text-transform: uppercase;
}

td {
  padding: 10px 14px;
  border-bottom: 1px solid #e4e4e7;
}

tbody tr:nth-child(even) {
  background: #fafafa;
}

.info-box {
  background: linear-gradient(135deg, #ecfeff, #f0f9ff);
  border-left: 4px solid #06b6d4;
  padding: 16px 20px;
  border-radius: 0 8px 8px 0;
  margin: 20px 0;
  font-size: 10pt;
  color: #155e75;
}

.warn-box {
  background: linear-gradient(135deg, #fefce8, #fffbeb);
  border-left: 4px solid #f59e0b;
  padding: 16px 20px;
  border-radius: 0 8px 8px 0;
  margin: 20px 0;
  font-size: 10pt;
  color: #92400e;
}

/* ── API BADGES ── */
.api-badge {
  display: inline-block;
  padding: 2px 10px;
  border-radius: 4px;
  font-family: 'Space Grotesk', monospace;
  font-size: 9pt;
  font-weight: 600;
  color: #ffffff;
}
.api-get    { background: #10b981; }
.api-post   { background: #3b82f6; }
.api-put    { background: #f59e0b; }
.api-delete { background: #ef4444; }

/* ── FLOW ── */
.flow-diagram {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-wrap: wrap;
  gap: 6px;
  background: #fafafa;
  border: 1px solid #e4e4e7;
  border-radius: 10px;
  padding: 20px;
  margin: 20px 0;
}

.flow-diagram .step {
  display: inline-block;
  padding: 8px 16px;
  background: #0a0a0f;
  color: #ffffff;
  border-radius: 6px;
  font-family: 'Space Grotesk', sans-serif;
  font-size: 9pt;
  font-weight: 500;
}

.flow-diagram .arrow {
  color: #06b6d4;
  font-size: 16pt;
  font-weight: 700;
}

/* ── TECH GRID ── */
.tech-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 14px;
  margin: 20px 0;
}

.tech-card {
  background: #fafafa;
  border: 1px solid #e4e4e7;
  border-radius: 10px;
  padding: 16px;
  page-break-inside: avoid;
}

.tech-card strong {
  display: block;
  font-family: 'Space Grotesk', sans-serif;
  font-size: 11pt;
  color: #0a0a0f;
  margin-bottom: 4px;
}

.tech-card span {
  font-size: 9.5pt;
  color: #52525b;
  line-height: 1.5;
}

/* ── CHECKLIST ── */
.checklist {
  list-style: none;
  padding: 0;
}

.checklist li {
  padding: 8px 0 8px 30px;
  position: relative;
  border-bottom: 1px solid #f4f4f5;
}

.checklist li::before {
  content: '\2713';
  position: absolute;
  left: 0;
  color: #10b981;
  font-weight: 700;
  font-size: 14pt;
}

/* ── REPO LINK ── */
.cover-repo {
  margin-top: 32px;
  display: inline-block;
  padding: 10px 28px;
  border: 1px solid rgba(6,182,212,0.4);
  border-radius: 8px;
  background: rgba(6,182,212,0.08);
  text-decoration: none;
  transition: background 0.2s;
}

.cover-repo span {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 10pt;
  color: #06b6d4;
  letter-spacing: 0.5px;
}

.cover-repo .repo-label {
  display: block;
  font-size: 8pt;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 1.5px;
  color: #71717a;
  margin-bottom: 4px;
}

/* ── FOOTER ── */
.doc-footer {
  margin-top: 60px;
  padding-top: 20px;
  border-top: 2px solid #0a0a0f;
  text-align: center;
  font-size: 9pt;
  color: #71717a;
}

.doc-footer a {
  color: #06b6d4;
  text-decoration: none;
}
</style>

<!-- ═══════════════════════════ PORTADA ═══════════════════════════ -->

<div class="cover">
  <div class="cover-badge">Aplicacion Movil Flutter</div>

  <h1>Fashion<span class="accent">Market</span></h1>
  <h2>Plataforma de comercio electronico — App movil multiplataforma</h2>

  <div class="cover-divider"></div>

  <div class="cover-meta">
    <div class="cover-meta-item">
      <span class="cover-meta-label">Alumno</span>
      <span class="cover-meta-value">Jose Manuel Ortega Soto</span>
    </div>
    <div class="cover-meta-item">
      <span class="cover-meta-label">Asignatura</span>
      <span class="cover-meta-value">Sistema de Gestion Empresarial</span>
    </div>
    <div class="cover-meta-item">
      <span class="cover-meta-label">Profesor</span>
      <span class="cover-meta-value">David Soto</span>
    </div>
    <div class="cover-meta-item">
      <span class="cover-meta-label">Centro</span>
      <span class="cover-meta-value">Victoriafp</span>
    </div>
  </div>

  <a class="cover-repo" href="https://github.com/JoseManuelOS/FashionMarketFlutter.git">
    <span class="repo-label">Repositorio GitHub</span>
    <span>github.com/JoseManuelOS/FashionMarketFlutter</span>
  </a>
</div>

<!-- ═══════════════════════════ INDICE ═══════════════════════════ -->

<div class="toc">
  <div class="toc-title">Indice de contenidos</div>
  <ol>
    <li>Resumen ejecutivo</li>
    <li>Objetivos del proyecto</li>
    <li>Problema que resuelve</li>
    <li>Publico objetivo</li>
    <li>Descripcion general</li>
    <li>Funcionalidades principales</li>
    <li>Flujo de compra</li>
    <li>Pedidos, devoluciones y facturacion</li>
    <li>Panel de administracion</li>
    <li>Seguridad y confianza</li>
    <li>Arquitectura y tecnologias</li>
    <li>Integraciones externas</li>
    <li>Modelos de datos</li>
    <li>Navegacion y rutas</li>
    <li>Estado actual y operacion</li>
    <li>Impacto y beneficios</li>
    <li>Mejoras futuras</li>
  </ol>
</div>

<!-- ═══════════════════════════ CONTENIDO ═══════════════════════════ -->

<div class="content">

<!-- ═══════════════════════════ SECCION 1 ═══════════════════════════ -->

<h2>1. Resumen ejecutivo</h2>

<p><strong>FashionMarket Flutter</strong> es la aplicacion movil multiplataforma del ecosistema FashionMarket, desarrollada con <strong>Flutter 3</strong> y <strong>Dart 3.8</strong>. Complementa la tienda web (Astro) proporcionando una experiencia nativa optimizada para iOS y Android, con soporte adicional para Web.</p>

<p>La aplicacion implementa el ciclo completo de comercio electronico: catalogo de productos con busqueda y filtrado avanzado, carrito persistente offline, pasarela de pago Stripe, gestion de pedidos, favoritos, devoluciones, y un panel de administracion integrado para gestionar toda la operativa del negocio desde el dispositivo movil.</p>

<p>Construida siguiendo la arquitectura <strong>Clean Architecture por Features</strong>, utiliza <strong>Riverpod</strong> para la gestion de estado, <strong>Freezed</strong> para modelos inmutables, <strong>GoRouter</strong> para navegacion declarativa, <strong>Hive</strong> para persistencia local y <strong>Supabase</strong> como backend completo con autenticacion, base de datos PostgreSQL y suscripciones en tiempo real.</p>

<hr>

<!-- ═══════════════════════════ SECCION 2 ═══════════════════════════ -->

<h2>2. Objetivos del proyecto</h2>

<ul>
  <li><strong>Experiencia movil nativa:</strong> ofrecer una app fluida y optimizada para dispositivos moviles con rendimiento nativo en iOS y Android.</li>
  <li><strong>Comercio electronico completo:</strong> cubrir todo el ciclo de compra, desde el descubrimiento del producto hasta la entrega y posible devolucion.</li>
  <li><strong>Administracion movil:</strong> permitir al administrador gestionar productos, pedidos, devoluciones, descuentos y configuracion desde cualquier lugar.</li>
  <li><strong>Persistencia offline:</strong> mantener el carrito y preferencias del usuario disponibles sin conexion mediante almacenamiento local con Hive.</li>
  <li><strong>Tiempo real:</strong> reflejar cambios en ofertas, stock y configuracion de forma instantanea mediante Supabase Realtime.</li>
  <li><strong>Arquitectura mantenible:</strong> seguir principios de Clean Architecture con separacion de capas y tipado fuerte para facilitar el desarrollo y mantenimiento.</li>
  <li><strong>Manejo robusto de errores:</strong> utilizar programacion funcional con <code>Either&lt;Failure, T&gt;</code> (fpdart) y una jerarquia de excepciones tipadas.</li>
</ul>

<hr>

<!-- ═══════════════════════════ SECCION 3 ═══════════════════════════ -->

<h2>3. Problema que resuelve</h2>

<table>
  <thead><tr><th>Problema</th><th>Solucion en la app</th></tr></thead>
  <tbody>
    <tr><td>Los usuarios prefieren apps nativas para compras recurrentes</td><td>App Flutter multiplataforma con rendimiento nativo y navegacion fluida</td></tr>
    <tr><td>Perdida de carrito al cerrar la app o sin conexion</td><td>Carrito persistente con Hive — funciona offline y se mantiene entre sesiones</td></tr>
    <tr><td>El administrador necesita gestionar desde el movil</td><td>Panel de administracion completo integrado en la misma app con 13 pantallas dedicadas</td></tr>
    <tr><td>Actualizaciones lentas de ofertas y stock</td><td>Suscripciones Realtime de Supabase que reflejan cambios al instante</td></tr>
    <tr><td>Experiencia de compra lenta en web movil</td><td>Rendimiento nativo con animaciones Hero, carga de imagenes cacheadas y scroll infinito</td></tr>
    <tr><td>Gestion manual de devoluciones y cancelaciones</td><td>Flujos automatizados con reembolso Stripe, reposicion de stock y notificaciones por email</td></tr>
    <tr><td>Busqueda y filtrado limitados</td><td>Sistema completo de filtros por categoria, talla, color, precio, ofertas y ordenacion multiple</td></tr>
    <tr><td>Falta de metricas de negocio en movil</td><td>Dashboard con KPIs, graficos de ventas (fl_chart) y alertas de stock bajo</td></tr>
  </tbody>
</table>

<hr>

<!-- ═══════════════════════════ SECCION 4 ═══════════════════════════ -->

<h2>4. Publico objetivo</h2>

<ul>
  <li><strong>Compradores habituales:</strong> usuarios que prefieren una app nativa para realizar compras recurrentes con carrito persistente y notificaciones.</li>
  <li><strong>Usuarios moviles:</strong> personas que navegan y compran principalmente desde su smartphone, buscando una experiencia rapida y fluida.</li>
  <li><strong>Administradores en movimiento:</strong> gestores de la tienda que necesitan controlar pedidos, stock, devoluciones y configuracion desde cualquier lugar.</li>
  <li><strong>Profesorado y evaluadores:</strong> el proyecto demuestra el dominio de Flutter, arquitectura limpia, gestion de estado avanzada y desarrollo multiplataforma.</li>
</ul>

<hr>

<!-- ═══════════════════════════ SECCION 5 ═══════════════════════════ -->

<h2>5. Descripcion general</h2>

<p>La aplicacion se divide en dos grandes areas funcionales: la <strong>zona publica</strong> (cliente) y la <strong>zona de administracion</strong>.</p>

<h3>5.1 Zona publica (cliente)</h3>
<ul>
  <li>Splash animado con logo SVG animado por paths.</li>
  <li>Pantalla de inicio con carrusel hero configurable, categorias, productos destacados y ofertas en tiempo real.</li>
  <li>Catalogo de productos con grid escalonado, busqueda por texto, filtros avanzados (categoria, talla, color, precio, ofertas) y ordenacion multiple.</li>
  <li>Detalle de producto con galeria de imagenes, selector de color y talla, selector de cantidad con validacion de stock, boton de añadir al carrito con feedback visual, y productos relacionados.</li>
  <li>Carrito persistente con Hive (funciona offline), slide-over lateral, control de cantidades con validacion de stock real, y calculo automatico de totales y ahorros.</li>
  <li>Checkout multistep: datos de envio, metodo de envio, codigo de descuento y resumen final con redireccion a Stripe Checkout.</li>
  <li>Gestion de pedidos: listado con filtros por estado, detalle con linea temporal de estados, cancelacion con motivo, solicitud de devolucion y descarga de factura.</li>
  <li>Favoritos sincronizados con Supabase, toggle optimista con rollback ante error.</li>
  <li>Perfil de usuario con edicion de datos personales, direcciones y gestion de cuenta.</li>
  <li>Autenticacion completa: login con email, registro con bienvenida y newsletter, OAuth con Google y Apple, y recuperacion de contraseña.</li>
</ul>

<h3>5.2 Zona de administracion</h3>
<ul>
  <li>Dashboard con KPIs en tiempo real: ventas del dia/mes, pedidos pendientes, stock bajo, producto mas vendido.</li>
  <li>Graficos de ventas interactivos con periodos configurables (fl_chart).</li>
  <li>CRUD completo de productos: nombre, descripcion, precio, categoria, variantes (talla/color/stock), imagenes via Cloudinary, estado activo/inactivo y ofertas.</li>
  <li>Gestion de pedidos: listado filtrable, cambio de estado, envio de tracking, cancelacion con reembolso, aceptacion/rechazo de devoluciones (totales y parciales).</li>
  <li>Codigos de descuento: creacion, activacion/desactivacion, porcentaje/fijo, compra minima, limites de uso, un solo uso por cliente, fecha de expiracion.</li>
  <li>Carrusel de la home: CRUD de slides con titulo, subtitulo, imagen, enlace CTA, duracion y orden.</li>
  <li>Gestion de categorias: CRUD con nombre, slug, descripcion, imagen y orden de visualizacion.</li>
  <li>Gestion de usuarios: listado de clientes con estadisticas de pedidos y gasto total.</li>
  <li>Centro de notificaciones: pedidos nuevos (24h), variantes con stock bajo, productos agotados, pedidos pendientes.</li>
  <li>Newsletter: envio de campañas masivas con asunto, contenido, imagen, codigo promocional y boton CTA.</li>
  <li>Facturas: gestion y envio de facturas a clientes.</li>
  <li>Configuracion de animaciones del sitio.</li>
</ul>

<hr>

<!-- ═══════════════════════════ SECCION 6 ═══════════════════════════ -->

<h2>6. Funcionalidades principales</h2>

<h3>6.1 Catalogo de productos</h3>
<ul>
  <li>Grid escalonado con <code>flutter_staggered_grid_view</code> para una presentacion visual atractiva.</li>
  <li>Carga de imagenes cacheadas con <code>cached_network_image</code> y placeholders shimmer.</li>
  <li>Animaciones Hero entre la tarjeta del producto y la pagina de detalle.</li>
  <li>Busqueda por texto con debounce de 300ms y soporte para deep links (<code>/buscar?q=</code>).</li>
  <li>Filtros combinables: categoria, rango de tallas, rango de precios, solo ofertas, color.</li>
  <li>Ordenacion: mas recientes, precio ascendente/descendente, nombre A-Z/Z-A.</li>
  <li>Productos destacados como "Nuevo" si fueron creados en los ultimos 7 dias.</li>
  <li>Indicadores visuales de descuento con porcentaje y precio original tachado.</li>
</ul>

<h3>6.2 Carrito con persistencia local</h3>
<ul>
  <li>Almacenamiento en <strong>Hive</strong> con adaptador personalizado (<code>@HiveType</code>): el carrito sobrevive al cierre de la app y funciona sin conexion.</li>
  <li>Identificacion unica por combinacion de <code>productId + size + color</code>.</li>
  <li>Fusion automatica de cantidades al añadir un producto que ya esta en el carrito.</li>
  <li>Validacion de stock real antes de incrementar cantidad (consulta Supabase en tiempo real).</li>
  <li>Slide-over lateral accesible desde cualquier pantalla via el icono del carrito con badge de cantidad.</li>
  <li>Calculo automatico de subtotal, ahorros por descuento y total general.</li>
</ul>

<h3>6.3 Checkout y pagos con Stripe</h3>
<ul>
  <li>Proceso de checkout en 4 pasos con indicador de progreso visual.</li>
  <li><strong>Paso 1 — Datos de envio:</strong> email, telefono, nombre, direccion completa con validacion.</li>
  <li><strong>Paso 2 — Metodo de envio:</strong> seleccion entre metodos disponibles con precio y estimacion de entrega.</li>
  <li><strong>Paso 3 — Codigo de descuento:</strong> validacion en tiempo real contra el backend (limites de uso, expiracion, uso unico por cliente).</li>
  <li><strong>Paso 4 — Resumen y pago:</strong> desglose completo del pedido con redireccion a Stripe Checkout.</li>
  <li>Resolucion inteligente de variantes por color para enviar la informacion correcta a Stripe.</li>
  <li>Verificacion de pago post-redireccion con pantalla de exito y numero de pedido.</li>
  <li>Soporte para multiples metodos de pago en Stripe: tarjeta, Apple Pay, Google Pay, PayPal, Revolut Pay.</li>
</ul>

<h3>6.4 Cuenta del cliente</h3>
<ul>
  <li>Registro con creacion automatica de perfil en tabla <code>customers</code>, email de bienvenida y suscripcion opcional a newsletter con codigo promocional.</li>
  <li>Login con email/contraseña, Google OAuth y Apple OAuth con URLs de redireccion especificas por plataforma.</li>
  <li>Recuperacion de contraseña por email.</li>
  <li>Edicion de perfil: nombre, telefono, avatar.</li>
  <li>Historial de pedidos completo con filtro por estado.</li>
  <li>Favoritos sincronizados en la nube con toggle optimista.</li>
  <li>Descarga de facturas en PDF.</li>
</ul>

<h3>6.5 Ofertas y descuentos</h3>
<ul>
  <li><strong>Ofertas en tiempo real:</strong> <code>StreamProvider</code> suscrito a la tabla <code>products</code> — los cambios del admin se reflejan instantaneamente.</li>
  <li><strong>Switch global de ofertas:</strong> tabla <code>app_config</code> con flag <code>offers_enabled</code> monitorizado en tiempo real.</li>
  <li>Precios con descuento visibles en tarjetas y detalle del producto.</li>
  <li>Codigos de descuento aplicables en el checkout con validacion completa.</li>
  <li>Carrusel hero en la home con slides promocionales configurables por el admin.</li>
</ul>

<h3>6.6 Favoritos</h3>
<ul>
  <li>Almacenamiento en tabla <code>customer_favorites</code> de Supabase.</li>
  <li>Toggle optimista: la UI se actualiza inmediatamente, la sincronizacion con el servidor ocurre en segundo plano con rollback automatico ante errores.</li>
  <li>Cache global de IDs de productos favoritos para consultas reactivas eficientes.</li>
  <li>Pantalla dedicada con listado completo de productos favoritos.</li>
</ul>

<hr>

<!-- ═══════════════════════════ SECCION 7 ═══════════════════════════ -->

<h2>7. Flujo de compra</h2>

<div class="flow-diagram">
  <span class="step">Catalogo</span>
  <span class="arrow">&rarr;</span>
  <span class="step">Detalle producto</span>
  <span class="arrow">&rarr;</span>
  <span class="step">Seleccionar talla/color</span>
  <span class="arrow">&rarr;</span>
  <span class="step">Añadir al carrito</span>
  <span class="arrow">&rarr;</span>
  <span class="step">Checkout (4 pasos)</span>
  <span class="arrow">&rarr;</span>
  <span class="step">Stripe Checkout</span>
  <span class="arrow">&rarr;</span>
  <span class="step">Verificacion de pago</span>
  <span class="arrow">&rarr;</span>
  <span class="step">Pedido confirmado</span>
</div>

<ol>
  <li>El cliente navega por el catalogo, aplica filtros o busca un producto.</li>
  <li>Accede al detalle del producto con galeria de imagenes, descripcion y seleccion de variante (talla y color).</li>
  <li>Selecciona talla y color con validacion de stock en tiempo real. El selector muestra disponibilidad por variante.</li>
  <li>Añade el producto al carrito. Si el mismo producto con la misma variante ya existe, se fusionan las cantidades.</li>
  <li>Procede al checkout: introduce datos de envio, selecciona metodo de envio, aplica codigo de descuento opcional y revisa el resumen.</li>
  <li>Se crea una sesion de Stripe Checkout y se redirige al navegador externo para completar el pago de forma segura.</li>
  <li>Tras el pago, la app verifica la sesion de Stripe y muestra la pantalla de exito con el numero de pedido.</li>
  <li>Se vacia el carrito automaticamente y el pedido queda registrado en el historial del cliente.</li>
</ol>

<hr>

<!-- ═══════════════════════════ SECCION 8 ═══════════════════════════ -->

<h2>8. Pedidos, devoluciones y facturacion</h2>

<h3>8.1 Ciclo de vida del pedido</h3>

<div class="flow-diagram">
  <span class="step">Pendiente</span>
  <span class="arrow">&rarr;</span>
  <span class="step">Pagado</span>
  <span class="arrow">&rarr;</span>
  <span class="step">Enviado</span>
  <span class="arrow">&rarr;</span>
  <span class="step">Entregado</span>
</div>

<table>
  <thead><tr><th>Estado</th><th>Descripcion</th><th>Acciones disponibles</th></tr></thead>
  <tbody>
    <tr><td><strong>Pendiente</strong></td><td>Pedido creado, esperando confirmacion de pago</td><td>Cancelar (cliente/admin)</td></tr>
    <tr><td><strong>Pagado</strong></td><td>Pago verificado via webhook de Stripe</td><td>Cancelar (cliente/admin), preparar envio (admin)</td></tr>
    <tr><td><strong>Enviado</strong></td><td>Pedido enviado con numero de seguimiento</td><td>Consultar tracking (SEUR, Correos, MRW)</td></tr>
    <tr><td><strong>Entregado</strong></td><td>Pedido recibido por el cliente</td><td>Solicitar devolucion (cliente)</td></tr>
    <tr><td><strong>Cancelado</strong></td><td>Pedido cancelado con reembolso procesado</td><td>Solo lectura — motivo visible</td></tr>
    <tr><td><strong>Devolucion solicitada</strong></td><td>Cliente ha iniciado una devolucion</td><td>Aceptar/Rechazar (admin)</td></tr>
    <tr><td><strong>Devuelto</strong></td><td>Devolucion aceptada, reembolso procesado</td><td>Solo lectura</td></tr>
    <tr><td><strong>Devolucion parcial</strong></td><td>Parte de los articulos devueltos</td><td>Solicitar nueva devolucion (cliente)</td></tr>
    <tr><td><strong>Devolucion rechazada</strong></td><td>Admin ha denegado la devolucion</td><td>Solo lectura</td></tr>
  </tbody>
</table>

<h3>8.2 Cancelaciones</h3>
<ul>
  <li>El cliente puede cancelar pedidos en estado <strong>pendiente</strong> o <strong>pagado</strong>, indicando un motivo.</li>
  <li>El administrador puede cancelar cualquier pedido no entregado. El motivo "Cancelado por el administrador" se registra automaticamente.</li>
  <li>La cancelacion procesa el reembolso via Stripe, repone el stock y envia notificaciones por email a ambas partes.</li>
  <li>Los pedidos cancelados quedan bloqueados: el admin no puede modificar su estado ni datos de envio. El motivo de cancelacion se muestra en el detalle.</li>
</ul>

<h3>8.3 Devoluciones</h3>

<div class="flow-diagram">
  <span class="step">Solicitud</span>
  <span class="arrow">&rarr;</span>
  <span class="step">Revision admin</span>
  <span class="arrow">&rarr;</span>
  <span class="step">Aceptada / Rechazada</span>
  <span class="arrow">&rarr;</span>
  <span class="step">Reembolso</span>
</div>

<ul>
  <li>El cliente inicia la devolucion desde el detalle del pedido, indicando el motivo.</li>
  <li>El administrador revisa la solicitud y puede aceptarla (total o parcial) o rechazarla.</li>
  <li>Si se acepta, se procesa el reembolso via Stripe, se repone el stock y se genera una factura rectificativa en PDF.</li>
  <li>Las devoluciones parciales permiten devolver solo algunos articulos del pedido, manteniendo el estado <code>partial_return</code> para futuras devoluciones de los articulos restantes.</li>
  <li>El motivo de la devolucion se persiste en la base de datos y es visible tanto para el cliente como para el administrador.</li>
</ul>

<h3>8.4 Facturacion</h3>
<ul>
  <li><strong>Factura de venta:</strong> generada automaticamente al confirmar el pedido, descargable y enviable por email.</li>
  <li><strong>Factura rectificativa:</strong> generada automaticamente ante cancelacion o devolucion aceptada, con desglose de importes reembolsados.</li>
  <li>Generacion de PDF directamente en el Edge Function con <code>pdf-lib</code>, enviados como adjunto por email via Resend.</li>
</ul>

<hr>

<!-- ═══════════════════════════ SECCION 9 ═══════════════════════════ -->

<h2>9. Panel de administracion</h2>

<p>El panel de administracion esta integrado en la propia app, protegido por un sistema de autenticacion independiente basado en una tabla <code>admins</code> con verificacion de credenciales via RPC. Consta de <strong>13 pantallas</strong> con navegacion lateral mediante drawer.</p>

<h3>9.1 Dashboard</h3>
<ul>
  <li>KPIs del negocio: total de productos, total de clientes, pedidos pendientes, ventas del mes, productos con stock bajo, producto mas vendido.</li>
  <li>Listado rapido de los ultimos pedidos y productos registrados.</li>
  <li>Acceso directo a todas las secciones del panel desde tarjetas interactivas.</li>
</ul>

<h3>9.2 Graficos de ventas (KPIs)</h3>
<ul>
  <li>Graficos interactivos con <code>fl_chart</code> mostrando la evolucion diaria de pedidos e ingresos.</li>
  <li>Periodo configurable (ultimos N dias) con actualizacion en tiempo real.</li>
  <li>Visualizacion de tendencias de venta para toma de decisiones.</li>
</ul>

<h3>9.3 Gestion de productos</h3>
<table>
  <thead><tr><th>Accion</th><th>Descripcion</th></tr></thead>
  <tbody>
    <tr><td>Crear producto</td><td>Nombre, slug, descripcion, precio, categoria, etiquetas y estado (activo / inactivo)</td></tr>
    <tr><td>Variantes</td><td>Definicion de tallas y colores con stock independiente por variante, SKU y precio opcional</td></tr>
    <tr><td>Imagenes</td><td>Subida multiple a Cloudinary con compresion automatica (max 1200px, calidad 80), gestion de colores asociados</td></tr>
    <tr><td>Ofertas</td><td>Precio con descuento, porcentaje de ahorro, switch de oferta visible en catalogo y home</td></tr>
    <tr><td>Filtro activo/inactivo</td><td>Visualizacion separada de productos activos e inactivos con contadores</td></tr>
  </tbody>
</table>

<h3>9.4 Gestion de pedidos</h3>
<ul>
  <li>Listado completo con filtros por estado.</li>
  <li>Vista de detalle con productos comprados, direccion, metodo de envio y datos de pago.</li>
  <li>Cambio de estado: preparar envio con numero de tracking, marcar como entregado.</li>
  <li>Cancelacion con reembolso Stripe automatico y registro del motivo.</li>
  <li>Gestion de devoluciones: aceptar (total o parcial), rechazar, con reposicion de stock y factura rectificativa.</li>
  <li>Envio automatico de emails al cliente en cada cambio de estado (envio, entrega, cancelacion, devolucion).</li>
  <li>Pedidos cancelados bloqueados: panel de solo lectura con motivo visible.</li>
</ul>

<h3>9.5 Configuracion de la tienda</h3>
<ul>
  <li><strong>Codigos de descuento:</strong> creacion con porcentaje o cantidad fija, compra minima, limites de uso, uso unico por cliente, fechas de expiracion, activacion/desactivacion.</li>
  <li><strong>Carrusel hero:</strong> CRUD de slides con titulo, subtitulo, imagen, enlace CTA, duracion de visualizacion y orden.</li>
  <li><strong>Categorias:</strong> CRUD completo con nombre, slug, descripcion, imagen y orden de visualizacion.</li>
  <li><strong>Newsletter:</strong> envio de campañas masivas con contenido personalizado, imagen de encabezado, codigo promocional y boton de accion.</li>
  <li><strong>Notificaciones:</strong> centro con pedidos nuevos (24h), alertas de stock bajo/agotado y pedidos pendientes.</li>
  <li><strong>Usuarios:</strong> listado de clientes con estadisticas de pedidos realizados y gasto total acumulado.</li>
  <li><strong>Facturas:</strong> gestion y envio de facturas a clientes.</li>
  <li><strong>Animaciones:</strong> configuracion de animaciones del frontend.</li>
</ul>

<hr>

<!-- ═══════════════════════════ SECCION 10 ═══════════════════════════ -->

<h2>10. Seguridad y confianza</h2>

<table>
  <thead><tr><th>Mecanismo</th><th>Implementacion</th></tr></thead>
  <tbody>
    <tr><td>Autenticacion de clientes</td><td>Supabase Auth con email/contraseña, Google OAuth y Apple OAuth, con confirmacion por email y recuperacion de contraseña</td></tr>
    <tr><td>Autenticacion de admin</td><td>Sistema independiente con tabla <code>admins</code> y verificacion de credenciales via funcion RPC — aislado de Supabase Auth</td></tr>
    <tr><td>Autorizacion</td><td>Row Level Security (RLS) en todas las tablas: cada cliente solo accede a sus propios datos</td></tr>
    <tr><td>Funciones RPC admin</td><td>Funciones PostgreSQL con <code>SECURITY DEFINER</code> que operan como superusuario para bypass controlado de RLS en operaciones administrativas</td></tr>
    <tr><td>Pagos seguros</td><td>Stripe Checkout: los datos de la tarjeta nunca pasan por la app ni por nuestro servidor</td></tr>
    <tr><td>Verificacion de pagos</td><td>Webhook con firma HMAC — los pedidos solo se confirman tras validacion criptografica en el servidor</td></tr>
    <tr><td>Edge Function relay</td><td>Las peticiones Web pasan por un Supabase Edge Function que actua como proxy CORS, evitando exponer el backend directamente al navegador</td></tr>
    <tr><td>Variables de entorno</td><td>Claves sensibles almacenadas exclusivamente en variables de entorno del servidor y Edge Functions</td></tr>
    <tr><td>Manejo de errores</td><td>Jerarquia de excepciones tipadas (<code>AppException</code>) con <code>Either&lt;Failure, T&gt;</code> de fpdart para propagacion funcional de errores</td></tr>
  </tbody>
</table>

<div class="warn-box">
<strong>Principio de minimo privilegio:</strong> la app utiliza exclusivamente la clave anonima de Supabase. Las operaciones administrativas se ejecutan a traves de funciones RPC con <code>SECURITY DEFINER</code> y el Edge Function relay, nunca con la clave de servicio en el cliente.
</div>

<hr>

<!-- ═══════════════════════════ SECCION 11 ═══════════════════════════ -->

<h2>11. Arquitectura y tecnologias</h2>

<div class="tech-grid">
  <div class="tech-card">
    <strong>Flutter 3 + Dart 3.8</strong>
    <span>Framework multiplataforma para iOS, Android y Web con compilacion nativa y hot reload para desarrollo agil</span>
  </div>
  <div class="tech-card">
    <strong>Riverpod</strong>
    <span>Gestion de estado reactiva con generacion de codigo, StreamProvider para tiempo real y FutureProvider para datos asincronos</span>
  </div>
  <div class="tech-card">
    <strong>Freezed</strong>
    <span>Modelos de datos inmutables con union types, serializacion JSON automatica y metodo copyWith generado</span>
  </div>
  <div class="tech-card">
    <strong>GoRouter</strong>
    <span>Navegacion declarativa con StatefulShellRoute para pestañas, deep links, rutas tipadas y soporte para redirecciones</span>
  </div>
  <div class="tech-card">
    <strong>Supabase</strong>
    <span>Base de datos PostgreSQL, autenticacion, Realtime subscriptions, Edge Functions y Row Level Security como backend completo</span>
  </div>
  <div class="tech-card">
    <strong>Stripe</strong>
    <span>Pasarela de pagos con Checkout Sessions, redireccion a navegador externo, verificacion post-pago y reembolsos automaticos</span>
  </div>
  <div class="tech-card">
    <strong>Hive</strong>
    <span>Base de datos local NoSQL para persistencia del carrito offline con adaptadores personalizados y acceso ultrarapido</span>
  </div>
  <div class="tech-card">
    <strong>Cloudinary</strong>
    <span>Almacenamiento y optimizacion de imagenes con upload sin firma, compresion automatica y transformaciones por URL</span>
  </div>
  <div class="tech-card">
    <strong>fpdart</strong>
    <span>Programacion funcional con Either&lt;Failure, T&gt; para manejo robusto de errores sin excepciones no controladas</span>
  </div>
  <div class="tech-card">
    <strong>fl_chart</strong>
    <span>Graficos interactivos y personalizables para el dashboard de ventas con visualizacion de tendencias diarias</span>
  </div>
</div>

<h3>Patron arquitectonico</h3>
<p>La aplicacion sigue el patron <strong>Clean Architecture por Features</strong> (Feature-first). Cada funcionalidad se organiza en su propia carpeta dentro de <code>lib/features/</code> con tres capas independientes:</p>

<table>
  <thead><tr><th>Capa</th><th>Responsabilidad</th><th>Contenido</th></tr></thead>
  <tbody>
    <tr><td><strong>Data</strong></td><td>Acceso a datos y serializacion</td><td>Modelos Freezed, datasources remotos, repositorios de implementacion</td></tr>
    <tr><td><strong>Domain</strong></td><td>Logica de negocio pura</td><td>Repositorios abstractos, entidades, casos de uso</td></tr>
    <tr><td><strong>Presentation</strong></td><td>Interfaz de usuario y estado</td><td>Screens, widgets, providers Riverpod</td></tr>
  </tbody>
</table>

<h3>Estructura de carpetas</h3>

<table>
  <thead><tr><th>Carpeta</th><th>Descripcion</th></tr></thead>
  <tbody>
    <tr><td><code>lib/config/</code></td><td>Configuracion global: tema, router, constantes, almacenamiento Hive</td></tr>
    <tr><td><code>lib/shared/</code></td><td>Codigo compartido: excepciones, extensiones, servicios, widgets reutilizables</td></tr>
    <tr><td><code>lib/features/admin/</code></td><td>Panel de administracion (13 pantallas, dashboard, CRUD, notificaciones)</td></tr>
    <tr><td><code>lib/features/auth/</code></td><td>Autenticacion (login, registro, recuperacion, OAuth)</td></tr>
    <tr><td><code>lib/features/cart/</code></td><td>Carrito con persistencia Hive</td></tr>
    <tr><td><code>lib/features/checkout/</code></td><td>Proceso de checkout y pagos Stripe</td></tr>
    <tr><td><code>lib/features/favorites/</code></td><td>Lista de favoritos sincronizada</td></tr>
    <tr><td><code>lib/features/home/</code></td><td>Pantalla de inicio con carrusel y ofertas en tiempo real</td></tr>
    <tr><td><code>lib/features/orders/</code></td><td>Gestion de pedidos del cliente</td></tr>
    <tr><td><code>lib/features/products/</code></td><td>Catalogo, detalle, busqueda y filtrado de productos</td></tr>
    <tr><td><code>lib/features/profile/</code></td><td>Perfil y datos personales del usuario</td></tr>
    <tr><td><code>lib/features/splash/</code></td><td>Pantalla de carga con logo animado</td></tr>
  </tbody>
</table>

<hr>

<!-- ═══════════════════════════ SECCION 12 ═══════════════════════════ -->

<h2>12. Integraciones externas</h2>

<table>
  <thead><tr><th>Servicio</th><th>Funcion</th><th>Comunicacion</th></tr></thead>
  <tbody>
    <tr><td><strong>Supabase</strong></td><td>Base de datos, autenticacion, Realtime y politicas de acceso RLS</td><td>SDK oficial de Flutter (<code>supabase_flutter</code>)</td></tr>
    <tr><td><strong>Stripe</strong></td><td>Cobros online y reembolsos automaticos via Checkout Sessions</td><td>API REST a traves del backend FashionStore + Edge Function relay</td></tr>
    <tr><td><strong>Cloudinary</strong></td><td>Almacenamiento, compresion y entrega optimizada de imagenes</td><td>Upload HTTP sin firma + URLs de transformacion automatica</td></tr>
    <tr><td><strong>FashionStore API</strong></td><td>Backend Astro que gestiona checkout, emails, stock, facturas y descuentos</td><td>HTTP client directo (movil) o Edge Function relay (Web/CORS)</td></tr>
    <tr><td><strong>Resend</strong></td><td>Envio de emails transaccionales (confirmaciones, envio, devolucion, newsletter)</td><td>API REST invocada desde el backend FashionStore y Edge Functions</td></tr>
  </tbody>
</table>

<div class="info-box">
La app movil se comunica directamente con el backend FashionStore via HTTP. En Web, las peticiones pasan por un <strong>Supabase Edge Function</strong> (<code>orders-relay</code>) que actua como proxy CORS para evitar restricciones del navegador.
</div>

<hr>

<!-- ═══════════════════════════ SECCION 13 ═══════════════════════════ -->

<h2>13. Modelos de datos</h2>

<p>Todos los modelos principales utilizan <strong>Freezed</strong> para inmutabilidad, serializacion JSON automatica y metodo <code>copyWith</code>. El carrito utiliza ademas <strong>Hive</strong> para persistencia local.</p>

<h3>13.1 Modelos del dominio</h3>

<table>
  <thead><tr><th>Modelo</th><th>Campos principales</th><th>Propiedades computadas</th></tr></thead>
  <tbody>
    <tr>
      <td><strong>ProductModel</strong></td>
      <td>id, name, slug, description, price, stock, categoryId, isOffer, originalPrice, discountPercent, sizes, active, images, tags</td>
      <td>mainImage, hasDiscount, formattedPrice, availableSizes, colors, isNew, isSoldOut, canBePurchased</td>
    </tr>
    <tr>
      <td><strong>ProductImageModel</strong></td>
      <td>id, productId, imageUrl, sortOrder, color, colorHex, altText</td>
      <td>thumbnailUrl (300x400), detailUrl (800x1000)</td>
    </tr>
    <tr>
      <td><strong>ProductVariantModel</strong></td>
      <td>id, productId, size, stock, sku, price, isOffer</td>
      <td>isOutOfStock, isLowStock (3 o menos)</td>
    </tr>
    <tr>
      <td><strong>CategoryModel</strong></td>
      <td>id, name, slug, description, imageUrl, parentId, sortOrder, active</td>
      <td>—</td>
    </tr>
    <tr>
      <td><strong>OrderModel</strong></td>
      <td>id, orderNumber, totalPrice, status, customerId, customerEmail, shippingAddress, trackingNumber, cancellationReason, items</td>
      <td>formattedOrderNumber, canCancel, canRequestReturn, trackingUrl</td>
    </tr>
    <tr>
      <td><strong>CartItemModel</strong></td>
      <td>id, productId, name, slug, price, quantity, size, imageUrl, color, originalPrice, discountPercent</td>
      <td>uniqueId (productId_size_color), subtotal, savings, hasDiscount</td>
    </tr>
    <tr>
      <td><strong>CustomerModel</strong></td>
      <td>id, email, fullName, phone, avatarUrl, defaultAddressId, newsletter</td>
      <td>displayName, initials, isProfileComplete</td>
    </tr>
    <tr>
      <td><strong>CarouselSlideModel</strong></td>
      <td>id, title, subtitle, imageUrl, ctaText, ctaLink, duration, sortOrder, isActive, discountCode</td>
      <td>—</td>
    </tr>
  </tbody>
</table>

<h3>13.2 Modelos de soporte</h3>

<table>
  <thead><tr><th>Modelo</th><th>Descripcion</th></tr></thead>
  <tbody>
    <tr><td><strong>AdminModel</strong></td><td>id, email, fullName, role — con isSuperAdmin y displayName</td></tr>
    <tr><td><strong>AdminNotification / NotificationSummary</strong></td><td>Tipos: newOrder, lowStock, outOfStock, pendingOrders — con contadores y totalUnread</td></tr>
    <tr><td><strong>ShippingMethodModel</strong></td><td>id, name, description, price, estimatedDaysMin/Max — con formattedPrice y estimatedDelivery</td></tr>
    <tr><td><strong>OrderItemModel</strong></td><td>id, orderId, productId, productName, productImage, quantity, size, color, priceAtPurchase</td></tr>
    <tr><td><strong>CustomerAddressModel</strong></td><td>street, city, postalCode, province, country — para envio y facturacion</td></tr>
    <tr><td><strong>ProductFilters</strong></td><td>search, categorySlug, sizes, priceMin/Max, offersOnly, color, sortBy</td></tr>
  </tbody>
</table>

<hr>

<!-- ═══════════════════════════ SECCION 14 ═══════════════════════════ -->

<h2>14. Navegacion y rutas</h2>

<p>La navegacion utiliza <strong>GoRouter</strong> con <code>StatefulShellRoute</code> para mantener el estado de las pestañas principales. La app soporta deep links tanto en Web como en nativo.</p>

<h3>14.1 Navegacion principal (pestañas)</h3>

<table>
  <thead><tr><th>Pestaña</th><th>Ruta</th><th>Icono</th><th>Pantalla</th></tr></thead>
  <tbody>
    <tr><td>Inicio</td><td><code>/home</code></td><td>Icons.home</td><td>HomeScreen — carrusel, categorias, productos destacados, ofertas</td></tr>
    <tr><td>Productos</td><td><code>/productos</code></td><td>Icons.grid_view</td><td>ProductListPage — catalogo con filtros y busqueda</td></tr>
    <tr><td>Carrito</td><td><code>/carrito</code></td><td>Icons.shopping_bag + badge</td><td>CartScreen — productos añadidos con totales</td></tr>
    <tr><td>Cuenta</td><td><code>/cuenta</code></td><td>Icons.person</td><td>ProfileScreen — perfil, pedidos, favoritos</td></tr>
  </tbody>
</table>

<h3>14.2 Rutas de cliente</h3>

<table>
  <thead><tr><th>Ruta</th><th>Pantalla</th></tr></thead>
  <tbody>
    <tr><td><code>/productos/:slug</code></td><td>Detalle de producto con galeria, variantes y carrito</td></tr>
    <tr><td><code>/categoria/:slug</code></td><td>Listado filtrado por categoria</td></tr>
    <tr><td><code>/ofertas</code></td><td>Listado filtrado solo ofertas</td></tr>
    <tr><td><code>/buscar?q=texto</code></td><td>Busqueda por texto con deep link</td></tr>
    <tr><td><code>/cuenta/pedidos</code></td><td>Historial de pedidos del cliente</td></tr>
    <tr><td><code>/cuenta/pedidos/:orderId</code></td><td>Detalle de pedido con timeline de estados</td></tr>
    <tr><td><code>/cuenta/favoritos</code></td><td>Productos favoritos</td></tr>
    <tr><td><code>/checkout</code></td><td>Proceso de compra (4 pasos)</td></tr>
    <tr><td><code>/checkout/success</code></td><td>Confirmacion de compra exitosa</td></tr>
  </tbody>
</table>

<h3>14.3 Rutas de autenticacion</h3>

<table>
  <thead><tr><th>Ruta</th><th>Pantalla</th></tr></thead>
  <tbody>
    <tr><td><code>/auth/login</code></td><td>Inicio de sesion (email, Google, Apple)</td></tr>
    <tr><td><code>/auth/registro</code></td><td>Registro de nuevo cliente</td></tr>
    <tr><td><code>/auth/recuperar</code></td><td>Recuperacion de contraseña</td></tr>
  </tbody>
</table>

<h3>14.4 Rutas de administracion</h3>

<table>
  <thead><tr><th>Ruta</th><th>Pantalla</th></tr></thead>
  <tbody>
    <tr><td><code>/admin/dashboard</code></td><td>Dashboard con KPIs y resumen</td></tr>
    <tr><td><code>/admin/kpis</code></td><td>Graficos de ventas interactivos</td></tr>
    <tr><td><code>/admin/productos</code></td><td>Gestion CRUD de productos</td></tr>
    <tr><td><code>/admin/pedidos</code></td><td>Gestion de pedidos y devoluciones</td></tr>
    <tr><td><code>/admin/codigos</code></td><td>Codigos de descuento</td></tr>
    <tr><td><code>/admin/carrusel</code></td><td>Configuracion del carrusel hero</td></tr>
    <tr><td><code>/admin/categorias</code></td><td>Gestion de categorias</td></tr>
    <tr><td><code>/admin/usuarios</code></td><td>Listado de clientes</td></tr>
    <tr><td><code>/admin/notificaciones</code></td><td>Centro de notificaciones</td></tr>
    <tr><td><code>/admin/newsletter</code></td><td>Envio de campañas</td></tr>
    <tr><td><code>/admin/facturas</code></td><td>Gestion de facturas</td></tr>
    <tr><td><code>/admin/animaciones</code></td><td>Configuracion de animaciones</td></tr>
  </tbody>
</table>

<hr>

<!-- ═══════════════════════════ SECCION 15 ═══════════════════════════ -->

<h2>15. Estado actual y operacion</h2>

<table>
  <thead><tr><th>Aspecto</th><th>Estado</th></tr></thead>
  <tbody>
    <tr><td>App cliente (iOS / Android)</td><td>Operativa — todas las funcionalidades implementadas y probadas</td></tr>
    <tr><td>App cliente (Web)</td><td>Operativa — con Edge Function relay para CORS</td></tr>
    <tr><td>Panel de administracion</td><td>Operativo — 13 pantallas con gestion completa</td></tr>
    <tr><td>Pasarela de pago</td><td>Integrada y funcional con Stripe Checkout</td></tr>
    <tr><td>Persistencia local</td><td>Carrito offline con Hive, preferencias con SharedPreferences</td></tr>
    <tr><td>Tiempo real</td><td>Activo — ofertas y configuracion se actualizan instantaneamente via Supabase Realtime</td></tr>
    <tr><td>Backend compartido</td><td>Conectado al mismo backend FashionStore (Astro) y base de datos Supabase que la web</td></tr>
    <tr><td>Base de datos</td><td>18+ tablas con politicas RLS, funciones RPC, triggers y Realtime habilitado</td></tr>
  </tbody>
</table>

<h3>Servicios compartidos implementados</h3>

<table>
  <thead><tr><th>Servicio</th><th>Archivo</th><th>Funcion</th></tr></thead>
  <tbody>
    <tr><td><strong>SupabaseService</strong></td><td>shared/services/supabase_service.dart</td><td>Singleton de Supabase: auth, database, realtime, storage</td></tr>
    <tr><td><strong>FashionStoreApiService</strong></td><td>shared/services/fashion_store_api_service.dart</td><td>Cliente HTTP (637 lineas) para todo el backend: checkout, stock, descuentos, emails, pedidos, facturas</td></tr>
    <tr><td><strong>CloudinaryService</strong></td><td>shared/services/cloudinary_service.dart</td><td>Upload sin firma, compresion (1200px, calidad 80), carpetas por tipo (products, carousel, categories)</td></tr>
    <tr><td><strong>StripeService</strong></td><td>checkout/presentation/services/stripe_service.dart</td><td>Resolucion de variantes, creacion de sesion Stripe, apertura en navegador externo, verificacion</td></tr>
    <tr><td><strong>LocalStorageService</strong></td><td>shared/services/local_storage_service.dart</td><td>Wrapper de SharedPreferences con soporte para tipos primitivos, listas y JSON</td></tr>
  </tbody>
</table>

<h3>Edge Function: orders-relay</h3>
<p>Funcion de Supabase Edge Functions (703 lineas TypeScript) que actua como proxy CORS entre Flutter Web y el backend FashionStore. Soporta 17 acciones diferentes incluyendo checkout, verificacion de pago, gestion de descuentos, emails, devoluciones y cancelaciones. Incluye generacion directa de PDFs de facturas rectificativas con <code>pdf-lib</code>.</p>

<hr>

<!-- ═══════════════════════════ SECCION 16 ═══════════════════════════ -->

<h2>16. Impacto y beneficios</h2>

<table>
  <thead><tr><th>Beneficio</th><th>Descripcion</th></tr></thead>
  <tbody>
    <tr><td><strong>Experiencia nativa</strong></td><td>Rendimiento nativo en iOS y Android con animaciones fluidas, gestos naturales y carga instantanea</td></tr>
    <tr><td><strong>Acceso offline</strong></td><td>El carrito funciona sin conexion gracias a Hive — el usuario nunca pierde sus selecciones</td></tr>
    <tr><td><strong>Administracion movil</strong></td><td>El gestor de la tienda controla pedidos, stock, devoluciones y configuracion desde cualquier lugar</td></tr>
    <tr><td><strong>Actualización instantanea</strong></td><td>Los cambios en ofertas y configuracion se reflejan en tiempo real en todos los dispositivos conectados</td></tr>
    <tr><td><strong>Ecosistema unificado</strong></td><td>Comparte backend, base de datos y logica de negocio con la tienda web, eliminando duplicacion</td></tr>
    <tr><td><strong>Escalabilidad</strong></td><td>Arquitectura Clean Architecture por Features preparada para crecer en funcionalidades sin rediseñar</td></tr>
    <tr><td><strong>Mantenibilidad</strong></td><td>Modelos inmutables (Freezed), tipado fuerte (Dart), estado reactivo (Riverpod) y errores funcionales (fpdart) reducen bugs</td></tr>
    <tr><td><strong>Multiplataforma</strong></td><td>Un unico codebase para iOS, Android y Web — reduccion significativa de tiempo y coste de desarrollo</td></tr>
  </tbody>
</table>

<hr>

<!-- ═══════════════════════════ SECCION 17 ═══════════════════════════ -->

<h2>17. Mejoras futuras</h2>

<table>
  <thead><tr><th>Mejora</th><th>Descripcion</th></tr></thead>
  <tbody>
    <tr><td>Notificaciones push</td><td>Firebase Cloud Messaging para alertas de estado de pedido, ofertas y recordatorios de carrito abandonado</td></tr>
    <tr><td>Chat en vivo</td><td>Atencion al cliente en tiempo real integrada en la app con soporte de Supabase Realtime</td></tr>
    <tr><td>Programa de fidelizacion</td><td>Puntos por compra, descuentos acumulables y niveles de cliente VIP</td></tr>
    <tr><td>Internacionalizacion</td><td>Soporte multiidioma (i18n) y multidivisa para expansion internacional</td></tr>
    <tr><td>Opiniones de clientes</td><td>Sistema de valoraciones y reseñas verificadas en los productos con fotos</td></tr>
    <tr><td>Modo oscuro / claro</td><td>Implementacion completa del tema claro (actualmente dark-only) con switch de preferencia del usuario</td></tr>
    <tr><td>Biometria</td><td>Login con huella dactilar y Face ID para acceso rapido y seguro</td></tr>
    <tr><td>Widget de inicio</td><td>Widget nativo para iOS y Android mostrando ofertas destacadas en la pantalla de inicio del dispositivo</td></tr>
  </tbody>
</table>


</div>

<!-- ── PIE DE PAGINA ── -->
<div class="doc-footer">
  <p><strong>FashionMarket Flutter</strong> — Documentacion de entrega del proyecto</p>
  <p>Jose Manuel Ortega Soto · Sistema de Gestion Empresarial · Victoriafp · 2026</p>
  <p><a href="https://github.com/JoseManuelOS/FashionMarketFlutter.git">github.com/JoseManuelOS/FashionMarketFlutter</a></p>
</div>

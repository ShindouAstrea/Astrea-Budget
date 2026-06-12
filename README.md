# Astrea Budget

App móvil (Android e iOS) para llevar control visual de **ingresos y gastos mes a mes**,
recordar qué pagar y qué ya se pagó, y autorregular las finanzas personales.

Pensada para Chile: moneda por defecto **CLP**, formato `es_CL`, montos sin decimales
(ej. `$1.250.000`).

## Stack

- **Flutter** (canal stable) + Dart null-safety.
- **Riverpod** (`flutter_riverpod`) — estado y acceso a datos. Arquitectura por capas
  `data / domain / presentation` dentro de cada *feature*.
- **go_router** — navegación declarativa con guard de autenticación y bloqueo.
- **Supabase** — Postgres + Auth + Row Level Security.
- **freezed** + **json_serializable** — modelos inmutables (con codegen).
- **fl_chart** — gráfico de gasto por categoría.
- **local_auth** + **flutter_secure_storage** — PIN/biometría y almacenamiento seguro.
- **intl** + **google_fonts** (IBM Plex Sans) — localización y tipografía.

> Nota sobre codegen: los modelos usan `build_runner` (freezed/json). Los *providers*
> de Riverpod se escriben **a mano** (sin `riverpod_generator`) porque su versión 2.x
> arrastra `analyzer_plugin 0.12.0`, incompatible con el `analyzer` del SDK actual.
> Son funcionalmente idénticos a los generados.

## Estructura

```
lib/
├── main.dart                 # bootstrap: init Supabase + ProviderScope
├── app.dart                  # MaterialApp.router, tema, locale es_CL, re-bloqueo
├── core/
│   ├── config/               # env (dart-define) + provider del cliente Supabase
│   ├── router/               # rutas + go_router con guards
│   ├── theme/                # Material 3 claro/oscuro + colores semánticos
│   ├── utils/                # formatters (CLP) y validators
│   └── widgets/              # shell, selector de mes, estados vacío/error
├── shared/                   # enums (mapean a la BD) y mes seleccionado
└── features/
    ├── auth/                 # login, registro, recuperar, sesión
    ├── categories/           # CRUD de categorías
    ├── transactions/         # CRUD + historial filtrable
    ├── services/             # servicios + service_payments (marcar pagado)
    ├── dashboard/            # resumen, próximos pagos, gráfico
    ├── security/             # PIN / biometría + pantalla de bloqueo
    └── settings/             # perfil, seguridad, moneda

supabase/
├── schema.sql                # tablas + RLS + trigger de categorías + enums
└── seed.sql                  # datos de ejemplo (opcional)
```

## Configuración de Supabase

1. Crea un proyecto en [supabase.com](https://supabase.com).
2. En **SQL Editor**, pega y ejecuta [`supabase/schema.sql`](supabase/schema.sql).
   Esto crea tablas, políticas RLS (por `user_id`), los `enum` y el trigger que
   inserta las categorías por defecto al registrarse.
3. (Opcional) En **Authentication → Providers → Email**, desactiva *"Confirm email"*
   si quieres probar el login sin verificar el correo.
4. Para el modo invitado, en **Authentication → Sign In / Up** activa
   *"Allow anonymous sign-ins"*. El invitado usa la app con un usuario anónimo
   y, al registrarse desde Ajustes, su cuenta (y todos sus datos) se conserva.
5. Copia tu **Project URL** y **anon public key** (Settings → API).

### Datos de ejemplo (seed)

1. Regístrate en la app (crea el usuario y sus categorías por defecto).
2. En Supabase, **Authentication → Users**, copia tu `user_id`.
3. Edita [`supabase/seed.sql`](supabase/seed.sql) reemplazando el UUID de ejemplo.
4. Ejecútalo en el **SQL Editor**.

## Cómo correr el proyecto

Las llaves se cargan en **runtime desde un archivo `.env`** (vía `flutter_dotenv`),
así el botón Run/Debug del IDE funciona sin pasar argumentos. El `.env` está en
`.gitignore` (no se commitea); la `anon key` de Supabase es pública por diseño y la
protección real es RLS.

```bash
# 1. Copia la plantilla y completa tus valores de Supabase (Settings → API)
cp .env.example .env
#    Edita .env:
#      SUPABASE_URL=https://TU-PROYECTO.supabase.co
#      SUPABASE_ANON_KEY=TU_ANON_KEY

flutter pub get

# 2. Genera los archivos de freezed/json (*.freezed.dart, *.g.dart)
dart run build_runner build --delete-conflicting-outputs

# 3. Corre (o usa el botón Run/Debug del IDE — no requiere argumentos)
flutter run
```

Si falta el `.env` o está vacío, la app muestra una pantalla guía en lugar de fallar.

## Seguridad

- **RLS** en todas las tablas filtrando por `auth.uid() = user_id`.
- Autenticación obligatoria; el router redirige a login sin sesión.
- Bloqueo opcional por **PIN o biometría**; el PIN se guarda **hasheado** en
  `flutter_secure_storage` (nunca en texto plano).
- Validación de inputs (montos positivos, fechas, campos requeridos) y manejo de
  errores con mensajes que no exponen información sensible.

## Fuera de alcance (fases posteriores)

Metas de ahorro, proyección de flujo futuro, importación de movimientos bancarios,
notificaciones push y multi-moneda **no** están implementados. Donde aplica, el modelo
de datos los deja previstos (ver comentarios en `supabase/schema.sql`).

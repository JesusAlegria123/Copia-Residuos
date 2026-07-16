## 🔐 Autenticación Segura - Guía de Configuración

Este documento describe cómo configurar y usar el sistema de autenticación segura basado en Supabase, JWT y BCrypt.

---

## 📋 Tabla de Contenidos

1. [Requisitos Previos](#requisitos-previos)
2. [Configuración de Supabase](#configuración-de-supabase)
3. [Instalación de Dependencias](#instalación-de-dependencias)
4. [Uso de Servicios](#uso-de-servicios)
5. [Flujo de Autenticación](#flujo-de-autenticación)
6. [Seguridad](#seguridad)
7. [Troubleshooting](#troubleshooting)

---

## 🚀 Requisitos Previos

- Flutter 3.0+
- Cuenta de Supabase (gratuita en https://supabase.com)
- Acceso a las credenciales del proyecto

---

## ⚙️ Configuración de Supabase

### 1. Ejecutar Script SQL

1. Ve a tu proyecto en Supabase Dashboard
2. Abre SQL Editor
3. Copia y ejecuta el contenido de `database/schema.sql`
4. Esto creará las tablas necesarias: `users`, `refresh_tokens`, `login_audit`

### 2. Habilitar RLS (Row Level Security)

El script SQL ya incluye políticas RLS. Verifica que estén activas:

```
Supabase Dashboard → Authentication → Policies
```

---

## 📦 Instalación de Dependencias

```bash
# Instalar dependencias
flutter pub get

# Dependencias instaladas:
# - flutter_secure_storage: Almacenamiento seguro de tokens
# - dart_jsonwebtoken: Generación y validación de JWT
# - bcrypt: Hash seguro de contraseñas
# - crypto: Funciones criptográficas adicionales
```

---

## 🔧 Uso de Servicios

### 1. Inicializar en main.dart

```dart
import 'package:my_app_residuos/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase
  await SupabaseService.init();
  
  runApp(const UnsaacApp());
}
```

### 2. Registrar un usuario

```dart
import 'package:my_app_residuos/services/auth_service.dart';

try {
  final user = await AuthService().signup(
    email: 'usuario@example.com',
    password: 'SecurePass123!@#',
    nombre: 'Juan Pérez',
    rol: 'Usuario',
  );
  
  print('Usuario registrado: ${user.email}');
} catch (e) {
  print('Error: $e');
}
```

### 3. Iniciar sesión

```dart
try {
  final user = await AuthService().login(
    email: 'usuario@example.com',
    password: 'SecurePass123!@#',
  );
  
  print('Login exitoso: ${user.nombre}');
} catch (e) {
  print('Error de login: $e');
}
```

### 4. Obtener sesión activa

```dart
final authService = AuthService();
final sessionInfo = await authService.obtenerSesionActiva();

if (sessionInfo != null) {
  print('Usuario: ${sessionInfo.user.nombre}');
  print('Token expira en: ${sessionInfo.expiresAt}');
} else {
  print('No hay sesión activa');
}
```

### 5. Cerrar sesión

```dart
await AuthService().logout();
```

### 6. Refrescar token

```dart
try {
  final newSession = await AuthService().refreshAccessToken();
  print('Token refrescado');
} catch (e) {
  print('Error al refrescar: $e');
}
```

---

## 🔄 Flujo de Autenticación

```
1. Usuario ingresa email y contraseña
   ↓
2. ValidationService valida formato
   ↓
3. SupabaseService busca usuario en BD
   ↓
4. CryptoService verifica contraseña (BCrypt)
   ↓
5. CryptoService genera tokens JWT
   ↓
6. RefreshToken se guarda en BD (hasheado)
   ↓
7. Tokens se guardan en almacenamiento seguro (FlutterSecureStorage)
   ↓
✓ Sesión activa
```

---

## 🔒 Seguridad

### Hash de Contraseñas

- Algoritmo: **BCrypt** (10 rondas)
- Las contraseñas NUNCA se almacenan en texto plano
- Verificación segura sin comparación directa

### JWT Tokens

- **Access Token**: Válido 15 minutos
  - Contiene: id, email, rol, exp, iat
  - Usado para autenticación en cada solicitud
  
- **Refresh Token**: Válido 7 días
  - Solamente contiene: id, exp, iat
  - Guardado hasheado en BD para seguridad adicional
  - Puede ser revocado en cualquier momento

### Almacenamiento Seguro

- **Tokens**: Guardados en iOS Keychain y Android Keystore
- **Datos sensibles**: NUnca en SharedPreferences
- **Limpeza en logout**: Todos los datos se eliminan

### Row Level Security (RLS)

- Usuarios solo ven su propio perfil
- Admins pueden ver todos los perfiles
- Auditoría protegida a nivel de BD

---

## 🎯 Validación de Datos

### Email

```dart
ValidationService.validateEmail(email);
// Valida formato RFC 5322
```

### Contraseña

```dart
ValidationService.validatePassword(password);
// Requisitos:
// - Mínimo 8 caracteres
// - Al menos 1 mayúscula
// - Al menos 1 minúscula
// - Al menos 1 número
// - Al menos 1 carácter especial (!@#$%^&*)
```

### Nombre

```dart
ValidationService.validateName(nombre);
// - Mínimo 3 caracteres
// - Máximo 100 caracteres
// - Solo letras, espacios, acentos y guiones
```

---

## 🚨 Manejo de Errores

El sistema usa excepciones personalizadas:

```dart
try {
  await AuthService().login(email: email, password: password);
} on AuthException catch (e) {
  print('Error de autenticación: ${e.message}');
} on ValidationException catch (e) {
  print('Error de validación: ${e.message}');
} on NetworkException catch (e) {
  print('Error de red: ${e.message}');
} on AppException catch (e) {
  print('Error general: ${e.message}');
}
```

### Tipos de Excepciones

- **AuthException**: Errores de autenticación
- **ValidationException**: Errores de validación
- **NetworkException**: Errores de conexión
- **StorageException**: Errores de almacenamiento

---

## 🐛 Troubleshooting

### Error: "Invalid JWT"

**Causa**: Token expirado o corrupto
**Solución**: Limpia el almacenamiento y vuelve a iniciar sesión

```dart
await FlutterSecureStorage().deleteAll();
```

### Error: "User not found"

**Causa**: Usuario no existe en BD
**Solución**: Registra el usuario primero con `signup()`

### Error: "Weak password"

**Causa**: Contraseña no cumple requisitos
**Solución**: Usa contraseña con al menos: mayúscula, minúscula, número, símbolo

### Error: "Email already exists"

**Causa**: Email ya está registrado
**Solución**: Usa otro email o usa `login()` si ya tienes cuenta

### Error: "Connection timeout"

**Causa**: Sin conexión a internet o Supabase lento
**Solución**: Verifica conexión y reintentra

---

## 📊 Auditoría

Todos los intentos de login se registran en la tabla `login_audit`:

```sql
-- Ver intentos de login fallidos
SELECT * FROM login_audit 
WHERE success = false 
ORDER BY created_at DESC;

-- Ver últimas sesiones de un usuario
SELECT * FROM login_audit 
WHERE user_id = 'user-id' 
ORDER BY created_at DESC;
```

---

## 🔑 Protección de Credenciales

**NUNCA**:
- Guardes credenciales en código fuente
- Expongas la secret key en cliente
- Loguees contraseñas o tokens completos

**SIEMPRE**:
- Usa variables de entorno para secretos
- Verifica tokens en el servidor
- Revoca tokens en logout

---

## 📱 Próximos Pasos

1. **Integración con UI**: Actualiza LoginScreen con el nuevo AuthService
2. **Manejo de sesiones**: Implementa refresh automático de tokens
3. **Protección de rutas**: Crea middleware de autenticación
4. **2FA**: Agrega autenticación de dos factores
5. **OAuth**: Integra login con Google, Microsoft, etc.

---

## 📚 Referencias

- [Supabase Documentation](https://supabase.com/docs)
- [JWT.io](https://jwt.io)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [Flutter Security Best Practices](https://flutter.dev/docs/testing/security)


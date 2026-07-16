## 📮 Guía de Autenticación con Postman

**Sistema de Autenticación Segura - Endpoints y Ejemplos**

---

## 🔧 INSTALACIÓN DE POSTMAN

1. Descarga desde: https://www.postman.com/downloads/
2. Instala según tu SO (Windows, Mac, Linux)
3. Abre Postman y crea una cuenta (opcional)

---

## 📋 ENDPOINTS DISPONIBLES

### Base URL
```
http://localhost:8080/api/auth
```

O si está en producción:
```
https://tu-servidor.com/api/auth
```

---

## 🔐 ENDPOINTS DE AUTENTICACIÓN

### 1️⃣ LOGIN (POST)
**Endpoint**: `POST /api/auth/login`

**Descripción**: Autentica un usuario y retorna tokens JWT

#### Request (Body - JSON):
```json
{
  "email": "test@example.com",
  "password": "SecurePass123!@#"
}
```

#### Response (Success - 200):
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "test@example.com",
      "nombre": "Test User",
      "rol": "Usuario",
      "activo": true
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 900
  }
}
```

#### Response (Error - 401):
```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Credenciales inválidas. Por favor, verifica tu email y contraseña."
  }
}
```

#### En Postman:
1. Selecciona: **POST**
2. URL: `http://localhost:8080/api/auth/login`
3. Tab **Body** → **raw** → **JSON**
4. Copia el JSON anterior
5. Presiona **Send**

---

### 2️⃣ SIGNUP (POST)
**Endpoint**: `POST /api/auth/signup`

**Descripción**: Registra un nuevo usuario

#### Request (Body - JSON):
```json
{
  "email": "nuevo@example.com",
  "password": "SecurePass123!@#",
  "nombre": "Juan Pérez",
  "rol": "Usuario"
}
```

#### Response (Success - 201):
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "nuevo@example.com",
      "nombre": "Juan Pérez",
      "rol": "Usuario",
      "activo": true,
      "createdAt": "2026-06-20T10:30:00Z"
    }
  }
}
```

#### Response (Error - 400):
```json
{
  "success": false,
  "error": {
    "code": "EMAIL_EXISTS",
    "message": "Este email ya está registrado. Intenta iniciar sesión."
  }
}
```

#### En Postman:
1. Selecciona: **POST**
2. URL: `http://localhost:8080/api/auth/signup`
3. Tab **Body** → **raw** → **JSON**
4. Copia el JSON anterior
5. Presiona **Send**

---

### 3️⃣ REFRESH TOKEN (POST)
**Endpoint**: `POST /api/auth/refresh`

**Descripción**: Genera un nuevo access token usando el refresh token

#### Request (Header):
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Request (Body - JSON):
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### Response (Success - 200):
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 900
  }
}
```

#### En Postman:
1. Selecciona: **POST**
2. URL: `http://localhost:8080/api/auth/refresh`
3. Tab **Headers** → Agregar:
   - Key: `Authorization`
   - Value: `Bearer <tu_access_token>`
4. Tab **Body** → **raw** → **JSON**
5. Presiona **Send**

---

### 4️⃣ LOGOUT (POST)
**Endpoint**: `POST /api/auth/logout`

**Descripción**: Cierra sesión y revoca tokens

#### Request (Header):
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Response (Success - 200):
```json
{
  "success": true,
  "message": "Logout exitoso. Sesión cerrada."
}
```

#### En Postman:
1. Selecciona: **POST**
2. URL: `http://localhost:8080/api/auth/logout`
3. Tab **Headers** → Agregar:
   - Key: `Authorization`
   - Value: `Bearer <tu_access_token>`
4. Presiona **Send**

---

### 5️⃣ GET CURRENT USER (GET)
**Endpoint**: `GET /api/auth/me`

**Descripción**: Obtiene información del usuario autenticado

#### Request (Header):
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Response (Success - 200):
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "test@example.com",
    "nombre": "Test User",
    "rol": "Usuario",
    "activo": true,
    "createdAt": "2026-06-20T10:30:00Z",
    "ultimoLogin": "2026-06-20T15:45:30Z"
  }
}
```

#### En Postman:
1. Selecciona: **GET**
2. URL: `http://localhost:8080/api/auth/me`
3. Tab **Headers** → Agregar:
   - Key: `Authorization`
   - Value: `Bearer <tu_access_token>`
4. Presiona **Send**

---

## 🔄 FLUJO COMPLETO EN POSTMAN (PASO A PASO)

### Paso 1: LOGIN
1. Create new request: **POST** `/api/auth/login`
2. Body:
```json
{
  "email": "test@example.com",
  "password": "SecurePass123!@#"
}
```
3. Send
4. **Copia el `accessToken` de la respuesta**

### Paso 2: GUARDAR TOKEN EN VARIABLE
En Postman, puedes guardar el token en una variable:

1. Selecciona la respuesta del login
2. Testing tab (debajo de Body)
3. Agrega esto:
```javascript
var jsonData = pm.response.json();
pm.environment.set("accessToken", jsonData.data.accessToken);
pm.environment.set("refreshToken", jsonData.data.refreshToken);
```
4. Send

### Paso 3: USAR TOKEN EN OTROS REQUESTS
En cualquier request que necesite token:

1. Tab **Headers**
2. Key: `Authorization`
3. Value: `Bearer {{accessToken}}`
4. Postman automáticamente reemplazará `{{accessToken}}` con tu token guardado

### Paso 4: REFRESCAR TOKEN
Si el token expira (después de 15 minutos):

1. **POST** `/api/auth/refresh`
2. Body:
```json
{
  "refreshToken": "{{refreshToken}}"
}
```
3. Send
4. Postman actualizará automáticamente `{{accessToken}}`

---

## 📊 CÓDIGOS DE ERROR

### 400 - Bad Request
```json
{
  "success": false,
  "error": {
    "code": "INVALID_EMAIL",
    "message": "El formato del email no es válido."
  }
}
```

### 401 - Unauthorized
```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Credenciales inválidas."
  }
}
```

### 403 - Forbidden
```json
{
  "success": false,
  "error": {
    "code": "TOKEN_EXPIRED",
    "message": "Tu sesión ha expirado. Por favor, inicia sesión nuevamente."
  }
}
```

### 500 - Server Error
```json
{
  "success": false,
  "error": {
    "code": "SERVER_ERROR",
    "message": "Error en el servidor. Por favor, intenta de nuevo más tarde."
  }
}
```

---

## 🔐 HEADERS REQUERIDOS

### Para requests que requieren autenticación:
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

### Ejemplo en Postman:
```
Tab Headers:
┌─────────────────────────────────────────────────┐
│ Key              │ Value                        │
├──────────────────┼──────────────────────────────┤
│ Authorization    │ Bearer eyJhbGc...           │
│ Content-Type     │ application/json            │
└─────────────────────────────────────────────────┘
```

---

## 🧪 COLECCIÓN POSTMAN LISTA

Puedes importar una colección prepararada. Crea un archivo `postman_collection.json`:

```json
{
  "info": {
    "name": "Autenticación - App Residuos",
    "description": "Endpoints de autenticación segura",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Login",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"email\": \"test@example.com\",\n  \"password\": \"SecurePass123!@#\"\n}"
        },
        "url": {
          "raw": "http://localhost:8080/api/auth/login",
          "protocol": "http",
          "host": ["localhost"],
          "port": "8080",
          "path": ["api", "auth", "login"]
        }
      }
    },
    {
      "name": "Get Current User",
      "request": {
        "method": "GET",
        "header": [
          {
            "key": "Authorization",
            "value": "Bearer {{accessToken}}"
          }
        ],
        "url": {
          "raw": "http://localhost:8080/api/auth/me",
          "protocol": "http",
          "host": ["localhost"],
          "port": "8080",
          "path": ["api", "auth", "me"]
        }
      }
    }
  ],
  "variable": [
    {
      "key": "accessToken",
      "value": ""
    },
    {
      "key": "refreshToken",
      "value": ""
    }
  ]
}
```

### Para usar la colección:
1. Copia el JSON anterior
2. En Postman: **Import** → **Raw text**
3. Pega el JSON
4. Click **Import**

---

## 💡 TIPS PARA POSTMAN

### 1️⃣ Guardar Ambiente (Environment)
```
1. Click "Settings" (engranaje arriba)
2. New Environment
3. Nombra: "Desarrollo"
4. Agrega variables:
   - base_url: http://localhost:8080
   - accessToken: (vacío, se llena con login)
   - refreshToken: (vacío, se llena con login)
5. Save
```

### 2️⃣ Usar Variables en URLs
```
URL: {{base_url}}/api/auth/login
Se convierte en: http://localhost:8080/api/auth/login
```

### 3️⃣ Pre-request Scripts (Ejecutar antes de request)
```javascript
// Verificar si token está próximo a expirar
var tokenAge = pm.environment.get("tokenAge");
if (tokenAge > 14 * 60) { // 14 minutos
  // Ejecutar refresh token
}
```

### 4️⃣ Tests (Verificar responses)
```javascript
// Verificar que la respuesta sea exitosa
pm.test("Status code es 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Response contiene accessToken", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.data).to.have.property('accessToken');
});
```

---

## 🌐 ENDPOINTS ADICIONALES (SI TIENES BACKEND)

Si implementas un backend personalizado, estos serían endpoints recomendados:

```
POST   /api/auth/login           - Iniciar sesión
POST   /api/auth/signup          - Registrarse
POST   /api/auth/logout          - Cerrar sesión
POST   /api/auth/refresh         - Refrescar token
GET    /api/auth/me              - Obtener usuario actual
POST   /api/auth/change-password - Cambiar contraseña
POST   /api/auth/forgot-password - Recuperar contraseña
POST   /api/auth/verify-email    - Verificar email
POST   /api/auth/2fa-enable      - Habilitar 2FA
```

---

## 🚀 FLUJO TÍPICO DE AUTENTICACIÓN

```
┌─────────────────────────────────────────────┐
│ 1. Usuario ingresa credenciales             │
└───────────────┬─────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────┐
│ 2. POST /api/auth/login                     │
│    Body: { email, password }                │
└───────────────┬─────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────┐
│ 3. Respuesta: { accessToken, refreshToken }│
└───────────────┬─────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────┐
│ 4. Guardar tokens en variable Postman       │
│    {{accessToken}}, {{refreshToken}}        │
└───────────────┬─────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────┐
│ 5. Usar en Header: Authorization: Bearer... │
└───────────────┬─────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────┐
│ 6. Si token expira → POST /api/auth/refresh │
└───────────────┬─────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────┐
│ 7. Obtener nuevo token                      │
└─────────────────────────────────────────────┘
```

---

## 📝 NOTAS IMPORTANTES

### ⚠️ NO HAGAS
```
❌ NO guardes tokens en variables globales sin encriptación
❌ NO expongas tokens en URLs (sempre en Headers o Body)
❌ NO uses HTTP en producción (siempre HTTPS)
❌ NO compartas colecciones con tokens activos
```

### ✅ SÍ DEBERÍAS
```
✅ Usa HTTPS en producción
✅ Almacena tokens en almacenamiento seguro (cliente)
✅ Valida tokens en el servidor
✅ Refresca tokens antes de que expiren
✅ Mantén registros de intentos de login (auditoría)
```

---

## 🎯 PRÓXIMO PASO

Una vez que entiendas los endpoints:

1. **Implementa Backend** si aún no lo tienes
2. **Prueba en Postman** todos los endpoints
3. **Integra en Flutter** usando `http` package
4. **Maneja errores** según códigos de respuesta

---

**¿Necesitas ayuda con algo específico en Postman?** 📮🚀


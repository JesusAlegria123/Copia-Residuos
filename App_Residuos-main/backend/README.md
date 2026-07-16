# Backend de Autenticación - App Residuos UNSAAC

Backend en **Node.js + Express** con **Supabase** (Postgres) como base de datos, implementando exactamente los endpoints descritos en `POSTMAN_GUIDE.md` del proyecto Flutter: login, signup, refresh, logout y me — con hash BCrypt, JWT (access 15 min / refresh 7 días) y auditoría de login.

## 📁 Estructura

```
backend/
├── database/
│   └── schema.sql          ← Ejecutar en Supabase SQL Editor
├── src/
│   ├── config/              ← Variables de entorno y cliente Supabase
│   ├── controllers/         ← Lógica de los endpoints
│   ├── middleware/          ← Auth (JWT) y manejo de errores
│   ├── routes/               ← Definición de rutas Express
│   ├── services/             ← Crypto (bcrypt/JWT), validación, acceso a datos
│   ├── utils/                ← AppError, asyncHandler
│   ├── app.js                ← Configuración de Express
│   └── server.js             ← Punto de entrada
├── .env.example
├── .gitignore
└── package.json
```

## 🚀 Paso 1: Configurar Supabase

1. Entra a tu proyecto en https://supabase.com/dashboard
2. Ve a **SQL Editor** → pega todo el contenido de `database/schema.sql` → **Run**
3. Ve a **Settings → API** y copia:
   - **Project URL** → `SUPABASE_URL`
   - **service_role key** (⚠️ NO la `anon` key) → `SUPABASE_SERVICE_ROLE_KEY`

> La `service_role key` tiene permisos totales sobre la base de datos. Solo debe vivir en el backend (`.env`), **jamás** en la app Flutter ni en el repositorio.

## 🚀 Paso 2: Configurar variables de entorno

```bash
cd backend
cp .env.example .env
```

Edita `.env` y completa:
- `SUPABASE_URL` y `SUPABASE_SERVICE_ROLE_KEY` (paso anterior)
- `JWT_ACCESS_SECRET` y `JWT_REFRESH_SECRET`: genera dos secretos distintos y largos, por ejemplo:
  ```bash
  node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
  ```

## 🚀 Paso 3: Instalar y correr

```bash
npm install
npm run dev      # con nodemon (recarga automática)
# o
npm start        # producción
```

El servidor queda en `http://localhost:8080`. Verifica con:

```bash
curl http://localhost:8080/health
```

## 📮 Endpoints (coinciden con POSTMAN_GUIDE.md)

| Método | Ruta                  | Auth requerida | Descripción                        |
|--------|-----------------------|----------------|-------------------------------------|
| POST   | `/api/auth/signup`    | No             | Registra un nuevo usuario           |
| POST   | `/api/auth/login`     | No             | Login, retorna accessToken/refreshToken |
| POST   | `/api/auth/refresh`   | No (usa body)  | Genera nuevo accessToken            |
| POST   | `/api/auth/logout`    | Sí (Bearer)    | Revoca el/los refresh token(s)      |
| GET    | `/api/auth/me`        | Sí (Bearer)    | Devuelve el usuario autenticado     |

Los request/response de cada uno son idénticos a los ya documentados en `POSTMAN_GUIDE.md` (incluye body de `refresh` y `logout` con `refreshToken` en el JSON, no solo en el header).

## 📱 Conectar tu app Flutter

En tu `pubspec.yaml` ya tienes el paquete `http`. Ejemplo de llamada desde Dart:

```dart
final response = await http.post(
  Uri.parse('http://TU_SERVIDOR:8080/api/auth/login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'email': email, 'password': password}),
);
final data = jsonDecode(response.body);
if (data['success'] == true) {
  final accessToken = data['data']['accessToken'];
  final refreshToken = data['data']['refreshToken'];
  // guardarlos con flutter_secure_storage
}
```

## ☁️ Dónde desplegarlo

Cualquier hosting de Node sirve (Railway, Render, Fly.io, VPS propio). Solo asegúrate de configurar las mismas variables de entorno del `.env` en el panel del hosting, y usar HTTPS en producción.

---

## 🔼 Cómo subir esto a tu repositorio de GitHub

Tienes dos caminos. Elige el que prefieras:

### Opción A: agregarlo como carpeta `backend/` dentro de tu repo actual (recomendado)

```bash
# 1. Clona tu repo si no lo tienes localmente
git clone https://github.com/JesusAlegria123/Copia-Residuos.git
cd Copia-Residuos

# 2. Copia la carpeta "backend" que te entregué dentro de la raíz del repo
#    (arrástrala con el explorador de archivos, o con cp/xcopy)

# 3. Verifica que .env NO aparezca (debe estar ignorado por .gitignore)
git status

# 4. Agrega, commitea y sube
git add backend/
git commit -m "feat: agregar backend de autenticación (Node.js + Express + Supabase)"
git push origin main
```

### Opción B: repositorio separado solo para el backend

```bash
cd backend
git init
git add .
git commit -m "feat: backend inicial de autenticacion"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/NOMBRE_NUEVO_REPO.git
git push -u origin main
```

### ⚠️ Antes de cualquier push, verifica:

```bash
cat .gitignore   # debe incluir "node_modules/" y ".env"
git status       # NO debe aparecer node_modules ni .env en los cambios a subir
```

Si por error ya agregaste `.env` o `node_modules` antes de tener el `.gitignore`, corre:

```bash
git rm -r --cached node_modules .env
git commit -m "chore: dejar de trackear archivos sensibles/generados"
```

### Configura los secretos en GitHub (opcional, para CI/CD)

Si luego automatizas el despliegue, ve a tu repo → **Settings → Secrets and variables → Actions** y agrega ahí `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `JWT_ACCESS_SECRET`, `JWT_REFRESH_SECRET` — nunca los subas en texto plano al código.

---

## ✅ Ya probado

Este backend fue levantado y probado localmente antes de la entrega:
- `GET /health` responde `200 OK`
- `POST /api/auth/login` con email inválido responde `400 INVALID_EMAIL`
- Validaciones de contraseña débil, email duplicado, y tokens expirados/ inválidos están cubiertas por `AppError` con los mismos códigos que ya definiste en `POSTMAN_GUIDE.md`.

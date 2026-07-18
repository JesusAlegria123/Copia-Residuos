# Backend — App Residuos UNSAAC

Backend en **Node.js (ES Modules) + Express + Supabase**. Este documento refleja el estado real del backend después de agregar:

1. Endpoints faltantes de gestión de usuarios (editar, además de activar/desactivar que ya existían)
2. Trazabilidad en `PATCH /api/reportes/:id/estado` (quién resolvió, validación de transición de estados)
3. Endpoints de estadísticas (usuarios, rutas, residuos)
4. Endpoints de monitoreo de unidades (camiones) y su ubicación GPS en tiempo real
5. Endpoint de registro de recolecciones (necesario para que las estadísticas de residuos tengan datos reales)

> ⚠️ El README anterior de esta carpeta estaba desactualizado (documentaba rutas `/api/users` que ya no existen). Este lo reemplaza por completo.

## 🚀 Instalación

```bash
cd backend
npm install
cp .env.example .env   # completa tus credenciales de Supabase y JWT_SECRET
npm run dev             # http://localhost:8080
```

## 🗄️ Base de datos

Ejecuta en el **SQL Editor de Supabase**, en este orden (todas usan `IF NOT EXISTS`, son seguras de re-ejecutar):

1. `database/schema.sql` (si aún no lo habías corrido)
2. `database/migration_reportes.sql` (si aún no lo habías corrido)
3. **`database/migration_operaciones.sql`** ← nueva, agrega:
   - `unidades_recoleccion` (camiones)
   - `ubicaciones_unidad` (historial GPS)
   - `recolecciones` (registro de residuos por tipo/peso, para estadísticas)
   - columnas `updated_at` y `resuelto_por` en `reportes_malos_trabajos`

## 📮 Endpoints completos

Todas las respuestas siguen el formato `{ success, data }` o `{ success: false, error: { code, message } }`.

### Autenticación (`/api/auth`) — ya existía
| Método | Ruta | Auth |
|---|---|---|
| POST | `/signup` | No |
| POST | `/login` | No |
| POST | `/refresh` | No |
| POST | `/logout` | Sí |
| GET | `/me` | Sí |

### Gestión de usuarios (`/api/usuarios`, `/api/users`)
| Método | Ruta | Auth | Estado |
|---|---|---|---|
| GET | `/usuarios` | Admin | Ya existía |
| GET | `/usuarios/:id` | Admin | Ya existía |
| **PATCH** | **`/usuarios/:id`** | Admin | 🆕 **Editar** (nombre, apellido, telefono, direccion, latitud, longitud, id_rol, id_zona) |
| PATCH | `/usuarios/:id/disable` | Admin | Ya existía |
| PATCH | `/usuarios/:id/enable` | Admin | Ya existía |
| GET | `/users` | Admin | Ya existía (cuentas de autenticación) |
| **PATCH** | **`/users/:id`** | Admin | 🆕 **Editar** (nombre, rol) |
| PATCH | `/users/:id/status` | Admin | Ya existía (activar/desactivar cuenta) |

Ejemplo — editar un usuario:
```bash
curl -X PATCH http://localhost:8080/api/usuarios/1 \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"nombre":"Brandon","telefono":"999888777","id_zona":2}'
```

### Reportes ciudadanos (`/api/reportes`)
| Método | Ruta | Auth | Estado |
|---|---|---|---|
| GET | `/distritos` | No | Ya existía |
| GET | `/` | No | Ya existía |
| GET | `/:id` | No | Ya existía |
| POST | `/` | Opcional | Ya existía |
| **PATCH** | **`/:id/estado`** | Admin | ✅ Reforzado: ahora valida transición (no se puede volver de "Resuelto"/"Rechazado" a "Pendiente"), y guarda `resuelto_por` con el id del admin que lo resolvió/rechazó |

```bash
curl -X PATCH http://localhost:8080/api/reportes/5/estado \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"estado":"Resuelto"}'
```

### 🆕 Estadísticas (`/api/estadisticas`) — todas Admin
| Método | Ruta | Descripción |
|---|---|---|
| GET | `/usuarios` | Total, activos/inactivos, por rol, por zona, registros por mes (últimos 6 meses) — incluye tanto la tabla `usuarios` como las cuentas `users` |
| GET | `/rutas` | Total, activas/inactivas, por zona, promedio de puntos por ruta, detalle por ruta (unidades asignadas, kg recolectados) |
| GET | `/residuos` | Kg totales, por tipo de residuo, por mes (últimos 7 meses), y estadísticas de reportes ciudadanos (por estado/distrito). Acepta `?desde=&hasta=` (fechas ISO) |

```bash
curl "http://localhost:8080/api/estadisticas/residuos?desde=2026-01-01" -H "Authorization: Bearer $TOKEN"
```

### 🆕 Unidades / Monitoreo (`/api/unidades`)
| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| GET | `/` | Sí | Lista unidades con su última ubicación conocida |
| GET | `/:id` | Sí | Detalle de una unidad |
| POST | `/` | Admin | Crear unidad (`codigo`, `nombre`, `placa`, `capacidadKg`, `colorHex`, `idRuta`) |
| PATCH | `/:id` | Admin | Editar unidad |
| PATCH | `/:id/estado` | Admin | Activar/desactivar unidad (`{ "estado": true|false }`) |
| **POST** | **`/:id/ubicacion`** | Sí | El dispositivo del camión reporta su posición GPS (`latitud`, `longitud`, `velocidadKmh`, `rumbo`) |
| GET | `/:id/ubicacion` | Sí | Última posición conocida |
| GET | `/:id/historial` | Sí | Historial de recorrido. Query: `?desde=&hasta=&limit=` |

```bash
# El camión reporta su posición cada X segundos
curl -X POST http://localhost:8080/api/unidades/1/ubicacion \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"latitud":-13.5255,"longitud":-71.9720,"velocidadKmh":22,"rumbo":180}'

# La app consulta la posición en vivo
curl http://localhost:8080/api/unidades/1/ubicacion -H "Authorization: Bearer $TOKEN"
```

> **Nota de diseño:** el reporte de ubicación (`POST /:id/ubicacion`) solo exige estar autenticado (no exige rol Admin), porque en la práctica lo llamará el dispositivo del recolector/chofer. Como el sistema todavía no tiene un rol "Recolector" en la tabla `users` (solo `Administrador`/`Usuario`), no se puede restringir más sin antes decidir cómo se identificará a los choferes. Si más adelante agregan ese rol, solo hay que añadir `requireRecolector` en `unidad.routes.js`.

### 🆕 Recolecciones (`/api/recolecciones`)
Registra cuánto residuo (por tipo) recogió una unidad — alimenta `/api/estadisticas/residuos` y `/api/estadisticas/rutas`.

| Método | Ruta | Auth |
|---|---|---|
| POST | `/` | Sí |
| GET | `/` | Admin |

```bash
curl -X POST http://localhost:8080/api/recolecciones \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"idUnidad":1,"idRuta":2,"tipoResiduo":"Organicos","pesoKg":85.5}'
```

Tipos válidos: `Organicos`, `Plasticos`, `Papel y Carton`, `Metales`, `Vidrio`, `Otros`.

## ✅ Ya probado

Antes de la entrega se levantó el servidor localmente y se verificó:
- Los 30 archivos `.js` del backend compilan sin errores de sintaxis (`node --check`)
- Todas las rutas nuevas devuelven `401` sin token (protección de `authenticate` funcionando)
- Las validaciones de negocio devuelven el código HTTP correcto (`400`, `404`) en vez de caer siempre en `500` — se corrigió además el `errorHandler` general para que cualquier error de negocio con su propio `statusCode` se respete, y no solo los que estaban en una lista blanca (esto beneficia también a los endpoints que ya existían, como `PATCH /reportes/:id/estado`)
- Sin conexión real a Supabase, las llamadas que sí llegan a la base de datos devuelven `500` (esperado — es un dominio de prueba, no tu Supabase real)

## 🔼 Cómo integrarlo a tu repo

Tu repo ya tiene una carpeta `backend/` en la raíz — estos son solo los archivos nuevos/modificados dentro de ella, más `database/migration_operaciones.sql` en la raíz del repo. Pasos:

```bash
cd Copia-Residuos          # tu repo ya clonado
git checkout main
git pull origin main        # asegúrate de tener lo último

# copia el contenido del zip que te entregué, reemplazando
# los archivos existentes en backend/ y agregando database/migration_operaciones.sql

git status                  # revisa qué cambió antes de subir
git add backend database/migration_operaciones.sql
git commit -m "feat: gestion de usuarios (editar), trazabilidad en reportes, estadisticas y monitoreo de unidades"
git push origin main
```

⚠️ Antes de correr `git add`, verifica que no aparezca `backend/.env` ni `backend/node_modules` en `git status` (deben estar en `.gitignore`).

### Nota sobre `App_Residuos-main/`

Noté que tu repo tiene una carpeta `App_Residuos-main/backend/` que es una copia del backend que te entregué en la primera vuelta (con `AppError.js`, `asyncHandler.js`, etc. — esos nombres no existen en el backend "real" que evolucionó en `backend/`). Esa carpeta ya no se usa; te recomiendo borrarla para evitar confusión:

```bash
git rm -r App_Residuos-main
git commit -m "chore: eliminar copia antigua del backend"
```

### Nota sobre `backend/index.js`

También hay un `backend/index.js` (en la raíz de `backend/`, no en `backend/src/`) que es una versión antigua en CommonJS (`require`) con solo 2 endpoints (`/api/users`, `/api/users/disable`) — no se usa: `package.json` apunta a `src/index.js`. Es seguro borrarlo:

```bash
git rm backend/index.js
git commit -m "chore: eliminar index.js legado (reemplazado por src/index.js)"
```


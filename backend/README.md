# Backend para gestión de usuarios (Supabase)

Endpoints:

1) GET /api/users
- Query params:
  - start_date (ISO) - optional
  - end_date (ISO) - optional
  - role (id or name) - optional
  - search - optional (busca en nombre, apellido, correo)
  - page - default 1
  - limit - default 50
  - sort_by - default fecha_registro
  - sort_order - asc|desc

Response:
```
{
  "usuarios": [ ... ],
  "meta": { "page": 1, "limit": 50, "total": 0 }
}
```

2) POST /api/users/disable
- Body: `{ "id_usuario": 1 }`
- Action: actualiza `estado` a `false` y retorna la fila actualizada.

Setup:

1. Instalar dependencias

```powershell
cd backend
npm install
```

2. Configurar `.env` (ya incluido de ejemplo)

3. Ejecutar

```powershell
npm start
```

Pruebas rápidas (ejemplos):

- Listar usuarios:

```bash
curl "http://localhost:3000/api/users?page=1&limit=10"
```

- Deshabilitar usuario (id 1):

```bash
curl -X POST -H "Content-Type: application/json" -d '{"id_usuario":1}' http://localhost:3000/api/users/disable
```

Notas:
- Este backend usa la `SUPABASE_SERVICE_KEY` del archivo `.env` para ejecutar acciones privilegiadas.
- No expongas la `service_role` en el cliente.


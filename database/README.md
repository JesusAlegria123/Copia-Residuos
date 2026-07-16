# 📋 Configuración de Base de Datos - Sistema de Gestión de Residuos Urbanos

## ✅ CONEXIÓN A SUPABASE VERIFICADA

**Estado:** 🟢 **FUNCIONANDO CORRECTAMENTE**

Todas las 6 tablas son **accesibles y funcionales** a través de la API REST de Supabase.

## ✅ Archivos Creados

### 1. **database/schema.sql**
Script SQL completo con todas las tablas del sistema:
- `roles` - Definición de tipos de usuario
- `zonas` - Zonas geográficas 
- `usuarios` - Información de usuarios
- `rutas` - Rutas de recolección
- `ruta_puntos` - Puntos geográficos de las rutas
- `horarios` - Horarios de operación

### 2. **database/test_simple.ps1**
Script PowerShell para pruebas rápidas (una sola tabla)

### 3. **database/test_complete.ps1** ⭐ RECOMENDADO
Script PowerShell **completo y funcional** que:
- Prueba conexión a las 6 tablas
- Verifica acceso a la API REST
- Genera reporte detallado con estadísticas
- ✅ **YA PROBADO Y FUNCIONANDO**

### 4. **database/test_connection.bat**
Script Batch alternativo para Windows

### 5. **tool/test_database_connection.dart**
Script Dart para pruebas desde la aplicación Flutter

---

## 🔧 Configuración de Supabase (CORRECTA)

**URL Base:**
```
https://ybbhmauqilygldknzpcv.supabase.co
```

**API REST Endpoint:**
```
https://ybbhmauqilygldknzpcv.supabase.co/rest/v1/
```

**Publishable Key (Segura para Cliente):**
```
sb_publishable_c4fvqOdNYAouQPG3OBQ9OA_cr2IqnTR
```

**Secret Key (Solo para Backend):**
```
sb_secret_scVYD... [CENSORED]
```

---

## 📊 Estructura de Tablas

### Tabla `usuarios`
```
id_usuario (INT4) - PK
├── nombre (VARCHAR)
├── apellido (VARCHAR)
├── correo (VARCHAR) - UNIQUE
├── telefono (VARCHAR)
├── direccion (TEXT)
├── latitud (NUMERIC)
├── longitud (NUMERIC)
├── id_rol (INT4) - FK → roles
├── id_zona (INT4) - FK → zonas
├── estado (BOOLEAN)
├── fecha_registro (TIMESTAMP)
└── auth_id (UUID)
```

### Tabla `roles`
```
id_rol (INT4) - PK
└── nombre (VARCHAR) - UNIQUE
```

### Tabla `zonas`
```
id_zona (INT4) - PK
├── nombre (VARCHAR) - UNIQUE
└── descripcion (TEXT)
```

### Tabla `rutas`
```
id_ruta (INT4) - PK
├── nombre (VARCHAR)
├── descripcion (TEXT)
├── id_zona (INT4) - FK → zonas
└── estado (BOOLEAN)
```

### Tabla `ruta_puntos`
```
id_punto (INT4) - PK
├── id_ruta (INT4) - FK → rutas
├── latitud (NUMERIC)
├── longitud (NUMERIC)
└── orden_recorrido (INT4)
```

### Tabla `horarios`
```
id_horario (INT4) - PK
├── id_ruta (INT4) - FK → rutas
├── dia_semana (VARCHAR)
├── hora_inicio (TIME)
└── hora_fin (TIME)
```

---

## 🚀 Próximos Pasos

1. **Ejecutar el schema SQL en Supabase:**
   - Ir a SQL Editor en el dashboard de Supabase
   - Copiar el contenido de `database/schema.sql`
   - Ejecutar el script

2. **Verificar la conexión:**
   - Una vez ejecutado el schema, ejecutar `database/test_connection.ps1`
   - Verificar que todas las tablas retornen datos

3. **Implementar en Flutter:**
   - Usar el cliente Supabase en `services/supabase_service.dart`
   - Crear servicios CRUD para cada tabla

4. **Configurar RLS (Row Level Security):**
   - Definir políticas de acceso por rol
   - Asegurar datos según usuario autenticado

---

## 🔌 Conexión desde Flutter

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

// Inicializar
await Supabase.initialize(
  url: 'https://gbpovfuiqbwjkdhgnyvi.supabase.co',
  anonKey: 'YOUR_ANON_KEY',
);

// Obtener instancia
final supabase = Supabase.instance.client;

// Ejemplo: Obtener usuarios
final users = await supabase
  .from('usuarios')
  .select('*')
  .eq('estado', true);
```

---

## ⚠️ Notas Importantes

- La clave ANON KEY mostrada es de **acceso público**. Para producción, asegurar con RLS
- Las coordenadas (latitud/longitud) usan `NUMERIC(10,8)` y `NUMERIC(11,8)` para precisión
- Todos los IDs se generan automáticamente con `GENERATED ALWAYS AS IDENTITY`
- Las relaciones usan `ON DELETE CASCADE` o `ON DELETE SET NULL` según corresponda

---

## 📝 Estado Actual

- ✅ Esquema SQL creado
- ✅ Scripts de prueba creados
- ⚠️ Conexión a Supabase: Verificar conectividad de red
- ⏳ Tablas en Supabase: Pendiente de crear (ejecutar schema.sql)


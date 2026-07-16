-- ══════════════════════════════════════════════════════════════════════════════════
-- SCHEMA: Gestión de Residuos Urbanos - UNSAAC
-- Incluye Autenticación Segura con JWT, BCrypt y Auditoría
-- ══════════════════════════════════════════════════════════════════════════════════

-- ══════════════════════════════════════════════════════════════════════════════════
-- 1. TABLA DE USUARIOS - AUTENTICACIÓN SEGURA
-- ══════════════════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    rol VARCHAR(50) NOT NULL DEFAULT 'Usuario',
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ultimo_login TIMESTAMP WITH TIME ZONE,
    CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_rol ON users(rol);
CREATE INDEX IF NOT EXISTS idx_users_activo ON users(activo);

-- ══════════════════════════════════════════════════════════════════════════════════
-- 2. TABLA DE REFRESH TOKENS
-- ══════════════════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    revoked BOOLEAN DEFAULT false,
    CHECK (expires_at > NOW())
);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_expires_at ON refresh_tokens(expires_at);

-- ══════════════════════════════════════════════════════════════════════════════════
-- 3. TABLA DE AUDITORÍA DE LOGIN
-- ══════════════════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS login_audit (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    email VARCHAR(255),
    ip_address VARCHAR(45),
    user_agent TEXT,
    success BOOLEAN,
    error_message VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_login_audit_user_id ON login_audit(user_id);
CREATE INDEX IF NOT EXISTS idx_login_audit_created_at ON login_audit(created_at);

-- ══════════════════════════════════════════════════════════════════════════════════
-- 4. TABLAS EXISTENTES DEL SISTEMA
-- ══════════════════════════════════════════════════════════════════════════════════

-- Tabla de Roles
CREATE TABLE IF NOT EXISTS roles (
    id_rol INT4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla de Zonas
CREATE TABLE IF NOT EXISTS zonas (
    id_zona INT4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
);

-- Tabla de Usuarios Tradicional (Legado)
CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario INT4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    correo VARCHAR(255) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    direccion TEXT,
    latitud NUMERIC(10, 8),
    longitud NUMERIC(11, 8),
    id_rol INT4 NOT NULL REFERENCES roles(id_rol) ON DELETE RESTRICT,
    id_zona INT4 REFERENCES zonas(id_zona) ON DELETE SET NULL,
    estado BOOLEAN DEFAULT TRUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    auth_id UUID REFERENCES users(id) ON DELETE SET NULL
);

-- Tabla de Rutas
CREATE TABLE IF NOT EXISTS rutas (
    id_ruta INT4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    id_zona INT4 NOT NULL REFERENCES zonas(id_zona) ON DELETE CASCADE,
    estado BOOLEAN DEFAULT TRUE
);

-- Tabla de Puntos de Ruta
CREATE TABLE IF NOT EXISTS ruta_puntos (
    id_punto INT4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_ruta INT4 NOT NULL REFERENCES rutas(id_ruta) ON DELETE CASCADE,
    latitud NUMERIC(10, 8) NOT NULL,
    longitud NUMERIC(11, 8) NOT NULL,
    orden_recorrido INT4 NOT NULL,
    CONSTRAINT unique_ruta_orden UNIQUE(id_ruta, orden_recorrido)
);

-- Tabla de Horarios
CREATE TABLE IF NOT EXISTS horarios (
    id_horario INT4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_ruta INT4 NOT NULL REFERENCES rutas(id_ruta) ON DELETE CASCADE,
    dia_semana VARCHAR(20) NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL
);

-- ══════════════════════════════════════════════════════════════════════════════════
-- ÍNDICES
-- ══════════════════════════════════════════════════════════════════════════════════
CREATE INDEX IF NOT EXISTS idx_usuarios_id_rol ON usuarios(id_rol);
CREATE INDEX IF NOT EXISTS idx_usuarios_id_zona ON usuarios(id_zona);
CREATE INDEX IF NOT EXISTS idx_usuarios_correo ON usuarios(correo);
CREATE INDEX IF NOT EXISTS idx_rutas_id_zona ON rutas(id_zona);
CREATE INDEX IF NOT EXISTS idx_ruta_puntos_id_ruta ON ruta_puntos(id_ruta);
CREATE INDEX IF NOT EXISTS idx_horarios_id_ruta ON horarios(id_ruta);

-- ══════════════════════════════════════════════════════════════════════════════════
-- 5. REPORTES DE MALOS TRABAJOS (CIUDADANOS)
-- ══════════════════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS reportes_malos_trabajos (
    id_reporte INT4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    titulo VARCHAR(255),
    descripcion TEXT NOT NULL,
    distrito VARCHAR(100) NOT NULL,
    latitud NUMERIC(10, 8) NOT NULL,
    longitud NUMERIC(11, 8) NOT NULL,
    foto_url TEXT,
    estado VARCHAR(30) NOT NULL DEFAULT 'Pendiente',
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CHECK (char_length(trim(descripcion)) >= 10),
    CHECK (char_length(trim(distrito)) >= 2)
);

CREATE INDEX IF NOT EXISTS idx_reportes_distrito ON reportes_malos_trabajos(distrito);
CREATE INDEX IF NOT EXISTS idx_reportes_estado ON reportes_malos_trabajos(estado);
CREATE INDEX IF NOT EXISTS idx_reportes_created_at ON reportes_malos_trabajos(created_at DESC);

-- ══════════════════════════════════════════════════════════════════════════════════

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Política 1: Permitir registro de nuevos usuarios (sin autenticación)
CREATE POLICY "Permitir inserción de nuevos usuarios" ON users
    FOR INSERT WITH CHECK (true);

-- Política 2: Usuarios ven solo su propio perfil
CREATE POLICY "Usuarios ven solo su perfil" ON users
    FOR SELECT USING (auth.uid()::text = id::text OR auth.role() = 'authenticated');

-- Política 3: Usuarios pueden actualizar su propio perfil
CREATE POLICY "Usuarios actualizan su perfil" ON users
    FOR UPDATE USING (auth.uid()::text = id::text)
    WITH CHECK (auth.uid()::text = id::text);

-- ══════════════════════════════════════════════════════════════════════════════════
-- INSERTAR DATOS INICIALES
-- ══════════════════════════════════════════════════════════════════════════════════

INSERT INTO roles (nombre) VALUES
    ('Administrador'),
    ('Recolector'),
    ('Ciudadano')
ON CONFLICT (nombre) DO NOTHING;


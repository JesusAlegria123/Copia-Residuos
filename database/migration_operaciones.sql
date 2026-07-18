-- ══════════════════════════════════════════════════════════════════════════════════
-- MIGRACIÓN: Monitoreo de unidades, ubicación GPS, registro de recolecciones
-- y trazabilidad de reportes.
-- Ejecutar en Supabase Dashboard -> SQL Editor -> Run
-- (usa IF NOT EXISTS / ADD COLUMN IF NOT EXISTS, es seguro re-ejecutarla)
-- ══════════════════════════════════════════════════════════════════════════════════

-- ══════════════════════════════════════════════════════════════════════════════════
-- 1. UNIDADES DE RECOLECCIÓN (camiones)
-- ══════════════════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS unidades_recoleccion (
    id_unidad INT4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    placa VARCHAR(20),
    capacidad_kg NUMERIC(10, 2),
    color_hex VARCHAR(9) DEFAULT '#9333EA',
    id_ruta INT4 REFERENCES rutas(id_ruta) ON DELETE SET NULL,
    estado BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_unidades_id_ruta ON unidades_recoleccion(id_ruta);
CREATE INDEX IF NOT EXISTS idx_unidades_estado ON unidades_recoleccion(estado);

-- ══════════════════════════════════════════════════════════════════════════════════
-- 2. UBICACIONES DE UNIDAD (historial GPS en tiempo real)
-- ══════════════════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS ubicaciones_unidad (
    id_ubicacion BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_unidad INT4 NOT NULL REFERENCES unidades_recoleccion(id_unidad) ON DELETE CASCADE,
    latitud NUMERIC(10, 8) NOT NULL,
    longitud NUMERIC(11, 8) NOT NULL,
    velocidad_kmh NUMERIC(6, 2),
    rumbo NUMERIC(6, 2),
    fuente VARCHAR(20) NOT NULL DEFAULT 'gps',
    registrado_en TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CHECK (latitud BETWEEN -90 AND 90),
    CHECK (longitud BETWEEN -180 AND 180)
);

CREATE INDEX IF NOT EXISTS idx_ubicaciones_id_unidad ON ubicaciones_unidad(id_unidad);
CREATE INDEX IF NOT EXISTS idx_ubicaciones_registrado_en ON ubicaciones_unidad(id_unidad, registrado_en DESC);

-- ══════════════════════════════════════════════════════════════════════════════════
-- 3. RECOLECCIONES (registro de residuos recogidos, para estadísticas)
-- ══════════════════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS recolecciones (
    id_recoleccion INT4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_unidad INT4 REFERENCES unidades_recoleccion(id_unidad) ON DELETE SET NULL,
    id_ruta INT4 REFERENCES rutas(id_ruta) ON DELETE SET NULL,
    tipo_residuo VARCHAR(30) NOT NULL,
    peso_kg NUMERIC(10, 2) NOT NULL CHECK (peso_kg > 0),
    registrado_por UUID REFERENCES users(id) ON DELETE SET NULL,
    fecha TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CHECK (tipo_residuo IN ('Organicos', 'Plasticos', 'Papel y Carton', 'Metales', 'Vidrio', 'Otros'))
);

CREATE INDEX IF NOT EXISTS idx_recolecciones_fecha ON recolecciones(fecha DESC);
CREATE INDEX IF NOT EXISTS idx_recolecciones_tipo ON recolecciones(tipo_residuo);
CREATE INDEX IF NOT EXISTS idx_recolecciones_id_ruta ON recolecciones(id_ruta);

-- ══════════════════════════════════════════════════════════════════════════════════
-- 4. TRAZABILIDAD EN REPORTES (quién y cuándo cambió el estado)
-- ══════════════════════════════════════════════════════════════════════════════════
ALTER TABLE reportes_malos_trabajos
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

ALTER TABLE reportes_malos_trabajos
    ADD COLUMN IF NOT EXISTS resuelto_por UUID REFERENCES users(id) ON DELETE SET NULL;

CREATE OR REPLACE FUNCTION set_updated_at_reportes()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_reportes_updated_at ON reportes_malos_trabajos;
CREATE TRIGGER trg_reportes_updated_at
    BEFORE UPDATE ON reportes_malos_trabajos
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at_reportes();

-- ══════════════════════════════════════════════════════════════════════════════════
-- 5. DATOS INICIALES DE EJEMPLO (opcional, cómodo para probar en Postman)
-- ══════════════════════════════════════════════════════════════════════════════════
INSERT INTO unidades_recoleccion (codigo, nombre, placa, capacidad_kg, color_hex, estado)
VALUES
    ('UNIDAD-1', 'Unidad 1', 'CUS-101', 5000, '#9333EA', TRUE),
    ('UNIDAD-2', 'Unidad 2', 'CUS-102', 5000, '#0EA5E9', TRUE),
    ('UNIDAD-3', 'Unidad 3', 'CUS-103', 4000, '#10B981', TRUE)
ON CONFLICT (codigo) DO NOTHING;

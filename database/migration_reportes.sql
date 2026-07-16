-- Migración: tabla de reportes de malos trabajos
-- Ejecutar en Supabase SQL Editor si ya tienes el schema base aplicado

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

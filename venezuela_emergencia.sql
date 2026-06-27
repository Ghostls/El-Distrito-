-- ═══════════════════════════════════════════════════════════════
-- EL DISTRITO — VENEZUELA EMERGENCIA
-- SQL para Supabase · Valkyron Group 2026
-- ═══════════════════════════════════════════════════════════════

-- ──────────────────────────────────────────
-- 1. DESAPARECIDOS
-- ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS desaparecidos (
  id            BIGSERIAL PRIMARY KEY,
  nombre        TEXT NOT NULL,
  edad          INT,
  lugar         TEXT NOT NULL,
  estado        TEXT,
  telefono      TEXT NOT NULL,
  descripcion   TEXT,
  notas         TEXT,
  lat           DOUBLE PRECISION,
  lng           DOUBLE PRECISION,
  status        TEXT DEFAULT 'buscado' CHECK (status IN ('buscado','encontrado')),
  reportado_por TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ──────────────────────────────────────────
-- 2. DAÑOS ESTRUCTURALES
-- ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS daños_estructurales (
  id            BIGSERIAL PRIMARY KEY,
  ubicacion     TEXT NOT NULL,
  estado        TEXT,
  nivel         TEXT CHECK (nivel IN ('leve','moderado','grave','total')),
  tipo          TEXT,
  descripcion   TEXT,
  atrapados     TEXT DEFAULT 'no' CHECK (atrapados IN ('si','no','desconocido')),
  telefono      TEXT,
  lat           DOUBLE PRECISION,
  lng           DOUBLE PRECISION,
  verificado    BOOLEAN DEFAULT FALSE,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ──────────────────────────────────────────
-- 3. CENTROS DE ACOPIO
-- ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS centros_acopio (
  id            BIGSERIAL PRIMARY KEY,
  nombre        TEXT NOT NULL,
  direccion     TEXT NOT NULL,
  estado        TEXT,
  status        TEXT DEFAULT 'activo' CHECK (status IN ('activo','lleno','bloqueado')),
  necesidades   TEXT[],
  contacto      TEXT,
  lat           DOUBLE PRECISION,
  lng           DOUBLE PRECISION,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ──────────────────────────────────────────
-- 4. RLS — Row Level Security
-- Lectura pública, escritura pública (emergencia)
-- ──────────────────────────────────────────
ALTER TABLE desaparecidos       ENABLE ROW LEVEL SECURITY;
ALTER TABLE daños_estructurales ENABLE ROW LEVEL SECURITY;
ALTER TABLE centros_acopio      ENABLE ROW LEVEL SECURITY;

-- Lectura para todos (anon)
CREATE POLICY "lectura_publica_desap"   ON desaparecidos       FOR SELECT USING (true);
CREATE POLICY "lectura_publica_daños"   ON daños_estructurales FOR SELECT USING (true);
CREATE POLICY "lectura_publica_acopio"  ON centros_acopio      FOR SELECT USING (true);

-- Escritura para todos en emergencia (anon puede insertar)
CREATE POLICY "insertar_desap"   ON desaparecidos       FOR INSERT WITH CHECK (true);
CREATE POLICY "insertar_daños"   ON daños_estructurales FOR INSERT WITH CHECK (true);
CREATE POLICY "insertar_acopio"  ON centros_acopio      FOR INSERT WITH CHECK (true);

-- Solo update de status en desaparecidos (para "marcar encontrado")
CREATE POLICY "update_status_desap" ON desaparecidos FOR UPDATE USING (true) WITH CHECK (true);

-- ──────────────────────────────────────────
-- 5. DATOS SEMILLA (seed)
-- ──────────────────────────────────────────
INSERT INTO desaparecidos (nombre, edad, lugar, estado, telefono, descripcion, notas, lat, lng, status) VALUES
('María González',    42, 'Catia La Mar, La Guaira',    'La Guaira (Vargas)', '+58 412-555-0001', 'Cabello corto negro, ropa azul',   'Trabajaba en Residencias Las Palmas', 10.600, -67.020, 'buscado'),
('Carlos Martínez',   28, 'Urb. La Zorra, Caracas',      'Caracas',            '+58 424-555-0002', 'Alto, barba, camisa roja',          'Fue a visitar a su madre antes del sismo', 10.480, -66.900, 'buscado'),
('Ana Pérez',         65, 'San Felipe, Yaracuy',         'Yaracuy',            '+58 416-555-0003', 'Mayor, cabello blanco, usa bastón', 'Sin comunicación desde el primer sismo',  10.340, -68.740, 'buscado');

INSERT INTO daños_estructurales (ubicacion, estado, nivel, tipo, descripcion, atrapados, lat, lng) VALUES
('Av. La Playa, Catia La Mar',    'La Guaira (Vargas)', 'total',    'Edificio residencial',  'Colapso total del edificio de 8 pisos. Se buscan sobrevivientes.', 'si',  10.590, -67.020),
('Urb. El Naranjillo, San Felipe', 'Yaracuy',           'grave',    'Vivienda unifamiliar',  'Colapso parcial, muros exteriores caídos',                         'no',  10.400, -68.740);

INSERT INTO centros_acopio (nombre, direccion, estado, status, necesidades, contacto, lat, lng) VALUES
('Centro Comunitario La Vega',  'Calle Principal La Vega, Caracas',   'Caracas',            'activo',   ARRAY['agua','alimentos','medicina'], '+58 412-555-9001', 10.480, -66.930),
('Parroquia San Juan Bosco',    'Av. Soublette, La Guaira',           'La Guaira (Vargas)', 'activo',   ARRAY['ropa','frazadas','higiene'],  '@somos_laguaira', 10.600, -67.010),
('Alcaldía de San Felipe',      'Plaza Bolívar, San Felipe',          'Yaracuy',            'activo',   ARRAY['agua','medicina','voluntarios'],'+58 254-555-0100', 10.340, -68.744);

-- ──────────────────────────────────────────
-- 6. ÍNDICES para búsqueda rápida
-- ──────────────────────────────────────────
CREATE INDEX idx_desap_nombre  ON desaparecidos       (nombre);
CREATE INDEX idx_desap_estado  ON desaparecidos       (estado);
CREATE INDEX idx_desap_status  ON desaparecidos       (status);
CREATE INDEX idx_daños_estado  ON daños_estructurales (estado);
CREATE INDEX idx_daños_nivel   ON daños_estructurales (nivel);
CREATE INDEX idx_daños_atrap   ON daños_estructurales (atrapados);
CREATE INDEX idx_acopio_estado ON centros_acopio      (estado);
CREATE INDEX idx_acopio_status ON centros_acopio      (status);

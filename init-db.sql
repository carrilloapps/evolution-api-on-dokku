-- NOTA: Este script se ejecutará automáticamente SOLO cuando el contenedor de PostgreSQL se inicie por primera vez.
-- Si el volumen de datos persiste entre reinicios, este script NO se ejecutará de nuevo.

-- Verifica si el usuario ya existe antes de crearlo
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'evo_app_user') THEN
        CREATE USER evo_app_user WITH PASSWORD 'jA54%B@rF7$pQs2*Lx8#mZvN9!wY3&tD';
    END IF;
END
$$;

-- Verifica si la base de datos ya existe antes de crearla
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'service_db') THEN
        CREATE DATABASE service_db;
        -- Asigna propietario después de crear la DB
        EXECUTE 'ALTER DATABASE service_db OWNER TO evo_app_user';
    END IF;
END
$$;

-- Otorga privilegios (esto es idempotente y no causa error si se ejecuta varias veces)
GRANT ALL PRIVILEGES ON DATABASE service_db TO evo_app_user;

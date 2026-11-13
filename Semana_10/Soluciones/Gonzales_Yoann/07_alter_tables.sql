-- ============================================================
-- 07_alter_tables.sql
-- OBJETIVO: Aplicar 4 cambios de requerimiento con ALTER / sp_rename
-- ============================================================

USE EcommerceBD;
GO

-- ------------------------------------------------------------
-- CAMBIO 1
-- REQUERIMIENTO: Almacenar la fecha de nacimiento del cliente
-- ------------------------------------------------------------
ALTER TABLE ecommerce.CLIENTE
    ADD fechaNacimiento DATE NULL;
GO

-- Validar la nueva columna:
EXEC sp_help 'ecommerce.CLIENTE';
GO

-- ------------------------------------------------------------
-- CAMBIO 2
-- REQUERIMIENTO: Teléfonos internacionales de hasta 30 caracteres
-- ------------------------------------------------------------
ALTER TABLE ecommerce.CLIENTE
    ALTER COLUMN telefono VARCHAR(30) NULL;
GO

-- ------------------------------------------------------------
-- CAMBIO 3
-- REQUERIMIENTO: La fecha de nacimiento no puede ser una fecha futura
-- NOTA: En SQL Server no se antepone el nombre de la tabla en CHECK
-- ------------------------------------------------------------
ALTER TABLE ecommerce.CLIENTE
    ADD CONSTRAINT CK_CLIENTE_FECHANACIMIENTO
        CHECK (fechaNacimiento IS NULL OR fechaNacimiento <= GETDATE());
GO

-- ------------------------------------------------------------
-- CAMBIO 4
-- REQUERIMIENTO: Renombrar nombreCategoria a nombre_categoria (snake_case)
-- En SQL Server se usa sp_rename, no existe RENAME COLUMN
-- ------------------------------------------------------------
EXEC sp_rename
    'ecommerce.CATEGORIA.nombreCategoria',
    'nombre_categoria',
    'COLUMN';
GO

EXEC sp_help 'ecommerce.CATEGORIA';
GO

-- Se revierte el renombre para mantener la compatibilidad con el resto de scripts:
EXEC sp_rename
    'ecommerce.CATEGORIA.nombre_categoria',
    'nombreCategoria',
    'COLUMN';
GO

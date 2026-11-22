-- ============================================================
-- 08_drop_rename_demo.sql
-- OBJETIVO: Demostración controlada de DROP y RENAME (sp_rename)
-- sin afectar las tablas del modelo real del negocio.
-- ============================================================

USE EcommerceBD;
GO

-- ------------------------------------------------------------
-- 1. Crear tabla temporal de prueba
-- ------------------------------------------------------------
CREATE TABLE ecommerce.LOG_PRUEBA_TEMP (
    idLog       INT IDENTITY(1,1) PRIMARY KEY,
    mensaje     VARCHAR(200) NOT NULL,
    fechaLog    DATETIME NOT NULL DEFAULT GETDATE()
);
GO

INSERT INTO ecommerce.LOG_PRUEBA_TEMP (mensaje) VALUES ('Registro de prueba 1');
GO

-- ------------------------------------------------------------
-- 2. Renombrar tabla en SQL Server con sp_rename
-- ------------------------------------------------------------
EXEC sp_rename 'ecommerce.LOG_PRUEBA_TEMP', 'LOG_TEMPORAL_OBSOLETO';
GO

EXEC sp_help 'ecommerce.LOG_TEMPORAL_OBSOLETO';
GO

-- ------------------------------------------------------------
-- 3. Eliminar tabla temporal (DROP TABLE)
-- ------------------------------------------------------------
DROP TABLE ecommerce.LOG_TEMPORAL_OBSOLETO;
GO

-- ------------------------------------------------------------
-- 4. Demostración de Integridad Referencial impidiendo un DROP
-- INTENTO DE ERROR CONTROLADO:
-- Intentar borrar CATEGORIA fallará porque PRODUCTO depende de ella (FK).
-- ------------------------------------------------------------
-- Este DROP fallará a propósito:
DROP TABLE ecommerce.CATEGORIA;
GO

-- ------------------------------------------------------------
-- 5. Validación final: CATEGORIA sigue existiendo intacta
-- ------------------------------------------------------------
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'ecommerce'
ORDER BY TABLE_NAME;
GO

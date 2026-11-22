/* ============================================================
   08_drop_rename_demo.sql
   OBJETIVO: Mostrar DROP y RENAME (sp_rename) en un contexto
   justificado y controlado, usando una tabla y una columna
   temporales creadas solo para esta demostración — NO se toca el
   modelo real del caso (CLIENTE, PRODUCTO, PEDIDO, etc.).
   ============================================================ */

USE EcommerceBD;
GO

/* ------------------------------------------------------------
   CONTEXTO: el equipo crea una tabla de prueba para explorar una
   idea ("LOG_PRUEBA_TEMP"), y luego decide que ya no la necesita.
   ------------------------------------------------------------ */
CREATE TABLE ecommerce.LOG_PRUEBA_TEMP (
    idLog       INT IDENTITY(1,1) PRIMARY KEY,
    mensaje     VARCHAR(200) NOT NULL,
    fechaLog    DATETIME NOT NULL DEFAULT GETDATE()
);
GO

INSERT INTO ecommerce.LOG_PRUEBA_TEMP (mensaje) VALUES ('Registro de prueba 1');
GO

-- RENAME de una TABLA en SQL Server: también con sp_rename
-- (a diferencia de otros motores donde existiría un RENAME TABLE
-- directo).
EXEC sp_rename 'ecommerce.LOG_PRUEBA_TEMP', 'LOG_TEMPORAL_OBSOLETO';
GO

EXEC sp_help 'ecommerce.LOG_TEMPORAL_OBSOLETO';
GO

-- Decisión de negocio: esta tabla temporal ya cumplió su propósito
-- y debe eliminarse. DROP TABLE es irreversible: borra estructura Y
-- datos, por eso solo se usa aquí, sobre una tabla de prueba, nunca
-- sobre CLIENTE, PEDIDO, etc.
DROP TABLE ecommerce.LOG_TEMPORAL_OBSOLETO;
GO

/* ------------------------------------------------------------
   DEMOSTRACIÓN CONTROLADA DE UN ERROR REAL:
   "No se puede eliminar una tabla referenciada por una FK"
   ------------------------------------------------------------ */

-- Este DROP fallará a propósito, porque CATEGORIA es referenciada
-- por PRODUCTO mediante FK_PRODUCTO_CATEGORIA. Es un ejemplo real
-- de integridad referencial impidiendo una operación destructiva.
-- Ejecútalo y observa el mensaje de error (ver PARTE 9 de la guía).
DROP TABLE ecommerce.CATEGORIA;
GO

/* ------------------------------------------------------------
   RESULTADO ESPERADO
   - LOG_PRUEBA_TEMP se renombra correctamente a
     LOG_TEMPORAL_OBSOLETO y luego se elimina sin problema (no
     tiene FK que dependan de ella).
   - El DROP TABLE ecommerce.CATEGORIA falla con un mensaje similar
     a: "Could not drop object 'ecommerce.CATEGORIA' because it is
     referenced by a FOREIGN KEY constraint."
   - CATEGORIA sigue existiendo intacta después de este script.

   CÓMO VALIDARLO
   SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
   WHERE TABLE_SCHEMA = 'ecommerce';
   -- CATEGORIA debe seguir apareciendo; LOG_TEMPORAL_OBSOLETO no.
   ------------------------------------------------------------ */

SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'ecommerce'
ORDER BY TABLE_NAME;
GO

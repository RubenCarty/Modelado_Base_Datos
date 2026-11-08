/* ============================================================
   07_alter_tables.sql
   OBJETIVO: Simular que, después de tener la base en producción,
   Gerencia solicita 4 cambios reales sobre el modelo. Cada cambio
   se resuelve con ALTER TABLE, justificado por un requerimiento,
   nunca "porque sí".
   ============================================================ */

USE EcommerceBD;
GO

/* ------------------------------------------------------------
   CAMBIO 1
   REQUERIMIENTO: "Gerencia ahora necesita almacenar la fecha de
   nacimiento del cliente, para futuras campañas de marketing."
   ------------------------------------------------------------ */
ALTER TABLE ecommerce.CLIENTE
    ADD fechaNacimiento DATE NULL;
GO
-- QUÉ HACE: agrega una columna nueva, NULL porque los clientes ya
-- existentes no tienen ese dato todavía (no podemos inventarlo).
-- RESULTADO ESPERADO: la tabla CLIENTE ahora tiene 8 columnas.
-- CÓMO VALIDARLO:
EXEC sp_help 'ecommerce.CLIENTE';
GO

/* ------------------------------------------------------------
   CAMBIO 2
   REQUERIMIENTO: "El teléfono de algunos clientes internacionales
   no cabe en 20 caracteres; debe admitir mayor longitud."
   ------------------------------------------------------------ */
ALTER TABLE ecommerce.CLIENTE
    ALTER COLUMN telefono VARCHAR(30) NULL;
GO
-- QUÉ HACE: amplía el tamaño de la columna telefono de VARCHAR(20)
-- a VARCHAR(30), sin perder los datos ya almacenados.
-- RESULTADO ESPERADO: sp_help muestra telefono como varchar(30).

/* ------------------------------------------------------------
   CAMBIO 3
   REQUERIMIENTO: "Se necesita una nueva restricción: la fecha de
   nacimiento no puede ser una fecha futura."
   ------------------------------------------------------------ */
ALTER TABLE ecommerce.CLIENTE
    ADD CONSTRAINT CK_CLIENTE_FECHANACIMIENTO
        CHECK (fechaNacimiento IS NULL OR fechaNacimiento <= GETDATE());
GO
-- QUÉ HACE: agrega una regla de negocio nueva sobre una columna que
-- ya existía en la tabla (demuestra que las constraints se pueden
-- añadir en cualquier momento del ciclo de vida de la base).
-- CÓMO VALIDARLO (debe fallar):
-- INSERT INTO ecommerce.CLIENTE (nombres, apellidos, email, fechaRegistro, estado, fechaNacimiento)
-- VALUES ('Test','Futuro','test.futuro@correo.com','2024-01-01','ACTIVO','2099-01-01');

/* ------------------------------------------------------------
   CAMBIO 4
   REQUERIMIENTO: "El campo 'nombreCategoria' en realidad debe
   llamarse 'nombre_categoria' para alinearse al nuevo estándar de
   nomenclatura de la empresa (snake_case)."

   IMPORTANTE — DIFERENCIA CON SQL ESTÁNDAR:
   En SQL estándar (y en otros motores como PostgreSQL o MySQL)
   se usaría: RENAME COLUMN nombreCategoria TO nombre_categoria.
   SQL Server NO soporta esa sintaxis. En SQL Server, renombrar
   columnas, tablas u otros objetos se hace con el procedimiento
   almacenado del sistema sp_rename.
   ------------------------------------------------------------ */
EXEC sp_rename
    'ecommerce.CATEGORIA.nombreCategoria', -- objeto a renombrar
    'nombre_categoria',                     -- nuevo nombre
    'COLUMN';                               -- tipo de objeto
GO
-- QUÉ HACE: renombra la columna sin perder datos ni constraints
-- asociadas (el UNIQUE definido sobre ella se conserva).
-- CÓMO VALIDARLO:
EXEC sp_help 'ecommerce.CATEGORIA';
GO

-- Como el resto de scripts de este laboratorio (05, 06, 09, 10)
-- fue escrito usando el nombre original "nombreCategoria", si vas
-- a seguir ejecutándolos después de este cambio, revierte el
-- renombre para no romper las referencias del resto del laboratorio:
EXEC sp_rename
    'ecommerce.CATEGORIA.nombre_categoria',
    'nombreCategoria',
    'COLUMN';
GO

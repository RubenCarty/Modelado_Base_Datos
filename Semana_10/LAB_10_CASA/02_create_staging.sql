-- ============================================================
-- 02_create_staging.sql
-- Paso 2 del Bloque B (guía del estudiante, sección 6).
-- Crea (o recrea) la zona temporal de recepción. A propósito NO
-- tiene PK, FK, CHECK ni tipos estrictos: debe poder aceptar datos
-- crudos, mal formados o incompletos tal como llegan del scraping.
-- Esa es justamente la pregunta PIENSA de la guía: "¿por qué STAGE
-- puede aceptar texto y NULL aunque PRODUCTO tenga tipos y
-- restricciones más estrictos?"
-- ============================================================

USE EcommerceBD;
GO

DROP TABLE IF EXISTS PRODUCTO_WEB_STAGE;
GO

CREATE TABLE PRODUCTO_WEB_STAGE (
    nombre          NVARCHAR(300) NULL,
    precio          NVARCHAR(50)  NULL,  -- texto a propósito: aún no se valida que sea numérico
    categoria       NVARCHAR(100) NULL,
    disponibilidad  NVARCHAR(100) NULL,
    calificacion    NVARCHAR(20)  NULL,  -- texto a propósito: aún no se valida que esté entre 1 y 5
    url             NVARCHAR(300) NULL
);
GO

PRINT 'PRODUCTO_WEB_STAGE creada (vacia). Carga productos_web.csv con el metodo indicado por el docente (BULK INSERT o el importador grafico de DBeaver, igual que en 00_COMO_IMPORTAR_CSV_SQLSERVER22.md de la S06). Luego ejecuta 03_insertar_productos_desde_stage.sql para pasar los productos validados a ecommerce.PRODUCTO.';

-- ============================================================
-- 01_verificar_bd.sql
-- Paso 1 del Bloque B (guía del estudiante, sección 6).
-- Confirma que EcommerceBD existe y que la Semana 9 (DDL, con el
-- paquete real de S09/SEMANA09_ECOMMERCE) ya quedó construida.
-- ============================================================

USE master;
GO

IF DB_ID(N'EcommerceBD') IS NULL
BEGIN
    RAISERROR('EcommerceBD no existe todavia. Ejecuta primero S09/SEMANA09_ECOMMERCE/sql/01 a 04.', 16, 1);
END
GO

USE EcommerceBD;
GO

IF OBJECT_ID('ecommerce.PRODUCTO', 'U') IS NULL OR OBJECT_ID('ecommerce.CATEGORIA', 'U') IS NULL
BEGIN
    RAISERROR('Faltan ecommerce.PRODUCTO / ecommerce.CATEGORIA. Ejecuta S09/SEMANA09_ECOMMERCE/sql/01 a 04.', 16, 1);
END
ELSE
BEGIN
    PRINT 'EcommerceBD verificada correctamente: ecommerce.PRODUCTO y ecommerce.CATEGORIA existen.';
    SELECT COUNT(*) AS TotalProductosActuales FROM ecommerce.PRODUCTO;
    SELECT COUNT(*) AS TotalCategoriasActuales FROM ecommerce.CATEGORIA;
END
GO

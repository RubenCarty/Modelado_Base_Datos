
-- 02_create_schemas.sql

USE EcommerceBD;
GO

-- CREACION DE SCHEMA
CREATE SCHEMA ecommerce AUTHORIZATION dbo;
GO

-- VERIFICAR CREACION DE SCHEMA
SELECT * FROM sys.schemas WHERE name = 'ecommerce';
GO

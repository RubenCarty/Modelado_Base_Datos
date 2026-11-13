-- ============================================================
-- 09_challenge.sql
-- CHALLENGE AUTÓNOMO: Creación y blindaje de la tabla CUPON
-- ============================================================

USE EcommerceBD;
GO

-- ------------------------------------------------------------
-- 1. CREACIÓN DE LA TABLA ecommerce.CUPON
-- ------------------------------------------------------------
CREATE TABLE ecommerce.CUPON (
    idCupon             INT             IDENTITY(1,1) NOT NULL,
    codigo              VARCHAR(20)     NOT NULL,
    porcentajeDescuento DECIMAL(5,2)    NOT NULL,
    fechaInicio         DATE            NOT NULL,
    fechaFin            DATE            NOT NULL,
    estado              VARCHAR(10)     NOT NULL DEFAULT ('ACTIVO'),
    
    CONSTRAINT PK_CUPON 
        PRIMARY KEY (idCupon),
    CONSTRAINT UQ_CUPON_CODIGO 
        UNIQUE (codigo),
    CONSTRAINT CK_CUPON_PORCENTAJE 
        CHECK (porcentajeDescuento > 0 AND porcentajeDescuento <= 100),
    CONSTRAINT CK_CUPON_FECHAS 
        CHECK (fechaFin >= fechaInicio),
    CONSTRAINT CK_CUPON_ESTADO 
        CHECK (estado IN ('ACTIVO', 'INACTIVO', 'VENCIDO'))
);
GO

-- ------------------------------------------------------------
-- 2. PRUEBAS DE VALIDACIÓN (Las 4 pedidas en la guía)
-- ------------------------------------------------------------

-- Prueba 1: INSERT VÁLIDO (Debe insertarse exitosamente)
INSERT INTO ecommerce.CUPON (codigo, porcentajeDescuento, fechaInicio, fechaFin, estado)
VALUES ('BIENVENIDA10', 10.00, '2024-06-01', '2024-06-30', 'ACTIVO');
GO

-- Prueba 2: Porcentaje > 100 (Debe ser rechazado por CK_CUPON_PORCENTAJE)
INSERT INTO ecommerce.CUPON (codigo, porcentajeDescuento, fechaInicio, fechaFin, estado)
VALUES ('INVALIDO150', 150.00, '2024-06-01', '2024-06-30', 'ACTIVO');
GO

-- Prueba 3: fechaFin anterior a fechaInicio (Debe ser rechazado por CK_CUPON_FECHAS)
INSERT INTO ecommerce.CUPON (codigo, porcentajeDescuento, fechaInicio, fechaFin, estado)
VALUES ('FECHASMAL', 15.00, '2024-07-15', '2024-07-01', 'ACTIVO');
GO

-- Prueba 4: Código de cupón duplicado (Debe ser rechazado por UQ_CUPON_CODIGO)
INSERT INTO ecommerce.CUPON (codigo, porcentajeDescuento, fechaInicio, fechaFin, estado)
VALUES ('BIENVENIDA10', 20.00, '2024-08-01', '2024-08-31', 'ACTIVO');
GO

-- ------------------------------------------------------------
-- 3. COMPROBACIÓN FINAL
-- Solo debe existir exactamente 1 fila (la del INSERT #1)
-- ------------------------------------------------------------
SELECT * FROM ecommerce.CUPON;
GO

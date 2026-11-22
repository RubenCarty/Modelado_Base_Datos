/* ============================================================
   10_solution.sql   ***** SOLO PARA EL DOCENTE *****
   Solución de referencia del Challenge Autónomo (09_challenge.sql).
   No entregar este archivo a los estudiantes antes del cierre
   de la sesión.
   ============================================================ */

USE EcommerceBD;
GO

CREATE TABLE ecommerce.CUPON (
    idCupon             INT             IDENTITY(1,1) NOT NULL,
    codigo              VARCHAR(20)     NOT NULL,
    porcentajeDescuento DECIMAL(5,2)    NOT NULL,
    fechaInicio         DATE            NOT NULL,
    fechaFin            DATE            NOT NULL,
    estado              VARCHAR(10)     NOT NULL DEFAULT ('ACTIVO'),
    CONSTRAINT PK_CUPON PRIMARY KEY (idCupon),
    CONSTRAINT UQ_CUPON_CODIGO UNIQUE (codigo),
    CONSTRAINT CK_CUPON_PORCENTAJE
        CHECK (porcentajeDescuento > 0 AND porcentajeDescuento <= 100),
    CONSTRAINT CK_CUPON_FECHAS
        CHECK (fechaFin >= fechaInicio),
    CONSTRAINT CK_CUPON_ESTADO
        CHECK (estado IN ('ACTIVO','INACTIVO','VENCIDO'))
);
GO

/* --------- Pruebas de validación (las 4 pedidas en el enunciado) --------- */

-- 1) Válido
INSERT INTO ecommerce.CUPON (codigo, porcentajeDescuento, fechaInicio, fechaFin, estado)
VALUES ('BIENVENIDA10', 10.00, '2024-06-01', '2024-06-30', 'ACTIVO');
GO

-- 2) Porcentaje > 100 -> debe fallar por CK_CUPON_PORCENTAJE
INSERT INTO ecommerce.CUPON (codigo, porcentajeDescuento, fechaInicio, fechaFin, estado)
VALUES ('INVALIDO150', 150.00, '2024-06-01', '2024-06-30', 'ACTIVO');
GO

-- 3) fechaFin anterior a fechaInicio -> debe fallar por CK_CUPON_FECHAS
INSERT INTO ecommerce.CUPON (codigo, porcentajeDescuento, fechaInicio, fechaFin, estado)
VALUES ('FECHASMAL', 15.00, '2024-07-15', '2024-07-01', 'ACTIVO');
GO

-- 4) Código repetido -> debe fallar por UQ_CUPON_CODIGO
INSERT INTO ecommerce.CUPON (codigo, porcentajeDescuento, fechaInicio, fechaFin, estado)
VALUES ('BIENVENIDA10', 20.00, '2024-08-01', '2024-08-31', 'ACTIVO');
GO

-- Comprobación: solo debe existir 1 fila (la del INSERT #1).
SELECT * FROM ecommerce.CUPON;
GO

/* ============================================================
   RESPUESTAS — TECH INTERVIEW CHALLENGE (ver PARTE 12 de la guía
   docente para el detalle completo de criterios de evaluación)
   ============================================================

   PREGUNTA 1 (conceptual): PRIMARY KEY vs UNIQUE
   - Ambas garantizan unicidad de valores.
   - PRIMARY KEY: solo una por tabla, NO admite NULL, se usa como
     identificador principal y normalmente es referenciada por FK.
   - UNIQUE: puede haber varias por tabla, SÍ admite NULL (una o
     más filas con NULL, según el motor), y sirve para reglas de
     negocio adicionales (ej. email único) sin ser el identificador
     principal de la fila.

   PREGUNTA 2 (caso): impedir pedido con cliente inexistente
   - Respuesta esperada: una FOREIGN KEY desde PEDIDO.idCliente
     hacia CLIENTE.idCliente. SQL Server rechaza automáticamente
     cualquier INSERT/UPDATE que intente usar un idCliente que no
     exista en CLIENTE.

   PREGUNTA 3 (debugging): ver el CREATE TABLE defectuoso que se
   entrega en la guía docente; los problemas típicos a identificar
   son: falta de PRIMARY KEY, tipo de dato inadecuado para dinero
   (FLOAT en vez de DECIMAL), FK apuntando a una tabla que aún no
   existe, y ausencia de NOT NULL en columnas obligatorias.
   ============================================================ */

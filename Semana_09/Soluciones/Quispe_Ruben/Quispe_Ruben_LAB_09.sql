CREATE DATABASE IF EXISTS Quispe_Ruben_LAB_09
CREATE DATABASE Quispe_Ruben_LAB_09;
USE Quispe_Ruben_LAB_09;

--======sol_lab09

select * from [dbo].[01_Ventas_Minoristas_200]
-- 2.1 ¿Cuál es el largo máximo real de cada texto? (para no poner VARCHAR(255) a ciegas)
SELECT
    MAX(LEN(IDOrden)) AS max_IDOrden, MAX(LEN(NombreCliente)) AS max_NombreCliente,
    MAX(LEN(ZonaCliente)) AS max_ZonaCliente, MAX(LEN(SupervisorZona)) AS max_SupervisorZona,
    MAX(LEN(NombreProducto)) AS max_NombreProducto, MAX(LEN(CategoriaProducto)) AS max_CategoriaProducto,
    MAX(LEN(NombreProveedor)) AS max_NombreProveedor, MAX(LEN(CiudadProveedor)) AS max_CiudadProveedor
FROM [dbo].[01_Ventas_Minoristas_200];

--SupervisorZona = 12
-- 2.2 ¿Qué rango tienen los valores numéricos? (para elegir INT vs TINYINT, DECIMAL con la precisión justa)
SELECT MIN(PrecioUnitario) AS min_precio, MAX(PrecioUnitario) AS max_precio,
       MIN(Cantidad) AS min_cant, MAX(Cantidad) AS max_cant,
       MIN(PrecioTotal) AS min_total, MAX(PrecioTotal) AS max_total
FROM [dbo].[01_Ventas_Minoristas_200];
-- min_precio = 24.5
-- max_precio = 110

--===========================
CREATE TABLE ZONA (
    ZonaCliente    NVARCHAR(20) NOT NULL,
    SupervisorZona NVARCHAR(30) NOT NULL,
    CONSTRAINT PK_ZONA PRIMARY KEY (ZonaCliente)
);

CREATE TABLE PROVEEDOR (
    IDProveedor     CHAR(5)      NOT NULL,
    NombreProveedor NVARCHAR(40) NOT NULL,
    CiudadProveedor NVARCHAR(30) NOT NULL,
    CONSTRAINT PK_PROVEEDOR PRIMARY KEY (IDProveedor)
);

--===============
CREATE TABLE CLIENTE (
    IDCliente     CHAR(5)      NOT NULL,
    NombreCliente NVARCHAR(30) NOT NULL,
    ZonaCliente   NVARCHAR(20) NOT NULL,
    CONSTRAINT PK_CLIENTE PRIMARY KEY (IDCliente),
    CONSTRAINT FK_CLIENTE_ZONA FOREIGN KEY (ZonaCliente) REFERENCES ZONA (ZonaCliente)
);

-- TODO: crea PRODUCTO (IDProducto PK, NombreProducto, CategoriaProducto, PrecioUnitario, IDProveedor FK)
-- Pista de restricción: ¿puede un producto tener precio 0 o negativo? Agrega el CHECK correspondiente.

--== producto
CREATE TABLE CLIENTE_TELEFONO (
    IDCliente CHAR(5)     NOT NULL,
    Valor     CHAR(9)     NOT NULL,
    CONSTRAINT PK_CLIENTE_TELEFONO PRIMARY KEY (IDCliente, Valor),
    CONSTRAINT FK_CLIENTE_TELEFONO FOREIGN KEY (IDCliente) REFERENCES CLIENTE (IDCliente),
    CONSTRAINT CK_CLIENTE_TELEFONO_FORMATO CHECK (Valor NOT LIKE '%[^0-9]%')
);
--==================
CREATE TABLE ORDEN_CANALATENCION (
    IDOrden       CHAR(4)      NOT NULL,
    CanalAtencion NVARCHAR(10) NOT NULL,
    CONSTRAINT PK_ORDEN_CANALATENCION PRIMARY KEY (IDOrden, CanalAtencion),
    CONSTRAINT FK_ORDEN_CANALATENCION FOREIGN KEY (IDOrden) REFERENCES ORDEN (IDOrden),
    CONSTRAINT CK_ORDEN_CANAL CHECK (CanalAtencion IN (N'Web', N'Tienda'))
);

-- TODO: crea ORDEN_PROMOCION y ORDEN_PROYECTOCOMERCIAL siguiendo el mismo patrón.
-- Pista: revisa con SELECT DISTINCT qué valores reales tiene cada columna en ORDEN_INICIAL
-- antes de decidir si vale la pena un CHECK con lista fija como el de arriba.

-- TODO: crea ORDEN (IDOrden PK, IDCliente FK)
--======
-- Consulta frecuente de negocio: "dame todos los pedidos de un cliente"
-- Sin índice, SQL Server debe revisar TODA la tabla ORDEN fila por fila (scan).
SELECT * FROM ORDEN WHERE IDCliente = 'CL001';

-- Índice que acelera exactamente esa búsqueda:
CREATE NONCLUSTERED INDEX IX_ORDEN_CLIENTE ON ORDEN (IDCliente);

--==== paso 9
-- Carga (mismo patrón del Laboratorio 6)
INSERT INTO ZONA SELECT DISTINCT ZonaCliente, SupervisorZona FROM [dbo].[01_Ventas_Minoristas_200]
INSERT INTO PROVEEDOR SELECT DISTINCT IDProveedor, NombreProveedor, CiudadProveedor FROM ;
INSERT INTO CLIENTE SELECT DISTINCT IDCliente, NombreCliente, ZonaCliente FROM [01_Ventas_Minoristas_200]
-- completa el resto de INSERT para tus propias tablas (PRODUCTO, ORDEN, DETALLE_ORDEN, las 3 de hechos)

--=====================
-- Prueba 1: ¿tu CHECK de precio rechaza un producto gratis o negativo?
INSERT INTO PRODUCTO VALUES ('P999', N'Producto prueba', N'Categoria X', -10.00, 'PV001');

-- Prueba 2: ¿tu PK compuesta de DETALLE_ORDEN rechaza una fila duplicada?
INSERT INTO DETALLE_ORDEN VALUES ('O001', 'P001', 24.5, 3, 73.5);  -- ya existe, debe fallar

-- Prueba 3: ¿tu FK rechaza un cliente inexistente?
INSERT INTO ORDEN VALUES ('O999', 'CL999');
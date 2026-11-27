--Creación de la base de datos
CREATE DATABASE BD_NEXOMARKET_S12;

--validación de los registros
SELECT count(*) AS TotalRegistros FROM PRODUCTO;

-- Seleccion de los 10 primeros registros
SELECT TOP 10* FROM PRODUCTO;

-- SQL Challenge 8 retos
-- Reto 1: AND / OR
-- Muestra con AND
SELECT idOferta,nombre,categoria,marca,precio,stock,estado
FROM PRODUCTO
WHERE estado = 'ACTIVO' AND stock >0;

-- Muestra con OR
SELECT idOferta,nombre,categoria,marca,precio,stock,estado
FROM PRODUCTO
WHERE estado= 'ACTIVO' OR stock >0;

--Reto 2: IN
--mostrar Laptop, Tablet o Smartphone.
SELECT idOferta,nombre,categoria,marca,precio,stock
FROM PRODUCTO
WHERE categoria IN ('Laptops','Tablets','Smartphones')

--Reto 3: BETWEEN
--Mostrar productos entre S/1500 y S/3000
SELECT idOferta,nombre,categoria,marca,precio,stock
FROM PRODUCTO
WHERE precio BETWEEN 1500.00 AND 3000.00
ORDER BY precio DESC;

--Verificacion de Extremos
SELECT
    MIN(precio) AS MinimoEncontrado,
    MAX(precio) AS MAximoEncontrado,
    COUNT(*) AS totalEnRango
FROM PRODUCTO
WHERE precio BETWEEN 1500.00 AND 3000.00;

--Reto 4: LIKE
--Buscar nombres que contengan "Pro"
--inico con el nombre "Pro"
SELECT idOferta,nombre,categoria,precio
FROM PRODUCTO
WHERE nombre LIKE 'Pro%'
ORDER BY nombre;

--termina con el nombre "Pro"
SELECT idOferta,nombre,categoria,precio
FROM PRODUCTO
WHERE nombre LIKE '%Pro'
ORDER BY nombre;

--Nombres que contiene 'Pro' en cualquier posición
SELECT idOferta,nombre,categoria,precio
FROM PRODUCTO
WHERE nombre LIKE '%Pro%'
ORDER BY nombre;

--Reto 5: IS NULL
SELECT idOferta,nombre,categoria, marca,stock,proveedor
FROM PRODUCTO
WHERE proveedor IS NULL ;

--Reto 6: DISTINCT
SELECT DISTINCT marca
FROM PRODUCTO
ORDER BY marca ASC;

--Reto 7: TOP + ORDER BY
SELECT TOP 10
    idOferta,nombre,categoria,marca,precio,stock
FROM PRODUCTO
WHERE stock >0
ORDER BY precio DESC;

--Reto 8: CASE
SELECT idOferta,
       nombre,
       categoria,
       precio,
       stock,
       CASE
           WHEN precio < 1000.00 THEN 'ECONÓMICO'
           WHEN precio BETWEEN 1000.00 AND 2500.00 THEN 'MEDIO'
           ELSE 'PREMIUM'
        END AS segmentoPrecio,
    CASE
        WHEN stock = 0 THEN 'AGOTADO'
        WHEN stock BETWEEN 1 AND 10 THEN 'CRITICO'
        WHEN stock BETWEEN 11 AND 30 THEN 'ADECUADO'
        ELSE 'SOBRESTOCK'
    END AS estadoStock
FROM PRODUCTO

--Boss level
SELECT TOP 10
    idOferta,
    nombre,
    categoria,
    marca,
    precio,
    costo,
    stock,
    ventas30dias,
    proveedor,
    estado,
    CASE
        WHEN precio < 1800.00 THEN 'ECONÓMICO'
        WHEN precio BETWEEN 1800.00 AND 2400.00 THEN 'MEDIO'
        ELSE 'PREMIUM'
    END AS segmentoPrecio
FROM dbo.PRODUCTO
WHERE categoria IN ('Laptops', 'Tablets')
  AND precio BETWEEN 1500.00 AND 3000.00
  AND stock > 0
  AND proveedor IS NOT NULL
  AND nombre LIKE '%Pro%'
  AND estado <> 'DESCONTINUADO'
ORDER BY precio DESC;

--Decision room . VIEW
CREATE  OR ALTER VIEW dbo.vw_DecisionRoom
AS
SELECT
    idOferta,
    nombre,
    categoria,
    marca,
    precio,
    costo,
    (precio - costo) AS margenUnitario,
    ROUND(((precio - costo)/NULLIF(precio,0))*100.0,2) AS margenPorcentaje,
    stock,
    ventas30dias,
    rating,
    proveedor,
    ciudad,
    estado,
    (precio * stock) AS valorInventario,
    CASE
        WHEN precio < 1000.00 THEN 'ECONOMICO'
        WHEN precio BETWEEN 1000.00 AND 2500.00 THEN 'MEDIO'
        ELSE 'PREMIUM'
    END AS segmentoPrecio,
    CASE
        WHEN stock = 0 THEN 'AGOTADO'
        WHEN stock BETWEEN 1 AND 10 THEN 'CRITICO'
        WHEN stock BETWEEN 11 AND 30 THEN 'ADECUADO'
    END AS estadoStock
FROM  PRODUCTO
WHERE estado <> 'DESCONTINUADO';

--Consulta de verificación solicitada
SELECT TOP 20 *
FROM dbo.vw_DecisionRoom
ORDER BY ventas30dias DESC;



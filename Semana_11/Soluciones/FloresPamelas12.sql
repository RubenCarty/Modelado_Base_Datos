CREATE DATABASE FLORES_PAMELA_S12;
GO

SELECT * FROM productos_web;


SELECT
    nombre        AS Producto,
    precio        AS PrecioTexto,
    categoria     AS Categoria
FROM productos_web;

SELECT DISTINCT categoria FROM productos_web;

SELECT * FROM productos_web WHERE categoria = N'Travel' OR categoria = N'Mystery';

SELECT * FROM productos_web WHERE categoria IN (N'Travel', N'Mystery');

SELECT * FROM productos_web
WHERE categoria = N'Mystery' AND TRY_CAST(calificacion AS INT) = 5;

SELECT
    nombre,
    precio AS PrecioTexto,
    TRY_CAST(precio AS DECIMAL(10,2)) AS PrecioNumerico
FROM productos_web;

SELECT nombre, precio FROM productos_web
WHERE TRY_CAST(precio AS DECIMAL(10,2)) BETWEEN 20 AND 40;

SELECT nombre FROM productos_web WHERE nombre LIKE N'%World%';

SELECT nombre, precio FROM productos_web
ORDER BY TRY_CAST(precio AS DECIMAL(10,2)) DESC;

SELECT TOP 10 nombre, precio FROM productos_web
ORDER BY TRY_CAST(precio AS DECIMAL(10,2)) DESC;


SELECT * FROM productos_web WHERE nombre IS NULL OR LTRIM(RTRIM(nombre)) = '';


SELECT * FROM productos_web WHERE precio IS NULL;


SELECT * FROM productos_web
WHERE precio IS NOT NULL AND TRY_CAST(precio AS DECIMAL(10,2)) IS NULL;


SELECT * FROM productos_web WHERE TRY_CAST(precio AS DECIMAL(10,2)) <= 0;

SELECT DISTINCT categoria FROM productos_web
WHERE categoria NOT IN (N'Travel', N'Mystery', N'Historical Fiction');

SELECT nombre, categoria FROM productos_web
WHERE nombre <> LTRIM(RTRIM(nombre)) OR categoria <> LTRIM(RTRIM(categoria));


SELECT nombre, categoria, COUNT(*) AS Repeticiones
FROM productos_web
GROUP BY nombre, categoria
HAVING COUNT(*) > 1;

SELECT url, COUNT(*) AS Repeticiones
FROM productos_web
GROUP BY url
HAVING COUNT(*) > 1;

SELECT * FROM productos_web
WHERE TRY_CAST(calificacion AS INT) IS NULL
   OR TRY_CAST(calificacion AS INT) NOT BETWEEN 1 AND 5;

SELECT
    categoria,
    COUNT(*)                                         AS TotalLibros,
    ROUND(AVG(TRY_CAST(precio AS DECIMAL(10,2))), 2) AS PrecioPromedio,
    MIN(TRY_CAST(precio AS DECIMAL(10,2)))           AS PrecioMinimo,
    MAX(TRY_CAST(precio AS DECIMAL(10,2)))           AS PrecioMaximo
FROM productos_web
GROUP BY categoria;

SELECT
    CASE
        WHEN TRY_CAST(calificacion AS INT) >= 4 THEN N'Alta'
        WHEN TRY_CAST(calificacion AS INT) = 3  THEN N'Media'
        ELSE N'Baja'
    END AS NivelCalidad,
    COUNT(*) AS Total
FROM productos_web
GROUP BY
    CASE
        WHEN TRY_CAST(calificacion AS INT) >= 4 THEN N'Alta'
        WHEN TRY_CAST(calificacion AS INT) = 3  THEN N'Media'
        ELSE N'Baja'
    END;
SELECT categoria, COUNT(*) AS Total
FROM productos_web
GROUP BY categoria
HAVING COUNT(*) > 15;
SELECT nombre, precio
FROM productos_web
WHERE TRY_CAST(precio AS DECIMAL(10,2)) >
      (SELECT AVG(TRY_CAST(precio AS DECIMAL(10,2))) FROM productos_web)
ORDER BY TRY_CAST(precio AS DECIMAL(10,2)) DESC;

WITH Numerado AS (
    SELECT
        nombre, categoria, TRY_CAST(precio AS DECIMAL(10,2)) AS PrecioNum,
        ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY TRY_CAST(precio AS DECIMAL(10,2)) DESC) AS Posicion
    FROM productos_web
)
SELECT categoria, nombre, PrecioNum
FROM Numerado
WHERE Posicion = 1;
WITH Rankeado AS (
    SELECT
        categoria, nombre, TRY_CAST(precio AS DECIMAL(10,2)) AS PrecioNum,
        RANK() OVER (PARTITION BY categoria ORDER BY TRY_CAST(precio AS DECIMAL(10,2)) DESC) AS Posicion
    FROM productos_web
)
SELECT categoria, nombre, PrecioNum, Posicion
FROM Rankeado
WHERE Posicion <= 3
ORDER BY categoria, Posicion;

SELECT s.categoria, s.nombre, TRY_CAST(s.precio AS DECIMAL(10,2)) AS Precio
FROM productos_web s
WHERE TRY_CAST(s.precio AS DECIMAL(10,2)) > (
    SELECT AVG(TRY_CAST(s2.precio AS DECIMAL(10,2)))
    FROM productos_web s2
    WHERE s2.categoria = s.categoria
)
ORDER BY s.categoria, Precio DESC;

SELECT
    categoria,
    STRING_AGG(nombre, N' | ') AS Catalogo
FROM productos_web
GROUP BY categoria;
GO
CREATE OR ALTER VIEW V_AUDITORIA_STAGE AS
SELECT
    'Nombre NULL o vacio'  AS Problema, COUNT(*) AS Total
    FROM productos_web WHERE nombre IS NULL OR LTRIM(RTRIM(nombre)) = ''
UNION ALL
SELECT 'Precio NULL', COUNT(*)
    FROM productos_web WHERE precio IS NULL
UNION ALL
SELECT 'Precio no numerico', COUNT(*)
    FROM productos_web WHERE precio IS NOT NULL AND TRY_CAST(precio AS DECIMAL(10,2)) IS NULL
UNION ALL
SELECT 'Precio <= 0', COUNT(*)
    FROM productos_web WHERE TRY_CAST(precio AS DECIMAL(10,2)) <= 0
UNION ALL
SELECT 'Categoria inesperada', COUNT(*)
    FROM productos_web WHERE categoria NOT IN (N'Travel', N'Mystery', N'Historical Fiction')
UNION ALL
SELECT 'Calificacion fuera de 1-5', COUNT(*)
    FROM productos_web
    WHERE TRY_CAST(calificacion AS INT) IS NULL OR TRY_CAST(calificacion AS INT) NOT BETWEEN 1 AND 5;
GO

SELECT * FROM V_AUDITORIA_STAGE;



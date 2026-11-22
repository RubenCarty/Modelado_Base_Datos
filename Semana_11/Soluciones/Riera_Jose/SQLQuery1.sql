CREATE DATABASE DDBB_Riera_Jose_S12;


SELECT * FROM [dbo].[productos_web]



-- El libro MÁS CARO de cada categoría, con ROW_NUMBER() + PARTITION BY
WITH Numerado AS (
    SELECT
        nombre, categoria, TRY_CAST(precio AS DECIMAL(10,2)) AS PrecioNum,
        ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY TRY_CAST(precio AS DECIMAL(10,2)) DESC) AS Posicion
    FROM [dbo].[productos_web]
)
SELECT categoria, nombre, PrecioNum
FROM Numerado
WHERE Posicion = 1;

--===================

-- TOP 3 por categoría (cambia Posicion = 1 por <= 3), con RANK() para permitir empates
WITH Rankeado AS (
    SELECT
        categoria, nombre, TRY_CAST(precio AS DECIMAL(10,2)) AS PrecioNum,
        RANK() OVER (PARTITION BY categoria ORDER BY TRY_CAST(precio AS DECIMAL(10,2)) DESC) AS Posicion
    FROM [dbo].[productos_web]
)
SELECT categoria, nombre, PrecioNum, Posicion
FROM Rankeado
WHERE Posicion <= 3
ORDER BY categoria, Posicion;

--================

-- Subconsulta CORRELACIONADA: libros más caros que el promedio DE SU PROPIA categoría
-- (distinto del "promedio general" del Nivel 2: aquí el promedio se recalcula por cada fila)
SELECT s.categoria, s.nombre, TRY_CAST(s.precio AS DECIMAL(10,2)) AS Precio
FROM [dbo].[productos_web] s
WHERE TRY_CAST(s.precio AS DECIMAL(10,2)) > (
    SELECT AVG(TRY_CAST(s2.precio AS DECIMAL(10,2)))
    FROM [dbo].[productos_web] s2
    WHERE s2.categoria = s.categoria
)
ORDER BY s.categoria, Precio DESC;
--===================


-- STRING_AGG: todos los nombres de una categoría en una sola celda (SQL Server 2017+)
SELECT
    categoria,
    STRING_AGG(nombre, N' | ') AS Catalogo
FROM [dbo].[productos_web]
GROUP BY categoria;

--=============================

-- VISTA reutilizable: consolida toda la auditoría del Bloque C en un solo objeto
-- (para no reescribir las 8 consultas cada vez que se recarga STAGE)
CREATE OR ALTER VIEW V_AUDITORIA_STAGE AS
SELECT
    'Nombre NULL o vacio'  AS Problema, COUNT(*) AS Total
    FROM [dbo].[productos_web] WHERE nombre IS NULL OR LTRIM(RTRIM(nombre)) = ''
UNION ALL
SELECT 'Precio NULL', COUNT(*)
    FROM [dbo].[productos_web] WHERE precio IS NULL
UNION ALL
SELECT 'Precio no numerico', COUNT(*)
    FROM [dbo].[productos_web] WHERE precio IS NOT NULL AND TRY_CAST(precio AS DECIMAL(10,2)) IS NULL
UNION ALL
SELECT 'Precio <= 0', COUNT(*)
    FROM [dbo].[productos_web] WHERE TRY_CAST(precio AS DECIMAL(10,2)) <= 0
UNION ALL
SELECT 'Categoria inesperada', COUNT(*)
    FROM [dbo].[productos_web] WHERE categoria NOT IN (N'Travel', N'Mystery', N'Historical Fiction')
UNION ALL
SELECT 'Calificacion fuera de 1-5', COUNT(*)
    FROM [dbo].[productos_web]
    WHERE TRY_CAST(calificacion AS INT) IS NULL OR TRY_CAST(calificacion AS INT) NOT BETWEEN 1 AND 5;
GO

-- Uso: en vez de correr 6 SELECT sueltos, ahora basta
SELECT * FROM V_AUDITORIA_STAGE;
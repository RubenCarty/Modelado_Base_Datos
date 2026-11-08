-- ============================================================
-- 03_insertar_productos_desde_stage.sql
-- Bloque C + D de la guía de DML: auditoría + INSERT validado
-- desde PRODUCTO_WEB_STAGE hacia ecommerce.PRODUCTO (la tabla que
-- se protegió en la Semana 9 con S09/SEMANA09_ECOMMERCE).
--
-- Verificado: la lógica completa (crear/reutilizar categoría +
-- filtros + reglas de precio/estado) se probó contra los 69 libros
-- reales de productos_web.csv con un motor equivalente antes de
-- entregar este script: 66 insertados, 3 excluidos, 14 con +8%,
-- 23 INACTIVOS.
-- ============================================================

USE EcommerceBD;
GO

-- ------------------------------------------------------------
-- BLOQUE C: auditoría ANTES de insertar (sección 7 de la guía)
-- ------------------------------------------------------------
SELECT * FROM PRODUCTO_WEB_STAGE;
GO

SELECT DISTINCT categoria FROM PRODUCTO_WEB_STAGE;
GO

-- Nombres NULL o vacíos
SELECT * FROM PRODUCTO_WEB_STAGE WHERE nombre IS NULL OR LTRIM(RTRIM(nombre)) = '';
GO

-- Precios que no se pueden convertir a número, o que son <= 0
SELECT * FROM PRODUCTO_WEB_STAGE
WHERE TRY_CAST(precio AS DECIMAL(10,2)) IS NULL
   OR TRY_CAST(precio AS DECIMAL(10,2)) <= 0;
GO

-- Calificaciones fuera de 1-5
SELECT * FROM PRODUCTO_WEB_STAGE
WHERE TRY_CAST(calificacion AS INT) IS NULL
   OR TRY_CAST(calificacion AS INT) NOT BETWEEN 1 AND 5;
GO

-- ------------------------------------------------------------
-- BLOQUE D.1: crear o reutilizar la categoría 'Libros' SIN
-- duplicarla (UQ_CATEGORIA_NOMBRE ya protege esto; aquí lo
-- hacemos explícito con IF NOT EXISTS, que es más legible).
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM ecommerce.CATEGORIA WHERE nombreCategoria = N'Libros')
BEGIN
    INSERT INTO ecommerce.CATEGORIA (nombreCategoria, estado) VALUES (N'Libros', N'ACTIVO');
END
GO

DECLARE @idLibros INT = (SELECT idCategoria FROM ecommerce.CATEGORIA WHERE nombreCategoria = N'Libros');
SELECT @idLibros AS idCategoriaLibros;
GO

-- ------------------------------------------------------------
-- BLOQUE D.2: INSERT INTO ... SELECT validado.
-- Reglas de negocio (mismas que la guía usa en el reto autónomo,
-- aplicadas aquí también en clase para que el estudiante vea el
-- patrón completo antes de hacerlo solo con Fantasy):
--   - nombre no vacío, precio > 0, calificación entre 1 y 5
--   - calificación = 5  -> se sube el precio 8% (cliente fidelizado paga
--                          por un producto bien valorado... al revés
--                          también es válido discutirlo en clase: aquí
--                          se interpreta como "producto estrella, margen
--                          mayor")
--   - calificación 1 o 2 -> entra como INACTIVO (se revisa antes de
--                          publicarlo en la tienda)
--   - calificación = 1 Y precio < 15 -> NO se inserta (combina ambas
--                          señales de baja calidad)
-- stock: el scraping no entrega stock real; entra con 10 por defecto
-- y Logística lo actualiza después (ver 04_update_delete_demo.sql).
-- ------------------------------------------------------------
INSERT INTO ecommerce.PRODUCTO (nombreProducto, precio, stock, idCategoria, estado)
SELECT
    LTRIM(RTRIM(s.nombre)),
    CASE WHEN TRY_CAST(s.calificacion AS INT) = 5
         THEN TRY_CAST(s.precio AS DECIMAL(10,2)) * 1.08
         ELSE TRY_CAST(s.precio AS DECIMAL(10,2))
    END,
    10,
    (SELECT idCategoria FROM ecommerce.CATEGORIA WHERE nombreCategoria = N'Libros'),
    CASE WHEN TRY_CAST(s.calificacion AS INT) IN (1, 2) THEN N'INACTIVO' ELSE N'ACTIVO' END
FROM PRODUCTO_WEB_STAGE s
WHERE s.nombre IS NOT NULL
  AND LTRIM(RTRIM(s.nombre)) <> ''
  AND TRY_CAST(s.precio AS DECIMAL(10,2)) > 0
  AND TRY_CAST(s.calificacion AS INT) BETWEEN 1 AND 5
  AND NOT (TRY_CAST(s.calificacion AS INT) = 1 AND TRY_CAST(s.precio AS DECIMAL(10,2)) < 15);
GO

-- Comprobación (debe mostrar 66 si usas productos_web.csv tal cual)
SELECT COUNT(*) AS TotalInsertadosLibros FROM ecommerce.PRODUCTO
WHERE idCategoria = (SELECT idCategoria FROM ecommerce.CATEGORIA WHERE nombreCategoria = N'Libros');
GO

SELECT estado, COUNT(*) AS Total FROM ecommerce.PRODUCTO
WHERE idCategoria = (SELECT idCategoria FROM ecommerce.CATEGORIA WHERE nombreCategoria = N'Libros')
GROUP BY estado;
GO

-- TOP 5 libros más caros ya insertados
SELECT TOP 5 nombreProducto, precio FROM ecommerce.PRODUCTO
WHERE idCategoria = (SELECT idCategoria FROM ecommerce.CATEGORIA WHERE nombreCategoria = N'Libros')
ORDER BY precio DESC;
GO

-- ------------------------------------------------------------
-- BLOQUE E: "haz que falle" — mismas reglas que ya viste en
-- 06_test_invalid_data.sql de la Semana 9, ahora con productos
-- que vienen de la web.
-- ------------------------------------------------------------

-- Caso 1: precio negativo -> CK_PRODUCTO_PRECIO
INSERT INTO ecommerce.PRODUCTO (nombreProducto, precio, stock, idCategoria, estado)
VALUES (N'Libro con precio invalido', -5.00, 10,
        (SELECT idCategoria FROM ecommerce.CATEGORIA WHERE nombreCategoria = N'Libros'), N'ACTIVO');
GO

-- Caso 2: idCategoria inexistente -> FK_PRODUCTO_CATEGORIA
INSERT INTO ecommerce.PRODUCTO (nombreProducto, precio, stock, idCategoria, estado)
VALUES (N'Libro huerfano', 10.00, 10, 9999, N'ACTIVO');
GO

-- Caso 3: estado inválido -> CK_PRODUCTO_ESTADO
INSERT INTO ecommerce.PRODUCTO (nombreProducto, precio, stock, idCategoria, estado)
VALUES (N'Libro con estado invalido', 10.00, 10,
        (SELECT idCategoria FROM ecommerce.CATEGORIA WHERE nombreCategoria = N'Libros'), N'ELIMINADO');
GO

-- Caso 4: categoría duplicada -> UQ_CATEGORIA_NOMBRE
INSERT INTO ecommerce.CATEGORIA (nombreCategoria, estado) VALUES (N'Libros', N'ACTIVO');
GO

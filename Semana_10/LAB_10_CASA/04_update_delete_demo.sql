-- ============================================================
-- 04_update_delete_demo.sql
-- Bloque D.3 (UPDATE) y D.4 (DELETE/TRUNCATE) de la guía de DML.
-- Regla profesional de toda la sección: SELECT BEFORE MODIFY.
-- ============================================================

USE EcommerceBD;
GO

DECLARE @idLibros INT = (SELECT idCategoria FROM ecommerce.CATEGORIA WHERE nombreCategoria = N'Libros');

-- ------------------------------------------------------------
-- UPDATE 1: Logística confirma stock real para los libros ACTIVOS
-- (llegaron con 10 por defecto en 03_insertar_productos_desde_stage.sql)
-- ------------------------------------------------------------

-- Paso 1: SELECT antes (confirmar QUÉ se va a modificar)
SELECT idProducto, nombreProducto, stock, estado FROM ecommerce.PRODUCTO
WHERE idCategoria = @idLibros AND estado = N'ACTIVO';
GO

-- Paso 2: UPDATE con la MISMA condición
UPDATE ecommerce.PRODUCTO
SET stock = stock + 15
WHERE idCategoria = (SELECT idCategoria FROM ecommerce.CATEGORIA WHERE nombreCategoria = N'Libros')
  AND estado = N'ACTIVO';
GO

-- Paso 3: @@ROWCOUNT (filas afectadas por la instrucción anterior)
SELECT @@ROWCOUNT AS FilasActualizadas;
GO

-- Paso 4: SELECT de comprobación
SELECT idProducto, nombreProducto, stock, estado FROM ecommerce.PRODUCTO
WHERE idCategoria = (SELECT idCategoria FROM ecommerce.CATEGORIA WHERE nombreCategoria = N'Libros')
  AND estado = N'ACTIVO';
GO

-- ------------------------------------------------------------
-- UPDATE 2: baja lógica. Marketing decide retirar temporalmente
-- de la tienda los libros más baratos (precio < 12), sin borrarlos.
-- ------------------------------------------------------------
SELECT idProducto, nombreProducto, precio, estado FROM ecommerce.PRODUCTO
WHERE idCategoria = (SELECT idCategoria FROM ecommerce.CATEGORIA WHERE nombreCategoria = N'Libros')
  AND precio < 12 AND estado = N'ACTIVO';
GO

UPDATE ecommerce.PRODUCTO
SET estado = N'INACTIVO'
WHERE idCategoria = (SELECT idCategoria FROM ecommerce.CATEGORIA WHERE nombreCategoria = N'Libros')
  AND precio < 12 AND estado = N'ACTIVO';
GO

SELECT @@ROWCOUNT AS FilasActualizadas;
GO

-- PREDICE antes de ejecutar esto: ¿qué pasaría si se te olvida el WHERE?
-- (NO lo ejecutes en producción: UPDATE ecommerce.PRODUCTO SET estado = 'INACTIVO';
--  modificaría TODA la tabla, incluidos productos de otras categorías)

-- ------------------------------------------------------------
-- DELETE: Marketing pide borrar un libro de prueba que insertaste
-- manualmente (reemplaza 'Libro con precio invalido' por el nombre
-- real si decides sí probar insertarlo sin el CHECK, o usa cualquier
-- fila de prueba que hayas creado).
-- ------------------------------------------------------------
SELECT idProducto, nombreProducto FROM ecommerce.PRODUCTO
WHERE nombreProducto LIKE N'%prueba%';
GO

DELETE FROM ecommerce.PRODUCTO WHERE nombreProducto LIKE N'%prueba%';
GO

SELECT @@ROWCOUNT AS FilasEliminadas;
GO

-- PIENSA: ¿por qué SÍ puedes borrar un libro de prueba sin historial,
-- pero NO podrías borrar un producto que ya aparece en
-- ecommerce.DETALLE_PEDIDO? Pruébalo con cualquier idProducto 1-5
-- (los que insertó 05_test_valid_data.sql de la Semana 9):
DELETE FROM ecommerce.PRODUCTO WHERE idProducto = 1;
-- Error esperado: conflicto con FK_DETALLE_PRODUCTO (el producto 1
-- tiene una fila en DETALLE_PEDIDO). Alternativa correcta: UPDATE
-- estado = 'INACTIVO' en vez de DELETE.
GO

-- ------------------------------------------------------------
-- TRUNCATE: solo sobre STAGE, nunca sobre PRODUCTO.
-- ------------------------------------------------------------
TRUNCATE TABLE PRODUCTO_WEB_STAGE;
GO
-- Esto SÍ funciona: STAGE no tiene FK que la protejan y ya cumplió
-- su función (sus datos válidos ya están en ecommerce.PRODUCTO).

-- Si alguien intenta esto, SQL Server lo rechaza (FK_DETALLE_PRODUCTO /
-- FK_PRODUCTO_CATEGORIA referencian la tabla):
-- TRUNCATE TABLE ecommerce.PRODUCTO;

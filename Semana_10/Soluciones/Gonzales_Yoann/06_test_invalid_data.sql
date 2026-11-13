
-- 06_test_invalid_data.sql
-- OBJETIVO ("HAZ QUE FALLE"): Intentar insertar 8 registros
-- incorrectos, uno por uno, y comprobar que SQL Server los rechaza.


USE EcommerceBD;
GO

-- ============================================================
-- INTENTO 1 — Precio negativo
-- CONSTRAINT QUE LO DETIENE: CK_PRODUCTO_PRECIO (precio > 0)
-- ============================================================
INSERT INTO ecommerce.PRODUCTO (nombreProducto, precio, stock, idCategoria, estado)
VALUES ('Producto con precio inválido', -50.00, 10, 1, 'ACTIVO');
GO

-- ============================================================
-- INTENTO 2 — Stock negativo
-- CONSTRAINT QUE LO DETIENE: CK_PRODUCTO_STOCK (stock >= 0)
-- ============================================================
INSERT INTO ecommerce.PRODUCTO (nombreProducto, precio, stock, idCategoria, estado)
VALUES ('Producto con stock inválido', 50.00, -5, 1, 'ACTIVO');
GO

-- ============================================================
-- INTENTO 3 — Email duplicado
-- CONSTRAINT QUE LO DETIENE: UQ_CLIENTE_EMAIL
-- ============================================================
INSERT INTO ecommerce.CLIENTE (nombres, apellidos, email, telefono, fechaRegistro, estado)
VALUES ('Pedro', 'Gómez', 'ana.torres@correo.com', '987000111', '2024-06-01', 'ACTIVO');
GO

-- ============================================================
-- INTENTO 4 — Email NULL
-- CONSTRAINT QUE LO DETIENE: NOT NULL sobre columna email
-- ============================================================
INSERT INTO ecommerce.CLIENTE (nombres, apellidos, email, telefono, fechaRegistro, estado)
VALUES ('Rosa', 'Díaz', NULL, '987000112', '2024-06-01', 'ACTIVO');
GO

-- ============================================================
-- INTENTO 5 — idCliente inexistente en PEDIDO
-- CONSTRAINT QUE LO DETIENE: FK_PEDIDO_CLIENTE
-- ============================================================
INSERT INTO ecommerce.PEDIDO (idCliente, fechaPedido, estadoPedido, total)
VALUES (9999, '2024-06-01', 'PENDIENTE', 100.00);
GO

-- ============================================================
-- INTENTO 6 — idCategoria inexistente en PRODUCTO
-- CONSTRAINT QUE LO DETIENE: FK_PRODUCTO_CATEGORIA
-- ============================================================
INSERT INTO ecommerce.PRODUCTO (nombreProducto, precio, stock, idCategoria, estado)
VALUES ('Producto huérfano', 50.00, 10, 9999, 'ACTIVO');
GO

-- ============================================================
-- INTENTO 7 — Cantidad cero en DETALLE_PEDIDO
-- CONSTRAINT QUE LO DETIENE: CK_DETALLE_CANTIDAD (cantidad > 0)
-- ============================================================
INSERT INTO ecommerce.DETALLE_PEDIDO (idPedido, idProducto, cantidad, precioUnitario, subtotal)
VALUES (1, 2, 0, 2899.00, 0.00);
GO

-- ============================================================
-- INTENTO 8 — Duplicar el mismo producto en el mismo pedido
-- CONSTRAINT QUE LO DETIENE: PK_DETALLE_PEDIDO (idPedido, idProducto)
-- ============================================================
INSERT INTO ecommerce.DETALLE_PEDIDO (idPedido, idProducto, cantidad, precioUnitario, subtotal)
VALUES (1, 1, 5, 129.90, 649.50);
GO

-- ============================================================
-- COMPROBACIÓN FINAL (Sección 11 de la Guía)
-- Ninguno de los registros incorrectos debe existir en la BD.
-- ============================================================

SELECT * FROM ecommerce.PRODUCTO WHERE nombreProducto IN
    ('Producto con precio inválido','Producto con stock inválido','Producto huérfano');
-- Debe devolver 0 filas.

SELECT * FROM ecommerce.CLIENTE WHERE nombres IN ('Pedro','Rosa');
-- Debe devolver 0 filas.

SELECT * FROM ecommerce.PEDIDO WHERE idCliente = 9999;
-- Debe devolver 0 filas.

SELECT * FROM ecommerce.DETALLE_PEDIDO WHERE idPedido = 1 AND idProducto = 2;
-- Debe devolver 0 filas (cantidad cero fue rechazada).

SELECT idPedido, idProducto, cantidad FROM ecommerce.DETALLE_PEDIDO
WHERE idPedido = 1 AND idProducto = 1;
-- Debe devolver EXACTAMENTE 1 fila, con cantidad = 2 (la original válida),
-- confirmando que el intento 8 no se insertó.
GO

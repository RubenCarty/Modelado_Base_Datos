/* ============================================================
   06_test_invalid_data.sql
   OBJETIVO ("HAZ QUE FALLE"): Intentar insertar 8 registros
   incorrectos, uno por uno, y comprobar que SQL Server los
   rechaza gracias a las constraints definidas en 04_constraints.sql.
   Ejecutar cada bloque POR SEPARADO (seleccionar el bloque + F5),
   leer el mensaje de error, y luego pasar al siguiente.
   ============================================================ */

USE EcommerceBD;
GO

/* ============================================================
   INTENTO 1 — Precio negativo
   CONSTRAINT QUE LO DETIENE: CK_PRODUCTO_PRECIO (precio > 0)
   ERROR ESPERADO: "The INSERT statement conflicted with the CHECK
   constraint 'CK_PRODUCTO_PRECIO'."
   EXPLICACIÓN: un producto con precio negativo no tiene sentido de
   negocio; el CHECK lo bloquea antes de tocar el disco.
   ============================================================ */
INSERT INTO ecommerce.PRODUCTO (nombreProducto, precio, stock, idCategoria, estado)
VALUES ('Producto con precio inválido', -50.00, 10, 1, 'ACTIVO');
GO

/* ============================================================
   INTENTO 2 — Stock negativo
   CONSTRAINT QUE LO DETIENE: CK_PRODUCTO_STOCK (stock >= 0)
   ERROR ESPERADO: conflicto con CHECK constraint 'CK_PRODUCTO_STOCK'.
   EXPLICACIÓN: no puede existir stock físico negativo; el CHECK
   protege esta regla aunque la aplicación la olvide validar.
   ============================================================ */
INSERT INTO ecommerce.PRODUCTO (nombreProducto, precio, stock, idCategoria, estado)
VALUES ('Producto con stock inválido', 50.00, -5, 1, 'ACTIVO');
GO

/* ============================================================
   INTENTO 3 — Email duplicado
   CONSTRAINT QUE LO DETIENE: UQ_CLIENTE_EMAIL
   ERROR ESPERADO: "Violation of UNIQUE KEY constraint
   'UQ_CLIENTE_EMAIL'. Cannot insert duplicate key..."
   EXPLICACIÓN: el email es el identificador de contacto/login del
   cliente; permitir duplicados generaría ambigüedad de identidad.
   ============================================================ */
INSERT INTO ecommerce.CLIENTE (nombres, apellidos, email, telefono, fechaRegistro, estado)
VALUES ('Pedro', 'Gómez', 'ana.torres@correo.com', '987000111', '2024-06-01', 'ACTIVO');
GO

/* ============================================================
   INTENTO 4 — Email NULL
   CONSTRAINT QUE LO DETIENE: NOT NULL sobre la columna email
   ERROR ESPERADO: "Cannot insert the value NULL into column
   'email'... does not allow nulls."
   EXPLICACIÓN: un cliente sin email no puede ser contactado ni
   identificado de forma confiable.
   ============================================================ */
INSERT INTO ecommerce.CLIENTE (nombres, apellidos, email, telefono, fechaRegistro, estado)
VALUES ('Rosa', 'Díaz', NULL, '987000112', '2024-06-01', 'ACTIVO');
GO

/* ============================================================
   INTENTO 5 — idCliente inexistente en PEDIDO
   CONSTRAINT QUE LO DETIENE: FK_PEDIDO_CLIENTE
   ERROR ESPERADO: "The INSERT statement conflicted with the
   FOREIGN KEY constraint 'FK_PEDIDO_CLIENTE'."
   EXPLICACIÓN: esta es la respuesta a la pregunta motivadora del
   caso ("¿qué impide un pedido de un cliente inexistente?").
   ============================================================ */
INSERT INTO ecommerce.PEDIDO (idCliente, fechaPedido, estadoPedido, total)
VALUES (9999, '2024-06-01', 'PENDIENTE', 100.00);
GO

/* ============================================================
   INTENTO 6 — idCategoria inexistente en PRODUCTO
   CONSTRAINT QUE LO DETIENE: FK_PRODUCTO_CATEGORIA
   ERROR ESPERADO: conflicto con FOREIGN KEY constraint
   'FK_PRODUCTO_CATEGORIA'.
   EXPLICACIÓN: un producto siempre debe pertenecer a una
   categoría real y existente del catálogo.
   ============================================================ */
INSERT INTO ecommerce.PRODUCTO (nombreProducto, precio, stock, idCategoria, estado)
VALUES ('Producto huérfano', 50.00, 10, 9999, 'ACTIVO');
GO

/* ============================================================
   INTENTO 7 — Cantidad cero/negativa en DETALLE_PEDIDO
   CONSTRAINT QUE LO DETIENE: CK_DETALLE_CANTIDAD (cantidad > 0)
   ERROR ESPERADO: conflicto con CHECK constraint
   'CK_DETALLE_CANTIDAD'.
   EXPLICACIÓN: no existe un pedido de 0 o -3 unidades de un
   producto.
   ============================================================ */
INSERT INTO ecommerce.DETALLE_PEDIDO (idPedido, idProducto, cantidad, precioUnitario, subtotal)
VALUES (1, 2, 0, 2899.00, 0.00);
GO

/* ============================================================
   INTENTO 8 — Duplicar el mismo producto en el mismo pedido
   (violación de la PK COMPUESTA)
   CONSTRAINT QUE LO DETIENE: PK_DETALLE_PEDIDO (idPedido, idProducto)
   ERROR ESPERADO: "Violation of PRIMARY KEY constraint
   'PK_DETALLE_PEDIDO'. Cannot insert duplicate key..."
   EXPLICACIÓN: el pedido 1 ya tiene una línea para el producto 1
   (ver 05_test_valid_data.sql); insertar otra línea idéntica
   duplicaría la clave compuesta. La forma correcta de "agregar
   más cantidad" sería un UPDATE sobre la fila existente, no un
   segundo INSERT.
   ============================================================ */
INSERT INTO ecommerce.DETALLE_PEDIDO (idPedido, idProducto, cantidad, precioUnitario, subtotal)
VALUES (1, 1, 5, 129.90, 649.50);
GO

/* ============================================================
   COMPROBACIÓN FINAL
   Ninguno de los 8 registros incorrectos debe existir en la base.
   ============================================================ */

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
-- Debe devolver EXACTAMENTE 1 fila, con cantidad = 2 (la original de
-- 05_test_valid_data.sql), confirmando que el intento 8 no se sumó.
GO

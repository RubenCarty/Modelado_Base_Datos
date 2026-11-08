-- insertar datos incorrectos para verificar la integridad de la tablas
--EL PRECIO NO PUEDE SER NEGATIVO
INSERT INTO ecommerce.PRODUCTO(nombreProducto, precio, stock, idCategoria, estado)
VALUES ('Producto con precio inválido', -50.00, 10, 1, 'ACTIVO');

--EL NUMERO DE STOCK NO PUEDE SER NEGATIVO
INSERT INTO ecommerce.PRODUCTO(nombreProducto, precio, stock, idCategoria, estado)
VALUES ('producto con stock invalido', 50.00,-5,1,'ACTIVO');

--email duplicados
INSERT INTO ecommerce.CLIENTE(nombres, apellidos, email, telefono, fechaRegistro, estado)
VALUES ('Pedro', 'Gomez','ana.torres@correo.com','987000111', '2024-06-01', 'ACTIVO');

--email null
INSERT INTO ecommerce.CLIENTE (nombres, apellidos, email, telefono, fechaRegistro, estado)
VALUES ('Rosa', 'Díaz', NULL, '987000112', '2024-06-01', 'ACTIVO');

--EL IDCLIENTE INEXISTENTE EN PEDIDO
INSERT INTO ecommerce.PEDIDO (idCliente, fechaPedido, estadoPeddido, total)
VALUES (9999, '2024-06-01', 'PENDIENTE', 100.00);

--IDCATEGORIA INEXISTENTE EN PRODCUTO
INSERT INTO ecommerce.PRODUCTO(nombreProducto, precio, stock, idCategoria, estado)
VALUES ('Producto huérfano', 50.00, 10, 9999, 'ACTIVO');

--CANTIDAD CERO EN DETALLE_PEDIDO
INSERT INTO ecommerce.DETALLE_PEDIDO(IDPEDIDO, IDPRODUCTO, CANTIDAD, PRECIOUNITARIO, SUBTOTAL)
VALUES (1,2,0,2899.00,0.00);

--DUPLICAR EL MISMO PRODUCTO EN EL MISMO PEDIDO
INSERT INTO ecommerce.DETALLE_PEDIDO(idPedido, idProducto, cantidad, precioUnitario, subtotal)
VALUES (1,1,5,129.90,649.50);

-- 05_test_valid_data.sql
-- OBJETIVO: Insertar datos 100% válidos de prueba


USE EcommerceBD;
GO

-- ------------------------------------------------------------
-- 1. CATEGORIA
-- ------------------------------------------------------------
INSERT INTO ecommerce.CATEGORIA (nombreCategoria, estado) VALUES
('Electrodomésticos', 'ACTIVO'),
('Cómputo',          'ACTIVO'),
('Celulares',        'ACTIVO'),
('Hogar',            'ACTIVO'),
('Deportes',         'ACTIVO');
GO

-- ------------------------------------------------------------
-- 2. CLIENTE
-- ------------------------------------------------------------
INSERT INTO ecommerce.CLIENTE (nombres, apellidos, email, telefono, fechaRegistro, estado) VALUES
('Ana',    'Torres',   'ana.torres@correo.com',   '987654321', '2024-01-10', 'ACTIVO'),
('Luis',   'Ramírez',  'luis.ramirez@correo.com', '987654322', '2024-02-15', 'ACTIVO'),
('Marta',  'Quispe',   'marta.quispe@correo.com', '987654323', '2024-03-05', 'ACTIVO'),
('Carlos', 'Fernández','carlos.fernandez@correo.com', '987654324', '2024-04-20', 'ACTIVO');
GO

-- ------------------------------------------------------------
-- 3. PRODUCTO
-- ------------------------------------------------------------
INSERT INTO ecommerce.PRODUCTO (nombreProducto, precio, stock, idCategoria, estado) VALUES
('Licuadora 700W',        129.90, 50, 1, 'ACTIVO'),
('Laptop 14" i5',        2899.00, 15, 2, 'ACTIVO'),
('Smartphone 128GB',      999.00, 30, 3, 'ACTIVO'),
('Juego de sábanas',       89.90, 40, 4, 'ACTIVO'),
('Balón de fútbol N°5',    59.90, 60, 5, 'ACTIVO');
GO

-- ------------------------------------------------------------
-- 4. PEDIDO
-- ------------------------------------------------------------
INSERT INTO ecommerce.PEDIDO (idCliente, fechaPedido, estadoPedido, total) VALUES
(1, '2024-05-01', 'PAGADO', 259.80),
(2, '2024-05-02', 'PENDIENTE', 2899.00);
GO

-- ------------------------------------------------------------
-- 5. DETALLE_PEDIDO
-- ------------------------------------------------------------
INSERT INTO ecommerce.DETALLE_PEDIDO (idPedido, idProducto, cantidad, precioUnitario, subtotal) VALUES
(1, 1, 2, 129.90, 259.80),
(2, 2, 1, 2899.00, 2899.00);
GO

-- ------------------------------------------------------------
-- VERIFICACION DE DATOS INSERTADOS
-- ------------------------------------------------------------
SELECT * FROM ecommerce.CATEGORIA;
SELECT * FROM ecommerce.CLIENTE;
SELECT * FROM ecommerce.PRODUCTO;
SELECT * FROM ecommerce.PEDIDO;
SELECT * FROM ecommerce.DETALLE_PEDIDO;
GO

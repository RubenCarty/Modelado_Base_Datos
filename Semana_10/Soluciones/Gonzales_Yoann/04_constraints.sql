
-- 04_constraints.sql
-- OBJETIVO: Agregar FK, UNIQUE, CHECK y DEFAULT

USE EcommerceBD;
GO

-- ------------------------------------------------------------
-- CLIENTE
-- ------------------------------------------------------------
-- No permitir emails duplicados
ALTER TABLE ecommerce.CLIENTE
    ADD CONSTRAINT UQ_CLIENTE_EMAIL UNIQUE (email);
GO

-- Valor por defecto en estado
ALTER TABLE ecommerce.CLIENTE
    ADD CONSTRAINT DF_CLIENTE_ESTADO DEFAULT ('ACTIVO') FOR estado;
GO

-- Estados permitidos
ALTER TABLE ecommerce.CLIENTE
    ADD CONSTRAINT CK_CLIENTE_ESTADO
        CHECK (estado IN ('ACTIVO', 'INACTIVO'));
GO

-- ------------------------------------------------------------
-- CATEGORIA
-- ------------------------------------------------------------
-- Nombre de categoría único
ALTER TABLE ecommerce.CATEGORIA
    ADD CONSTRAINT UQ_CATEGORIA_NOMBRE UNIQUE (nombreCategoria);
GO

-- Valor por defecto en estado
ALTER TABLE ecommerce.CATEGORIA
    ADD CONSTRAINT DF_CATEGORIA_ESTADO DEFAULT ('ACTIVO') FOR estado;
GO

-- Estados permitidos
ALTER TABLE ecommerce.CATEGORIA
    ADD CONSTRAINT CK_CATEGORIA_ESTADO
        CHECK (estado IN ('ACTIVO', 'INACTIVO'));
GO

-- ------------------------------------------------------------
-- PRODUCTO
-- ------------------------------------------------------------
-- Integridad referencial con CATEGORIA
ALTER TABLE ecommerce.PRODUCTO
    ADD CONSTRAINT FK_PRODUCTO_CATEGORIA
        FOREIGN KEY (idCategoria) REFERENCES ecommerce.CATEGORIA(idCategoria);
GO

-- Precio estrictamente positivo
ALTER TABLE ecommerce.PRODUCTO
    ADD CONSTRAINT CK_PRODUCTO_PRECIO CHECK (precio > 0);
GO

-- Stock no negativo
ALTER TABLE ecommerce.PRODUCTO
    ADD CONSTRAINT CK_PRODUCTO_STOCK CHECK (stock >= 0);
GO

-- Stock por defecto en 0
ALTER TABLE ecommerce.PRODUCTO
    ADD CONSTRAINT DF_PRODUCTO_STOCK DEFAULT (0) FOR stock;
GO

-- Estado por defecto ACTIVO
ALTER TABLE ecommerce.PRODUCTO
    ADD CONSTRAINT DF_PRODUCTO_ESTADO DEFAULT ('ACTIVO') FOR estado;
GO

-- Estados permitidos
ALTER TABLE ecommerce.PRODUCTO
    ADD CONSTRAINT CK_PRODUCTO_ESTADO
        CHECK (estado IN ('ACTIVO', 'INACTIVO'));
GO

-- ------------------------------------------------------------
-- PEDIDO
-- ------------------------------------------------------------
-- Integridad referencial con CLIENTE
ALTER TABLE ecommerce.PEDIDO
    ADD CONSTRAINT FK_PEDIDO_CLIENTE
        FOREIGN KEY (idCliente) REFERENCES ecommerce.CLIENTE(idCliente);
GO

-- Estados permitidos para pedido
ALTER TABLE ecommerce.PEDIDO
    ADD CONSTRAINT CK_PEDIDO_ESTADO
        CHECK (estadoPedido IN ('PENDIENTE','PAGADO','ENVIADO','ENTREGADO','CANCELADO'));
GO

-- Estado de pedido por defecto PENDIENTE
ALTER TABLE ecommerce.PEDIDO
    ADD CONSTRAINT DF_PEDIDO_ESTADO DEFAULT ('PENDIENTE') FOR estadoPedido;
GO

-- Fecha de pedido por defecto fecha actual
ALTER TABLE ecommerce.PEDIDO
    ADD CONSTRAINT DF_PEDIDO_FECHA DEFAULT (CAST(GETDATE() AS DATE)) FOR fechaPedido;
GO

-- El total no debe ser negativo
ALTER TABLE ecommerce.PEDIDO
    ADD CONSTRAINT CK_PEDIDO_TOTAL CHECK (total >= 0);
GO

-- ------------------------------------------------------------
-- DETALLE_PEDIDO
-- ------------------------------------------------------------
-- Integridad referencial con PEDIDO
ALTER TABLE ecommerce.DETALLE_PEDIDO
    ADD CONSTRAINT FK_DETALLE_PEDIDO
        FOREIGN KEY (idPedido) REFERENCES ecommerce.PEDIDO(idPedido);
GO

-- Integridad referencial con PRODUCTO
ALTER TABLE ecommerce.DETALLE_PEDIDO
    ADD CONSTRAINT FK_DETALLE_PRODUCTO
        FOREIGN KEY (idProducto) REFERENCES ecommerce.PRODUCTO(idProducto);
GO

-- Cantidad estrictamente positiva
ALTER TABLE ecommerce.DETALLE_PEDIDO
    ADD CONSTRAINT CK_DETALLE_CANTIDAD CHECK (cantidad > 0);
GO

-- Precio unitario estrictamente positivo
ALTER TABLE ecommerce.DETALLE_PEDIDO
    ADD CONSTRAINT CK_DETALLE_PRECIO CHECK (precioUnitario > 0);
GO

-- Subtotal no negativo
ALTER TABLE ecommerce.DETALLE_PEDIDO
    ADD CONSTRAINT CK_DETALLE_SUBTOTAL CHECK (subtotal >= 0);
GO

-- ------------------------------------------------------------
-- VERIFICACIÓN DE CONSTRAINTS EN ESQUEMA ECOMMERCE
-- ------------------------------------------------------------
SELECT name, type_desc 
FROM sys.objects
WHERE type IN ('F','UQ','C','D') AND schema_id = SCHEMA_ID('ecommerce')
ORDER BY type_desc, name;
GO

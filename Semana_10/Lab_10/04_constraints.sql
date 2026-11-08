/* ============================================================
   04_constraints.sql
   OBJETIVO: Convertir cada regla de negocio del caso en una
   restricción física de la base de datos: FOREIGN KEY, UNIQUE,
   CHECK y DEFAULT. Cada bloque indica, en comentario, qué regla
   de negocio (1-13) está resolviendo.
   ============================================================ */

USE EcommerceBD;
GO

/* ---------------- CLIENTE ---------------- */

-- Regla 3: no se permiten emails duplicados.
ALTER TABLE ecommerce.CLIENTE
    ADD CONSTRAINT UQ_CLIENTE_EMAIL UNIQUE (email);
GO

-- Regla 1 y 2 (nombre y email) ya quedaron resueltas con NOT NULL
-- en 03_create_tables.sql: un cliente sin nombre o sin email no
-- puede insertarse. Aquí solo reforzamos con DEFAULT el estado.
ALTER TABLE ecommerce.CLIENTE
    ADD CONSTRAINT DF_CLIENTE_ESTADO DEFAULT ('ACTIVO') FOR estado;
GO

ALTER TABLE ecommerce.CLIENTE
    ADD CONSTRAINT CK_CLIENTE_ESTADO
        CHECK (estado IN ('ACTIVO', 'INACTIVO'));
GO

/* ---------------- CATEGORIA ---------------- */

ALTER TABLE ecommerce.CATEGORIA
    ADD CONSTRAINT UQ_CATEGORIA_NOMBRE UNIQUE (nombreCategoria);
GO

ALTER TABLE ecommerce.CATEGORIA
    ADD CONSTRAINT DF_CATEGORIA_ESTADO DEFAULT ('ACTIVO') FOR estado;
GO

ALTER TABLE ecommerce.CATEGORIA
    ADD CONSTRAINT CK_CATEGORIA_ESTADO
        CHECK (estado IN ('ACTIVO', 'INACTIVO'));
GO

/* ---------------- PRODUCTO ---------------- */

-- Regla 7: un producto no puede pertenecer a una categoría
-- inexistente.
ALTER TABLE ecommerce.PRODUCTO
    ADD CONSTRAINT FK_PRODUCTO_CATEGORIA
        FOREIGN KEY (idCategoria) REFERENCES ecommerce.CATEGORIA(idCategoria);
GO

-- Regla 5: precio <= 0 no puede almacenarse.
ALTER TABLE ecommerce.PRODUCTO
    ADD CONSTRAINT CK_PRODUCTO_PRECIO CHECK (precio > 0);
GO

-- Regla 6: stock negativo no puede almacenarse.
ALTER TABLE ecommerce.PRODUCTO
    ADD CONSTRAINT CK_PRODUCTO_STOCK CHECK (stock >= 0);
GO

ALTER TABLE ecommerce.PRODUCTO
    ADD CONSTRAINT DF_PRODUCTO_STOCK DEFAULT (0) FOR stock;
GO

ALTER TABLE ecommerce.PRODUCTO
    ADD CONSTRAINT DF_PRODUCTO_ESTADO DEFAULT ('ACTIVO') FOR estado;
GO

ALTER TABLE ecommerce.PRODUCTO
    ADD CONSTRAINT CK_PRODUCTO_ESTADO
        CHECK (estado IN ('ACTIVO', 'INACTIVO'));
GO

/* ---------------- PEDIDO ---------------- */

-- Regla 8: un pedido no puede pertenecer a un cliente inexistente.
-- Esta es la respuesta a la pregunta estilo entrevista técnica del
-- caso: "¿Qué implementarías para impedir un pedido con cliente
-- inexistente?" -> Respuesta: FOREIGN KEY.
ALTER TABLE ecommerce.PEDIDO
    ADD CONSTRAINT FK_PEDIDO_CLIENTE
        FOREIGN KEY (idCliente) REFERENCES ecommerce.CLIENTE(idCliente);
GO

-- Regla 12: estados de pedido fuera del dominio permitido.
ALTER TABLE ecommerce.PEDIDO
    ADD CONSTRAINT CK_PEDIDO_ESTADO
        CHECK (estadoPedido IN ('PENDIENTE','PAGADO','ENVIADO','ENTREGADO','CANCELADO'));
GO

ALTER TABLE ecommerce.PEDIDO
    ADD CONSTRAINT DF_PEDIDO_ESTADO DEFAULT ('PENDIENTE') FOR estadoPedido;
GO

ALTER TABLE ecommerce.PEDIDO
    ADD CONSTRAINT DF_PEDIDO_FECHA DEFAULT (CAST(GETDATE() AS DATE)) FOR fechaPedido;
GO

-- El total no debe ser negativo.
ALTER TABLE ecommerce.PEDIDO
    ADD CONSTRAINT CK_PEDIDO_TOTAL CHECK (total >= 0);
GO

/* ---------------- DETALLE_PEDIDO ---------------- */

-- Regla 9: un detalle no puede pertenecer a un pedido inexistente.
ALTER TABLE ecommerce.DETALLE_PEDIDO
    ADD CONSTRAINT FK_DETALLE_PEDIDO
        FOREIGN KEY (idPedido) REFERENCES ecommerce.PEDIDO(idPedido);
GO

-- Regla 10: un detalle no puede referenciar un producto inexistente.
ALTER TABLE ecommerce.DETALLE_PEDIDO
    ADD CONSTRAINT FK_DETALLE_PRODUCTO
        FOREIGN KEY (idProducto) REFERENCES ecommerce.PRODUCTO(idProducto);
GO

-- Regla 11: cantidad <= 0 no puede almacenarse.
ALTER TABLE ecommerce.DETALLE_PEDIDO
    ADD CONSTRAINT CK_DETALLE_CANTIDAD CHECK (cantidad > 0);
GO

ALTER TABLE ecommerce.DETALLE_PEDIDO
    ADD CONSTRAINT CK_DETALLE_PRECIO CHECK (precioUnitario > 0);
GO

ALTER TABLE ecommerce.DETALLE_PEDIDO
    ADD CONSTRAINT CK_DETALLE_SUBTOTAL CHECK (subtotal >= 0);
GO

/* ------------------------------------------------------------
   QUÉ HACE
   - Agrega, con ALTER TABLE ... ADD CONSTRAINT, todas las FK,
     UNIQUE, CHECK y DEFAULT que faltaban.
   - Cada constraint tiene nombre explícito (PK_, FK_, UQ_, CK_,
     DF_) siguiendo una convención profesional: esto es clave
     para que, cuando un INSERT falle, el mensaje de error de SQL
     Server sea legible ("The INSERT statement conflicted with the
     CHECK constraint 'CK_PRODUCTO_PRECIO'") en vez de un nombre
     autogenerado ilegible.

   RESULTADO ESPERADO
   - Las 13 reglas de negocio del caso quedan cubiertas por al
     menos una restricción física.

   CÓMO VALIDARLO
   SELECT name, type_desc FROM sys.objects
   WHERE type IN ('F','UQ','C','D') AND schema_id = SCHEMA_ID('ecommerce')
   ORDER BY type_desc, name;
   ------------------------------------------------------------ */

SELECT name, type_desc
FROM sys.objects
WHERE type IN ('F','UQ','C','D') AND schema_id = SCHEMA_ID('ecommerce')
ORDER BY type_desc, name;
GO

/* ============================================================
   03_create_tables.sql
   OBJETIVO: Crear la estructura física de las 5 tablas del caso,
   con tipos de datos, PRIMARY KEY y NOT NULL. Las FK, UNIQUE,
   CHECK y DEFAULT se agregan a propósito en 04_constraints.sql,
   para que el estudiante vea que DDL no es "todo de una vez":
   primero se define la forma de los datos, luego se blindan las
   reglas de negocio.
   ============================================================ */

USE EcommerceBD;
GO

/* ---------- CATEGORIA (sin FK, va primero) ---------- */
CREATE TABLE ecommerce.CATEGORIA (
    idCategoria     INT             IDENTITY(1,1) NOT NULL,
    nombreCategoria VARCHAR(80)     NOT NULL,
    estado          VARCHAR(10)     NOT NULL,
    CONSTRAINT PK_CATEGORIA PRIMARY KEY (idCategoria)
);
GO

/* ---------- CLIENTE ---------- */
CREATE TABLE ecommerce.CLIENTE (
    idCliente       INT             IDENTITY(1,1) NOT NULL,
    nombres         VARCHAR(80)     NOT NULL,
    apellidos       VARCHAR(80)     NOT NULL,
    email           VARCHAR(120)    NOT NULL,
    telefono        VARCHAR(20)     NULL,
    fechaRegistro   DATE            NOT NULL,
    estado          VARCHAR(10)     NOT NULL,
    CONSTRAINT PK_CLIENTE PRIMARY KEY (idCliente)
);
GO

/* ---------- PRODUCTO (referencia a CATEGORIA) ---------- */
CREATE TABLE ecommerce.PRODUCTO (
    idProducto      INT             IDENTITY(1,1) NOT NULL,
    nombreProducto  VARCHAR(120)    NOT NULL,
    precio          DECIMAL(10,2)   NOT NULL,
    stock           INT             NOT NULL,
    idCategoria     INT             NOT NULL,
    estado          VARCHAR(10)     NOT NULL,
    CONSTRAINT PK_PRODUCTO PRIMARY KEY (idProducto)
);
GO

/* ---------- PEDIDO (referencia a CLIENTE) ---------- */
CREATE TABLE ecommerce.PEDIDO (
    idPedido        INT             IDENTITY(1,1) NOT NULL,
    idCliente       INT             NOT NULL,
    fechaPedido     DATE            NOT NULL,
    estadoPedido    VARCHAR(20)     NOT NULL,
    total           DECIMAL(10,2)   NOT NULL,
    CONSTRAINT PK_PEDIDO PRIMARY KEY (idPedido)
);
GO

/* ---------- DETALLE_PEDIDO (PK COMPUESTA) ---------- */
CREATE TABLE ecommerce.DETALLE_PEDIDO (
    idPedido        INT             NOT NULL,
    idProducto      INT             NOT NULL,
    cantidad        INT             NOT NULL,
    precioUnitario  DECIMAL(10,2)   NOT NULL,
    subtotal        DECIMAL(10,2)   NOT NULL,
    CONSTRAINT PK_DETALLE_PEDIDO PRIMARY KEY (idPedido, idProducto)
);
GO

/* ------------------------------------------------------------
   QUÉ HACE
   - Crea las 5 tablas del modelo dentro del esquema ecommerce.
   - Define tipos de datos apropiados para cada atributo:
     INT para identificadores y cantidades, VARCHAR para texto,
     DECIMAL(10,2) para dinero (nunca FLOAT, por precisión),
     DATE para fechas.
   - IDENTITY(1,1) autogenera los idCliente/idProducto/etc.,
     evitando que el estudiante tenga que inventar IDs a mano.
   - DETALLE_PEDIDO usa una CLAVE PRIMARIA COMPUESTA
     (idPedido, idProducto): esto, por sí solo, ya impide que el
     mismo producto se repita dos veces dentro del mismo pedido
     (regla de negocio #13).
   - Todavía NO existen las FOREIGN KEY: por eso en este momento
     sería posible insertar un PRODUCTO con idCategoria = 999
     aunque esa categoría no exista. Eso se corrige en el
     siguiente script y es precisamente el punto pedagógico.

   RESULTADO ESPERADO
   - 5 tablas visibles en EcommerceBD → ecommerce.* (Object Explorer).

   CÓMO VALIDARLO
   SELECT TABLE_SCHEMA, TABLE_NAME
   FROM INFORMATION_SCHEMA.TABLES
   WHERE TABLE_SCHEMA = 'ecommerce'
   ORDER BY TABLE_NAME;
   ------------------------------------------------------------ */

SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'ecommerce'
ORDER BY TABLE_NAME;
GO

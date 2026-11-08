--CREACION DE TABLAS
--TABLA DE CATEGORIA
CREATE TABLE ecommerce.CATEGORIA (
    idCategoria     INT             IDENTITY(1,1) NOT NULL,
    nombreCategoria VARCHAR(80)     NOT NULL,
    estado          VARCHAR(10)     NOT NULL,
    CONSTRAINT PK_CATEGORIA PRIMARY KEY (idCategoria)
);

--TABLA DE CLIENTE
CREATE TABLE ecommerce.CLIENTE(
    idCliente     INT IDENTITY (1,1) NOT NULL,
    nombres       VARCHAR(80)        NOT NULL,
    apellidos     VARCHAR(80)        NOT NULL,
    email         VARCHAR(120)       NOT NULL,
    telefono      VARCHAR(20)        NULL,
    fechaRegistro DATE               NOT NULL,
    estado        VARCHAR(10)        NOT NULL,
    CONSTRAINT PK_CLIENTE PRIMARY KEY (idCliente)
);

--TABLA DE PRODUCTO
CREATE TABLE ecommerce.PRODUCTO (
    idProducto  INT IDENTITY (1,1) NOT NULL,
    nombreProducto VARCHAR(120) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL ,
    idCategoria INT NOT NULL ,
    estado VARCHAR(10) NOT NULL ,
    CONSTRAINT PK_PRODUCTO PRIMARY KEY (idProducto)
);

--TABLA DE PEDIDO
CREATE TABLE ecommerce.PEDIDO(
  idPedido INT IDENTITY (1,1) NOT NULL ,
  idCliente INT NOT NULL ,
  fechaPedido DATE NOT NULL ,
  estadoPeddido VARCHAR(20) NOT NULL ,
  total DECIMAL(10,2) NOT NULL ,
  CONSTRAINT PK_PEDIDO PRIMARY KEY (idPedido)
);

--TABLA DETALLE_PEDIDO
CREATE TABLE ecommerce.DETALLE_PEDIDO (
    idPedido        INT             NOT NULL,
    idProducto      INT             NOT NULL,
    cantidad        INT             NOT NULL,
    precioUnitario  DECIMAL(10,2)   NOT NULL,
    subtotal        DECIMAL(10,2)   NOT NULL,
    CONSTRAINT PK_DETALLE_PEDIDO PRIMARY KEY (idPedido, idProducto)
);

--VERIFICAR CREACION DE TABLAS EN SCHEME ECOMMERCE
SELECT TABLE_SCHEMA, TABLE_NAME
        FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA='ecommerce'
ORDER BY TABLE_NAME;

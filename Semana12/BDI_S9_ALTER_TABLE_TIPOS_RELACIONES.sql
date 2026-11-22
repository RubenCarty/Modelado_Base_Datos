/* BASES DE DATOS I - SEMANA 9 - MARKETPLACE 360
   POSTIMPORTACION MANUAL DE 10 CSV - SOLO TIPOS, PK, FK Y VALIDACION.
   PRIMERO: importar los 10 CSV con el asistente de SSMS a dbo.TABLA.
   ESTE ARCHIVO NO CREA TABLAS, NO IMPORTA CSV Y NO BORRA DATOS.
   IMPORTANTE: si un valor no se puede convertir, corrija el CSV o el dato
   importado antes de ejecutar nuevamente. Haga una copia de seguridad.
   Si el asistente creo columnas con otros nombres, renombrelas primero.
*/
USE BD_MARKETPLACE_S9;
GO
SET NOCOUNT ON;
GO
-- PASO 1. Comprobar que existen las 10 tablas y sus columnas.

IF OBJECT_ID(N'dbo.CATEGORIA', N'U') IS NULL THROW 51001, 'Falta tabla dbo.CATEGORIA. Importe el CSV primero.', 1;
IF COL_LENGTH(N'dbo.CATEGORIA', N'IDCategoria') IS NULL THROW 51002, 'Falta columna CATEGORIA.IDCategoria. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.CATEGORIA', N'NombreCategoria') IS NULL THROW 51002, 'Falta columna CATEGORIA.NombreCategoria. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.CATEGORIA', N'Descripcion') IS NULL THROW 51002, 'Falta columna CATEGORIA.Descripcion. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.CATEGORIA', N'Activo') IS NULL THROW 51002, 'Falta columna CATEGORIA.Activo. Revise el asistente de importacion.', 1;
IF OBJECT_ID(N'dbo.MARCA', N'U') IS NULL THROW 51001, 'Falta tabla dbo.MARCA. Importe el CSV primero.', 1;
IF COL_LENGTH(N'dbo.MARCA', N'IDMarca') IS NULL THROW 51002, 'Falta columna MARCA.IDMarca. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.MARCA', N'NombreMarca') IS NULL THROW 51002, 'Falta columna MARCA.NombreMarca. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.MARCA', N'PaisOrigen') IS NULL THROW 51002, 'Falta columna MARCA.PaisOrigen. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.MARCA', N'Activo') IS NULL THROW 51002, 'Falta columna MARCA.Activo. Revise el asistente de importacion.', 1;
IF OBJECT_ID(N'dbo.TIENDA', N'U') IS NULL THROW 51001, 'Falta tabla dbo.TIENDA. Importe el CSV primero.', 1;
IF COL_LENGTH(N'dbo.TIENDA', N'IDTienda') IS NULL THROW 51002, 'Falta columna TIENDA.IDTienda. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.TIENDA', N'NombreTienda') IS NULL THROW 51002, 'Falta columna TIENDA.NombreTienda. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.TIENDA', N'Ciudad') IS NULL THROW 51002, 'Falta columna TIENDA.Ciudad. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.TIENDA', N'Distrito') IS NULL THROW 51002, 'Falta columna TIENDA.Distrito. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.TIENDA', N'Direccion') IS NULL THROW 51002, 'Falta columna TIENDA.Direccion. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.TIENDA', N'TipoTienda') IS NULL THROW 51002, 'Falta columna TIENDA.TipoTienda. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.TIENDA', N'Activo') IS NULL THROW 51002, 'Falta columna TIENDA.Activo. Revise el asistente de importacion.', 1;
IF OBJECT_ID(N'dbo.PRODUCTO', N'U') IS NULL THROW 51001, 'Falta tabla dbo.PRODUCTO. Importe el CSV primero.', 1;
IF COL_LENGTH(N'dbo.PRODUCTO', N'IDProducto') IS NULL THROW 51002, 'Falta columna PRODUCTO.IDProducto. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PRODUCTO', N'NombreProducto') IS NULL THROW 51002, 'Falta columna PRODUCTO.NombreProducto. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PRODUCTO', N'IDCategoria') IS NULL THROW 51002, 'Falta columna PRODUCTO.IDCategoria. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PRODUCTO', N'IDMarca') IS NULL THROW 51002, 'Falta columna PRODUCTO.IDMarca. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PRODUCTO', N'Descripcion') IS NULL THROW 51002, 'Falta columna PRODUCTO.Descripcion. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PRODUCTO', N'SKU') IS NULL THROW 51002, 'Falta columna PRODUCTO.SKU. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PRODUCTO', N'Color') IS NULL THROW 51002, 'Falta columna PRODUCTO.Color. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PRODUCTO', N'Costo') IS NULL THROW 51002, 'Falta columna PRODUCTO.Costo. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PRODUCTO', N'PrecioLista') IS NULL THROW 51002, 'Falta columna PRODUCTO.PrecioLista. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PRODUCTO', N'StockGeneral') IS NULL THROW 51002, 'Falta columna PRODUCTO.StockGeneral. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PRODUCTO', N'FechaAlta') IS NULL THROW 51002, 'Falta columna PRODUCTO.FechaAlta. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PRODUCTO', N'Activo') IS NULL THROW 51002, 'Falta columna PRODUCTO.Activo. Revise el asistente de importacion.', 1;
IF OBJECT_ID(N'dbo.PRECIO_TIENDA', N'U') IS NULL THROW 51001, 'Falta tabla dbo.PRECIO_TIENDA. Importe el CSV primero.', 1;
IF COL_LENGTH(N'dbo.PRECIO_TIENDA', N'IDPrecioTienda') IS NULL THROW 51002, 'Falta columna PRECIO_TIENDA.IDPrecioTienda. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PRECIO_TIENDA', N'IDProducto') IS NULL THROW 51002, 'Falta columna PRECIO_TIENDA.IDProducto. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PRECIO_TIENDA', N'IDTienda') IS NULL THROW 51002, 'Falta columna PRECIO_TIENDA.IDTienda. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PRECIO_TIENDA', N'Precio') IS NULL THROW 51002, 'Falta columna PRECIO_TIENDA.Precio. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PRECIO_TIENDA', N'StockTienda') IS NULL THROW 51002, 'Falta columna PRECIO_TIENDA.StockTienda. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PRECIO_TIENDA', N'FechaActualizacion') IS NULL THROW 51002, 'Falta columna PRECIO_TIENDA.FechaActualizacion. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PRECIO_TIENDA', N'TipoPrecio') IS NULL THROW 51002, 'Falta columna PRECIO_TIENDA.TipoPrecio. Revise el asistente de importacion.', 1;
IF OBJECT_ID(N'dbo.CLIENTE', N'U') IS NULL THROW 51001, 'Falta tabla dbo.CLIENTE. Importe el CSV primero.', 1;
IF COL_LENGTH(N'dbo.CLIENTE', N'IDCliente') IS NULL THROW 51002, 'Falta columna CLIENTE.IDCliente. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.CLIENTE', N'Nombre') IS NULL THROW 51002, 'Falta columna CLIENTE.Nombre. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.CLIENTE', N'Apellido') IS NULL THROW 51002, 'Falta columna CLIENTE.Apellido. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.CLIENTE', N'Correo') IS NULL THROW 51002, 'Falta columna CLIENTE.Correo. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.CLIENTE', N'Telefono') IS NULL THROW 51002, 'Falta columna CLIENTE.Telefono. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.CLIENTE', N'Ciudad') IS NULL THROW 51002, 'Falta columna CLIENTE.Ciudad. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.CLIENTE', N'Distrito') IS NULL THROW 51002, 'Falta columna CLIENTE.Distrito. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.CLIENTE', N'FechaRegistro') IS NULL THROW 51002, 'Falta columna CLIENTE.FechaRegistro. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.CLIENTE', N'Segmento') IS NULL THROW 51002, 'Falta columna CLIENTE.Segmento. Revise el asistente de importacion.', 1;
IF OBJECT_ID(N'dbo.PEDIDO', N'U') IS NULL THROW 51001, 'Falta tabla dbo.PEDIDO. Importe el CSV primero.', 1;
IF COL_LENGTH(N'dbo.PEDIDO', N'IDPedido') IS NULL THROW 51002, 'Falta columna PEDIDO.IDPedido. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PEDIDO', N'IDCliente') IS NULL THROW 51002, 'Falta columna PEDIDO.IDCliente. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PEDIDO', N'IDTienda') IS NULL THROW 51002, 'Falta columna PEDIDO.IDTienda. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PEDIDO', N'FechaPedido') IS NULL THROW 51002, 'Falta columna PEDIDO.FechaPedido. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PEDIDO', N'Estado') IS NULL THROW 51002, 'Falta columna PEDIDO.Estado. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PEDIDO', N'MetodoPago') IS NULL THROW 51002, 'Falta columna PEDIDO.MetodoPago. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PEDIDO', N'CanalVenta') IS NULL THROW 51002, 'Falta columna PEDIDO.CanalVenta. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.PEDIDO', N'CiudadEntrega') IS NULL THROW 51002, 'Falta columna PEDIDO.CiudadEntrega. Revise el asistente de importacion.', 1;
IF OBJECT_ID(N'dbo.DETALLE_PEDIDO', N'U') IS NULL THROW 51001, 'Falta tabla dbo.DETALLE_PEDIDO. Importe el CSV primero.', 1;
IF COL_LENGTH(N'dbo.DETALLE_PEDIDO', N'IDDetallePedido') IS NULL THROW 51002, 'Falta columna DETALLE_PEDIDO.IDDetallePedido. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.DETALLE_PEDIDO', N'IDPedido') IS NULL THROW 51002, 'Falta columna DETALLE_PEDIDO.IDPedido. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.DETALLE_PEDIDO', N'IDProducto') IS NULL THROW 51002, 'Falta columna DETALLE_PEDIDO.IDProducto. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.DETALLE_PEDIDO', N'Cantidad') IS NULL THROW 51002, 'Falta columna DETALLE_PEDIDO.Cantidad. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.DETALLE_PEDIDO', N'PrecioUnitario') IS NULL THROW 51002, 'Falta columna DETALLE_PEDIDO.PrecioUnitario. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.DETALLE_PEDIDO', N'Descuento') IS NULL THROW 51002, 'Falta columna DETALLE_PEDIDO.Descuento. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.DETALLE_PEDIDO', N'Subtotal') IS NULL THROW 51002, 'Falta columna DETALLE_PEDIDO.Subtotal. Revise el asistente de importacion.', 1;
IF OBJECT_ID(N'dbo.CATALOGO_WEB', N'U') IS NULL THROW 51001, 'Falta tabla dbo.CATALOGO_WEB. Importe el CSV primero.', 1;
IF COL_LENGTH(N'dbo.CATALOGO_WEB', N'Codigo') IS NULL THROW 51002, 'Falta columna CATALOGO_WEB.Codigo. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.CATALOGO_WEB', N'Descripcion') IS NULL THROW 51002, 'Falta columna CATALOGO_WEB.Descripcion. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.CATALOGO_WEB', N'EstadoWeb') IS NULL THROW 51002, 'Falta columna CATALOGO_WEB.EstadoWeb. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.CATALOGO_WEB', N'PrecioWeb') IS NULL THROW 51002, 'Falta columna CATALOGO_WEB.PrecioWeb. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.CATALOGO_WEB', N'FechaPublicacion') IS NULL THROW 51002, 'Falta columna CATALOGO_WEB.FechaPublicacion. Revise el asistente de importacion.', 1;
IF OBJECT_ID(N'dbo.CATALOGO_ERP', N'U') IS NULL THROW 51001, 'Falta tabla dbo.CATALOGO_ERP. Importe el CSV primero.', 1;
IF COL_LENGTH(N'dbo.CATALOGO_ERP', N'Codigo') IS NULL THROW 51002, 'Falta columna CATALOGO_ERP.Codigo. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.CATALOGO_ERP', N'Descripcion') IS NULL THROW 51002, 'Falta columna CATALOGO_ERP.Descripcion. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.CATALOGO_ERP', N'EstadoERP') IS NULL THROW 51002, 'Falta columna CATALOGO_ERP.EstadoERP. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.CATALOGO_ERP', N'StockERP') IS NULL THROW 51002, 'Falta columna CATALOGO_ERP.StockERP. Revise el asistente de importacion.', 1;
IF COL_LENGTH(N'dbo.CATALOGO_ERP', N'FechaRegistro') IS NULL THROW 51002, 'Falta columna CATALOGO_ERP.FechaRegistro. Revise el asistente de importacion.', 1;
GO
-- PASO 2. Convertir tipos de columnas importadas.
-- Si aparece error de conversion, revise formatos (fechas ISO yyyy-mm-dd; decimales con punto).

-- CATEGORIA
ALTER TABLE dbo.[CATEGORIA] ALTER COLUMN [IDCategoria] INT NOT NULL;
ALTER TABLE dbo.[CATEGORIA] ALTER COLUMN [NombreCategoria] NVARCHAR(120) NOT NULL;
ALTER TABLE dbo.[CATEGORIA] ALTER COLUMN [Descripcion] NVARCHAR(300) NULL;
ALTER TABLE dbo.[CATEGORIA] ALTER COLUMN [Activo] BIT NOT NULL;
GO

-- MARCA
ALTER TABLE dbo.[MARCA] ALTER COLUMN [IDMarca] INT NOT NULL;
ALTER TABLE dbo.[MARCA] ALTER COLUMN [NombreMarca] NVARCHAR(120) NOT NULL;
ALTER TABLE dbo.[MARCA] ALTER COLUMN [PaisOrigen] NVARCHAR(100) NULL;
ALTER TABLE dbo.[MARCA] ALTER COLUMN [Activo] BIT NOT NULL;
GO

-- TIENDA
ALTER TABLE dbo.[TIENDA] ALTER COLUMN [IDTienda] INT NOT NULL;
ALTER TABLE dbo.[TIENDA] ALTER COLUMN [NombreTienda] NVARCHAR(150) NOT NULL;
ALTER TABLE dbo.[TIENDA] ALTER COLUMN [Ciudad] NVARCHAR(100) NULL;
ALTER TABLE dbo.[TIENDA] ALTER COLUMN [Distrito] NVARCHAR(100) NULL;
ALTER TABLE dbo.[TIENDA] ALTER COLUMN [Direccion] NVARCHAR(200) NULL;
ALTER TABLE dbo.[TIENDA] ALTER COLUMN [TipoTienda] NVARCHAR(100) NULL;
ALTER TABLE dbo.[TIENDA] ALTER COLUMN [Activo] BIT NOT NULL;
GO

-- PRODUCTO
ALTER TABLE dbo.[PRODUCTO] ALTER COLUMN [IDProducto] INT NOT NULL;
ALTER TABLE dbo.[PRODUCTO] ALTER COLUMN [NombreProducto] NVARCHAR(180) NOT NULL;
ALTER TABLE dbo.[PRODUCTO] ALTER COLUMN [IDCategoria] INT NOT NULL;
ALTER TABLE dbo.[PRODUCTO] ALTER COLUMN [IDMarca] INT NOT NULL;
ALTER TABLE dbo.[PRODUCTO] ALTER COLUMN [Descripcion] NVARCHAR(400) NULL;
ALTER TABLE dbo.[PRODUCTO] ALTER COLUMN [SKU] VARCHAR(40) NOT NULL;
ALTER TABLE dbo.[PRODUCTO] ALTER COLUMN [Color] NVARCHAR(60) NULL;
ALTER TABLE dbo.[PRODUCTO] ALTER COLUMN [Costo] DECIMAL(12,2) NOT NULL;
ALTER TABLE dbo.[PRODUCTO] ALTER COLUMN [PrecioLista] DECIMAL(12,2) NOT NULL;
ALTER TABLE dbo.[PRODUCTO] ALTER COLUMN [StockGeneral] INT NOT NULL;
ALTER TABLE dbo.[PRODUCTO] ALTER COLUMN [FechaAlta] DATE NOT NULL;
ALTER TABLE dbo.[PRODUCTO] ALTER COLUMN [Activo] BIT NOT NULL;
GO

-- PRECIO_TIENDA
ALTER TABLE dbo.[PRECIO_TIENDA] ALTER COLUMN [IDPrecioTienda] INT NOT NULL;
ALTER TABLE dbo.[PRECIO_TIENDA] ALTER COLUMN [IDProducto] INT NOT NULL;
ALTER TABLE dbo.[PRECIO_TIENDA] ALTER COLUMN [IDTienda] INT NOT NULL;
ALTER TABLE dbo.[PRECIO_TIENDA] ALTER COLUMN [Precio] DECIMAL(12,2) NOT NULL;
ALTER TABLE dbo.[PRECIO_TIENDA] ALTER COLUMN [StockTienda] INT NOT NULL;
ALTER TABLE dbo.[PRECIO_TIENDA] ALTER COLUMN [FechaActualizacion] DATE NOT NULL;
ALTER TABLE dbo.[PRECIO_TIENDA] ALTER COLUMN [TipoPrecio] NVARCHAR(60) NULL;
GO

-- CLIENTE
ALTER TABLE dbo.[CLIENTE] ALTER COLUMN [IDCliente] INT NOT NULL;
ALTER TABLE dbo.[CLIENTE] ALTER COLUMN [Nombre] NVARCHAR(100) NOT NULL;
ALTER TABLE dbo.[CLIENTE] ALTER COLUMN [Apellido] NVARCHAR(100) NOT NULL;
ALTER TABLE dbo.[CLIENTE] ALTER COLUMN [Correo] VARCHAR(200) NULL;
ALTER TABLE dbo.[CLIENTE] ALTER COLUMN [Telefono] VARCHAR(30) NULL;
ALTER TABLE dbo.[CLIENTE] ALTER COLUMN [Ciudad] NVARCHAR(100) NULL;
ALTER TABLE dbo.[CLIENTE] ALTER COLUMN [Distrito] NVARCHAR(100) NULL;
ALTER TABLE dbo.[CLIENTE] ALTER COLUMN [FechaRegistro] DATE NOT NULL;
ALTER TABLE dbo.[CLIENTE] ALTER COLUMN [Segmento] NVARCHAR(80) NULL;
GO

-- PEDIDO
ALTER TABLE dbo.[PEDIDO] ALTER COLUMN [IDPedido] INT NOT NULL;
ALTER TABLE dbo.[PEDIDO] ALTER COLUMN [IDCliente] INT NOT NULL;
ALTER TABLE dbo.[PEDIDO] ALTER COLUMN [IDTienda] INT NOT NULL;
ALTER TABLE dbo.[PEDIDO] ALTER COLUMN [FechaPedido] DATE NOT NULL;
ALTER TABLE dbo.[PEDIDO] ALTER COLUMN [Estado] NVARCHAR(60) NOT NULL;
ALTER TABLE dbo.[PEDIDO] ALTER COLUMN [MetodoPago] NVARCHAR(60) NULL;
ALTER TABLE dbo.[PEDIDO] ALTER COLUMN [CanalVenta] NVARCHAR(60) NULL;
ALTER TABLE dbo.[PEDIDO] ALTER COLUMN [CiudadEntrega] NVARCHAR(100) NULL;
GO

-- DETALLE_PEDIDO
ALTER TABLE dbo.[DETALLE_PEDIDO] ALTER COLUMN [IDDetallePedido] INT NOT NULL;
ALTER TABLE dbo.[DETALLE_PEDIDO] ALTER COLUMN [IDPedido] INT NOT NULL;
ALTER TABLE dbo.[DETALLE_PEDIDO] ALTER COLUMN [IDProducto] INT NOT NULL;
ALTER TABLE dbo.[DETALLE_PEDIDO] ALTER COLUMN [Cantidad] INT NOT NULL;
ALTER TABLE dbo.[DETALLE_PEDIDO] ALTER COLUMN [PrecioUnitario] DECIMAL(12,2) NOT NULL;
ALTER TABLE dbo.[DETALLE_PEDIDO] ALTER COLUMN [Descuento] DECIMAL(12,2) NOT NULL;
ALTER TABLE dbo.[DETALLE_PEDIDO] ALTER COLUMN [Subtotal] DECIMAL(14,2) NOT NULL;
GO

-- CATALOGO_WEB
ALTER TABLE dbo.[CATALOGO_WEB] ALTER COLUMN [Codigo] VARCHAR(40) NOT NULL;
ALTER TABLE dbo.[CATALOGO_WEB] ALTER COLUMN [Descripcion] NVARCHAR(200) NULL;
ALTER TABLE dbo.[CATALOGO_WEB] ALTER COLUMN [EstadoWeb] NVARCHAR(60) NULL;
ALTER TABLE dbo.[CATALOGO_WEB] ALTER COLUMN [PrecioWeb] DECIMAL(12,2) NULL;
ALTER TABLE dbo.[CATALOGO_WEB] ALTER COLUMN [FechaPublicacion] DATE NULL;
GO

-- CATALOGO_ERP
ALTER TABLE dbo.[CATALOGO_ERP] ALTER COLUMN [Codigo] VARCHAR(40) NOT NULL;
ALTER TABLE dbo.[CATALOGO_ERP] ALTER COLUMN [Descripcion] NVARCHAR(200) NULL;
ALTER TABLE dbo.[CATALOGO_ERP] ALTER COLUMN [EstadoERP] NVARCHAR(60) NULL;
ALTER TABLE dbo.[CATALOGO_ERP] ALTER COLUMN [StockERP] INT NULL;
ALTER TABLE dbo.[CATALOGO_ERP] ALTER COLUMN [FechaRegistro] DATE NULL;
GO

-- PASO 3. Crear claves primarias (solo cuando aun no existan).
-- Las PK exigen IDs unicos y sin NULL. Si falla, revisar duplicados.

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.CATEGORIA') AND type = 'PK')
    ALTER TABLE dbo.[CATEGORIA] ADD CONSTRAINT [PK_CATEGORIA] PRIMARY KEY ([IDCategoria]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.MARCA') AND type = 'PK')
    ALTER TABLE dbo.[MARCA] ADD CONSTRAINT [PK_MARCA] PRIMARY KEY ([IDMarca]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.TIENDA') AND type = 'PK')
    ALTER TABLE dbo.[TIENDA] ADD CONSTRAINT [PK_TIENDA] PRIMARY KEY ([IDTienda]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.PRODUCTO') AND type = 'PK')
    ALTER TABLE dbo.[PRODUCTO] ADD CONSTRAINT [PK_PRODUCTO] PRIMARY KEY ([IDProducto]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.PRECIO_TIENDA') AND type = 'PK')
    ALTER TABLE dbo.[PRECIO_TIENDA] ADD CONSTRAINT [PK_PRECIO_TIENDA] PRIMARY KEY ([IDPrecioTienda]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.CLIENTE') AND type = 'PK')
    ALTER TABLE dbo.[CLIENTE] ADD CONSTRAINT [PK_CLIENTE] PRIMARY KEY ([IDCliente]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.PEDIDO') AND type = 'PK')
    ALTER TABLE dbo.[PEDIDO] ADD CONSTRAINT [PK_PEDIDO] PRIMARY KEY ([IDPedido]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.DETALLE_PEDIDO') AND type = 'PK')
    ALTER TABLE dbo.[DETALLE_PEDIDO] ADD CONSTRAINT [PK_DETALLE_PEDIDO] PRIMARY KEY ([IDDetallePedido]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.CATALOGO_WEB') AND type = 'PK')
    ALTER TABLE dbo.[CATALOGO_WEB] ADD CONSTRAINT [PK_CATALOGO_WEB] PRIMARY KEY ([Codigo]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.CATALOGO_ERP') AND type = 'PK')
    ALTER TABLE dbo.[CATALOGO_ERP] ADD CONSTRAINT [PK_CATALOGO_ERP] PRIMARY KEY ([Codigo]);
GO

-- PASO 4. Crear las ocho relaciones 1:N, sin duplicarlas al reejecutar.
-- Si falla una FK, revisar los ID de ambas tablas y corregir datos.

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PRODUCTO_CATEGORIA' AND parent_object_id = OBJECT_ID(N'dbo.PRODUCTO'))
    ALTER TABLE dbo.[PRODUCTO] WITH CHECK ADD CONSTRAINT [FK_PRODUCTO_CATEGORIA] FOREIGN KEY ([IDCategoria]) REFERENCES dbo.[CATEGORIA]([IDCategoria]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PRODUCTO_MARCA' AND parent_object_id = OBJECT_ID(N'dbo.PRODUCTO'))
    ALTER TABLE dbo.[PRODUCTO] WITH CHECK ADD CONSTRAINT [FK_PRODUCTO_MARCA] FOREIGN KEY ([IDMarca]) REFERENCES dbo.[MARCA]([IDMarca]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PRECIO_TIENDA_PRODUCTO' AND parent_object_id = OBJECT_ID(N'dbo.PRECIO_TIENDA'))
    ALTER TABLE dbo.[PRECIO_TIENDA] WITH CHECK ADD CONSTRAINT [FK_PRECIO_TIENDA_PRODUCTO] FOREIGN KEY ([IDProducto]) REFERENCES dbo.[PRODUCTO]([IDProducto]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PRECIO_TIENDA_TIENDA' AND parent_object_id = OBJECT_ID(N'dbo.PRECIO_TIENDA'))
    ALTER TABLE dbo.[PRECIO_TIENDA] WITH CHECK ADD CONSTRAINT [FK_PRECIO_TIENDA_TIENDA] FOREIGN KEY ([IDTienda]) REFERENCES dbo.[TIENDA]([IDTienda]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PEDIDO_CLIENTE' AND parent_object_id = OBJECT_ID(N'dbo.PEDIDO'))
    ALTER TABLE dbo.[PEDIDO] WITH CHECK ADD CONSTRAINT [FK_PEDIDO_CLIENTE] FOREIGN KEY ([IDCliente]) REFERENCES dbo.[CLIENTE]([IDCliente]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PEDIDO_TIENDA' AND parent_object_id = OBJECT_ID(N'dbo.PEDIDO'))
    ALTER TABLE dbo.[PEDIDO] WITH CHECK ADD CONSTRAINT [FK_PEDIDO_TIENDA] FOREIGN KEY ([IDTienda]) REFERENCES dbo.[TIENDA]([IDTienda]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_DETALLE_PEDIDO_PEDIDO' AND parent_object_id = OBJECT_ID(N'dbo.DETALLE_PEDIDO'))
    ALTER TABLE dbo.[DETALLE_PEDIDO] WITH CHECK ADD CONSTRAINT [FK_DETALLE_PEDIDO_PEDIDO] FOREIGN KEY ([IDPedido]) REFERENCES dbo.[PEDIDO]([IDPedido]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_DETALLE_PEDIDO_PRODUCTO' AND parent_object_id = OBJECT_ID(N'dbo.DETALLE_PEDIDO'))
    ALTER TABLE dbo.[DETALLE_PEDIDO] WITH CHECK ADD CONSTRAINT [FK_DETALLE_PEDIDO_PRODUCTO] FOREIGN KEY ([IDProducto]) REFERENCES dbo.[PRODUCTO]([IDProducto]);
GO

-- PASO 5. Validar volumen de las diez tablas (sin resolver tickets).
SELECT N'CATEGORIA' AS Tabla, COUNT_BIG(*) AS Filas FROM dbo.CATEGORIA
UNION ALL SELECT N'MARCA', COUNT_BIG(*) FROM dbo.MARCA
UNION ALL SELECT N'TIENDA', COUNT_BIG(*) FROM dbo.TIENDA
UNION ALL SELECT N'PRODUCTO', COUNT_BIG(*) FROM dbo.PRODUCTO
UNION ALL SELECT N'PRECIO_TIENDA', COUNT_BIG(*) FROM dbo.PRECIO_TIENDA
UNION ALL SELECT N'CLIENTE', COUNT_BIG(*) FROM dbo.CLIENTE
UNION ALL SELECT N'PEDIDO', COUNT_BIG(*) FROM dbo.PEDIDO
UNION ALL SELECT N'DETALLE_PEDIDO', COUNT_BIG(*) FROM dbo.DETALLE_PEDIDO
UNION ALL SELECT N'CATALOGO_WEB', COUNT_BIG(*) FROM dbo.CATALOGO_WEB
UNION ALL SELECT N'CATALOGO_ERP', COUNT_BIG(*) FROM dbo.CATALOGO_ERP;
GO
-- PASO 6. Revisar columnas y tipos finales.
SELECT TABLE_NAME AS Tabla, COLUMN_NAME AS Columna, DATA_TYPE AS Tipo,
       CHARACTER_MAXIMUM_LENGTH AS Longitud, NUMERIC_PRECISION AS Precision,
       NUMERIC_SCALE AS Escala, IS_NULLABLE AS PermiteNulos
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME IN ('CATEGORIA','MARCA','TIENDA','PRODUCTO','PRECIO_TIENDA',
                     'CLIENTE','PEDIDO','DETALLE_PEDIDO','CATALOGO_WEB','CATALOGO_ERP')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
GO
-- PASO 7. Comprobar que las ocho relaciones estan registradas.
SELECT fk.name AS Relacion, OBJECT_NAME(fk.parent_object_id) AS TablaHija,
       OBJECT_NAME(fk.referenced_object_id) AS TablaPadre
FROM sys.foreign_keys AS fk
WHERE fk.parent_object_id IN
    (OBJECT_ID('dbo.PRODUCTO'),OBJECT_ID('dbo.PRECIO_TIENDA'),
     OBJECT_ID('dbo.PEDIDO'),OBJECT_ID('dbo.DETALLE_PEDIDO'))
ORDER BY TablaHija, Relacion;
GO
PRINT N'Preparacion estructural finalizada. Continuar con los tickets de la Semana 9.';
GO

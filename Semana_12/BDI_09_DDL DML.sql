/* ============================================================================
   UTP | BASES DE DATOS I | SEMANA 9
   MARKETPLACE 360 - CREACION E IMPORTACION DE 10 TABLAS
   Requisito: motor SQL Server 2019/2022 instalado en Windows (no Docker).

   PASOS DEL ESTUDIANTE:
   1. Ejecuta el notebook Python y descarga los 10 archivos CSV.
   2. Crea la carpeta C:\MARKETPLACE_S9_10_TABLAS_CSV\
   3. Copia DIRECTAMENTE los 10 archivos .csv en esa carpeta.
      Ejemplo: C:\MARKETPLACE_S9_10_TABLAS_CSV\CATEGORIA.csv
   4. Abre SSMS conectado a tu SQL Server de Windows.
   5. Ejecuta ESTE ARCHIVO COMPLETO una sola vez (F5).
   6. Comprueba que las 10 tablas tengan filas.

   ATENCION: REEJECUTAR ESTE ARCHIVO ELIMINA LAS 10 TABLAS Y SUS DATOS.
   Los archivos CSV deben coincidir con los generados por el notebook.
   El servicio de SQL Server necesita permiso de lectura sobre la carpeta.
   Si el motor esta en otro equipo, la ruta debe existir EN ESE SERVIDOR.
   ============================================================================ */

-- PASO 0. Comprobar plataforma: debe indicar Windows.
SELECT CONVERT(NVARCHAR(100), SERVERPROPERTY('HostPlatform')) AS PlataformaSQL,
       CONVERT(NVARCHAR(128), SERVERPROPERTY('ServerName')) AS NombreServidor;
GO

-- PASO 1. Crear y seleccionar la base.
USE master;
GO
IF DB_ID(N'BD_MARKETPLACE_S9') IS NULL
    CREATE DATABASE BD_MARKETPLACE_S9;
GO
USE BD_MARKETPLACE_S9;
GO
SET NOCOUNT ON;
GO

-- PASO 2. Recrear tablas de laboratorio. ADVERTENCIA: BORRA DATOS PREVIOS.
DROP TABLE IF EXISTS dbo.DETALLE_PEDIDO;
DROP TABLE IF EXISTS dbo.PRECIO_TIENDA;
DROP TABLE IF EXISTS dbo.PEDIDO;
DROP TABLE IF EXISTS dbo.CATALOGO_WEB;
DROP TABLE IF EXISTS dbo.CATALOGO_ERP;
DROP TABLE IF EXISTS dbo.PRODUCTO;
DROP TABLE IF EXISTS dbo.CLIENTE;
DROP TABLE IF EXISTS dbo.TIENDA;
DROP TABLE IF EXISTS dbo.MARCA;
DROP TABLE IF EXISTS dbo.CATEGORIA;
GO

CREATE TABLE dbo.CATEGORIA (
    IDCategoria INT NOT NULL PRIMARY KEY,
    NombreCategoria NVARCHAR(120) NOT NULL,
    Descripcion NVARCHAR(300) NULL,
    Activo BIT NOT NULL
);
CREATE TABLE dbo.MARCA (
    IDMarca INT NOT NULL PRIMARY KEY,
    NombreMarca NVARCHAR(120) NOT NULL,
    PaisOrigen NVARCHAR(100) NULL,
    Activo BIT NOT NULL
);
CREATE TABLE dbo.TIENDA (
    IDTienda INT NOT NULL PRIMARY KEY,
    NombreTienda NVARCHAR(150) NOT NULL,
    Ciudad NVARCHAR(100) NULL,
    Distrito NVARCHAR(100) NULL,
    Direccion NVARCHAR(200) NULL,
    TipoTienda NVARCHAR(100) NULL,
    Activo BIT NOT NULL
);
CREATE TABLE dbo.PRODUCTO (
    IDProducto INT NOT NULL PRIMARY KEY,
    NombreProducto NVARCHAR(180) NOT NULL,
    IDCategoria INT NOT NULL,
    IDMarca INT NOT NULL,
    Descripcion NVARCHAR(400) NULL,
    SKU VARCHAR(40) NOT NULL,
    Color NVARCHAR(60) NULL,
    Costo DECIMAL(12,2) NOT NULL,
    PrecioLista DECIMAL(12,2) NOT NULL,
    StockGeneral INT NOT NULL,
    FechaAlta DATE NOT NULL,
    Activo BIT NOT NULL
);
CREATE TABLE dbo.PRECIO_TIENDA (
    IDPrecioTienda INT NOT NULL PRIMARY KEY,
    IDProducto INT NOT NULL,
    IDTienda INT NOT NULL,
    Precio DECIMAL(12,2) NOT NULL,
    StockTienda INT NOT NULL,
    FechaActualizacion DATE NOT NULL,
    TipoPrecio NVARCHAR(60) NULL
);
CREATE TABLE dbo.CLIENTE (
    IDCliente INT NOT NULL PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    Apellido NVARCHAR(100) NOT NULL,
    Correo VARCHAR(200) NULL,
    Telefono VARCHAR(30) NULL,
    Ciudad NVARCHAR(100) NULL,
    Distrito NVARCHAR(100) NULL,
    FechaRegistro DATE NOT NULL,
    Segmento NVARCHAR(80) NULL
);
CREATE TABLE dbo.PEDIDO (
    IDPedido INT NOT NULL PRIMARY KEY,
    IDCliente INT NOT NULL,
    IDTienda INT NOT NULL,
    FechaPedido DATE NOT NULL,
    Estado NVARCHAR(60) NOT NULL,
    MetodoPago NVARCHAR(60) NULL,
    CanalVenta NVARCHAR(60) NULL,
    CiudadEntrega NVARCHAR(100) NULL
);
CREATE TABLE dbo.DETALLE_PEDIDO (
    IDDetallePedido INT NOT NULL PRIMARY KEY,
    IDPedido INT NOT NULL,
    IDProducto INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(12,2) NOT NULL,
    Descuento DECIMAL(12,2) NOT NULL,
    Subtotal DECIMAL(14,2) NOT NULL
);
CREATE TABLE dbo.CATALOGO_WEB (
    Codigo VARCHAR(40) NOT NULL PRIMARY KEY,
    Descripcion NVARCHAR(200) NULL,
    EstadoWeb NVARCHAR(60) NULL,
    PrecioWeb DECIMAL(12,2) NULL,
    FechaPublicacion DATE NULL
);
CREATE TABLE dbo.CATALOGO_ERP (
    Codigo VARCHAR(40) NOT NULL PRIMARY KEY,
    Descripcion NVARCHAR(200) NULL,
    EstadoERP NVARCHAR(60) NULL,
    StockERP INT NULL,
    FechaRegistro DATE NULL
);
GO

-- PASO 3. Cargar 10 CSV en orden. No cambiar salvo que la carpeta sea distinta.
-- SQL Server en WINDOWS lee desde el disco del equipo donde corre el MOTOR.
-- FORMAT CSV + FIELDQUOTE admiten campos con comas entre comillas.
-- CODEPAGE 65001 permite leer UTF-8 en SQL Server sobre Windows.
DECLARE @Ruta NVARCHAR(4000) = N'C:\MARKETPLACE_S9_10_TABLAS_CSV\';
DECLARE @Tabla SYSNAME, @Archivo NVARCHAR(4000), @SQL NVARCHAR(MAX);
DECLARE @Carga TABLE (Orden INT PRIMARY KEY, Tabla SYSNAME);
INSERT INTO @Carga (Orden, Tabla) VALUES
    (1,N'CATEGORIA'), (2,N'MARCA'), (3,N'TIENDA'),
    (4,N'PRODUCTO'), (5,N'PRECIO_TIENDA'), (6,N'CLIENTE'),
    (7,N'PEDIDO'), (8,N'DETALLE_PEDIDO'),
    (9,N'CATALOGO_WEB'), (10,N'CATALOGO_ERP');

DECLARE c CURSOR LOCAL FAST_FORWARD FOR
    SELECT Tabla FROM @Carga ORDER BY Orden;

BEGIN TRY
    BEGIN TRANSACTION;
    OPEN c;
    FETCH NEXT FROM c INTO @Tabla;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Archivo = @Ruta + @Tabla + N'.csv';
        SET @SQL = N'BULK INSERT dbo.' + QUOTENAME(@Tabla)
                 + N' FROM N''' + REPLACE(@Archivo, N'''', N'''''') + N''' '
                 + N'WITH (FORMAT = ''CSV'', FIRSTROW = 2, FIELDQUOTE = ''"'', '
                 + N'CODEPAGE = ''65001'', TABLOCK);';
        PRINT N'Importando: ' + @Archivo;
        EXEC sys.sp_executesql @SQL;
        PRINT N'OK: ' + @Tabla;
        FETCH NEXT FROM c INTO @Tabla;
    END;
    CLOSE c;
    DEALLOCATE c;
    COMMIT TRANSACTION;
    PRINT N'IMPORTACION COMPLETA: 10 archivos procesados.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    IF CURSOR_STATUS('local', 'c') >= 0 CLOSE c;
    IF CURSOR_STATUS('local', 'c') >= -1 DEALLOCATE c;
    PRINT N'ERROR EN LA IMPORTACION. Revisa la carpeta, permisos y el CSV indicado.';
    THROW;
END CATCH;
GO

-- PASO 4. Crear relaciones solo si todas las tablas se cargaron.
-- Si la importacion fallo, corregir el error y volver a ejecutar TODO el script.
IF NOT EXISTS (SELECT 1 FROM dbo.CATEGORIA)
    THROW 51001, 'CATEGORIA esta vacia: no se crearan relaciones. Revisa la importacion.', 1;
IF NOT EXISTS (SELECT 1 FROM dbo.PRODUCTO)
    THROW 51002, 'PRODUCTO esta vacia: no se crearan relaciones. Revisa la importacion.', 1;
IF NOT EXISTS (SELECT 1 FROM dbo.DETALLE_PEDIDO)
    THROW 51003, 'DETALLE_PEDIDO esta vacia: no se crearan relaciones. Revisa la importacion.', 1;
GO
ALTER TABLE dbo.PRODUCTO ADD CONSTRAINT FK_PRODUCTO_CATEGORIA
    FOREIGN KEY (IDCategoria) REFERENCES dbo.CATEGORIA(IDCategoria);
ALTER TABLE dbo.PRODUCTO ADD CONSTRAINT FK_PRODUCTO_MARCA
    FOREIGN KEY (IDMarca) REFERENCES dbo.MARCA(IDMarca);
ALTER TABLE dbo.PRECIO_TIENDA ADD CONSTRAINT FK_PRECIO_PRODUCTO
    FOREIGN KEY (IDProducto) REFERENCES dbo.PRODUCTO(IDProducto);
ALTER TABLE dbo.PRECIO_TIENDA ADD CONSTRAINT FK_PRECIO_TIENDA
    FOREIGN KEY (IDTienda) REFERENCES dbo.TIENDA(IDTienda);
ALTER TABLE dbo.PEDIDO ADD CONSTRAINT FK_PEDIDO_CLIENTE
    FOREIGN KEY (IDCliente) REFERENCES dbo.CLIENTE(IDCliente);
ALTER TABLE dbo.PEDIDO ADD CONSTRAINT FK_PEDIDO_TIENDA
    FOREIGN KEY (IDTienda) REFERENCES dbo.TIENDA(IDTienda);
ALTER TABLE dbo.DETALLE_PEDIDO ADD CONSTRAINT FK_DETALLE_PEDIDO
    FOREIGN KEY (IDPedido) REFERENCES dbo.PEDIDO(IDPedido);
ALTER TABLE dbo.DETALLE_PEDIDO ADD CONSTRAINT FK_DETALLE_PRODUCTO
    FOREIGN KEY (IDProducto) REFERENCES dbo.PRODUCTO(IDProducto);
GO

-- PASO 5. Validacion: verificar las 10 tablas.
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

-- PASO 6. Vista rapida de productos (sin resolver los tickets JOIN).
SELECT TOP (10) IDProducto, NombreProducto, PrecioLista, StockGeneral
FROM dbo.PRODUCTO
ORDER BY IDProducto;
GO
PRINT N'Preparacion terminada. Continua con la guia de laboratorio de la Semana 9.';
GO

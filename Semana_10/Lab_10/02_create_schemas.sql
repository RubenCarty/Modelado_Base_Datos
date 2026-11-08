/* ============================================================
   02_create_schemas.sql
   OBJETIVO: Crear un esquema propio para separar los objetos del
   caso "E-commerce" del esquema dbo por defecto. Esto simula una
   práctica real de organización de bases de datos corporativas,
   donde cada dominio de negocio vive en su propio esquema.
   ============================================================ */

USE EcommerceBD;
GO

CREATE SCHEMA ecommerce AUTHORIZATION dbo;
GO

/* ------------------------------------------------------------
   QUÉ HACE
   - CREATE SCHEMA crea un "contenedor lógico" llamado ecommerce.
     Todas las tablas del caso se crearán como ecommerce.CLIENTE,
     ecommerce.PRODUCTO, etc., en lugar de dbo.CLIENTE.

   POR QUÉ IMPORTA PARA UN SQL DEVELOPER JR.
   - En empresas reales rara vez todo vive en dbo. Los esquemas
     permiten separar módulos (ventas, inventario, seguridad,
     auditoría) y aplicar permisos distintos a cada uno.

   RESULTADO ESPERADO
   - En SSMS: EcommerceBD → Security → Schemas → aparece "ecommerce".

   CÓMO VALIDARLO
   SELECT * FROM sys.schemas WHERE name = 'ecommerce';
   ------------------------------------------------------------ */

SELECT * FROM sys.schemas WHERE name = 'ecommerce';
GO

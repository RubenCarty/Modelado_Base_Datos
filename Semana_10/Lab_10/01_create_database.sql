/* ============================================================
   01_create_database.sql
   OBJETIVO: Crear la base de datos del caso "E-commerce en
   crecimiento" en Microsoft SQL Server.
   ============================================================ */

-- Si ya existe una versión anterior de la base (de una corrida
-- previa del laboratorio), la eliminamos para partir limpios.
IF DB_ID(N'EcommerceBD') IS NOT NULL
BEGIN
    ALTER DATABASE EcommerceBD SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE EcommerceBD;
END
GO

CREATE DATABASE EcommerceBD;
GO

-- A partir de aquí, todo el script se ejecuta dentro de EcommerceBD.
USE EcommerceBD;
GO

SELECT DB_NAME() AS BaseDeDatosActual;
GO

/* ------------------------------------------------------------
   QUÉ HACE
   - Elimina cualquier base EcommerceBD previa (limpieza segura
     para poder repetir el laboratorio las veces que sea necesario).
   - Crea la base de datos EcommerceBD con las opciones por
     defecto de SQL Server (esto es suficiente para el laboratorio;
     en un entorno productivo se definiría también el tamaño de
     archivos de datos/log, pero eso corresponde a un curso de
     administración, no de DDL básico).
   - Cambia el contexto de conexión a EcommerceBD con USE.

   RESULTADO ESPERADO
   - En el Object Explorer de SSMS aparece la base "EcommerceBD".
   - La consulta SELECT DB_NAME() devuelve "EcommerceBD".

   CÓMO VALIDARLO
   - Panel izquierdo de SSMS → botón derecho sobre "Databases" →
     "Refresh" → debe listarse EcommerceBD.
   ------------------------------------------------------------ */

/* ============================================================
   09_challenge.sql
   CHALLENGE AUTÓNOMO (15-20 minutos)
   ============================================================

   NUEVO REQUERIMIENTO DEL NEGOCIO:

   "La empresa quiere lanzar CUPONES de descuento para campañas
   de marketing. Cada cupón tiene un código único, un porcentaje
   de descuento, una fecha de inicio, una fecha de fin y un
   estado. Un cupón no puede tener un porcentaje de descuento
   mayor a 100% ni menor o igual a 0%. Además, la fecha de fin
   de un cupón nunca puede ser anterior a su fecha de inicio."

   TU MISIÓN:
   Escribe, en este mismo archivo, el CREATE TABLE de la tabla
   ecommerce.CUPON con las columnas:

       idCupon             (clave primaria)
       codigo
       porcentajeDescuento
       fechaInicio
       fechaFin
       estado

   DEBES DECIDIR (no está resuelto aquí a propósito):
   - El tipo de dato más adecuado para cada columna.
   - Qué columnas admiten NULL y cuáles no.
   - Qué columna(s) necesitan UNIQUE.
   - Qué CHECK constraints hacen falta para blindar las reglas
     de negocio indicadas arriba, incluyendo la relación entre
     fechaInicio y fechaFin (pista: un CHECK puede comparar dos
     columnas de la misma fila entre sí).
   - Qué valor(es) DEFAULT tienen sentido.

   NO existe una única solución "perfecta": lo importante es que
   puedas JUSTIFICAR cada decisión de diseño frente al docente.

   -- Escribe tu CREATE TABLE aquí abajo: -----------------------




   ------------------------------------------------------------

   Cuando termines, prueba tu tabla con al menos:
   1) Un INSERT válido.
   2) Un INSERT que intente un porcentaje de descuento de 150%.
   3) Un INSERT que intente fechaFin anterior a fechaInicio.
   4) Un INSERT que repita un código de cupón ya usado.

   Los intentos 2, 3 y 4 deben ser RECHAZADOS por tus constraints.
   ============================================================ */

USE EcommerceBD;
GO

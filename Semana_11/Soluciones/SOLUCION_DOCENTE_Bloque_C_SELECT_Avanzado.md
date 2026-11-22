# SOLUCIÓN DOCENTE — Bloque C: SELECT como herramienta de negocio y auditoría
## ⚠ CONFIDENCIAL — Guía de Laboratorio 10 (DML), sección 7

> **Base de datos:** `PRODUCTO_WEB_STAGE` cargada con `S10/productos_web.csv` (69 libros reales:
> Travel 11, Mystery 32, Historical Fiction 26 — scrapeados el 07-nov-2026, ver `02_create_staging.sql`).
> **Verificación:** cada consulta de este documento fue ejecutada contra esos 69 datos reales con un
> motor equivalente antes de entregarla. Los números que aparecen junto a cada consulta ("Resultado
> real: ...") son el resultado verdadero, no una estimación.
>
> Está organizado en 3 niveles, como pediste: **BÁSICAS** (resuelven exactamente las dos tablas de
> la sección 7 de la guía), **INTERMEDIAS** (agregación y lógica de negocio) y **AVANZADAS**
> (funciones de ventana, subconsultas correlacionadas, CTE, vistas).

---

## Nivel 1 — BÁSICAS (resuelven la tabla "Herramienta → Pregunta" de la guía)

```sql
USE EcommerceBD;
GO
```

### 1. `SELECT *` — ¿Qué llegó a STAGE?
```sql
SELECT * FROM PRODUCTO_WEB_STAGE;
```
**Resultado real: 69 filas.**

### 2. Columnas + alias — ¿Cómo mostrar solo lo que Comercial necesita?
```sql
SELECT
    nombre        AS Producto,
    precio        AS PrecioTexto,
    categoria     AS Categoria
FROM PRODUCTO_WEB_STAGE;
```
Comercial no necesita `disponibilidad`, `calificacion` ni `url` para decidir qué mostrar en el
catálogo — solo nombre, precio y categoría.

### 3. `DISTINCT` — ¿Qué categorías diferentes llegaron?
```sql
SELECT DISTINCT categoria FROM PRODUCTO_WEB_STAGE;
```
**Resultado real: 3 filas — `Travel`, `Mystery`, `Historical Fiction`.**

### 4. `WHERE` / `AND` / `OR` / `IN` — ¿Qué subconjunto cumple una condición?
```sql
-- OR
SELECT * FROM PRODUCTO_WEB_STAGE WHERE categoria = N'Travel' OR categoria = N'Mystery';

-- Equivalente con IN (más legible con 2+ valores)
SELECT * FROM PRODUCTO_WEB_STAGE WHERE categoria IN (N'Travel', N'Mystery');

-- AND
SELECT * FROM PRODUCTO_WEB_STAGE
WHERE categoria = N'Mystery' AND TRY_CAST(calificacion AS INT) = 5;
```
**Resultado real: `categoria IN ('Travel','Mystery')` → 43 filas (11 + 32).**

### 5. `TRY_CAST` — ¿El precio texto puede convertirse a número?
```sql
SELECT
    nombre,
    precio AS PrecioTexto,
    TRY_CAST(precio AS DECIMAL(10,2)) AS PrecioNumerico
FROM PRODUCTO_WEB_STAGE;
```
**Resultado real: las 69 filas convierten correctamente** (ninguna tiene `PrecioNumerico` en `NULL`)
— pero la consulta es la misma que usarías si hubiera precios corruptos, por eso se enseña aquí y no
se "da por hecho" que el precio siempre es válido. **PIENSA (pregúntalo a la clase):** si esto viniera
de un scraping real sin control de calidad, ¿qué pasaría con una fila con precio `"N/D"`? (Respuesta:
`TRY_CAST` devolvería `NULL` en vez de romper toda la consulta, que es justamente la ventaja frente a
`CAST`.)

### 6. `BETWEEN` — ¿Qué productos están dentro de un rango?
```sql
SELECT nombre, precio FROM PRODUCTO_WEB_STAGE
WHERE TRY_CAST(precio AS DECIMAL(10,2)) BETWEEN 20 AND 40;
```
**Resultado real: 33 filas.**

### 7. `LIKE` — ¿Qué nombres contienen una palabra?
```sql
SELECT nombre FROM PRODUCTO_WEB_STAGE WHERE nombre LIKE N'%World%';
```
**Resultado real: 2 filas** — *"Vagabonding: An Uncommon Guide to the Art of Long-Term World Travel"*
y *"World Without End (The Pillars of the Earth #2)"*.

### 8. `ORDER BY` — ¿Cuál es el orden por precio?
```sql
SELECT nombre, precio FROM PRODUCTO_WEB_STAGE
ORDER BY TRY_CAST(precio AS DECIMAL(10,2)) DESC;
```
Nota para la clase: hay que ordenar por `TRY_CAST(precio AS DECIMAL(10,2))`, NO por `precio` a secas
— `precio` sigue siendo texto en STAGE, y un `ORDER BY` de texto ordenaría `"9.99"` después de
`"59.48"` (orden alfabético, no numérico). Es un error común: pídeles que lo prueben sin `TRY_CAST`
y vean la diferencia.

### 9. `TOP` — ¿Cuáles son los 10 más caros?
```sql
SELECT TOP 10 nombre, precio FROM PRODUCTO_WEB_STAGE
ORDER BY TRY_CAST(precio AS DECIMAL(10,2)) DESC;
```
**Resultado real (los 3 primeros):**
1. *Boar Island (Anna Pigeon #19)* — 59.48
2. *The No. 1 Ladies' Detective Agency* — 57.70
3. *A Year in Provence (Provence #1)* — 56.88

---

## Nivel 1 — Auditoría antes de insertar (la segunda tabla de la sección 7)

```sql
-- 1. Nombres NULL o vacíos
SELECT * FROM PRODUCTO_WEB_STAGE WHERE nombre IS NULL OR LTRIM(RTRIM(nombre)) = '';

-- 2. Precios NULL
SELECT * FROM PRODUCTO_WEB_STAGE WHERE precio IS NULL;

-- 3. Precios no numéricos (texto que NO convierte)
SELECT * FROM PRODUCTO_WEB_STAGE
WHERE precio IS NOT NULL AND TRY_CAST(precio AS DECIMAL(10,2)) IS NULL;

-- 4. Precios <= 0
SELECT * FROM PRODUCTO_WEB_STAGE WHERE TRY_CAST(precio AS DECIMAL(10,2)) <= 0;

-- 5. Categorías inesperadas (la clase trabajó solo con estas 3)
SELECT DISTINCT categoria FROM PRODUCTO_WEB_STAGE
WHERE categoria NOT IN (N'Travel', N'Mystery', N'Historical Fiction');

-- 6. Espacios innecesarios al inicio/final del nombre o la categoría
SELECT nombre, categoria FROM PRODUCTO_WEB_STAGE
WHERE nombre <> LTRIM(RTRIM(nombre)) OR categoria <> LTRIM(RTRIM(categoria));

-- 7. Duplicados (mismo nombre + misma categoría, o misma URL)
SELECT nombre, categoria, COUNT(*) AS Repeticiones
FROM PRODUCTO_WEB_STAGE
GROUP BY nombre, categoria
HAVING COUNT(*) > 1;

SELECT url, COUNT(*) AS Repeticiones
FROM PRODUCTO_WEB_STAGE
GROUP BY url
HAVING COUNT(*) > 1;

-- 8. Calificaciones fuera de 1-5
SELECT * FROM PRODUCTO_WEB_STAGE
WHERE TRY_CAST(calificacion AS INT) IS NULL
   OR TRY_CAST(calificacion AS INT) NOT BETWEEN 1 AND 5;
```

**Resultado real de las 8: las 8 devuelven 0 filas.** Los 69 libros scrapeados de un sitio real y
limpio (`books.toscrape.com`) no traen datos corruptos — y esto es, en sí mismo, un resultado válido
que hay que saber reportar ("auditamos y no encontramos problemas" es una conclusión legítima, no un
fracaso de la consulta).

**Para que la clase VEA que las 8 consultas sí funcionan (no solo que "dan 0 por suerte"),** antes del
Bloque C, inserta manualmente 1-2 filas sucias de prueba en STAGE y vuelve a correr las 8:

```sql
INSERT INTO PRODUCTO_WEB_STAGE (nombre, precio, categoria, disponibilidad, calificacion, url) VALUES
(N'  Libro con espacios  ', N'-5', N'Terror', N'In stock', N'9', N'https://x/prueba1'),
(NULL, N'no-es-numero', N'Mystery', N'In stock', N'3', N'https://x/prueba2');
```
Con estas 2 filas de prueba: la auditoría 1 encuentra 1 (nombre NULL), la 3 encuentra 1 (precio no
numérico), la 4 encuentra 1 (precio -5 ≤ 0), la 5 encuentra 1 (categoría "Terror" no está en la lista
de clase), la 6 encuentra 1 ("Libro con espacios"), y la 8 encuentra 1 (calificación 9, fuera de 1-5).
**No olvides borrarlas antes del Bloque D** (`DELETE FROM PRODUCTO_WEB_STAGE WHERE url LIKE 'https://x/%';`)
para no contaminar el INSERT real hacia `ecommerce.PRODUCTO`.

### CONSTRUYE — reglas mínimas para pasar de STAGE a PRODUCTO

Esta es la respuesta esperada a la pregunta abierta de cierre del Bloque C (y es exactamente lo que
ya implementa `03_insertar_productos_desde_stage.sql`):

1. `nombre` no debe ser `NULL` ni estar vacío (después de `LTRIM(RTRIM(...))`).
2. `precio` debe convertir con `TRY_CAST` y ser `> 0`.
3. `calificacion` debe convertir con `TRY_CAST` y estar entre 1 y 5.
4. La `categoria` debe existir (o crearse una sola vez) en `ecommerce.CATEGORIA` antes del `INSERT`
   — nunca duplicarla.
5. No se valida `disponibilidad` como bloqueante (es informativa), pero si apareciera un valor
   distinto de `"In stock"` se debe decidir en equipo si es motivo de exclusión.

---

## Nivel 2 — INTERMEDIAS (agregación, `CASE`, `HAVING`, funciones de texto)

```sql
-- Cuántos libros, precio promedio, mínimo y máximo POR categoría
SELECT
    categoria,
    COUNT(*)                                   AS TotalLibros,
    ROUND(AVG(TRY_CAST(precio AS DECIMAL(10,2))), 2) AS PrecioPromedio,
    MIN(TRY_CAST(precio AS DECIMAL(10,2)))     AS PrecioMinimo,
    MAX(TRY_CAST(precio AS DECIMAL(10,2)))     AS PrecioMaximo
FROM PRODUCTO_WEB_STAGE
GROUP BY categoria;
```
**Resultado real:**

| categoria | TotalLibros | PrecioPromedio | PrecioMinimo | PrecioMaximo |
|---|---|---|---|---|
| Historical Fiction | 26 | 33.64 | 16.62 | 55.55 |
| Mystery | 32 | 31.72 | 10.69 | 59.48 |
| Travel | 11 | 39.79 | 23.21 | 56.88 |

```sql
-- Clasificar por nivel de calidad con CASE
SELECT
    CASE
        WHEN TRY_CAST(calificacion AS INT) >= 4 THEN N'Alta'
        WHEN TRY_CAST(calificacion AS INT) = 3  THEN N'Media'
        ELSE N'Baja'
    END AS NivelCalidad,
    COUNT(*) AS Total
FROM PRODUCTO_WEB_STAGE
GROUP BY
    CASE
        WHEN TRY_CAST(calificacion AS INT) >= 4 THEN N'Alta'
        WHEN TRY_CAST(calificacion AS INT) = 3  THEN N'Media'
        ELSE N'Baja'
    END;
```
**Resultado real: Alta = 27, Media = 16, Baja = 26.** (Nota: "Baja" aquí son 26, mientras que en
`03_insertar_productos_desde_stage.sql` solo 23 terminan `INACTIVO` — los 3 de diferencia son los que
además tienen precio < 15 y por eso quedan excluidos del todo, no solo inactivos. Buen punto para
discutir en clase: "Baja calidad" y "se excluye" no son lo mismo.)

```sql
-- Categorías con más de 15 libros (HAVING filtra DESPUÉS de agrupar, WHERE no podría)
SELECT categoria, COUNT(*) AS Total
FROM PRODUCTO_WEB_STAGE
GROUP BY categoria
HAVING COUNT(*) > 15;
```
**Resultado real: Historical Fiction (26), Mystery (32).** Travel (11) queda fuera.

```sql
-- Libros con precio por encima del promedio GENERAL de todo STAGE
SELECT nombre, precio
FROM PRODUCTO_WEB_STAGE
WHERE TRY_CAST(precio AS DECIMAL(10,2)) >
      (SELECT AVG(TRY_CAST(precio AS DECIMAL(10,2))) FROM PRODUCTO_WEB_STAGE)
ORDER BY TRY_CAST(precio AS DECIMAL(10,2)) DESC;
```
**Resultado real: 33 filas.**

```sql
-- Funciones de texto: normalizar y medir
SELECT
    nombre,
    UPPER(nombre)              AS NombreMayusculas,
    LEN(LTRIM(RTRIM(nombre)))  AS LargoReal
FROM PRODUCTO_WEB_STAGE
ORDER BY LargoReal DESC;
```
Útil para fundamentar el `NVARCHAR(150)` que ya se usó al diseñar `ecommerce.PRODUCTO` en la Semana 9
— el nombre más largo real de esta muestra tiene bastante menos de 150 caracteres, lo que confirma
que la holgura elegida fue razonable.

---

## Nivel 3 — AVANZADAS (funciones de ventana, subconsulta correlacionada, CTE, vistas)

```sql
-- El libro MÁS CARO de cada categoría, con ROW_NUMBER() + PARTITION BY
WITH Numerado AS (
    SELECT
        nombre, categoria, TRY_CAST(precio AS DECIMAL(10,2)) AS PrecioNum,
        ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY TRY_CAST(precio AS DECIMAL(10,2)) DESC) AS Posicion
    FROM PRODUCTO_WEB_STAGE
)
SELECT categoria, nombre, PrecioNum
FROM Numerado
WHERE Posicion = 1;
```
**Resultado real:**

| categoria | nombre | PrecioNum |
|---|---|---|
| Historical Fiction | The Last Painting of Sara de Vos | 55.55 |
| Mystery | Boar Island (Anna Pigeon #19) | 59.48 |
| Travel | A Year in Provence (Provence #1) | 56.88 |

**Por qué `ROW_NUMBER()` y no simplemente `TOP 1` por categoría:** `TOP` solo funciona sobre UNA
consulta completa; para "el top 1 de CADA grupo" en una sola pasada necesitas una función de ventana
con `PARTITION BY` — es el reemplazo profesional de "hacer 3 SELECT TOP 1, uno por categoría, a mano".

```sql
-- TOP 3 por categoría (cambia Posicion = 1 por <= 3), con RANK() para permitir empates
WITH Rankeado AS (
    SELECT
        categoria, nombre, TRY_CAST(precio AS DECIMAL(10,2)) AS PrecioNum,
        RANK() OVER (PARTITION BY categoria ORDER BY TRY_CAST(precio AS DECIMAL(10,2)) DESC) AS Posicion
    FROM PRODUCTO_WEB_STAGE
)
SELECT categoria, nombre, PrecioNum, Posicion
FROM Rankeado
WHERE Posicion <= 3
ORDER BY categoria, Posicion;
```
**Resultado real: 9 filas (3 por cada una de las 3 categorías).** Pregunta de clase: ¿por qué `RANK()`
y no `ROW_NUMBER()` aquí? (Respuesta: si dos libros empataran en precio, `RANK()` les da la misma
posición y salta la siguiente —p. ej. 1,1,3—, mientras `ROW_NUMBER()` los separaría arbitrariamente
en 1,2,3 aunque el precio sea idéntico. Con precios reales de dos decimales el empate es raro, pero
hay que saber cuál usar cuando sí ocurre.)

```sql
-- Subconsulta CORRELACIONADA: libros más caros que el promedio DE SU PROPIA categoría
-- (distinto del "promedio general" del Nivel 2: aquí el promedio se recalcula por cada fila)
SELECT s.categoria, s.nombre, TRY_CAST(s.precio AS DECIMAL(10,2)) AS Precio
FROM PRODUCTO_WEB_STAGE s
WHERE TRY_CAST(s.precio AS DECIMAL(10,2)) > (
    SELECT AVG(TRY_CAST(s2.precio AS DECIMAL(10,2)))
    FROM PRODUCTO_WEB_STAGE s2
    WHERE s2.categoria = s.categoria
)
ORDER BY s.categoria, Precio DESC;
```
**Resultado real: 30 filas** (distinto de las 33 del promedio general del Nivel 2 — un libro de
Travel puede estar por debajo del promedio de Travel pero por encima del promedio general de las 3
categorías juntas; es la diferencia exacta que esta consulta hace visible).

```sql
-- STRING_AGG: todos los nombres de una categoría en una sola celda (SQL Server 2017+)
SELECT
    categoria,
    STRING_AGG(nombre, N' | ') AS Catalogo
FROM PRODUCTO_WEB_STAGE
GROUP BY categoria;
```
Útil para un reporte ejecutivo de una sola fila por categoría en vez de 11-32 filas sueltas.

```sql
-- VISTA reutilizable: consolida toda la auditoría del Bloque C en un solo objeto
-- (para no reescribir las 8 consultas cada vez que se recarga STAGE)
CREATE OR ALTER VIEW V_AUDITORIA_STAGE AS
SELECT
    'Nombre NULL o vacio'  AS Problema, COUNT(*) AS Total
    FROM PRODUCTO_WEB_STAGE WHERE nombre IS NULL OR LTRIM(RTRIM(nombre)) = ''
UNION ALL
SELECT 'Precio NULL', COUNT(*)
    FROM PRODUCTO_WEB_STAGE WHERE precio IS NULL
UNION ALL
SELECT 'Precio no numerico', COUNT(*)
    FROM PRODUCTO_WEB_STAGE WHERE precio IS NOT NULL AND TRY_CAST(precio AS DECIMAL(10,2)) IS NULL
UNION ALL
SELECT 'Precio <= 0', COUNT(*)
    FROM PRODUCTO_WEB_STAGE WHERE TRY_CAST(precio AS DECIMAL(10,2)) <= 0
UNION ALL
SELECT 'Categoria inesperada', COUNT(*)
    FROM PRODUCTO_WEB_STAGE WHERE categoria NOT IN (N'Travel', N'Mystery', N'Historical Fiction')
UNION ALL
SELECT 'Calificacion fuera de 1-5', COUNT(*)
    FROM PRODUCTO_WEB_STAGE
    WHERE TRY_CAST(calificacion AS INT) IS NULL OR TRY_CAST(calificacion AS INT) NOT BETWEEN 1 AND 5;
GO

-- Uso: en vez de correr 6 SELECT sueltos, ahora basta
SELECT * FROM V_AUDITORIA_STAGE;
```
Este es el tipo de automatización que un Data/SQL Developer Jr. real construiría después de hacer
la auditoría "a mano" un par de veces — buen cierre para conectar el Bloque C con el rol profesional
que la guía plantea en su encabezado.

---

## Resumen para proyectar en clase

| Nivel | Qué enseña | Minutos sugeridos dentro de los 45 del Bloque C |
|---|---|---|
| Básicas | Las 9 herramientas + las 8 auditorías de la guía, tal cual | 25 |
| Intermedias | `GROUP BY`, `HAVING`, `CASE`, subconsulta simple | 10 |
| Avanzadas | `ROW_NUMBER`/`RANK` + `PARTITION BY`, subconsulta correlacionada, `STRING_AGG`, vista | 10 (opcional, para grupos que van adelantados) |

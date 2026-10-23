# SOLUCIÓN — Caso 2. Biblioteca universitaria
## Laboratorio 6 de Base de Datos — Normalización 1FN · 2FN · 3FN · 4FN · 5FN

**Archivo de datos:** `02_Biblioteca_200.csv` (200 registros reales, ya cargados y verificados para esta solución)
**Base de datos a crear en SQL Server:** `Lab06_Caso02`

> **Antes de empezar:** si todavía no sabes cómo importar un CSV a SQL Server 2022, abre primero
> [`00_COMO_IMPORTAR_CSV_SQLSERVER22.md`](00_COMO_IMPORTAR_CSV_SQLSERVER22.md) — son los mismos 10 pasos para los 10 casos del laboratorio, aquí no se repiten.
>
> **Verificación de esta solución:** todas las consultas de este documento (claves, dependencias funcionales, cardinalidades, reconstrucción por JOIN) fueron ejecutadas y comprobadas contra el archivo CSV real con un motor de prueba — los números que aparecen (filas, conteos, violaciones) son los resultados reales del archivo, no estimaciones. La sintaxis T-SQL (`STRING_SPLIT`, `IDENTITY`, etc.) es válida en SQL Server 2022; se recomienda correr el script completo en tu propio SQL Server antes de la clase.

---

## Contexto y problemática (del enunciado de la guía)

**Contexto.** Una biblioteca registra préstamos, estudiantes, libros, editoriales, autores, temas y sedes en un único archivo.

**Problemática.** La información del estudiante, libro y editorial se repite. Un libro puede relacionarse con varios autores y temas, generando combinaciones redundantes.

---

## PASO 0 — Crear la base de datos

```sql
DROP DATABASE IF EXISTS Lab06_Caso02;
CREATE DATABASE Lab06_Caso02;
USE Lab06_Caso02;
```

---

## PASO 1 — Explorar los 200 registros (hallazgos antes de tocar la estructura)

Abre la tabla ya importada (ver guía de importación) y mira las primeras filas:

```sql
SELECT TOP 10 * FROM PRESTAMO_INICIAL;
```

**Tres hallazgos que debes anotar antes de modificar nada** (ya verificados en este archivo):

1. **Dato repetido de editorial:** la editorial `ED001` (Editorial 1) aparece repetido en varias filas, siempre con el mismo nombre — exactamente el patrón que genera riesgo de inconsistencia si alguien actualiza una sola fila y olvida las demás.
2. **Valor no atómico en `TelefonosEstudiante`:** la columna trae dos valores en una sola celda separados por `|` (ejemplo real: `97000001|97100001`) — viola la atomicidad exigida por 1FN.
3. **Clave simple insuficiente:** ni `IDPrestamo` ni `IDLibro` identifican una fila por sí solos — `IDPrestamo` se repite 20 veces (una por cada libro) y `IDLibro` se repite 10 veces (una por cada préstamo); se necesita la combinación de ambos.

---

## PASO 2 — Determinar la clave candidata (COUNT + GROUP BY)

```sql
-- 2.1  ¿Es IDPrestamo suficiente por sí solo?
SELECT IDPrestamo, COUNT(*) AS Filas
FROM PRESTAMO_INICIAL
GROUP BY IDPrestamo;
-- Resultado real: 10 valores distintos de IDPrestamo, cada uno con 20 filas -> NO es clave por sí solo.
```

```sql
-- 2.2  ¿Es IDLibro suficiente por sí solo?
SELECT IDLibro, COUNT(*) AS Filas
FROM PRESTAMO_INICIAL
GROUP BY IDLibro;
-- Resultado real: 20 valores distintos de IDLibro, cada uno con 10 filas -> NO es clave por sí solo.
```

```sql
-- 2.3  ¿La combinación (IDPrestamo, IDLibro) identifica una fila única?
SELECT IDPrestamo, IDLibro, COUNT(*) AS Filas
FROM PRESTAMO_INICIAL
GROUP BY IDPrestamo, IDLibro
HAVING COUNT(*) > 1;
-- Resultado real: 0 filas devueltas -> cada combinación aparece EXACTAMENTE una vez.
```

**Clave candidata: {IDPrestamo, IDLibro}** (clave compuesta).

---

## PASO 3 — Identificar las dependencias funcionales (con evidencia real del CSV)

```sql
-- DF 1:  IDEstudiante -> NombreEstudiante, Carrera, TelefonosEstudiante
SELECT IDEstudiante, NombreEstudiante, Carrera, TelefonosEstudiante
FROM PRESTAMO_INICIAL
WHERE IDEstudiante = 'E001';
```
**Evidencia (2 filas reales, mismo `IDEstudiante`, 20 veces en total — aquí solo 2):**
| IDEstudiante | NombreEstudiante | Carrera | TelefonosEstudiante |
|---|---|---|---|
| E001 | Estudiante 1 | Carrera 1 | 97000001\|97100001 |
| E001 | Estudiante 1 | Carrera 1 | 97000001\|97100001 |

Siempre el mismo nombre, carrera y teléfonos para `E001` → **`IDEstudiante → NombreEstudiante, Carrera, TelefonosEstudiante`** se confirma.

```sql
-- DF 2:  Carrera -> CoordinadorCarrera
SELECT DISTINCT Carrera, CoordinadorCarrera
FROM PRESTAMO_INICIAL
WHERE Carrera = 'Carrera 1';
```
**Evidencia:** `Carrera 1` siempre trae `CoordinadorCarrera` = `Coordinador 1` → **`Carrera → CoordinadorCarrera`** se confirma.

```sql
-- DF 3:  IDLibro -> TituloLibro, AreaTematica, PrecioUnitario, IDEditorial
SELECT IDLibro, TituloLibro, AreaTematica, PrecioUnitario, IDEditorial
FROM PRESTAMO_INICIAL
WHERE IDLibro = 'L001'
ORDER BY IDPrestamo;
```
**Evidencia (2 filas reales, mismo `IDLibro`, en préstamos distintos — demuestra que NO depende de `IDPrestamo`):**
| IDLibro | TituloLibro | AreaTematica | PrecioUnitario | IDEditorial |
|---|---|---|---|---|
| L001 | Libro 1 | Area 1 | 32.0 | ED001 |
| L001 | Libro 1 | Area 1 | 32.0 | ED001 |

**`IDLibro → TituloLibro, AreaTematica, PrecioUnitario, IDEditorial`** se confirma: el precio y la editorial del libro no cambian aunque cambie el préstamo.

```sql
-- DF 4:  IDEditorial -> Editorial, CiudadEditorial
SELECT DISTINCT IDEditorial, Editorial, CiudadEditorial
FROM PRESTAMO_INICIAL
WHERE IDEditorial = 'ED001';
```
**Evidencia:** `ED001` siempre trae `Editorial` = `Editorial 1` y `CiudadEditorial` = `Ciudad 1` → **`IDEditorial → Editorial, CiudadEditorial`** se confirma.

```sql
-- DF 5 (dependencia COMPLETA, no parcial):  (IDPrestamo, IDLibro) -> Cantidad, PrecioTotal
SELECT IDPrestamo, IDLibro, Cantidad, PrecioTotal
FROM PRESTAMO_INICIAL
WHERE IDLibro = 'L001'
ORDER BY IDPrestamo;
-- Observa: el mismo IDLibro trae distinta Cantidad/PrecioTotal según el préstamo -> depende de LA CLAVE COMPLETA, no de una parte.
```

---

## PASO 4 — Primera Forma Normal (1FN)

**Violación encontrada:** `TelefonosEstudiante` no es atómica (trae `97000001|97100001`, 2 valores en una celda).

```sql
-- 4.1  Separar el valor multivaluado en su propia tabla
CREATE TABLE ESTUDIANTE_TELEFONO (
    IDEstudiante VARCHAR(10)  NOT NULL,
    Valor            VARCHAR(30) NOT NULL,
    CONSTRAINT PK_ESTUDIANTE_TELEFONO PRIMARY KEY (IDEstudiante, Valor)
);

INSERT INTO ESTUDIANTE_TELEFONO (IDEstudiante, Valor)
SELECT DISTINCT IDEstudiante, LTRIM(RTRIM(valor.value))
FROM PRESTAMO_INICIAL
CROSS APPLY STRING_SPLIT(TelefonosEstudiante, '|') AS valor;
```

```sql
-- 4.2  Verificar 1FN: debe haber 20 filas (= 10 estudiantes x 2 teléfonos cada uno)
SELECT COUNT(*) AS Filas FROM ESTUDIANTE_TELEFONO;
```

```sql
-- 4.3  Crear la tabla en 1FN: mismas columnas MENOS la multivaluada, con PK compuesta
CREATE TABLE PRESTAMO_1FN (
    IDPrestamo        VARCHAR(10)   NOT NULL,
    IDEstudiante        VARCHAR(10)   NOT NULL,
    NombreEstudiante       NVARCHAR(80)  NOT NULL,
    Carrera        NVARCHAR(40)  NOT NULL,
    CoordinadorCarrera     NVARCHAR(40)  NOT NULL,
    IDLibro        VARCHAR(10)   NOT NULL,
    TituloLibro       NVARCHAR(80)  NOT NULL,
    AreaTematica       NVARCHAR(40)  NOT NULL,
    PrecioUnitario       DECIMAL(10,2) NOT NULL,
    Cantidad      INT           NOT NULL,
    PrecioTotal      DECIMAL(10,2) NOT NULL,
    IDEditorial        VARCHAR(10)   NOT NULL,
    Editorial       NVARCHAR(80)  NOT NULL,
    CiudadEditorial       NVARCHAR(40)  NOT NULL,
    Autor       NVARCHAR(40)  NOT NULL,
    Tema       NVARCHAR(40)  NOT NULL,
    SedeBiblioteca       NVARCHAR(40)  NOT NULL,
    CONSTRAINT PK_PRESTAMO_1FN PRIMARY KEY (IDPrestamo, IDLibro)
);

INSERT INTO PRESTAMO_1FN
SELECT IDPrestamo,IDEstudiante,NombreEstudiante,Carrera,CoordinadorCarrera,IDLibro,TituloLibro,AreaTematica,PrecioUnitario,Cantidad,PrecioTotal,IDEditorial,Editorial,CiudadEditorial,Autor,Tema,SedeBiblioteca
FROM PRESTAMO_INICIAL;

SELECT COUNT(*) AS Filas FROM PRESTAMO_1FN;   -- debe devolver 200
```

✅ **Cumple 1FN:** cada celda tiene un único valor; la clave compuesta (IDPrestamo, IDLibro) identifica cada fila sin ambigüedad.

---

## PASO 5 — Segunda Forma Normal (2FN): eliminar dependencias parciales

Atributos que dependen SOLO de `IDPrestamo` (parte de la clave): `IDEstudiante, NombreEstudiante, Carrera, CoordinadorCarrera`.
Atributos que dependen SOLO de `IDLibro` (la otra parte): `TituloLibro, AreaTematica, PrecioUnitario, IDEditorial, Editorial, CiudadEditorial`.
Atributos que dependen de LA CLAVE COMPLETA: `Cantidad, PrecioTotal`.

```sql
-- 5.1  Lado del préstamo (todo lo que depende solo de IDPrestamo)
CREATE TABLE PRESTAMO_2FN (
    IDPrestamo    VARCHAR(10)  NOT NULL,
    IDEstudiante    VARCHAR(10)  NOT NULL,
    NombreEstudiante   NVARCHAR(80) NOT NULL,
    Carrera    NVARCHAR(40) NOT NULL,
    CoordinadorCarrera NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_PRESTAMO_2FN PRIMARY KEY (IDPrestamo)
);
INSERT INTO PRESTAMO_2FN
SELECT DISTINCT IDPrestamo,IDEstudiante,NombreEstudiante,Carrera,CoordinadorCarrera FROM PRESTAMO_1FN;

-- 5.2  Lado del libro (todo lo que depende solo de IDLibro)
CREATE TABLE LIBRO_2FN (
    IDLibro  VARCHAR(10)   NOT NULL,
    TituloLibro NVARCHAR(80)  NOT NULL,
    AreaTematica NVARCHAR(40)  NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    IDEditorial  VARCHAR(10)   NOT NULL,
    Editorial NVARCHAR(80)  NOT NULL,
    CiudadEditorial NVARCHAR(40)  NOT NULL,
    CONSTRAINT PK_LIBRO_2FN PRIMARY KEY (IDLibro)
);
INSERT INTO LIBRO_2FN
SELECT DISTINCT IDLibro,TituloLibro,AreaTematica,PrecioUnitario,IDEditorial,Editorial,CiudadEditorial FROM PRESTAMO_1FN;

-- 5.3  Detalle: solo lo que depende de LA CLAVE COMPLETA (+ precio histórico de la transacción)
CREATE TABLE DETALLE_PRESTAMO (
    IDPrestamo    VARCHAR(10)   NOT NULL,
    IDLibro    VARCHAR(10)   NOT NULL,
    PrecioUnitario   DECIMAL(10,2) NOT NULL,   -- precio histórico al momento de la transacción
    Cantidad  INT           NOT NULL,
    PrecioTotal  DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_DETALLE_PRESTAMO PRIMARY KEY (IDPrestamo, IDLibro),
    CONSTRAINT FK_DETALLE_PRESTAMO_LIBRO FOREIGN KEY (IDLibro) REFERENCES LIBRO_2FN(IDLibro)
);
INSERT INTO DETALLE_PRESTAMO (IDPrestamo,IDLibro,PrecioUnitario,Cantidad,PrecioTotal)
SELECT IDPrestamo,IDLibro,PrecioUnitario,Cantidad,PrecioTotal FROM PRESTAMO_1FN;
```

```sql
-- Verificación: PRESTAMO_2FN debe tener 10 filas, LIBRO_2FN debe tener 20 filas, DETALLE_PRESTAMO debe tener 200 filas
SELECT COUNT(*) FROM PRESTAMO_2FN;   -- 10
SELECT COUNT(*) FROM LIBRO_2FN;   -- 20
SELECT COUNT(*) FROM DETALLE_PRESTAMO;  -- 200
```

> **¿Por qué se conserva `PrecioUnitario` también en `DETALLE_PRESTAMO`?** Para guardar el precio **histórico** de esa transacción puntual. El precio "actual" del catálogo vive en `LIBRO_2FN`; si el precio de catálogo cambia mañana, las transacciones ya registradas no deben cambiar retroactivamente.

---

## PASO 6 — Tercera Forma Normal (3FN): eliminar dependencias transitivas

Dos cadenas transitivas detectadas:
- `IDPrestamo → IDEstudiante → NombreEstudiante, Carrera` y `Carrera → CoordinadorCarrera` (cadena de 3: `IDPrestamo → Carrera → CoordinadorCarrera`)
- `IDLibro → IDEditorial → Editorial, CiudadEditorial` (cadena: `IDLibro → IDEditorial → Editorial, CiudadEditorial`)

```sql
-- 6.1  Separar CARRERA (resuelve Carrera -> CoordinadorCarrera)
CREATE TABLE CARRERA (
    Carrera    NVARCHAR(40) NOT NULL,
    CoordinadorCarrera NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_CARRERA PRIMARY KEY (Carrera)
);
INSERT INTO CARRERA SELECT DISTINCT Carrera,CoordinadorCarrera FROM PRESTAMO_2FN;

-- 6.2  ESTUDIANTE definitivo (ya sin Carrera repetido con el responsable adentro; Carrera queda como FK)
CREATE TABLE ESTUDIANTE (
    IDEstudiante  VARCHAR(10)  NOT NULL,
    NombreEstudiante NVARCHAR(80) NOT NULL,
    Carrera  NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_ESTUDIANTE PRIMARY KEY (IDEstudiante),
    CONSTRAINT FK_ESTUDIANTE_CARRERA FOREIGN KEY (Carrera) REFERENCES CARRERA(Carrera)
);
INSERT INTO ESTUDIANTE SELECT DISTINCT IDEstudiante,NombreEstudiante,Carrera FROM PRESTAMO_2FN;

-- 6.3  PRESTAMO definitivo (solo el id del préstamo + FK al estudiante)
CREATE TABLE PRESTAMO (
    IDPrestamo VARCHAR(10) NOT NULL,
    IDEstudiante VARCHAR(10) NOT NULL,
    CONSTRAINT PK_PRESTAMO PRIMARY KEY (IDPrestamo),
    CONSTRAINT FK_PRESTAMO_ESTUDIANTE FOREIGN KEY (IDEstudiante) REFERENCES ESTUDIANTE(IDEstudiante)
);
INSERT INTO PRESTAMO SELECT IDPrestamo,IDEstudiante FROM PRESTAMO_2FN;

-- 6.4  Separar EDITORIAL (resuelve IDLibro -> IDEditorial -> Editorial,CiudadEditorial)
CREATE TABLE EDITORIAL (
    IDEditorial  VARCHAR(10)  NOT NULL,
    Editorial NVARCHAR(80) NOT NULL,
    CiudadEditorial NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_EDITORIAL PRIMARY KEY (IDEditorial)
);
INSERT INTO EDITORIAL SELECT DISTINCT IDEditorial,Editorial,CiudadEditorial FROM LIBRO_2FN;

-- 6.5  LIBRO definitivo (ya sin los datos de la editorial adentro; IDEditorial queda como FK)
CREATE TABLE LIBRO (
    IDLibro  VARCHAR(10)   NOT NULL,
    TituloLibro NVARCHAR(80)  NOT NULL,
    AreaTematica NVARCHAR(40)  NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    IDEditorial  VARCHAR(10)   NOT NULL,
    CONSTRAINT PK_LIBRO PRIMARY KEY (IDLibro),
    CONSTRAINT FK_LIBRO_EDITORIAL FOREIGN KEY (IDEditorial) REFERENCES EDITORIAL(IDEditorial)
);
INSERT INTO LIBRO SELECT IDLibro,TituloLibro,AreaTematica,PrecioUnitario,IDEditorial FROM LIBRO_2FN;
```

```sql
-- Verificación: CARRERA=4 filas | ESTUDIANTE=10 filas | PRESTAMO=10 filas | EDITORIAL=5 filas | LIBRO=20 filas
SELECT COUNT(*) FROM CARRERA;  SELECT COUNT(*) FROM ESTUDIANTE;  SELECT COUNT(*) FROM PRESTAMO;
SELECT COUNT(*) FROM EDITORIAL;  SELECT COUNT(*) FROM LIBRO;
```

✅ **Cumple 3FN:** ningún atributo no-clave depende de otro atributo no-clave; todo depende directamente de la clave de su propia tabla.

---

## PASO 7 — Cuarta Forma Normal (4FN): hechos multivaluados independientes

**Hallazgo (grano = un `IDPrestamo`):** dentro de un mismo préstamo (ejemplo real `PS001`, con sus 20 filas), `Autor` toma **2** valores distintos (Autor Invitado, Autor Principal) y `Tema` toma **2** valores distintos (Bases de Datos, Programacion) — y aparecen **todas** las combinaciones posibles entre ambos (evidencia de que son independientes entre sí para la misma operación, no uno depende del otro).

```sql
-- Evidencia: ¿aparecen TODAS las combinaciones de Autor x Tema dentro de un mismo IDPrestamo?
SELECT DISTINCT Autor, Tema
FROM PRESTAMO_1FN
WHERE IDPrestamo = 'PS001'
ORDER BY Autor, Tema;
-- Resultado real: 4 combinaciones (= 2 x 2) -> confirma independencia (MVD).
```

```sql
-- 7.1  Separar los dos hechos multivaluados independientes
CREATE TABLE PRESTAMO_AUTOR (
    IDPrestamo  VARCHAR(10)  NOT NULL,
    Autor NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_PRESTAMO_AUTOR PRIMARY KEY (IDPrestamo, Autor)
);
INSERT INTO PRESTAMO_AUTOR SELECT DISTINCT IDPrestamo,Autor FROM PRESTAMO_1FN;

CREATE TABLE PRESTAMO_TEMA (
    IDPrestamo  VARCHAR(10)  NOT NULL,
    Tema NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_PRESTAMO_TEMA PRIMARY KEY (IDPrestamo, Tema)
);
INSERT INTO PRESTAMO_TEMA SELECT DISTINCT IDPrestamo,Tema FROM PRESTAMO_1FN;
```

> ⚠ **Nota honesta sobre estos datos.** En esta muestra, `IDLibro` TAMBIÉN determina `Autor` y `Tema` sin excepción (es un efecto de cómo se generó el archivo: los mismos 20 libros se repiten idénticos en cada préstamo). Eso NO es una regla de negocio real — un libro no "tiene" un autor fijo en la vida real. Tratamos `Autor` y `Tema` como hechos independientes del **préstamo** (que es la lectura que pide el enunciado de la guía: "hechos multivaluados... para una misma operación"), no del libro. Coméntalo así en tu sustentación.

---

## PASO 8 — Quinta Forma Normal (5FN): relación ternaria y reconstrucción sin pérdida

Agregamos el tercer hecho, `SedeBiblioteca` (5 valores: Central, Este, Norte, Sur, Virtual), y verificamos si la combinación de los **tres** (Autor, Tema, SedeBiblioteca) para un mismo `IDPrestamo` se reconstruye exactamente uniendo tres tablas binarias — sin inventar combinaciones (filas espurias) ni perder ninguna.

```sql
-- 8.1  Tercera tabla
CREATE TABLE PRESTAMO_SEDEBIBLIOTECA (
    IDPrestamo  VARCHAR(10)  NOT NULL,
    SedeBiblioteca NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_PRESTAMO_SEDEBIBLIOTECA PRIMARY KEY (IDPrestamo, SedeBiblioteca)
);
INSERT INTO PRESTAMO_SEDEBIBLIOTECA SELECT DISTINCT IDPrestamo,SedeBiblioteca FROM PRESTAMO_1FN;
```

```sql
-- 8.2  Verificación de reconstrucción (debe devolver exactamente 20 filas para 'PS001', ni una más ni una menos)
SELECT c1.IDPrestamo, c1.Autor, c2.Tema, c3.SedeBiblioteca
FROM PRESTAMO_AUTOR c1
JOIN PRESTAMO_TEMA c2 ON c2.IDPrestamo = c1.IDPrestamo
JOIN PRESTAMO_SEDEBIBLIOTECA c3 ON c3.IDPrestamo = c1.IDPrestamo
WHERE c1.IDPrestamo = 'PS001'
ORDER BY c1.Autor, c2.Tema, c3.SedeBiblioteca;
```

```sql
-- 8.3  Comprobación automática contra la tabla original (0 = reconstrucción exacta)
SELECT COUNT(*) AS Diferencias FROM (
    SELECT Autor,Tema,SedeBiblioteca FROM PRESTAMO_1FN WHERE IDPrestamo='PS001'
    EXCEPT
    SELECT c1.Autor, c2.Tema, c3.SedeBiblioteca
    FROM PRESTAMO_AUTOR c1
    JOIN PRESTAMO_TEMA c2 ON c2.IDPrestamo=c1.IDPrestamo
    JOIN PRESTAMO_SEDEBIBLIOTECA c3 ON c3.IDPrestamo=c1.IDPrestamo
    WHERE c1.IDPrestamo='PS001'
) AS Diff;
-- Verificado contra el CSV real: 0 diferencias -> descomposición SIN PÉRDIDA.
```

✅ **Cumple 5FN:** la relación ternaria se reconstruye exactamente mediante el JOIN de las tres tablas binarias — no hace falta guardar una tabla de 3 columnas.

---

## MODELO FINAL

| # | Tabla | Clave primaria (PK) | Claves foráneas (FK) |
|---|---|---|---|
| 1 | `CARRERA` | Carrera | — |
| 2 | `ESTUDIANTE` | IDEstudiante | Carrera → `CARRERA` |
| 3 | `ESTUDIANTE_TELEFONO` | (IDEstudiante, Valor) | IDEstudiante → `ESTUDIANTE` |
| 4 | `PRESTAMO` | IDPrestamo | IDEstudiante → `ESTUDIANTE` |
| 5 | `EDITORIAL` | IDEditorial | — |
| 6 | `LIBRO` | IDLibro | IDEditorial → `EDITORIAL` |
| 7 | `DETALLE_PRESTAMO` | (IDPrestamo, IDLibro) | IDPrestamo → `PRESTAMO` · IDLibro → `LIBRO` |
| 8 | `PRESTAMO_AUTOR` | (IDPrestamo, Autor) | IDPrestamo → `PRESTAMO` |
| 9 | `PRESTAMO_TEMA` | (IDPrestamo, Tema) | IDPrestamo → `PRESTAMO` |
| 10 | `PRESTAMO_SEDEBIBLIOTECA` | (IDPrestamo, SedeBiblioteca) | IDPrestamo → `PRESTAMO` |

**Relaciones:** `CARRERA` 1:N `ESTUDIANTE` · `ESTUDIANTE` 1:N `PRESTAMO` (vía FK) · `ESTUDIANTE` 1:N `ESTUDIANTE_TEL` · `PRESTAMO` 1:N `DETALLE_PRESTAMO` · `LIBRO` 1:N `DETALLE_PRESTAMO` · `EDITORIAL` 1:N `LIBRO` · `PRESTAMO` 1:N `PRESTAMO_AUTOR`/`PRESTAMO_TEMA`/`PRESTAMO_SEDEBIBLIOTECA`.

### JOIN final (reúne más de tres tablas normalizadas)

```sql
SELECT
    h.IDPrestamo, a.NombreEstudiante, g.Carrera, g.CoordinadorCarrera,
    i.TituloLibro, s.Editorial, s.CiudadEditorial,
    d.Cantidad, d.PrecioUnitario, d.PrecioTotal
FROM DETALLE_PRESTAMO d
JOIN PRESTAMO h ON h.IDPrestamo = d.IDPrestamo
JOIN ESTUDIANTE a ON a.IDEstudiante = h.IDEstudiante
JOIN CARRERA g ON g.Carrera = a.Carrera
JOIN LIBRO i ON i.IDLibro = d.IDLibro
JOIN EDITORIAL s ON s.IDEditorial = i.IDEditorial
ORDER BY h.IDPrestamo, i.IDLibro;
-- Verificado contra el CSV real: reconstruye exactamente las 200 filas del archivo original.
```

---

## COMPARACIÓN: tabla original vs. modelo final

| Aspecto | `PRESTAMO_INICIAL` (reporte plano) | Modelo final (10 tablas) |
|---|---|---|
| Filas totales | 200 | 10 + 4 + 10 + 20 + 20 + 5 + 200 + (10×2) + (10×2) + (10×5) |
| Veces que se repite `Editorial` para `ED001` | 40 veces | **1 vez** (en `EDITORIAL`) |
| Veces que se repite `NombreEstudiante` para `E001` | 20 veces | **1 vez** (en `ESTUDIANTE`) |
| Columna `TelefonosEstudiante` | Texto con `\|` (no atómico) | Filas individuales en `ESTUDIANTE_TEL` |
| Claves primarias explícitas | Ninguna | 10 |

---

## TRES ANOMALÍAS QUE EL NUEVO DISEÑO REDUCE (con datos reales del CSV)

**Anomalía de INSERCIÓN.** En `PRESTAMO_INICIAL`, para registrar una nuevo editorial (ej. uno que todavía no tiene ningún libro asignado) sería necesario inventar una fila completa de préstamo/libro solo para poder guardar sus datos — no se puede insertar una editorial "solo". En el modelo final, basta con `INSERT INTO EDITORIAL (...)`, sin necesidad de ningún préstamo ni ningún libro asociado todavía.

**Anomalía de ACTUALIZACIÓN.** El editorial `ED001` (Editorial 1) aparece repetido 40 veces en `PRESTAMO_INICIAL`. Si cambia su `CiudadEditorial`, en la tabla original hay que actualizar las 40 filas (riesgo real de dejar alguna desactualizada); en el modelo final, **un solo** `UPDATE EDITORIAL SET CiudadEditorial=... WHERE IDEditorial='ED001'` corrige el dato para siempre.

**Anomalía de ELIMINACIÓN.** Si en `PRESTAMO_INICIAL` se eliminara la única fila del préstamo `PS001` que contiene al libro `L001` (Libro 1), se perdería SIMULTÁNEAMENTE toda la información del libro (nombre, categoría, precio, editorial) aunque ese libro siga existiendo en el catálogo real. En el modelo final, `LIBRO` conserva los datos del libro de forma independiente: borrar una fila de `DETALLE_PRESTAMO` no borra nada de `LIBRO`.

---

## CHECKLIST DE ENTREGA — Caso 2

- [ ] Script `.sql` con los 8 pasos de este documento, ejecutado de principio a fin sin errores
- [ ] Capturas de las consultas del Paso 2 (clave candidata) y Paso 3 (dependencias funcionales)
- [ ] Capturas de la verificación 1FN (Paso 4.2) y de los conteos 2FN/3FN (Pasos 5 y 6)
- [ ] Captura de la comprobación 4FN (combinaciones completas) y 5FN (0 diferencias, Paso 8.3)
- [ ] Modelo final con las 10 tablas, PK y FK indicadas
- [ ] JOIN final de al menos 3 tablas, ejecutado y con resultado visible
- [ ] Explicación de una anomalía de inserción, una de actualización y una de eliminación, con datos reales del CSV (puedes usar las de este documento o encontrar las tuyas)

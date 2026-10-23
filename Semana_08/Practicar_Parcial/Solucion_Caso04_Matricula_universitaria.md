# SOLUCIÓN — Caso 4. Matrícula universitaria
## Laboratorio 6 de Base de Datos — Normalización 1FN · 2FN · 3FN · 4FN · 5FN

**Archivo de datos:** `04_Matricula_Universitaria_200.csv` (200 registros reales, ya cargados y verificados para esta solución)
**Base de datos a crear en SQL Server:** `Lab06_Caso04`

> **Antes de empezar:** si todavía no sabes cómo importar un CSV a SQL Server 2022, abre primero
> [`00_COMO_IMPORTAR_CSV_SQLSERVER22.md`](00_COMO_IMPORTAR_CSV_SQLSERVER22.md) — son los mismos 10 pasos para los 10 casos del laboratorio, aquí no se repiten.
>
> **Verificación de esta solución:** todas las consultas de este documento (claves, dependencias funcionales, cardinalidades, reconstrucción por JOIN) fueron ejecutadas y comprobadas contra el archivo CSV real con un motor de prueba — los números que aparecen (filas, conteos, violaciones) son los resultados reales del archivo, no estimaciones. La sintaxis T-SQL (`STRING_SPLIT`, `IDENTITY`, etc.) es válida en SQL Server 2022; se recomienda correr el script completo en tu propio SQL Server antes de la clase.

---

## Contexto y problemática (del enunciado de la guía)

**Contexto.** Una universidad registra matrículas, alumnos, cursos, docentes, recursos, horarios y campus en una tabla general.

**Problemática.** La tabla mezcla datos académicos y de matrícula. Cambiar un curso, docente u oficina obliga a modificar muchas filas.

---

## PASO 0 — Crear la base de datos

```sql
DROP DATABASE IF EXISTS Lab06_Caso04;
CREATE DATABASE Lab06_Caso04;
USE Lab06_Caso04;
```

---

## PASO 1 — Explorar los 200 registros (hallazgos antes de tocar la estructura)

Abre la tabla ya importada (ver guía de importación) y mira las primeras filas:

```sql
SELECT TOP 10 * FROM MATRICULA_INICIAL;
```

**Tres hallazgos que debes anotar antes de modificar nada** (ya verificados en este archivo):

1. **Dato repetido de docente:** el docente `D001` (Docente 1) aparece repetido en varias filas, siempre con el mismo nombre — exactamente el patrón que genera riesgo de inconsistencia si alguien actualiza una sola fila y olvida las demás.
2. **Valor no atómico en `TelefonosAlumno`:** la columna trae dos valores en una sola celda separados por `|` (ejemplo real: `95000001|95100001`) — viola la atomicidad exigida por 1FN.
3. **Clave simple insuficiente:** ni `IDMatricula` ni `IDCurso` identifican una fila por sí solos — `IDMatricula` se repite 20 veces (una por cada curso) y `IDCurso` se repite 10 veces (una por cada matrícula); se necesita la combinación de ambos.

---

## PASO 2 — Determinar la clave candidata (COUNT + GROUP BY)

```sql
-- 2.1  ¿Es IDMatricula suficiente por sí solo?
SELECT IDMatricula, COUNT(*) AS Filas
FROM MATRICULA_INICIAL
GROUP BY IDMatricula;
-- Resultado real: 10 valores distintos de IDMatricula, cada uno con 20 filas -> NO es clave por sí solo.
```

```sql
-- 2.2  ¿Es IDCurso suficiente por sí solo?
SELECT IDCurso, COUNT(*) AS Filas
FROM MATRICULA_INICIAL
GROUP BY IDCurso;
-- Resultado real: 20 valores distintos de IDCurso, cada uno con 10 filas -> NO es clave por sí solo.
```

```sql
-- 2.3  ¿La combinación (IDMatricula, IDCurso) identifica una fila única?
SELECT IDMatricula, IDCurso, COUNT(*) AS Filas
FROM MATRICULA_INICIAL
GROUP BY IDMatricula, IDCurso
HAVING COUNT(*) > 1;
-- Resultado real: 0 filas devueltas -> cada combinación aparece EXACTAMENTE una vez.
```

**Clave candidata: {IDMatricula, IDCurso}** (clave compuesta).

---

## PASO 3 — Identificar las dependencias funcionales (con evidencia real del CSV)

```sql
-- DF 1:  IDAlumno -> NombreAlumno, Escuela, TelefonosAlumno
SELECT IDAlumno, NombreAlumno, Escuela, TelefonosAlumno
FROM MATRICULA_INICIAL
WHERE IDAlumno = 'A001';
```
**Evidencia (2 filas reales, mismo `IDAlumno`, 20 veces en total — aquí solo 2):**
| IDAlumno | NombreAlumno | Escuela | TelefonosAlumno |
|---|---|---|---|
| A001 | Alumno 1 | Escuela 1 | 95000001\|95100001 |
| A001 | Alumno 1 | Escuela 1 | 95000001\|95100001 |

Siempre el mismo nombre, escuela y teléfonos para `A001` → **`IDAlumno → NombreAlumno, Escuela, TelefonosAlumno`** se confirma.

```sql
-- DF 2:  Escuela -> DirectorEscuela
SELECT DISTINCT Escuela, DirectorEscuela
FROM MATRICULA_INICIAL
WHERE Escuela = 'Escuela 1';
```
**Evidencia:** `Escuela 1` siempre trae `DirectorEscuela` = `Director 1` → **`Escuela → DirectorEscuela`** se confirma.

```sql
-- DF 3:  IDCurso -> NombreCurso, AreaAcademica, PrecioUnitario, IDDocente
SELECT IDCurso, NombreCurso, AreaAcademica, PrecioUnitario, IDDocente
FROM MATRICULA_INICIAL
WHERE IDCurso = 'CU001'
ORDER BY IDMatricula;
```
**Evidencia (2 filas reales, mismo `IDCurso`, en matriculas distintas — demuestra que NO depende de `IDMatricula`):**
| IDCurso | NombreCurso | AreaAcademica | PrecioUnitario | IDDocente |
|---|---|---|---|---|
| CU001 | Curso 1 | Area 1 | 105 | D001 |
| CU001 | Curso 1 | Area 1 | 105 | D001 |

**`IDCurso → NombreCurso, AreaAcademica, PrecioUnitario, IDDocente`** se confirma: el precio y el docente del curso no cambian aunque cambie la matrícula.

```sql
-- DF 4:  IDDocente -> NombreDocente, OficinaDocente
SELECT DISTINCT IDDocente, NombreDocente, OficinaDocente
FROM MATRICULA_INICIAL
WHERE IDDocente = 'D001';
```
**Evidencia:** `D001` siempre trae `NombreDocente` = `Docente 1` y `OficinaDocente` = `Oficina 1` → **`IDDocente → NombreDocente, OficinaDocente`** se confirma.

```sql
-- DF 5 (dependencia COMPLETA, no parcial):  (IDMatricula, IDCurso) -> Cantidad, PrecioTotal
SELECT IDMatricula, IDCurso, Cantidad, PrecioTotal
FROM MATRICULA_INICIAL
WHERE IDCurso = 'CU001'
ORDER BY IDMatricula;
-- Observa: el mismo IDCurso trae distinta Cantidad/PrecioTotal según la matrícula -> depende de LA CLAVE COMPLETA, no de una parte.
```

---

## PASO 4 — Primera Forma Normal (1FN)

**Violación encontrada:** `TelefonosAlumno` no es atómica (trae `95000001|95100001`, 2 valores en una celda).

```sql
-- 4.1  Separar el valor multivaluado en su propia tabla
CREATE TABLE ALUMNO_TELEFONO (
    IDAlumno VARCHAR(10)  NOT NULL,
    Valor            VARCHAR(30) NOT NULL,
    CONSTRAINT PK_ALUMNO_TELEFONO PRIMARY KEY (IDAlumno, Valor)
);

INSERT INTO ALUMNO_TELEFONO (IDAlumno, Valor)
SELECT DISTINCT IDAlumno, LTRIM(RTRIM(valor.value))
FROM MATRICULA_INICIAL
CROSS APPLY STRING_SPLIT(TelefonosAlumno, '|') AS valor;
```

```sql
-- 4.2  Verificar 1FN: debe haber 20 filas (= 10 alumnos x 2 teléfonos cada uno)
SELECT COUNT(*) AS Filas FROM ALUMNO_TELEFONO;
```

```sql
-- 4.3  Crear la tabla en 1FN: mismas columnas MENOS la multivaluada, con PK compuesta
CREATE TABLE MATRICULA_1FN (
    IDMatricula        VARCHAR(10)   NOT NULL,
    IDAlumno        VARCHAR(10)   NOT NULL,
    NombreAlumno       NVARCHAR(80)  NOT NULL,
    Escuela        NVARCHAR(40)  NOT NULL,
    DirectorEscuela     NVARCHAR(40)  NOT NULL,
    IDCurso        VARCHAR(10)   NOT NULL,
    NombreCurso       NVARCHAR(80)  NOT NULL,
    AreaAcademica       NVARCHAR(40)  NOT NULL,
    PrecioUnitario       DECIMAL(10,2) NOT NULL,
    Cantidad      INT           NOT NULL,
    PrecioTotal      DECIMAL(10,2) NOT NULL,
    IDDocente        VARCHAR(10)   NOT NULL,
    NombreDocente       NVARCHAR(80)  NOT NULL,
    OficinaDocente       NVARCHAR(40)  NOT NULL,
    RecursoCurso       NVARCHAR(40)  NOT NULL,
    HorarioCurso       NVARCHAR(40)  NOT NULL,
    Campus       NVARCHAR(40)  NOT NULL,
    CONSTRAINT PK_MATRICULA_1FN PRIMARY KEY (IDMatricula, IDCurso)
);

INSERT INTO MATRICULA_1FN
SELECT IDMatricula,IDAlumno,NombreAlumno,Escuela,DirectorEscuela,IDCurso,NombreCurso,AreaAcademica,PrecioUnitario,Cantidad,PrecioTotal,IDDocente,NombreDocente,OficinaDocente,RecursoCurso,HorarioCurso,Campus
FROM MATRICULA_INICIAL;

SELECT COUNT(*) AS Filas FROM MATRICULA_1FN;   -- debe devolver 200
```

✅ **Cumple 1FN:** cada celda tiene un único valor; la clave compuesta (IDMatricula, IDCurso) identifica cada fila sin ambigüedad.

---

## PASO 5 — Segunda Forma Normal (2FN): eliminar dependencias parciales

Atributos que dependen SOLO de `IDMatricula` (parte de la clave): `IDAlumno, NombreAlumno, Escuela, DirectorEscuela`.
Atributos que dependen SOLO de `IDCurso` (la otra parte): `NombreCurso, AreaAcademica, PrecioUnitario, IDDocente, NombreDocente, OficinaDocente`.
Atributos que dependen de LA CLAVE COMPLETA: `Cantidad, PrecioTotal`.

```sql
-- 5.1  Lado de matrícula (todo lo que depende solo de IDMatricula)
CREATE TABLE MATRICULA_2FN (
    IDMatricula    VARCHAR(10)  NOT NULL,
    IDAlumno    VARCHAR(10)  NOT NULL,
    NombreAlumno   NVARCHAR(80) NOT NULL,
    Escuela    NVARCHAR(40) NOT NULL,
    DirectorEscuela NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_MATRICULA_2FN PRIMARY KEY (IDMatricula)
);
INSERT INTO MATRICULA_2FN
SELECT DISTINCT IDMatricula,IDAlumno,NombreAlumno,Escuela,DirectorEscuela FROM MATRICULA_1FN;

-- 5.2  Lado del curso (todo lo que depende solo de IDCurso)
CREATE TABLE CURSO_2FN (
    IDCurso  VARCHAR(10)   NOT NULL,
    NombreCurso NVARCHAR(80)  NOT NULL,
    AreaAcademica NVARCHAR(40)  NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    IDDocente  VARCHAR(10)   NOT NULL,
    NombreDocente NVARCHAR(80)  NOT NULL,
    OficinaDocente NVARCHAR(40)  NOT NULL,
    CONSTRAINT PK_CURSO_2FN PRIMARY KEY (IDCurso)
);
INSERT INTO CURSO_2FN
SELECT DISTINCT IDCurso,NombreCurso,AreaAcademica,PrecioUnitario,IDDocente,NombreDocente,OficinaDocente FROM MATRICULA_1FN;

-- 5.3  Detalle: solo lo que depende de LA CLAVE COMPLETA (+ precio histórico de la transacción)
CREATE TABLE DETALLE_MATRICULA (
    IDMatricula    VARCHAR(10)   NOT NULL,
    IDCurso    VARCHAR(10)   NOT NULL,
    PrecioUnitario   DECIMAL(10,2) NOT NULL,   -- precio histórico al momento de la transacción
    Cantidad  INT           NOT NULL,
    PrecioTotal  DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_DETALLE_MATRICULA PRIMARY KEY (IDMatricula, IDCurso),
    CONSTRAINT FK_DETALLE_MATRICULA_CURSO FOREIGN KEY (IDCurso) REFERENCES CURSO_2FN(IDCurso)
);
INSERT INTO DETALLE_MATRICULA (IDMatricula,IDCurso,PrecioUnitario,Cantidad,PrecioTotal)
SELECT IDMatricula,IDCurso,PrecioUnitario,Cantidad,PrecioTotal FROM MATRICULA_1FN;
```

```sql
-- Verificación: MATRICULA_2FN debe tener 10 filas, CURSO_2FN debe tener 20 filas, DETALLE_MATRICULA debe tener 200 filas
SELECT COUNT(*) FROM MATRICULA_2FN;   -- 10
SELECT COUNT(*) FROM CURSO_2FN;   -- 20
SELECT COUNT(*) FROM DETALLE_MATRICULA;  -- 200
```

> **¿Por qué se conserva `PrecioUnitario` también en `DETALLE_MATRICULA`?** Para guardar el precio **histórico** de esa transacción puntual. El precio "actual" del catálogo vive en `CURSO_2FN`; si el precio de catálogo cambia mañana, las transacciones ya registradas no deben cambiar retroactivamente.

---

## PASO 6 — Tercera Forma Normal (3FN): eliminar dependencias transitivas

Dos cadenas transitivas detectadas:
- `IDMatricula → IDAlumno → NombreAlumno, Escuela` y `Escuela → DirectorEscuela` (cadena de 3: `IDMatricula → Escuela → DirectorEscuela`)
- `IDCurso → IDDocente → NombreDocente, OficinaDocente` (cadena: `IDCurso → IDDocente → NombreDocente, OficinaDocente`)

```sql
-- 6.1  Separar ESCUELA (resuelve Escuela -> DirectorEscuela)
CREATE TABLE ESCUELA (
    Escuela    NVARCHAR(40) NOT NULL,
    DirectorEscuela NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_ESCUELA PRIMARY KEY (Escuela)
);
INSERT INTO ESCUELA SELECT DISTINCT Escuela,DirectorEscuela FROM MATRICULA_2FN;

-- 6.2  ALUMNO definitivo (ya sin Escuela repetido con el responsable adentro; Escuela queda como FK)
CREATE TABLE ALUMNO (
    IDAlumno  VARCHAR(10)  NOT NULL,
    NombreAlumno NVARCHAR(80) NOT NULL,
    Escuela  NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_ALUMNO PRIMARY KEY (IDAlumno),
    CONSTRAINT FK_ALUMNO_ESCUELA FOREIGN KEY (Escuela) REFERENCES ESCUELA(Escuela)
);
INSERT INTO ALUMNO SELECT DISTINCT IDAlumno,NombreAlumno,Escuela FROM MATRICULA_2FN;

-- 6.3  MATRICULA definitivo (solo el id de matrícula + FK al alumno)
CREATE TABLE MATRICULA (
    IDMatricula VARCHAR(10) NOT NULL,
    IDAlumno VARCHAR(10) NOT NULL,
    CONSTRAINT PK_MATRICULA PRIMARY KEY (IDMatricula),
    CONSTRAINT FK_MATRICULA_ALUMNO FOREIGN KEY (IDAlumno) REFERENCES ALUMNO(IDAlumno)
);
INSERT INTO MATRICULA SELECT IDMatricula,IDAlumno FROM MATRICULA_2FN;

-- 6.4  Separar DOCENTE (resuelve IDCurso -> IDDocente -> NombreDocente,OficinaDocente)
CREATE TABLE DOCENTE (
    IDDocente  VARCHAR(10)  NOT NULL,
    NombreDocente NVARCHAR(80) NOT NULL,
    OficinaDocente NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_DOCENTE PRIMARY KEY (IDDocente)
);
INSERT INTO DOCENTE SELECT DISTINCT IDDocente,NombreDocente,OficinaDocente FROM CURSO_2FN;

-- 6.5  CURSO definitivo (ya sin los datos del docente adentro; IDDocente queda como FK)
CREATE TABLE CURSO (
    IDCurso  VARCHAR(10)   NOT NULL,
    NombreCurso NVARCHAR(80)  NOT NULL,
    AreaAcademica NVARCHAR(40)  NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    IDDocente  VARCHAR(10)   NOT NULL,
    CONSTRAINT PK_CURSO PRIMARY KEY (IDCurso),
    CONSTRAINT FK_CURSO_DOCENTE FOREIGN KEY (IDDocente) REFERENCES DOCENTE(IDDocente)
);
INSERT INTO CURSO SELECT IDCurso,NombreCurso,AreaAcademica,PrecioUnitario,IDDocente FROM CURSO_2FN;
```

```sql
-- Verificación: ESCUELA=4 filas | ALUMNO=10 filas | MATRICULA=10 filas | DOCENTE=5 filas | CURSO=20 filas
SELECT COUNT(*) FROM ESCUELA;  SELECT COUNT(*) FROM ALUMNO;  SELECT COUNT(*) FROM MATRICULA;
SELECT COUNT(*) FROM DOCENTE;  SELECT COUNT(*) FROM CURSO;
```

✅ **Cumple 3FN:** ningún atributo no-clave depende de otro atributo no-clave; todo depende directamente de la clave de su propia tabla.

---

## PASO 7 — Cuarta Forma Normal (4FN): hechos multivaluados independientes

**Hallazgo (grano = un `IDMatricula`):** dentro de una misma matrícula (ejemplo real `MAT001`, con sus 20 filas), `RecursoCurso` toma **2** valores distintos (Libro, Video) y `HorarioCurso` toma **2** valores distintos (Lunes, Miercoles) — y aparecen **todas** las combinaciones posibles entre ambos (evidencia de que son independientes entre sí para la misma operación, no uno depende del otro).

```sql
-- Evidencia: ¿aparecen TODAS las combinaciones de RecursoCurso x HorarioCurso dentro de un mismo IDMatricula?
SELECT DISTINCT RecursoCurso, HorarioCurso
FROM MATRICULA_1FN
WHERE IDMatricula = 'MAT001'
ORDER BY RecursoCurso, HorarioCurso;
-- Resultado real: 4 combinaciones (= 2 x 2) -> confirma independencia (MVD).
```

```sql
-- 7.1  Separar los dos hechos multivaluados independientes
CREATE TABLE MATRICULA_RECURSOCURSO (
    IDMatricula  VARCHAR(10)  NOT NULL,
    RecursoCurso NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_MATRICULA_RECURSOCURSO PRIMARY KEY (IDMatricula, RecursoCurso)
);
INSERT INTO MATRICULA_RECURSOCURSO SELECT DISTINCT IDMatricula,RecursoCurso FROM MATRICULA_1FN;

CREATE TABLE MATRICULA_HORARIOCURSO (
    IDMatricula  VARCHAR(10)  NOT NULL,
    HorarioCurso NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_MATRICULA_HORARIOCURSO PRIMARY KEY (IDMatricula, HorarioCurso)
);
INSERT INTO MATRICULA_HORARIOCURSO SELECT DISTINCT IDMatricula,HorarioCurso FROM MATRICULA_1FN;
```

> ⚠ **Nota honesta sobre estos datos.** En esta muestra, `IDCurso` TAMBIÉN determina `RecursoCurso` y `HorarioCurso` sin excepción (es un efecto de cómo se generó el archivo: los mismos 20 cursos se repiten idénticos en cada matrícula). Eso NO es una regla de negocio real — un curso no "tiene" un recurso fijo en la vida real. Tratamos `RecursoCurso` y `HorarioCurso` como hechos independientes de la **matrícula** (que es la lectura que pide el enunciado de la guía: "hechos multivaluados... para una misma operación"), no del curso. Coméntalo así en tu sustentación.

---

## PASO 8 — Quinta Forma Normal (5FN): relación ternaria y reconstrucción sin pérdida

Agregamos el tercer hecho, `Campus` (5 valores: Centro, Este, Norte, Sur, Virtual), y verificamos si la combinación de los **tres** (RecursoCurso, HorarioCurso, Campus) para un mismo `IDMatricula` se reconstruye exactamente uniendo tres tablas binarias — sin inventar combinaciones (filas espurias) ni perder ninguna.

```sql
-- 8.1  Tercera tabla
CREATE TABLE MATRICULA_CAMPUS (
    IDMatricula  VARCHAR(10)  NOT NULL,
    Campus NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_MATRICULA_CAMPUS PRIMARY KEY (IDMatricula, Campus)
);
INSERT INTO MATRICULA_CAMPUS SELECT DISTINCT IDMatricula,Campus FROM MATRICULA_1FN;
```

```sql
-- 8.2  Verificación de reconstrucción (debe devolver exactamente 20 filas para 'MAT001', ni una más ni una menos)
SELECT c1.IDMatricula, c1.RecursoCurso, c2.HorarioCurso, c3.Campus
FROM MATRICULA_RECURSOCURSO c1
JOIN MATRICULA_HORARIOCURSO c2 ON c2.IDMatricula = c1.IDMatricula
JOIN MATRICULA_CAMPUS c3 ON c3.IDMatricula = c1.IDMatricula
WHERE c1.IDMatricula = 'MAT001'
ORDER BY c1.RecursoCurso, c2.HorarioCurso, c3.Campus;
```

```sql
-- 8.3  Comprobación automática contra la tabla original (0 = reconstrucción exacta)
SELECT COUNT(*) AS Diferencias FROM (
    SELECT RecursoCurso,HorarioCurso,Campus FROM MATRICULA_1FN WHERE IDMatricula='MAT001'
    EXCEPT
    SELECT c1.RecursoCurso, c2.HorarioCurso, c3.Campus
    FROM MATRICULA_RECURSOCURSO c1
    JOIN MATRICULA_HORARIOCURSO c2 ON c2.IDMatricula=c1.IDMatricula
    JOIN MATRICULA_CAMPUS c3 ON c3.IDMatricula=c1.IDMatricula
    WHERE c1.IDMatricula='MAT001'
) AS Diff;
-- Verificado contra el CSV real: 0 diferencias -> descomposición SIN PÉRDIDA.
```

✅ **Cumple 5FN:** la relación ternaria se reconstruye exactamente mediante el JOIN de las tres tablas binarias — no hace falta guardar una tabla de 3 columnas.

---

## MODELO FINAL

| # | Tabla | Clave primaria (PK) | Claves foráneas (FK) |
|---|---|---|---|
| 1 | `ESCUELA` | Escuela | — |
| 2 | `ALUMNO` | IDAlumno | Escuela → `ESCUELA` |
| 3 | `ALUMNO_TELEFONO` | (IDAlumno, Valor) | IDAlumno → `ALUMNO` |
| 4 | `MATRICULA` | IDMatricula | IDAlumno → `ALUMNO` |
| 5 | `DOCENTE` | IDDocente | — |
| 6 | `CURSO` | IDCurso | IDDocente → `DOCENTE` |
| 7 | `DETALLE_MATRICULA` | (IDMatricula, IDCurso) | IDMatricula → `MATRICULA` · IDCurso → `CURSO` |
| 8 | `MATRICULA_RECURSOCURSO` | (IDMatricula, RecursoCurso) | IDMatricula → `MATRICULA` |
| 9 | `MATRICULA_HORARIOCURSO` | (IDMatricula, HorarioCurso) | IDMatricula → `MATRICULA` |
| 10 | `MATRICULA_CAMPUS` | (IDMatricula, Campus) | IDMatricula → `MATRICULA` |

**Relaciones:** `ESCUELA` 1:N `ALUMNO` · `ALUMNO` 1:N `MATRICULA` (vía FK) · `ALUMNO` 1:N `ALUMNO_TEL` · `MATRICULA` 1:N `DETALLE_MATRICULA` · `CURSO` 1:N `DETALLE_MATRICULA` · `DOCENTE` 1:N `CURSO` · `MATRICULA` 1:N `MATRICULA_RECURSOCURSO`/`MATRICULA_HORARIOCURSO`/`MATRICULA_CAMPUS`.

### JOIN final (reúne más de tres tablas normalizadas)

```sql
SELECT
    h.IDMatricula, a.NombreAlumno, g.Escuela, g.DirectorEscuela,
    i.NombreCurso, s.NombreDocente, s.OficinaDocente,
    d.Cantidad, d.PrecioUnitario, d.PrecioTotal
FROM DETALLE_MATRICULA d
JOIN MATRICULA h ON h.IDMatricula = d.IDMatricula
JOIN ALUMNO a ON a.IDAlumno = h.IDAlumno
JOIN ESCUELA g ON g.Escuela = a.Escuela
JOIN CURSO i ON i.IDCurso = d.IDCurso
JOIN DOCENTE s ON s.IDDocente = i.IDDocente
ORDER BY h.IDMatricula, i.IDCurso;
-- Verificado contra el CSV real: reconstruye exactamente las 200 filas del archivo original.
```

---

## COMPARACIÓN: tabla original vs. modelo final

| Aspecto | `MATRICULA_INICIAL` (reporte plano) | Modelo final (10 tablas) |
|---|---|---|
| Filas totales | 200 | 10 + 4 + 10 + 20 + 20 + 5 + 200 + (10×2) + (10×2) + (10×5) |
| Veces que se repite `NombreDocente` para `D001` | 40 veces | **1 vez** (en `DOCENTE`) |
| Veces que se repite `NombreAlumno` para `A001` | 20 veces | **1 vez** (en `ALUMNO`) |
| Columna `TelefonosAlumno` | Texto con `\|` (no atómico) | Filas individuales en `ALUMNO_TEL` |
| Claves primarias explícitas | Ninguna | 10 |

---

## TRES ANOMALÍAS QUE EL NUEVO DISEÑO REDUCE (con datos reales del CSV)

**Anomalía de INSERCIÓN.** En `MATRICULA_INICIAL`, para registrar un nuevo docente (ej. uno que todavía no tiene ningún curso asignado) sería necesario inventar una fila completa de matrícula/curso solo para poder guardar sus datos — no se puede insertar un docente "solo". En el modelo final, basta con `INSERT INTO DOCENTE (...)`, sin necesidad de ninguna matrícula ni ningún curso asociado todavía.

**Anomalía de ACTUALIZACIÓN.** El docente `D001` (Docente 1) aparece repetido 40 veces en `MATRICULA_INICIAL`. Si cambia su `OficinaDocente`, en la tabla original hay que actualizar las 40 filas (riesgo real de dejar alguna desactualizada); en el modelo final, **un solo** `UPDATE DOCENTE SET OficinaDocente=... WHERE IDDocente='D001'` corrige el dato para siempre.

**Anomalía de ELIMINACIÓN.** Si en `MATRICULA_INICIAL` se eliminara la única fila de matrícula `MAT001` que contiene al curso `CU001` (Curso 1), se perdería SIMULTÁNEAMENTE toda la información del curso (nombre, categoría, precio, docente) aunque ese curso siga existiendo en el catálogo real. En el modelo final, `CURSO` conserva los datos del curso de forma independiente: borrar una fila de `DETALLE_MATRICULA` no borra nada de `CURSO`.

---

## CHECKLIST DE ENTREGA — Caso 4

- [ ] Script `.sql` con los 8 pasos de este documento, ejecutado de principio a fin sin errores
- [ ] Capturas de las consultas del Paso 2 (clave candidata) y Paso 3 (dependencias funcionales)
- [ ] Capturas de la verificación 1FN (Paso 4.2) y de los conteos 2FN/3FN (Pasos 5 y 6)
- [ ] Captura de la comprobación 4FN (combinaciones completas) y 5FN (0 diferencias, Paso 8.3)
- [ ] Modelo final con las 10 tablas, PK y FK indicadas
- [ ] JOIN final de al menos 3 tablas, ejecutado y con resultado visible
- [ ] Explicación de una anomalía de inserción, una de actualización y una de eliminación, con datos reales del CSV (puedes usar las de este documento o encontrar las tuyas)

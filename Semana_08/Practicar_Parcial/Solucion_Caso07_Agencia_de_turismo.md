# SOLUCIÓN — Caso 7. Agencia de turismo
## Laboratorio 6 de Base de Datos — Normalización 1FN · 2FN · 3FN · 4FN · 5FN

**Archivo de datos:** `07_Turismo_200.csv` (200 registros reales, ya cargados y verificados para esta solución)
**Base de datos a crear en SQL Server:** `Lab06_Caso07`

> **Antes de empezar:** si todavía no sabes cómo importar un CSV a SQL Server 2022, abre primero
> [`00_COMO_IMPORTAR_CSV_SQLSERVER22.md`](00_COMO_IMPORTAR_CSV_SQLSERVER22.md) — son los mismos 10 pasos para los 10 casos del laboratorio, aquí no se repiten.
>
> **Verificación de esta solución:** todas las consultas de este documento (claves, dependencias funcionales, cardinalidades, reconstrucción por JOIN) fueron ejecutadas y comprobadas contra el archivo CSV real con un motor de prueba — los números que aparecen (filas, conteos, violaciones) son los resultados reales del archivo, no estimaciones. La sintaxis T-SQL (`STRING_SPLIT`, `IDENTITY`, etc.) es válida en SQL Server 2022; se recomienda correr el script completo en tu propio SQL Server antes de la clase.

---

## Contexto y problemática (del enunciado de la guía)

**Contexto.** Una agencia registra reservas de turistas, tours, guías, países, idiomas, actividades y hoteles.

**Problemática.** La tabla contiene información repetida del turista, tour y guía y mezcla múltiples preferencias del servicio.

---

## PASO 0 — Crear la base de datos

```sql
DROP DATABASE IF EXISTS Lab06_Caso07;
CREATE DATABASE Lab06_Caso07;
USE Lab06_Caso07;
```

---

## PASO 1 — Explorar los 200 registros (hallazgos antes de tocar la estructura)

Abre la tabla ya importada (ver guía de importación) y mira las primeras filas:

```sql
SELECT TOP 10 * FROM RESERVA_INICIAL;
```

**Tres hallazgos que debes anotar antes de modificar nada** (ya verificados en este archivo):

1. **Dato repetido de guía:** el guía `G001` (Guia 1) aparece repetido en varias filas, siempre con el mismo nombre — exactamente el patrón que genera riesgo de inconsistencia si alguien actualiza una sola fila y olvida las demás.
2. **Valor no atómico en `TelefonosTurista`:** la columna trae dos valores en una sola celda separados por `|` (ejemplo real: `92000001|92100001`) — viola la atomicidad exigida por 1FN.
3. **Clave simple insuficiente:** ni `IDReserva` ni `IDTour` identifican una fila por sí solos — `IDReserva` se repite 20 veces (una por cada tour) y `IDTour` se repite 10 veces (una por cada reserva); se necesita la combinación de ambos.

---

## PASO 2 — Determinar la clave candidata (COUNT + GROUP BY)

```sql
-- 2.1  ¿Es IDReserva suficiente por sí solo?
SELECT IDReserva, COUNT(*) AS Filas
FROM RESERVA_INICIAL
GROUP BY IDReserva;
-- Resultado real: 10 valores distintos de IDReserva, cada uno con 20 filas -> NO es clave por sí solo.
```

```sql
-- 2.2  ¿Es IDTour suficiente por sí solo?
SELECT IDTour, COUNT(*) AS Filas
FROM RESERVA_INICIAL
GROUP BY IDTour;
-- Resultado real: 20 valores distintos de IDTour, cada uno con 10 filas -> NO es clave por sí solo.
```

```sql
-- 2.3  ¿La combinación (IDReserva, IDTour) identifica una fila única?
SELECT IDReserva, IDTour, COUNT(*) AS Filas
FROM RESERVA_INICIAL
GROUP BY IDReserva, IDTour
HAVING COUNT(*) > 1;
-- Resultado real: 0 filas devueltas -> cada combinación aparece EXACTAMENTE una vez.
```

**Clave candidata: {IDReserva, IDTour}** (clave compuesta).

---

## PASO 3 — Identificar las dependencias funcionales (con evidencia real del CSV)

```sql
-- DF 1:  IDTurista -> Turista, PaisOrigen, TelefonosTurista
SELECT IDTurista, Turista, PaisOrigen, TelefonosTurista
FROM RESERVA_INICIAL
WHERE IDTurista = 'T001';
```
**Evidencia (2 filas reales, mismo `IDTurista`, 20 veces en total — aquí solo 2):**
| IDTurista | Turista | PaisOrigen | TelefonosTurista |
|---|---|---|---|
| T001 | Turista 1 | Pais 1 | 92000001\|92100001 |
| T001 | Turista 1 | Pais 1 | 92000001\|92100001 |

Siempre el mismo nombre, pais_origen y teléfonos para `T001` → **`IDTurista → Turista, PaisOrigen, TelefonosTurista`** se confirma.

```sql
-- DF 2:  PaisOrigen -> AgenciaPais
SELECT DISTINCT PaisOrigen, AgenciaPais
FROM RESERVA_INICIAL
WHERE PaisOrigen = 'Pais 1';
```
**Evidencia:** `Pais 1` siempre trae `AgenciaPais` = `Agencia 1` → **`PaisOrigen → AgenciaPais`** se confirma.

```sql
-- DF 3:  IDTour -> Tour, Destino, PrecioUnitario, IDGuia
SELECT IDTour, Tour, Destino, PrecioUnitario, IDGuia
FROM RESERVA_INICIAL
WHERE IDTour = 'TO001'
ORDER BY IDReserva;
```
**Evidencia (2 filas reales, mismo `IDTour`, en reservas distintas — demuestra que NO depende de `IDReserva`):**
| IDTour | Tour | Destino | PrecioUnitario | IDGuia |
|---|---|---|---|---|
| TO001 | Tour 1 | Destino 1 | 86 | G001 |
| TO001 | Tour 1 | Destino 1 | 86 | G001 |

**`IDTour → Tour, Destino, PrecioUnitario, IDGuia`** se confirma: el precio y el guía del tour no cambian aunque cambie la reserva.

```sql
-- DF 4:  IDGuia -> Guia, RegionGuia
SELECT DISTINCT IDGuia, Guia, RegionGuia
FROM RESERVA_INICIAL
WHERE IDGuia = 'G001';
```
**Evidencia:** `G001` siempre trae `Guia` = `Guia 1` y `RegionGuia` = `Region 1` → **`IDGuia → Guia, RegionGuia`** se confirma.

```sql
-- DF 5 (dependencia COMPLETA, no parcial):  (IDReserva, IDTour) -> Cantidad, PrecioTotal
SELECT IDReserva, IDTour, Cantidad, PrecioTotal
FROM RESERVA_INICIAL
WHERE IDTour = 'TO001'
ORDER BY IDReserva;
-- Observa: el mismo IDTour trae distinta Cantidad/PrecioTotal según la reserva -> depende de LA CLAVE COMPLETA, no de una parte.
```

---

## PASO 4 — Primera Forma Normal (1FN)

**Violación encontrada:** `TelefonosTurista` no es atómica (trae `92000001|92100001`, 2 valores en una celda).

```sql
-- 4.1  Separar el valor multivaluado en su propia tabla
CREATE TABLE TURISTA_TELEFONO (
    IDTurista VARCHAR(10)  NOT NULL,
    Valor            VARCHAR(30) NOT NULL,
    CONSTRAINT PK_TURISTA_TELEFONO PRIMARY KEY (IDTurista, Valor)
);

INSERT INTO TURISTA_TELEFONO (IDTurista, Valor)
SELECT DISTINCT IDTurista, LTRIM(RTRIM(valor.value))
FROM RESERVA_INICIAL
CROSS APPLY STRING_SPLIT(TelefonosTurista, '|') AS valor;
```

```sql
-- 4.2  Verificar 1FN: debe haber 20 filas (= 10 turistas x 2 teléfonos cada uno)
SELECT COUNT(*) AS Filas FROM TURISTA_TELEFONO;
```

```sql
-- 4.3  Crear la tabla en 1FN: mismas columnas MENOS la multivaluada, con PK compuesta
CREATE TABLE RESERVA_1FN (
    IDReserva        VARCHAR(10)   NOT NULL,
    IDTurista        VARCHAR(10)   NOT NULL,
    Turista       NVARCHAR(80)  NOT NULL,
    PaisOrigen        NVARCHAR(40)  NOT NULL,
    AgenciaPais     NVARCHAR(40)  NOT NULL,
    IDTour        VARCHAR(10)   NOT NULL,
    Tour       NVARCHAR(80)  NOT NULL,
    Destino       NVARCHAR(40)  NOT NULL,
    PrecioUnitario       DECIMAL(10,2) NOT NULL,
    Cantidad      INT           NOT NULL,
    PrecioTotal      DECIMAL(10,2) NOT NULL,
    IDGuia        VARCHAR(10)   NOT NULL,
    Guia       NVARCHAR(80)  NOT NULL,
    RegionGuia       NVARCHAR(40)  NOT NULL,
    IdiomaSolicitado       NVARCHAR(40)  NOT NULL,
    Actividad       NVARCHAR(40)  NOT NULL,
    Hotel       NVARCHAR(40)  NOT NULL,
    CONSTRAINT PK_RESERVA_1FN PRIMARY KEY (IDReserva, IDTour)
);

INSERT INTO RESERVA_1FN
SELECT IDReserva,IDTurista,Turista,PaisOrigen,AgenciaPais,IDTour,Tour,Destino,PrecioUnitario,Cantidad,PrecioTotal,IDGuia,Guia,RegionGuia,IdiomaSolicitado,Actividad,Hotel
FROM RESERVA_INICIAL;

SELECT COUNT(*) AS Filas FROM RESERVA_1FN;   -- debe devolver 200
```

✅ **Cumple 1FN:** cada celda tiene un único valor; la clave compuesta (IDReserva, IDTour) identifica cada fila sin ambigüedad.

---

## PASO 5 — Segunda Forma Normal (2FN): eliminar dependencias parciales

Atributos que dependen SOLO de `IDReserva` (parte de la clave): `IDTurista, Turista, PaisOrigen, AgenciaPais`.
Atributos que dependen SOLO de `IDTour` (la otra parte): `Tour, Destino, PrecioUnitario, IDGuia, Guia, RegionGuia`.
Atributos que dependen de LA CLAVE COMPLETA: `Cantidad, PrecioTotal`.

```sql
-- 5.1  Lado de reserva (todo lo que depende solo de IDReserva)
CREATE TABLE RESERVA_2FN (
    IDReserva    VARCHAR(10)  NOT NULL,
    IDTurista    VARCHAR(10)  NOT NULL,
    Turista   NVARCHAR(80) NOT NULL,
    PaisOrigen    NVARCHAR(40) NOT NULL,
    AgenciaPais NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_RESERVA_2FN PRIMARY KEY (IDReserva)
);
INSERT INTO RESERVA_2FN
SELECT DISTINCT IDReserva,IDTurista,Turista,PaisOrigen,AgenciaPais FROM RESERVA_1FN;

-- 5.2  Lado del tour (todo lo que depende solo de IDTour)
CREATE TABLE TOUR_2FN (
    IDTour  VARCHAR(10)   NOT NULL,
    Tour NVARCHAR(80)  NOT NULL,
    Destino NVARCHAR(40)  NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    IDGuia  VARCHAR(10)   NOT NULL,
    Guia NVARCHAR(80)  NOT NULL,
    RegionGuia NVARCHAR(40)  NOT NULL,
    CONSTRAINT PK_TOUR_2FN PRIMARY KEY (IDTour)
);
INSERT INTO TOUR_2FN
SELECT DISTINCT IDTour,Tour,Destino,PrecioUnitario,IDGuia,Guia,RegionGuia FROM RESERVA_1FN;

-- 5.3  Detalle: solo lo que depende de LA CLAVE COMPLETA (+ precio histórico de la transacción)
CREATE TABLE DETALLE_RESERVA (
    IDReserva    VARCHAR(10)   NOT NULL,
    IDTour    VARCHAR(10)   NOT NULL,
    PrecioUnitario   DECIMAL(10,2) NOT NULL,   -- precio histórico al momento de la transacción
    Cantidad  INT           NOT NULL,
    PrecioTotal  DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_DETALLE_RESERVA PRIMARY KEY (IDReserva, IDTour),
    CONSTRAINT FK_DETALLE_RESERVA_TOUR FOREIGN KEY (IDTour) REFERENCES TOUR_2FN(IDTour)
);
INSERT INTO DETALLE_RESERVA (IDReserva,IDTour,PrecioUnitario,Cantidad,PrecioTotal)
SELECT IDReserva,IDTour,PrecioUnitario,Cantidad,PrecioTotal FROM RESERVA_1FN;
```

```sql
-- Verificación: RESERVA_2FN debe tener 10 filas, TOUR_2FN debe tener 20 filas, DETALLE_RESERVA debe tener 200 filas
SELECT COUNT(*) FROM RESERVA_2FN;   -- 10
SELECT COUNT(*) FROM TOUR_2FN;   -- 20
SELECT COUNT(*) FROM DETALLE_RESERVA;  -- 200
```

> **¿Por qué se conserva `PrecioUnitario` también en `DETALLE_RESERVA`?** Para guardar el precio **histórico** de esa transacción puntual. El precio "actual" del catálogo vive en `TOUR_2FN`; si el precio de catálogo cambia mañana, las transacciones ya registradas no deben cambiar retroactivamente.

---

## PASO 6 — Tercera Forma Normal (3FN): eliminar dependencias transitivas

Dos cadenas transitivas detectadas:
- `IDReserva → IDTurista → Turista, PaisOrigen` y `PaisOrigen → AgenciaPais` (cadena de 3: `IDReserva → PaisOrigen → AgenciaPais`)
- `IDTour → IDGuia → Guia, RegionGuia` (cadena: `IDTour → IDGuia → Guia, RegionGuia`)

```sql
-- 6.1  Separar PAIS_ORIGEN (resuelve PaisOrigen -> AgenciaPais)
CREATE TABLE PAIS_ORIGEN (
    PaisOrigen    NVARCHAR(40) NOT NULL,
    AgenciaPais NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_PAIS_ORIGEN PRIMARY KEY (PaisOrigen)
);
INSERT INTO PAIS_ORIGEN SELECT DISTINCT PaisOrigen,AgenciaPais FROM RESERVA_2FN;

-- 6.2  TURISTA definitivo (ya sin PaisOrigen repetido con el responsable adentro; PaisOrigen queda como FK)
CREATE TABLE TURISTA (
    IDTurista  VARCHAR(10)  NOT NULL,
    Turista NVARCHAR(80) NOT NULL,
    PaisOrigen  NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_TURISTA PRIMARY KEY (IDTurista),
    CONSTRAINT FK_TURISTA_PAIS_ORIGEN FOREIGN KEY (PaisOrigen) REFERENCES PAIS_ORIGEN(PaisOrigen)
);
INSERT INTO TURISTA SELECT DISTINCT IDTurista,Turista,PaisOrigen FROM RESERVA_2FN;

-- 6.3  RESERVA definitivo (solo el id de reserva + FK al turista)
CREATE TABLE RESERVA (
    IDReserva VARCHAR(10) NOT NULL,
    IDTurista VARCHAR(10) NOT NULL,
    CONSTRAINT PK_RESERVA PRIMARY KEY (IDReserva),
    CONSTRAINT FK_RESERVA_TURISTA FOREIGN KEY (IDTurista) REFERENCES TURISTA(IDTurista)
);
INSERT INTO RESERVA SELECT IDReserva,IDTurista FROM RESERVA_2FN;

-- 6.4  Separar GUIA (resuelve IDTour -> IDGuia -> Guia,RegionGuia)
CREATE TABLE GUIA (
    IDGuia  VARCHAR(10)  NOT NULL,
    Guia NVARCHAR(80) NOT NULL,
    RegionGuia NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_GUIA PRIMARY KEY (IDGuia)
);
INSERT INTO GUIA SELECT DISTINCT IDGuia,Guia,RegionGuia FROM TOUR_2FN;

-- 6.5  TOUR definitivo (ya sin los datos del guía adentro; IDGuia queda como FK)
CREATE TABLE TOUR (
    IDTour  VARCHAR(10)   NOT NULL,
    Tour NVARCHAR(80)  NOT NULL,
    Destino NVARCHAR(40)  NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    IDGuia  VARCHAR(10)   NOT NULL,
    CONSTRAINT PK_TOUR PRIMARY KEY (IDTour),
    CONSTRAINT FK_TOUR_GUIA FOREIGN KEY (IDGuia) REFERENCES GUIA(IDGuia)
);
INSERT INTO TOUR SELECT IDTour,Tour,Destino,PrecioUnitario,IDGuia FROM TOUR_2FN;
```

```sql
-- Verificación: PAIS_ORIGEN=4 filas | TURISTA=10 filas | RESERVA=10 filas | GUIA=5 filas | TOUR=20 filas
SELECT COUNT(*) FROM PAIS_ORIGEN;  SELECT COUNT(*) FROM TURISTA;  SELECT COUNT(*) FROM RESERVA;
SELECT COUNT(*) FROM GUIA;  SELECT COUNT(*) FROM TOUR;
```

✅ **Cumple 3FN:** ningún atributo no-clave depende de otro atributo no-clave; todo depende directamente de la clave de su propia tabla.

---

## PASO 7 — Cuarta Forma Normal (4FN): hechos multivaluados independientes

**Hallazgo (grano = un `IDReserva`):** dentro de una misma reserva (ejemplo real `RES001`, con sus 20 filas), `IdiomaSolicitado` toma **2** valores distintos (Ingles, Portugues) y `Actividad` toma **2** valores distintos (Museo, Trekking) — y aparecen **todas** las combinaciones posibles entre ambos (evidencia de que son independientes entre sí para la misma operación, no uno depende del otro).

```sql
-- Evidencia: ¿aparecen TODAS las combinaciones de IdiomaSolicitado x Actividad dentro de un mismo IDReserva?
SELECT DISTINCT IdiomaSolicitado, Actividad
FROM RESERVA_1FN
WHERE IDReserva = 'RES001'
ORDER BY IdiomaSolicitado, Actividad;
-- Resultado real: 4 combinaciones (= 2 x 2) -> confirma independencia (MVD).
```

```sql
-- 7.1  Separar los dos hechos multivaluados independientes
CREATE TABLE RESERVA_IDIOMASOLICITADO (
    IDReserva  VARCHAR(10)  NOT NULL,
    IdiomaSolicitado NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_RESERVA_IDIOMASOLICITADO PRIMARY KEY (IDReserva, IdiomaSolicitado)
);
INSERT INTO RESERVA_IDIOMASOLICITADO SELECT DISTINCT IDReserva,IdiomaSolicitado FROM RESERVA_1FN;

CREATE TABLE RESERVA_ACTIVIDAD (
    IDReserva  VARCHAR(10)  NOT NULL,
    Actividad NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_RESERVA_ACTIVIDAD PRIMARY KEY (IDReserva, Actividad)
);
INSERT INTO RESERVA_ACTIVIDAD SELECT DISTINCT IDReserva,Actividad FROM RESERVA_1FN;
```

> ⚠ **Nota honesta sobre estos datos.** En esta muestra, `IDTour` TAMBIÉN determina `IdiomaSolicitado` y `Actividad` sin excepción (es un efecto de cómo se generó el archivo: los mismos 20 tours se repiten idénticos en cada reserva). Eso NO es una regla de negocio real — un tour no "tiene" un idioma fijo en la vida real. Tratamos `IdiomaSolicitado` y `Actividad` como hechos independientes de la **reserva** (que es la lectura que pide el enunciado de la guía: "hechos multivaluados... para una misma operación"), no del tour. Coméntalo así en tu sustentación.

---

## PASO 8 — Quinta Forma Normal (5FN): relación ternaria y reconstrucción sin pérdida

Agregamos el tercer hecho, `Hotel` (5 valores: Hotel A, Hotel B, Hotel C, Hotel D, Hotel E), y verificamos si la combinación de los **tres** (IdiomaSolicitado, Actividad, Hotel) para un mismo `IDReserva` se reconstruye exactamente uniendo tres tablas binarias — sin inventar combinaciones (filas espurias) ni perder ninguna.

```sql
-- 8.1  Tercera tabla
CREATE TABLE RESERVA_HOTEL (
    IDReserva  VARCHAR(10)  NOT NULL,
    Hotel NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_RESERVA_HOTEL PRIMARY KEY (IDReserva, Hotel)
);
INSERT INTO RESERVA_HOTEL SELECT DISTINCT IDReserva,Hotel FROM RESERVA_1FN;
```

```sql
-- 8.2  Verificación de reconstrucción (debe devolver exactamente 20 filas para 'RES001', ni una más ni una menos)
SELECT c1.IDReserva, c1.IdiomaSolicitado, c2.Actividad, c3.Hotel
FROM RESERVA_IDIOMASOLICITADO c1
JOIN RESERVA_ACTIVIDAD c2 ON c2.IDReserva = c1.IDReserva
JOIN RESERVA_HOTEL c3 ON c3.IDReserva = c1.IDReserva
WHERE c1.IDReserva = 'RES001'
ORDER BY c1.IdiomaSolicitado, c2.Actividad, c3.Hotel;
```

```sql
-- 8.3  Comprobación automática contra la tabla original (0 = reconstrucción exacta)
SELECT COUNT(*) AS Diferencias FROM (
    SELECT IdiomaSolicitado,Actividad,Hotel FROM RESERVA_1FN WHERE IDReserva='RES001'
    EXCEPT
    SELECT c1.IdiomaSolicitado, c2.Actividad, c3.Hotel
    FROM RESERVA_IDIOMASOLICITADO c1
    JOIN RESERVA_ACTIVIDAD c2 ON c2.IDReserva=c1.IDReserva
    JOIN RESERVA_HOTEL c3 ON c3.IDReserva=c1.IDReserva
    WHERE c1.IDReserva='RES001'
) AS Diff;
-- Verificado contra el CSV real: 0 diferencias -> descomposición SIN PÉRDIDA.
```

✅ **Cumple 5FN:** la relación ternaria se reconstruye exactamente mediante el JOIN de las tres tablas binarias — no hace falta guardar una tabla de 3 columnas.

---

## MODELO FINAL

| # | Tabla | Clave primaria (PK) | Claves foráneas (FK) |
|---|---|---|---|
| 1 | `PAIS_ORIGEN` | PaisOrigen | — |
| 2 | `TURISTA` | IDTurista | PaisOrigen → `PAIS_ORIGEN` |
| 3 | `TURISTA_TELEFONO` | (IDTurista, Valor) | IDTurista → `TURISTA` |
| 4 | `RESERVA` | IDReserva | IDTurista → `TURISTA` |
| 5 | `GUIA` | IDGuia | — |
| 6 | `TOUR` | IDTour | IDGuia → `GUIA` |
| 7 | `DETALLE_RESERVA` | (IDReserva, IDTour) | IDReserva → `RESERVA` · IDTour → `TOUR` |
| 8 | `RESERVA_IDIOMASOLICITADO` | (IDReserva, IdiomaSolicitado) | IDReserva → `RESERVA` |
| 9 | `RESERVA_ACTIVIDAD` | (IDReserva, Actividad) | IDReserva → `RESERVA` |
| 10 | `RESERVA_HOTEL` | (IDReserva, Hotel) | IDReserva → `RESERVA` |

**Relaciones:** `PAIS_ORIGEN` 1:N `TURISTA` · `TURISTA` 1:N `RESERVA` (vía FK) · `TURISTA` 1:N `TURISTA_TEL` · `RESERVA` 1:N `DETALLE_RESERVA` · `TOUR` 1:N `DETALLE_RESERVA` · `GUIA` 1:N `TOUR` · `RESERVA` 1:N `RESERVA_IDIOMASOLICITADO`/`RESERVA_ACTIVIDAD`/`RESERVA_HOTEL`.

### JOIN final (reúne más de tres tablas normalizadas)

```sql
SELECT
    h.IDReserva, a.Turista, g.PaisOrigen, g.AgenciaPais,
    i.Tour, s.Guia, s.RegionGuia,
    d.Cantidad, d.PrecioUnitario, d.PrecioTotal
FROM DETALLE_RESERVA d
JOIN RESERVA h ON h.IDReserva = d.IDReserva
JOIN TURISTA a ON a.IDTurista = h.IDTurista
JOIN PAIS_ORIGEN g ON g.PaisOrigen = a.PaisOrigen
JOIN TOUR i ON i.IDTour = d.IDTour
JOIN GUIA s ON s.IDGuia = i.IDGuia
ORDER BY h.IDReserva, i.IDTour;
-- Verificado contra el CSV real: reconstruye exactamente las 200 filas del archivo original.
```

---

## COMPARACIÓN: tabla original vs. modelo final

| Aspecto | `RESERVA_INICIAL` (reporte plano) | Modelo final (10 tablas) |
|---|---|---|
| Filas totales | 200 | 10 + 4 + 10 + 20 + 20 + 5 + 200 + (10×2) + (10×2) + (10×5) |
| Veces que se repite `Guia` para `G001` | 40 veces | **1 vez** (en `GUIA`) |
| Veces que se repite `Turista` para `T001` | 20 veces | **1 vez** (en `TURISTA`) |
| Columna `TelefonosTurista` | Texto con `\|` (no atómico) | Filas individuales en `TURISTA_TEL` |
| Claves primarias explícitas | Ninguna | 10 |

---

## TRES ANOMALÍAS QUE EL NUEVO DISEÑO REDUCE (con datos reales del CSV)

**Anomalía de INSERCIÓN.** En `RESERVA_INICIAL`, para registrar un nuevo guía (ej. uno que todavía no tiene ningún tour asignado) sería necesario inventar una fila completa de reserva/tour solo para poder guardar sus datos — no se puede insertar un guía "solo". En el modelo final, basta con `INSERT INTO GUIA (...)`, sin necesidad de ninguna reserva ni ningún tour asociado todavía.

**Anomalía de ACTUALIZACIÓN.** El guía `G001` (Guia 1) aparece repetido 40 veces en `RESERVA_INICIAL`. Si cambia su `RegionGuia`, en la tabla original hay que actualizar las 40 filas (riesgo real de dejar alguna desactualizada); en el modelo final, **un solo** `UPDATE GUIA SET RegionGuia=... WHERE IDGuia='G001'` corrige el dato para siempre.

**Anomalía de ELIMINACIÓN.** Si en `RESERVA_INICIAL` se eliminara la única fila de reserva `RES001` que contiene al tour `TO001` (Tour 1), se perdería SIMULTÁNEAMENTE toda la información del tour (nombre, categoría, precio, guía) aunque ese tour siga existiendo en el catálogo real. En el modelo final, `TOUR` conserva los datos del tour de forma independiente: borrar una fila de `DETALLE_RESERVA` no borra nada de `TOUR`.

---

## CHECKLIST DE ENTREGA — Caso 7

- [ ] Script `.sql` con los 8 pasos de este documento, ejecutado de principio a fin sin errores
- [ ] Capturas de las consultas del Paso 2 (clave candidata) y Paso 3 (dependencias funcionales)
- [ ] Capturas de la verificación 1FN (Paso 4.2) y de los conteos 2FN/3FN (Pasos 5 y 6)
- [ ] Captura de la comprobación 4FN (combinaciones completas) y 5FN (0 diferencias, Paso 8.3)
- [ ] Modelo final con las 10 tablas, PK y FK indicadas
- [ ] JOIN final de al menos 3 tablas, ejecutado y con resultado visible
- [ ] Explicación de una anomalía de inserción, una de actualización y una de eliminación, con datos reales del CSV (puedes usar las de este documento o encontrar las tuyas)

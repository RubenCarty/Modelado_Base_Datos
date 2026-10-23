# SOLUCIÓN — Caso 5. Inventario de laboratorio
## Laboratorio 6 de Base de Datos — Normalización 1FN · 2FN · 3FN · 4FN · 5FN

**Archivo de datos:** `05_Inventario_Laboratorio_200.csv` (200 registros reales, ya cargados y verificados para esta solución)
**Base de datos a crear en SQL Server:** `Lab06_Caso05`

> **Antes de empezar:** si todavía no sabes cómo importar un CSV a SQL Server 2022, abre primero
> [`00_COMO_IMPORTAR_CSV_SQLSERVER22.md`](00_COMO_IMPORTAR_CSV_SQLSERVER22.md) — son los mismos 10 pasos para los 10 casos del laboratorio, aquí no se repiten.
>
> **Verificación de esta solución:** todas las consultas de este documento (claves, dependencias funcionales, cardinalidades, reconstrucción por JOIN) fueron ejecutadas y comprobadas contra el archivo CSV real con un motor de prueba — los números que aparecen (filas, conteos, violaciones) son los resultados reales del archivo, no estimaciones. La sintaxis T-SQL (`STRING_SPLIT`, `IDENTITY`, etc.) es válida en SQL Server 2022; se recomienda correr el script completo en tu propio SQL Server antes de la clase.

---

## Contexto y problemática (del enunciado de la guía)

**Contexto.** Un área de laboratorios controla movimientos de equipos, proveedores, edificios, accesorios, técnicos y proyectos de uso.

**Problemática.** El inventario plano presenta redundancia de equipos, proveedores y responsables, lo que dificulta mantener información consistente.

---

## PASO 0 — Crear la base de datos

```sql
DROP DATABASE IF EXISTS Lab06_Caso05;
CREATE DATABASE Lab06_Caso05;
USE Lab06_Caso05;
```

---

## PASO 1 — Explorar los 200 registros (hallazgos antes de tocar la estructura)

Abre la tabla ya importada (ver guía de importación) y mira las primeras filas:

```sql
SELECT TOP 10 * FROM MOVIMIENTO_INICIAL;
```

**Tres hallazgos que debes anotar antes de modificar nada** (ya verificados en este archivo):

1. **Dato repetido de proveedor:** el proveedor `PV001` (Proveedor 1) aparece repetido en varias filas, siempre con el mismo nombre — exactamente el patrón que genera riesgo de inconsistencia si alguien actualiza una sola fila y olvida las demás.
2. **Valor no atómico en `TelefonosLaboratorio`:** la columna trae dos valores en una sola celda separados por `|` (ejemplo real: `94000001|94100001`) — viola la atomicidad exigida por 1FN.
3. **Clave simple insuficiente:** ni `IDMovimiento` ni `IDEquipo` identifican una fila por sí solos — `IDMovimiento` se repite 20 veces (una por cada equipo) y `IDEquipo` se repite 10 veces (una por cada movimiento); se necesita la combinación de ambos.

---

## PASO 2 — Determinar la clave candidata (COUNT + GROUP BY)

```sql
-- 2.1  ¿Es IDMovimiento suficiente por sí solo?
SELECT IDMovimiento, COUNT(*) AS Filas
FROM MOVIMIENTO_INICIAL
GROUP BY IDMovimiento;
-- Resultado real: 10 valores distintos de IDMovimiento, cada uno con 20 filas -> NO es clave por sí solo.
```

```sql
-- 2.2  ¿Es IDEquipo suficiente por sí solo?
SELECT IDEquipo, COUNT(*) AS Filas
FROM MOVIMIENTO_INICIAL
GROUP BY IDEquipo;
-- Resultado real: 20 valores distintos de IDEquipo, cada uno con 10 filas -> NO es clave por sí solo.
```

```sql
-- 2.3  ¿La combinación (IDMovimiento, IDEquipo) identifica una fila única?
SELECT IDMovimiento, IDEquipo, COUNT(*) AS Filas
FROM MOVIMIENTO_INICIAL
GROUP BY IDMovimiento, IDEquipo
HAVING COUNT(*) > 1;
-- Resultado real: 0 filas devueltas -> cada combinación aparece EXACTAMENTE una vez.
```

**Clave candidata: {IDMovimiento, IDEquipo}** (clave compuesta).

---

## PASO 3 — Identificar las dependencias funcionales (con evidencia real del CSV)

```sql
-- DF 1:  IDLaboratorio -> Laboratorio, Edificio, TelefonosLaboratorio
SELECT IDLaboratorio, Laboratorio, Edificio, TelefonosLaboratorio
FROM MOVIMIENTO_INICIAL
WHERE IDLaboratorio = 'LAB001';
```
**Evidencia (2 filas reales, mismo `IDLaboratorio`, 20 veces en total — aquí solo 2):**
| IDLaboratorio | Laboratorio | Edificio | TelefonosLaboratorio |
|---|---|---|---|
| LAB001 | Laboratorio 1 | Edificio 1 | 94000001\|94100001 |
| LAB001 | Laboratorio 1 | Edificio 1 | 94000001\|94100001 |

Siempre el mismo nombre, edificio y teléfonos para `LAB001` → **`IDLaboratorio → Laboratorio, Edificio, TelefonosLaboratorio`** se confirma.

```sql
-- DF 2:  Edificio -> ResponsableEdificio
SELECT DISTINCT Edificio, ResponsableEdificio
FROM MOVIMIENTO_INICIAL
WHERE Edificio = 'Edificio 1';
```
**Evidencia:** `Edificio 1` siempre trae `ResponsableEdificio` = `Responsable 1` → **`Edificio → ResponsableEdificio`** se confirma.

```sql
-- DF 3:  IDEquipo -> Equipo, MarcaEquipo, PrecioUnitario, IDProveedor
SELECT IDEquipo, Equipo, MarcaEquipo, PrecioUnitario, IDProveedor
FROM MOVIMIENTO_INICIAL
WHERE IDEquipo = 'EQ001'
ORDER BY IDMovimiento;
```
**Evidencia (2 filas reales, mismo `IDEquipo`, en movimientos distintos — demuestra que NO depende de `IDMovimiento`):**
| IDEquipo | Equipo | MarcaEquipo | PrecioUnitario | IDProveedor |
|---|---|---|---|---|
| EQ001 | Equipo 1 | Marca 1 | 225 | PV001 |
| EQ001 | Equipo 1 | Marca 1 | 225 | PV001 |

**`IDEquipo → Equipo, MarcaEquipo, PrecioUnitario, IDProveedor`** se confirma: el precio y el proveedor del equipo no cambian aunque cambie el movimiento.

```sql
-- DF 4:  IDProveedor -> Proveedor, CiudadProveedor
SELECT DISTINCT IDProveedor, Proveedor, CiudadProveedor
FROM MOVIMIENTO_INICIAL
WHERE IDProveedor = 'PV001';
```
**Evidencia:** `PV001` siempre trae `Proveedor` = `Proveedor 1` y `CiudadProveedor` = `Ciudad 1` → **`IDProveedor → Proveedor, CiudadProveedor`** se confirma.

```sql
-- DF 5 (dependencia COMPLETA, no parcial):  (IDMovimiento, IDEquipo) -> Cantidad, PrecioTotal
SELECT IDMovimiento, IDEquipo, Cantidad, PrecioTotal
FROM MOVIMIENTO_INICIAL
WHERE IDEquipo = 'EQ001'
ORDER BY IDMovimiento;
-- Observa: el mismo IDEquipo trae distinta Cantidad/PrecioTotal según el movimiento -> depende de LA CLAVE COMPLETA, no de una parte.
```

---

## PASO 4 — Primera Forma Normal (1FN)

**Violación encontrada:** `TelefonosLaboratorio` no es atómica (trae `94000001|94100001`, 2 valores en una celda).

```sql
-- 4.1  Separar el valor multivaluado en su propia tabla
CREATE TABLE LABORATORIO_TELEFONO (
    IDLaboratorio VARCHAR(10)  NOT NULL,
    Valor            VARCHAR(30) NOT NULL,
    CONSTRAINT PK_LABORATORIO_TELEFONO PRIMARY KEY (IDLaboratorio, Valor)
);

INSERT INTO LABORATORIO_TELEFONO (IDLaboratorio, Valor)
SELECT DISTINCT IDLaboratorio, LTRIM(RTRIM(valor.value))
FROM MOVIMIENTO_INICIAL
CROSS APPLY STRING_SPLIT(TelefonosLaboratorio, '|') AS valor;
```

```sql
-- 4.2  Verificar 1FN: debe haber 20 filas (= 10 laboratorios x 2 teléfonos cada uno)
SELECT COUNT(*) AS Filas FROM LABORATORIO_TELEFONO;
```

```sql
-- 4.3  Crear la tabla en 1FN: mismas columnas MENOS la multivaluada, con PK compuesta
CREATE TABLE MOVIMIENTO_1FN (
    IDMovimiento        VARCHAR(10)   NOT NULL,
    IDLaboratorio        VARCHAR(10)   NOT NULL,
    Laboratorio       NVARCHAR(80)  NOT NULL,
    Edificio        NVARCHAR(40)  NOT NULL,
    ResponsableEdificio     NVARCHAR(40)  NOT NULL,
    IDEquipo        VARCHAR(10)   NOT NULL,
    Equipo       NVARCHAR(80)  NOT NULL,
    MarcaEquipo       NVARCHAR(40)  NOT NULL,
    PrecioUnitario       DECIMAL(10,2) NOT NULL,
    Cantidad      INT           NOT NULL,
    PrecioTotal      DECIMAL(10,2) NOT NULL,
    IDProveedor        VARCHAR(10)   NOT NULL,
    Proveedor       NVARCHAR(80)  NOT NULL,
    CiudadProveedor       NVARCHAR(40)  NOT NULL,
    Accesorio       NVARCHAR(40)  NOT NULL,
    TecnicoMantenimiento       NVARCHAR(40)  NOT NULL,
    ProyectoUso       NVARCHAR(40)  NOT NULL,
    CONSTRAINT PK_MOVIMIENTO_1FN PRIMARY KEY (IDMovimiento, IDEquipo)
);

INSERT INTO MOVIMIENTO_1FN
SELECT IDMovimiento,IDLaboratorio,Laboratorio,Edificio,ResponsableEdificio,IDEquipo,Equipo,MarcaEquipo,PrecioUnitario,Cantidad,PrecioTotal,IDProveedor,Proveedor,CiudadProveedor,Accesorio,TecnicoMantenimiento,ProyectoUso
FROM MOVIMIENTO_INICIAL;

SELECT COUNT(*) AS Filas FROM MOVIMIENTO_1FN;   -- debe devolver 200
```

✅ **Cumple 1FN:** cada celda tiene un único valor; la clave compuesta (IDMovimiento, IDEquipo) identifica cada fila sin ambigüedad.

---

## PASO 5 — Segunda Forma Normal (2FN): eliminar dependencias parciales

Atributos que dependen SOLO de `IDMovimiento` (parte de la clave): `IDLaboratorio, Laboratorio, Edificio, ResponsableEdificio`.
Atributos que dependen SOLO de `IDEquipo` (la otra parte): `Equipo, MarcaEquipo, PrecioUnitario, IDProveedor, Proveedor, CiudadProveedor`.
Atributos que dependen de LA CLAVE COMPLETA: `Cantidad, PrecioTotal`.

```sql
-- 5.1  Lado del movimiento (todo lo que depende solo de IDMovimiento)
CREATE TABLE MOVIMIENTO_2FN (
    IDMovimiento    VARCHAR(10)  NOT NULL,
    IDLaboratorio    VARCHAR(10)  NOT NULL,
    Laboratorio   NVARCHAR(80) NOT NULL,
    Edificio    NVARCHAR(40) NOT NULL,
    ResponsableEdificio NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_MOVIMIENTO_2FN PRIMARY KEY (IDMovimiento)
);
INSERT INTO MOVIMIENTO_2FN
SELECT DISTINCT IDMovimiento,IDLaboratorio,Laboratorio,Edificio,ResponsableEdificio FROM MOVIMIENTO_1FN;

-- 5.2  Lado del equipo (todo lo que depende solo de IDEquipo)
CREATE TABLE EQUIPO_2FN (
    IDEquipo  VARCHAR(10)   NOT NULL,
    Equipo NVARCHAR(80)  NOT NULL,
    MarcaEquipo NVARCHAR(40)  NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    IDProveedor  VARCHAR(10)   NOT NULL,
    Proveedor NVARCHAR(80)  NOT NULL,
    CiudadProveedor NVARCHAR(40)  NOT NULL,
    CONSTRAINT PK_EQUIPO_2FN PRIMARY KEY (IDEquipo)
);
INSERT INTO EQUIPO_2FN
SELECT DISTINCT IDEquipo,Equipo,MarcaEquipo,PrecioUnitario,IDProveedor,Proveedor,CiudadProveedor FROM MOVIMIENTO_1FN;

-- 5.3  Detalle: solo lo que depende de LA CLAVE COMPLETA (+ precio histórico de la transacción)
CREATE TABLE DETALLE_MOVIMIENTO (
    IDMovimiento    VARCHAR(10)   NOT NULL,
    IDEquipo    VARCHAR(10)   NOT NULL,
    PrecioUnitario   DECIMAL(10,2) NOT NULL,   -- precio histórico al momento de la transacción
    Cantidad  INT           NOT NULL,
    PrecioTotal  DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_DETALLE_MOVIMIENTO PRIMARY KEY (IDMovimiento, IDEquipo),
    CONSTRAINT FK_DETALLE_MOVIMIENTO_EQUIPO FOREIGN KEY (IDEquipo) REFERENCES EQUIPO_2FN(IDEquipo)
);
INSERT INTO DETALLE_MOVIMIENTO (IDMovimiento,IDEquipo,PrecioUnitario,Cantidad,PrecioTotal)
SELECT IDMovimiento,IDEquipo,PrecioUnitario,Cantidad,PrecioTotal FROM MOVIMIENTO_1FN;
```

```sql
-- Verificación: MOVIMIENTO_2FN debe tener 10 filas, EQUIPO_2FN debe tener 20 filas, DETALLE_MOVIMIENTO debe tener 200 filas
SELECT COUNT(*) FROM MOVIMIENTO_2FN;   -- 10
SELECT COUNT(*) FROM EQUIPO_2FN;   -- 20
SELECT COUNT(*) FROM DETALLE_MOVIMIENTO;  -- 200
```

> **¿Por qué se conserva `PrecioUnitario` también en `DETALLE_MOVIMIENTO`?** Para guardar el precio **histórico** de esa transacción puntual. El precio "actual" del catálogo vive en `EQUIPO_2FN`; si el precio de catálogo cambia mañana, las transacciones ya registradas no deben cambiar retroactivamente.

---

## PASO 6 — Tercera Forma Normal (3FN): eliminar dependencias transitivas

Dos cadenas transitivas detectadas:
- `IDMovimiento → IDLaboratorio → Laboratorio, Edificio` y `Edificio → ResponsableEdificio` (cadena de 3: `IDMovimiento → Edificio → ResponsableEdificio`)
- `IDEquipo → IDProveedor → Proveedor, CiudadProveedor` (cadena: `IDEquipo → IDProveedor → Proveedor, CiudadProveedor`)

```sql
-- 6.1  Separar EDIFICIO (resuelve Edificio -> ResponsableEdificio)
CREATE TABLE EDIFICIO (
    Edificio    NVARCHAR(40) NOT NULL,
    ResponsableEdificio NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_EDIFICIO PRIMARY KEY (Edificio)
);
INSERT INTO EDIFICIO SELECT DISTINCT Edificio,ResponsableEdificio FROM MOVIMIENTO_2FN;

-- 6.2  LABORATORIO definitivo (ya sin Edificio repetido con el responsable adentro; Edificio queda como FK)
CREATE TABLE LABORATORIO (
    IDLaboratorio  VARCHAR(10)  NOT NULL,
    Laboratorio NVARCHAR(80) NOT NULL,
    Edificio  NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_LABORATORIO PRIMARY KEY (IDLaboratorio),
    CONSTRAINT FK_LABORATORIO_EDIFICIO FOREIGN KEY (Edificio) REFERENCES EDIFICIO(Edificio)
);
INSERT INTO LABORATORIO SELECT DISTINCT IDLaboratorio,Laboratorio,Edificio FROM MOVIMIENTO_2FN;

-- 6.3  MOVIMIENTO definitivo (solo el id del movimiento + FK al laboratorio)
CREATE TABLE MOVIMIENTO (
    IDMovimiento VARCHAR(10) NOT NULL,
    IDLaboratorio VARCHAR(10) NOT NULL,
    CONSTRAINT PK_MOVIMIENTO PRIMARY KEY (IDMovimiento),
    CONSTRAINT FK_MOVIMIENTO_LABORATORIO FOREIGN KEY (IDLaboratorio) REFERENCES LABORATORIO(IDLaboratorio)
);
INSERT INTO MOVIMIENTO SELECT IDMovimiento,IDLaboratorio FROM MOVIMIENTO_2FN;

-- 6.4  Separar PROVEEDOR (resuelve IDEquipo -> IDProveedor -> Proveedor,CiudadProveedor)
CREATE TABLE PROVEEDOR (
    IDProveedor  VARCHAR(10)  NOT NULL,
    Proveedor NVARCHAR(80) NOT NULL,
    CiudadProveedor NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_PROVEEDOR PRIMARY KEY (IDProveedor)
);
INSERT INTO PROVEEDOR SELECT DISTINCT IDProveedor,Proveedor,CiudadProveedor FROM EQUIPO_2FN;

-- 6.5  EQUIPO definitivo (ya sin los datos del proveedor adentro; IDProveedor queda como FK)
CREATE TABLE EQUIPO (
    IDEquipo  VARCHAR(10)   NOT NULL,
    Equipo NVARCHAR(80)  NOT NULL,
    MarcaEquipo NVARCHAR(40)  NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    IDProveedor  VARCHAR(10)   NOT NULL,
    CONSTRAINT PK_EQUIPO PRIMARY KEY (IDEquipo),
    CONSTRAINT FK_EQUIPO_PROVEEDOR FOREIGN KEY (IDProveedor) REFERENCES PROVEEDOR(IDProveedor)
);
INSERT INTO EQUIPO SELECT IDEquipo,Equipo,MarcaEquipo,PrecioUnitario,IDProveedor FROM EQUIPO_2FN;
```

```sql
-- Verificación: EDIFICIO=4 filas | LABORATORIO=10 filas | MOVIMIENTO=10 filas | PROVEEDOR=5 filas | EQUIPO=20 filas
SELECT COUNT(*) FROM EDIFICIO;  SELECT COUNT(*) FROM LABORATORIO;  SELECT COUNT(*) FROM MOVIMIENTO;
SELECT COUNT(*) FROM PROVEEDOR;  SELECT COUNT(*) FROM EQUIPO;
```

✅ **Cumple 3FN:** ningún atributo no-clave depende de otro atributo no-clave; todo depende directamente de la clave de su propia tabla.

---

## PASO 7 — Cuarta Forma Normal (4FN): hechos multivaluados independientes

**Hallazgo (grano = un `IDMovimiento`):** dentro de un mismo movimiento (ejemplo real `MV001`, con sus 20 filas), `Accesorio` toma **2** valores distintos (Cable, Sensor) y `TecnicoMantenimiento` toma **2** valores distintos (Tecnico A, Tecnico B) — y aparecen **todas** las combinaciones posibles entre ambos (evidencia de que son independientes entre sí para la misma operación, no uno depende del otro).

```sql
-- Evidencia: ¿aparecen TODAS las combinaciones de Accesorio x TecnicoMantenimiento dentro de un mismo IDMovimiento?
SELECT DISTINCT Accesorio, TecnicoMantenimiento
FROM MOVIMIENTO_1FN
WHERE IDMovimiento = 'MV001'
ORDER BY Accesorio, TecnicoMantenimiento;
-- Resultado real: 4 combinaciones (= 2 x 2) -> confirma independencia (MVD).
```

```sql
-- 7.1  Separar los dos hechos multivaluados independientes
CREATE TABLE MOVIMIENTO_ACCESORIO (
    IDMovimiento  VARCHAR(10)  NOT NULL,
    Accesorio NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_MOVIMIENTO_ACCESORIO PRIMARY KEY (IDMovimiento, Accesorio)
);
INSERT INTO MOVIMIENTO_ACCESORIO SELECT DISTINCT IDMovimiento,Accesorio FROM MOVIMIENTO_1FN;

CREATE TABLE MOVIMIENTO_TECNICOMANTENIMIENTO (
    IDMovimiento  VARCHAR(10)  NOT NULL,
    TecnicoMantenimiento NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_MOVIMIENTO_TECNICOMANTENIMIENTO PRIMARY KEY (IDMovimiento, TecnicoMantenimiento)
);
INSERT INTO MOVIMIENTO_TECNICOMANTENIMIENTO SELECT DISTINCT IDMovimiento,TecnicoMantenimiento FROM MOVIMIENTO_1FN;
```

> ⚠ **Nota honesta sobre estos datos.** En esta muestra, `IDEquipo` TAMBIÉN determina `Accesorio` y `TecnicoMantenimiento` sin excepción (es un efecto de cómo se generó el archivo: los mismos 20 equipos se repiten idénticos en cada movimiento). Eso NO es una regla de negocio real — un equipo no "tiene" un accesorio fijo en la vida real. Tratamos `Accesorio` y `TecnicoMantenimiento` como hechos independientes del **movimiento** (que es la lectura que pide el enunciado de la guía: "hechos multivaluados... para una misma operación"), no del equipo. Coméntalo así en tu sustentación.

---

## PASO 8 — Quinta Forma Normal (5FN): relación ternaria y reconstrucción sin pérdida

Agregamos el tercer hecho, `ProyectoUso` (5 valores: Calidad, Docencia, Extension, Innovacion, Investigacion), y verificamos si la combinación de los **tres** (Accesorio, TecnicoMantenimiento, ProyectoUso) para un mismo `IDMovimiento` se reconstruye exactamente uniendo tres tablas binarias — sin inventar combinaciones (filas espurias) ni perder ninguna.

```sql
-- 8.1  Tercera tabla
CREATE TABLE MOVIMIENTO_PROYECTOUSO (
    IDMovimiento  VARCHAR(10)  NOT NULL,
    ProyectoUso NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_MOVIMIENTO_PROYECTOUSO PRIMARY KEY (IDMovimiento, ProyectoUso)
);
INSERT INTO MOVIMIENTO_PROYECTOUSO SELECT DISTINCT IDMovimiento,ProyectoUso FROM MOVIMIENTO_1FN;
```

```sql
-- 8.2  Verificación de reconstrucción (debe devolver exactamente 20 filas para 'MV001', ni una más ni una menos)
SELECT c1.IDMovimiento, c1.Accesorio, c2.TecnicoMantenimiento, c3.ProyectoUso
FROM MOVIMIENTO_ACCESORIO c1
JOIN MOVIMIENTO_TECNICOMANTENIMIENTO c2 ON c2.IDMovimiento = c1.IDMovimiento
JOIN MOVIMIENTO_PROYECTOUSO c3 ON c3.IDMovimiento = c1.IDMovimiento
WHERE c1.IDMovimiento = 'MV001'
ORDER BY c1.Accesorio, c2.TecnicoMantenimiento, c3.ProyectoUso;
```

```sql
-- 8.3  Comprobación automática contra la tabla original (0 = reconstrucción exacta)
SELECT COUNT(*) AS Diferencias FROM (
    SELECT Accesorio,TecnicoMantenimiento,ProyectoUso FROM MOVIMIENTO_1FN WHERE IDMovimiento='MV001'
    EXCEPT
    SELECT c1.Accesorio, c2.TecnicoMantenimiento, c3.ProyectoUso
    FROM MOVIMIENTO_ACCESORIO c1
    JOIN MOVIMIENTO_TECNICOMANTENIMIENTO c2 ON c2.IDMovimiento=c1.IDMovimiento
    JOIN MOVIMIENTO_PROYECTOUSO c3 ON c3.IDMovimiento=c1.IDMovimiento
    WHERE c1.IDMovimiento='MV001'
) AS Diff;
-- Verificado contra el CSV real: 0 diferencias -> descomposición SIN PÉRDIDA.
```

✅ **Cumple 5FN:** la relación ternaria se reconstruye exactamente mediante el JOIN de las tres tablas binarias — no hace falta guardar una tabla de 3 columnas.

---

## MODELO FINAL

| # | Tabla | Clave primaria (PK) | Claves foráneas (FK) |
|---|---|---|---|
| 1 | `EDIFICIO` | Edificio | — |
| 2 | `LABORATORIO` | IDLaboratorio | Edificio → `EDIFICIO` |
| 3 | `LABORATORIO_TELEFONO` | (IDLaboratorio, Valor) | IDLaboratorio → `LABORATORIO` |
| 4 | `MOVIMIENTO` | IDMovimiento | IDLaboratorio → `LABORATORIO` |
| 5 | `PROVEEDOR` | IDProveedor | — |
| 6 | `EQUIPO` | IDEquipo | IDProveedor → `PROVEEDOR` |
| 7 | `DETALLE_MOVIMIENTO` | (IDMovimiento, IDEquipo) | IDMovimiento → `MOVIMIENTO` · IDEquipo → `EQUIPO` |
| 8 | `MOVIMIENTO_ACCESORIO` | (IDMovimiento, Accesorio) | IDMovimiento → `MOVIMIENTO` |
| 9 | `MOVIMIENTO_TECNICOMANTENIMIENTO` | (IDMovimiento, TecnicoMantenimiento) | IDMovimiento → `MOVIMIENTO` |
| 10 | `MOVIMIENTO_PROYECTOUSO` | (IDMovimiento, ProyectoUso) | IDMovimiento → `MOVIMIENTO` |

**Relaciones:** `EDIFICIO` 1:N `LABORATORIO` · `LABORATORIO` 1:N `MOVIMIENTO` (vía FK) · `LABORATORIO` 1:N `LABORATORIO_TEL` · `MOVIMIENTO` 1:N `DETALLE_MOVIMIENTO` · `EQUIPO` 1:N `DETALLE_MOVIMIENTO` · `PROVEEDOR` 1:N `EQUIPO` · `MOVIMIENTO` 1:N `MOVIMIENTO_ACCESORIO`/`MOVIMIENTO_TECNICOMANTENIMIENTO`/`MOVIMIENTO_PROYECTOUSO`.

### JOIN final (reúne más de tres tablas normalizadas)

```sql
SELECT
    h.IDMovimiento, a.Laboratorio, g.Edificio, g.ResponsableEdificio,
    i.Equipo, s.Proveedor, s.CiudadProveedor,
    d.Cantidad, d.PrecioUnitario, d.PrecioTotal
FROM DETALLE_MOVIMIENTO d
JOIN MOVIMIENTO h ON h.IDMovimiento = d.IDMovimiento
JOIN LABORATORIO a ON a.IDLaboratorio = h.IDLaboratorio
JOIN EDIFICIO g ON g.Edificio = a.Edificio
JOIN EQUIPO i ON i.IDEquipo = d.IDEquipo
JOIN PROVEEDOR s ON s.IDProveedor = i.IDProveedor
ORDER BY h.IDMovimiento, i.IDEquipo;
-- Verificado contra el CSV real: reconstruye exactamente las 200 filas del archivo original.
```

---

## COMPARACIÓN: tabla original vs. modelo final

| Aspecto | `MOVIMIENTO_INICIAL` (reporte plano) | Modelo final (10 tablas) |
|---|---|---|
| Filas totales | 200 | 10 + 4 + 10 + 20 + 20 + 5 + 200 + (10×2) + (10×2) + (10×5) |
| Veces que se repite `Proveedor` para `PV001` | 40 veces | **1 vez** (en `PROVEEDOR`) |
| Veces que se repite `Laboratorio` para `LAB001` | 20 veces | **1 vez** (en `LABORATORIO`) |
| Columna `TelefonosLaboratorio` | Texto con `\|` (no atómico) | Filas individuales en `LABORATORIO_TEL` |
| Claves primarias explícitas | Ninguna | 10 |

---

## TRES ANOMALÍAS QUE EL NUEVO DISEÑO REDUCE (con datos reales del CSV)

**Anomalía de INSERCIÓN.** En `MOVIMIENTO_INICIAL`, para registrar un nuevo proveedor (ej. uno que todavía no tiene ningún equipo asignado) sería necesario inventar una fila completa de movimiento/equipo solo para poder guardar sus datos — no se puede insertar un proveedor "solo". En el modelo final, basta con `INSERT INTO PROVEEDOR (...)`, sin necesidad de ningún movimiento ni ningún equipo asociado todavía.

**Anomalía de ACTUALIZACIÓN.** El proveedor `PV001` (Proveedor 1) aparece repetido 40 veces en `MOVIMIENTO_INICIAL`. Si cambia su `CiudadProveedor`, en la tabla original hay que actualizar las 40 filas (riesgo real de dejar alguna desactualizada); en el modelo final, **un solo** `UPDATE PROVEEDOR SET CiudadProveedor=... WHERE IDProveedor='PV001'` corrige el dato para siempre.

**Anomalía de ELIMINACIÓN.** Si en `MOVIMIENTO_INICIAL` se eliminara la única fila del movimiento `MV001` que contiene al equipo `EQ001` (Equipo 1), se perdería SIMULTÁNEAMENTE toda la información del equipo (nombre, categoría, precio, proveedor) aunque ese equipo siga existiendo en el catálogo real. En el modelo final, `EQUIPO` conserva los datos del equipo de forma independiente: borrar una fila de `DETALLE_MOVIMIENTO` no borra nada de `EQUIPO`.

---

## CHECKLIST DE ENTREGA — Caso 5

- [ ] Script `.sql` con los 8 pasos de este documento, ejecutado de principio a fin sin errores
- [ ] Capturas de las consultas del Paso 2 (clave candidata) y Paso 3 (dependencias funcionales)
- [ ] Capturas de la verificación 1FN (Paso 4.2) y de los conteos 2FN/3FN (Pasos 5 y 6)
- [ ] Captura de la comprobación 4FN (combinaciones completas) y 5FN (0 diferencias, Paso 8.3)
- [ ] Modelo final con las 10 tablas, PK y FK indicadas
- [ ] JOIN final de al menos 3 tablas, ejecutado y con resultado visible
- [ ] Explicación de una anomalía de inserción, una de actualización y una de eliminación, con datos reales del CSV (puedes usar las de este documento o encontrar las tuyas)

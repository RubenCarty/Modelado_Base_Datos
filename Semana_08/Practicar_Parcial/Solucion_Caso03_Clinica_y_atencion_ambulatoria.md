# SOLUCIÓN — Caso 3. Clínica y atención ambulatoria
## Laboratorio 6 de Base de Datos — Normalización 1FN · 2FN · 3FN · 4FN · 5FN

**Archivo de datos:** `03_Clinica_200.csv` (200 registros reales, ya cargados y verificados para esta solución)
**Base de datos a crear en SQL Server:** `Lab06_Caso03`

> **Antes de empezar:** si todavía no sabes cómo importar un CSV a SQL Server 2022, abre primero
> [`00_COMO_IMPORTAR_CSV_SQLSERVER22.md`](00_COMO_IMPORTAR_CSV_SQLSERVER22.md) — son los mismos 10 pasos para los 10 casos del laboratorio, aquí no se repiten.
>
> **Verificación de esta solución:** todas las consultas de este documento (claves, dependencias funcionales, cardinalidades, reconstrucción por JOIN) fueron ejecutadas y comprobadas contra el archivo CSV real con un motor de prueba — los números que aparecen (filas, conteos, violaciones) son los resultados reales del archivo, no estimaciones. La sintaxis T-SQL (`STRING_SPLIT`, `IDENTITY`, etc.) es válida en SQL Server 2022; se recomienda correr el script completo en tu propio SQL Server antes de la clase.

---

## Contexto y problemática (del enunciado de la guía)

**Contexto.** Una clínica consolida citas, pacientes, seguros, servicios, médicos, alergias, síntomas y laboratorios en una tabla.

**Problemática.** Los datos clínicos y administrativos se duplican; cambiar un médico de pabellón o un contacto de seguro puede exigir varias actualizaciones.

---

## PASO 0 — Crear la base de datos

```sql
DROP DATABASE IF EXISTS Lab06_Caso03;
CREATE DATABASE Lab06_Caso03;
USE Lab06_Caso03;
```

---

## PASO 1 — Explorar los 200 registros (hallazgos antes de tocar la estructura)

Abre la tabla ya importada (ver guía de importación) y mira las primeras filas:

```sql
SELECT TOP 10 * FROM CITA_INICIAL;
```

**Tres hallazgos que debes anotar antes de modificar nada** (ya verificados en este archivo):

1. **Dato repetido de médico:** el médico `M001` (Medico 1) aparece repetido en varias filas, siempre con el mismo nombre — exactamente el patrón que genera riesgo de inconsistencia si alguien actualiza una sola fila y olvida las demás.
2. **Valor no atómico en `TelefonosPaciente`:** la columna trae dos valores en una sola celda separados por `|` (ejemplo real: `96000001|96100001`) — viola la atomicidad exigida por 1FN.
3. **Clave simple insuficiente:** ni `IDCita` ni `IDServicio` identifican una fila por sí solos — `IDCita` se repite 20 veces (una por cada servicio) y `IDServicio` se repite 10 veces (una por cada cita); se necesita la combinación de ambos.

---

## PASO 2 — Determinar la clave candidata (COUNT + GROUP BY)

```sql
-- 2.1  ¿Es IDCita suficiente por sí solo?
SELECT IDCita, COUNT(*) AS Filas
FROM CITA_INICIAL
GROUP BY IDCita;
-- Resultado real: 10 valores distintos de IDCita, cada uno con 20 filas -> NO es clave por sí solo.
```

```sql
-- 2.2  ¿Es IDServicio suficiente por sí solo?
SELECT IDServicio, COUNT(*) AS Filas
FROM CITA_INICIAL
GROUP BY IDServicio;
-- Resultado real: 20 valores distintos de IDServicio, cada uno con 10 filas -> NO es clave por sí solo.
```

```sql
-- 2.3  ¿La combinación (IDCita, IDServicio) identifica una fila única?
SELECT IDCita, IDServicio, COUNT(*) AS Filas
FROM CITA_INICIAL
GROUP BY IDCita, IDServicio
HAVING COUNT(*) > 1;
-- Resultado real: 0 filas devueltas -> cada combinación aparece EXACTAMENTE una vez.
```

**Clave candidata: {IDCita, IDServicio}** (clave compuesta).

---

## PASO 3 — Identificar las dependencias funcionales (con evidencia real del CSV)

```sql
-- DF 1:  IDPaciente -> NombrePaciente, Seguro, TelefonosPaciente
SELECT IDPaciente, NombrePaciente, Seguro, TelefonosPaciente
FROM CITA_INICIAL
WHERE IDPaciente = 'PA001';
```
**Evidencia (2 filas reales, mismo `IDPaciente`, 20 veces en total — aquí solo 2):**
| IDPaciente | NombrePaciente | Seguro | TelefonosPaciente |
|---|---|---|---|
| PA001 | Paciente 1 | Seguro 1 | 96000001\|96100001 |
| PA001 | Paciente 1 | Seguro 1 | 96000001\|96100001 |

Siempre el mismo nombre, seguro y teléfonos para `PA001` → **`IDPaciente → NombrePaciente, Seguro, TelefonosPaciente`** se confirma.

```sql
-- DF 2:  Seguro -> ContactoSeguro
SELECT DISTINCT Seguro, ContactoSeguro
FROM CITA_INICIAL
WHERE Seguro = 'Seguro 1';
```
**Evidencia:** `Seguro 1` siempre trae `ContactoSeguro` = `Gestor 1` → **`Seguro → ContactoSeguro`** se confirma.

```sql
-- DF 3:  IDServicio -> Servicio, EspecialidadServicio, PrecioUnitario, IDMedico
SELECT IDServicio, Servicio, EspecialidadServicio, PrecioUnitario, IDMedico
FROM CITA_INICIAL
WHERE IDServicio = 'S001'
ORDER BY IDCita;
```
**Evidencia (2 filas reales, mismo `IDServicio`, en citas distintas — demuestra que NO depende de `IDCita`):**
| IDServicio | Servicio | EspecialidadServicio | PrecioUnitario | IDMedico |
|---|---|---|---|---|
| S001 | Servicio 1 | Especialidad 1 | 57.5 | M001 |
| S001 | Servicio 1 | Especialidad 1 | 57.5 | M001 |

**`IDServicio → Servicio, EspecialidadServicio, PrecioUnitario, IDMedico`** se confirma: el precio y el médico del servicio no cambian aunque cambie la cita.

```sql
-- DF 4:  IDMedico -> NombreMedico, PabellonMedico
SELECT DISTINCT IDMedico, NombreMedico, PabellonMedico
FROM CITA_INICIAL
WHERE IDMedico = 'M001';
```
**Evidencia:** `M001` siempre trae `NombreMedico` = `Medico 1` y `PabellonMedico` = `Pabellon 1` → **`IDMedico → NombreMedico, PabellonMedico`** se confirma.

```sql
-- DF 5 (dependencia COMPLETA, no parcial):  (IDCita, IDServicio) -> Cantidad, PrecioTotal
SELECT IDCita, IDServicio, Cantidad, PrecioTotal
FROM CITA_INICIAL
WHERE IDServicio = 'S001'
ORDER BY IDCita;
-- Observa: el mismo IDServicio trae distinta Cantidad/PrecioTotal según la cita -> depende de LA CLAVE COMPLETA, no de una parte.
```

---

## PASO 4 — Primera Forma Normal (1FN)

**Violación encontrada:** `TelefonosPaciente` no es atómica (trae `96000001|96100001`, 2 valores en una celda).

```sql
-- 4.1  Separar el valor multivaluado en su propia tabla
CREATE TABLE PACIENTE_TELEFONO (
    IDPaciente VARCHAR(10)  NOT NULL,
    Valor            VARCHAR(30) NOT NULL,
    CONSTRAINT PK_PACIENTE_TELEFONO PRIMARY KEY (IDPaciente, Valor)
);

INSERT INTO PACIENTE_TELEFONO (IDPaciente, Valor)
SELECT DISTINCT IDPaciente, LTRIM(RTRIM(valor.value))
FROM CITA_INICIAL
CROSS APPLY STRING_SPLIT(TelefonosPaciente, '|') AS valor;
```

```sql
-- 4.2  Verificar 1FN: debe haber 20 filas (= 10 pacientes x 2 teléfonos cada uno)
SELECT COUNT(*) AS Filas FROM PACIENTE_TELEFONO;
```

```sql
-- 4.3  Crear la tabla en 1FN: mismas columnas MENOS la multivaluada, con PK compuesta
CREATE TABLE CITA_1FN (
    IDCita        VARCHAR(10)   NOT NULL,
    IDPaciente        VARCHAR(10)   NOT NULL,
    NombrePaciente       NVARCHAR(80)  NOT NULL,
    Seguro        NVARCHAR(40)  NOT NULL,
    ContactoSeguro     NVARCHAR(40)  NOT NULL,
    IDServicio        VARCHAR(10)   NOT NULL,
    Servicio       NVARCHAR(80)  NOT NULL,
    EspecialidadServicio       NVARCHAR(40)  NOT NULL,
    PrecioUnitario       DECIMAL(10,2) NOT NULL,
    Cantidad      INT           NOT NULL,
    PrecioTotal      DECIMAL(10,2) NOT NULL,
    IDMedico        VARCHAR(10)   NOT NULL,
    NombreMedico       NVARCHAR(80)  NOT NULL,
    PabellonMedico       NVARCHAR(40)  NOT NULL,
    Alergia       NVARCHAR(40)  NOT NULL,
    Sintoma       NVARCHAR(40)  NOT NULL,
    Laboratorio       NVARCHAR(40)  NOT NULL,
    CONSTRAINT PK_CITA_1FN PRIMARY KEY (IDCita, IDServicio)
);

INSERT INTO CITA_1FN
SELECT IDCita,IDPaciente,NombrePaciente,Seguro,ContactoSeguro,IDServicio,Servicio,EspecialidadServicio,PrecioUnitario,Cantidad,PrecioTotal,IDMedico,NombreMedico,PabellonMedico,Alergia,Sintoma,Laboratorio
FROM CITA_INICIAL;

SELECT COUNT(*) AS Filas FROM CITA_1FN;   -- debe devolver 200
```

✅ **Cumple 1FN:** cada celda tiene un único valor; la clave compuesta (IDCita, IDServicio) identifica cada fila sin ambigüedad.

---

## PASO 5 — Segunda Forma Normal (2FN): eliminar dependencias parciales

Atributos que dependen SOLO de `IDCita` (parte de la clave): `IDPaciente, NombrePaciente, Seguro, ContactoSeguro`.
Atributos que dependen SOLO de `IDServicio` (la otra parte): `Servicio, EspecialidadServicio, PrecioUnitario, IDMedico, NombreMedico, PabellonMedico`.
Atributos que dependen de LA CLAVE COMPLETA: `Cantidad, PrecioTotal`.

```sql
-- 5.1  Lado de cita (todo lo que depende solo de IDCita)
CREATE TABLE CITA_2FN (
    IDCita    VARCHAR(10)  NOT NULL,
    IDPaciente    VARCHAR(10)  NOT NULL,
    NombrePaciente   NVARCHAR(80) NOT NULL,
    Seguro    NVARCHAR(40) NOT NULL,
    ContactoSeguro NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_CITA_2FN PRIMARY KEY (IDCita)
);
INSERT INTO CITA_2FN
SELECT DISTINCT IDCita,IDPaciente,NombrePaciente,Seguro,ContactoSeguro FROM CITA_1FN;

-- 5.2  Lado del servicio (todo lo que depende solo de IDServicio)
CREATE TABLE SERVICIO_2FN (
    IDServicio  VARCHAR(10)   NOT NULL,
    Servicio NVARCHAR(80)  NOT NULL,
    EspecialidadServicio NVARCHAR(40)  NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    IDMedico  VARCHAR(10)   NOT NULL,
    NombreMedico NVARCHAR(80)  NOT NULL,
    PabellonMedico NVARCHAR(40)  NOT NULL,
    CONSTRAINT PK_SERVICIO_2FN PRIMARY KEY (IDServicio)
);
INSERT INTO SERVICIO_2FN
SELECT DISTINCT IDServicio,Servicio,EspecialidadServicio,PrecioUnitario,IDMedico,NombreMedico,PabellonMedico FROM CITA_1FN;

-- 5.3  Detalle: solo lo que depende de LA CLAVE COMPLETA (+ precio histórico de la transacción)
CREATE TABLE DETALLE_CITA (
    IDCita    VARCHAR(10)   NOT NULL,
    IDServicio    VARCHAR(10)   NOT NULL,
    PrecioUnitario   DECIMAL(10,2) NOT NULL,   -- precio histórico al momento de la transacción
    Cantidad  INT           NOT NULL,
    PrecioTotal  DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_DETALLE_CITA PRIMARY KEY (IDCita, IDServicio),
    CONSTRAINT FK_DETALLE_CITA_SERVICIO FOREIGN KEY (IDServicio) REFERENCES SERVICIO_2FN(IDServicio)
);
INSERT INTO DETALLE_CITA (IDCita,IDServicio,PrecioUnitario,Cantidad,PrecioTotal)
SELECT IDCita,IDServicio,PrecioUnitario,Cantidad,PrecioTotal FROM CITA_1FN;
```

```sql
-- Verificación: CITA_2FN debe tener 10 filas, SERVICIO_2FN debe tener 20 filas, DETALLE_CITA debe tener 200 filas
SELECT COUNT(*) FROM CITA_2FN;   -- 10
SELECT COUNT(*) FROM SERVICIO_2FN;   -- 20
SELECT COUNT(*) FROM DETALLE_CITA;  -- 200
```

> **¿Por qué se conserva `PrecioUnitario` también en `DETALLE_CITA`?** Para guardar el precio **histórico** de esa transacción puntual. El precio "actual" del catálogo vive en `SERVICIO_2FN`; si el precio de catálogo cambia mañana, las transacciones ya registradas no deben cambiar retroactivamente.

---

## PASO 6 — Tercera Forma Normal (3FN): eliminar dependencias transitivas

Dos cadenas transitivas detectadas:
- `IDCita → IDPaciente → NombrePaciente, Seguro` y `Seguro → ContactoSeguro` (cadena de 3: `IDCita → Seguro → ContactoSeguro`)
- `IDServicio → IDMedico → NombreMedico, PabellonMedico` (cadena: `IDServicio → IDMedico → NombreMedico, PabellonMedico`)

```sql
-- 6.1  Separar SEGURO (resuelve Seguro -> ContactoSeguro)
CREATE TABLE SEGURO (
    Seguro    NVARCHAR(40) NOT NULL,
    ContactoSeguro NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_SEGURO PRIMARY KEY (Seguro)
);
INSERT INTO SEGURO SELECT DISTINCT Seguro,ContactoSeguro FROM CITA_2FN;

-- 6.2  PACIENTE definitivo (ya sin Seguro repetido con el responsable adentro; Seguro queda como FK)
CREATE TABLE PACIENTE (
    IDPaciente  VARCHAR(10)  NOT NULL,
    NombrePaciente NVARCHAR(80) NOT NULL,
    Seguro  NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_PACIENTE PRIMARY KEY (IDPaciente),
    CONSTRAINT FK_PACIENTE_SEGURO FOREIGN KEY (Seguro) REFERENCES SEGURO(Seguro)
);
INSERT INTO PACIENTE SELECT DISTINCT IDPaciente,NombrePaciente,Seguro FROM CITA_2FN;

-- 6.3  CITA definitivo (solo el id de cita + FK al paciente)
CREATE TABLE CITA (
    IDCita VARCHAR(10) NOT NULL,
    IDPaciente VARCHAR(10) NOT NULL,
    CONSTRAINT PK_CITA PRIMARY KEY (IDCita),
    CONSTRAINT FK_CITA_PACIENTE FOREIGN KEY (IDPaciente) REFERENCES PACIENTE(IDPaciente)
);
INSERT INTO CITA SELECT IDCita,IDPaciente FROM CITA_2FN;

-- 6.4  Separar MEDICO (resuelve IDServicio -> IDMedico -> NombreMedico,PabellonMedico)
CREATE TABLE MEDICO (
    IDMedico  VARCHAR(10)  NOT NULL,
    NombreMedico NVARCHAR(80) NOT NULL,
    PabellonMedico NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_MEDICO PRIMARY KEY (IDMedico)
);
INSERT INTO MEDICO SELECT DISTINCT IDMedico,NombreMedico,PabellonMedico FROM SERVICIO_2FN;

-- 6.5  SERVICIO definitivo (ya sin los datos del médico adentro; IDMedico queda como FK)
CREATE TABLE SERVICIO (
    IDServicio  VARCHAR(10)   NOT NULL,
    Servicio NVARCHAR(80)  NOT NULL,
    EspecialidadServicio NVARCHAR(40)  NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    IDMedico  VARCHAR(10)   NOT NULL,
    CONSTRAINT PK_SERVICIO PRIMARY KEY (IDServicio),
    CONSTRAINT FK_SERVICIO_MEDICO FOREIGN KEY (IDMedico) REFERENCES MEDICO(IDMedico)
);
INSERT INTO SERVICIO SELECT IDServicio,Servicio,EspecialidadServicio,PrecioUnitario,IDMedico FROM SERVICIO_2FN;
```

```sql
-- Verificación: SEGURO=4 filas | PACIENTE=10 filas | CITA=10 filas | MEDICO=5 filas | SERVICIO=20 filas
SELECT COUNT(*) FROM SEGURO;  SELECT COUNT(*) FROM PACIENTE;  SELECT COUNT(*) FROM CITA;
SELECT COUNT(*) FROM MEDICO;  SELECT COUNT(*) FROM SERVICIO;
```

✅ **Cumple 3FN:** ningún atributo no-clave depende de otro atributo no-clave; todo depende directamente de la clave de su propia tabla.

---

## PASO 7 — Cuarta Forma Normal (4FN): hechos multivaluados independientes

**Hallazgo (grano = un `IDCita`):** dentro de una misma cita (ejemplo real `C001`, con sus 20 filas), `Alergia` toma **2** valores distintos (Penicilina, Polen) y `Sintoma` toma **2** valores distintos (Dolor, Fiebre) — y aparecen **todas** las combinaciones posibles entre ambos (evidencia de que son independientes entre sí para la misma operación, no uno depende del otro).

```sql
-- Evidencia: ¿aparecen TODAS las combinaciones de Alergia x Sintoma dentro de un mismo IDCita?
SELECT DISTINCT Alergia, Sintoma
FROM CITA_1FN
WHERE IDCita = 'C001'
ORDER BY Alergia, Sintoma;
-- Resultado real: 4 combinaciones (= 2 x 2) -> confirma independencia (MVD).
```

```sql
-- 7.1  Separar los dos hechos multivaluados independientes
CREATE TABLE CITA_ALERGIA (
    IDCita  VARCHAR(10)  NOT NULL,
    Alergia NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_CITA_ALERGIA PRIMARY KEY (IDCita, Alergia)
);
INSERT INTO CITA_ALERGIA SELECT DISTINCT IDCita,Alergia FROM CITA_1FN;

CREATE TABLE CITA_SINTOMA (
    IDCita  VARCHAR(10)  NOT NULL,
    Sintoma NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_CITA_SINTOMA PRIMARY KEY (IDCita, Sintoma)
);
INSERT INTO CITA_SINTOMA SELECT DISTINCT IDCita,Sintoma FROM CITA_1FN;
```

> ⚠ **Nota honesta sobre estos datos.** En esta muestra, `IDServicio` TAMBIÉN determina `Alergia` y `Sintoma` sin excepción (es un efecto de cómo se generó el archivo: los mismos 20 servicios se repiten idénticos en cada cita). Eso NO es una regla de negocio real — un servicio no "tiene" una alergia fija en la vida real. Tratamos `Alergia` y `Sintoma` como hechos independientes de la **cita** (que es la lectura que pide el enunciado de la guía: "hechos multivaluados... para una misma operación"), no del servicio. Coméntalo así en tu sustentación.

---

## PASO 8 — Quinta Forma Normal (5FN): relación ternaria y reconstrucción sin pérdida

Agregamos el tercer hecho, `Laboratorio` (5 valores: Lab A, Lab B, Lab C, Lab D, Lab E), y verificamos si la combinación de los **tres** (Alergia, Sintoma, Laboratorio) para un mismo `IDCita` se reconstruye exactamente uniendo tres tablas binarias — sin inventar combinaciones (filas espurias) ni perder ninguna.

```sql
-- 8.1  Tercera tabla
CREATE TABLE CITA_LABORATORIO (
    IDCita  VARCHAR(10)  NOT NULL,
    Laboratorio NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_CITA_LABORATORIO PRIMARY KEY (IDCita, Laboratorio)
);
INSERT INTO CITA_LABORATORIO SELECT DISTINCT IDCita,Laboratorio FROM CITA_1FN;
```

```sql
-- 8.2  Verificación de reconstrucción (debe devolver exactamente 20 filas para 'C001', ni una más ni una menos)
SELECT c1.IDCita, c1.Alergia, c2.Sintoma, c3.Laboratorio
FROM CITA_ALERGIA c1
JOIN CITA_SINTOMA c2 ON c2.IDCita = c1.IDCita
JOIN CITA_LABORATORIO c3 ON c3.IDCita = c1.IDCita
WHERE c1.IDCita = 'C001'
ORDER BY c1.Alergia, c2.Sintoma, c3.Laboratorio;
```

```sql
-- 8.3  Comprobación automática contra la tabla original (0 = reconstrucción exacta)
SELECT COUNT(*) AS Diferencias FROM (
    SELECT Alergia,Sintoma,Laboratorio FROM CITA_1FN WHERE IDCita='C001'
    EXCEPT
    SELECT c1.Alergia, c2.Sintoma, c3.Laboratorio
    FROM CITA_ALERGIA c1
    JOIN CITA_SINTOMA c2 ON c2.IDCita=c1.IDCita
    JOIN CITA_LABORATORIO c3 ON c3.IDCita=c1.IDCita
    WHERE c1.IDCita='C001'
) AS Diff;
-- Verificado contra el CSV real: 0 diferencias -> descomposición SIN PÉRDIDA.
```

✅ **Cumple 5FN:** la relación ternaria se reconstruye exactamente mediante el JOIN de las tres tablas binarias — no hace falta guardar una tabla de 3 columnas.

---

## MODELO FINAL

| # | Tabla | Clave primaria (PK) | Claves foráneas (FK) |
|---|---|---|---|
| 1 | `SEGURO` | Seguro | — |
| 2 | `PACIENTE` | IDPaciente | Seguro → `SEGURO` |
| 3 | `PACIENTE_TELEFONO` | (IDPaciente, Valor) | IDPaciente → `PACIENTE` |
| 4 | `CITA` | IDCita | IDPaciente → `PACIENTE` |
| 5 | `MEDICO` | IDMedico | — |
| 6 | `SERVICIO` | IDServicio | IDMedico → `MEDICO` |
| 7 | `DETALLE_CITA` | (IDCita, IDServicio) | IDCita → `CITA` · IDServicio → `SERVICIO` |
| 8 | `CITA_ALERGIA` | (IDCita, Alergia) | IDCita → `CITA` |
| 9 | `CITA_SINTOMA` | (IDCita, Sintoma) | IDCita → `CITA` |
| 10 | `CITA_LABORATORIO` | (IDCita, Laboratorio) | IDCita → `CITA` |

**Relaciones:** `SEGURO` 1:N `PACIENTE` · `PACIENTE` 1:N `CITA` (vía FK) · `PACIENTE` 1:N `PACIENTE_TEL` · `CITA` 1:N `DETALLE_CITA` · `SERVICIO` 1:N `DETALLE_CITA` · `MEDICO` 1:N `SERVICIO` · `CITA` 1:N `CITA_ALERGIA`/`CITA_SINTOMA`/`CITA_LABORATORIO`.

### JOIN final (reúne más de tres tablas normalizadas)

```sql
SELECT
    h.IDCita, a.NombrePaciente, g.Seguro, g.ContactoSeguro,
    i.Servicio, s.NombreMedico, s.PabellonMedico,
    d.Cantidad, d.PrecioUnitario, d.PrecioTotal
FROM DETALLE_CITA d
JOIN CITA h ON h.IDCita = d.IDCita
JOIN PACIENTE a ON a.IDPaciente = h.IDPaciente
JOIN SEGURO g ON g.Seguro = a.Seguro
JOIN SERVICIO i ON i.IDServicio = d.IDServicio
JOIN MEDICO s ON s.IDMedico = i.IDMedico
ORDER BY h.IDCita, i.IDServicio;
-- Verificado contra el CSV real: reconstruye exactamente las 200 filas del archivo original.
```

---

## COMPARACIÓN: tabla original vs. modelo final

| Aspecto | `CITA_INICIAL` (reporte plano) | Modelo final (10 tablas) |
|---|---|---|
| Filas totales | 200 | 10 + 4 + 10 + 20 + 20 + 5 + 200 + (10×2) + (10×2) + (10×5) |
| Veces que se repite `NombreMedico` para `M001` | 40 veces | **1 vez** (en `MEDICO`) |
| Veces que se repite `NombrePaciente` para `PA001` | 20 veces | **1 vez** (en `PACIENTE`) |
| Columna `TelefonosPaciente` | Texto con `\|` (no atómico) | Filas individuales en `PACIENTE_TEL` |
| Claves primarias explícitas | Ninguna | 10 |

---

## TRES ANOMALÍAS QUE EL NUEVO DISEÑO REDUCE (con datos reales del CSV)

**Anomalía de INSERCIÓN.** En `CITA_INICIAL`, para registrar un nuevo médico (ej. uno que todavía no tiene ningún servicio asignado) sería necesario inventar una fila completa de cita/servicio solo para poder guardar sus datos — no se puede insertar un médico "solo". En el modelo final, basta con `INSERT INTO MEDICO (...)`, sin necesidad de ninguna cita ni ningún servicio asociado todavía.

**Anomalía de ACTUALIZACIÓN.** El médico `M001` (Medico 1) aparece repetido 40 veces en `CITA_INICIAL`. Si cambia su `PabellonMedico`, en la tabla original hay que actualizar las 40 filas (riesgo real de dejar alguna desactualizada); en el modelo final, **un solo** `UPDATE MEDICO SET PabellonMedico=... WHERE IDMedico='M001'` corrige el dato para siempre.

**Anomalía de ELIMINACIÓN.** Si en `CITA_INICIAL` se eliminara la única fila de cita `C001` que contiene al servicio `S001` (Servicio 1), se perdería SIMULTÁNEAMENTE toda la información del servicio (nombre, categoría, precio, médico) aunque ese servicio siga existiendo en el catálogo real. En el modelo final, `SERVICIO` conserva los datos del servicio de forma independiente: borrar una fila de `DETALLE_CITA` no borra nada de `SERVICIO`.

---

## CHECKLIST DE ENTREGA — Caso 3

- [ ] Script `.sql` con los 8 pasos de este documento, ejecutado de principio a fin sin errores
- [ ] Capturas de las consultas del Paso 2 (clave candidata) y Paso 3 (dependencias funcionales)
- [ ] Capturas de la verificación 1FN (Paso 4.2) y de los conteos 2FN/3FN (Pasos 5 y 6)
- [ ] Captura de la comprobación 4FN (combinaciones completas) y 5FN (0 diferencias, Paso 8.3)
- [ ] Modelo final con las 10 tablas, PK y FK indicadas
- [ ] JOIN final de al menos 3 tablas, ejecutado y con resultado visible
- [ ] Explicación de una anomalía de inserción, una de actualización y una de eliminación, con datos reales del CSV (puedes usar las de este documento o encontrar las tuyas)

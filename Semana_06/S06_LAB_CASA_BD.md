# S06 — LABORATORIO EN CASA | Modelado y Diseño de Base de Datos

**ESTADO: BORRADOR — PENDIENTE DE REVISIÓN DOCENTE**

---

| Campo | Detalle |
|---|---|
| **Curso** | Modelado y Diseño de Base de Datos |
| **Semana** | 06 — Segunda y Tercera Forma Normal, Descomposición sin Pérdida de Información |
| **Duración estimada** | 2 horas |
| **Modalidad** | Individual o en pareja |
| **Entrega** | Soy Autónoma → Semana 6 → Lab en Casa — antes de la siguiente sesión |

| **Nombre** | ________________________________________ |
|---|---|
| **Código** | ________________________________________ |
| **Sistema de proyecto elegido en S02** | ________________________________________ |

---

## SOFTWARE Y HERRAMIENTAS

| Herramienta | Versión | Link de descarga | ¿Ya instalada? |
|---|---|---|---|
| SQL Server | 2025, en contenedor Docker (`sqlserver2025`) | — ya configurado en S05 | ✅ Sí |
| DBeaver Community | 24.x / 25.x | https://dbeaver.io/download/ | ✅ Sí |

**Alternativa 100% online** (si no puedes usar tu computadora habitual):
- **DB Fiddle** (soporta SQL Server) — https://www.db-fiddle.com/

**Verificación de entorno** (antes de empezar):
```bash
# En Docker Desktop, confirma que el contenedor sqlserver2025 esté "Running".
# Si está detenido, inícialo con el botón ▶ antes de abrir DBeaver.
```
```sql
SELECT 1 AS conexion_ok;
```

Usa tu base `S05_APELLIDO` (de la semana pasada) o crea una nueva:
```sql
CREATE DATABASE S06_APELLIDO;
USE S06_APELLIDO;
```

---

## OBJETIVO DEL LABORATORIO

Aplicar 2FN y 3FN de forma completa sobre un reporte ya normalizado a 1FN, y verificar con SQL que cada descomposición es sin pérdida de información — cerrando el ciclo de normalización iniciado en S05, como preparación directa para el diseño físico final de tu proyecto en S07.

Al finalizar este lab deberás tener:
- Una dependencia parcial y una dependencia transitiva correctamente identificadas y resueltas sobre el caso de la Clínica Dental (continuación de S05)
- Las tablas resultantes creadas en SQL Server, en 3FN completa
- Una consulta SQL que demuestre que la reconstrucción (JOIN) de las tablas es sin pérdida
- Un fragmento de tu propio proyecto llevado a 2FN/3FN (Parte 3)

---

## PARTE 1 — EXPLORACIÓN (30 min)

**Caso guiado: ChaskiExpress — continuación de la sesión de hoy**

Este código reproduce exactamente lo trabajado en la Transformación de la sesión (Subtemas 6.1 a 6.3). Ejecútalo paso a paso y observa el patrón completo antes de aplicarlo tú mismo en la Parte 2.

### Paso 1 — Tabla con dependencia parcial (1FN, no 2FN) (5 min)

```sql
CREATE TABLE DETALLE_PEDIDO_EXT (
    idPedido          VARCHAR(10)   NOT NULL,
    idProducto        VARCHAR(10)   NOT NULL,
    nombreProducto    NVARCHAR(60)  NOT NULL,
    categoriaProducto NVARCHAR(30)  NOT NULL,
    precioUnitario    DECIMAL(8,2)  NOT NULL,
    cantidad          INT           NOT NULL
);

INSERT INTO DETALLE_PEDIDO_EXT VALUES
 ('PED001', 'PRD01', N'Lomo Saltado',      N'Plato de fondo', 28.00, 2),
 ('PED001', 'PRD02', N'Inca Kola 500ml',   N'Bebida',          6.00, 1),
 ('PED002', 'PRD03', N'Pizza Familiar',    N'Pizza',          55.00, 1),
 ('PED003', 'PRD01', N'Lomo Saltado',      N'Plato de fondo', 28.00, 1);
```

### Paso 2 — Comprobar la dependencia parcial con SQL (5 min)

```sql
-- Si idProducto determina nombreProducto, categoriaProducto y precioUnitario,
-- NO deberían existir dos filas con el mismo idProducto y datos distintos.
SELECT idProducto,
       COUNT(DISTINCT nombreProducto)    AS nombres,
       COUNT(DISTINCT categoriaProducto) AS categorias,
       COUNT(DISTINCT precioUnitario)    AS precios
FROM DETALLE_PEDIDO_EXT
GROUP BY idProducto
HAVING COUNT(DISTINCT nombreProducto) > 1
    OR COUNT(DISTINCT categoriaProducto) > 1
    OR COUNT(DISTINCT precioUnitario) > 1;
-- Resultado esperado: 0 filas → confirma que la dependencia idProducto → (nombre, categoría, precio) se cumple
-- (y por lo tanto, SÍ es una dependencia parcial respecto a la clave compuesta (idPedido, idProducto))
```

### Paso 3 — Descomponer a 2FN (10 min)

```sql
CREATE TABLE PRODUCTO (
    idProducto        VARCHAR(10)   NOT NULL,
    nombreProducto    NVARCHAR(60)  NOT NULL,
    categoriaProducto NVARCHAR(30)  NOT NULL,
    precioUnitario    DECIMAL(8,2)  NOT NULL,
    CONSTRAINT PK_PRODUCTO PRIMARY KEY (idProducto)
);

CREATE TABLE DETALLE_PEDIDO (
    idPedido   VARCHAR(10) NOT NULL,
    idProducto VARCHAR(10) NOT NULL,
    cantidad   INT         NOT NULL,
    CONSTRAINT PK_DETALLE_PEDIDO PRIMARY KEY (idPedido, idProducto),
    CONSTRAINT FK_DETALLE_PRODUCTO FOREIGN KEY (idProducto) REFERENCES PRODUCTO (idProducto),
    CONSTRAINT CK_DETALLE_CANT CHECK (cantidad > 0)
);

INSERT INTO PRODUCTO (idProducto, nombreProducto, categoriaProducto, precioUnitario)
SELECT DISTINCT idProducto, nombreProducto, categoriaProducto, precioUnitario
FROM DETALLE_PEDIDO_EXT;

INSERT INTO DETALLE_PEDIDO (idPedido, idProducto, cantidad)
SELECT idPedido, idProducto, cantidad
FROM DETALLE_PEDIDO_EXT;
```

### Paso 4 — Verificar que la descomposición es sin pérdida (10 min)

```sql
-- Reconstrucción: debe devolver EXACTAMENTE las mismas 4 filas de DETALLE_PEDIDO_EXT
SELECT dp.idPedido, dp.idProducto, p.nombreProducto, p.categoriaProducto, p.precioUnitario, dp.cantidad
FROM DETALLE_PEDIDO dp
INNER JOIN PRODUCTO p ON p.idProducto = dp.idProducto
ORDER BY dp.idPedido, dp.idProducto;

-- Comprobación automática: debe devolver 0 (ninguna diferencia)
SELECT COUNT(*) AS diferencias FROM (
    SELECT idPedido, idProducto, nombreProducto, categoriaProducto, precioUnitario, cantidad FROM DETALLE_PEDIDO_EXT
    EXCEPT
    SELECT dp.idPedido, dp.idProducto, p.nombreProducto, p.categoriaProducto, p.precioUnitario, dp.cantidad
    FROM DETALLE_PEDIDO dp INNER JOIN PRODUCTO p ON p.idProducto = dp.idProducto
) AS diff;
```

### Pregunta de reflexión al finalizar Parte 1

> *"¿Qué observaste en la consulta del Paso 4? ¿Qué pasaría con el resultado de la comprobación automática (EXCEPT) si, al armar PRODUCTO, te hubieras equivocado y hubieras insertado dos veces el mismo idProducto con precios distintos?"*

**Escribe tu respuesta aquí (para incluir en el entregable):**

_____________________________________________________________________________

_____________________________________________________________________________

---

## PARTE 2 — APLICACIÓN (60 min)

**Objetivo:** Resolver, de forma completa, 2FN y 3FN sobre la Clínica Dental "Sonrisas del Sur" — retomando exactamente las tablas CITA y DETALLE_CITA que construiste en el Lab en Casa de S05.

### Contexto: dos reportes nuevos llegaron esta semana

**Reporte A — detalle de servicios, con más columnas que en S05 (clave compuesta: idCita + idServicio):**

| idCita | idServicio | nombreServicio | categoriaServicio | precioServicio | cantidad |
|---|---|---|---|---|---|
| CIT01 | SRV01 | Limpieza dental | Preventivo | 90.00 | 1 |
| CIT01 | SRV02 | Resina | Restaurativo | 90.00 | 1 |
| CIT02 | SRV03 | Consulta general | Preventivo | 50.00 | 1 |
| CIT03 | SRV02 | Resina | Restaurativo | 90.00 | 2 |
| CIT03 | SRV04 | Fluorización | Preventivo | 40.00 | 1 |

**Reporte B — datos de cabecera de la cita, con el odontólogo "aplanado" (clave simple: idCita):**

| idCita | idPaciente | nombrePaciente | idOdontologo | nombreOdontologo | especialidadOdontologo |
|---|---|---|---|---|---|
| CIT01 | PAC12 | Gladys Ruiz | ODO02 | Dr. Carlos Peña | Ortodoncia |
| CIT02 | PAC13 | Mario Tello | ODO01 | Dra. Vanessa Luna | Odontopediatría |
| CIT03 | PAC12 | Gladys Ruiz | ODO01 | Dra. Vanessa Luna | Odontopediatría |

> **Nota sobre el `montoCita` de S05:** la semana pasada quedó la pregunta abierta de si `montoCita` (que dejamos en CITA) dependía de toda la cita o de algo más específico. La respuesta: `montoCita` **no es un atributo base** — es un valor **calculado** a partir de `SUM(precioServicio × cantidad)` agrupado por cita, usando exactamente el Reporte A de arriba. No es estrictamente una violación de 1FN/2FN/3FN (es un tema distinto, de atributos derivados, que verás con más detalle en S09-S11 con funciones de agregación), pero la buena práctica de normalización es **no almacenarlo como columna fija** en CITA, sino calcularlo con una consulta cuando se necesite — así nunca queda desactualizado respecto al detalle real.

### Código esqueleto — completa las partes marcadas `-- TODO`

```sql
-- PARTE 2 — APLICACIÓN
-- Sistema: Clínica Dental "Sonrisas del Sur" — 2FN y 3FN

CREATE TABLE DETALLE_CITA_EXT (
    idCita             VARCHAR(10)   NOT NULL,
    idServicio         VARCHAR(10)   NOT NULL,
    nombreServicio     NVARCHAR(60)  NOT NULL,
    categoriaServicio  NVARCHAR(30)  NOT NULL,
    precioServicio     DECIMAL(8,2)  NOT NULL,
    cantidad           INT           NOT NULL
);
INSERT INTO DETALLE_CITA_EXT VALUES
 ('CIT01', 'SRV01', N'Limpieza dental',  N'Preventivo',    90.00, 1),
 ('CIT01', 'SRV02', N'Resina',           N'Restaurativo',  90.00, 1),
 ('CIT02', 'SRV03', N'Consulta general', N'Preventivo',    50.00, 1),
 ('CIT03', 'SRV02', N'Resina',           N'Restaurativo',  90.00, 2),
 ('CIT03', 'SRV04', N'Fluorización',     N'Preventivo',    40.00, 1);

CREATE TABLE CITA_EXT (
    idCita                  VARCHAR(10)  NOT NULL,
    idPaciente              VARCHAR(10)  NOT NULL,
    nombrePaciente          NVARCHAR(60) NOT NULL,
    idOdontologo            VARCHAR(10)  NOT NULL,
    nombreOdontologo        NVARCHAR(60) NOT NULL,
    especialidadOdontologo  NVARCHAR(40) NOT NULL
);
INSERT INTO CITA_EXT VALUES
 ('CIT01', 'PAC12', N'Gladys Ruiz', 'ODO02', N'Dr. Carlos Peña',  N'Ortodoncia'),
 ('CIT02', 'PAC13', N'Mario Tello',  'ODO01', N'Dra. Vanessa Luna', N'Odontopediatría'),
 ('CIT03', 'PAC12', N'Gladys Ruiz', 'ODO01', N'Dra. Vanessa Luna', N'Odontopediatría');

-- TODO 1: Escribe, como comentario, qué atributos de DETALLE_CITA_EXT tienen dependencia
--         PARCIAL respecto a la clave compuesta (idCita, idServicio), y cuál tiene
--         dependencia COMPLETA. Justifica cada uno en una línea.


-- TODO 2: Crea la tabla SERVICIO (idServicio PK, nombreServicio, categoriaServicio, precioServicio)
--         que resuelve la dependencia parcial detectada en TODO 1.


-- TODO 3: Crea la tabla DETALLE_CITA (idCita, idServicio, cantidad) con clave compuesta
--         y FK hacia SERVICIO. Solo debe quedar el atributo de dependencia completa.


-- TODO 4: CITA_EXT tiene clave SIMPLE (idCita), así que el problema aquí no es 2FN.
--         Escribe, como comentario, la cadena completa de dependencia TRANSITIVA que
--         encuentres (recuerda: X → Z → Y).


-- TODO 5: Crea la tabla ODONTOLOGO (idOdontologo PK, nombreOdontologo, especialidadOdontologo)
--         que resuelve la dependencia transitiva del TODO 4.


-- TODO 6: Crea la tabla PACIENTE (idPaciente PK, nombrePaciente) y la tabla final
--         CITA (idCita PK, idPaciente FK, idOdontologo FK) — ya en 3FN completa.


-- TODO 7: Inserta los datos correspondientes en las 5 tablas nuevas (SERVICIO, DETALLE_CITA,
--         ODONTOLOGO, PACIENTE, CITA), migrándolos desde DETALLE_CITA_EXT y CITA_EXT.


-- TODO 8: Escribe UNA consulta que verifique, mediante un JOIN de SERVICIO + DETALLE_CITA,
--         que la reconstrucción reproduce exactamente las 5 filas de DETALLE_CITA_EXT.
```

### 3 puntos de verificación — sabes que vas bien si:

- ✅ **Checkpoint 1:** `SELECT * FROM SERVICIO;` devuelve **4 filas** (Limpieza dental, Resina, Consulta general, Fluorización — sin repetir Resina dos veces).
- ✅ **Checkpoint 2:** `SELECT * FROM ODONTOLOGO;` devuelve **2 filas** (Dr. Carlos Peña, Dra. Vanessa Luna — sin repetir a la Dra. Luna, que aparece en 2 citas).
- ✅ **Checkpoint 3:** tu consulta del TODO 8 devuelve **0 diferencias** (usa `EXCEPT` como en la Parte 1, Paso 4) al comparar contra DETALLE_CITA_EXT.

### Preguntas de análisis (responder como comentarios en el código o en documento aparte)

1. ¿Por qué `idOdontologo` se queda en CITA como clave foránea, mientras que `nombreOdontologo` y `especialidadOdontologo` se van a la tabla ODONTOLOGO?
2. Si mañana la Dra. Vanessa Luna cambia de especialidad (se certifica también en Ortodoncia), ¿en cuántas filas tendrías que actualizar ese dato con tu diseño final? ¿Y con el reporte original CITA_EXT?
3. La próxima semana (S07) vamos a convertir este mismo diseño en el modelo físico definitivo de tu proyecto. Adelántate: ¿cuántas tablas en total tiene tu proyecto hasta ahora, sumando lo resuelto en S05 y hoy?

---

## PARTE 3 — DESAFÍO (30 min)

**Objetivo:** Aplicar 2FN y 3FN completas sobre un fragmento de tu propio proyecto de base de datos.

No se provee código esqueleto: debes diseñarlo desde cero, siguiendo el mismo patrón de las Partes 1 y 2.

### Instrucciones

1. Retoma las tablas que dejaste en 1FN en el Lab en Casa de S05 (o construye una tabla plana hipotética de 5 filas, con clave compuesta, si tu proyecto aún no lo necesitaba).
2. Para cada tabla con clave compuesta: revisa si hay dependencias parciales. Para cada tabla con clave simple: revisa si hay dependencias transitivas.
3. Antes de diseñar, puedes contrastar tu criterio con este verificador automático de formas normales: https://github.com/toblu302/Database-Normal-Form-Checker
4. Implementa en SQL Server las tablas resultantes en 3FN, con al menos una consulta que verifique que una de tus descomposiciones es sin pérdida (JOIN + `EXCEPT`, como en la Parte 1).

```sql
-- PARTE 3 — DESAFÍO
-- Aquí diseñas e implementas 2FN/3FN para tu propio proyecto
-- (tabla(s) de partida en 1FN, detección de dependencias parciales/transitivas documentada
--  en comentarios, CREATE TABLE de las tablas en 3FN, INSERT de datos de prueba,
--  consulta de verificación sin pérdida)
```

### Pregunta de reflexión final

> *"¿Qué fue más difícil: detectar la dependencia parcial, detectar la transitiva, o verificar que la descomposición fue sin pérdida? ¿Por qué?"*

_____________________________________________________________________________

### Pregunta de conexión con el proyecto real

> *"De las tablas de tu proyecto que ya revisaste en S05 y hoy, ¿cuál tenía el problema de diseño más grave antes de normalizarla? ¿Qué anomalía concreta (de actualización, inserción o borrado) hubiera podido ocurrir si la hubieras dejado así?"*

_____________________________________________________________________________

---

## ENTREGABLES

| # | Archivo a entregar | Descripción |
|---|---|---|
| 1 | `S06_LabCasa_APELLIDO.sql` | Script completo de las Partes 1, 2 y 3, en orden, con los comentarios de las preguntas de análisis incluidos |
| 2 | `capturas_parte2.png` | Capturas de los 3 checkpoints de la Parte 2 (código + resultado visibles) |
| 3 | `respuestas_analisis.docx` | Respuestas escritas a las preguntas de reflexión de las Partes 1 y 3, y a las 3 preguntas de análisis de la Parte 2 |

**Formato de entrega:** Subir a Soy Autónoma → Semana 6 → Laboratorio en Casa → antes de la siguiente sesión.

**Rúbrica básica:**

| Criterio | Excelente (100%) | Suficiente (70%) | Insuficiente (<70%) | Pts |
|---|---|---|---|---|
| Parte 1 completa y correcta | Exploración ejecutada sin errores, reflexión completa sobre el EXCEPT | Exploración correcta sin reflexión o con reflexión superficial | Incompleta o con errores de ejecución | 20% |
| Parte 2: producto funcional | Los 8 TODO completos, 5 tablas creadas y pobladas, 3 checkpoints superados | 5-7 de los 8 TODO completos | Menos de 5 TODO completos | 40% |
| Parte 2: preguntas de análisis | Las 3 respuestas completas y fundamentadas | 2 de 3 respuestas completas | 0-1 respuesta completa | 20% |
| Parte 3: desafío | Caso propio implementado completo, con verificación de descomposición sin pérdida y reflexión sustentada | Implementado pero incompleto, o sin la consulta de verificación | No implementado | 20% |

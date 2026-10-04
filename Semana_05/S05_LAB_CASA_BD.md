# S05 — LABORATORIO EN CASA | Modelado y Diseño de Base de Datos

**ESTADO: BORRADOR — PENDIENTE DE REVISIÓN DOCENTE**

---

| Campo | Detalle |
|---|---|
| **Curso** | Modelado y Diseño de Base de Datos |
| **Semana** | 05 — Primera Forma Normal, Dependencias Funcionales y Eliminación de Grupos Repetitivos |
| **Duración estimada** | 2 horas |
| **Modalidad** | Individual o en pareja |
| **Entrega** | Soy Autónoma → Semana 5 → Lab en Casa — antes de la siguiente sesión |

| **Nombre** | ________________________________________ |
|---|---|
| **Código** | ________________________________________ |
| **Sistema de proyecto elegido en S02** | ________________________________________ |

---

## SOFTWARE Y HERRAMIENTAS

| Herramienta | Versión | Link de descarga | ¿Ya instalada? |
|---|---|---|---|
| SQL Server | 2022 Express / Developer | https://aka.ms/sqlserver2022-express | ✅ Sí |
| DBeaver Community | 24.x | https://dbeaver.io/download/ | ✅ Sí |

**Alternativa 100% online** (si no puedes usar tu computadora habitual):
- **DB Fiddle** (soporta SQL Server) — https://www.db-fiddle.com/ — selecciona "MS SQL Server" en el motor y pega el código de este laboratorio directamente, sin registro.

**Verificación de entorno** (antes de empezar):
```sql
-- Ejecuta esto en DBeaver. Si ves "1" como resultado, estás listo.
SELECT 1 AS conexion_ok;
```

Si no tienes aún una base de datos para esta semana, créala:
```sql
CREATE DATABASE S05_APELLIDO;
USE S05_APELLIDO;
```
*(Puedes reutilizar tu base `EC_S04_APELLIDO` de la semana pasada si lo prefieres — solo asegúrate de usar nombres de tabla distintos a los que ya creaste.)*

---

## OBJETIVO DEL LABORATORIO

Aplicar la Primera Forma Normal (1FN) y la detección de dependencias funcionales sobre reportes planos reales, transformándolos en tablas correctamente estructuradas y creándolas en SQL Server — como paso previo a la normalización completa de tu proyecto (2FN y 3FN en S06-S07).

Al finalizar este lab deberás tener:
- Al menos un grupo repetitivo y un atributo multivalorado correctamente identificados y resueltos en tablas separadas
- Las tablas resultantes creadas con `CREATE TABLE`, con sus claves primarias (simples y compuestas) y claves foráneas
- Al menos tres dependencias funcionales escritas con notación X → Y, confirmadas con una consulta SQL
- Un fragmento de tu propio proyecto llevado a 1FN (Parte 3)

---

## PARTE 1 — EXPLORACIÓN (30 min)

**Caso guiado: TiendaVirtual PeruShop — reporte de pedidos**

En esta parte seguirás instrucciones paso a paso usando un caso ya resuelto. El objetivo es que observes el patrón completo (detección → transformación → verificación) antes de aplicarlo tú mismo en la Parte 2.

### Paso 1 — Crear y cargar la tabla plana original (5 min)

```sql
-- PARTE 1 — EXPLORACIÓN
-- Esta es la tabla TAL COMO llega de un reporte exportado: viola 1FN a propósito.
CREATE TABLE PEDIDO_PLANO (
    idPedido        VARCHAR(10)   NOT NULL,
    idCliente       VARCHAR(10)   NOT NULL,
    nombreCliente   NVARCHAR(60)  NOT NULL,
    telefonosCliente NVARCHAR(60) NOT NULL,   -- viola 1FN: varios teléfonos separados por "/"
    productos       NVARCHAR(200) NOT NULL,   -- viola 1FN: grupo repetitivo comprimido en texto
    totalPedido     DECIMAL(8,2)  NOT NULL
);

INSERT INTO PEDIDO_PLANO VALUES
 ('PED101', 'CLI50', N'Hugo Benavides', '945112233 / 014667788', N'Mouse inalámbrico x1, Teclado mecánico x1', 189.00),
 ('PED102', 'CLI51', N'Sara Ponce',     '978223344',             N'Audífonos bluetooth x2',                     158.00),
 ('PED103', 'CLI50', N'Hugo Benavides', '945112233 / 014667788', N'Mouse inalámbrico x1, Monitor 24" x1',        799.00);
```

### Paso 2 — Observar el problema con una consulta (5 min)

```sql
-- Intenta contar cuántas unidades de "Mouse inalámbrico" se han vendido en total.
-- Spoiler: no se puede hacer con una consulta simple, porque "productos" es texto libre.
SELECT productos FROM PEDIDO_PLANO;
```

### Paso 3 — Crear las tablas en 1FN (10 min)

```sql
-- Tabla principal: solo atributos que dependen directamente de idPedido
CREATE TABLE PEDIDO (
    idPedido    VARCHAR(10)  NOT NULL,
    idCliente   VARCHAR(10)  NOT NULL,
    totalPedido DECIMAL(8,2) NOT NULL,
    CONSTRAINT PK_PEDIDO PRIMARY KEY (idPedido)
);

-- Grupo repetitivo resuelto: una fila por cada producto del pedido
CREATE TABLE DETALLE_PEDIDO (
    idPedido       VARCHAR(10)   NOT NULL,
    nombreProducto NVARCHAR(60)  NOT NULL,
    cantidad       INT           NOT NULL,
    CONSTRAINT PK_DETALLE_PEDIDO PRIMARY KEY (idPedido, nombreProducto),
    CONSTRAINT FK_DETALLE_PEDIDO FOREIGN KEY (idPedido) REFERENCES PEDIDO (idPedido),
    CONSTRAINT CK_DETALLE_CANT CHECK (cantidad > 0)
);

-- Cliente: separado porque sus datos se repiten cada vez que vuelve a comprar
CREATE TABLE CLIENTE (
    idCliente     VARCHAR(10)  NOT NULL,
    nombreCliente NVARCHAR(60) NOT NULL,
    CONSTRAINT PK_CLIENTE PRIMARY KEY (idCliente)
);

-- Atributo multivalorado resuelto: una fila por cada teléfono del cliente
CREATE TABLE CLIENTE_TELEFONO (
    idCliente VARCHAR(10) NOT NULL,
    telefono  VARCHAR(15) NOT NULL,
    CONSTRAINT PK_CLIENTE_TELEFONO PRIMARY KEY (idCliente, telefono),
    CONSTRAINT FK_CLIENTE_TELEFONO FOREIGN KEY (idCliente) REFERENCES CLIENTE (idCliente)
);
```

### Paso 4 — Cargar los datos ya separados (5 min)

```sql
INSERT INTO CLIENTE VALUES ('CLI50', N'Hugo Benavides'), ('CLI51', N'Sara Ponce');

INSERT INTO CLIENTE_TELEFONO VALUES
 ('CLI50', '945112233'), ('CLI50', '014667788'), ('CLI51', '978223344');

INSERT INTO PEDIDO VALUES
 ('PED101', 'CLI50', 189.00), ('PED102', 'CLI51', 158.00), ('PED103', 'CLI50', 799.00);

INSERT INTO DETALLE_PEDIDO VALUES
 ('PED101', N'Mouse inalámbrico', 1), ('PED101', N'Teclado mecánico', 1),
 ('PED102', N'Audífonos bluetooth', 2),
 ('PED103', N'Mouse inalámbrico', 1), ('PED103', N'Monitor 24"', 1);
```

### Paso 5 — Repetir la pregunta del Paso 2, ahora sí respondible (5 min)

```sql
-- Ahora SÍ se puede responder con una consulta simple:
SELECT nombreProducto, SUM(cantidad) AS totalVendido
FROM DETALLE_PEDIDO
WHERE nombreProducto = N'Mouse inalámbrico'
GROUP BY nombreProducto;
-- Resultado esperado: Mouse inalámbrico | 2
```

### Pregunta de reflexión al finalizar Parte 1

> *"¿Qué observaste? ¿Qué pasaría si, en vez de crear DETALLE_PEDIDO con clave compuesta (idPedido, nombreProducto), hubieras dejado la columna 'productos' tal como estaba e intentado resolver la pregunta del Paso 2 'a mano', revisando cada celda?"*

**Escribe tu respuesta aquí (para incluir en el entregable):**

_____________________________________________________________________________

_____________________________________________________________________________

---

## PARTE 2 — APLICACIÓN (60 min)

**Objetivo:** Construir, desde cero, las tablas en 1FN para un caso nuevo, completando un script con partes marcadas `-- TODO`.

### Especificación del producto a construir

**Caso: Clínica Dental "Sonrisas del Sur" — reporte de citas**

La clínica exportó este reporte plano de citas, directo de su sistema de agenda:

| idCita | fechaCita | idPaciente | nombrePaciente | telefonosPaciente | idOdontologo | nombreOdontologo | serviciosRealizados | montoCita |
|---|---|---|---|---|---|---|---|---|
| CIT01 | 2026-09-29 | PAC12 | Gladys Ruiz | 944556677 / 016223344 | ODO02 | Dr. Carlos Peña | Limpieza dental x1, Resina x1 | 180.00 |
| CIT02 | 2026-09-29 | PAC13 | Mario Tello | 988112233 | ODO01 | Dra. Vanessa Luna | Consulta general x1 | 50.00 |
| CIT03 | 2026-09-30 | PAC12 | Gladys Ruiz | 944556677 / 016223344 | ODO01 | Dra. Vanessa Luna | Resina x2, Fluorización x1 | 220.00 |

Al finalizar debes tener: la tabla plana original cargada, las dos violaciones de 1FN identificadas en un comentario, las tablas resultantes creadas con sus claves, y los datos migrados a las tablas nuevas.

### Código esqueleto — completa las partes marcadas `-- TODO`

```sql
-- PARTE 2 — APLICACIÓN
-- Sistema: Clínica Dental "Sonrisas del Sur"

CREATE TABLE CITA_PLANO (
    idCita              VARCHAR(10)   NOT NULL,
    fechaCita           DATE          NOT NULL,
    idPaciente          VARCHAR(10)   NOT NULL,
    nombrePaciente      NVARCHAR(60)  NOT NULL,
    telefonosPaciente   NVARCHAR(60)  NOT NULL,
    idOdontologo        VARCHAR(10)   NOT NULL,
    nombreOdontologo    NVARCHAR(60)  NOT NULL,
    serviciosRealizados NVARCHAR(200) NOT NULL,
    montoCita           DECIMAL(8,2)  NOT NULL
);

INSERT INTO CITA_PLANO VALUES
 ('CIT01', '2026-09-29', 'PAC12', N'Gladys Ruiz', '944556677 / 016223344', 'ODO02', N'Dr. Carlos Peña',  N'Limpieza dental x1, Resina x1',       180.00),
 ('CIT02', '2026-09-29', 'PAC13', N'Mario Tello',  '988112233',             'ODO01', N'Dra. Vanessa Luna', N'Consulta general x1',                  50.00),
 ('CIT03', '2026-09-30', 'PAC12', N'Gladys Ruiz', '944556677 / 016223344', 'ODO01', N'Dra. Vanessa Luna', N'Resina x2, Fluorización x1',           220.00);

-- TODO 1: Escribe, como comentario, qué DOS columnas violan 1FN y de qué tipo es cada una
--         (grupo repetitivo o atributo multivalorado). Justifica en una línea cada una.
-- Pista: una mezcla pares (servicio + cantidad); la otra es una lista de un mismo tipo de dato.


-- TODO 2: Crea la tabla CITA (idCita PK, fechaCita, idPaciente FK, idOdontologo FK, montoCita)
--         Solo con los atributos que dependen directamente de idCita.


-- TODO 3: Crea la tabla DETALLE_CITA que resuelve el grupo repetitivo de "serviciosRealizados".
--         Debe tener clave primaria COMPUESTA y una FK hacia CITA.
--         Columnas sugeridas: idCita, nombreServicio, cantidad.


-- TODO 4: Crea las tablas PACIENTE (idPaciente PK, nombrePaciente) y
--         PACIENTE_TELEFONO (clave compuesta: idPaciente + telefono, con FK a PACIENTE),
--         que resuelven el atributo multivalorado "telefonosPaciente".


-- TODO 5: Crea la tabla ODONTOLOGO (idOdontologo PK, nombreOdontologo).


-- TODO 6: Inserta los datos correspondientes en las 5 tablas nuevas, migrándolos desde
--         CITA_PLANO. Usa INSERT ... VALUES con los datos ya separados (no copies las
--         celdas con "/" o comas tal cual: sepáralas tú mismo en filas distintas).
```

### 3 puntos de verificación — sabes que vas bien si:

- ✅ **Checkpoint 1:** `SELECT * FROM DETALLE_CITA;` devuelve **5 filas** (una por cada servicio individual: Limpieza dental, Resina, Consulta general, Resina, Fluorización), ninguna celda con comas ni "x2" pegado al nombre del servicio.
- ✅ **Checkpoint 2:** `SELECT * FROM PACIENTE_TELEFONO;` devuelve **3 filas** (Gladys Ruiz aparece dos veces, una por cada teléfono; Mario Tello una vez).
- ✅ **Checkpoint 3:** Esta consulta corre sin error y devuelve un resultado (confirma que tus FK están bien definidas):
  ```sql
  SELECT c.idCita, p.nombrePaciente, o.nombreOdontologo, c.montoCita
  FROM CITA c
  INNER JOIN PACIENTE p ON p.idPaciente = c.idPaciente
  INNER JOIN ODONTOLOGO o ON o.idOdontologo = c.idOdontologo;
  ```

### Preguntas de análisis (responder como comentarios en el código o en documento aparte)

1. Escribe tres dependencias funcionales válidas detectadas en el reporte de CITA_PLANO, usando notación X → Y.
2. ¿`idPaciente → idOdontologo` sería una dependencia funcional válida en este reporte? Revisa los datos de Gladys Ruiz (PAC12) antes de responder.
3. La próxima semana (S06) vamos a preguntarnos si DETALLE_CITA tiene dependencias parciales. Adelántate: `montoCita`, que hoy dejaste en la tabla CITA, ¿depende de toda la cita o podría depender solo de qué servicios se realizaron? Anota tu intuición — la retomaremos en S06.

---

## PARTE 3 — DESAFÍO (30 min)

**Objetivo:** Investigar y aplicar el mismo proceso sobre un fragmento de tu propio proyecto de base de datos.

No se provee código esqueleto para esta parte: debes diseñarlo desde cero, siguiendo el mismo patrón de las Partes 1 y 2.

### Instrucciones

1. Retoma el modelo ER de tu proyecto (de S02-S03). Identifica si alguna entidad tiene, o podría tener en un reporte real, un atributo multivalorado o un grupo repetitivo que **todavía no hayas resuelto** con una tabla aparte.
2. Si tu proyecto ya tiene todos sus atributos multivalorados resueltos desde S02-S03, construye tú mismo un reporte plano hipotético de 3 filas (como los de este lab) que un analista de datos podría exportar de tu sistema ANTES de normalizar, y aplícale 1FN completo: detección de violaciones, dependencias funcionales, y `CREATE TABLE` de las tablas resultantes.
3. Antes de diseñar, revisa este repositorio con problemas reales de normalización para contrastar tu criterio: https://github.com/mark-ruuan/Database-Normalization-Practice

```sql
-- PARTE 3 — DESAFÍO
-- Aquí diseñas e implementas la extensión para tu propio proyecto
-- (tabla plana de partida, detección de violaciones, CREATE TABLE de las tablas en 1FN,
--  INSERT de al menos 3 filas de prueba)
```

### Pregunta de reflexión final

> *"¿Qué fue lo más difícil de este laboratorio: detectar la violación de 1FN, decidir la clave compuesta correcta, o escribir las dependencias funcionales con seguridad? ¿Cómo lo resolviste?"*

_____________________________________________________________________________

### Pregunta de conexión con el proyecto real

> *"¿Qué tabla de TU proyecto corre más riesgo de terminar con un grupo repetitivo si no se diseña con cuidado? ¿Por qué esa y no otra?"*

_____________________________________________________________________________

---

## ENTREGABLES

| # | Archivo a entregar | Descripción |
|---|---|---|
| 1 | `S05_LabCasa_APELLIDO.sql` | Script completo de las Partes 1, 2 y 3, en orden, con los comentarios de las preguntas de análisis incluidos |
| 2 | `capturas_parte2.png` | Capturas de los 3 checkpoints de la Parte 2 (código + resultado visibles) |
| 3 | `respuestas_analisis.docx` | Respuestas escritas a las preguntas de reflexión de las Partes 1 y 3, y a las 3 preguntas de análisis de la Parte 2 |

**Formato de entrega:** Subir a Soy Autónoma → Semana 5 → Laboratorio en Casa → antes de la siguiente sesión.

**Rúbrica básica:**

| Criterio | Excelente (100%) | Suficiente (70%) | Insuficiente (<70%) | Pts |
|---|---|---|---|---|
| Parte 1 completa y correcta | Exploración ejecutada sin errores, con reflexión completa | Exploración correcta sin reflexión o con reflexión superficial | Incompleta o con errores de ejecución | 20% |
| Parte 2: producto funcional | Los 6 TODO completos, las 5 tablas creadas y pobladas, 3 checkpoints superados | 4-5 de los 6 TODO completos | Menos de 4 TODO completos | 40% |
| Parte 2: preguntas de análisis | Las 3 respuestas completas y fundamentadas, con DF correctamente notadas | 2 de 3 respuestas completas | 0-1 respuesta completa | 20% |
| Parte 3: desafío | Caso propio (o del proyecto) implementado completo, con reflexión sustentada | Implementado pero incompleto, o sin reflexión | No implementado | 20% |

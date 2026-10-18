# S07 — LABORATORIO EN CASA | Modelado y Diseño de Base de Datos

**ESTADO: BORRADOR — PENDIENTE DE REVISIÓN DOCENTE**

---

| Campo | Detalle |
|---|---|
| **Curso** | Modelado y Diseño de Base de Datos |
| **Semana** | 07 — Transformación ER a Relacional: entidades, relaciones, especialización, PK y FK |
| **Duración estimada** | 2 horas |
| **Modalidad** | Individual o en pareja |
| **Entrega** | Soy Autónoma → Semana 7 → Lab en Casa — antes de la siguiente sesión |

| **Nombre** | ________________________________________ |
|---|---|
| **Código** | ________________________________________ |
| **Sistema de proyecto elegido en S02** | ________________________________________ |

---

## SOFTWARE Y HERRAMIENTAS

| Herramienta | Versión | Link de descarga | ¿Ya instalada? |
|---|---|---|---|
| SQL Server | 2022, contenedor Docker (`sqlserver2025`) | — ya configurado en S05 | ✅ Sí |
| DBeaver Community | 24.x / 25.x | https://dbeaver.io/download/ | ✅ Sí |

**Alternativa 100% online:** DB Fiddle (soporta SQL Server) — https://www.db-fiddle.com/

**Verificación de entorno:**
```sql
SELECT 1 AS conexion_ok;
```

```sql
CREATE DATABASE S07_APELLIDO;
USE S07_APELLIDO;
```

---

## OBJETIVO DEL LABORATORIO

Transformar un modelo entidad-relación completo (con entidades fuertes y débiles, relaciones 1:N, N:M y 1:1, y una especialización) en un esquema relacional implementado en SQL Server, con todas sus claves primarias y foráneas correctamente definidas — **como preparación directa del modelo lógico que presentarás en la Evaluación Parcial de S08.**

Al finalizar este lab deberás tener:
- Un caso guiado completo ya transformado y ejecutado (Parte 1)
- Un caso nuevo, con los 4 tipos de construcción (entidad débil, N:M, 1:1, especialización), transformado por ti (Parte 2)
- **El diagrama ER de tu propio proyecto transformado a su modelo lógico final en SQL Server** (Parte 3) — esto es lo que llevarás a S08

---

## PARTE 1 — EXPLORACIÓN (30 min)

**Caso guiado, ya resuelto: Veterinaria PataFeliz**

Modelo conceptual:
```
VETERINARIO (dni, nombres, especialidad)
MASCOTA (codigoMascota, nombreMascota, especie, {vacuna})
Relación: VETERINARIO (1) ──atiende──> (N) MASCOTA     [1:N]
```

Ejecuta este script completo, línea por línea, y observa cada resultado antes de seguir.

```sql
-- PARTE 1 — EXPLORACIÓN
-- Entidades fuertes
CREATE TABLE VETERINARIO (
    dni          CHAR(8)      NOT NULL,
    nombres      NVARCHAR(60) NOT NULL,
    especialidad NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_VETERINARIO PRIMARY KEY (dni)
);

CREATE TABLE MASCOTA (
    codigoMascota VARCHAR(10)  NOT NULL,
    nombreMascota NVARCHAR(40) NOT NULL,
    especie       NVARCHAR(30) NOT NULL,
    dni           CHAR(8)      NOT NULL,   -- FK: MASCOTA es el lado "N" de la relación 1:N
    CONSTRAINT PK_MASCOTA PRIMARY KEY (codigoMascota),
    CONSTRAINT FK_MASCOTA_VETERINARIO FOREIGN KEY (dni) REFERENCES VETERINARIO (dni)
);

-- Atributo multivalorado {vacuna} -> tabla aparte
CREATE TABLE MASCOTA_VACUNA (
    codigoMascota VARCHAR(10)  NOT NULL,
    vacuna        NVARCHAR(40) NOT NULL,
    fechaAplicada DATE         NOT NULL,
    CONSTRAINT PK_MASCOTA_VACUNA PRIMARY KEY (codigoMascota, vacuna),
    CONSTRAINT FK_MASCOTA_VACUNA FOREIGN KEY (codigoMascota) REFERENCES MASCOTA (codigoMascota)
);

-- Datos de prueba
INSERT INTO VETERINARIO VALUES ('40111111', N'Dra. Pilar Soto', N'Cirugía'), ('40222222', N'Dr. Iván Mejía', N'Dermatología');
INSERT INTO MASCOTA VALUES ('M001', N'Rocky', N'Perro', '40111111'), ('M002', N'Misha', N'Gato', '40222222');
INSERT INTO MASCOTA_VACUNA VALUES
 ('M001', N'Antirrábica', '2026-03-10'), ('M001', N'Parvovirus', '2026-04-02'), ('M002', N'Antirrábica', '2026-05-15');
```

```sql
-- Verificación: la FK está en el lado correcto
SELECT m.nombreMascota, v.nombres AS veterinario
FROM MASCOTA m
JOIN VETERINARIO v ON v.dni = m.dni;
-- Resultado esperado: 2 filas, cada mascota con su veterinario correcto.
```

### Pregunta de reflexión al finalizar Parte 1

> *"¿Qué pasaría si, en vez de poner `dni` en MASCOTA, lo hubieras puesto `codigoMascota` en VETERINARIO? ¿Por qué esa alternativa no funciona si un veterinario atiende más de una mascota?"*

**Escribe tu respuesta aquí:**

_____________________________________________________________________________

---

## PARTE 2 — APLICACIÓN (60 min)

**Objetivo:** Transformar un modelo ER completo (con los 4 tipos de construcción vistos en la sesión) completando un script con partes marcadas `-- TODO`.

### Caso: Spa & Bienestar RelaxTotal

```
CLIENTE (codigoCliente, nombres, {correo})
TERAPEUTA (dni, nombres, especialidad)
SERVICIO (idServicio, nombreServicio, duracionMin)
    SERVICIO se especializa en MASAJE (tipoMasaje, presionRecomendada) y
    FACIAL (tipoPiel, productosUsados) — disjunta y total (todo servicio es de un solo tipo).

Relaciones:
- CLIENTE (N) ──reserva──> (N) SERVICIO   [N:M, vía RESERVA: fecha, hora, dni del terapeuta asignado]
- CLIENTE (1) ──tiene──> (1) MEMBRESIA (numeroMembresia, nivel, fechaInicio)
    [1:1 PARCIAL: no todo cliente tiene membresía todavía]
- CLIENTE (1) ──presenta──> (N) QUEJA (numeroQueja, fecha, descripcion)
    [QUEJA es ENTIDAD DÉBIL: se numera de forma independiente por cada cliente]
```

### Código esqueleto — completa las partes marcadas `-- TODO`

```sql
-- PARTE 2 — APLICACIÓN
-- Sistema: Spa & Bienestar RelaxTotal

-- TODO 1: Crea CLIENTE (codigoCliente PK, nombres) y resuelve el atributo
--         multivalorado {correo} en una tabla CLIENTE_CORREO.


-- TODO 2: Crea TERAPEUTA (dni PK, nombres, especialidad).


-- TODO 3: Crea SERVICIO con un discriminador (tipoServicio) para la especialización
--         disjunta y total, y las tablas MASAJE y FACIAL con PK = FK hacia SERVICIO.
--         Pista: repasa el ejemplo CAMION/MINIBUS/CAMIONETA de la sesión — la PK de
--         la subclase NUNCA es un IDENTITY nuevo.


-- TODO 4: Resuelve la relación N:M CLIENTE-SERVICIO en una tabla RESERVA, con sus
--         atributos propios (fecha, hora) y la FK hacia el terapeuta asignado
--         (dni de TERAPEUTA, que NO forma parte de la clave — es un dato adicional
--         de la reserva, no parte de lo que la identifica).
--         Pista: ¿qué pasa si el mismo cliente reserva el mismo servicio dos veces
--         en fechas distintas? Esa pregunta define tu clave primaria.


-- TODO 5: Resuelve la relación 1:1 PARCIAL CLIENTE-MEMBRESIA. Decide en qué tabla
--         va la FK, pensando en minimizar los NULL (repasa el Subtema 7.3).


-- TODO 6: Resuelve QUEJA como entidad débil de CLIENTE.


-- TODO 7: Inserta al menos 2 filas de datos de prueba en cada tabla, consistentes
--         entre sí (ej. una reserva debe usar un codigoCliente, idServicio y dni
--         que ya existan en sus tablas).
```

### 3 puntos de verificación — sabes que vas bien si:

- ✅ **Checkpoint 1:** `SELECT name FROM sys.tables ORDER BY name;` devuelve **9 tablas**: `CLIENTE`, `CLIENTE_CORREO`, `FACIAL`, `MASAJE`, `MEMBRESIA`, `QUEJA`, `RESERVA`, `SERVICIO`, `TERAPEUTA`.
- ✅ **Checkpoint 2:** Esta consulta corre sin error y devuelve tus datos de prueba (confirma que las FK de RESERVA están bien definidas):
  ```sql
  SELECT c.nombres AS cliente, s.nombreServicio, t.nombres AS terapeuta, r.fecha, r.hora
  FROM RESERVA r
  JOIN CLIENTE c ON c.codigoCliente = r.codigoCliente
  JOIN SERVICIO s ON s.idServicio = r.idServicio
  JOIN TERAPEUTA t ON t.dni = r.dni;
  ```
- ✅ **Checkpoint 3:** `SELECT * FROM MEMBRESIA;` devuelve **menos filas que** `SELECT * FROM CLIENTE;` (confirma que resolviste correctamente la relación 1:1 PARCIAL — no todo cliente tiene membresía).

### Preguntas de análisis

1. ¿Por qué `dni` del terapeuta en RESERVA NO forma parte de la clave primaria de esa tabla, a diferencia de `codigoCliente` e `idServicio`?
2. Si RelaxTotal quisiera agregar un tercer tipo de servicio, "MANICURA" (con atributos propios: tipoEsmalte, incluyeDecoracion), ¿qué tablas tendrías que crear y cuáles NO tendrías que tocar?
3. La próxima semana (S08) presentas tu proyecto completo. ¿Cuántas de las 4 construcciones de esta sesión (multivalorado, entidad débil, N:M, especialización/1:1) tiene tu propio diagrama ER?

---

## PARTE 3 — DESAFÍO (30 min)

**Objetivo: transformar el diagrama ER completo de TU PROPIO PROYECTO al modelo lógico final — lo que vas a presentar en S08.**

No se provee código esqueleto: este es tu proyecto real.

### Instrucciones

1. Recupera el diagrama ER de tu proyecto (de S02-S03, con su especialización si la tiene) y las tablas que ya normalizaste en S05-S06.
2. Para **cada** entidad, relación y especialización de tu diagrama, aplica las reglas de esta semana:
   - Entidad fuerte → tabla con PK propia.
   - Entidad débil (si tienes alguna) → tabla con PK compuesta (FK del dueño + clave parcial).
   - Relación 1:N → FK en el lado "muchos".
   - Relación N:M → tabla intermedia con PK compuesta.
   - Relación 1:1 → FK en el lado con participación total.
   - Especialización → tabla por superclase + tabla por subclase, PK=FK, discriminador si es disjunta.
3. Implementa TODO el modelo en SQL Server: `CREATE TABLE` de cada tabla, con sus PK y FK.
4. Inserta al menos 2-3 filas de datos de prueba en tus tablas principales.
5. Verifica con un `JOIN` que las relaciones funcionan correctamente.

```sql
-- PARTE 3 — DESAFÍO
-- Modelo lógico final de TU proyecto
-- (CREATE TABLE de cada entidad/relación/especialización de tu diagrama, con PK y FK,
--  datos de prueba, y una consulta JOIN que confirme que el modelo funciona)
```

Si tu proyecto NO tiene todavía alguna de las 4 construcciones (por ejemplo, no tiene especialización), revisa si corresponde agregarla honestamente al negocio, o documenta por qué tu proyecto no la necesita — ambas son respuestas válidas para S08, siempre que estén justificadas.

### Pregunta de reflexión final

> *"¿Qué parte de tu propio diagrama fue más difícil de transformar: una entidad débil, una relación N:M, una 1:1, o la especialización? ¿Por qué?"*

_____________________________________________________________________________

### Pregunta de conexión con el proyecto real

> *"¿Tu modelo lógico final de hoy es exactamente el que vas a presentar en la Evaluación Parcial, o todavía le falta algo? Si le falta algo, ¿qué es?"*

_____________________________________________________________________________

---

## ENTREGABLES

| # | Archivo a entregar | Descripción |
|---|---|---|
| 1 | `S07_LabCasa_APELLIDO.sql` | Script completo de las Partes 1, 2 y 3, en orden |
| 2 | `capturas_parte2.png` | Capturas de los 3 checkpoints de la Parte 2 |
| 3 | `modelo_logico_proyecto_APELLIDO.sql` | El script de la Parte 3 — **este archivo lo vuelves a usar en S08** |
| 4 | `respuestas_analisis.docx` | Respuestas a las preguntas de reflexión y análisis |

**Formato de entrega:** Subir a Soy Autónoma → Semana 7 → Laboratorio en Casa → antes de la siguiente sesión.

**Rúbrica básica:**

| Criterio | Excelente (100%) | Suficiente (70%) | Insuficiente (<70%) | Pts |
|---|---|---|---|---|
| Parte 1 completa y correcta | Ejecutada sin error, reflexión completa | Ejecutada sin error, reflexión superficial | Con errores de ejecución | 15% |
| Parte 2: producto funcional | Los 7 TODO completos, 9 tablas creadas, 3 checkpoints superados | 5-6 de los 7 TODO completos | Menos de 5 TODO completos | 30% |
| Parte 2: preguntas de análisis | Las 3 respuestas completas y fundamentadas | 2 de 3 completas | 0-1 completa | 15% |
| Parte 3: proyecto propio | Modelo lógico completo de su proyecto, con PK/FK correctas y JOIN de verificación | Modelo parcial o con errores menores de FK | No implementado o sin relación real con su proyecto | 40% |

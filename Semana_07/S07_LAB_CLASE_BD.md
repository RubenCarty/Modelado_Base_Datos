# LABORATORIO EN CLASE — SEMANA 07
## Modelado y Diseño de Base de Datos

| Campo | Detalle |
|---|---|
| **Curso** | Modelado y Diseño de Base de Datos |
| **Semana** | 07 |
| **Tema** | Transformación modelo ER a relacional: entidades, relaciones, especialización, PK y FK |
| **Nombre** | _________________________________________________ |
| **Código** | _________________ |
| **Duración** | 35–40 minutos |
| **Modalidad** | Individual (se puede consultar al compañero) |
| **Herramienta** | SQL Server (contenedor `sqlserver2025`) + DBeaver |

---

## ACCESO AL ENTORNO (máx. 2 min)

```
1. Docker Desktop → Containers → confirma que "sqlserver2025" esté Running.
2. DBeaver → tu conexión → crea o usa tu base S07_APELLIDO:
   CREATE DATABASE S07_APELLIDO;  USE S07_APELLIDO;
3. Clic derecho en la conexión → "SQL Editor" → "New SQL Script"
✅ Listo para transformar.
```

---

## ACTIVIDAD ÚNICA (35–40 min)
**El docente NO explica más de 5 min — el lab es autoexplicativo. Aquí NO se te da el script armado: tú transformas el diagrama.**

**Caso: Academia de Música Armonía**

La academia ofrece cursos de instrumento con profesores asignados. Este es su modelo conceptual (ya validado, no lo cuestiones — tu trabajo es transformarlo, no rediseñarlo):

```
PROFESOR (dni, nombres, apellidos, {telefono})
CURSO (idCurso, nombreCurso, instrumento)
ALUMNO (codigoAlumno, nombres, apellidos)
INSTRUMENTO (idInstrumento, nombreInstrumento, marca)

Relaciones:
- PROFESOR (1) ──dicta──> (N) CURSO                         [1:N]
- ALUMNO (N) ──se inscribe──> (N) CURSO                      [N:M, con atributos: fechaInscripcion, horario]
- PROFESOR (1) ──tiene──> (1) CONTRATO (numeroContrato, fechaInicio, sueldo)   [1:1, CONTRATO siempre tiene profesor]
- ALUMNO (1) ──recibe──> (N) EVALUACION (numeroEvaluacion, idCurso, fecha, nota)
      EVALUACION es una ENTIDAD DÉBIL: "evaluación 1, 2, 3..." se numera de forma
      independiente para cada alumno (no existe un correlativo único de toda la academia).
- INSTRUMENTO se especializa en CUERDA (numeroCuerdas, tipoMaterial) y
  PERCUSION (numeroPiezas, tipoBaqueta) — todo instrumento es de un solo tipo (disjunta),
  y todo instrumento registrado tiene su tipo definido (total).
```

---

### PASO 1 — Entidades fuertes y relación 1:N (12 min)

**Instrucciones:**
1. Crea las 4 tablas de las entidades fuertes (`PROFESOR`, `CURSO`, `ALUMNO`, `INSTRUMENTO`) con su PK.
2. Resuelve el atributo multivalorado `{telefono}` de PROFESOR con una tabla aparte.
3. Resuelve la relación 1:N **PROFESOR–CURSO** (recuerda: la FK va en el lado "muchos").

```sql
-- Escribe aquí tus CREATE TABLE para PROFESOR, PROFESOR_TELEFONO, ALUMNO e INSTRUMENTO
-- (sin pistas de código — aplica las reglas del Subtema 7.1 de la sesión)



-- CURSO debe incluir la FK hacia PROFESOR
```

**✅ CHECKPOINT 1:** ¿Tu tabla `CURSO` tiene una columna `dni` (o `idProfesor`, según cómo la llamaste) con una `FOREIGN KEY` hacia `PROFESOR`? Si no, revisa: ¿de qué lado de la relación 1:N está CURSO?

---

### PASO 2 — Entidad débil y relación N:M (15 min)

**Instrucciones:**
1. Resuelve **EVALUACION** como entidad débil (depende de ALUMNO; `numeroEvaluacion` es su clave parcial).
2. Resuelve la relación N:M **ALUMNO–CURSO** con sus atributos propios (`fechaInscripcion`, `horario`) en una tabla `INSCRIPCION`.

```sql
-- Escribe aquí EVALUACION (entidad débil) e INSCRIPCION (N:M con atributos)



```

**✅ CHECKPOINT 2:** Ejecuta esta consulta para autoevaluarte — debe devolver **"OK"** en ambas filas si tu diseño es correcto:

```sql
SELECT
    CASE WHEN COUNT(*) = 2 THEN 'OK: EVALUACION tiene 2 columnas en su PK' ELSE 'REVISA: PK incompleta' END AS Resultado
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'EVALUACION' AND CONSTRAINT_NAME LIKE 'PK%';

SELECT
    CASE WHEN COUNT(*) >= 2 THEN 'OK: INSCRIPCION tiene al menos 2 columnas en su PK' ELSE 'REVISA: PK incompleta' END AS Resultado
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'INSCRIPCION' AND CONSTRAINT_NAME LIKE 'PK%';
```

---

### PASO 3 — Relación 1:1 y especialización (10 min)

**Instrucciones:**
1. Resuelve **CONTRATO** (1:1 con PROFESOR; CONTRATO siempre tiene profesor → la FK va en CONTRATO).
2. Resuelve la especialización de **INSTRUMENTO** en **CUERDA** y **PERCUSION** (disjunta y total: agrega un discriminador en INSTRUMENTO; recuerda que la PK de cada subclase es la misma PK de la superclase).

```sql
-- Escribe aquí CONTRATO, el discriminador de INSTRUMENTO, CUERDA y PERCUSION



```

**✅ CHECKPOINT 3:** Ejecuta `SELECT name FROM sys.tables ORDER BY name;` — deben aparecer **10 tablas**: `ALUMNO`, `CONTRATO`, `CUERDA`, `CURSO`, `EVALUACION`, `INSCRIPCION`, `INSTRUMENTO`, `PERCUSION`, `PROFESOR`, `PROFESOR_TELEFONO`.

---

## PREGUNTA DE ANÁLISIS FINAL (responder en el mismo script o en papel)

> *"Si mañana la academia quisiera agregar un tercer tipo de instrumento, 'VIENTO' (con atributos propios: materialBoquilla, requiereLimpiezaDiaria), ¿qué tendrías que modificar de las tablas que ya creaste, y qué NO tendrías que tocar?"*

_____________________________________________________________________________

---

## ROL DEL DOCENTE DURANTE EL LABORATORIO

**QUÉ OBSERVAR al circular:**
- Estudiantes que colocan la FK de CURSO hacia PROFESOR correctamente (lado "muchos") sin ayuda, **vs.** quienes la ponen al revés o en ambas tablas.
- Estudiantes que usan clave compuesta real en EVALUACION e INSCRIPCION, **vs.** quienes usan un `IDENTITY` simple "para simplificar" sin incluir las FK en la PK.
- Error específico frecuente: inventar una PK nueva (`idCuerda IDENTITY`) para CUERDA/PERCUSION en vez de reusar `idInstrumento`.

**3 PREGUNTAS DE ANDAMIAJE** (para estudiantes bloqueados, sin dar la respuesta):
1. *"¿De qué lado de la relación PROFESOR-CURSO puede haber 'muchos'? Ese lado es el que necesita la columna extra."*
2. *"¿'Evaluación 3' significa algo sin saber de qué alumno es? Esa es la señal de entidad débil."*
3. *"Repasa el ejemplo de CAMION/MINIBUS/CAMIONETA de la sesión de hoy: ¿qué usaron como PK de cada subclase?"*

**CIERRE DEL LAB (5 min):**
- Pedir a 2 voluntarios que proyecten su Checkpoint 3 (las 10 tablas) y expliquen en voz alta una de sus decisiones de diseño.
- Preguntar al grupo: *"¿Alguien puso la FK de CONTRATO en PROFESOR en vez de en CONTRATO? ¿Por qué esa elección genera más NULLs?"*
- Mostrar la solución de referencia (`S07_SOLUCION_LAB_DOCENTE_BD.md`) y señalar el error más común visto en la sesión.

---

## ENTREGABLE EN CLASE

El estudiante muestra al docente, al finalizar: su script con las 10 tablas creadas, el resultado del Checkpoint 3, y su respuesta a la pregunta de análisis final.

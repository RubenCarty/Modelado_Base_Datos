# LABORATORIO EN CLASE — SEMANA 06
## Modelado y Diseño de Base de Datos

| Campo | Detalle |
|---|---|
| **Curso** | Modelado y Diseño de Base de Datos |
| **Semana** | 06 |
| **Tema** | Segunda y Tercera Forma Normal, Descomposición sin Pérdida de Información |
| **Nombre** | _________________________________________________ |
| **Código** | _________________ |
| **Duración** | 35–40 minutos |
| **Modalidad** | Individual (se puede consultar al compañero) |
| **Herramienta** | SQL Server (contenedor `sqlserver2025`) + DBeaver |

---

## ACCESO AL ENTORNO (máx. 2 min)

```
1. Docker Desktop → Containers → confirma que "sqlserver2025" esté Running
   (si está detenido, clic en ▶ antes de continuar).
2. DBeaver → tu conexión ya guardada → usa tu base S05_APELLIDO o S06_APELLIDO.
3. Clic derecho en la conexión → "SQL Editor" → "New SQL Script"
4. Pega el código base provisto abajo (Paso 1).
✅ Listo para ejecutar.
```

---

## ACTIVIDAD ÚNICA (35–40 min)
**El docente NO explica más de 5 min — el lab es autoexplicativo.**

**Caso: Hotel Pacífico — continuación de la semana pasada**

Retomas el Hotel Pacífico del Lab de S05. Esta semana llegaron dos reportes nuevos, ya en 1FN, con columnas adicionales que esconden una dependencia parcial y una transitiva.

**Reporte A — servicios por reserva (clave compuesta: idReserva + idServicio):**

| idReserva | idServicio | nombreServicio | categoriaServicio | precioServicio | cantidad |
|---|---|---|---|---|---|
| RES01 | SRV01 | Desayuno buffet | Alimentación | 35.00 | 2 |
| RES01 | SRV02 | Spa | Bienestar | 120.00 | 1 |
| RES02 | SRV03 | Minibar | Alimentación | 40.00 | 1 |
| RES03 | SRV01 | Desayuno buffet | Alimentación | 35.00 | 2 |
| RES03 | SRV03 | Minibar | Alimentación | 40.00 | 1 |

**Reporte B — cabecera de reserva con la habitación aplanada (clave simple: idReserva):**

| idReserva | idHuesped | nombreHuesped | idHabitacion | tipoHabitacion | precioNocheHabitacion |
|---|---|---|---|---|---|
| RES01 | HUE07 | Patricia Alva | HAB12 | Doble Vista al Mar | 220.00 |
| RES02 | HUE08 | Renzo Díaz | HAB05 | Simple | 110.00 |
| RES03 | HUE07 | Patricia Alva | HAB09 | Suite | 350.00 |

---

### PASO 1 — Cargar los reportes y detectar la dependencia parcial (12 min)

```sql
CREATE TABLE RESERVA_SERVICIO_EXT (
    idReserva         VARCHAR(10)   NOT NULL,
    idServicio        VARCHAR(10)   NOT NULL,
    nombreServicio    NVARCHAR(60)  NOT NULL,
    categoriaServicio NVARCHAR(30)  NOT NULL,
    precioServicio    DECIMAL(8,2)  NOT NULL,
    cantidad          INT           NOT NULL
);
INSERT INTO RESERVA_SERVICIO_EXT VALUES
 ('RES01', 'SRV01', N'Desayuno buffet', N'Alimentación', 35.00, 2),
 ('RES01', 'SRV02', N'Spa',              N'Bienestar',    120.00, 1),
 ('RES02', 'SRV03', N'Minibar',          N'Alimentación',  40.00, 1),
 ('RES03', 'SRV01', N'Desayuno buffet',  N'Alimentación',  35.00, 2),
 ('RES03', 'SRV03', N'Minibar',          N'Alimentación',  40.00, 1);

-- Comprueba la dependencia idServicio → (nombre, categoría, precio):
SELECT idServicio,
       COUNT(DISTINCT nombreServicio)    AS nombres,
       COUNT(DISTINCT categoriaServicio) AS categorias,
       COUNT(DISTINCT precioServicio)    AS precios
FROM RESERVA_SERVICIO_EXT
GROUP BY idServicio
HAVING COUNT(DISTINCT nombreServicio) > 1 OR COUNT(DISTINCT precioServicio) > 1;
```

**✅ CHECKPOINT 1:** la consulta de comprobación debe devolver **0 filas** (confirma que la dependencia es real: cada idServicio trae siempre el mismo nombre, categoría y precio).

---

### PASO 2 — Descomponer a 2FN y a 3FN (15 min)

```sql
-- 2FN: separa SERVICIO de la clave compuesta (idReserva, idServicio)
CREATE TABLE SERVICIO (
    idServicio        VARCHAR(10)  NOT NULL,
    nombreServicio    NVARCHAR(60) NOT NULL,
    categoriaServicio NVARCHAR(30) NOT NULL,
    precioServicio    DECIMAL(8,2) NOT NULL,
    CONSTRAINT PK_SERVICIO PRIMARY KEY (idServicio)
);
CREATE TABLE DETALLE_RESERVA (
    idReserva  VARCHAR(10) NOT NULL,
    idServicio VARCHAR(10) NOT NULL,
    cantidad   INT         NOT NULL,
    CONSTRAINT PK_DETALLE_RESERVA PRIMARY KEY (idReserva, idServicio),
    CONSTRAINT FK_DETALLE_SERVICIO FOREIGN KEY (idServicio) REFERENCES SERVICIO (idServicio),
    CONSTRAINT CK_DETALLE_RESERVA_CANT CHECK (cantidad > 0)
);
INSERT INTO SERVICIO (idServicio, nombreServicio, categoriaServicio, precioServicio)
SELECT DISTINCT idServicio, nombreServicio, categoriaServicio, precioServicio FROM RESERVA_SERVICIO_EXT;
INSERT INTO DETALLE_RESERVA (idReserva, idServicio, cantidad)
SELECT idReserva, idServicio, cantidad FROM RESERVA_SERVICIO_EXT;

-- 3FN: la cabecera (Reporte B) tiene clave SIMPLE (idReserva), pero tipoHabitacion y
-- precioNocheHabitacion dependen de idHabitacion, no directamente de idReserva: es TRANSITIVA.
CREATE TABLE HABITACION (
    idHabitacion           VARCHAR(10)  NOT NULL,
    tipoHabitacion         NVARCHAR(40) NOT NULL,
    precioNocheHabitacion  DECIMAL(8,2) NOT NULL,
    CONSTRAINT PK_HABITACION PRIMARY KEY (idHabitacion)
);
CREATE TABLE HUESPED (
    idHuesped     VARCHAR(10)  NOT NULL,
    nombreHuesped NVARCHAR(60) NOT NULL,
    CONSTRAINT PK_HUESPED PRIMARY KEY (idHuesped)
);
CREATE TABLE RESERVA (
    idReserva    VARCHAR(10) NOT NULL,
    idHuesped    VARCHAR(10) NOT NULL,
    idHabitacion VARCHAR(10) NOT NULL,
    CONSTRAINT PK_RESERVA PRIMARY KEY (idReserva),
    CONSTRAINT FK_RESERVA_HUESPED    FOREIGN KEY (idHuesped)    REFERENCES HUESPED (idHuesped),
    CONSTRAINT FK_RESERVA_HABITACION FOREIGN KEY (idHabitacion) REFERENCES HABITACION (idHabitacion)
);

INSERT INTO HUESPED VALUES ('HUE07', N'Patricia Alva'), ('HUE08', N'Renzo Díaz');
INSERT INTO HABITACION VALUES
 ('HAB12', N'Doble Vista al Mar', 220.00), ('HAB05', N'Simple', 110.00), ('HAB09', N'Suite', 350.00);
INSERT INTO RESERVA VALUES
 ('RES01', 'HUE07', 'HAB12'), ('RES02', 'HUE08', 'HAB05'), ('RES03', 'HUE07', 'HAB09');
```

**✅ CHECKPOINT 2:** `SELECT * FROM HABITACION;` → **3 filas** (ninguna repetida, aunque HUE07 tenga 2 reservas, cada habitación aparece una sola vez aquí porque son habitaciones distintas en este ejemplo).

---

### PASO 3 — Verificar que ambas descomposiciones son sin pérdida (8 min)

```sql
-- Verificación 2FN: reconstruir RESERVA_SERVICIO_EXT
SELECT COUNT(*) AS diferencias_servicios FROM (
    SELECT idReserva, idServicio, nombreServicio, categoriaServicio, precioServicio, cantidad
    FROM RESERVA_SERVICIO_EXT
    EXCEPT
    SELECT dr.idReserva, dr.idServicio, s.nombreServicio, s.categoriaServicio, s.precioServicio, dr.cantidad
    FROM DETALLE_RESERVA dr INNER JOIN SERVICIO s ON s.idServicio = dr.idServicio
) AS diff;

-- Verificación 3FN: reconstruir la cabecera (idReserva, idHuesped, nombreHuesped, idHabitacion, tipoHabitacion, precioNocheHabitacion)
SELECT r.idReserva, r.idHuesped, h.nombreHuesped, r.idHabitacion, hb.tipoHabitacion, hb.precioNocheHabitacion
FROM RESERVA r
INNER JOIN HUESPED h ON h.idHuesped = r.idHuesped
INNER JOIN HABITACION hb ON hb.idHabitacion = r.idHabitacion
ORDER BY r.idReserva;
```

**✅ CHECKPOINT 3:** la primera consulta debe devolver **0** (sin diferencias); la segunda debe devolver **3 filas**, idénticas en contenido al Reporte B original.

---

## PREGUNTA DE ANÁLISIS FINAL (responder en el mismo script o en papel)

> *"HAB12 (Doble Vista al Mar) y HAB09 (Suite) son habitaciones distintas que ambas reservó Patricia Alva. Si el hotel decidiera, por error, usar `tipoHabitacion` (en vez de `idHabitacion`) para relacionar RESERVA con HABITACION, ¿qué pasaría el día que exista una 'Suite' en otro piso con un precio distinto por noche?"*

_____________________________________________________________________________

---

## ROL DEL DOCENTE DURANTE EL LABORATORIO

**QUÉ OBSERVAR al circular:**
- Estudiantes que, antes de escribir el `CREATE TABLE`, verifican primero la dependencia con la consulta `GROUP BY ... HAVING` del Paso 1, **vs.** quienes van directo a crear tablas sin comprobar nada.
- Estudiantes que identifican correctamente que el Reporte B tiene clave SIMPLE y aun así tiene un problema (3FN, no 2FN) **vs.** quienes buscan dependencia parcial donde no aplica.
- Error específico frecuente: usar `tipoHabitacion` o `nombreServicio` como clave foránea en vez de `idHabitacion`/`idServicio` — mismo error de fondo que la pregunta de análisis final.

**3 PREGUNTAS DE ANDAMIAJE** (para estudiantes bloqueados, sin dar la respuesta):
1. *"¿La clave de ese reporte es compuesta o simple? Eso te dice si buscas 2FN o 3FN."*
2. *"Dibuja la cadena: idReserva → idHabitacion → tipoHabitacion. ¿Cuántos pasos hay? Ese número te dice si es directa o transitiva."*
3. *"¿Qué consulta del Paso 1 usaste la semana pasada, en el caso de ChaskiExpress de la Transformación, para comprobar una dependencia antes de separar la tabla? Aplícala aquí."*

**CIERRE DEL LAB (5 min):**
- Pedir a 2 voluntarios que proyecten su Checkpoint 3 (ambas verificaciones).
- Preguntar al grupo: *"¿Alguien detectó mal la dependencia del Reporte B como parcial en vez de transitiva? ¿Qué pista se les pasó?"*
- Mostrar la solución de referencia (`S06_SOLUCION_LAB_DOCENTE_BD.md`) y señalar el error más común visto en la sesión.

---

## ENTREGABLE EN CLASE

El estudiante muestra al docente, al finalizar: su script con las 5 tablas nuevas creadas (SERVICIO, DETALLE_RESERVA, HABITACION, HUESPED, RESERVA), el resultado de ambas verificaciones del Paso 3, y la respuesta a la pregunta de análisis final.

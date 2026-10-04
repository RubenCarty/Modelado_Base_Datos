# LABORATORIO EN CLASE — SEMANA 05
## Modelado y Diseño de Base de Datos

| Campo | Detalle |
|---|---|
| **Curso** | Modelado y Diseño de Base de Datos |
| **Semana** | 05 |
| **Tema** | Primera Forma Normal (1FN) y Dependencias Funcionales |
| **Nombre** | _________________________________________________ |
| **Código** | _________________ |
| **Duración** | 35–40 minutos |
| **Modalidad** | Individual (se puede consultar al compañero) |
| **Herramienta** | SQL Server + DBeaver (ya conectados) |

---

## ACCESO AL ENTORNO (máx. 2 min)

```
1. DBeaver ya está abierto y conectado a SQL Server.
2. Usa tu base de datos EC_S04_APELLIDO (de la semana pasada) o crea una nueva:
   CREATE DATABASE S05_APELLIDO;  USE S05_APELLIDO;
3. Clic derecho en la conexión → "SQL Editor" → "New SQL Script"
4. Pega el código base provisto abajo (Paso 1).
✅ Listo para ejecutar.
```

---

## ACTIVIDAD ÚNICA (35–40 min)
**El docente NO explica más de 5 min — el lab es autoexplicativo.**

**Caso: Hotel Pacífico — reporte de reservas**

El Hotel Pacífico, en Máncora, exportó este reporte plano de reservas de la última semana, directo de su sistema de recepción, para que su equipo de sistemas lo evalúe:

| idReserva | fechaCheckIn | idHuesped | nombreHuesped | telefonosHuesped | idHabitacion | tipoHabitacion | serviciosConsumidos | montoTotal |
|---|---|---|---|---|---|---|---|---|
| RES01 | 2026-09-28 | HUE07 | Patricia Alva | 987445566 / 012233445 | HAB12 | Doble Vista al Mar | Desayuno buffet x2, Spa x1 | 540.00 |
| RES02 | 2026-09-28 | HUE08 | Renzo Díaz | 998334455 | HAB05 | Simple | Minibar x1 | 160.00 |
| RES03 | 2026-09-29 | HUE07 | Patricia Alva | 987445566 / 012233445 | HAB09 | Suite | Desayuno buffet x2, Minibar x1, Lavandería x1 | 890.00 |

---

### PASO 1 — Cargar el reporte plano (8 min)

```sql
CREATE TABLE RESERVA_PLANO (
    idReserva           VARCHAR(10)   NOT NULL,
    fechaCheckIn        DATE          NOT NULL,
    idHuesped           VARCHAR(10)   NOT NULL,
    nombreHuesped       NVARCHAR(60)  NOT NULL,
    telefonosHuesped    NVARCHAR(60)  NOT NULL,
    idHabitacion        VARCHAR(10)   NOT NULL,
    tipoHabitacion      NVARCHAR(40)  NOT NULL,
    serviciosConsumidos NVARCHAR(200) NOT NULL,
    montoTotal          DECIMAL(8,2)  NOT NULL
);

INSERT INTO RESERVA_PLANO VALUES
 ('RES01', '2026-09-28', 'HUE07', N'Patricia Alva', '987445566 / 012233445', 'HAB12', N'Doble Vista al Mar', N'Desayuno buffet x2, Spa x1',                        540.00),
 ('RES02', '2026-09-28', 'HUE08', N'Renzo Díaz',    '998334455',             'HAB05', N'Simple',             N'Minibar x1',                                        160.00),
 ('RES03', '2026-09-29', 'HUE07', N'Patricia Alva', '987445566 / 012233445', 'HAB09', N'Suite',               N'Desayuno buffet x2, Minibar x1, Lavandería x1',    890.00);

SELECT * FROM RESERVA_PLANO;
```

**✅ CHECKPOINT 1:** ¿Ves 3 filas con las columnas `telefonosHuesped` y `serviciosConsumidos` mostrando varios valores juntos en la misma celda? Si sí, avanza. Si no, revisa que el `INSERT` se haya ejecutado sin error.

---

### PASO 2 — Identificar las violaciones y escribir las dependencias funcionales (10 min)

En un comentario al inicio de tu script, responde:

```sql
/* PASO 2 — ANÁLISIS
   a) ¿Qué columna es un grupo repetitivo? ¿Por qué?
      

   b) ¿Qué columna es un atributo multivalorado? ¿Por qué?
      

   c) Escribe 3 dependencias funcionales válidas del reporte (notación X → Y):
      1.
      2.
      3.
*/
```

**✅ CHECKPOINT 2:** Tu análisis debe nombrar `serviciosConsumidos` como grupo repetitivo (pares servicio+cantidad variables) y `telefonosHuesped` como atributo multivalorado (lista simple). Si invertiste los nombres, revisa: ¿alguna de las dos trae un número asociado a cada valor (x1, x2)?

---

### PASO 3 — Crear las tablas en 1FN (15 min)

```sql
CREATE TABLE RESERVA (
    idReserva     VARCHAR(10)  NOT NULL,
    fechaCheckIn  DATE         NOT NULL,
    idHuesped     VARCHAR(10)  NOT NULL,
    idHabitacion  VARCHAR(10)  NOT NULL,
    montoTotal    DECIMAL(8,2) NOT NULL,
    CONSTRAINT PK_RESERVA PRIMARY KEY (idReserva)
);

CREATE TABLE DETALLE_RESERVA (
    idReserva      VARCHAR(10)  NOT NULL,
    nombreServicio NVARCHAR(60) NOT NULL,
    cantidad       INT          NOT NULL,
    CONSTRAINT PK_DETALLE_RESERVA PRIMARY KEY (idReserva, nombreServicio),
    CONSTRAINT FK_DETALLE_RESERVA FOREIGN KEY (idReserva) REFERENCES RESERVA (idReserva),
    CONSTRAINT CK_DETALLE_RESERVA_CANT CHECK (cantidad > 0)
);

CREATE TABLE HUESPED (
    idHuesped     VARCHAR(10)  NOT NULL,
    nombreHuesped NVARCHAR(60) NOT NULL,
    CONSTRAINT PK_HUESPED PRIMARY KEY (idHuesped)
);

CREATE TABLE HUESPED_TELEFONO (
    idHuesped VARCHAR(10) NOT NULL,
    telefono  VARCHAR(15) NOT NULL,
    CONSTRAINT PK_HUESPED_TELEFONO PRIMARY KEY (idHuesped, telefono),
    CONSTRAINT FK_HUESPED_TELEFONO FOREIGN KEY (idHuesped) REFERENCES HUESPED (idHuesped)
);

CREATE TABLE HABITACION (
    idHabitacion   VARCHAR(10)  NOT NULL,
    tipoHabitacion NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_HABITACION PRIMARY KEY (idHabitacion)
);

-- Inserta los datos migrados desde RESERVA_PLANO (sepáralos tú mismo, fila por valor):
INSERT INTO HUESPED VALUES ('HUE07', N'Patricia Alva'), ('HUE08', N'Renzo Díaz');

INSERT INTO HUESPED_TELEFONO VALUES
 ('HUE07', '987445566'), ('HUE07', '012233445'), ('HUE08', '998334455');

INSERT INTO HABITACION VALUES ('HAB12', N'Doble Vista al Mar'), ('HAB05', N'Simple'), ('HAB09', N'Suite');

INSERT INTO RESERVA VALUES
 ('RES01', '2026-09-28', 'HUE07', 'HAB12', 540.00),
 ('RES02', '2026-09-28', 'HUE08', 'HAB05', 160.00),
 ('RES03', '2026-09-29', 'HUE07', 'HAB09', 890.00);

INSERT INTO DETALLE_RESERVA VALUES
 ('RES01', N'Desayuno buffet', 2), ('RES01', N'Spa', 1),
 ('RES02', N'Minibar', 1),
 ('RES03', N'Desayuno buffet', 2), ('RES03', N'Minibar', 1), ('RES03', N'Lavandería', 1);
```

**✅ CHECKPOINT 3:** Ejecuta `SELECT * FROM DETALLE_RESERVA;` — deben aparecer **6 filas**, ninguna con "x1" o "x2" pegado al nombre del servicio, y ninguna celda con comas.

---

## PREGUNTA DE ANÁLISIS FINAL (responder en el mismo script o en papel)

> *"Patricia Alva (HUE07) aparece en dos reservas distintas (RES01 y RES03). Si mañana cambia uno de sus dos teléfonos, ¿en cuántos lugares de tu nuevo diseño tienes que actualizar ese dato? Compara tu respuesta con lo que hubiera pasado si hubieras dejado 'telefonosHuesped' tal como estaba en el reporte original, repetido en cada fila de RESERVA_PLANO."*

_____________________________________________________________________________

---

## ROL DEL DOCENTE DURANTE EL LABORATORIO

**QUÉ OBSERVAR al circular:**
- Estudiantes que nombran correctamente "grupo repetitivo" vs. "atributo multivalorado" en el Paso 2, sin que se les recuerde la definición, **vs.** estudiantes que escriben "está mal" sin usar el vocabulario técnico.
- Estudiantes que usan clave compuesta (idReserva, nombreServicio) en DETALLE_RESERVA por iniciativa propia **vs.** quienes agregan un autoincremental simple sin pensar en la regla de unicidad.
- Error específico frecuente en este tema: copiar literalmente "987445566 / 012233445" como un solo valor en `INSERT INTO HUESPED_TELEFONO`, en vez de separarlo en dos filas — es la señal más clara de que el estudiante entendió la teoría pero no la aplicó al dato real.

**3 PREGUNTAS DE ANDAMIAJE** (para estudiantes bloqueados, sin dar la respuesta):
1. *"¿Cuántos valores distintos hay realmente escondidos en esa celda? Cuéntalos tú mismo antes de escribir el INSERT."*
2. *"Si RES01 tuviera, en vez de 2 servicios, 5 servicios distintos, ¿cuántas filas necesitarías en DETALLE_RESERVA? Esa misma lógica aplica aquí con 2."*
3. *"¿Qué fue lo que usaste la semana pasada, en la EC, para que un mismo socio no pudiera inscribirse dos veces en la misma clase? Aplica exactamente esa misma idea aquí."*

**CIERRE DEL LAB (5 min):**
- Pedir a 2 voluntarios que proyecten su Paso 2 (análisis) y su Checkpoint 3.
- Preguntar al grupo: *"¿Alguien definió serviciosConsumidos como atributo multivalorado en vez de grupo repetitivo? ¿Por qué la diferencia importa para decidir la estructura de la tabla?"*
- Mostrar la solución de referencia (ver `S05_SOLUCION_LAB_DOCENTE_BD.md`) y señalar el error más común visto en la sesión (habitualmente: PK simple en DETALLE_RESERVA, o no separar los teléfonos en filas distintas).

---

## ENTREGABLE EN CLASE

El estudiante muestra al docente, al finalizar: su script con las 5 tablas creadas, el resultado del Checkpoint 3 (6 filas en DETALLE_RESERVA) y el comentario del Paso 2 completo con las 3 dependencias funcionales.

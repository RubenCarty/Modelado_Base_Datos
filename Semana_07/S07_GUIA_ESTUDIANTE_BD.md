# GUÍA DE TRABAJO DEL ESTUDIANTE — SEMANA 07
## Modelado y Diseño de Base de Datos

| Campo | Detalle |
|---|---|
| **Curso** | Modelado y Diseño de Base de Datos |
| **Semana** | 07 — Unidad I: Modelado de Datos |
| **Tema** | Transformación del Modelo ER a Relacional: Entidades, Relaciones, Especializaciones, Claves Primarias y Foráneas |
| **Nombre del estudiante** | _________________________________________________ |
| **Código** | _________________ | **Sección** | ________ |
| **Fecha de entrega** | _________________ |

---

### INSTRUCCIONES
- Tiempo estimado: **1 hora 30 minutos**
- Trabaja de forma **individual**
- Responde con tus propias palabras — no copies definiciones textuales
- Entrega en **Soy Autónoma → Semana 7 → Guía de Trabajo** antes de la siguiente sesión
- **⚠ Este documento NO contiene respuestas**

---

## SECCIÓN A — PREGUNTAS DE OPCIÓN MÚLTIPLE (20 puntos)
*Marca con una X la alternativa correcta. Solo una respuesta por pregunta.*

---

**Pregunta 1 [BÁSICO]** (2 pts)
Al transformar una entidad fuerte del modelo ER al modelo relacional:

a) Se crea una tabla cuyo identificador de la entidad se convierte en su clave primaria
b) Se crea una tabla sin ninguna clave primaria
c) Se crea solo si la entidad tiene más de 5 atributos
d) Se fusiona automáticamente con otra entidad relacionada

---

**Pregunta 2 [BÁSICO]** (2 pts)
Un atributo multivalorado, al transformarse al modelo relacional:

a) Se convierte en varias columnas (valor1, valor2, valor3) en la misma tabla
b) Se convierte en una tabla aparte, con clave primaria compuesta (clave de la entidad + el valor)
c) Se elimina, porque el modelo relacional no admite ese tipo de atributo
d) Se concatena en una sola columna de texto separada por comas

---

**Pregunta 3 [BÁSICO]** (2 pts)
En una relación 1:N, la clave foránea se coloca:

a) Siempre en el lado "1"
b) Siempre en el lado "N"
c) En cualquiera de los dos lados, a elección del diseñador
d) En una tabla intermedia nueva

---

**Pregunta 4 [BÁSICO]** (2 pts)
Una relación N:M (muchos a muchos) se transforma en:

a) Una columna extra en cada una de las dos tablas originales
b) Una tabla intermedia con una clave foránea hacia cada una de las dos entidades
c) Una sola tabla que fusiona ambas entidades
d) No requiere ninguna transformación adicional

---

**Pregunta 5 [INTERMEDIO]** (2 pts)
Una entidad débil, al transformarse al modelo relacional, forma su clave primaria con:

a) Solo su clave parcial
b) Solo la clave primaria de la entidad de la que depende
c) La clave primaria de la entidad de la que depende (como FK) MÁS su propia clave parcial
d) Un identificador autoincremental, sin relación con ninguna otra tabla

---

**Pregunta 6 [INTERMEDIO]** (2 pts)
En una especialización (superclase con subclases) resuelta con "una tabla por subtipo", la clave primaria de cada tabla de subclase:

a) Es un identificador autoincremental nuevo, independiente de la superclase
b) Es la misma clave primaria de la superclase, que funciona también como clave foránea hacia ella
c) Se omite, porque las subclases no necesitan clave primaria
d) Combina la clave de la superclase con un número aleatorio

---

**Pregunta 7 [INTERMEDIO]** (2 pts)
Dada la tabla `MANTENIMIENTO (placa, numeroMantenimiento, fecha, descripcion)` con clave primaria compuesta (placa, numeroMantenimiento), ¿por qué `numeroMantenimiento` NO puede ser la única clave primaria?

a) Porque es un número y los números no pueden ser clave primaria
b) Porque se repite entre vehículos distintos (cada vehículo numera sus propios mantenimientos desde 1)
c) Porque `fecha` debería ser la clave primaria en su lugar
d) Porque `descripcion` siempre debe ir en la clave primaria

---

**Pregunta 8 [AVANZADO]** (2 pts)
Una especialización es **disjunta** cuando:

a) Toda instancia de la superclase debe pertenecer a alguna subclase
b) Una misma instancia puede pertenecer a más de una subclase a la vez
c) Cada instancia pertenece, como máximo, a UNA subclase — nunca a dos simultáneamente
d) Las subclases no tienen atributos propios

---

**Pregunta 9 [AVANZADO]** (2 pts)
Un diseñador resuelve una relación 1:1 PARCIAL (el lado B no siempre tiene su contraparte en A) colocando la clave foránea en la tabla A (el lado que SIEMPRE existe). ¿Qué consecuencia práctica tiene esa decisión?

a) Ninguna, da exactamente igual en qué lado se coloque
b) La tabla A acumulará valores NULL en la columna de la FK para los registros que no tienen contraparte en B
c) La tabla B dejará de necesitar clave primaria
d) La relación 1:1 se convierte automáticamente en 1:N

---

**Pregunta 10 [AVANZADO]** (2 pts)
En la tabla intermedia `RESERVA (codigoCliente, idServicio, fecha, hora, dniTerapeuta)` con clave primaria (codigoCliente, idServicio, fecha), ¿por qué `dniTerapeuta` NO forma parte de la clave primaria?

a) Porque los DNI nunca pueden ser parte de una clave primaria
b) Porque no es necesario para distinguir una reserva de otra — es un dato adicional de la reserva, no parte de lo que la identifica
c) Porque ya está en la tabla TERAPEUTA
d) Porque las claves primarias no pueden tener más de 3 columnas

---

## SECCIÓN B — COMPLETAR Y RELACIONAR (20 puntos)

### Parte B1 — Completar (10 pts)
*Completa cada oración con el término técnico correcto.*

1. En una relación 1:N, la clave foránea se coloca en el lado ______________________ de la relación.

2. Una relación N:M se resuelve creando una tabla ______________________ con una clave foránea hacia cada una de las entidades participantes.

3. Una entidad ______________________ no tiene un identificador propio suficiente y depende de otra entidad para poder identificarse.

4. En una especialización resuelta con tabla por subtipo, la clave primaria de cada subclase es también una clave ______________________ hacia la superclase.

5. Una especialización ______________________ permite que una misma instancia pertenezca a más de una subclase al mismo tiempo.

### Parte B2 — Relacionar columnas (10 pts)
*Relaciona cada término de la Columna A con su definición o ejemplo correspondiente en la Columna B. Cada término tiene una sola pareja correcta.*

| Columna A | |
|---|---|
| 1. Entidad fuerte | |
| 2. Entidad débil | |
| 3. Relación 1:N | |
| 4. Relación N:M | |
| 5. Especialización disjunta | |
| 6. Especialización total | |

| Columna B (en desorden) | |
|---|---|
| a. Toda instancia de la superclase debe pertenecer a alguna subclase, sin excepción | |
| b. Se resuelve con una tabla intermedia que lleva la clave foránea de ambas entidades participantes | |
| c. Tiene un identificador propio y se convierte directamente en una tabla con PK | |
| d. La clave foránea se coloca en el lado "muchos" de la relación | |
| e. Cada instancia pertenece, como máximo, a una sola subclase | |
| f. Su clave primaria se forma con la clave de la entidad de la que depende más su propia clave parcial | |

**Tu respuesta (escribe la letra correspondiente a cada número):**

1. ___  2. ___  3. ___  4. ___  5. ___  6. ___

---

## SECCIÓN C — ANÁLISIS Y REFLEXIÓN (30 puntos)

**Pregunta C1** (10 pts)
Un compañero afirma: *"Para resolver la relación N:M entre ALUMNO y CURSO, agregué una columna `idCurso` en la tabla ALUMNO."* Explica, en 3 a 5 líneas, por qué este diseño falla en cuanto un alumno se matricule en un segundo curso.

_____________________________________________________________________________

_____________________________________________________________________________

_____________________________________________________________________________

---

**Pregunta C2** (10 pts)
Compara una entidad débil con una tabla intermedia de una relación N:M. ¿En qué se parecen (ambas usan clave primaria compuesta) y en qué se diferencian (qué representa cada una conceptualmente)? Justifica con tus propias palabras.

_____________________________________________________________________________

_____________________________________________________________________________

_____________________________________________________________________________

---

**Pregunta C3** (10 pts)
Explica por qué, en una especialización, la clave primaria de cada subclase debe ser la MISMA clave primaria de la superclase (y no un identificador nuevo). ¿Qué problema concreto evita esta regla?

_____________________________________________________________________________

_____________________________________________________________________________

_____________________________________________________________________________

---

### Mini caso de análisis

**Contexto:** La empresa peruana "Konecta Delivery" tiene este modelo ER para su operación:

```
REPARTIDOR (dni, nombres, {telefono})
PEDIDO (idPedido, fecha, direccionEntrega)
INCIDENCIA (numeroIncidencia, fecha, descripcion)   -- depende de PEDIDO; se numera por pedido

Relaciones:
- REPARTIDOR (1) ──entrega──> (N) PEDIDO
- PEDIDO (1) ──genera──> (N) INCIDENCIA
```

**Preguntas derivadas:**

**P1.** Transforma `{telefono}` de REPARTIDOR e INCIDENCIA a sus tablas correspondientes, indicando PK y FK. (5 pts)

_____________________________________________________________________________

**P2.** ¿En qué tabla va la clave foránea que resuelve la relación REPARTIDOR–PEDIDO? Escribe el `CREATE TABLE` de PEDIDO con esa FK incluida. (5 pts)

_____________________________________________________________________________

_____________________________________________________________________________

---

## SECCIÓN D — CASO AVANZADO (30 puntos)

**Caso profesional: "Red de Talleres Automotrices RuedaFirme"**

RuedaFirme administra varios talleres. El área de sistemas te entrega este modelo ER para transformar:

```
TALLER (idTaller, nombreTaller, distrito)
MECANICO (dni, nombres, {certificacion})
VEHICULO (placa, marca, modelo)
ORDEN_SERVICIO (numeroOrden, fecha, descripcion)   -- depende de VEHICULO; se numera por vehículo
EQUIPO (idEquipo, nombreEquipo, marca)
    EQUIPO se especializa en ELEVADOR (capacidadToneladas, tipoHidraulico) y
    DIAGNOSTICO (marcaSoftware, version) — disjunta y total.

Relaciones:
- TALLER (1) ──emplea──> (N) MECANICO
- MECANICO (N) ──repara──> (N) VEHICULO, mediante REPARACION (fecha, horasTrabajadas)
- MECANICO (1) ──tiene──> (1) EVALUACION_DESEMPENO (puntaje, fechaEvaluacion)
    [1:1 PARCIAL: no todo mecánico tiene evaluación registrada todavía]
- TALLER (1) ──posee──> (N) EQUIPO
```

**Preguntas de análisis profundo:**

**D1.** Transforma las 5 entidades fuertes y el atributo multivalorado de MECANICO. Indica PK de cada una. (8 pts)

_____________________________________________________________________________

**D2.** ORDEN_SERVICIO: ¿es entidad fuerte o débil? Justifica y escribe su `CREATE TABLE` completo con PK y FK. (6 pts)

_____________________________________________________________________________

**D3.** La relación MECANICO–VEHICULO (vía REPARACION) es N:M. Escribe el `CREATE TABLE` de REPARACION, decidiendo si necesita algún atributo adicional en la clave además de las dos FK, y justifica tu decisión. (6 pts)

_____________________________________________________________________________

_____________________________________________________________________________

---

**Pregunta de diseño** (6 pts)
Diseña el conjunto completo de tablas para EQUIPO, ELEVADOR y DIAGNOSTICO (la especialización), y para EVALUACION_DESEMPENO (la relación 1:1 parcial). Indica PK, FK y el discriminador que corresponda.

_____________________________________________________________________________

_____________________________________________________________________________

_____________________________________________________________________________

---

**Pregunta crítica** (4 pts)
Si un desarrollador, por ahorrar tiempo, decide NO crear una tabla separada para la especialización y en su lugar agrega a EQUIPO todas las columnas de ELEVADOR y de DIAGNOSTICO juntas (con varias quedando en NULL según el tipo), ¿qué problema concreto tendría ese diseño el día que RuedaFirme agregue un tercer tipo de equipo?

_____________________________________________________________________________

_____________________________________________________________________________

# GUÍA DE TRABAJO DEL ESTUDIANTE — SEMANA 05
## Modelado y Diseño de Base de Datos

| Campo | Detalle |
|---|---|
| **Curso** | Modelado y Diseño de Base de Datos |
| **Semana** | 05 — Unidad I: Modelado de Datos |
| **Tema** | Primera Forma Normal (1FN), Dependencias Funcionales, Eliminación de Grupos Repetitivos y Atributos Multivalorados |
| **Nombre del estudiante** | _________________________________________________ |
| **Código** | _________________ | **Sección** | ________ |
| **Fecha de entrega** | _________________ |

---

### INSTRUCCIONES
- Tiempo estimado: **1 hora 30 minutos**
- Trabaja de forma **individual**
- Responde con tus propias palabras — no copies definiciones textuales
- Entrega en **Soy Autónoma → Semana 5 → Guía de Trabajo** antes de la siguiente sesión
- **⚠ Este documento NO contiene respuestas**

---

## SECCIÓN A — PREGUNTAS DE OPCIÓN MÚLTIPLE (20 puntos)
*Marca con una X la alternativa correcta. Solo una respuesta por pregunta.*

---

**Pregunta 1 [BÁSICO]** (2 pts)
Una tabla cumple la Primera Forma Normal (1FN) cuando:

a) Todas sus columnas tienen nombres en mayúsculas
b) Cada celda contiene un único valor atómico y no existen grupos repetitivos
c) Tiene al menos una clave foránea
d) Todas sus columnas son de tipo texto

---

**Pregunta 2 [BÁSICO]** (2 pts)
Un **grupo repetitivo** es:

a) Un conjunto de columnas (o una celda) que almacena un número variable de valores similares para una misma fila
b) Una columna que nunca cambia de valor
c) Una tabla que se repite dos veces en el mismo esquema
d) Una clave primaria compuesta por más de dos columnas

---

**Pregunta 3 [BÁSICO]** (2 pts)
Se dice que X determina funcionalmente a Y (X → Y) cuando:

a) X e Y siempre tienen el mismo tipo de dato
b) Para cada valor de X existe un único valor posible de Y asociado
c) X es siempre una clave foránea e Y una clave primaria
d) Y aparece físicamente antes que X en la tabla

---

**Pregunta 4 [BÁSICO]** (2 pts)
¿Cuál de las siguientes columnas, tal como está descrita, viola la atomicidad exigida por 1FN?

a) `fechaNacimiento` con el valor `1998-04-12`
b) `telefonos` con el valor `987111222 / 014558899`
c) `precio` con el valor `25.90`
d) `estado` con el valor `Activo`

---

**Pregunta 5 [INTERMEDIO]** (2 pts)
Una tabla `PEDIDO` tiene las columnas `idPedido, idCliente, nombreCliente, producto1, cantidad1, producto2, cantidad2, producto3, cantidad3`. Este diseño:

a) Cumple 1FN porque cada columna tiene un único valor por fila
b) No cumple 1FN porque sigue siendo un grupo repetitivo, solo que desplegado en columnas fijas en vez de comprimido en una celda
c) Cumple 1FN porque no hay comas dentro de las celdas
d) No cumple 1FN porque le falta una clave foránea

---

**Pregunta 6 [INTERMEDIO]** (2 pts)
¿Cuál es la diferencia principal entre un **atributo compuesto** (como `direccion` = calle + distrito) y un **grupo repetitivo** (como los productos de un pedido)?

a) No hay ninguna diferencia; ambos se resuelven de la misma manera
b) El atributo compuesto tiene un número fijo de partes; el grupo repetitivo tiene un número variable de repeticiones
c) El atributo compuesto siempre es numérico; el grupo repetitivo siempre es texto
d) El grupo repetitivo nunca necesita una tabla nueva, el atributo compuesto sí

---

**Pregunta 7 [INTERMEDIO]** (2 pts)
En una tabla `VENTA (idVenta, idProducto, nombreProducto, cantidad)` donde la clave primaria es la combinación (idVenta, idProducto), ¿por qué no es suficiente usar solo `idVenta` como clave primaria?

a) Porque idVenta no es un número entero
b) Porque un mismo idVenta puede repetirse en varias filas (una por cada producto de esa venta), así que idVenta solo no identifica una fila única
c) Porque las claves primarias nunca pueden estar en tablas de detalle
d) Porque idProducto siempre debe ir antes que idVenta en la tabla

---

**Pregunta 8 [AVANZADO]** (2 pts)
Se observa que, en una tabla de 500 filas, `nombreCliente → idCliente` parece cumplirse siempre. Un estudiante concluye que es una dependencia funcional válida. ¿Cuál es el error en ese razonamiento?

a) No hay ningún error; si se cumple en los datos, es una DF válida
b) Que se cumpla en una muestra de datos no garantiza que sea una regla del negocio; podría existir un contraejemplo futuro (dos clientes con el mismo nombre) que la refute
c) El error es que nombreCliente debería ir siempre a la izquierda de la flecha
d) El error es que las DF solo se pueden definir sobre columnas numéricas

---

**Pregunta 9 [AVANZADO]** (2 pts)
Dada la tabla `MATRICULA (idMatricula, idEstudiante, nombreEstudiante, idCurso, nombreCurso, nota)`, donde cada fila representa la nota de un estudiante en un curso, ¿cuál de las siguientes dependencias funcionales es **incorrecta**?

a) `idEstudiante → nombreEstudiante`
b) `idCurso → nombreCurso`
c) `idMatricula → idEstudiante, idCurso, nota`
d) `idEstudiante → idCurso`

---

**Pregunta 10 [AVANZADO]** (2 pts)
Un analista propone resolver un atributo multivalorado `alergias` de un paciente creando una tabla `PACIENTE_ALERGIA (idPaciente, alergia)` con clave primaria compuesta (idPaciente, alergia). ¿Por qué esta clave compuesta es más correcta que agregar una columna autoincremental `idAlergiaRegistro` como única clave primaria?

a) Porque las claves autoincrementales están prohibidas en SQL Server
b) Porque la clave compuesta garantiza, por diseño, que la misma alergia no se registre dos veces para el mismo paciente — una regla de integridad que un autoincremental simple no impone
c) Porque las claves compuestas ocupan menos espacio en disco
d) Porque alergia siempre debe ser la única columna de la tabla

---

## SECCIÓN B — COMPLETAR Y RELACIONAR (20 puntos)

### Parte B1 — Completar (10 pts)
*Completa cada oración con el término técnico correcto.*

1. Un atributo que almacena más de un valor para una misma fila, como una lista de teléfonos en una sola celda, se llama atributo _____________________.

2. Cuando conociendo el valor de X puedo determinar con certeza el valor de Y, decimos que existe una ______________________ entre X e Y, y se escribe X → Y.

3. Una condición de 1FN es que cada celda de la tabla contenga valores ______________________, es decir, indivisibles.

4. Una tabla que resulta de eliminar un grupo repetitivo normalmente necesita una clave primaria ______________________, formada por la clave de la tabla original más el valor que se repetía.

5. Para que una dependencia funcional propuesta se considere válida, debe estar garantizada por una regla del ______________________, y no solo coincidir en la muestra de datos disponible.

### Parte B2 — Relacionar columnas (10 pts)
*Relaciona cada término de la Columna A con su definición o ejemplo correspondiente en la Columna B. Cada término tiene una sola pareja correcta.*

| Columna A | |
|---|---|
| 1. Grupo repetitivo | |
| 2. Atributo multivalorado | |
| 3. Dependencia funcional | |
| 4. Clave primaria compuesta | |
| 5. Contraejemplo | |
| 6. Atributo atómico | |

| Columna B (en desorden) | |
|---|---|
| a. Dato que no puede subdividirse en partes más pequeñas sin perder su significado | |
| b. Fila (real o hipotética) que demuestra que una dependencia funcional propuesta es falsa | |
| c. Conjunto de columnas que se repite un número variable de veces dentro de una misma fila, como "producto1, cantidad1, producto2, cantidad2..." | |
| d. Relación donde, para cada valor de un atributo X, existe un único valor asociado de otro atributo Y | |
| e. Clave primaria formada por dos o más columnas, típica de las tablas de detalle o de atributos multivalorados | |
| f. Atributo que admite varios valores simultáneos para una misma instancia, como los teléfonos de un cliente | |

**Tu respuesta (escribe la letra correspondiente a cada número):**

1. ___  2. ___  3. ___  4. ___  5. ___  6. ___

---

## SECCIÓN C — ANÁLISIS Y REFLEXIÓN (30 puntos)

**Pregunta C1** (10 pts)
Un compañero te dice: *"Yo resolví el problema del atributo multivalorado 'teléfonos' agregando las columnas telefono1, telefono2 y telefono3 a la tabla CLIENTE."* Explica, en 3 a 5 líneas, por qué este diseño NO cumple 1FN y qué problema concreto traerá cuando la base de datos tenga miles de clientes.

_____________________________________________________________________________

_____________________________________________________________________________

_____________________________________________________________________________

---

**Pregunta C2** (10 pts)
Compara un **atributo compuesto** (ej. dirección = calle + distrito) con un **grupo repetitivo** (ej. productos de un pedido). ¿Por qué el primero se resuelve con columnas separadas y el segundo necesita obligatoriamente una tabla nueva? Justifica con tus propias palabras.

_____________________________________________________________________________

_____________________________________________________________________________

_____________________________________________________________________________

---

**Pregunta C3** (10 pts)
Explica por qué una dependencia funcional que "se cumple en los datos actuales" no siempre es una dependencia funcional válida desde el punto de vista del diseño de base de datos. Da un ejemplo propio (distinto a los vistos en clase) de una posible coincidencia engañosa.

_____________________________________________________________________________

_____________________________________________________________________________

_____________________________________________________________________________

---

### Mini caso de análisis

**Contexto:** La empresa peruana "Konecta Envíos" exportó el siguiente reporte plano de sus envíos de la semana, antes de migrarlo a una base de datos relacional:

| idEnvio | idCliente | nombreCliente | telefonosCliente | idRepartidor | nombreRepartidor | paquetesIncluidos |
|---|---|---|---|---|---|---|
| ENV01 | CLI10 | Mario Rojas | 955111222 / 014009988 | REP02 | Luis Campos | Caja chica x1, Sobre documentos x2 |
| ENV02 | CLI11 | Elena Paz | 988222333 | REP01 | Carla Núñez | Caja grande x1 |

**Preguntas derivadas:**

**P1.** Identifica las dos columnas del reporte que violan 1FN y clasifica cada una (grupo repetitivo o atributo multivalorado). (5 pts)

_____________________________________________________________________________

**P2.** Propón las tablas resultantes de aplicar 1FN a este reporte, indicando el nombre de cada tabla, sus atributos principales y su clave primaria (marca las compuestas). (5 pts — puedes usar notación como `TABLA (atributo1 PK, atributo2, ...)`)

_____________________________________________________________________________

_____________________________________________________________________________

---

## SECCIÓN D — CASO AVANZADO (30 puntos)

**Caso profesional: "Universidad Continental Andina — Reporte de inscripciones a talleres"**

La oficina de bienestar universitario exportó el siguiente reporte, directo del sistema de inscripciones a talleres extracurriculares, para que el equipo de TI lo evalúe antes de construir la base de datos definitiva:

| idInscripcion | fechaInscripcion | idAlumno | nombreAlumno | correosAlumno | idTaller | nombreTaller | docenteATaller | horariosTaller | cupoOcupado |
|---|---|---|---|---|---|---|---|---|---|
| INS01 | 2026-09-20 | ALU30 | Fiorella Ponce | fiorella.p@uni.edu / fponce@gmail.com | TAL05 | Danza Moderna | Rocío Ibáñez | Lun 18:00 / Mié 18:00 | 1 |
| INS02 | 2026-09-20 | ALU31 | Jorge Salas | jsalas@uni.edu | TAL02 | Ajedrez | Teodoro Vidal | Mar 16:00 | 1 |
| INS03 | 2026-09-21 | ALU30 | Fiorella Ponce | fiorella.p@uni.edu / fponce@gmail.com | TAL02 | Ajedrez | Teodoro Vidal | Mar 16:00 | 1 |

**Preguntas de análisis profundo:**

**D1.** Identifica TODAS las columnas de este reporte que violan 1FN. Para cada una, indica si es un grupo repetitivo o un atributo multivalorado y explica tu razonamiento. (8 pts)

_____________________________________________________________________________

_____________________________________________________________________________

**D2.** Escribe al menos CUATRO dependencias funcionales válidas detectadas en este reporte, usando la notación X → Y. (6 pts)

_____________________________________________________________________________

**D3.** Un compañero afirma que `idAlumno → idTaller` es una dependencia funcional válida, porque en las tres filas del reporte "funciona". ¿Estás de acuerdo? Justifica usando los propios datos de la tabla. (6 pts)

_____________________________________________________________________________

_____________________________________________________________________________

---

**Pregunta de diseño** (6 pts)
¿Cómo diseñarías el conjunto completo de tablas en 1FN para este caso? Indica el nombre de cada tabla, sus atributos y su clave primaria (marcando las compuestas). Asegúrate de resolver TODAS las violaciones identificadas en D1.

_____________________________________________________________________________

_____________________________________________________________________________

_____________________________________________________________________________

---

**Pregunta crítica** (4 pts)
`horariosTaller` indica los días y horas en que se dicta un taller (por ejemplo, "Lun 18:00 / Mié 18:00" para Danza Moderna). ¿Qué riesgo concreto corre la universidad si esta información se queda como texto en una sola celda, en vez de modelarse en una tabla aparte, el día que necesite saber qué talleres chocan de horario entre sí?

_____________________________________________________________________________

_____________________________________________________________________________

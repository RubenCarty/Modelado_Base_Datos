# GUÍA DE TRABAJO DEL ESTUDIANTE — SEMANA 06
## Modelado y Diseño de Base de Datos

| Campo | Detalle |
|---|---|
| **Curso** | Modelado y Diseño de Base de Datos |
| **Semana** | 06 — Unidad I: Modelado de Datos |
| **Tema** | Segunda Forma Normal (2FN), Tercera Forma Normal (3FN), Descomposición sin Pérdida de Información |
| **Nombre del estudiante** | _________________________________________________ |
| **Código** | _________________ | **Sección** | ________ |
| **Fecha de entrega** | _________________ |

---

### INSTRUCCIONES
- Tiempo estimado: **1 hora 30 minutos**
- Trabaja de forma **individual**
- Responde con tus propias palabras — no copies definiciones textuales
- Entrega en **Soy Autónoma → Semana 6 → Guía de Trabajo** antes de la siguiente sesión
- **⚠ Este documento NO contiene respuestas**

---

## SECCIÓN A — PREGUNTAS DE OPCIÓN MÚLTIPLE (20 puntos)
*Marca con una X la alternativa correcta. Solo una respuesta por pregunta.*

---

**Pregunta 1 [BÁSICO]** (2 pts)
Una dependencia funcional X → Y se considera **parcial** cuando:

a) X es la clave primaria completa de la tabla
b) X es solo una parte de una clave compuesta, y Y no necesita el resto de la clave para quedar determinado
c) Y es un atributo que nunca cambia de valor
d) X e Y están en tablas distintas

---

**Pregunta 2 [BÁSICO]** (2 pts)
La Segunda Forma Normal (2FN) solo es relevante de revisar cuando:

a) La tabla tiene más de 10 columnas
b) La clave primaria es compuesta (de dos o más columnas)
c) La tabla tiene una clave foránea
d) La tabla no tiene ninguna restricción CHECK

---

**Pregunta 3 [BÁSICO]** (2 pts)
Una **dependencia transitiva** ocurre cuando:

a) Un atributo no-clave depende de otro atributo no-clave, el cual a su vez depende de la clave
b) Dos tablas están relacionadas por una clave foránea
c) Una tabla tiene más de una clave candidata
d) Un atributo cambia de valor con el tiempo

---

**Pregunta 4 [BÁSICO]** (2 pts)
¿Cuál es el objetivo de la Tercera Forma Normal (3FN)?

a) Que todas las columnas sean de tipo numérico
b) Que todo atributo no-clave dependa directamente de la clave, sin pasar por otro atributo no-clave intermedio
c) Que la tabla tenga como máximo 5 columnas
d) Que no existan claves foráneas

---

**Pregunta 5 [INTERMEDIO]** (2 pts)
En la tabla `DETALLE_PEDIDO (idPedido, idProducto, nombreProducto, cantidad)` con clave compuesta (idPedido, idProducto), ¿por qué `cantidad` NO viola 2FN mientras que `nombreProducto` sí?

a) Porque cantidad es numérico y nombreProducto es texto
b) Porque cantidad depende de la combinación completa (idPedido + idProducto), mientras que nombreProducto depende solo de idProducto
c) Porque cantidad siempre tiene el mismo valor
d) Porque nombreProducto debería estar en mayúsculas

---

**Pregunta 6 [INTERMEDIO]** (2 pts)
Una tabla `PEDIDO (idPedido, idRestaurante, nombreRestaurante)` tiene clave SIMPLE (idPedido). ¿Puede violar 3FN aunque no tenga clave compuesta?

a) No, 3FN solo aplica a claves compuestas, igual que 2FN
b) Sí — si nombreRestaurante depende de idRestaurante en vez de depender directamente de idPedido, hay dependencia transitiva, sin importar que la clave sea simple
c) No, porque idRestaurante es una clave foránea válida
d) Sí, pero solo si la tabla tiene más de 3 columnas

---

**Pregunta 7 [INTERMEDIO]** (2 pts)
¿Cuál es la diferencia principal entre una dependencia transitiva y el uso correcto de una clave foránea?

a) No hay diferencia, ambas se resuelven igual
b) La clave foránea apunta a la PK de otra tabla sin duplicar sus datos descriptivos; la dependencia transitiva aparece cuando, además de la FK, se deja también el dato descriptivo duplicado en la misma tabla
c) Las claves foráneas nunca pueden estar en la misma tabla que una dependencia transitiva
d) La dependencia transitiva solo ocurre entre tablas distintas

---

**Pregunta 8 [AVANZADO]** (2 pts)
Al descomponer una tabla en dos, ¿qué condición garantiza que la descomposición sea "sin pérdida de información"?

a) Que las dos tablas tengan el mismo número de columnas
b) Que la columna usada para volver a unirlas (vía JOIN) sea una clave (PK) en al menos una de las dos tablas resultantes
c) Que ambas tablas tengan clave primaria compuesta
d) Que no se usen claves foráneas

---

**Pregunta 9 [AVANZADO]** (2 pts)
Un estudiante descompone una tabla uniendo dos partes mediante la columna `nombreCliente` (texto, no garantizado como único). ¿Qué riesgo concreto corre esa descomposición?

a) Ninguno, mientras el texto esté bien escrito
b) Que aparezcan filas espurias en la reconstrucción si dos clientes distintos llegaran a compartir el mismo nombre
c) Que la tabla ocupe más espacio en disco
d) Que SQL Server rechace la creación de la tabla

---

**Pregunta 10 [AVANZADO]** (2 pts)
En `ATENCION_DETALLE (idAtencion, idServicio, idVeterinario, nombreVeterinario, nombreServicio, cantidad)` con clave compuesta (idAtencion, idServicio), ¿dónde debería quedar correctamente `idVeterinario` y `nombreVeterinario` tras la normalización completa?

a) En DETALLE_ATENCION, porque dependen de idServicio
b) En una tabla ATENCION (clave idAtencion) o VETERINARIO aparte, porque idVeterinario depende de idAtencion (no de idServicio ni de la combinación completa)
c) Deben quedarse en la tabla original sin cambios
d) En la tabla SERVICIO, junto con nombreServicio

---

## SECCIÓN B — COMPLETAR Y RELACIONAR (20 puntos)

### Parte B1 — Completar (10 pts)
*Completa cada oración con el término técnico correcto.*

1. Una dependencia funcional es ______________________ cuando el atributo determinante es solo una parte de una clave compuesta.

2. La ______________________ Forma Normal exige que todo atributo no-clave dependa de la clave completa, no de una parte de ella.

3. Una dependencia ______________________ ocurre cuando un atributo no-clave depende de otro atributo no-clave, en vez de depender directamente de la clave.

4. Para que una descomposición sea sin pérdida de información, la columna usada para reconstruir la tabla original mediante JOIN debe ser una ______________________ en al menos una de las tablas resultantes.

5. Si una tabla genera filas que no existían en los datos originales al volver a unirla con JOIN, se dice que la descomposición produjo filas ______________________.

### Parte B2 — Relacionar columnas (10 pts)
*Relaciona cada término de la Columna A con su definición o ejemplo correspondiente en la Columna B. Cada término tiene una sola pareja correcta.*

| Columna A | |
|---|---|
| 1. Dependencia parcial | |
| 2. Dependencia completa | |
| 3. Dependencia transitiva | |
| 4. Descomposición sin pérdida | |
| 5. Fila espuria | |
| 6. Segunda Forma Normal (2FN) | |

| Columna B (en desorden) | |
|---|---|
| a. Fila que aparece al reconstruir una tabla descompuesta, pero que no existía en los datos originales | |
| b. Un atributo no-clave depende de la clave completa, no de una parte de ella | |
| c. X → Z → Y, donde Y depende de la clave solo a través de otro atributo no-clave Z | |
| d. Regla que exige eliminar las dependencias parciales en tablas con clave compuesta | |
| e. Al reunir las tablas resultantes con JOIN, se recupera exactamente la tabla original, sin filas de más ni de menos | |
| f. Un atributo depende de solo una parte de una clave compuesta | |

**Tu respuesta (escribe la letra correspondiente a cada número):**

1. ___  2. ___  3. ___  4. ___  5. ___  6. ___

---

## SECCIÓN C — ANÁLISIS Y REFLEXIÓN (30 puntos)

**Pregunta C1** (10 pts)
Un compañero afirma: *"En mi tabla DETALLE_VENTA (idVenta, idProducto, nombreProducto, cantidad), con clave compuesta (idVenta, idProducto), decidí mover 'cantidad' a una tabla PRODUCTO aparte, porque me pareció más prolijo tener todo separado."* Explica, en 3 a 5 líneas, por qué esta decisión es un error, usando el concepto de dependencia completa.

_____________________________________________________________________________

_____________________________________________________________________________

_____________________________________________________________________________

---

**Pregunta C2** (10 pts)
Compara una dependencia parcial con una dependencia transitiva. ¿En qué se parecen (ambas generan redundancia que hay que resolver con una tabla nueva) y en qué se diferencian (qué condición específica detecta cada una)? Justifica con tus propias palabras.

_____________________________________________________________________________

_____________________________________________________________________________

_____________________________________________________________________________

---

**Pregunta C3** (10 pts)
Explica por qué una clave foránea bien usada (que apunta a la PK de otra tabla) NO es, por sí misma, una dependencia transitiva. ¿Qué tendría que pasar, además de tener esa clave foránea, para que SÍ se convierta en una violación de 3FN?

_____________________________________________________________________________

_____________________________________________________________________________

_____________________________________________________________________________

---

### Mini caso de análisis

**Contexto:** La empresa peruana "TransLima Carga" exportó este reporte de envíos, ya en 1FN:

**ENVIO_DETALLE (clave compuesta: idEnvio + idPaquete)**

| idEnvio | idPaquete | pesoKg | idConductor | nombreConductor | licenciaConductor |
|---|---|---|---|---|---|
| ENV01 | PAQ01 | 12.5 | COND02 | Hugo Ramos | Q-884211 |
| ENV01 | PAQ02 | 8.0 | COND02 | Hugo Ramos | Q-884211 |
| ENV02 | PAQ03 | 20.0 | COND01 | Ana Belén | Q-773100 |

**Preguntas derivadas:**

**P1.** La clave es (idEnvio, idPaquete). Para `idConductor`, `nombreConductor` y `licenciaConductor`, determina si cada uno tiene dependencia parcial, completa, o si en realidad el problema real está en otro lado (pista: ¿de qué depende realmente idConductor?). (5 pts)

_____________________________________________________________________________

**P2.** Propón el diseño final en 3FN para este caso, indicando el nombre de cada tabla, sus atributos y su clave (marca las compuestas). (5 pts)

_____________________________________________________________________________

_____________________________________________________________________________

---

## SECCIÓN D — CASO AVANZADO (30 puntos)

**Caso profesional: "Konecta Seguros — Reporte de pólizas y coberturas"**

El área de sistemas de una aseguradora peruana exportó este reporte, ya validado en 1FN, para que el equipo evalúe su diseño antes de implementarlo en producción:

**POLIZA_COBERTURA (clave compuesta: idPoliza + idCobertura)**

| idPoliza | idCliente | nombreCliente | idAsesor | nombreAsesor | sedeAsesor | idCobertura | nombreCobertura | montoAsegurado |
|---|---|---|---|---|---|---|---|---|
| POL01 | CLI40 | Marco Iparraguirre | ASE02 | Diana Rojas | San Isidro | COB01 | Robo | 15000.00 |
| POL01 | CLI40 | Marco Iparraguirre | ASE02 | Diana Rojas | San Isidro | COB03 | Incendio | 40000.00 |
| POL02 | CLI41 | Lucía Bravo | ASE01 | Renzo Cueto | Miraflores | COB01 | Robo | 18000.00 |

**Preguntas de análisis profundo:**

**D1.** La clave de este reporte es (idPoliza, idCobertura). Clasifica TODOS los atributos no-clave entre dependencia parcial y dependencia completa, justificando cada uno. (10 pts)

_____________________________________________________________________________

_____________________________________________________________________________

**D2.** Después de resolver las dependencias parciales, revisa la tabla que contiene los datos de la póliza (idCliente, idAsesor, etc.). ¿Existe alguna dependencia transitiva ahí? Si la hay, escribe la cadena completa X → Z → Y. (8 pts)

_____________________________________________________________________________

**D3.** Un compañero decide usar `nombreAsesor` (en vez de `idAsesor`) como la columna para relacionar la tabla de pólizas con la tabla de asesores. Explica por qué esto pone en riesgo la propiedad de "descomposición sin pérdida de información". (6 pts)

_____________________________________________________________________________

_____________________________________________________________________________

---

**Pregunta de diseño** (6 pts)
Diseña el conjunto completo de tablas en 3FN para este caso. Indica el nombre de cada tabla, sus atributos y su clave primaria (marcando las compuestas y las foráneas).

_____________________________________________________________________________

_____________________________________________________________________________

_____________________________________________________________________________

---

**Pregunta crítica** (adicional, sin puntaje — reflexión abierta)
`montoAsegurado` depende de la combinación (idPoliza, idCobertura) — es el monto asegurado de ESA cobertura específica en ESA póliza. ¿Qué error cometería un diseñador que, confundido por ver que "se repite poco", decidiera moverlo a la tabla COBERTURA? ¿Qué problema de negocio causaría ese error?

_____________________________________________________________________________

_____________________________________________________________________________

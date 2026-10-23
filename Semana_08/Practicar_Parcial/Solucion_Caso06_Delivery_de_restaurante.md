# SOLUCIÓN — Caso 6. Delivery de restaurante
## Laboratorio 6 de Base de Datos — Normalización 1FN · 2FN · 3FN · 4FN · 5FN

**Archivo de datos:** `06_Delivery_Restaurante_200.csv` (200 registros reales, ya cargados y verificados para esta solución)
**Base de datos a crear en SQL Server:** `Lab06_Caso06`

> **Antes de empezar:** si todavía no sabes cómo importar un CSV a SQL Server 2022, abre primero
> [`00_COMO_IMPORTAR_CSV_SQLSERVER22.md`](00_COMO_IMPORTAR_CSV_SQLSERVER22.md) — son los mismos 10 pasos para los 10 casos del laboratorio, aquí no se repiten.
>
> **Verificación de esta solución:** todas las consultas de este documento (claves, dependencias funcionales, cardinalidades, reconstrucción por JOIN) fueron ejecutadas y comprobadas contra el archivo CSV real con un motor de prueba — los números que aparecen (filas, conteos, violaciones) son los resultados reales del archivo, no estimaciones. La sintaxis T-SQL (`STRING_SPLIT`, `IDENTITY`, etc.) es válida en SQL Server 2022; se recomienda correr el script completo en tu propio SQL Server antes de la clase.

---

## Contexto y problemática (del enunciado de la guía)

**Contexto.** Una plataforma de delivery registra pedidos, clientes, platos, restaurantes, zonas, extras, métodos de pago y campañas.

**Problemática.** Se repiten datos de platos y restaurantes, y se combinan características independientes del pedido, aumentando innecesariamente las filas.

---

## PASO 0 — Crear la base de datos

```sql
DROP DATABASE IF EXISTS Lab06_Caso06;
CREATE DATABASE Lab06_Caso06;
USE Lab06_Caso06;
```

---

## PASO 1 — Explorar los 200 registros (hallazgos antes de tocar la estructura)

Abre la tabla ya importada (ver guía de importación) y mira las primeras filas:

```sql
SELECT TOP 10 * FROM PEDIDO_INICIAL;
```

**Tres hallazgos que debes anotar antes de modificar nada** (ya verificados en este archivo):

1. **Dato repetido de restaurante:** el restaurante `R001` (Restaurante 1) aparece repetido en varias filas, siempre con el mismo nombre — exactamente el patrón que genera riesgo de inconsistencia si alguien actualiza una sola fila y olvida las demás.
2. **Valor no atómico en `TelefonosCliente`:** la columna trae dos valores en una sola celda separados por `|` (ejemplo real: `93000001|93100001`) — viola la atomicidad exigida por 1FN.
3. **Clave simple insuficiente:** ni `IDPedido` ni `IDPlato` identifican una fila por sí solos — `IDPedido` se repite 20 veces (una por cada plato) y `IDPlato` se repite 10 veces (una por cada pedido); se necesita la combinación de ambos.

---

## PASO 2 — Determinar la clave candidata (COUNT + GROUP BY)

```sql
-- 2.1  ¿Es IDPedido suficiente por sí solo?
SELECT IDPedido, COUNT(*) AS Filas
FROM PEDIDO_INICIAL
GROUP BY IDPedido;
-- Resultado real: 10 valores distintos de IDPedido, cada uno con 20 filas -> NO es clave por sí solo.
```

```sql
-- 2.2  ¿Es IDPlato suficiente por sí solo?
SELECT IDPlato, COUNT(*) AS Filas
FROM PEDIDO_INICIAL
GROUP BY IDPlato;
-- Resultado real: 20 valores distintos de IDPlato, cada uno con 10 filas -> NO es clave por sí solo.
```

```sql
-- 2.3  ¿La combinación (IDPedido, IDPlato) identifica una fila única?
SELECT IDPedido, IDPlato, COUNT(*) AS Filas
FROM PEDIDO_INICIAL
GROUP BY IDPedido, IDPlato
HAVING COUNT(*) > 1;
-- Resultado real: 0 filas devueltas -> cada combinación aparece EXACTAMENTE una vez.
```

**Clave candidata: {IDPedido, IDPlato}** (clave compuesta).

---

## PASO 3 — Identificar las dependencias funcionales (con evidencia real del CSV)

```sql
-- DF 1:  IDCliente -> Cliente, Zona, TelefonosCliente
SELECT IDCliente, Cliente, Zona, TelefonosCliente
FROM PEDIDO_INICIAL
WHERE IDCliente = 'CL001';
```
**Evidencia (2 filas reales, mismo `IDCliente`, 20 veces en total — aquí solo 2):**
| IDCliente | Cliente | Zona | TelefonosCliente |
|---|---|---|---|
| CL001 | Cliente 1 | Zona 1 | 93000001\|93100001 |
| CL001 | Cliente 1 | Zona 1 | 93000001\|93100001 |

Siempre el mismo nombre, zona y teléfonos para `CL001` → **`IDCliente → Cliente, Zona, TelefonosCliente`** se confirma.

```sql
-- DF 2:  Zona -> RepartidorZona
SELECT DISTINCT Zona, RepartidorZona
FROM PEDIDO_INICIAL
WHERE Zona = 'Zona 1';
```
**Evidencia:** `Zona 1` siempre trae `RepartidorZona` = `Repartidor 1` → **`Zona → RepartidorZona`** se confirma.

```sql
-- DF 3:  IDPlato -> Plato, CategoriaPlato, PrecioUnitario, IDRestaurante
SELECT IDPlato, Plato, CategoriaPlato, PrecioUnitario, IDRestaurante
FROM PEDIDO_INICIAL
WHERE IDPlato = 'PL001'
ORDER BY IDPedido;
```
**Evidencia (2 filas reales, mismo `IDPlato`, en pedidos distintos — demuestra que NO depende de `IDPedido`):**
| IDPlato | Plato | CategoriaPlato | PrecioUnitario | IDRestaurante |
|---|---|---|---|---|
| PL001 | Plato 1 | Categoria 1 | 13.8 | R001 |
| PL001 | Plato 1 | Categoria 1 | 13.8 | R001 |

**`IDPlato → Plato, CategoriaPlato, PrecioUnitario, IDRestaurante`** se confirma: el precio y el restaurante del plato no cambian aunque cambie el pedido.

```sql
-- DF 4:  IDRestaurante -> Restaurante, DistritoRestaurante
SELECT DISTINCT IDRestaurante, Restaurante, DistritoRestaurante
FROM PEDIDO_INICIAL
WHERE IDRestaurante = 'R001';
```
**Evidencia:** `R001` siempre trae `Restaurante` = `Restaurante 1` y `DistritoRestaurante` = `Distrito 1` → **`IDRestaurante → Restaurante, DistritoRestaurante`** se confirma.

```sql
-- DF 5 (dependencia COMPLETA, no parcial):  (IDPedido, IDPlato) -> Cantidad, PrecioTotal
SELECT IDPedido, IDPlato, Cantidad, PrecioTotal
FROM PEDIDO_INICIAL
WHERE IDPlato = 'PL001'
ORDER BY IDPedido;
-- Observa: el mismo IDPlato trae distinta Cantidad/PrecioTotal según el pedido -> depende de LA CLAVE COMPLETA, no de una parte.
```

---

## PASO 4 — Primera Forma Normal (1FN)

**Violación encontrada:** `TelefonosCliente` no es atómica (trae `93000001|93100001`, 2 valores en una celda).

```sql
-- 4.1  Separar el valor multivaluado en su propia tabla
CREATE TABLE CLIENTE_TELEFONO (
    IDCliente VARCHAR(10)  NOT NULL,
    Valor            VARCHAR(30) NOT NULL,
    CONSTRAINT PK_CLIENTE_TELEFONO PRIMARY KEY (IDCliente, Valor)
);

INSERT INTO CLIENTE_TELEFONO (IDCliente, Valor)
SELECT DISTINCT IDCliente, LTRIM(RTRIM(valor.value))
FROM PEDIDO_INICIAL
CROSS APPLY STRING_SPLIT(TelefonosCliente, '|') AS valor;
```

```sql
-- 4.2  Verificar 1FN: debe haber 20 filas (= 10 clientes x 2 teléfonos cada uno)
SELECT COUNT(*) AS Filas FROM CLIENTE_TELEFONO;
```

```sql
-- 4.3  Crear la tabla en 1FN: mismas columnas MENOS la multivaluada, con PK compuesta
CREATE TABLE PEDIDO_1FN (
    IDPedido        VARCHAR(10)   NOT NULL,
    IDCliente        VARCHAR(10)   NOT NULL,
    Cliente       NVARCHAR(80)  NOT NULL,
    Zona        NVARCHAR(40)  NOT NULL,
    RepartidorZona     NVARCHAR(40)  NOT NULL,
    IDPlato        VARCHAR(10)   NOT NULL,
    Plato       NVARCHAR(80)  NOT NULL,
    CategoriaPlato       NVARCHAR(40)  NOT NULL,
    PrecioUnitario       DECIMAL(10,2) NOT NULL,
    Cantidad      INT           NOT NULL,
    PrecioTotal      DECIMAL(10,2) NOT NULL,
    IDRestaurante        VARCHAR(10)   NOT NULL,
    Restaurante       NVARCHAR(80)  NOT NULL,
    DistritoRestaurante       NVARCHAR(40)  NOT NULL,
    Extra       NVARCHAR(40)  NOT NULL,
    MetodoPago       NVARCHAR(40)  NOT NULL,
    Campania       NVARCHAR(40)  NOT NULL,
    CONSTRAINT PK_PEDIDO_1FN PRIMARY KEY (IDPedido, IDPlato)
);

INSERT INTO PEDIDO_1FN
SELECT IDPedido,IDCliente,Cliente,Zona,RepartidorZona,IDPlato,Plato,CategoriaPlato,PrecioUnitario,Cantidad,PrecioTotal,IDRestaurante,Restaurante,DistritoRestaurante,Extra,MetodoPago,Campania
FROM PEDIDO_INICIAL;

SELECT COUNT(*) AS Filas FROM PEDIDO_1FN;   -- debe devolver 200
```

✅ **Cumple 1FN:** cada celda tiene un único valor; la clave compuesta (IDPedido, IDPlato) identifica cada fila sin ambigüedad.

---

## PASO 5 — Segunda Forma Normal (2FN): eliminar dependencias parciales

Atributos que dependen SOLO de `IDPedido` (parte de la clave): `IDCliente, Cliente, Zona, RepartidorZona`.
Atributos que dependen SOLO de `IDPlato` (la otra parte): `Plato, CategoriaPlato, PrecioUnitario, IDRestaurante, Restaurante, DistritoRestaurante`.
Atributos que dependen de LA CLAVE COMPLETA: `Cantidad, PrecioTotal`.

```sql
-- 5.1  Lado del pedido (todo lo que depende solo de IDPedido)
CREATE TABLE PEDIDO_2FN (
    IDPedido    VARCHAR(10)  NOT NULL,
    IDCliente    VARCHAR(10)  NOT NULL,
    Cliente   NVARCHAR(80) NOT NULL,
    Zona    NVARCHAR(40) NOT NULL,
    RepartidorZona NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_PEDIDO_2FN PRIMARY KEY (IDPedido)
);
INSERT INTO PEDIDO_2FN
SELECT DISTINCT IDPedido,IDCliente,Cliente,Zona,RepartidorZona FROM PEDIDO_1FN;

-- 5.2  Lado del plato (todo lo que depende solo de IDPlato)
CREATE TABLE PLATO_2FN (
    IDPlato  VARCHAR(10)   NOT NULL,
    Plato NVARCHAR(80)  NOT NULL,
    CategoriaPlato NVARCHAR(40)  NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    IDRestaurante  VARCHAR(10)   NOT NULL,
    Restaurante NVARCHAR(80)  NOT NULL,
    DistritoRestaurante NVARCHAR(40)  NOT NULL,
    CONSTRAINT PK_PLATO_2FN PRIMARY KEY (IDPlato)
);
INSERT INTO PLATO_2FN
SELECT DISTINCT IDPlato,Plato,CategoriaPlato,PrecioUnitario,IDRestaurante,Restaurante,DistritoRestaurante FROM PEDIDO_1FN;

-- 5.3  Detalle: solo lo que depende de LA CLAVE COMPLETA (+ precio histórico de la transacción)
CREATE TABLE DETALLE_PEDIDO (
    IDPedido    VARCHAR(10)   NOT NULL,
    IDPlato    VARCHAR(10)   NOT NULL,
    PrecioUnitario   DECIMAL(10,2) NOT NULL,   -- precio histórico al momento de la transacción
    Cantidad  INT           NOT NULL,
    PrecioTotal  DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_DETALLE_PEDIDO PRIMARY KEY (IDPedido, IDPlato),
    CONSTRAINT FK_DETALLE_PEDIDO_PLATO FOREIGN KEY (IDPlato) REFERENCES PLATO_2FN(IDPlato)
);
INSERT INTO DETALLE_PEDIDO (IDPedido,IDPlato,PrecioUnitario,Cantidad,PrecioTotal)
SELECT IDPedido,IDPlato,PrecioUnitario,Cantidad,PrecioTotal FROM PEDIDO_1FN;
```

```sql
-- Verificación: PEDIDO_2FN debe tener 10 filas, PLATO_2FN debe tener 20 filas, DETALLE_PEDIDO debe tener 200 filas
SELECT COUNT(*) FROM PEDIDO_2FN;   -- 10
SELECT COUNT(*) FROM PLATO_2FN;   -- 20
SELECT COUNT(*) FROM DETALLE_PEDIDO;  -- 200
```

> **¿Por qué se conserva `PrecioUnitario` también en `DETALLE_PEDIDO`?** Para guardar el precio **histórico** de esa transacción puntual. El precio "actual" del catálogo vive en `PLATO_2FN`; si el precio de catálogo cambia mañana, las transacciones ya registradas no deben cambiar retroactivamente.

---

## PASO 6 — Tercera Forma Normal (3FN): eliminar dependencias transitivas

Dos cadenas transitivas detectadas:
- `IDPedido → IDCliente → Cliente, Zona` y `Zona → RepartidorZona` (cadena de 3: `IDPedido → Zona → RepartidorZona`)
- `IDPlato → IDRestaurante → Restaurante, DistritoRestaurante` (cadena: `IDPlato → IDRestaurante → Restaurante, DistritoRestaurante`)

```sql
-- 6.1  Separar ZONA (resuelve Zona -> RepartidorZona)
CREATE TABLE ZONA (
    Zona    NVARCHAR(40) NOT NULL,
    RepartidorZona NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_ZONA PRIMARY KEY (Zona)
);
INSERT INTO ZONA SELECT DISTINCT Zona,RepartidorZona FROM PEDIDO_2FN;

-- 6.2  CLIENTE definitivo (ya sin Zona repetido con el responsable adentro; Zona queda como FK)
CREATE TABLE CLIENTE (
    IDCliente  VARCHAR(10)  NOT NULL,
    Cliente NVARCHAR(80) NOT NULL,
    Zona  NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_CLIENTE PRIMARY KEY (IDCliente),
    CONSTRAINT FK_CLIENTE_ZONA FOREIGN KEY (Zona) REFERENCES ZONA(Zona)
);
INSERT INTO CLIENTE SELECT DISTINCT IDCliente,Cliente,Zona FROM PEDIDO_2FN;

-- 6.3  PEDIDO definitivo (solo el id del pedido + FK al cliente)
CREATE TABLE PEDIDO (
    IDPedido VARCHAR(10) NOT NULL,
    IDCliente VARCHAR(10) NOT NULL,
    CONSTRAINT PK_PEDIDO PRIMARY KEY (IDPedido),
    CONSTRAINT FK_PEDIDO_CLIENTE FOREIGN KEY (IDCliente) REFERENCES CLIENTE(IDCliente)
);
INSERT INTO PEDIDO SELECT IDPedido,IDCliente FROM PEDIDO_2FN;

-- 6.4  Separar RESTAURANTE (resuelve IDPlato -> IDRestaurante -> Restaurante,DistritoRestaurante)
CREATE TABLE RESTAURANTE (
    IDRestaurante  VARCHAR(10)  NOT NULL,
    Restaurante NVARCHAR(80) NOT NULL,
    DistritoRestaurante NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_RESTAURANTE PRIMARY KEY (IDRestaurante)
);
INSERT INTO RESTAURANTE SELECT DISTINCT IDRestaurante,Restaurante,DistritoRestaurante FROM PLATO_2FN;

-- 6.5  PLATO definitivo (ya sin los datos del restaurante adentro; IDRestaurante queda como FK)
CREATE TABLE PLATO (
    IDPlato  VARCHAR(10)   NOT NULL,
    Plato NVARCHAR(80)  NOT NULL,
    CategoriaPlato NVARCHAR(40)  NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    IDRestaurante  VARCHAR(10)   NOT NULL,
    CONSTRAINT PK_PLATO PRIMARY KEY (IDPlato),
    CONSTRAINT FK_PLATO_RESTAURANTE FOREIGN KEY (IDRestaurante) REFERENCES RESTAURANTE(IDRestaurante)
);
INSERT INTO PLATO SELECT IDPlato,Plato,CategoriaPlato,PrecioUnitario,IDRestaurante FROM PLATO_2FN;
```

```sql
-- Verificación: ZONA=4 filas | CLIENTE=10 filas | PEDIDO=10 filas | RESTAURANTE=5 filas | PLATO=20 filas
SELECT COUNT(*) FROM ZONA;  SELECT COUNT(*) FROM CLIENTE;  SELECT COUNT(*) FROM PEDIDO;
SELECT COUNT(*) FROM RESTAURANTE;  SELECT COUNT(*) FROM PLATO;
```

✅ **Cumple 3FN:** ningún atributo no-clave depende de otro atributo no-clave; todo depende directamente de la clave de su propia tabla.

---

## PASO 7 — Cuarta Forma Normal (4FN): hechos multivaluados independientes

**Hallazgo (grano = un `IDPedido`):** dentro de un mismo pedido (ejemplo real `PED001`, con sus 20 filas), `Extra` toma **2** valores distintos (Bebida, Salsa) y `MetodoPago` toma **2** valores distintos (Tarjeta, Yape) — y aparecen **todas** las combinaciones posibles entre ambos (evidencia de que son independientes entre sí para la misma operación, no uno depende del otro).

```sql
-- Evidencia: ¿aparecen TODAS las combinaciones de Extra x MetodoPago dentro de un mismo IDPedido?
SELECT DISTINCT Extra, MetodoPago
FROM PEDIDO_1FN
WHERE IDPedido = 'PED001'
ORDER BY Extra, MetodoPago;
-- Resultado real: 4 combinaciones (= 2 x 2) -> confirma independencia (MVD).
```

```sql
-- 7.1  Separar los dos hechos multivaluados independientes
CREATE TABLE PEDIDO_EXTRA (
    IDPedido  VARCHAR(10)  NOT NULL,
    Extra NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_PEDIDO_EXTRA PRIMARY KEY (IDPedido, Extra)
);
INSERT INTO PEDIDO_EXTRA SELECT DISTINCT IDPedido,Extra FROM PEDIDO_1FN;

CREATE TABLE PEDIDO_METODOPAGO (
    IDPedido  VARCHAR(10)  NOT NULL,
    MetodoPago NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_PEDIDO_METODOPAGO PRIMARY KEY (IDPedido, MetodoPago)
);
INSERT INTO PEDIDO_METODOPAGO SELECT DISTINCT IDPedido,MetodoPago FROM PEDIDO_1FN;
```

> ⚠ **Nota honesta sobre estos datos.** En esta muestra, `IDPlato` TAMBIÉN determina `Extra` y `MetodoPago` sin excepción (es un efecto de cómo se generó el archivo: los mismos 20 platos se repiten idénticos en cada pedido). Eso NO es una regla de negocio real — un plato no "tiene" un extra fijo en la vida real. Tratamos `Extra` y `MetodoPago` como hechos independientes del **pedido** (que es la lectura que pide el enunciado de la guía: "hechos multivaluados... para una misma operación"), no del plato. Coméntalo así en tu sustentación.

---

## PASO 8 — Quinta Forma Normal (5FN): relación ternaria y reconstrucción sin pérdida

Agregamos el tercer hecho, `Campania` (5 valores: Familiar, FinSemana, Lunch, Noche, Universitaria), y verificamos si la combinación de los **tres** (Extra, MetodoPago, Campania) para un mismo `IDPedido` se reconstruye exactamente uniendo tres tablas binarias — sin inventar combinaciones (filas espurias) ni perder ninguna.

```sql
-- 8.1  Tercera tabla
CREATE TABLE PEDIDO_CAMPANIA (
    IDPedido  VARCHAR(10)  NOT NULL,
    Campania NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_PEDIDO_CAMPANIA PRIMARY KEY (IDPedido, Campania)
);
INSERT INTO PEDIDO_CAMPANIA SELECT DISTINCT IDPedido,Campania FROM PEDIDO_1FN;
```

```sql
-- 8.2  Verificación de reconstrucción (debe devolver exactamente 20 filas para 'PED001', ni una más ni una menos)
SELECT c1.IDPedido, c1.Extra, c2.MetodoPago, c3.Campania
FROM PEDIDO_EXTRA c1
JOIN PEDIDO_METODOPAGO c2 ON c2.IDPedido = c1.IDPedido
JOIN PEDIDO_CAMPANIA c3 ON c3.IDPedido = c1.IDPedido
WHERE c1.IDPedido = 'PED001'
ORDER BY c1.Extra, c2.MetodoPago, c3.Campania;
```

```sql
-- 8.3  Comprobación automática contra la tabla original (0 = reconstrucción exacta)
SELECT COUNT(*) AS Diferencias FROM (
    SELECT Extra,MetodoPago,Campania FROM PEDIDO_1FN WHERE IDPedido='PED001'
    EXCEPT
    SELECT c1.Extra, c2.MetodoPago, c3.Campania
    FROM PEDIDO_EXTRA c1
    JOIN PEDIDO_METODOPAGO c2 ON c2.IDPedido=c1.IDPedido
    JOIN PEDIDO_CAMPANIA c3 ON c3.IDPedido=c1.IDPedido
    WHERE c1.IDPedido='PED001'
) AS Diff;
-- Verificado contra el CSV real: 0 diferencias -> descomposición SIN PÉRDIDA.
```

✅ **Cumple 5FN:** la relación ternaria se reconstruye exactamente mediante el JOIN de las tres tablas binarias — no hace falta guardar una tabla de 3 columnas.

---

## MODELO FINAL

| # | Tabla | Clave primaria (PK) | Claves foráneas (FK) |
|---|---|---|---|
| 1 | `ZONA` | Zona | — |
| 2 | `CLIENTE` | IDCliente | Zona → `ZONA` |
| 3 | `CLIENTE_TELEFONO` | (IDCliente, Valor) | IDCliente → `CLIENTE` |
| 4 | `PEDIDO` | IDPedido | IDCliente → `CLIENTE` |
| 5 | `RESTAURANTE` | IDRestaurante | — |
| 6 | `PLATO` | IDPlato | IDRestaurante → `RESTAURANTE` |
| 7 | `DETALLE_PEDIDO` | (IDPedido, IDPlato) | IDPedido → `PEDIDO` · IDPlato → `PLATO` |
| 8 | `PEDIDO_EXTRA` | (IDPedido, Extra) | IDPedido → `PEDIDO` |
| 9 | `PEDIDO_METODOPAGO` | (IDPedido, MetodoPago) | IDPedido → `PEDIDO` |
| 10 | `PEDIDO_CAMPANIA` | (IDPedido, Campania) | IDPedido → `PEDIDO` |

**Relaciones:** `ZONA` 1:N `CLIENTE` · `CLIENTE` 1:N `PEDIDO` (vía FK) · `CLIENTE` 1:N `CLIENTE_TEL` · `PEDIDO` 1:N `DETALLE_PEDIDO` · `PLATO` 1:N `DETALLE_PEDIDO` · `RESTAURANTE` 1:N `PLATO` · `PEDIDO` 1:N `PEDIDO_EXTRA`/`PEDIDO_METODOPAGO`/`PEDIDO_CAMPANIA`.

### JOIN final (reúne más de tres tablas normalizadas)

```sql
SELECT
    h.IDPedido, a.Cliente, g.Zona, g.RepartidorZona,
    i.Plato, s.Restaurante, s.DistritoRestaurante,
    d.Cantidad, d.PrecioUnitario, d.PrecioTotal
FROM DETALLE_PEDIDO d
JOIN PEDIDO h ON h.IDPedido = d.IDPedido
JOIN CLIENTE a ON a.IDCliente = h.IDCliente
JOIN ZONA g ON g.Zona = a.Zona
JOIN PLATO i ON i.IDPlato = d.IDPlato
JOIN RESTAURANTE s ON s.IDRestaurante = i.IDRestaurante
ORDER BY h.IDPedido, i.IDPlato;
-- Verificado contra el CSV real: reconstruye exactamente las 200 filas del archivo original.
```

---

## COMPARACIÓN: tabla original vs. modelo final

| Aspecto | `PEDIDO_INICIAL` (reporte plano) | Modelo final (10 tablas) |
|---|---|---|
| Filas totales | 200 | 10 + 4 + 10 + 20 + 20 + 5 + 200 + (10×2) + (10×2) + (10×5) |
| Veces que se repite `Restaurante` para `R001` | 40 veces | **1 vez** (en `RESTAURANTE`) |
| Veces que se repite `Cliente` para `CL001` | 20 veces | **1 vez** (en `CLIENTE`) |
| Columna `TelefonosCliente` | Texto con `\|` (no atómico) | Filas individuales en `CLIENTE_TEL` |
| Claves primarias explícitas | Ninguna | 10 |

---

## TRES ANOMALÍAS QUE EL NUEVO DISEÑO REDUCE (con datos reales del CSV)

**Anomalía de INSERCIÓN.** En `PEDIDO_INICIAL`, para registrar un nuevo restaurante (ej. uno que todavía no tiene ningún plato asignado) sería necesario inventar una fila completa de pedido/plato solo para poder guardar sus datos — no se puede insertar un restaurante "solo". En el modelo final, basta con `INSERT INTO RESTAURANTE (...)`, sin necesidad de ningún pedido ni ningún plato asociado todavía.

**Anomalía de ACTUALIZACIÓN.** El restaurante `R001` (Restaurante 1) aparece repetido 40 veces en `PEDIDO_INICIAL`. Si cambia su `DistritoRestaurante`, en la tabla original hay que actualizar las 40 filas (riesgo real de dejar alguna desactualizada); en el modelo final, **un solo** `UPDATE RESTAURANTE SET DistritoRestaurante=... WHERE IDRestaurante='R001'` corrige el dato para siempre.

**Anomalía de ELIMINACIÓN.** Si en `PEDIDO_INICIAL` se eliminara la única fila del pedido `PED001` que contiene al plato `PL001` (Plato 1), se perdería SIMULTÁNEAMENTE toda la información del plato (nombre, categoría, precio, restaurante) aunque ese plato siga existiendo en el catálogo real. En el modelo final, `PLATO` conserva los datos del plato de forma independiente: borrar una fila de `DETALLE_PEDIDO` no borra nada de `PLATO`.

---

## CHECKLIST DE ENTREGA — Caso 6

- [ ] Script `.sql` con los 8 pasos de este documento, ejecutado de principio a fin sin errores
- [ ] Capturas de las consultas del Paso 2 (clave candidata) y Paso 3 (dependencias funcionales)
- [ ] Capturas de la verificación 1FN (Paso 4.2) y de los conteos 2FN/3FN (Pasos 5 y 6)
- [ ] Captura de la comprobación 4FN (combinaciones completas) y 5FN (0 diferencias, Paso 8.3)
- [ ] Modelo final con las 10 tablas, PK y FK indicadas
- [ ] JOIN final de al menos 3 tablas, ejecutado y con resultado visible
- [ ] Explicación de una anomalía de inserción, una de actualización y una de eliminación, con datos reales del CSV (puedes usar las de este documento o encontrar las tuyas)

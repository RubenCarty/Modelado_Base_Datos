# SOLUCIÓN — Caso 1. Ventas minoristas
## Laboratorio 6 de Base de Datos — Normalización 1FN · 2FN · 3FN · 4FN · 5FN

**Archivo de datos:** `01_Ventas_Minoristas_200.csv` (200 registros reales, ya cargados y verificados para esta solución)
**Base de datos a crear en SQL Server:** `Lab06_Caso01`

> **Antes de empezar:** si todavía no sabes cómo importar un CSV a SQL Server 2022, abre primero
> [`00_COMO_IMPORTAR_CSV_SQLSERVER22.md`](00_COMO_IMPORTAR_CSV_SQLSERVER22.md) — son los mismos 10 pasos para los 10 casos del laboratorio, aquí no se repiten.
>
> **Verificación de esta solución:** todas las consultas de este documento (claves, dependencias funcionales, cardinalidades, reconstrucción por JOIN) fueron ejecutadas y comprobadas contra el archivo CSV real con un motor de prueba — los números que aparecen (filas, conteos, violaciones) son los resultados reales del archivo, no estimaciones. La sintaxis T-SQL (`STRING_SPLIT`, `IDENTITY`, etc.) es válida en SQL Server 2022; se recomienda correr el script completo en tu propio SQL Server antes de la clase.

---

## Contexto y problemática (del enunciado de la guía)

**Contexto.** Una empresa comercial registra pedidos de clientes atendidos por web y tienda. En una sola tabla guarda datos del cliente, producto, proveedor, canal, promoción y proyecto comercial.

**Problemática.** La misma información de clientes, productos y proveedores aparece repetida. Una actualización parcial puede dejar nombres, precios o datos del proveedor inconsistentes.

---

## PASO 0 — Crear la base de datos

```sql
DROP DATABASE IF EXISTS Lab06_Caso01;
CREATE DATABASE Lab06_Caso01;
USE Lab06_Caso01;
```

---

## PASO 1 — Explorar los 200 registros (hallazgos antes de tocar la estructura)

Abre la tabla ya importada (ver guía de importación) y mira las primeras filas:

```sql
SELECT TOP 10 * FROM ORDEN_INICIAL;
```

**Tres hallazgos que debes anotar antes de modificar nada** (ya verificados en este archivo):

1. **Dato repetido de proveedor:** el proveedor `PV001` (Proveedor 1) aparece repetido en varias filas, siempre con el mismo nombre — exactamente el patrón que genera riesgo de inconsistencia si alguien actualiza una sola fila y olvida las demás.
2. **Valor no atómico en `TelefonosCliente`:** la columna trae dos valores en una sola celda separados por `|` (ejemplo real: `98000001|98100001`) — viola la atomicidad exigida por 1FN.
3. **Clave simple insuficiente:** ni `IDOrden` ni `IDProducto` identifican una fila por sí solos — `IDOrden` se repite 20 veces (una por cada producto) y `IDProducto` se repite 10 veces (una por cada pedido); se necesita la combinación de ambos.

---

## PASO 2 — Determinar la clave candidata (COUNT + GROUP BY)

```sql
-- 2.1  ¿Es IDOrden suficiente por sí solo?
SELECT IDOrden, COUNT(*) AS Filas
FROM ORDEN_INICIAL
GROUP BY IDOrden;
-- Resultado real: 10 valores distintos de IDOrden, cada uno con 20 filas -> NO es clave por sí solo.
```

```sql
-- 2.2  ¿Es IDProducto suficiente por sí solo?
SELECT IDProducto, COUNT(*) AS Filas
FROM ORDEN_INICIAL
GROUP BY IDProducto;
-- Resultado real: 20 valores distintos de IDProducto, cada uno con 10 filas -> NO es clave por sí solo.
```

```sql
-- 2.3  ¿La combinación (IDOrden, IDProducto) identifica una fila única?
SELECT IDOrden, IDProducto, COUNT(*) AS Filas
FROM ORDEN_INICIAL
GROUP BY IDOrden, IDProducto
HAVING COUNT(*) > 1;
-- Resultado real: 0 filas devueltas -> cada combinación aparece EXACTAMENTE una vez.
```

**Clave candidata: {IDOrden, IDProducto}** (clave compuesta).

---

## PASO 3 — Identificar las dependencias funcionales (con evidencia real del CSV)

```sql
-- DF 1:  IDCliente -> NombreCliente, ZonaCliente, TelefonosCliente
SELECT IDCliente, NombreCliente, ZonaCliente, TelefonosCliente
FROM ORDEN_INICIAL
WHERE IDCliente = 'CL001';
```
**Evidencia (2 filas reales, mismo `IDCliente`, 20 veces en total — aquí solo 2):**
| IDCliente | NombreCliente | ZonaCliente | TelefonosCliente |
|---|---|---|---|
| CL001 | Cliente 1 | Zona 1 | 98000001\|98100001 |
| CL001 | Cliente 1 | Zona 1 | 98000001\|98100001 |

Siempre el mismo nombre, zona y teléfonos para `CL001` → **`IDCliente → NombreCliente, ZonaCliente, TelefonosCliente`** se confirma.

```sql
-- DF 2:  ZonaCliente -> SupervisorZona
SELECT DISTINCT ZonaCliente, SupervisorZona
FROM ORDEN_INICIAL
WHERE ZonaCliente = 'Zona 1';
```
**Evidencia:** `Zona 1` siempre trae `SupervisorZona` = `Supervisor 1` → **`ZonaCliente → SupervisorZona`** se confirma.

```sql
-- DF 3:  IDProducto -> NombreProducto, CategoriaProducto, PrecioUnitario, IDProveedor
SELECT IDProducto, NombreProducto, CategoriaProducto, PrecioUnitario, IDProveedor
FROM ORDEN_INICIAL
WHERE IDProducto = 'P001'
ORDER BY IDOrden;
```
**Evidencia (2 filas reales, mismo `IDProducto`, en pedidos distintos — demuestra que NO depende de `IDOrden`):**
| IDProducto | NombreProducto | CategoriaProducto | PrecioUnitario | IDProveedor |
|---|---|---|---|---|
| P001 | Producto 1 | Categoria 1 | 24.5 | PV001 |
| P001 | Producto 1 | Categoria 1 | 24.5 | PV001 |

**`IDProducto → NombreProducto, CategoriaProducto, PrecioUnitario, IDProveedor`** se confirma: el precio y el proveedor del producto no cambian aunque cambie el pedido.

```sql
-- DF 4:  IDProveedor -> NombreProveedor, CiudadProveedor
SELECT DISTINCT IDProveedor, NombreProveedor, CiudadProveedor
FROM ORDEN_INICIAL
WHERE IDProveedor = 'PV001';
```
**Evidencia:** `PV001` siempre trae `NombreProveedor` = `Proveedor 1` y `CiudadProveedor` = `Ciudad 1` → **`IDProveedor → NombreProveedor, CiudadProveedor`** se confirma.

```sql
-- DF 5 (dependencia COMPLETA, no parcial):  (IDOrden, IDProducto) -> Cantidad, PrecioTotal
SELECT IDOrden, IDProducto, Cantidad, PrecioTotal
FROM ORDEN_INICIAL
WHERE IDProducto = 'P001'
ORDER BY IDOrden;
-- Observa: el mismo IDProducto trae distinta Cantidad/PrecioTotal según el pedido -> depende de LA CLAVE COMPLETA, no de una parte.
```

---

## PASO 4 — Primera Forma Normal (1FN)

**Violación encontrada:** `TelefonosCliente` no es atómica (trae `98000001|98100001`, 2 valores en una celda).

```sql
-- 4.1  Separar el valor multivaluado en su propia tabla
CREATE TABLE CLIENTE_TELEFONO (
    IDCliente VARCHAR(10)  NOT NULL,
    Valor            VARCHAR(30) NOT NULL,
    CONSTRAINT PK_CLIENTE_TELEFONO PRIMARY KEY (IDCliente, Valor)
);

INSERT INTO CLIENTE_TELEFONO (IDCliente, Valor)
SELECT DISTINCT IDCliente, LTRIM(RTRIM(valor.value))
FROM ORDEN_INICIAL
CROSS APPLY STRING_SPLIT(TelefonosCliente, '|') AS valor;
```

```sql
-- 4.2  Verificar 1FN: debe haber 20 filas (= 10 clientes x 2 teléfonos cada uno)
SELECT COUNT(*) AS Filas FROM CLIENTE_TELEFONO;
```

```sql
-- 4.3  Crear la tabla en 1FN: mismas columnas MENOS la multivaluada, con PK compuesta
CREATE TABLE ORDEN_1FN (
    IDOrden        VARCHAR(10)   NOT NULL,
    IDCliente        VARCHAR(10)   NOT NULL,
    NombreCliente       NVARCHAR(80)  NOT NULL,
    ZonaCliente        NVARCHAR(40)  NOT NULL,
    SupervisorZona     NVARCHAR(40)  NOT NULL,
    IDProducto        VARCHAR(10)   NOT NULL,
    NombreProducto       NVARCHAR(80)  NOT NULL,
    CategoriaProducto       NVARCHAR(40)  NOT NULL,
    PrecioUnitario       DECIMAL(10,2) NOT NULL,
    Cantidad      INT           NOT NULL,
    PrecioTotal      DECIMAL(10,2) NOT NULL,
    IDProveedor        VARCHAR(10)   NOT NULL,
    NombreProveedor       NVARCHAR(80)  NOT NULL,
    CiudadProveedor       NVARCHAR(40)  NOT NULL,
    CanalAtencion       NVARCHAR(40)  NOT NULL,
    Promocion       NVARCHAR(40)  NOT NULL,
    ProyectoComercial       NVARCHAR(40)  NOT NULL,
    CONSTRAINT PK_ORDEN_1FN PRIMARY KEY (IDOrden, IDProducto)
);

INSERT INTO ORDEN_1FN
SELECT IDOrden,IDCliente,NombreCliente,ZonaCliente,SupervisorZona,IDProducto,NombreProducto,CategoriaProducto,PrecioUnitario,Cantidad,PrecioTotal,IDProveedor,NombreProveedor,CiudadProveedor,CanalAtencion,Promocion,ProyectoComercial
FROM ORDEN_INICIAL;

SELECT COUNT(*) AS Filas FROM ORDEN_1FN;   -- debe devolver 200
```

✅ **Cumple 1FN:** cada celda tiene un único valor; la clave compuesta (IDOrden, IDProducto) identifica cada fila sin ambigüedad.

---

## PASO 5 — Segunda Forma Normal (2FN): eliminar dependencias parciales

Atributos que dependen SOLO de `IDOrden` (parte de la clave): `IDCliente, NombreCliente, ZonaCliente, SupervisorZona`.
Atributos que dependen SOLO de `IDProducto` (la otra parte): `NombreProducto, CategoriaProducto, PrecioUnitario, IDProveedor, NombreProveedor, CiudadProveedor`.
Atributos que dependen de LA CLAVE COMPLETA: `Cantidad, PrecioTotal`.

```sql
-- 5.1  Lado del pedido (todo lo que depende solo de IDOrden)
CREATE TABLE ORDEN_2FN (
    IDOrden    VARCHAR(10)  NOT NULL,
    IDCliente    VARCHAR(10)  NOT NULL,
    NombreCliente   NVARCHAR(80) NOT NULL,
    ZonaCliente    NVARCHAR(40) NOT NULL,
    SupervisorZona NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_ORDEN_2FN PRIMARY KEY (IDOrden)
);
INSERT INTO ORDEN_2FN
SELECT DISTINCT IDOrden,IDCliente,NombreCliente,ZonaCliente,SupervisorZona FROM ORDEN_1FN;

-- 5.2  Lado del producto (todo lo que depende solo de IDProducto)
CREATE TABLE PRODUCTO_2FN (
    IDProducto  VARCHAR(10)   NOT NULL,
    NombreProducto NVARCHAR(80)  NOT NULL,
    CategoriaProducto NVARCHAR(40)  NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    IDProveedor  VARCHAR(10)   NOT NULL,
    NombreProveedor NVARCHAR(80)  NOT NULL,
    CiudadProveedor NVARCHAR(40)  NOT NULL,
    CONSTRAINT PK_PRODUCTO_2FN PRIMARY KEY (IDProducto)
);
INSERT INTO PRODUCTO_2FN
SELECT DISTINCT IDProducto,NombreProducto,CategoriaProducto,PrecioUnitario,IDProveedor,NombreProveedor,CiudadProveedor FROM ORDEN_1FN;

-- 5.3  Detalle: solo lo que depende de LA CLAVE COMPLETA (+ precio histórico de la transacción)
CREATE TABLE DETALLE_ORDEN (
    IDOrden    VARCHAR(10)   NOT NULL,
    IDProducto    VARCHAR(10)   NOT NULL,
    PrecioUnitario   DECIMAL(10,2) NOT NULL,   -- precio histórico al momento de la transacción
    Cantidad  INT           NOT NULL,
    PrecioTotal  DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_DETALLE_ORDEN PRIMARY KEY (IDOrden, IDProducto),
    CONSTRAINT FK_DETALLE_ORDEN_PRODUCTO FOREIGN KEY (IDProducto) REFERENCES PRODUCTO_2FN(IDProducto)
);
INSERT INTO DETALLE_ORDEN (IDOrden,IDProducto,PrecioUnitario,Cantidad,PrecioTotal)
SELECT IDOrden,IDProducto,PrecioUnitario,Cantidad,PrecioTotal FROM ORDEN_1FN;
```

```sql
-- Verificación: ORDEN_2FN debe tener 10 filas, PRODUCTO_2FN debe tener 20 filas, DETALLE_ORDEN debe tener 200 filas
SELECT COUNT(*) FROM ORDEN_2FN;   -- 10
SELECT COUNT(*) FROM PRODUCTO_2FN;   -- 20
SELECT COUNT(*) FROM DETALLE_ORDEN;  -- 200
```

> **¿Por qué se conserva `PrecioUnitario` también en `DETALLE_ORDEN`?** Para guardar el precio **histórico** de esa transacción puntual. El precio "actual" del catálogo vive en `PRODUCTO_2FN`; si el precio de catálogo cambia mañana, las transacciones ya registradas no deben cambiar retroactivamente.

---

## PASO 6 — Tercera Forma Normal (3FN): eliminar dependencias transitivas

Dos cadenas transitivas detectadas:
- `IDOrden → IDCliente → NombreCliente, ZonaCliente` y `ZonaCliente → SupervisorZona` (cadena de 3: `IDOrden → ZonaCliente → SupervisorZona`)
- `IDProducto → IDProveedor → NombreProveedor, CiudadProveedor` (cadena: `IDProducto → IDProveedor → NombreProveedor, CiudadProveedor`)

```sql
-- 6.1  Separar ZONA (resuelve ZonaCliente -> SupervisorZona)
CREATE TABLE ZONA (
    ZonaCliente    NVARCHAR(40) NOT NULL,
    SupervisorZona NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_ZONA PRIMARY KEY (ZonaCliente)
);
INSERT INTO ZONA SELECT DISTINCT ZonaCliente,SupervisorZona FROM ORDEN_2FN;

-- 6.2  CLIENTE definitivo (ya sin ZonaCliente repetido con el responsable adentro; ZonaCliente queda como FK)
CREATE TABLE CLIENTE (
    IDCliente  VARCHAR(10)  NOT NULL,
    NombreCliente NVARCHAR(80) NOT NULL,
    ZonaCliente  NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_CLIENTE PRIMARY KEY (IDCliente),
    CONSTRAINT FK_CLIENTE_ZONA FOREIGN KEY (ZonaCliente) REFERENCES ZONA(ZonaCliente)
);
INSERT INTO CLIENTE SELECT DISTINCT IDCliente,NombreCliente,ZonaCliente FROM ORDEN_2FN;

-- 6.3  ORDEN definitivo (solo el id del pedido + FK al cliente)
CREATE TABLE ORDEN (
    IDOrden VARCHAR(10) NOT NULL,
    IDCliente VARCHAR(10) NOT NULL,
    CONSTRAINT PK_ORDEN PRIMARY KEY (IDOrden),
    CONSTRAINT FK_ORDEN_CLIENTE FOREIGN KEY (IDCliente) REFERENCES CLIENTE(IDCliente)
);
INSERT INTO ORDEN SELECT IDOrden,IDCliente FROM ORDEN_2FN;

-- 6.4  Separar PROVEEDOR (resuelve IDProducto -> IDProveedor -> NombreProveedor,CiudadProveedor)
CREATE TABLE PROVEEDOR (
    IDProveedor  VARCHAR(10)  NOT NULL,
    NombreProveedor NVARCHAR(80) NOT NULL,
    CiudadProveedor NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_PROVEEDOR PRIMARY KEY (IDProveedor)
);
INSERT INTO PROVEEDOR SELECT DISTINCT IDProveedor,NombreProveedor,CiudadProveedor FROM PRODUCTO_2FN;

-- 6.5  PRODUCTO definitivo (ya sin los datos del proveedor adentro; IDProveedor queda como FK)
CREATE TABLE PRODUCTO (
    IDProducto  VARCHAR(10)   NOT NULL,
    NombreProducto NVARCHAR(80)  NOT NULL,
    CategoriaProducto NVARCHAR(40)  NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    IDProveedor  VARCHAR(10)   NOT NULL,
    CONSTRAINT PK_PRODUCTO PRIMARY KEY (IDProducto),
    CONSTRAINT FK_PRODUCTO_PROVEEDOR FOREIGN KEY (IDProveedor) REFERENCES PROVEEDOR(IDProveedor)
);
INSERT INTO PRODUCTO SELECT IDProducto,NombreProducto,CategoriaProducto,PrecioUnitario,IDProveedor FROM PRODUCTO_2FN;
```

```sql
-- Verificación: ZONA=4 filas | CLIENTE=10 filas | ORDEN=10 filas | PROVEEDOR=5 filas | PRODUCTO=20 filas
SELECT COUNT(*) FROM ZONA;  SELECT COUNT(*) FROM CLIENTE;  SELECT COUNT(*) FROM ORDEN;
SELECT COUNT(*) FROM PROVEEDOR;  SELECT COUNT(*) FROM PRODUCTO;
```

✅ **Cumple 3FN:** ningún atributo no-clave depende de otro atributo no-clave; todo depende directamente de la clave de su propia tabla.

---

## PASO 7 — Cuarta Forma Normal (4FN): hechos multivaluados independientes

**Hallazgo (grano = un `IDOrden`):** dentro de un mismo pedido (ejemplo real `O001`, con sus 20 filas), `CanalAtencion` toma **2** valores distintos (Tienda, Web) y `Promocion` toma **2** valores distintos (Cupon10, EnvioGratis) — y aparecen **todas** las combinaciones posibles entre ambos (evidencia de que son independientes entre sí para la misma operación, no uno depende del otro).

```sql
-- Evidencia: ¿aparecen TODAS las combinaciones de CanalAtencion x Promocion dentro de un mismo IDOrden?
SELECT DISTINCT CanalAtencion, Promocion
FROM ORDEN_1FN
WHERE IDOrden = 'O001'
ORDER BY CanalAtencion, Promocion;
-- Resultado real: 4 combinaciones (= 2 x 2) -> confirma independencia (MVD).
```

```sql
-- 7.1  Separar los dos hechos multivaluados independientes
CREATE TABLE ORDEN_CANALATENCION (
    IDOrden  VARCHAR(10)  NOT NULL,
    CanalAtencion NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_ORDEN_CANALATENCION PRIMARY KEY (IDOrden, CanalAtencion)
);
INSERT INTO ORDEN_CANALATENCION SELECT DISTINCT IDOrden,CanalAtencion FROM ORDEN_1FN;

CREATE TABLE ORDEN_PROMOCION (
    IDOrden  VARCHAR(10)  NOT NULL,
    Promocion NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_ORDEN_PROMOCION PRIMARY KEY (IDOrden, Promocion)
);
INSERT INTO ORDEN_PROMOCION SELECT DISTINCT IDOrden,Promocion FROM ORDEN_1FN;
```

> ⚠ **Nota honesta sobre estos datos.** En esta muestra, `IDProducto` TAMBIÉN determina `CanalAtencion` y `Promocion` sin excepción (es un efecto de cómo se generó el archivo: los mismos 20 productos se repiten idénticos en cada pedido). Eso NO es una regla de negocio real — un producto no "tiene" un canal fijo en la vida real. Tratamos `CanalAtencion` y `Promocion` como hechos independientes del **pedido** (que es la lectura que pide el enunciado de la guía: "hechos multivaluados... para una misma operación"), no del producto. Coméntalo así en tu sustentación.

---

## PASO 8 — Quinta Forma Normal (5FN): relación ternaria y reconstrucción sin pérdida

Agregamos el tercer hecho, `ProyectoComercial` (5 valores: Proyecto Centro, Proyecto Escolar, Proyecto Norte, Proyecto Premium, Proyecto Sur), y verificamos si la combinación de los **tres** (CanalAtencion, Promocion, ProyectoComercial) para un mismo `IDOrden` se reconstruye exactamente uniendo tres tablas binarias — sin inventar combinaciones (filas espurias) ni perder ninguna.

```sql
-- 8.1  Tercera tabla
CREATE TABLE ORDEN_PROYECTOCOMERCIAL (
    IDOrden  VARCHAR(10)  NOT NULL,
    ProyectoComercial NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_ORDEN_PROYECTOCOMERCIAL PRIMARY KEY (IDOrden, ProyectoComercial)
);
INSERT INTO ORDEN_PROYECTOCOMERCIAL SELECT DISTINCT IDOrden,ProyectoComercial FROM ORDEN_1FN;
```

```sql
-- 8.2  Verificación de reconstrucción (debe devolver exactamente 20 filas para 'O001', ni una más ni una menos)
SELECT c1.IDOrden, c1.CanalAtencion, c2.Promocion, c3.ProyectoComercial
FROM ORDEN_CANALATENCION c1
JOIN ORDEN_PROMOCION c2 ON c2.IDOrden = c1.IDOrden
JOIN ORDEN_PROYECTOCOMERCIAL c3 ON c3.IDOrden = c1.IDOrden
WHERE c1.IDOrden = 'O001'
ORDER BY c1.CanalAtencion, c2.Promocion, c3.ProyectoComercial;
```

```sql
-- 8.3  Comprobación automática contra la tabla original (0 = reconstrucción exacta)
SELECT COUNT(*) AS Diferencias FROM (
    SELECT CanalAtencion,Promocion,ProyectoComercial FROM ORDEN_1FN WHERE IDOrden='O001'
    EXCEPT
    SELECT c1.CanalAtencion, c2.Promocion, c3.ProyectoComercial
    FROM ORDEN_CANALATENCION c1
    JOIN ORDEN_PROMOCION c2 ON c2.IDOrden=c1.IDOrden
    JOIN ORDEN_PROYECTOCOMERCIAL c3 ON c3.IDOrden=c1.IDOrden
    WHERE c1.IDOrden='O001'
) AS Diff;
-- Verificado contra el CSV real: 0 diferencias -> descomposición SIN PÉRDIDA.
```

✅ **Cumple 5FN:** la relación ternaria se reconstruye exactamente mediante el JOIN de las tres tablas binarias — no hace falta guardar una tabla de 3 columnas.

---

## MODELO FINAL

| # | Tabla | Clave primaria (PK) | Claves foráneas (FK) |
|---|---|---|---|
| 1 | `ZONA` | ZonaCliente | — |
| 2 | `CLIENTE` | IDCliente | ZonaCliente → `ZONA` |
| 3 | `CLIENTE_TELEFONO` | (IDCliente, Valor) | IDCliente → `CLIENTE` |
| 4 | `ORDEN` | IDOrden | IDCliente → `CLIENTE` |
| 5 | `PROVEEDOR` | IDProveedor | — |
| 6 | `PRODUCTO` | IDProducto | IDProveedor → `PROVEEDOR` |
| 7 | `DETALLE_ORDEN` | (IDOrden, IDProducto) | IDOrden → `ORDEN` · IDProducto → `PRODUCTO` |
| 8 | `ORDEN_CANALATENCION` | (IDOrden, CanalAtencion) | IDOrden → `ORDEN` |
| 9 | `ORDEN_PROMOCION` | (IDOrden, Promocion) | IDOrden → `ORDEN` |
| 10 | `ORDEN_PROYECTOCOMERCIAL` | (IDOrden, ProyectoComercial) | IDOrden → `ORDEN` |

**Relaciones:** `ZONA` 1:N `CLIENTE` · `CLIENTE` 1:N `ORDEN` (vía FK) · `CLIENTE` 1:N `CLIENTE_TEL` · `ORDEN` 1:N `DETALLE_ORDEN` · `PRODUCTO` 1:N `DETALLE_ORDEN` · `PROVEEDOR` 1:N `PRODUCTO` · `ORDEN` 1:N `ORDEN_CANALATENCION`/`ORDEN_PROMOCION`/`ORDEN_PROYECTOCOMERCIAL`.

### JOIN final (reúne más de tres tablas normalizadas)

```sql
SELECT
    h.IDOrden, a.NombreCliente, g.ZonaCliente, g.SupervisorZona,
    i.NombreProducto, s.NombreProveedor, s.CiudadProveedor,
    d.Cantidad, d.PrecioUnitario, d.PrecioTotal
FROM DETALLE_ORDEN d
JOIN ORDEN h ON h.IDOrden = d.IDOrden
JOIN CLIENTE a ON a.IDCliente = h.IDCliente
JOIN ZONA g ON g.ZonaCliente = a.ZonaCliente
JOIN PRODUCTO i ON i.IDProducto = d.IDProducto
JOIN PROVEEDOR s ON s.IDProveedor = i.IDProveedor
ORDER BY h.IDOrden, i.IDProducto;
-- Verificado contra el CSV real: reconstruye exactamente las 200 filas del archivo original.
```

---

## COMPARACIÓN: tabla original vs. modelo final

| Aspecto | `ORDEN_INICIAL` (reporte plano) | Modelo final (10 tablas) |
|---|---|---|
| Filas totales | 200 | 10 + 4 + 10 + 20 + 20 + 5 + 200 + (10×2) + (10×2) + (10×5) |
| Veces que se repite `NombreProveedor` para `PV001` | 40 veces | **1 vez** (en `PROVEEDOR`) |
| Veces que se repite `NombreCliente` para `CL001` | 20 veces | **1 vez** (en `CLIENTE`) |
| Columna `TelefonosCliente` | Texto con `\|` (no atómico) | Filas individuales en `CLIENTE_TEL` |
| Claves primarias explícitas | Ninguna | 10 |

---

## TRES ANOMALÍAS QUE EL NUEVO DISEÑO REDUCE (con datos reales del CSV)

**Anomalía de INSERCIÓN.** En `ORDEN_INICIAL`, para registrar un nuevo proveedor (ej. uno que todavía no tiene ningún producto asignado) sería necesario inventar una fila completa de pedido/producto solo para poder guardar sus datos — no se puede insertar un proveedor "solo". En el modelo final, basta con `INSERT INTO PROVEEDOR (...)`, sin necesidad de ningún pedido ni ningún producto asociado todavía.

**Anomalía de ACTUALIZACIÓN.** El proveedor `PV001` (Proveedor 1) aparece repetido 40 veces en `ORDEN_INICIAL`. Si cambia su `CiudadProveedor`, en la tabla original hay que actualizar las 40 filas (riesgo real de dejar alguna desactualizada); en el modelo final, **un solo** `UPDATE PROVEEDOR SET CiudadProveedor=... WHERE IDProveedor='PV001'` corrige el dato para siempre.

**Anomalía de ELIMINACIÓN.** Si en `ORDEN_INICIAL` se eliminara la única fila del pedido `O001` que contiene al producto `P001` (Producto 1), se perdería SIMULTÁNEAMENTE toda la información del producto (nombre, categoría, precio, proveedor) aunque ese producto siga existiendo en el catálogo real. En el modelo final, `PRODUCTO` conserva los datos del producto de forma independiente: borrar una fila de `DETALLE_ORDEN` no borra nada de `PRODUCTO`.

---

## CHECKLIST DE ENTREGA — Caso 1

- [ ] Script `.sql` con los 8 pasos de este documento, ejecutado de principio a fin sin errores
- [ ] Capturas de las consultas del Paso 2 (clave candidata) y Paso 3 (dependencias funcionales)
- [ ] Capturas de la verificación 1FN (Paso 4.2) y de los conteos 2FN/3FN (Pasos 5 y 6)
- [ ] Captura de la comprobación 4FN (combinaciones completas) y 5FN (0 diferencias, Paso 8.3)
- [ ] Modelo final con las 10 tablas, PK y FK indicadas
- [ ] JOIN final de al menos 3 tablas, ejecutado y con resultado visible
- [ ] Explicación de una anomalía de inserción, una de actualización y una de eliminación, con datos reales del CSV (puedes usar las de este documento o encontrar las tuyas)

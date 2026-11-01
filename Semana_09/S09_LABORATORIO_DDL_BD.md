# LABORATORIO 9 — DDL: de modelo lógico a tablas reales en SQL Server
## Modelado y Diseño de Base de Datos — Semana 9

| Campo | Detalle |
|---|---|
| **Tema** | DDL: `CREATE TABLE`, tipos de dato, restricciones, índices |
| **Caso** | Ventas Minoristas (el mismo que ya normalizaste en el Laboratorio 6) |
| **Duración** | 2 horas |
| **Herramienta** | SQL Server (contenedor `sqlserver2025`) + DBeaver |
| **Nombre** | _________________________________________________ |
| **Código** | _________________ |

---

## OBJETIVO

En el Laboratorio 6 ya decidiste **cuáles** tablas necesitabas y **cómo** se relacionan (normalización 1FN-5FN). Hoy el objetivo cambia: decidir **con qué precisión** representar cada dato — el tipo de columna correcto, qué valores prohibir con restricciones, y qué índices acelerarán las consultas que más vas a usar. Esto es DDL: el lenguaje que define la estructura física de tu base de datos, no sus datos.

Al finalizar debes tener las 10 tablas del Caso 1 creadas en SQL Server, con tipos de dato ajustados a datos reales (no "VARCHAR(255) por si acaso"), restricciones que reflejan reglas de negocio verificadas en el CSV, y 2 índices justificados.

---

## PASO 0 — Preparar el entorno

```sql
DROP DATABASE IF EXISTS Lab09_DDL;
CREATE DATABASE Lab09_DDL;
USE Lab09_DDL;
```

Importa `01_Ventas_Minoristas_200.csv` a una tabla `ORDEN_INICIAL` siguiendo la guía `00_COMO_IMPORTAR_CSV_SQLSERVER22.md` de la carpeta `S06/dataset_Lab6/` (mismo procedimiento del Laboratorio 6).

---

## PASO 1 — Recuerda el modelo lógico que ya decidiste en S06

Estas son las 10 tablas de tu `Solucion_Caso01_Ventas_minoristas.md`. Hoy no cambias el diseño — lo implementas con rigor:

| Tabla | PK | FK |
|---|---|---|
| `ZONA` | ZonaCliente | — |
| `CLIENTE` | IDCliente | ZonaCliente → ZONA |
| `CLIENTE_TELEFONO` | (IDCliente, Valor) | IDCliente → CLIENTE |
| `PROVEEDOR` | IDProveedor | — |
| `PRODUCTO` | IDProducto | IDProveedor → PROVEEDOR |
| `ORDEN` | IDOrden | IDCliente → CLIENTE |
| `DETALLE_ORDEN` | (IDOrden, IDProducto) | IDOrden → ORDEN · IDProducto → PRODUCTO |
| `ORDEN_CANALATENCION` | (IDOrden, CanalAtencion) | IDOrden → ORDEN |
| `ORDEN_PROMOCION` | (IDOrden, Promocion) | IDOrden → ORDEN |
| `ORDEN_PROYECTOCOMERCIAL` | (IDOrden, ProyectoComercial) | IDOrden → ORDEN |

---

## PASO 2 — Elige el tipo de dato correcto para cada columna

**No existe un tipo "universal".** Antes de escribir un solo `CREATE TABLE`, inspecciona los datos reales y decide con evidencia:

```sql
-- 2.1 ¿Cuál es el largo máximo real de cada texto? (para no poner VARCHAR(255) a ciegas)
SELECT
    MAX(LEN(IDOrden)) AS max_IDOrden, MAX(LEN(NombreCliente)) AS max_NombreCliente,
    MAX(LEN(ZonaCliente)) AS max_ZonaCliente, MAX(LEN(SupervisorZona)) AS max_SupervisorZona,
    MAX(LEN(NombreProducto)) AS max_NombreProducto, MAX(LEN(CategoriaProducto)) AS max_CategoriaProducto,
    MAX(LEN(NombreProveedor)) AS max_NombreProveedor, MAX(LEN(CiudadProveedor)) AS max_CiudadProveedor
FROM ORDEN_INICIAL;
```

```sql
-- 2.2 ¿Qué rango tienen los valores numéricos? (para elegir INT vs TINYINT, DECIMAL con la precisión justa)
SELECT MIN(PrecioUnitario) AS min_precio, MAX(PrecioUnitario) AS max_precio,
       MIN(Cantidad) AS min_cant, MAX(Cantidad) AS max_cant,
       MIN(PrecioTotal) AS min_total, MAX(PrecioTotal) AS max_total
FROM ORDEN_INICIAL;
```

**Completa esta tabla con tus resultados, y la decisión de tipo que tomarás (deja margen razonable, no copies el máximo exacto):**

| Columna | Largo/rango real observado | Tipo elegido | Justificación |
|---|---|---|---|
| IDOrden | | | |
| NombreCliente | | | |
| PrecioUnitario | | | |
| Cantidad | | | |

> **Guía de decisión rápida:**
> - Texto con tildes/Ñ (nombres, ciudades) → `NVARCHAR`, nunca `VARCHAR`.
> - Códigos cortos de formato fijo (IDOrden, IDProducto) → `CHAR` o `VARCHAR` corto, no `NVARCHAR` (no llevan tildes).
> - Dinero → `DECIMAL(p,s)`, nunca `FLOAT` (el redondeo de FLOAT puede alterar centavos).
> - Cantidades enteras pequeñas → `TINYINT` o `SMALLINT`, no `INT` "por si acaso" si el negocio nunca superará unas pocas unidades.
> - Fechas sin hora → `DATE`, no `DATETIME`.

---

## PASO 3 — Tablas maestras (sin FK)

```sql
CREATE TABLE ZONA (
    ZonaCliente    NVARCHAR(20) NOT NULL,
    SupervisorZona NVARCHAR(30) NOT NULL,
    CONSTRAINT PK_ZONA PRIMARY KEY (ZonaCliente)
);

CREATE TABLE PROVEEDOR (
    IDProveedor     CHAR(5)      NOT NULL,
    NombreProveedor NVARCHAR(40) NOT NULL,
    CiudadProveedor NVARCHAR(30) NOT NULL,
    CONSTRAINT PK_PROVEEDOR PRIMARY KEY (IDProveedor)
);
```

**Pregunta antes de seguir:** ¿por qué `IDProveedor` es `CHAR(5)` y no `NVARCHAR(5)`? *(Respuesta esperada: es un código de formato fijo sin tildes — "PV001" siempre mide 5; `CHAR` es más eficiente que `NVARCHAR` cuando el largo es constante.)*

---

## PASO 4 — Tablas con una FK simple

```sql
CREATE TABLE CLIENTE (
    IDCliente     CHAR(5)      NOT NULL,
    NombreCliente NVARCHAR(30) NOT NULL,
    ZonaCliente   NVARCHAR(20) NOT NULL,
    CONSTRAINT PK_CLIENTE PRIMARY KEY (IDCliente),
    CONSTRAINT FK_CLIENTE_ZONA FOREIGN KEY (ZonaCliente) REFERENCES ZONA (ZonaCliente)
);

-- TODO: crea PRODUCTO (IDProducto PK, NombreProducto, CategoriaProducto, PrecioUnitario, IDProveedor FK)
-- Pista de restricción: ¿puede un producto tener precio 0 o negativo? Agrega el CHECK correspondiente.
```

---

## PASO 5 — Atributo multivalorado y tabla de encabezado

```sql
CREATE TABLE CLIENTE_TELEFONO (
    IDCliente CHAR(5)     NOT NULL,
    Valor     CHAR(9)     NOT NULL,
    CONSTRAINT PK_CLIENTE_TELEFONO PRIMARY KEY (IDCliente, Valor),
    CONSTRAINT FK_CLIENTE_TELEFONO FOREIGN KEY (IDCliente) REFERENCES CLIENTE (IDCliente),
    CONSTRAINT CK_CLIENTE_TELEFONO_FORMATO CHECK (Valor NOT LIKE '%[^0-9]%')
);

-- TODO: crea ORDEN (IDOrden PK, IDCliente FK)
```

**Pregunta antes de seguir:** ¿qué hace el `CHECK (Valor NOT LIKE '%[^0-9]%')` de `CLIENTE_TELEFONO`? *(Respuesta esperada: rechaza cualquier teléfono que contenga un carácter que NO sea dígito — fuerza que solo se guarden números.)*

---

## PASO 6 — El detalle (clave compuesta, dependencia completa)

```sql
-- TODO: crea DETALLE_ORDEN (IDOrden PK FK, IDProducto PK FK, PrecioUnitario, Cantidad, PrecioTotal)
-- Restricciones a decidir con evidencia real (PASO 2.2):
--   - Cantidad: ¿qué tipo de dato y qué CHECK, según el rango real observado (1 a 8)?
--   - PrecioTotal: ¿debería existir siempre, o podrías calcularlo? (de momento, guárdalo; en S11 verás cómo auditarlo con SUM)
```

---

## PASO 7 — Las 3 tablas de hechos multivaluados (4FN/5FN de S06)

```sql
CREATE TABLE ORDEN_CANALATENCION (
    IDOrden       CHAR(4)      NOT NULL,
    CanalAtencion NVARCHAR(10) NOT NULL,
    CONSTRAINT PK_ORDEN_CANALATENCION PRIMARY KEY (IDOrden, CanalAtencion),
    CONSTRAINT FK_ORDEN_CANALATENCION FOREIGN KEY (IDOrden) REFERENCES ORDEN (IDOrden),
    CONSTRAINT CK_ORDEN_CANAL CHECK (CanalAtencion IN (N'Web', N'Tienda'))
);

-- TODO: crea ORDEN_PROMOCION y ORDEN_PROYECTOCOMERCIAL siguiendo el mismo patrón.
-- Pista: revisa con SELECT DISTINCT qué valores reales tiene cada columna en ORDEN_INICIAL
-- antes de decidir si vale la pena un CHECK con lista fija como el de arriba.
```

---

## PASO 8 — Un índice, con justificación (no "por si acaso")

Un índice acelera **una consulta concreta** a costa de espacio y de volver más lento el `INSERT`. No se crean al azar.

```sql
-- Consulta frecuente de negocio: "dame todos los pedidos de un cliente"
-- Sin índice, SQL Server debe revisar TODA la tabla ORDEN fila por fila (scan).
SELECT * FROM ORDEN WHERE IDCliente = 'CL001';

-- Índice que acelera exactamente esa búsqueda:
CREATE NONCLUSTERED INDEX IX_ORDEN_CLIENTE ON ORDEN (IDCliente);
```

**Tarea:** propón un segundo índice justificado (qué consulta acelera y por qué) sobre `DETALLE_ORDEN` o `PRODUCTO`. Escríbelo y documenta tu razonamiento en un comentario.

---

## PASO 9 — Cargar los datos reales y comprobar que las restricciones protegen

```sql
-- Carga (mismo patrón del Laboratorio 6)
INSERT INTO ZONA SELECT DISTINCT ZonaCliente, SupervisorZona FROM ORDEN_INICIAL;
INSERT INTO PROVEEDOR SELECT DISTINCT IDProveedor, NombreProveedor, CiudadProveedor FROM ORDEN_INICIAL;
INSERT INTO CLIENTE SELECT DISTINCT IDCliente, NombreCliente, ZonaCliente FROM ORDEN_INICIAL;
-- completa el resto de INSERT para tus propias tablas (PRODUCTO, ORDEN, DETALLE_ORDEN, las 3 de hechos)
```

**Prueba que tus restricciones de verdad protegen** (cada una de estas 3 líneas DEBE fallar con un error — captúralo):

```sql
-- Prueba 1: ¿tu CHECK de precio rechaza un producto gratis o negativo?
INSERT INTO PRODUCTO VALUES ('P999', N'Producto prueba', N'Categoria X', -10.00, 'PV001');

-- Prueba 2: ¿tu PK compuesta de DETALLE_ORDEN rechaza una fila duplicada?
INSERT INTO DETALLE_ORDEN VALUES ('O001', 'P001', 24.5, 3, 73.5);  -- ya existe, debe fallar

-- Prueba 3: ¿tu FK rechaza un cliente inexistente?
INSERT INTO ORDEN VALUES ('O999', 'CL999');
```

---

## ENTREGABLES

1. Script `.sql` con las 10 tablas completas (incluyendo tus 2 índices justificados), ejecutado sin errores.
2. La tabla del Paso 2 completa con tus decisiones de tipo y justificación.
3. Capturas de las 3 pruebas de restricción del Paso 9, con su mensaje de error.
4. Una respuesta escrita (3-5 líneas): ¿qué columna del Caso 1 te costó más decidir el tipo de dato correcto, y por qué?

## CHECKLIST FINAL

- [ ] Ninguna columna de texto usa `VARCHAR(255)` sin justificación basada en datos reales.
- [ ] Los nombres con tildes/Ñ usan `NVARCHAR`, no `VARCHAR`.
- [ ] `PrecioUnitario` y `PrecioTotal` son `DECIMAL`, no `FLOAT`.
- [ ] Las 4 tablas con clave compuesta (`CLIENTE_TELEFONO`, `DETALLE_ORDEN`, y las 2 de hechos) tienen su `PRIMARY KEY` sobre las columnas correctas.
- [ ] Al menos un `CHECK` está grounded en un valor real observado en el CSV (no inventado).
- [ ] Los 2 índices están justificados por una consulta concreta, no "por si acaso".
- [ ] Las 3 pruebas de restricción del Paso 9 fallaron como se esperaba.

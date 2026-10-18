# MANUAL DE GITHUB PARA ESTUDIANTES
## Curso: Modelado y Diseño de Base de Datos — Universidad Autónoma del Perú

Este manual te explica, paso a paso y sin dar nada por sabido, cómo usar GitHub para entregar tus trabajos del curso durante las 16 semanas. Léelo una vez completo antes de tu primera entrega — después solo necesitas la sección **"Flujo semanal"** cada viernes.

**Repositorio del curso:** https://github.com/RubenCarty/Modelado_Base_Datos

---

## Índice

1. [¿Qué es un "fork" y por qué lo usamos?](#que-es-fork)
2. [Preparación (una sola vez, antes de tu primera entrega)](#preparacion)
3. [Flujo semanal (repetir cada semana, todos los viernes)](#flujo-semanal)
4. [Convención de nombres de carpeta](#convencion-nombres)
5. [Qué debes subir cada semana](#que-subir)
6. [Problemas comunes y cómo resolverlos](#problemas-comunes)
7. [Resumen de todos los comandos](#resumen-comandos)

---

## 1. ¿Qué es un "fork" y por qué lo usamos? {#que-es-fork}

El repositorio `RubenCarty/Modelado_Base_Datos` es el repositorio **del curso** — ahí el docente publica cada semana las guías, laboratorios y plantillas. Tú **no tienes permiso para escribir directamente ahí**.

Un **fork** es tu propia copia completa de ese repositorio, dentro de tu propia cuenta de GitHub. En TU fork sí puedes escribir libremente. El flujo es:

```
Repositorio del curso (RubenCarty/Modelado_Base_Datos)
        │
        │  1. Fork (una sola vez)
        ▼
Tu fork (TU_USUARIO/Modelado_Base_Datos)
        │
        │  2. Clone (una sola vez) — trae tu fork a tu computadora
        ▼
Tu computadora (carpeta local)
        │
        │  3. Edita tus archivos aquí, cada semana
        │  4. git add + commit + push → sube tus cambios a TU fork
        ▼
Tu fork actualizado
        │
        │  5. Pull Request → le avisas al docente que revise tu entrega
        ▼
El docente la revisa en el repositorio del curso
```

---

## 2. Preparación (una sola vez, antes de tu primera entrega) {#preparacion}

### 2.1 Crea tu cuenta de GitHub (si no tienes)

Ve a https://github.com/signup y crea una cuenta. Usa un correo que revises seguido — GitHub te manda ahí las confirmaciones.

### 2.2 Instala Git en tu computadora

**Mac:** abre Terminal y escribe `git --version`. Si no lo tienes, macOS te ofrece instalarlo automáticamente (acepta). Si usas Homebrew: `brew install git`.

**Windows:** descarga e instala Git desde https://git-scm.com/download/win (deja todas las opciones por defecto).

Verifica que quedó instalado:
```bash
git --version
```

### 2.3 Configura tu identidad en Git (una sola vez por computadora)

Git necesita saber quién eres para firmar tus entregas. Ejecuta esto reemplazando con tus datos reales:

```bash
git config --global user.name "Tu Nombre Completo"
git config --global user.email "tu-correo@gmail.com"
```

> Usa el **mismo correo** con el que te registraste en GitHub, para que tus commits se vean asociados a tu perfil.

### 2.4 Haz el Fork del repositorio del curso

1. Entra a https://github.com/RubenCarty/Modelado_Base_Datos (inicia sesión con tu cuenta primero).
2. Arriba a la derecha, clic en el botón **"Fork"**.
3. En la pantalla siguiente, deja el nombre tal cual (`Modelado_Base_Datos`) y clic en **"Create fork"**.
4. Espera unos segundos — ahora tienes tu propia copia en `https://github.com/TU_USUARIO/Modelado_Base_Datos`.

### 2.5 Clona TU fork a tu computadora

En GitHub, dentro de **TU fork** (no el del docente — revisa que la URL diga tu usuario), clic en el botón verde **`<> Code`** → pestaña **HTTPS** → copia la URL (algo como `https://github.com/TU_USUARIO/Modelado_Base_Datos.git`).

En Terminal, ubícate en la carpeta donde quieres guardar el curso y clona:

```bash
cd ~/Documents
git clone https://github.com/TU_USUARIO/Modelado_Base_Datos.git
cd Modelado_Base_Datos
```

Esto crea la carpeta `Modelado_Base_Datos` en tu computadora, con todo el contenido del repositorio.

### 2.6 Conecta tu fork con el repositorio original del curso ("upstream")

Esto es importante: el docente va a seguir publicando contenido nuevo cada semana en SU repositorio, y tú necesitas poder traer esas novedades a tu copia. Para eso, agregas el repositorio del curso como un segundo "remoto" llamado `upstream`:

```bash
git remote add upstream https://github.com/RubenCarty/Modelado_Base_Datos.git
```

Verifica que quedaron ambos remotos configurados:

```bash
git remote -v
```
Debes ver algo así:
```
origin    https://github.com/TU_USUARIO/Modelado_Base_Datos.git (fetch)
origin    https://github.com/TU_USUARIO/Modelado_Base_Datos.git (push)
upstream  https://github.com/RubenCarty/Modelado_Base_Datos.git (fetch)
upstream  https://github.com/RubenCarty/Modelado_Base_Datos.git (push)
```
- **`origin`** = tu fork (de aquí lees y aquí escribes tus entregas).
- **`upstream`** = el repositorio del docente (de aquí solo LEES las novedades de cada semana — nunca escribes ahí directamente).

**La preparación termina aquí. Todo esto se hace UNA SOLA VEZ, no se repite cada semana.**

---

## 3. Flujo semanal (repetir cada semana, todos los viernes) {#flujo-semanal}

### Paso 1 — Actualiza tu copia con el contenido nuevo del curso

Antes de empezar a trabajar cada semana, trae lo que el docente publicó (la carpeta `Semana_NN` nueva, por ejemplo):

```bash
cd ~/Documents/Modelado_Base_Datos
git fetch upstream
git checkout main
git merge upstream/main
```

Esto actualiza tu copia LOCAL con las novedades. Ahora súbelas también a tu fork en GitHub, para que todo quede sincronizado:

```bash
git push origin main
```

### Paso 2 — Crea (o ubica) tu carpeta personal de esa semana

Dentro de la carpeta de la semana correspondiente, hay una subcarpeta `Soluciones`. Ahí creas (solo la primera vez que entregas) tu carpeta personal con tu apellido paterno y tu nombre:

```bash
mkdir -p "Semana_05/Soluciones/Quispe_Ruben"
```
*(Reemplaza `Quispe_Ruben` por **tu** apellido paterno y tu nombre — ver la [convención de nombres](#convencion-nombres) abajo.)*

Para las semanas siguientes, solo cambias el número: `Semana_06/Soluciones/Quispe_Ruben`, `Semana_07/Soluciones/Quispe_Ruben`, etc. — usa siempre el mismo nombre de carpeta para que el docente te identifique igual todas las semanas.

### Paso 3 — Resuelve tus ejercicios localmente

Copia dentro de tu carpeta personal los archivos de la guía de esa semana (`SNN_GUIA_ESTUDIANTE_BD.md`, `SNN_LAB_CASA_BD.md`, `SNN_LAB_CLASE_BD.md`) y resuélvelos ahí — edítalos con cualquier editor (VS Code, el Bloc de notas, DBeaver para tus scripts `.sql`, etc.). Puedes trabajar con tu editor de texto normal; no necesitas hacer nada especial de Git mientras editas.

Ejemplo de cómo debería verse tu carpeta después de resolver la Semana 5:
```
Semana_05/Soluciones/Quispe_Ruben/
├── S05_GUIA_ESTUDIANTE_BD.md      (con tus respuestas)
├── S05_LAB_CASA_BD.md              (con tu desarrollo)
├── S05_LAB_CLASE_BD.md             (con tu desarrollo)
└── capturas/                       (opcional: tus capturas de pantalla)
```

### Paso 4 — Revisa qué cambiaste

```bash
git status
```
Debe mostrarte, en verde o en rojo, los archivos nuevos o modificados dentro de tu carpeta.

### Paso 5 — Sube tus cambios a TU fork (origin)

```bash
git add Semana_05/Soluciones/Quispe_Ruben
git commit -m "Entrega Semana 05 - Quispe Ruben"
git push origin main
```

> **`git add .`** (con un punto) agrega TODO lo que cambiaste en toda la carpeta — úsalo solo si estás seguro de que no hay nada más modificado por accidente (como un `.DS_Store`). Es más seguro escribir la ruta exacta de tu carpeta, como en el ejemplo de arriba.

Si Git te pide iniciar sesión, sigue las instrucciones en pantalla (se abre tu navegador para autorizar).

### Paso 6 — Abre un Pull Request para que el docente revise tu entrega

1. Ve a tu fork en GitHub: `https://github.com/TU_USUARIO/Modelado_Base_Datos`.
2. Si acabas de hacer `push`, GitHub suele mostrar un botón amarillo **"Compare & pull request"** — haz clic ahí. Si no aparece, ve a la pestaña **"Pull requests"** → **"New pull request"**.
3. Verifica que diga: base repository `RubenCarty/Modelado_Base_Datos` ← compare `TU_USUARIO/Modelado_Base_Datos`, ambos en la rama `main`.
4. En el título, escribe algo como: `Entrega Semana 05 - Quispe Ruben`.
5. Clic en **"Create pull request"**.

**Esto es lo que realmente cuenta como tu entrega.** Un `push` a tu fork sin Pull Request no le llega al docente.

Repite los Pasos 1 a 6 cada semana, cambiando solo el número de semana y el contenido que resuelves.

---

## 4. Convención de nombres de carpeta {#convencion-nombres}

Dentro de `Semana_NN/Soluciones/`, tu carpeta debe llamarse:

```
ApellidoPaterno_Nombre
```

- **Solo tu apellido paterno** (no el materno), seguido de guion bajo, seguido de **tu primer nombre**.
- Sin tildes, sin espacios, con la primera letra en mayúscula.
- **Exactamente el mismo nombre de carpeta todas las semanas** — no lo cambies de una semana a otra.

| Nombre completo del estudiante | Carpeta correcta |
|---|---|
| Rubén Quispe Llacctarimay | `Quispe_Ruben` |
| María Fernanda Torres Gómez | `Torres_Maria` |
| José Luis Pérez de la Cruz | `Perez_Jose` |

---

## 5. Qué debes subir cada semana {#que-subir}

Dentro de tu carpeta `Semana_NN/Soluciones/TuApellido_TuNombre/`, sube **los 3 archivos resueltos**:

| Archivo | Qué contiene |
|---|---|
| `SNN_GUIA_ESTUDIANTE_BD.md` | Tus respuestas a la guía de trabajo de esa semana |
| `SNN_LAB_CASA_BD.md` | Tu desarrollo completo del laboratorio en casa (código, capturas o enlaces a capturas, respuestas a las preguntas de análisis) |
| `SNN_LAB_CLASE_BD.md` | Lo que alcanzaste a resolver del laboratorio en clase |

*(Reemplaza `NN` por el número de semana: `S05`, `S06`, `S07`...)*

**Fecha límite: todos los viernes, antes de medianoche**, con tu Pull Request ya creado (no basta con el `push` a tu fork — recuerda el Paso 6).

---

## 6. Problemas comunes y cómo resolverlos {#problemas-comunes}

### "fatal: not a git repository"
Estás parado en la carpeta equivocada. Verifica con `pwd` (Mac) o `cd` (Windows) que estés DENTRO de la carpeta `Modelado_Base_Datos` que clonaste.

### `git push` te manda a una pantalla del navegador pidiendo un código
Es normal — es la verificación de identidad de GitHub. El código aparece **en tu Terminal**, no te llega por correo. Cópialo de ahí y pégalo en la página del navegador, luego clic en "Authorize".

### "Updates were rejected because the remote contains work that you do not have"
Alguien (tú mismo desde otra computadora, o una actualización del docente) modificó tu fork después de tu última copia local. Antes de volver a hacer `push`, trae esos cambios:
```bash
git pull origin main
git push origin main
```

### Conflicto al hacer `git merge upstream/main` (dos líneas marcadas con `<<<<<<<` y `>>>>>>>`)
Esto casi nunca debería pasarte si solo trabajas DENTRO de tu propia carpeta personal — los conflictos ocurren cuando dos personas editan EL MISMO archivo. Si te aparece:
1. Abre el archivo marcado en conflicto con tu editor.
2. Busca las marcas `<<<<<<< HEAD`, `=======`, `>>>>>>> upstream/main`.
3. Deja el contenido correcto (normalmente el de `upstream/main`, que es lo nuevo del curso) y borra las marcas.
4. Guarda el archivo y ejecuta:
```bash
git add nombre-del-archivo
git commit -m "Resueltos conflictos con upstream"
```

### Me equivoqué de carpeta y subí mis archivos en `Semana_06` en vez de `Semana_05`
```bash
git mv Semana_06/Soluciones/TuApellido_TuNombre Semana_05/Soluciones/TuApellido_TuNombre
git commit -m "Corrijo carpeta de entrega"
git push origin main
```

### Subí sin querer archivos que no debía (como `.DS_Store` o carpetas de otro compañero)
```bash
git rm --cached nombre-del-archivo-no-deseado
git commit -m "Elimino archivo que no correspondía"
git push origin main
```

### No sé si ya hice el Pull Request de esta semana
Entra a tu fork en GitHub → pestaña **"Pull requests"** → revisa si aparece uno con el título de la semana en cuestión.

---

## 7. Resumen de todos los comandos {#resumen-comandos}

### Preparación (una sola vez)
```bash
git config --global user.name "Tu Nombre Completo"
git config --global user.email "tu-correo@gmail.com"

git clone https://github.com/TU_USUARIO/Modelado_Base_Datos.git
cd Modelado_Base_Datos
git remote add upstream https://github.com/RubenCarty/Modelado_Base_Datos.git
```

### Cada semana (en este orden)
```bash
# 1. Actualizar con lo nuevo del curso
git fetch upstream
git checkout main
git merge upstream/main
git push origin main

# 2. Crear tu carpeta (solo la primera vez que entregas)
mkdir -p "Semana_NN/Soluciones/TuApellido_TuNombre"

# 3. (Edita tus archivos con tu editor normal — sin comandos de Git)

# 4. Revisar qué cambiaste
git status

# 5. Subir tu entrega
git add Semana_NN/Soluciones/TuApellido_TuNombre
git commit -m "Entrega Semana NN - TuApellido TuNombre"
git push origin main

# 6. Ir a GitHub y crear el Pull Request (no tiene comando — se hace en la web)
```

---

**¿Dudas?** Pregunta en clase o escribe al docente antes del viernes — no dejes tu primera entrega de Git para el último minuto, la configuración inicial (Sección 2) puede tomar su tiempo la primera vez.

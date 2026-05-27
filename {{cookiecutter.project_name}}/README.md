# {{cookiecutter.project_name}}

{{cookiecutter.description}}

## Estructura del proyecto

```
.
└── tf
    └── {{cookiecutter.project_name}}
        ├── environments
        │   ├── dev
        │   │   ├── compute
        │   │   │   └── terragrunt.hcl
        │   │   └── rds
        │   │       └── terragrunt.hcl
        │   └── ...
        ├── modules
        │   └── compute
        │       ├── imports.tf
        │       ├── locals.tf
        │       ├── main.tf
        │       ├── outputs.tf
        │       └── variables.tf
        ├── root.hcl
        └── shared
            └── inputs
                └── compute
                    └── example
```

## Configuración inicial

### 1. Instalar Terraform y Terragrunt

```bash
make install
```

Las versiones se definen en `.tf_version` y `.tg_version`.

### 2. Configurar variables de entorno

Crear la carpeta de ambiente y el archivo de credenciales:

```bash
make env-init ENVIRONMENT=dev
make env-init ENVIRONMENT=prod
```

Esto genera `.envs/.dev/.aws` o `.envs/.prod/.aws`. Edita el archivo con las credenciales correspondientes:

```dotenv
AWS_ACCESS_KEY_ID=AKIAXXXXXXXXXXXXXXXX
AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
AWS_DEFAULT_REGION=us-east-1
AWS_ACCOUNT_ID=XXXXXXXXXXXX
```

Luego genera el `.env` consolidado:

```bash
make env-merge ENVIRONMENT=dev
make env-merge ENVIRONMENT=prod
```

Ejecutar el siguiente comando para iniciar Terraform:

```bash
make init ENVIRONMENT=dev
make init ENVIRONMENT=prod
```

> **Nota:** El parámetro `ENVIRONMENT` debe especificarse en cada comando que interactúe con la infraestructura. Si se omite, se usará `dev` como valor por defecto.

### 3. Instalar pre-commit hooks

```bash
make pre-commit
```

---

## Uso

### Comandos principales de infraestructura

Todos los comandos que interactúan con infraestructura requieren `ENVIRONMENT`. Los comandos de módulo individual también requieren `MODULE`.

**Módulos disponibles:** `compute`, `rds`

| Comando | Descripción | Ejemplo |
|---------|-------------|---------|
| `make init ENVIRONMENT=<env>` | Inicializa todos los módulos con Terragrunt | `make init ENVIRONMENT=dev` |
| `make init-upgrade ENVIRONMENT=<env>` | Ejecuta `terraform init -upgrade` | `make init-upgrade ENVIRONMENT=prod` |
| `make plan ENVIRONMENT=<env> MODULE=<module>` | Muestra los cambios a aplicar | `make plan ENVIRONMENT=dev MODULE=compute` |
| `make apply ENVIRONMENT=<env> MODULE=<module>` | Aplica cambios en un módulo específico | `make apply ENVIRONMENT=dev MODULE=compute` |
| `make destroy ENVIRONMENT=<env> MODULE=<module>` | Destruye un módulo específico | `make destroy ENVIRONMENT=dev MODULE=compute` |
| `make destroy-all ENVIRONMENT=<env>` | Destruye toda la infraestructura del ambiente | `make destroy-all ENVIRONMENT=dev` |
| `make state ENVIRONMENT=<env> MODULE=<module>` | Lista los recursos en el state | `make state ENVIRONMENT=dev MODULE=compute` |
| `make outputs ENVIRONMENT=<env>` | Muestra los outputs de todos los módulos | `make outputs ENVIRONMENT=prod` |
| `make outputs-private-keys ENVIRONMENT=<env>` | Exporta llaves privadas del módulo `compute` a `.pems/` | `make outputs-private-keys ENVIRONMENT=dev` |
| `make force-unlock ENVIRONMENT=<env> MODULE=<module> ID=<lock-id>` | Libera un lock de estado bloqueado | `make force-unlock ENVIRONMENT=dev MODULE=compute ID=abc123` |

### Comandos auxiliares

| Comando | Descripción |
|---------|-------------|
| `make install` | Descarga Terraform y Terragrunt en versiones definidas en `.tf_version` / `.tg_version` |
| `make fmt` | Formatea archivos `.tf` recursivamente |
| `make ci-fmt` | Verifica formato sin modificar (para pipelines CI/CD) |
| `make validate` | Valida la configuración en todos los ambientes vía script |
| `make lint` | Ejecuta `fmt` y luego pre-commit en todos los archivos |
| `make pre-commit` | Instala y configura los hooks de pre-commit |
| `make env-init ENVIRONMENT=<env>` | Crea la carpeta de ambiente con template de variables |
| `make env-merge ENVIRONMENT=<env>` | Genera el `.env` a partir de los `.envs` del ambiente |
| `make tf-shell ENVIRONMENT=<env>` | Abre una shell dentro del directorio `tf/` con las variables cargadas |
| `make help` | Muestra todos los comandos disponibles del Makefile |

---

## Git Flow y buenas prácticas

### Rama principal

Todos los cambios de infraestructura se integran a la rama **`develop`**. No se hacen commits directamente a `develop`; los cambios llegan únicamente a través de Pull Requests desde ramas de trabajo.

### Antes de iniciar cualquier cambio

Siempre sincroniza tu rama local con los últimos cambios de `develop` antes de comenzar:

```bash
git pull origin develop
```

### Nomenclatura de ramas

Las ramas deben seguir la siguiente convención:

```
<tipo>/<proyecto-o-ticket>-<modulo-o-descripcion>
```

**Tipos permitidos:**

| Tipo | Uso |
|------|-----|
| `feat/` | Nueva funcionalidad o recurso de infraestructura |
| `fix/` | Corrección de un error o configuración incorrecta |
| `refactor/` | Reestructuración de módulos sin cambio funcional |

**Ejemplos:**

```bash
git checkout -b feat/mi-proyecto-networking
git checkout -b feat/mi-proyecto-rds
```

### Flujo de trabajo

```bash
# 1. Sincronizar con develop
git pull origin develop

# 2. Crear tu rama de trabajo
git checkout -b feat/<proyecto>-<descripcion>

# 3. Hacer tus cambios, validar y formatear
make fmt
make validate

# 4. Commit con mensaje descriptivo
git add .
git commit -m "feat(compute): descripción del cambio"

# 5. Push de la rama
git push origin feat/<proyecto>-<descripcion>

# 6. Abrir Pull Request hacia develop
```

### Buenas prácticas generales

- **Nunca apliques cambios sin antes ejecutar `make plan`** y revisar el output completo.
- **Un módulo a la vez:** usa `MODULE=` para aplicar cambios de forma controlada en lugar de `destroy-all` o `run --all apply`.
- **Mensajes de commit claros:** usa el formato `tipo(modulo): descripción breve` para mantener un historial legible.
- **No commits directos a `develop`:** todo cambio debe pasar por una rama y un Pull Request con al menos una revisión.
- **Mantén el `.env` fuera del repositorio:** el archivo `.env` y la carpeta `.envs/` están en `.gitignore`; nunca los agregues al índice de git.
- **Valida antes de hacer push:** los hooks de pre-commit (`make lint`) se ejecutan automáticamente, pero también puedes correrlos manualmente.

### Evitar hacer esto

- **No cambiar el nombre de las carpetas de los módulos**, esto afectará el state.
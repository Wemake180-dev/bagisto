# Flujo de Trabajo Git - Proyecto Bagisto

## Descripción General

Este documento describe el flujo de trabajo para el desarrollo y despliegue del proyecto Bagisto, manteniendo sincronización con el repositorio upstream y permitiendo múltiples despliegues.

## Estructura de Repositorios

```
Repositorios:
├── upstream: https://github.com/bagisto/bagisto.git (Repositorio original)
└── origin: https://github.com/Wemake180-dev/bagisto.git (Tu fork)
```

## Estructura de Ramas

```
2.3 (base principal)
├── develop (desarrollo y features)
└── deploy-lucella (despliegue producción)
```

### Descripción de Ramas

-   **`2.3`**: Rama base sincronizada con upstream, equivalente a `main`
-   **`develop`**: Rama de desarrollo donde se integran nuevos features
-   **`deploy-lucella`**: Rama específica para despliegue en producción

## Configuración Inicial

### Verificar remotos configurados:

```bash
git remote -v
# Debería mostrar:
# origin    https://github.com/Wemake180-dev/bagisto.git (fetch)
# origin    https://github.com/Wemake180-dev/bagisto.git (push)
# upstream  https://github.com/bagisto/bagisto.git (fetch)
# upstream  https://github.com/bagisto/bagisto.git (push)
```

### Si necesitas añadir upstream:

```bash
git remote add upstream https://github.com/bagisto/bagisto.git
```

## Flujos de Trabajo

### 1. Actualización desde Upstream

**Frecuencia recomendada**: Semanal o antes de iniciar nuevos desarrollos

```bash
# 1. Actualizar rama base desde upstream
git checkout 2.3
git pull upstream 2.3
git push origin 2.3

# 2. Actualizar rama de desarrollo
git checkout develop
git rebase 2.3
# Si hay conflictos, resolverlos y continuar:
# git add .
# git rebase --continue
git push origin develop --force-with-lease
```

### 2. Desarrollo de Nuevos Features

```bash
# 1. Crear nueva rama de feature desde develop
git checkout develop
git pull origin develop
git checkout -b feature/nombre-del-feature

# 2. Desarrollar el feature
# ... hacer cambios ...
git add .
git commit -m "feat: descripción del feature"

# 3. Actualizar develop y rebase si es necesario
git checkout develop
git pull origin develop
git checkout feature/nombre-del-feature
git rebase develop

# 4. Merge a develop
git checkout develop
git merge feature/nombre-del-feature
git push origin develop

# 5. Limpiar rama de feature
git branch -d feature/nombre-del-feature
```

### 3. Actualización de Despliegues

**Solo cuando develop esté estable y probado**

```bash
# 1. Actualizar despliegue desde develop
git checkout deploy-lucella
git pull origin deploy-lucella
git merge develop

# 2. Aplicar configuraciones específicas de producción si es necesario
# ... modificaciones específicas del entorno ...
git add .
git commit -m "config: ajustes específicos para producción"

# 3. Subir cambios
git push origin deploy-lucella
```

## Comandos Útiles

### Verificar estado de ramas:

```bash
git branch -a  # Ver todas las ramas
git status     # Estado actual
git log --oneline --graph --all  # Historial visual
```

### Resolver conflictos durante rebase:

```bash
# Si hay conflictos durante rebase:
git status  # Ver archivos en conflicto
# Editar archivos y resolver conflictos
git add .
git rebase --continue

# Si quieres cancelar el rebase:
git rebase --abort
```

### Comparar ramas:

```bash
git diff 2.3..develop        # Diferencias entre base y desarrollo
git diff develop..deploy-lucella  # Diferencias entre desarrollo y despliegue
```

## Crear Nuevos Despliegues

Para crear un nuevo despliegue (ej: deploy-cliente-2):

```bash
git checkout develop
git checkout -b deploy-cliente-2
git push origin deploy-cliente-2
```

## Buenas Prácticas

### Commits

-   Usar mensajes descriptivos
-   Formato recomendado: `tipo: descripción breve`
-   Tipos: `feat`, `fix`, `config`, `update`, `refactor`

### Ejemplo:

```bash
git commit -m "feat: añadir módulo de pagos personalizados"
git commit -m "fix: corregir error en carrito de compras"
git commit -m "config: configuración para producción Lucella"
```

### Sincronización

-   **Nunca hacer push directo a `2.3`** sin sincronizar con upstream primero
-   **Siempre probar en `develop`** antes de llevar a producción
-   **Usar `--force-with-lease`** en lugar de `--force` para pushes seguros

### Resolución de Conflictos

-   Resolver conflictos inmediatamente
-   Probar después de resolver conflictos
-   Comunicar cambios importantes al equipo

## Troubleshooting

### Error: "Your branch is behind"

```bash
git pull origin nombre-de-rama
# O si prefieres rebase:
git pull --rebase origin nombre-de-rama
```

### Error: "Merge conflicts"

```bash
# Ver archivos en conflicto
git status

# Editar archivos manualmente o usar herramienta
git mergetool

# Finalizar merge
git add .
git commit
```

### Deshacer último commit (si no se ha pusheado):

```bash
git reset --soft HEAD~1  # Mantiene cambios en staging
git reset --hard HEAD~1  # Elimina cambios completamente
```

## Contacto y Soporte

Para dudas sobre este flujo de trabajo, contactar al equipo de desarrollo.

---

**Última actualización**: $(date)
**Versión del documento**: 1.0

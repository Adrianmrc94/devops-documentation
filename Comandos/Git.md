# 🌿 Comandos esenciales de Git

---

## 🆕 Configuración inicial (una vez por máquina)

| Acción | Comando |
|--------|---------|
| Establecer nombre | `git config --global user.name "Tu Nombre"` |
| Establecer email | `git config --global user.email "tu@mail.com"` |
| Editor por defecto | `git config --global core.editor nano` |
| Ver configuración | `git config --list` |

---

## 📂 Repositorios

| Acción | Comando |
|--------|---------|
| Clonar por HTTPS | `git clone https://github.com/user/repo.git` |
| Clonar por SSH | `git clone git@github.com:user/repo.git` |
| Inicializar repo local | `git init` |

---

## 🕒 Estado e historial

| Acción | Comando |
|--------|---------|
| Estado del working tree | `git status` |
| Ver logs | `git log --oneline` |
| Ver logs gráfico | `git log --graph --all --oneline` |
| Ver diferencias | `git diff` |
| Ver diferencias staged | `git diff --staged` |

---

## 📁 Ramas

| Acción | Comando |
|--------|---------|
| Listar ramas | `git branch` |
| Listar ramas remotas | `git branch -r` |
| Crear rama | `git branch nueva-rama` |
| Cambiar de rama | `git switch nueva-rama` |
| Crear y cambiar | `git switch -c nueva-rama` |
| Renombrar rama actual | `git branch -m nuevo-nombre` |
| Eliminar rama local | `git branch -d nueva-rama` |
| Eliminar rama remota | `git push origin --delete nueva-rama` |

---

## ➕ Staging y commits

| Acción | Comando |
|--------|---------|
| Añadir archivo | `git add archivo.txt` |
| Añadir todos (tracked y untracked) | `git add -A` |
| Añadir por partes (interactivo) | `git add -p` |
| Commit | `git commit -m "Mensaje del commit"` |
| Commit con add incluido | `git commit -a -m "Mensaje"` |
| Amend último commit | `git commit --amend -m "Nuevo mensaje"` |

---

## 🚀 Push & Pull

| Acción | Comando |
|--------|---------|
| Push rama actual | `git push` |
| Push rama nueva | `git push -u origin nueva-rama` |
| Pull cambios | `git pull` |
| Fetch (sin merge) | `git fetch` |

---

## 🔄 Stash (guardar cambios temporalmente)

| Acción | Comando |
|--------|---------|
| Guardar cambios | `git stash push -m "descripción"` |
| Listar stashes | `git stash list` |
| Aplicar último stash | `git stash pop` |
| Aplicar sin borrar | `git stash apply stash@{0}` |
| Borrar stash | `git stash drop stash@{0}` |

---

## 🔙 Deshacer cambios

| Acción | Comando |
|--------|---------|
| Descartar cambios en archivo | `git checkout -- archivo.txt` |
| Deshacer commit (conservar cambios) | `git reset --soft HEAD~1` |
| Deshacer commit (descartar cambios) | `git reset --hard HEAD~1` |
| Revertir commit público | `git revert HEAD` |

---

## 🏷️ Tags

| Acción | Comando |
|--------|---------|
| Crear tag ligero | `git tag v1.0.0` |
| Crear tag anotado | `git tag -a v1.0.0 -m "Versión 1.0.0"` |
| Push tag al remoto | `git push origin v1.0.0` |
| Push todos los tags | `git push origin --tags` |
| Listar tags | `git tag` |

---

## 🔥 Comandos avanzados

| Acción | Comando |
|--------|---------|
| Ver historial de un archivo | `git log --follow archivo.txt` |
| Buscar en commits | `git log --grep="texto"` |
| Ver cambios entre ramas | `git diff rama1..rama2` |
| Rebase interactivo | `git rebase -i HEAD~3` |
| Cherry-pick commit | `git cherry-pick abc123` |
| Bisect (buscar bug) | `git bisect start` → `git bisect bad` → `git bisect good abc123` |
| Ver quien modificó cada línea | `git blame archivo.txt` |
| Crear patch | `git format-patch -1 HEAD` |
| Aplicar patch | `git apply parche.patch` |
| Submodules | `git submodule add https://github.com/user/repo.git path` |

---

## 🌐 Trabajo colaborativo

| Acción | Comando |
|--------|---------|
| Fetch específico | `git fetch origin rama-especifica` |
| Merge sin fast-forward | `git merge --no-ff rama` |
| Squash merge | `git merge --squash rama` |
| Rebase en vez de merge | `git pull --rebase` |
| Push forzado (cuidado) | `git push --force-with-lease` |
| Ver ramas merged | `git branch --merged` |
| Ver ramas no merged | `git branch --no-merged` |

---

## 🔍 Investigación y análisis

| Acción | Comando |
|--------|---------|
| Ver estadísticas | `git shortlog -sn` |
| Archivos más cambiados | `git log --stat --oneline | head -20` |
| Tamaño del repositorio | `git count-objects -vH` |
| Limpiar objetos | `git gc --prune=now` |
| Ver configuración actual | `git config --list --show-origin` |

---

## 🌙 Aliases útiles (configurar una vez)

```bash
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'
git config --global alias.tree 'log --graph --pretty=format:"%h %s" --abbrev-commit'
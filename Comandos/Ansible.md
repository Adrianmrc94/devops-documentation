# 🅰️ Comandos esenciales de Ansible

---

## 🔧 Instalación rápida

| Acción | Comando |
|--------|---------|
| Instalar ansible-core (Debian) | `sudo apt update && sudo apt install ansible-core` |
| Instalar vía pip | `python3 -m pip install --user ansible-core` |
| Ver versión | `ansible --version` |
| Completado bash (opcional) | `source &lt;(ansible-completion bash)` |

---

## 📁 Estructura básica

| Acción | Comando |
|--------|---------|
| Crear esqueleto de rol | `ansible-galaxy init mi-rol` |
| Crear proyecto estándar | `ansible-galaxy init --type project mi-proyecto` |
| Instalar rol de Galaxy | `ansible-galaxy install geerlingguy.nginx` |
| Listar roles locales | `ansible-galaxy list` |

---

## 🔍 Inventario y ping

| Acción | Comando |
|--------|---------|
| Inventario inline | `ansible -i "192.168.x.x," all -m ping` |
| Inventario archivo | `ansible -i inventario.ini all -m ping` |
| Usar usuario distinto | `ansible -i inventario.ini all -m ping -u deploy` |
| Clave privada explícita | `ansible -i inventario.ini all -m ping --key-file=~/.ssh/id_rsa` |

---

## 📦 Módulos imprescindibles (ad-hoc)

| Acción | Comando |
|--------|---------|
| Actualizar paquetes | `ansible all -b -m apt -a "update_cache=yes upgrade=dist"` |
| Instalar nginx | `ansible all -b -m apt -a "name=nginx state=present"` |
| Arrancar servicio | `ansible all -b -m service -a "name=nginx state=started enabled=yes"` |
| Copiar archivo | `ansible all -m copy -a "src=index.html dest=/var/www/html/index.html"` |
| Crear usuario | `ansible all -b -m user -a "name=app uid=5000 shell=/bin/bash"` |

---

## ▶️ Playbooks

| Acción | Comando |
|--------|---------|
| Sintaxis check | `ansible-playbook --syntax-check site.yml` |
| Dry-run (modo chequeo) | `ansible-playbook --check site.yml` |
| Ejecutar playbook | `ansible-playbook site.yml` |
| Ejecutar solo tags | `ansible-playbook site.yml --tags "nginx"` |
| Skip tags | `ansible-playbook site.yml --skip-tags "debug"` |
| Vault password file | `ansible-playbook site.yml --vault-password-file .vault_pass` |

---

## 🔐 Ansible Vault

| Acción | Comando |
|--------|---------|
| Crear archivo cifrado | `ansible-vault create secretos.yml` |
| Editar archivo cifrado | `ansible-vault edit secretos.yml` |
| Descifrar en línea | `ansible-vault decrypt secretos.yml` |
| Re-cifrar | `ansible-vault encrypt secretos.yml` |
| Cambiar password | `ansible-vault rekey secretos.yml` |

---

## 🧪 Testing & linting

| Acción | Comando |
|--------|---------|
| Lint de playbooks/roles | `ansible-lint` |
| Ver diffs antes de aplicar | `ansible-playbook site.yml --diff --check` |
| Ejecución paralela (25 forks) | `ansible-playbook site.yml -f 25` |

---

## 📝 Ejemplos de Playbooks útiles

| Tarea | Playbook ejemplo |
|-------|------------------|
| Instalar Docker | `- name: Install Docker`<br>`  apt: name=docker.io state=present`<br>`  become: yes` |
| Copiar y ejecutar script | `- name: Deploy script`<br>`  copy: src=script.sh dest=/tmp/`<br>`- shell: /tmp/script.sh` |
| Crear usuario | `- name: Add user`<br>`  user: name=deploy shell=/bin/bash groups=sudo` |
| Template con variables | `- name: Config file`<br>`  template: src=config.j2 dest=/etc/app/config` |

---

## 🎯 Mejores prácticas

| Práctica | Comando/Ejemplo |
|----------|-----------------|
| Dry run antes de ejecutar | `ansible-playbook --check --diff site.yml` |
| Usar variables de grupo | `group_vars/all.yml` y `host_vars/hostname.yml` |
| Handlers para servicios | `notify: restart nginx` |
| Condicionales | `when: ansible_os_family == "Debian"` |
| Loops | `with_items:` o `loop:` |
| Tags específicos | `tags: [nginx, webserver]` |
| Validar sintaxis | `ansible-playbook --syntax-check site.yml` |

---

## 🔧 Troubleshooting

| Problema | Solución |
|----------|----------|
| Conexión SSH falla | `ansible all -m ping -vvv` (verbose) |
| Permisos sudo | `ansible-playbook --ask-become-pass site.yml` |
| Variables no definidas | `ansible-playbook --extra-vars "var=value" site.yml` |
| Host key verification | `export ANSIBLE_HOST_KEY_CHECKING=False` |

---

## 🧹 Limpieza de hechos caché

| Acción | Comando |
|--------|---------|
| Limpiar fact-cache de un host | `ansible-inventory -i inventario.ini --flush-cache` |
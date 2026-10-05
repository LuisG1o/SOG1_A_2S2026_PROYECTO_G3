# Guía de Restauración de Base de Datos e Imágenes - Raíz Artesanal ERP (Fase 2)

Este respaldo contiene los **30 productos catalogados**, **imágenes**, existencias iniciales en almacén, **6 proveedores** y **7 clientes** registrados para la empresa **Raíz Artesanal**.

> **Nota importante:** Este procedimiento inyecta la base de datos directamente en PostgreSQL y restaura el almacenamiento de archivos, por lo que **no solicita el Master Password** de Odoo en ningún momento.

---

## Prerrequisitos

1. Tener los contenedores de Docker encendidos.
2. Verifica en la terminal de tu Ubuntu Server los nombres exactos de tus dos contenedores ejecutando:
   ```bash
   sudo docker ps
   ```
   *(Identifica en la columna `NAMES` cómo se llama tu contenedor de **postgres** [ej. `odoo-erp_db_1`] y tu contenedor de **odoo** [ej. `odoo-erp_web_1` o su `CONTAINER ID`]).*

---

## Procedimiento de Restauración (Desde Ubuntu Server)

### 1. Clonar la rama `develop` del repositorio

Entra a la terminal de tu máquina virtual Ubuntu Server y descarga los archivos del repositorio:

```bash
cd ~
git clone -b develop [https://github.com/Normis77/Geren1_Proyecto1_G3.git](https://github.com/Normis77/Geren1_Proyecto1_G3.git)
cd Geren1_Proyecto1_G3
```

---

### 2. Restaurar la Base de Datos en PostgreSQL

1. Copia el archivo `.dump` dentro del contenedor de base de datos:
   ```bash
   sudo docker cp backup_raiz_artesanal.dump odoo-erp_db_1:/tmp/backup_raiz_artesanal.dump
   ```

2. Crea la base de datos de destino `raiz_artesanal_db`:
   ```bash
   sudo docker exec -t odoo-erp_db_1 createdb -U odoo raiz_artesanal_db
   ```
   > *(Si ya tenías una base de datos con ese nombre, elimínala antes con: `sudo docker exec -t odoo-erp_db_1 dropdb -U odoo raiz_artesanal_db`)*

3. Ejecuta la restauración binaria:
   ```bash
   sudo docker exec -t odoo-erp_db_1 pg_restore -U odoo -d raiz_artesanal_db -v /tmp/backup_raiz_artesanal.dump
   ```
   *(Es normal que al final muestre `WARNING: errors ignored on restore` por permisos del rol postgres; todas las tablas se cargan al 100%).*

---

### 3. Restaurar las Imágenes del Catálogo (Filestore)

Para que todos los productos e iconos muestren sus fotografías en la interfaz web:

1. Descomprime el archivo de imágenes:
   ```bash
   tar -xzf filestore_backup.tar.gz
   ```

2. Copia la carpeta de imágenes dentro del contenedor web de Odoo (reemplaza `odoo-erp_web_1` por el nombre o `CONTAINER ID` de tu contenedor de Odoo que viste en `sudo docker ps`[cite: 6, 8]) y asigna permisos:
   ```bash
   sudo docker cp filestore_backup/. odoo-erp_web_1:/var/lib/odoo/filestore/
   sudo docker exec -u root -t odoo-erp_web_1 chown -R odoo:odoo /var/lib/odoo/filestore
   ```

---

### 4. Acceso al Sistema

1. Ingresa desde el navegador web a:  
   `http://localhost:8069/web/database/selector`
2. Selecciona la base de datos **`raiz_artesanal_db`**.
3. Inicia sesión con las credenciales de administrador:
   * **Correo:** `normacanu77@gmail.com`
   * **Password:** `Admin2026*`
4. Verifica en **Inventario -> Productos** que los 30 productos (`RA-001` a `RA-030`) aparezcan con sus fotografías y existencias, así como los proveedores en **Compra** y los clientes en **Ventas**.
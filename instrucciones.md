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

### 1. Clonar el repositorio

Entra a la terminal de tu máquina virtual Ubuntu Server y descarga los archivos del repositorio:

```bash
cd ~
git clone https://github.com/LuisG1o/SOG1_A_2S2026_PROYECTO_G3.git
cd SOG1_A_2S2026_PROYECTO_G3
```

---

### 2. Restaurar la Base de Datos en PostgreSQL

1. Copia el archivo `.dump` dentro del contenedor de base de datos:
   ```bash
   sudo docker cp Base_de_Datos/backup_raiz_artesanal.dump odoo-erp_db_1:/tmp/backup_raiz_artesanal.dump
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
   tar -xzf Base_de_Datos/filestore_backup.tar.gz
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

---

## Base de datos final de la Fase 2

Los archivos `Base_de_Datos/backup_raiz_artesanal_final.dump` y `Base_de_Datos/filestore_final.tar.gz` contienen el sistema completo de la Fase 2: datos maestros, compras (BO00002, P00025 a P00028), ventas (S00025 y S00026), factura INV/2026/00005, CRM con 5 oportunidades y las 2 campañas de correo enviadas. La empresa está configurada como **Raíz Artesanal** con su logotipo.

Se restaura con los mismos pasos 2 y 3 anteriores, usando estos archivos:

```bash
sudo docker compose up -d
sudo docker cp Base_de_Datos/backup_raiz_artesanal_final.dump odoo-erp_db_1:/tmp/final.dump
sudo docker exec -t odoo-erp_db_1 dropdb -U odoo --if-exists raiz_artesanal_db
sudo docker exec -t odoo-erp_db_1 createdb -U odoo raiz_artesanal_db
sudo docker exec -t odoo-erp_db_1 pg_restore -U odoo -d raiz_artesanal_db --no-owner /tmp/final.dump
tar -xzf Base_de_Datos/filestore_final.tar.gz
sudo docker cp filestore_backup/. odoo-erp_web_1:/var/lib/odoo/filestore/
sudo docker exec -u root -t odoo-erp_web_1 chown -R odoo:odoo /var/lib/odoo/filestore
```

Los correos de las campañas se envían al servidor de pruebas **Mailpit** (servicio `mailpit` del `docker-compose.yml`). La bandeja se revisa en `http://localhost:8025`.
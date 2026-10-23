# Guía de Instalación y Restauración - Raíz Artesanal

Este procedimiento levanta el sistema completo del proyecto (Fases 1, 2 y 3) a partir de los respaldos de la carpeta `Base_de_Datos`:

| Archivo | Contenido |
|---|---|
| `backup_raiz_artesanal_fase3.dump` | Base de datos de Odoo: 30 productos, proveedores, clientes, compras, ventas, facturas, CRM, campañas de correo, tienda en línea con 5 ventas en línea (S00027 a S00031), conteo físico de inventario y encuesta de satisfacción |
| `filestore_fase3.tar.gz` | Imágenes de los productos, logotipo y adjuntos |
| `metabase_fase3.dump` | Preguntas y tableros de Business Intelligence en Metabase |

> **Nota:** la base se carga directamente en PostgreSQL, por lo que no se solicita el Master Password de Odoo.

---

## 1. Clonar el repositorio y levantar los contenedores

```bash
cd ~
git clone https://github.com/LuisG1o/SOG1_A_2S2026_PROYECTO_G3.git
cd SOG1_A_2S2026_PROYECTO_G3
sudo docker compose -p odoo-erp up -d db web mailpit
sudo docker ps
```

En la columna `NAMES` se identifican el contenedor de PostgreSQL (`odoo-erp_db_1` u `odoo-erp-db-1`, según la versión de Docker Compose) y el de Odoo (`odoo-erp_web_1` u `odoo-erp-web-1`). Los comandos siguientes usan los primeros nombres; se reemplazan si en el equipo aparecen los otros.

---

## 2. Restaurar la base de datos de Odoo

```bash
sudo docker cp Base_de_Datos/backup_raiz_artesanal_fase3.dump odoo-erp_db_1:/tmp/fase3.dump
sudo docker exec -t odoo-erp_db_1 dropdb -U odoo --if-exists raiz_artesanal_db
sudo docker exec -t odoo-erp_db_1 createdb -U odoo raiz_artesanal_db
sudo docker exec -t odoo-erp_db_1 pg_restore -U odoo -d raiz_artesanal_db --no-owner /tmp/fase3.dump
```

Es normal que al final aparezca `WARNING: errors ignored on restore` por permisos del rol de PostgreSQL; las tablas se cargan completas.

---

## 3. Restaurar las imágenes (filestore)

```bash
tar -xzf Base_de_Datos/filestore_fase3.tar.gz
sudo docker cp filestore_backup/. odoo-erp_web_1:/var/lib/odoo/filestore/
sudo docker exec -u root -t odoo-erp_web_1 chown -R odoo:odoo /var/lib/odoo/filestore
sudo docker restart odoo-erp_web_1
```

---

## 4. Acceso al sistema

| Servicio | Dirección |
|---|---|
| Odoo (ERP y CRM) | `http://localhost:8069` (base `raiz_artesanal_db`) |
| Tienda en línea | `http://localhost:8069/shop` |
| Bandeja de correos de prueba (Mailpit) | `http://localhost:8025` |
| Business Intelligence (Metabase) | `http://localhost:3000` |

Usuario administrador de Odoo:

* **Correo:** `normacanu77@gmail.com`
* **Password:** `Admin2026*`

En **Inventario → Productos** deben aparecer los 30 productos (`RA-001` a `RA-030`) con sus fotografías y existencias.

### Clientes de prueba de la tienda

| Cliente | Usuario | Contraseña |
|---|---|---|
| Andrea Lucía Barrios | andrea.barrios@ejemplo.gt | RaizPrueba2026! |
| Diego Alejandro Ramírez | diego.ramirez@ejemplo.gt | RaizPrueba2026! |
| Gabriela Sofía Herrera | gabriela.herrera@ejemplo.gt | RaizPrueba2026! |
| Mariana Ruiz Estrada | mariana.ruiz@ejemplo.gt | RaizPrueba2026! |
| Lucía Morales (Hotel Real Santa Catalina) | lucia.morales@hotelsantacatalina.gt | RaizPrueba2026! |

Para pagar con tarjeta en la tienda se usa el método de prueba con cualquier número, por ejemplo `4111 1111 1111 1111`.

---

## 5. Business Intelligence (Metabase)

Metabase consulta la base `raiz_artesanal_db` mediante las vistas del esquema `bi` (`Fase_3/BI/sql/vistas_bi.sql`) y guarda sus preguntas y tableros en la base `metabase`.

```bash
# Usuario de solo lectura para BI (definir una contraseña propia)
sudo docker exec -it odoo-erp_db_1 psql -U odoo -d raiz_artesanal_db -c "CREATE ROLE bi_lectura LOGIN PASSWORD '<contraseña>';"

# Vistas y permisos del esquema bi
sudo docker cp Fase_3/BI/sql/vistas_bi.sql odoo-erp_db_1:/tmp/vistas_bi.sql
sudo docker exec -t odoo-erp_db_1 psql -U odoo -d raiz_artesanal_db -f /tmp/vistas_bi.sql

# Base de Metabase con los tableros
sudo docker cp Base_de_Datos/metabase_fase3.dump odoo-erp_db_1:/tmp/metabase.dump
sudo docker exec -t odoo-erp_db_1 createdb -U odoo metabase
sudo docker exec -t odoo-erp_db_1 pg_restore -U odoo -d metabase --no-owner /tmp/metabase.dump

# Levantar Metabase
sudo docker compose -p odoo-erp up -d metabase
```

1. Ingresar a `http://localhost:3000` con el usuario administrador del equipo.
2. En **Configuración → Bases de datos → Raíz Artesanal - Odoo** escribir la contraseña del usuario `bi_lectura` y guardar. Por seguridad, el respaldo de Metabase no incluye esa contraseña.
3. Abrir la colección **Raíz Artesanal – BI**: Reporte de Inventario, Reporte de Ventas y Tablero de Control Gerencial.

---

## 6. Operación

- Encender o apagar el sistema: `sudo docker compose -p odoo-erp start` / `sudo docker compose -p odoo-erp stop`. No usar `down`, porque elimina los contenedores.
- Para importar archivos Excel desde Odoo, instalar una vez la librería en el contenedor: `sudo docker exec -u root odoo-erp_web_1 pip3 install openpyxl` y reiniciarlo.
- Los KPIs se pueden recalcular en cualquier momento con `python Fase_3/KPIs/verificar_kpis.py`.

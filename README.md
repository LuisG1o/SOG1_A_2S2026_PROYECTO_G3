# Transformación Digital en E-Commerce con ERP, CRM y BI – QuetzalDev

---

**Grupo:** 3 - SISTEMAS ORGANIZACIONES Y GERENCIALES 1
**Período:** Segundo Semestre 2026
**Empresa:** Raíz Artesanal – comercialización de artesanía guatemalteca (textiles, cerámica, jade, cuero y cestería)

---

## Equipo de Desarrollo:

| Nombre | Carné |
|-------|--------|
| Luis Fernando Gonzalez | 202307727 |
| Norma Elizabeth Canú Xico | 202300768 |
| Carlos Javier Pérez Pocón | 202206425 |
| Eduardo Misael López Avila | 202100147 |

---

## Entregables

| Fase | Carpeta | Contenido |
|------|---------|-----------|
| Fase 1 – Planificación y diagnóstico | [`Entregables/Fase 1`](Entregables/Fase%201) | Informe ejecutivo, manuales de instalación del ERP y CRM, diagrama del ciclo de compra, presentación y enlace del video |
| Fase 2 – Configuración y operación base | [`Entregables/Fase 2`](Entregables/Fase%202) | Informe consolidado, manuales de usuario, medición de logros, archivos de datos y enlace del video |

## Estructura del repositorio

| Carpeta / archivo | Descripción |
|-------------------|-------------|
| `Entregables/` | Documentos entregados en cada fase |
| `Fase_2/Documento_Final/` | Informe consolidado de la Fase 2 (Word y PDF) |
| `Fase_2/Datos_Maestros/` | Plantillas Excel de productos, clientes y proveedores y su manual de carga |
| `Fase_2/Compras_Abastecimiento/` | Manual y capturas del ciclo de compras (requisición, orden de compra y recepción) |
| `Fase_2/Cotizaciones_y_Reportes/` | Manuales y capturas de cotizaciones, ventas, informes de inventario y medición de logros |
| `Fase_2/CRM_Correos/` | Manual y capturas del pipeline CRM, plantillas de correo y campañas |
| `Fase_3/` | Trabajo de la Fase 3: tienda en línea, integración, BI y documento final |
| `Base_de_Datos/` | Respaldos de la base de datos de Odoo y del filestore (imágenes) |
| `imagenes/` | Fotografías de los productos y logotipo de la marca |
| `docker-compose.yml` | Servicios de Odoo 16, PostgreSQL 15 y servidor de correo de pruebas |
| `instrucciones.md` | Pasos para levantar el sistema y restaurar la base de datos |

## Tecnologías

- **ERP y CRM:** Odoo 16 Community (Ventas, Compras, Inventario, Facturación, Acuerdos de compra, CRM y Marketing por correo)
- **Base de datos:** PostgreSQL 15
- **Infraestructura:** Docker y Docker Compose
- **Correo de pruebas:** Mailpit

## Ejecución

```bash
docker compose up -d
```

- Odoo: http://localhost:8069 (base `raiz_artesanal_db`)
- Bandeja de correos de prueba: http://localhost:8025

Para cargar los datos del proyecto, seguir [`instrucciones.md`](instrucciones.md).

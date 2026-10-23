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
| Fase 3 – Tienda en línea, integración y resultados | [`Entregables/Fase 3`](Entregables/Fase%203) | Informe final, manual técnico, manuales de usuario, reportes de BI, medición de KPIs, conclusiones y enlace del video |

## Estructura del repositorio

| Carpeta / archivo | Descripción |
|-------------------|-------------|
| `Entregables/` | Documentos entregados en cada fase |
| `Fase_2/Documento_Final/` | Informe consolidado de la Fase 2 (Word y PDF) |
| `Fase_2/Datos_Maestros/` | Plantillas Excel de productos, clientes y proveedores y su manual de carga |
| `Fase_2/Compras_Abastecimiento/` | Manual y capturas del ciclo de compras (requisición, orden de compra y recepción) |
| `Fase_2/Cotizaciones_y_Reportes/` | Manuales y capturas de cotizaciones, ventas, informes de inventario y medición de logros |
| `Fase_2/CRM_Correos/` | Manual y capturas del pipeline CRM, plantillas de correo y campañas |
| `Fase_3/Tienda_en_Linea/` | Manual y capturas de la tienda en línea y su integración con ventas, inventario, facturación y CRM |
| `Fase_3/Campana_Tienda/` | Manual y capturas de la campaña de correo segmentada que anuncia la tienda en línea |
| `Fase_3/KPIs/` | Medición de los KPIs con datos de Odoo y script para verificarlos |
| `Fase_3/BI/` | Reportes de inventario y ventas en Metabase, vistas SQL del esquema bi y manual |
| `Fase_3/Manual_Tecnico/` | Manual técnico, diagramas de arquitectura y del flujo de integración |
| `Fase_3/Conclusiones/` | Evaluación de los objetivos SMART, conclusiones y propuesta de escalabilidad |
| `Fase_3/Documento_Final/` | Informe final consolidado de la Fase 3 (Word y PDF) |
| `Base_de_Datos/` | Respaldo final de la base de datos de Odoo, del filestore (imágenes) y de los tableros de Metabase |
| `imagenes/` | Fotografías de los productos y logotipo de la marca |
| `docker-compose.yml` | Servicios de Odoo 16, PostgreSQL 15, Metabase y servidor de correo de pruebas |
| `instrucciones.md` | Pasos para levantar el sistema y restaurar la base de datos |

## Tecnologías

- **ERP y CRM:** Odoo 16 Community (Ventas, Compras, Inventario, Facturación, Acuerdos de compra, CRM, Marketing por correo y Encuestas)
- **Comercio electrónico:** Sitio web y tienda en línea de Odoo
- **Business Intelligence:** Metabase
- **Base de datos:** PostgreSQL 15
- **Infraestructura:** Docker y Docker Compose
- **Correo de pruebas:** Mailpit

## Ejecución

```bash
docker compose -p odoo-erp up -d db web mailpit
```

- Odoo: http://localhost:8069 (base `raiz_artesanal_db`)
- Tienda en línea: http://localhost:8069/shop
- Reportes de BI (Metabase): http://localhost:3000
- Bandeja de correos de prueba: http://localhost:8025

Para cargar los datos del proyecto y levantar Metabase, seguir [`instrucciones.md`](instrucciones.md).

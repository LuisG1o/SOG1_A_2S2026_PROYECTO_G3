# Medición de Logros y Evaluación de KPIs – Fase 2

**Proyecto:** Transformación Digital en E-Commerce con ERP, CRM y BI – QuetzalDev  
**Empresa:** Raíz Artesanal  
**Curso:** Sistemas Organizacionales y Gerenciales 1  
**Semestre:** Segundo Semestre 2026  
**Responsable del Análisis:** Eduardo Misael López Avila 
**Grupo:** Grupo 3  

---

## 1. Introducción y Alcance del Control en la Fase 2

El propósito de este documento es evaluar y certificar el grado de cumplimiento de los objetivos operativos, comerciales y logísticos establecidos para la **Fase 2 (Configuración, Desarrollo de Módulos y Operación Base)** del proyecto de transformación digital de **Raíz Artesanal**.

A diferencia de la Fase 1, donde los indicadores clave de rendimiento (KPIs) y los objetivos SMART se formularon a nivel conceptual y predictivo, en esta segunda etapa se cuenta con datos transaccionales reales ejecutados dentro del sistema ERP Odoo 16:
* Carga de datos maestros (30 productos, 6 proveedores y 7 clientes).
* 3 ciclos de compras a proveedores por un valor de Q 17,090.00 con recepción de 44 unidades físicas.
* 2 ciclos de cotización y ventas comerciales por un valor acumulado de Q 10,540.00.
* Despacho y facturación contable oficial con trazabilidad en bodega.
* Activación del motor de reposición automática de existencias con la orden P00028.

El análisis que se presenta a continuación da respuesta rigurosa a las directrices de la **Sección 8 (Medición de logros y resultados)**, la **Sección 10 (Definición de KPIs)** y el **Criterio 2.4 de la Rúbrica de Calificación de la Fase 2**.

---

## 2. Metodología de Control y Medición de Resultados

Para garantizar un control gerencial sistemático de las operaciones simuladas, la empresa da respuesta estructurada a las seis interrogantes fundamentales de seguimiento:

### 2.1 ¿Cómo se medirán los objetivos específicos?
Los objetivos específicos se evalúan mediante la confrontación matemática entre las metas planteadas en la planificación y los registros auditables en la base de datos de PostgreSQL:
* **Puesta en marcha del catálogo:** Medido por el recuento de artículos activos con ficha técnica, fotografía y costo estándar (30 de 30 artículos operativos, 100% de cumplimiento).
* **Capacidad de respuesta comercial:** Medido por el tiempo transcurrido entre la solicitud de cotización y la emisión del presupuesto formal en PDF (reducción de 3 días en el modelo manual previo a menos de 5 minutos en Odoo).
* **Automatización del abastecimiento:** Medido por la capacidad del sistema de emitir órdenes de compra sin intervención humana cuando el stock proyectado cae por debajo del umbral de seguridad.

### 2.2 ¿De qué manera se evaluará la ejecución de las actividades?
La ejecución de actividades se monitorea a través de la matriz de trazabilidad de estados en Odoo:
* En compras: seguimiento del ciclo `Requisición (purchase_requisition) -> Solicitud de Presupuesto (RFQ) -> Orden de Compra (PO) -> Albarán de Recepción (WH/IN) -> Validación Contable`.
* En ventas: seguimiento del ciclo `Presupuesto (draft) -> Pedido de Venta (sale) -> Albarán de Salida (WH/OUT) -> Factura de Cliente (posted)`.
Cada cambio de estado queda registrado con marca de tiempo (*timestamp*) y usuario responsable en el chatter lateral de Odoo.

### 2.3 ¿Cuáles serán los métodos para verificar el avance del proyecto?
Se implementan tres métodos formales de verificación:
1. **Auditoría de Base de Datos:** Verificación de integridad relacional mediante consultas SQL a las tablas maestras (`stock_quant`, `stock_picking`, `sale_order`, `purchase_order`, `account_move`).
2. **Conciliación de Inventario:** Comparación entre las unidades físicas demandadas y las cantidades efectivamente reservadas y descontadas de las ubicaciones internas (`WH/Stock`).
3. **Inspección Visual de Flujo:** Revisión de las evidencias documentales capturadas en los manuales de usuario y técnicos.

### 2.4 ¿Cómo se cuantificarán los beneficios económicos?
La cuantificación económica se establece evaluando:
* **Margen Bruto de Operación:** Diferencia entre el precio de venta facturado y el costo de adquisición de los artesanos.
* **Capital Inmovilizado en Bodega:** Valoración exacta del inventario activo disponible (Q 95,015.00 en existencia física distribuida en las 6 familias artesanales).
* **Ahorro en Tiempos de Gestión:** Eliminación de horas-hombre invertidas en conciliaciones manuales en hojas de cálculo y reducción de pérdidas por quiebres de existencias o sobreventa.

### 2.5 ¿Qué técnicas se emplearán para medir la satisfacción del cliente?
* **Puntualidad en la Entrega:** Cumplimiento del despacho en bodega en menos de 48 horas hábiles.
* **Exactitud del Pedido:** Tasa de cero discrepancias entre lo cotizado, lo facturado y lo empacado en el traslado de salida.
* **Comunicación Proactiva:** Envío de notificaciones automáticas inmediatas por mensaje de texto (SMS) o correo electrónico al validar la orden de entrega (evidenciado en el despacho `WH/OUT/00015`).

### 2.6 ¿Cómo se evaluará el desempeño de la plataforma?
* **Disponibilidad del Servicio:** Monitoreo del contenedor Docker `odoo:16.0` con tiempo de actividad continuo y respuesta HTTP 200 en todos los controladores web.
* **Integridad de Transacciones:** Comprobación de que ninguna orden de venta pueda confirmarse sin registrar su impacto correspondiente en inventario y facturación.

---

## 3. Evaluación Cuantitativa de los 5 KPIs Institucionales

A continuación se contrastan las metas teóricas definidas en la Fase 1 contra los resultados cuantitativos obtenidos en la operación real de la Fase 2:

### Tabla Resumen de KPIs de la Fase 2

| No. | Indicador Clave (KPI) | Dimensión Evaluada | Meta Fase 1 | Resultado Real Fase 2 | Variación / Desempeño | Estado de Cumplimiento |
| :---: | :--- | :--- | :--- | :--- | :--- | :---: |
| **KPI 1** | Tasa de Conversión de Cotizaciones | Ventas / Comercial | $\ge 70.0\%$ | **100.0%** (2 de 2 pedidos) | $+30.0\%$ | Superado |
| **KPI 2** | Valor Promedio del Pedido (AOV) | Financiera / Ventas | Q 350 - Q 450 (indiv.)<br>Q 5,000+ (corp.) | **Q 5,270.00** (promedio global)<br>Q 9,620.00 (corp.) / Q 920.00 (ind.) | Conforme a modelo | Superado |
| **KPI 3** | Tiempo de Cumplimiento y Despacho | Logística / Operaciones | $\le 48\text{ horas}$ | **2 minutos con 7 segundos** (despacho express S00026) | Despacho inmediato | Superado |
| **KPI 4** | Exactitud de Inventario (IRA) | Almacén / Suministros | $\ge 98.0\%$ | **100.0%** (30 de 30 SKUs) | $+2.0\%$ | Cumplido al 100% |
| **KPI 5** | Índice de Satisfacción del Cliente (CSAT) | Servicio / Postventa | $\ge 90.0\%$ ($\ge 4.5/5$) | **100.0%** de pedidos conformes sin reclamos | Simulación sin errores | Conforme |

---

### 3.1 Análisis Detallado por Indicador

#### KPI 1: Tasa de Conversión Comercial (Conversion Rate)
* **Fórmula:**
  $$\text{Tasa de Conversión} = \left(\frac{\text{Número de Pedidos de Venta Confirmados}}{\text{Total de Cotizaciones Emitidas}}\right) \times 100$$
* **Datos Fase 2:** Se emitieron dos cotizaciones formales: `S00025` a Hotel Casa Santo Domingo y `S00026` a María Fernanda Morales. Ambas ofertas fueron aceptadas y confirmadas en el sistema.
* **Cálculo:**
  $$\text{Tasa de Conversión} = \left(\frac{2}{2}\right) \times 100 = 100\%$$
* **Conclusión:** La parametrización de términos de crédito claros (15 días) y la entrega de cotizaciones formales en PDF reducen drásticamente la fricción comercial, logrando una efectividad total de cierre.

#### KPI 2: Valor Promedio del Pedido (Average Order Value - AOV)
* **Fórmula:**
  $$\text{AOV} = \frac{\text{Monto Total Facturado en Ventas}}{\text{Total de Pedidos Confirmados}}$$
* **Datos Fase 2:**
  * Venta Corporativa (`S00025`): Q 9,620.00
  * Venta Individual (`S00026`): Q 920.00
  * Ingreso Total Bruto: Q 10,540.00
* **Cálculo:**
  $$\text{AOV} = \frac{\text{Q } 10,540.00}{2} = \text{Q } 5,270.00$$
* **Conclusión:** Se valida la tesis del plan estratégico de Raíz Artesanal: la apertura del canal corporativo (hoteles y regalos institucionales) eleva exponencialmente el ticket promedio de compra en comparación con la venta minorista tradicional.

#### KPI 3: Tiempo de Cumplimiento y Despacho (Order Fulfillment Cycle Time)
* **Fórmula:**
  $$\text{Tiempo de Despacho} = \text{Hora de Validación en Almacén (Hecho)} - \text{Hora de Confirmación de Venta}$$
* **Datos Fase 2 (Auditoría Pedido S00026):**
  * Confirmación de Pedido: `05/10/2026 12:30:04`
  * Despacho y Salida Física (`WH/OUT/00015`): `05/10/2026 12:32:11`
  * Tiempo transcurrido: **2 minutos y 7 segundos**.
* **Conclusión:** Para mercancía con existencia disponible en bodega, la integración automática entre Ventas e Inventario elimina los retrasos de coordinación interna, pulverizando la meta de 48 horas máximas.

#### KPI 4: Exactitud de Registros de Inventario (Inventory Record Accuracy - IRA)
* **Fórmula:**
  $$\text{IRA} = \left(\frac{\text{Número de SKUs con Saldo Físico Exacto al Sistema}}{\text{Total de SKUs Auditados en Catálogo}}\right) \times 100$$
* **Datos Fase 2:** Se auditaron los 30 productos del catálogo (`RA-001` al `RA-030`).
  * Stock inicial ingresado por Norma: 223 unidades.
  * Entradas por compras validadas por Javier (`P00025` y `P00026`): +44 unidades.
  * Salidas por ventas validadas por Eduardo (`S00026`): -2 unidades.
  * Stock real disponible en almacén: **265.00 unidades**.
  * Valorización total del almacén: **Q 95,015.00**.
  * Discrepancias encontradas: **0 artículos**.
* **Cálculo:**
  $$\text{IRA} = \left(\frac{30}{30}\right) \times 100 = 100\%$$
* **Conclusión:** Se erradicó por completo la debilidad histórica de la empresa (control en hojas de cálculo desactualizadas), logrando un inventario perpetuo 100% confiable.

#### KPI 5: Puntuación de Satisfacción del Cliente (CSAT)
* **Datos Fase 2:** Aunque las encuestas masivas de satisfacción corresponden a la Fase 3, en la Fase 2 se verificó el 100% de cumplimiento en los factores determinantes del CSAT:
  1. Cero errores de producto en el despacho de almacén.
  2. Facturación electrónica inmediata por el monto acordado (Q 920.00).
  3. Disparo automático de notificación por SMS al cliente indicando el número de guía de envío (`S00026`).

---

## 4. Métricas del Flujo Integral de la Cadena de Suministro

La siguiente tabla resume la articulación de extremo a extremo lograda por los integrantes del equipo en Odoo 16:

| Área Funcional | Responsable | Módulo Odoo | Transacciones Ejecutadas | Impacto en el Sistema |
| :--- | :--- | :--- | :--- | :--- |
| **Datos Maestros** | Norma Canú | Inventario / Contactos | 30 productos, 6 proveedores, 7 clientes | Catálogo base valorizado con imágenes en filestore. |
| **Abastecimiento** | Javier Pérez | Compras / Inventario | 3 órdenes de compra (Q 17,090.00)<br>2 recepciones validadas (+44 u.)<br>1 orden en tránsito (P00027, Q 1,750.00) | Incremento automático de existencias físicas en bodega. |
| **Comercialización** | Eduardo López | Ventas / Facturación | 2 cotizaciones confirmadas (Q 10,540.00)<br>1 entrega despachada (-2 u.)<br>1 factura confirmada (Q 920.00) | Reserva en tiempo real y salida contable de bodega. |
| **Reposición Inteligente** | Sistema Odoo / Eduardo | Reabastecimiento | 1 regla de stock mínimo disparada (RA-014)<br>1 orden de reposición generada (P00028) | Prevención automatizada de desabastecimiento futuro. |

---

## 5. Auditoría de Trazabilidad Transaccional en Base de Datos

Se documenta la consulta de auditoría ejecutada directamente en PostgreSQL para validar el correcto funcionamiento del sistema:

```sql
SELECT 
    s.name AS pedido_venta,
    s.state AS estado_venta,
    s.amount_total AS total_venta,
    p.name AS albaran_entrega,
    p.state AS estado_entrega,
    m.name AS factura_contable,
    m.state AS estado_factura
FROM sale_order s
LEFT JOIN stock_picking p ON p.origin = s.name
LEFT JOIN sale_order_line sol ON sol.order_id = s.id
LEFT JOIN sale_order_line_invoice_rel rel ON rel.order_line_id = sol.id
LEFT JOIN account_move_line aml ON aml.id = rel.invoice_line_id
LEFT JOIN account_move m ON m.id = aml.move_id
WHERE s.name IN ('S00025', 'S00026')
GROUP BY s.name, s.state, s.amount_total, p.name, p.state, m.name, m.state;
```

### Resultado de la Auditoría en Base de Datos:

```
 pedido_venta | estado_venta | total_venta | albaran_entrega | estado_entrega | factura_contable | estado_factura 
--------------+--------------+-------------+-----------------+----------------+------------------+----------------
 S00025       | sale         |     9620.00 | WH/OUT/00014    | assigned       |                  | 
 S00026       | sale         |      920.00 | WH/OUT/00015    | done           | INV/2026/00005   | posted
```

---



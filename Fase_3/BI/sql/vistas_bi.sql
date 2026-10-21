-- Vistas de Business Intelligence para Raíz Artesanal
-- Base de datos: raiz_artesanal_db (Odoo 16)
-- Metabase consulta estas vistas con el usuario de solo lectura bi_lectura.

CREATE SCHEMA IF NOT EXISTS bi;

-- Costo de cada producto (en Odoo 16 el costo se guarda por compañía en ir_property)
CREATE OR REPLACE VIEW bi.costos AS
SELECT SPLIT_PART(res_id, ',', 2)::int AS product_id, value_float AS costo
FROM ir_property
WHERE name = 'standard_price' AND company_id = 1 AND res_id LIKE 'product.product,%';

-- Tipo de cliente según la etiqueta de segmento asignada en el CRM
CREATE OR REPLACE FUNCTION bi.tipo_cliente(partner integer) RETURNS text
LANGUAGE sql STABLE AS $$
    SELECT CASE WHEN EXISTS (
        SELECT 1 FROM res_partner_res_partner_category_rel r
        JOIN res_partner_category c ON c.id = r.category_id
        WHERE r.partner_id = partner AND 'Corporativo' IN (c.name ->> 'es_GT', c.name ->> 'en_US'))
    THEN 'Corporativo' ELSE 'Individual' END
$$;

-- Productos del catálogo con existencias, mercadería entrante y nivel de stock
CREATE OR REPLACE VIEW bi.productos AS
WITH stock AS (
    SELECT q.product_id, SUM(q.quantity) AS existencia
    FROM stock_quant q
    JOIN stock_location l ON l.id = q.location_id
    WHERE l.complete_name = 'WH/Stock'
    GROUP BY q.product_id
), entrante AS (
    SELECT m.product_id, SUM(m.product_uom_qty) AS entrante
    FROM stock_move m
    JOIN stock_picking_type t ON t.id = m.picking_type_id
    WHERE t.code = 'incoming' AND m.state NOT IN ('done', 'cancel', 'draft')
    GROUP BY m.product_id
)
SELECT pp.default_code                                   AS codigo,
       pt.name ->> 'es_GT'                               AS producto,
       pc.name                                           AS categoria,
       pt.list_price                                     AS precio_venta,
       COALESCE(c.costo, 0)              AS costo,
       COALESCE(s.existencia, 0)                         AS existencia,
       COALESCE(e.entrante, 0)                           AS entrante,
       COALESCE(s.existencia, 0) * COALESCE(c.costo, 0) AS valor_inventario,
       5                                                 AS punto_reposicion,
       CASE WHEN COALESCE(s.existencia, 0) <= 5 THEN 'Stock bajo'
            WHEN COALESCE(s.existencia, 0) <= 10 THEN 'Atención'
            ELSE 'Disponible' END                        AS nivel_stock
FROM product_product pp
JOIN product_template pt ON pt.id = pp.product_tmpl_id
JOIN product_category pc ON pc.id = pt.categ_id
LEFT JOIN bi.costos c ON c.product_id = pp.id
LEFT JOIN stock s ON s.product_id = pp.id
LEFT JOIN entrante e ON e.product_id = pp.id
WHERE pp.default_code LIKE 'RA-%' AND pp.active;

-- Líneas de venta confirmadas, con canal, tipo de cliente y ganancia
CREATE OR REPLACE VIEW bi.ventas AS
SELECT so.name                                                        AS pedido,
       (so.date_order AT TIME ZONE 'UTC' AT TIME ZONE 'America/Guatemala') AS fecha,
       CASE WHEN so.website_id IS NOT NULL THEN 'Tienda en línea' ELSE 'Venta directa' END AS canal,
       cp.name                                                        AS cliente,
       bi.tipo_cliente(cp.id)                                         AS tipo_cliente,
       pp.default_code                                                AS codigo,
       pt.name ->> 'es_GT'                                            AS producto,
       pc.name                                                        AS categoria,
       sol.product_uom_qty                                            AS cantidad,
       sol.price_subtotal                                             AS venta_sin_iva,
       sol.price_total                                                AS venta_con_iva,
       sol.product_uom_qty * COALESCE(c.costo, 0)     AS costo,
       sol.price_subtotal - sol.product_uom_qty * COALESCE(c.costo, 0) AS ganancia
FROM sale_order_line sol
JOIN sale_order so ON so.id = sol.order_id
JOIN res_partner p ON p.id = so.partner_id
JOIN res_partner cp ON cp.id = COALESCE(p.commercial_partner_id, p.id)
JOIN product_product pp ON pp.id = sol.product_id
JOIN product_template pt ON pt.id = pp.product_tmpl_id
JOIN product_category pc ON pc.id = pt.categ_id
LEFT JOIN bi.costos c ON c.product_id = pp.id
WHERE so.state IN ('sale', 'done') AND pp.default_code LIKE 'RA-%';

-- KPIs de la Fase 1 calculados con los registros de Odoo
CREATE OR REPLACE VIEW bi.kpis AS
WITH web AS (
    SELECT so.name, so.amount_total, so.date_order,
           bi.tipo_cliente(cp.id) AS tipo
    FROM sale_order so
    JOIN res_partner p ON p.id = so.partner_id
    JOIN res_partner cp ON cp.id = COALESCE(p.commercial_partner_id, p.id)
    WHERE so.website_id IS NOT NULL AND so.state IN ('sale', 'done')
), visitantes AS (
    SELECT COUNT(*) AS total
    FROM website_visitor v
    WHERE v.partner_id IS NULL
       OR EXISTS (SELECT 1 FROM res_users u WHERE u.partner_id = v.partner_id AND u.share)
), despacho AS (
    SELECT MAX(sp.date_done - w.date_order) AS maximo, AVG(sp.date_done - w.date_order) AS promedio
    FROM web w
    JOIN stock_picking sp ON sp.origin = w.name
    JOIN stock_picking_type t ON t.id = sp.picking_type_id AND t.code = 'outgoing'
    WHERE sp.state = 'done'
), conteo AS (
    SELECT COUNT(*) AS contados, COUNT(*) FILTER (WHERE product_uom_qty = 0) AS coinciden
    FROM stock_move WHERE reference = 'Conteo físico Fase 3' AND state = 'done'
), csat AS (
    SELECT COUNT(*) AS respuestas,
           COUNT(*) FILTER (WHERE LEFT(a.value ->> 'es_GT', 1) IN ('4', '5')) AS positivas,
           AVG(LEFT(a.value ->> 'es_GT', 1)::int) AS promedio
    FROM survey_user_input_line l
    JOIN survey_user_input ui ON ui.id = l.user_input_id AND ui.state = 'done'
    JOIN survey_survey s ON s.id = ui.survey_id AND s.title ->> 'es_GT' ILIKE '%satisfacción%'
    JOIN survey_question_answer a ON a.id = l.suggested_answer_id
)
SELECT (SELECT COUNT(*) FROM web)                                              AS pedidos_en_linea,
       (SELECT total FROM visitantes)                                          AS visitantes,
       ROUND((SELECT COUNT(*) FROM web) * 100.0 / NULLIF((SELECT total FROM visitantes), 0), 2) AS conversion_pct,
       (SELECT ROUND(AVG(amount_total), 2) FROM web WHERE tipo = 'Individual')  AS ticket_individual,
       (SELECT ROUND(AVG(amount_total), 2) FROM web WHERE tipo = 'Corporativo') AS ticket_corporativo,
       ROUND(EXTRACT(EPOCH FROM (SELECT maximo FROM despacho)) / 60, 1)          AS despacho_max_min,
       ROUND(EXTRACT(EPOCH FROM (SELECT promedio FROM despacho)) / 60, 1)        AS despacho_prom_min,
       ROUND((SELECT coinciden FROM conteo) * 100.0 / NULLIF((SELECT contados FROM conteo), 0), 0) AS exactitud_inventario_pct,
       ROUND((SELECT positivas FROM csat) * 100.0 / NULLIF((SELECT respuestas FROM csat), 0), 0)   AS csat_pct,
       ROUND((SELECT promedio FROM csat), 1)                                   AS csat_promedio;

-- Permisos para el usuario de solo lectura de la herramienta de BI.
-- El usuario se crea antes con: CREATE ROLE bi_lectura LOGIN PASSWORD '<contraseña>';
GRANT CONNECT ON DATABASE raiz_artesanal_db TO bi_lectura;
GRANT USAGE ON SCHEMA bi TO bi_lectura;
GRANT SELECT ON ALL TABLES IN SCHEMA bi TO bi_lectura;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA bi TO bi_lectura;
GRANT SELECT ON res_partner_res_partner_category_rel, res_partner_category TO bi_lectura;

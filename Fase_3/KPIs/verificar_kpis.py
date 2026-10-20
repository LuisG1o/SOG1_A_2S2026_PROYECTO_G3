"""
Calcula los KPIs de la Fase 3 directamente desde la base de datos de Odoo.

Uso (con Odoo levantado en http://localhost:8069):
    python verificar_kpis.py

Todos los valores salen de los registros del sistema (pedidos, entregas,
conteo de inventario y respuestas de la encuesta), por lo que coinciden
con lo que se muestra en las pantallas de Odoo.
"""
import xmlrpc.client
from datetime import datetime, timedelta

URL = "http://localhost:8069"
DB = "raiz_artesanal_db"
USUARIO = "normacanu77@gmail.com"
CLAVE = "Admin2026*"

PEDIDOS_WEB = ["S00027", "S00028", "S00029", "S00030", "S00031"]
PEDIDO_CORPORATIVO = "S00031"
REFERENCIA_CONTEO = "Conteo físico Fase 3"
FORMATO = "%Y-%m-%d %H:%M:%S"

uid = xmlrpc.client.ServerProxy(URL + "/xmlrpc/2/common").authenticate(DB, USUARIO, CLAVE, {})
odoo = xmlrpc.client.ServerProxy(URL + "/xmlrpc/2/object", allow_none=True)


def buscar(modelo, dominio, campos, **kw):
    return odoo.execute_kw(DB, uid, CLAVE, modelo, "search_read", [dominio], dict(fields=campos, **kw))


def contar(modelo, dominio):
    return odoo.execute_kw(DB, uid, CLAVE, modelo, "search_count", [dominio])


def linea(nombre, meta, resultado, cumple):
    print(f"{nombre:<34} meta: {meta:<22} resultado: {resultado:<28} {'CUMPLE' if cumple else 'NO CUMPLE'}")


pedidos = buscar("sale.order", [("name", "in", PEDIDOS_WEB), ("state", "=", "sale")],
                 ["name", "amount_total", "date_order"], order="name")

# KPI 1: tasa de conversión de la tienda en línea
# Se cuentan los visitantes del sitio sin incluir a los usuarios internos de la empresa.
visitantes = contar("website.visitor", ["|", ("partner_id", "=", False), ("partner_id.user_ids.share", "=", True)])
conversion = len(pedidos) / visitantes * 100
linea("1. Conversión de la tienda", "2.5 % a 3.0 %", f"{len(pedidos)} / {visitantes} = {conversion:.2f} %", conversion >= 2.5)

# KPI 2: valor promedio del pedido
individuales = [p["amount_total"] for p in pedidos if p["name"] != PEDIDO_CORPORATIVO]
corporativos = [p["amount_total"] for p in pedidos if p["name"] == PEDIDO_CORPORATIVO]
aov_ind = sum(individuales) / len(individuales)
aov_corp = sum(corporativos) / len(corporativos)
linea("2a. Ticket promedio individual", "Q 350.00", f"Q {aov_ind:,.2f}", aov_ind >= 350)
linea("2b. Ticket promedio corporativo", "Q 2,800.00", f"Q {aov_corp:,.2f}", aov_corp >= 2800)

# KPI 3: tiempo de despacho (confirmación del pedido -> entrega validada)
tiempos = []
for p in pedidos:
    entrega = buscar("stock.picking", [("origin", "=", p["name"]), ("picking_type_code", "=", "outgoing")], ["date_done"])[0]
    tiempos.append(datetime.strptime(entrega["date_done"], FORMATO) - datetime.strptime(p["date_order"], FORMATO))
maximo = max(tiempos)
promedio = sum(tiempos, timedelta()) / len(tiempos)
linea("3. Tiempo de despacho", "<= 48 horas", f"máx {maximo}, prom {str(promedio).split('.')[0]}", maximo <= timedelta(hours=48))

# KPI 4: exactitud de registros de inventario
movimientos = buscar("stock.move", [("reference", "=", REFERENCIA_CONTEO), ("state", "=", "done")], ["product_uom_qty"])
auditados = len(movimientos)
con_diferencia = sum(1 for m in movimientos if m["product_uom_qty"] != 0)
ira = (auditados - con_diferencia) / auditados * 100
linea("4. Exactitud de inventario", ">= 98 %", f"{auditados - con_diferencia} / {auditados} = {ira:.0f} %", ira >= 98)

# KPI 5: satisfacción del cliente (CSAT)
respuestas = buscar("survey.user_input", [("survey_id.title", "ilike", "satisfacción"), ("state", "=", "done")], ["id"])
calificaciones = buscar("survey.user_input.line",
                        [("user_input_id", "in", [r["id"] for r in respuestas]), ("answer_type", "=", "suggestion")],
                        ["suggested_answer_id"])
notas = [int(c["suggested_answer_id"][1][0]) for c in calificaciones]
positivas = sum(1 for n in notas if n >= 4)
csat = positivas / len(notas) * 100
linea("5. Satisfacción del cliente", ">= 90 %", f"{positivas} / {len(notas)} = {csat:.0f} % (prom {sum(notas)/len(notas):.1f})", csat >= 90)

# Datos de control
stock = sum(q["quantity"] for q in buscar("stock.quant", [("product_id.default_code", "like", "RA-"),
                                                         ("location_id.complete_name", "=", "WH/Stock")], ["quantity"]))
print()
print(f"Ventas en línea: {len(pedidos)} pedidos por Q {sum(p['amount_total'] for p in pedidos):,.2f}")
print(f"Existencias actuales en WH/Stock: {stock:.0f} unidades")

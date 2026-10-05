USE Ventas_Tech_DB;
GO

-- === CONSULTA 1: RESUMEN EJECUTIVO MENSUAL ===
-- Total facturado, cantidad de pedidos y ticket promedio por mes.
-- Aporta a la pregunta 1 del brief (¿en qué mes empezó la caída?)
-- y a los KPIs Total Ventas y Ticket promedio.
-- Se agrupa también por año para no mezclar el mismo mes de
-- años distintos cuando la base tenga más historia.

SELECT
    YEAR(fecha_venta)                                       AS anio,
    MONTH(fecha_venta)                                      AS mes,
    SUM(cantidad * precio_unitario)                         AS total_facturado,
    COUNT(*)                                                AS cantidad_pedidos,
    CAST(AVG(cantidad * precio_unitario) AS DECIMAL(10,2))  AS ticket_promedio
FROM ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY anio, mes;


-- === CONSULTA 2: RANKING DE PRODUCTOS ===
-- Top 5 de productos por total facturado, con unidades vendidas.
-- ¿qué productos explican el resultado?

SELECT TOP 5
    id_producto,
    SUM(cantidad)                    AS unidades_vendidas,
    SUM(cantidad * precio_unitario)  AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;


-- === CONSULTA 3: CLIENTES RECURRENTES ===
-- Clientes con más de un pedido, cantidad de pedidos y total gastado.
-- Aporta a las preguntas 4 y 5 del brief (¿se perdieron clientes o compran menos?, ¿quiénes redujeron sus compras?).
-- HAVING filtra después de agrupar: WHERE no puede usar COUNT(*).

SELECT
    id_cliente,
    COUNT(*)                         AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)  AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;


-- === CONSULTA 4: MESES POR ENCIMA / POR DEBAJO DEL PROMEDIO ===
-- Total facturado por mes, comparado con el promedio mensual general.
-- Paso 1 (ventas_mensuales): arma el total de cada mes.
-- Paso 2: compara cada mes contra el promedio de esos totales.
-- Se agrega la etiqueta 'En el promedio' para el caso en que el total del mes coincide exactamente con el promedio.

WITH ventas_mensuales AS (
    SELECT
        YEAR(fecha_venta)                AS anio,
        MONTH(fecha_venta)               AS mes,
        SUM(cantidad * precio_unitario)  AS total_facturado
    FROM ventas
    GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
)
SELECT
    anio,
    mes,
    total_facturado,
    CAST((SELECT AVG(total_facturado) FROM ventas_mensuales) AS DECIMAL(12,2)) AS promedio_mensual,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM ventas_mensuales) THEN 'Por encima'
        WHEN total_facturado < (SELECT AVG(total_facturado) FROM ventas_mensuales) THEN 'Por debajo'
        ELSE 'En el promedio'
    END                                  AS comparacion_con_promedio
FROM ventas_mensuales
ORDER BY anio, mes;


-- ============================================================
-- HALLAZGOS
-- ============================================================
-- 1. El producto 1 concentra el 55,9 % de la facturación: 3.600 de
--    6.444, con solo 3 unidades vendidas. Sumado al producto 3
--    (1.350), dos productos explican el 76,8 % del total.
--
-- 2. El producto 2 es el más vendido en unidades (13) pero queda
--    quinto en facturación (364). Mucho volumen y poco ingreso:
--    el ranking cambia según se mida por unidades o por monto.
--
-- 3. Los 5 clientes hicieron exactamente 2 pedidos, así que todos
--    son recurrentes. El gasto está concentrado: los clientes 1
--    (2.640) y 5 (2.100) suman el 73,6 % de la facturación.
--
-- Limitación de los datos: las 10 ventas son de marzo de 2024
-- (total 6.444, ticket promedio 644,40). Con un solo mes cargado,
-- la consulta 4 devuelve 'En el promedio': todavía no se puede
-- comparar meses ni ver una tendencia.

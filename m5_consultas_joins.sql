-- ============================================================
-- m5_consultas_joins.sql
-- Pre-entrega Módulo 5: Consultas con JOINs para el proyecto
-- Proyecto RetailPro - base de datos Ventas_Tech_DB
-- Motor utilizado: SQL Server (SSMS)
--
-- Requisito: ejecutar antes la versión actualizada de
-- ventas_tech_db.sql (Módulo 3), que agrega la tabla territorios
-- y la columna ventas.id_territorio. Sin esa actualización, las
-- consultas 1 y 4 fallan.
-- ============================================================

USE Ventas_Tech_DB;
GO


-- === CONSULTA 1: VISTA BASE DEL PROYECTO (INNER JOIN) ===
-- Propósito: una fila por venta, con los nombres en lugar de
-- los IDs. Es la fuente de datos principal para Power BI.
-- Cruza ventas con sus cuatro dimensiones por clave foránea:
--   ventas.id_cliente     -> clientes.id_cliente
--   ventas.id_producto    -> productos.id_producto
--   productos.id_categoria -> categorias.id_categoria
--   ventas.id_territorio  -> territorios.id_territorio
-- Columnas para agrupar: categoria, region. Para filtrar: ciudad,
-- fecha_venta.

SELECT
    v.id_venta,
    v.fecha_venta,
    c.id_cliente,
    c.nombre                        AS cliente,
    c.ciudad,
    t.region,
    p.nombre_producto               AS producto,
    cat.nombre_categoria            AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario  AS total_venta
FROM ventas AS v
INNER JOIN clientes    AS c   ON c.id_cliente      = v.id_cliente
INNER JOIN productos   AS p   ON p.id_producto     = v.id_producto
INNER JOIN categorias  AS cat ON cat.id_categoria  = p.id_categoria
INNER JOIN territorios AS t   ON t.id_territorio   = v.id_territorio
ORDER BY v.fecha_venta, v.id_venta;

-- Resultado: 10 filas, las mismas que tiene la tabla ventas.
-- Ninguna venta se pierde en el cruce: todas tienen cliente,
-- producto, categoría y territorio válidos. El total suma 6.444,
-- igual que el total facturado del Módulo 4.


-- === CONSULTA 2: CLIENTES SIN VENTAS (LEFT JOIN) ===
-- Propósito: detectar clientes registrados que nunca compraron,
-- para el área de CRM.
-- LEFT JOIN conserva a todos los clientes. Si un cliente no tiene
-- ventas, las columnas de ventas quedan en NULL; el WHERE se
-- queda solo con esos casos.

SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v ON v.id_cliente = c.id_cliente
WHERE v.id_venta IS NULL
ORDER BY c.fecha_registro;

-- Resultado: 0 filas. Los 5 clientes registrados compraron al
-- menos una vez, así que hoy no hay clientes inactivos para
-- una campaña de activación.


-- === CONSULTA 3: PRODUCTOS SIN VENTAS (LEFT JOIN) ===
-- Propósito: detectar productos del catálogo sin movimiento,
-- para el área de producto.
-- El LEFT JOIN con ventas busca los productos sin ninguna venta.
-- El LEFT JOIN con categorias trae el nombre de la categoría sin
-- descartar productos que no tengan categoría asignada.

SELECT
    p.nombre_producto,
    cat.nombre_categoria  AS categoria,
    p.precio
FROM productos AS p
LEFT JOIN ventas     AS v   ON v.id_producto    = p.id_producto
LEFT JOIN categorias AS cat ON cat.id_categoria = p.id_categoria
WHERE v.id_venta IS NULL
ORDER BY p.nombre_producto;

-- Resultado: 0 filas. Los 6 productos del catálogo tienen al
-- menos una venta: no hay artículos sin movimiento.


-- === CONSULTA 4: CONSOLIDADO POR ORIGEN (UNION ALL) ===
-- Propósito: comparar la región Norte contra el resto del país,
-- que es la comparación central del brief del Módulo 1.
-- La columna origen no existe en ninguna tabla: se crea como
-- texto fijo dentro de cada SELECT.
-- Criterio: id_territorio = 1 es Norte; cualquier otro valor es
-- el resto. Las dos condiciones no se superponen y cubren todas
-- las ventas, así que cada venta se cuenta una sola vez.
-- Los dos SELECT devuelven las mismas tres columnas, en el mismo
-- orden y con tipos compatibles (fecha, número, texto).

SELECT
    origen,
    COUNT(*)    AS cantidad_ventas,
    SUM(total)  AS total_origen
FROM (
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Norte' AS origen
    FROM ventas
    WHERE id_territorio = 1
    UNION ALL
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Resto del país' AS origen
    FROM ventas
    WHERE id_territorio <> 1
) AS consolidado
GROUP BY origen
ORDER BY total_origen DESC;

-- Resultado: Resto del país = 8 ventas y 4.344; Norte = 2 ventas
-- y 2.100. La suma da 6.444, el total facturado.


-- ============================================================
-- HALLAZGOS
-- ============================================================
-- 1. La categoría Computación explica el 76,8 % de la facturación
--    (4.950 de 6.444) con solo dos productos: Laptop Pro 15 y
--    Monitor 4K 27.
--
-- 2. La región Norte aporta el 32,6 % de la facturación (2.100)
--    con solo 2 ventas, y las dos son de un mismo cliente: Laura
--    Torres, de Tucumán. Si ese cliente deja de comprar, la región
--    queda en cero. Es el riesgo que plantea la pregunta 4 del brief.
--
-- 3. El ticket promedio de Norte (1.050) casi duplica al del resto
--    del país (543), porque sus dos ventas son de Computación.
--
-- 4. No hay clientes sin compras ni productos sin ventas: toda la
--    base de clientes y todo el catálogo tuvieron movimiento en
--    marzo de 2024.
-- ============================================================

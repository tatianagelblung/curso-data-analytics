RetailPro — Análisis de Ventas
Proyecto del curso de Data Analytics: un sistema de análisis de ventas para RetailPro, una distribuidora de tecnología, desde la base de datos relacional hasta el modelo analítico en Power BI.
Pregunta de negocio: ¿por qué cayeron las ventas de la región Norte en el último trimestre: se perdieron clientes, bajó el ticket promedio o cayó una categoría de producto?
Herramientas
SQL Server y SSMS (las ediciones Express y Developer son gratuitas): base de datos Ventas_Tech_DB y consultas de negocio.
Power BI Desktop (solo Windows): limpieza con Power Query, modelo en estrella y medidas DAX.
Estructura del repositorio
Archivo
Módulo
Qué contiene
modulo-3/ventas_tech_db_updated.sql
M3, actualizado en M5
Crea la base y las 5 tablas (categorias, clientes, territorios, productos y ventas) y carga 28 registros. Es la versión que hay que ejecutar.
modulo-3/ventas_tech_db.sql
M3
Versión original del checkpoint, con 4 tablas y sin territorios. Queda como historial.
RetailPro/m4_consultas_negocio.sql
M4
Resumen mensual, ranking de productos, clientes recurrentes y meses frente al promedio.
m5_consultas_joins.sql
M5
Vista base con INNER JOIN, clientes y productos sin ventas, y consolidado de Norte frente al resto del país.
modulo-8/Gelblung_Tatiana_Checkpoint2.pbix
M8
Modelo de Power BI: relaciones 1:N, tabla calendario Dim_Fechas y tabla _Medidas con 5 medidas DAX.

Cómo ejecutar los scripts SQL
Descargá el repositorio con el botón Code → Download ZIP, o clonalo:
git clone https://github.com/tatianagelblung/curso-data-analytics.git
Abrí SSMS y conectate a tu instancia de SQL Server.
Ejecutá los scripts en este orden. Abrí cada archivo y apretá F5:
modulo-3/ventas_tech_db_updated.sql: crea Ventas_Tech_DB si no existe, crea las tablas y carga los datos. Es repetible: se puede correr varias veces sin errores.
RetailPro/m4_consultas_negocio.sql
m5_consultas_joins.sql: necesita la tabla territorios, así que falla si antes corriste la versión original del M3.
Para verificar la carga, la sección de validación del primer script tiene que devolver 4, 5, 6, 10 y 3 filas.
Los scripts usan sintaxis de SQL Server (TOP, MONTH(), DROP TABLE IF EXISTS). Para PostgreSQL o MySQL hay que adaptarlos.
Datos y limitaciones
La base SQL tiene datos de ejemplo del curso: 10 ventas, todas de marzo de 2024, por un total de 6.444. Alcanzan para probar las consultas, pero no para analizar tendencias.
Cada venta se asignó a un territorio según la ciudad del cliente: Tucumán es Norte; Buenos Aires, Córdoba y Rosario, Centro; y Mendoza, Oeste. Es un supuesto para poder trabajar la pregunta de negocio.
El archivo de Power BI no lee la base SQL: parte de Pipeline_ETL_Dataset.xlsx, el dataset del curso (50 ventas entre enero de 2023 y julio de 2024), limpiado en el Módulo 6.
# curso-data-analytics

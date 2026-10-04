-- ============================================================
-- ventas_tech_db.sql
-- Checkpoint Módulo 3: Script SQL de Ingeniería de Datos
-- Caso: TechStore - base de datos Ventas_Tech_DB
-- Motor utilizado: SQL Server (SSMS)
--
-- Modelo:
--   categorias (1) ---- (N) productos (1) ---- (N) ventas (N) ---- (1) clientes
--
-- El script es repetible: se puede ejecutar completo varias
-- veces seguidas sin errores.
-- ============================================================


-- === SECCIÓN 0: BASE DE DATOS ===
-- Crea la base solo si todavía no existe y la selecciona,
-- para que las tablas no se creen por error en "master".

IF DB_ID('Ventas_Tech_DB') IS NULL
    CREATE DATABASE Ventas_Tech_DB;
GO

USE Ventas_Tech_DB;
GO


-- === SECCIÓN 1: DROP ===
-- Orden inverso a las dependencias: primero las tablas que
-- tienen foreign keys (ventas, productos) y al final las
-- tablas a las que esas claves apuntan (clientes, categorias).

DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;


-- === SECCIÓN 2: CREATE ===
-- Primero las dimensiones que no dependen de nadie
-- (categorias, clientes), después productos (depende de
-- categorias) y al final la tabla de hechos (ventas).

-- Dimensión: categorías de producto.
-- Va en tabla propia para no repetir el nombre de la categoría
-- en cada producto (3NF).
CREATE TABLE categorias (
    id_categoria      INT           PRIMARY KEY,
    nombre_categoria  VARCHAR(50)   NOT NULL,
    descripcion       VARCHAR(200)
);

-- Dimensión: clientes.
-- El email es UNIQUE: no puede haber dos clientes con el mismo.
CREATE TABLE clientes (
    id_cliente      INT           PRIMARY KEY,
    nombre          VARCHAR(100)  NOT NULL,
    email           VARCHAR(100)  UNIQUE,
    ciudad          VARCHAR(50),
    fecha_registro  DATE          NOT NULL
);

-- Dimensión: productos.
-- Cada producto pertenece a una categoría (FK a categorias).
-- precio usa DECIMAL(10,2) y no FLOAT, para no perder centavos.
CREATE TABLE productos (
    id_producto      INT            PRIMARY KEY,
    nombre_producto  VARCHAR(100)   NOT NULL,
    id_categoria     INT,
    precio           DECIMAL(10,2)  NOT NULL,
    stock            INT            DEFAULT 0,
    activo           BIT            DEFAULT 1,
    CONSTRAINT fk_productos_categorias
        FOREIGN KEY (id_categoria) REFERENCES categorias (id_categoria)
);

-- Tabla de hechos: ventas.
-- Cada venta referencia a un cliente y a un producto existentes.
-- precio_unitario guarda el precio cobrado en esa venta, que
-- puede diferir del precio actual del producto.
CREATE TABLE ventas (
    id_venta         INT            PRIMARY KEY,
    id_cliente       INT,
    id_producto      INT,
    cantidad         INT            NOT NULL,
    precio_unitario  DECIMAL(10,2)  NOT NULL,
    fecha_venta      DATE           NOT NULL,
    CONSTRAINT fk_ventas_clientes
        FOREIGN KEY (id_cliente)  REFERENCES clientes (id_cliente),
    CONSTRAINT fk_ventas_productos
        FOREIGN KEY (id_producto) REFERENCES productos (id_producto)
);


-- === SECCIÓN 3: INSERT ===
-- Mismo orden que el CREATE: primero las tablas sin
-- dependencias, para que cada foreign key encuentre su
-- registro. Total: 25 registros (4 + 5 + 6 + 10).

-- categorias: 4 registros
INSERT INTO categorias (id_categoria, nombre_categoria, descripcion) VALUES
  (1, 'Computación',    'Laptops, PCs y monitores'),
  (2, 'Accesorios',     'Periféricos y complementos'),
  (3, 'Audio',          'Auriculares y parlantes'),
  (4, 'Almacenamiento', 'Discos y memorias');

-- clientes: 5 registros
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
  (1, 'María López',  'maria@mail.com',  'Buenos Aires', '2024-01-05'),
  (2, 'Carlos Ruiz',  'carlos@mail.com', 'Córdoba',      '2024-01-10'),
  (3, 'Ana Gómez',    'ana@mail.com',    'Rosario',      '2024-02-01'),
  (4, 'Pedro Sanz',   'pedro@mail.com',  'Mendoza',      '2024-02-15'),
  (5, 'Laura Torres', 'laura@mail.com',  'Tucumán',      '2024-03-01');

-- productos: 6 registros
INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
  (1, 'Laptop Pro 15',      1, 1200.00, 15, 1),
  (2, 'Mouse Inalámbrico',  2,   28.00, 80, 1),
  (3, 'Monitor 4K 27',      1,  450.00, 12, 1),
  (4, 'Auriculares BT Pro', 3,  120.00, 35, 1),
  (5, 'SSD Externo 1TB',    4,  130.00, 18, 1),
  (6, 'Teclado Mecánico',   2,   95.00, 40, 1);

-- ventas: 10 registros
INSERT INTO ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
  ( 1, 1, 1, 2, 1200.00, '2024-03-05'),
  ( 2, 2, 2, 5,   28.00, '2024-03-06'),
  ( 3, 3, 3, 1,  450.00, '2024-03-07'),
  ( 4, 1, 4, 2,  120.00, '2024-03-08'),
  ( 5, 4, 5, 3,  130.00, '2024-03-10'),
  ( 6, 2, 6, 4,   95.00, '2024-03-11'),
  ( 7, 5, 1, 1, 1200.00, '2024-03-12'),
  ( 8, 3, 2, 8,   28.00, '2024-03-13'),
  ( 9, 4, 4, 1,  120.00, '2024-03-14'),
  (10, 5, 3, 2,  450.00, '2024-03-15');


-- === SECCIÓN 4: VALIDACIÓN ===
-- Confirma que cada tabla cargó la cantidad de filas esperada.

SELECT * FROM categorias;   -- esperado: 4 filas
SELECT * FROM clientes;     -- esperado: 5 filas
SELECT * FROM productos;    -- esperado: 6 filas
SELECT * FROM ventas;       -- esperado: 10 filas

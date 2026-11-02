create database romex on primary (
  name = romexData,
  filename = 'C:\BD\romex.mdf',
  size = 50mb,
  filegrowth = 25 %
) log on (
  name = romexLog,
  filename = 'C:\BD\romex_log.ldf',
  size = 25mb,
  filegrowth = 25 %
);
alter database romex
add filegroup secundario;
alter database romex
add file (
    name = romexSecundario,
    filename = 'C:\BD\romex_secundario.ndf',
    size = 15mb,
    filegrowth = 25 %
  ) to filegroup secundario;
--Crear más de 3 tablas (NO DEBE LLEVAR ESPACIOS, Ñ, NI CARACTERES EXTRAÑOS) 
use romex;
create table categoria(
  id_categoria int identity(1, 1) primary key,
  nombre varchar(50) not null
);
create table producto(
  id_producto int identity(1, 1) primary key,
  nombre varchar(80) not null,
  precio decimal(10, 2) not null,
  stock int not null,
  id_categoria int not null
);
create table proveedor(
  id_proveedor int identity(1, 1) primary key,
  nombre varchar(80) not null,
  telefono varchar(15) not null
);
create table entrada(
  id_entrada int identity(1, 1) primary key,
  id_producto int not null,
  id_proveedor int not null,
  fecha date not null,
  cantidad int not null
);
alter table producto
add constraint fk_producto_categoria foreign key (id_categoria) references categoria(id_categoria);
alter table entrada
add constraint fk_entrada_producto foreign key (id_producto) references producto(id_producto);
alter table entrada
add constraint fk_entrada_proveedor foreign key (id_proveedor) references proveedor(id_proveedor);
insert into categoria(nombre)
values ('Laptops'),
  ('Accesorios');
insert into proveedor(nombre, telefono)
values ('TechSupply', '8671234567'),
  ('DigitalStore', '8677654321');
insert into producto(nombre, precio, stock, id_categoria)
values ('Laptop HP', 15000.00, 10, 1),
  ('Mouse Logitech', 350.00, 25, 2);
insert into entrada(id_producto, id_proveedor, fecha, cantidad)
values (1, 1, getdate(), 5),
  (2, 2, getdate(), 15);
exec sp_rename 'entrada',
'movimiento';
exec sp_rename 'proveedor.telefono',
'telefono_contacto',
'COLUMN';
alter table proveedor
add constraint uq_proveedor_nombre unique(nombre);
alter table producto
add constraint ck_producto_stock check(stock >= 0);
select constraint_name,
  table_name,
  constraint_type
from information_schema.table_constraints
where table_name in ('proveedor', 'producto');
alter table producto drop constraint ck_producto_stock;


-- ? Crear una instantánea de la base de datos con el siguiente formato de ejemplo
use master;
create database romex_snapshot on (
  name = romexData,
  filename = 'C:\BD\romexData_snapshot.ss'
),
(
  name = romexSecundario,
  filename = 'C:\BD\romexSecundario_snapshot.ss'
) as snapshot of romex;

-- ? Crear un login para un usuario que pueda tener acceso a esa BD (tanto en código como en forma manual (con capturas de pantalla)
create login romex_user with password = 'Romex#2026*Segura',;
use romex;
create user romex_user for login romex_user;
alter role db_datareader
add member romex_user;
alter role db_datawriter
add member romex_user;
-- ? Obtener un respaldo de la BD creada por código y manual
use master;
backup database romex to disk = 'C:\BD\romex_full.bak' with init,
name = 'romex respaldo completo',
stats = 10;
-- ? Crea una consulta con un join y justifica porque es importante para la solución del problema planteado
use romex;
select movimiento.id_entrada,
  movimiento.fecha,
  producto.nombre as producto,
  categoria.nombre as categoria,
  proveedor.nombre as proveedor,
  proveedor.telefono_contacto,
  movimiento.cantidad,
  producto.precio,
  (movimiento.cantidad * producto.precio) as importe_estimado
from movimiento
  inner join producto on movimiento.id_producto = producto.id_producto
  inner join categoria on producto.id_categoria = categoria.id_categoria
  inner join proveedor on movimiento.id_proveedor = proveedor.id_proveedor;
-- * permite ver el detalle completo de cada movimiento (producto, categoria y proveedor) para control de inventario y trazabilidad de entradas.
-- ? Crea una consulta con un group by y justifica porque es importante para la solución del problema planteado
select categoria.nombre as categoria,
  producto.nombre as producto,
  sum(movimiento.cantidad) as total_entradas
from movimiento
  inner join producto on movimiento.id_producto = producto.id_producto
  inner join categoria on producto.id_categoria = categoria.id_categoria
group by categoria.nombre,
  producto.nombre
order by categoria.nombre,
  producto.nombre;
-- * resume las entradas por producto/categoria para analizar rotacion y planear compras (decisiones basadas en volumen).
-- ? Crea una consulta con un between y justifica porque es importante para la solución del problema planteado
select movimiento.id_entrada,
  movimiento.fecha,
  producto.nombre as producto,
  movimiento.cantidad
from movimiento
  inner join producto on movimiento.id_producto = producto.id_producto
where movimiento.fecha between '2026-02-01' and '2026-02-28'
order by movimiento.fecha;
-- * filtra movimientos por rango de fechas para reportes mensuales, auditoria y comparacion por periodos.
-- ? Crea una consulta con una función de agregado  y justifica porque es importante para la solución del problema planteado
select count(*) as total_movimientos,
  sum(movimiento.cantidad) as piezas_totales_entradas,
  avg(cast(movimiento.cantidad as decimal(10, 2))) as promedio_piezas_por_movimiento
from movimiento;
-- * entrega indicadores rapidos (cantidad de movimientos, volumen total y promedio) para evaluar carga operativa y demanda.
-- ? Crea una vista  y justifica porque es importante para la solución del problema planteado
create view vw_movimientos_detalle as
select movimiento.id_entrada,
  movimiento.fecha,
  producto.id_producto,
  producto.nombre as producto,
  categoria.nombre as categoria,
  proveedor.id_proveedor,
  proveedor.nombre as proveedor,
  movimiento.cantidad,
  producto.precio,
  (movimiento.cantidad * producto.precio) as importe_estimado
from movimiento
  inner join producto on movimiento.id_producto = producto.id_producto
  inner join categoria on producto.id_categoria = categoria.id_categoria
  inner join proveedor on movimiento.id_proveedor = proveedor.id_proveedor;
-- * centraliza una consulta recurrente (detalle de movimientos) para reutilizarla en reportes sin reescribir joins.
-- ? Crea una subconsulta indica que tipo es y justifica porque es importante para la solución del problema planteado
select producto.id_producto,
  producto.nombre,
  producto.stock
from producto
where producto.id_producto in (
    select movimiento.id_producto
    from movimiento
  );
-- ? identifica productos que ya tienen movimientos registrados (productos con actividad), util para validar catalogo y evitar registros “muertos”.
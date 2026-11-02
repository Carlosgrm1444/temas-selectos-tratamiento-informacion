-- Proyecto Unidad 2
-- ? Juan Manuel Ortega García
-- ! Bernardo Guillermo Núñez López
-- * Carlos Gabriel Rodríguez Macias

-- ? Estructura transcrita de las figuras 6 y 6.1 del documento del proyecto 1.
-- * No se utilizaron los scripts locales de Unidad1 como código base.
-- * Cambiamos únicamente el esquema de destino para conservar los datos de dbo.
-- * Ejecutar este archivo una sola vez, después de revisar la base seleccionada.
Use pepsi_distribucion;
GO

Create Schema proyecto_u2;
GO

-- ? Almacén de referencia. No es un cuarto CSV ni una cuarta tabla analizada.
Create Table proyecto_u2.almacen
(
  id_almacen int Primary Key Identity(1, 1),
  clave_almacen varchar(10) Not Null Unique,
  nombre varchar(100) Not Null,
  ubicacion varchar(200) Not Null,
  activo bit Not Null Default 1
);

Create Table proyecto_u2.producto
(
  id_producto int Primary Key Identity(1, 1),
  clave_producto varchar(15) Not Null Unique,
  nombre varchar(100) Not Null,
  presentacion varchar(50) Not Null,
  precio decimal(10, 2) Not Null,
  activo bit Not Null Default 1,
  Constraint ck_u2_producto_precio Check (precio > 0)
);

Create Table proyecto_u2.lote
(
  id_lote int Primary Key Identity(1, 1),
  id_producto int Not Null,
  numero_lote varchar(30) Not Null,
  fecha_recepcion date Not Null,
  fecha_caducidad date Not Null,
  Constraint fk_u2_lote_producto Foreign Key (id_producto)
    References proyecto_u2.producto(id_producto),
  Constraint uq_u2_lote_producto_numero Unique (id_producto, numero_lote),
  Constraint uq_u2_lote_validacion Unique (id_lote, id_producto),
  Constraint ck_u2_lote_fechas Check (fecha_caducidad > fecha_recepcion)
);

Create Table proyecto_u2.inventario_lote
(
  id_inventario int Primary Key Identity(1, 1),
  id_almacen int Not Null,
  id_lote int Not Null,
  id_producto int Not Null,
  cantidad int Not Null Default 0,
  fecha_actualizacion datetime2 Not Null Default Sysdatetime(),
  Constraint fk_u2_inventario_almacen Foreign Key (id_almacen)
    References proyecto_u2.almacen(id_almacen),
  Constraint fk_u2_inventario_lote_producto Foreign Key (id_lote, id_producto)
    References proyecto_u2.lote(id_lote, id_producto),
  Constraint uq_u2_inventario_almacen_lote Unique (id_almacen, id_lote),
  Constraint uq_u2_inventario_validacion
    Unique (id_inventario, id_lote, id_producto, id_almacen),
  Constraint ck_u2_inventario_cantidad Check (cantidad >= 0)
);
GO


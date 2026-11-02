-- ? Punto 2. Modelo relacional.
-- ? Objetivo: crear las 13 tablas, llaves, restricciones e indices del proyecto.
-- ! Requisito: ejecutar primero el Punto 1.

Use pepsi_distribucion;
GO

-- ? 2.1 Tablas del grupo PRIMARY.
Create Table dbo.tienda
(
  id_tienda int Primary Key Identity(1, 1),
  clave_tienda varchar(10) Not Null Unique,
  nombre varchar(100) Not Null,
  direccion varchar(200) Not Null,
  ciudad varchar(80) Not Null,
  activo bit Not Null Default 1
) On [PRIMARY];

Create Table dbo.producto
(
  id_producto int Primary Key Identity(1, 1),
  clave_producto varchar(15) Not Null Unique,
  nombre varchar(100) Not Null,
  presentacion varchar(50) Not Null,
  precio decimal(10, 2) Not Null,
  activo bit Not Null Default 1,
  Constraint ck_producto_precio Check (precio > 0)
) On [PRIMARY];

Create Table dbo.almacen
(
  id_almacen int Primary Key Identity(1, 1),
  clave_almacen varchar(10) Not Null Unique,
  nombre varchar(100) Not Null,
  ubicacion varchar(200) Not Null,
  activo bit Not Null Default 1
) On [PRIMARY];

Create Table dbo.pedido
(
  id_pedido int Primary Key Identity(1, 1),
  folio varchar(20) Not Null Unique,
  id_tienda int Not Null,
  fecha_pedido datetime2 Not Null Default Sysdatetime(),
  fecha_requerida date Not Null,
  estado varchar(20) Not Null Default 'PENDIENTE',
  usuario_captura sysname Not Null Default User_Name(),
  Constraint fk_pedido_tienda Foreign Key (id_tienda)
    References dbo.tienda(id_tienda),
  Constraint ck_pedido_estado Check
    (estado In ('PENDIENTE', 'PARCIAL', 'COMPLETADO', 'CANCELADO'))
) On [PRIMARY];

Create Table dbo.detalle_pedido
(
  id_detalle_pedido int Primary Key Identity(1, 1),
  id_pedido int Not Null,
  id_producto int Not Null,
  cantidad_solicitada int Not Null,
  precio_unitario decimal(10, 2) Not Null,
  Constraint fk_detalle_pedido_pedido Foreign Key (id_pedido)
    References dbo.pedido(id_pedido),
  Constraint fk_detalle_pedido_producto Foreign Key (id_producto)
    References dbo.producto(id_producto),
  Constraint uq_detalle_pedido_producto Unique (id_pedido, id_producto),
  Constraint uq_detalle_pedido_validacion
    Unique (id_detalle_pedido, id_pedido, id_producto),
  Constraint ck_detalle_pedido_cantidad Check (cantidad_solicitada > 0),
  Constraint ck_detalle_pedido_precio Check (precio_unitario > 0)
) On [PRIMARY];
GO

-- ? 2.2 Tablas del grupo SECUNDARIO.
Create Table dbo.lote
(
  id_lote int Primary Key Identity(1, 1),
  id_producto int Not Null,
  numero_lote varchar(30) Not Null,
  fecha_recepcion date Not Null,
  fecha_caducidad date Not Null,
  Constraint fk_lote_producto Foreign Key (id_producto)
    References dbo.producto(id_producto),
  Constraint uq_lote_producto_numero Unique (id_producto, numero_lote),
  Constraint uq_lote_validacion Unique (id_lote, id_producto),
  Constraint ck_lote_fechas Check (fecha_caducidad > fecha_recepcion)
) On SECUNDARIO;

Create Table dbo.inventario_lote
(
  id_inventario int Primary Key Identity(1, 1),
  id_almacen int Not Null,
  id_lote int Not Null,
  id_producto int Not Null,
  cantidad int Not Null Default 0,
  fecha_actualizacion datetime2 Not Null Default Sysdatetime(),
  Constraint fk_inventario_almacen Foreign Key (id_almacen)
    References dbo.almacen(id_almacen),
  Constraint fk_inventario_lote_producto Foreign Key (id_lote, id_producto)
    References dbo.lote(id_lote, id_producto),
  Constraint uq_inventario_almacen_lote Unique (id_almacen, id_lote),
  Constraint uq_inventario_validacion
    Unique (id_inventario, id_lote, id_producto, id_almacen),
  Constraint ck_inventario_cantidad Check (cantidad >= 0)
) On SECUNDARIO;

Create Table dbo.entrega
(
  id_entrega int Primary Key Identity(1, 1),
  folio varchar(20) Not Null Unique,
  id_pedido int Not Null,
  fecha_salida datetime2 Not Null Default Sysdatetime(),
  fecha_entrega datetime2 Null,
  estado varchar(20) Not Null Default 'PROGRAMADA',
  repartidor_usuario sysname Not Null,
  Constraint fk_entrega_pedido Foreign Key (id_pedido)
    References dbo.pedido(id_pedido),
  Constraint uq_entrega_validacion Unique (id_entrega, id_pedido),
  Constraint ck_entrega_estado Check
    (estado In ('PROGRAMADA', 'EN_RUTA', 'PARCIAL', 'ENTREGADA', 'CON_INCIDENCIA'))
) On SECUNDARIO;

Create Table dbo.detalle_entrega
(
  id_detalle_entrega int Primary Key Identity(1, 1),
  id_entrega int Not Null,
  id_pedido int Not Null,
  id_detalle_pedido int Not Null,
  id_producto int Not Null,
  id_lote int Not Null,
  cantidad_entregada int Not Null,
  cantidad_danada int Not Null Default 0,
  Constraint fk_detalle_entrega_entrega Foreign Key (id_entrega, id_pedido)
    References dbo.entrega(id_entrega, id_pedido),
  Constraint fk_detalle_entrega_pedido Foreign Key
    (id_detalle_pedido, id_pedido, id_producto)
    References dbo.detalle_pedido(id_detalle_pedido, id_pedido, id_producto),
  Constraint fk_detalle_entrega_lote Foreign Key (id_lote, id_producto)
    References dbo.lote(id_lote, id_producto),
  Constraint uq_detalle_entrega_validacion
    Unique (id_detalle_entrega, id_entrega),
  Constraint ck_detalle_entrega_cantidades Check
    (cantidad_entregada >= 0 And cantidad_danada >= 0)
) On SECUNDARIO;

Create Table dbo.incidencia
(
  id_incidencia int Primary Key Identity(1, 1),
  id_entrega int Not Null,
  id_detalle_entrega int Null,
  tipo varchar(20) Not Null,
  descripcion varchar(300) Not Null,
  cantidad_afectada int Not Null Default 0,
  estado varchar(20) Not Null Default 'ABIERTA',
  fecha_registro datetime2 Not Null Default Sysdatetime(),
  fecha_cierre datetime2 Null,
  Constraint fk_incidencia_entrega Foreign Key (id_entrega)
    References dbo.entrega(id_entrega),
  Constraint fk_incidencia_detalle Foreign Key (id_detalle_entrega, id_entrega)
    References dbo.detalle_entrega(id_detalle_entrega, id_entrega),
  Constraint ck_incidencia_tipo Check
    (tipo In ('FALTANTE', 'DANADO', 'RETRASO', 'OTRO')),
  Constraint ck_incidencia_cantidad Check (cantidad_afectada >= 0),
  Constraint ck_incidencia_estado Check
    (estado In ('ABIERTA', 'EN_REVISION', 'CERRADA'))
) On SECUNDARIO;

Create Table dbo.movimiento_inventario
(
  id_movimiento int Primary Key Identity(1, 1),
  id_inventario int Not Null,
  id_lote int Not Null,
  id_producto int Not Null,
  id_almacen int Not Null,
  tipo_movimiento varchar(15) Not Null,
  cantidad int Not Null,
  motivo varchar(200) Not Null,
  responsable sysname Not Null,
  fecha_movimiento datetime2 Not Null Default Sysdatetime(),
  Constraint fk_movimiento_inventario Foreign Key
    (id_inventario, id_lote, id_producto, id_almacen)
    References dbo.inventario_lote
      (id_inventario, id_lote, id_producto, id_almacen),
  Constraint ck_movimiento_tipo Check
    (tipo_movimiento In ('ENTRADA', 'SALIDA', 'AJUSTE', 'DEVOLUCION')),
  Constraint ck_movimiento_cantidad Check (cantidad <> 0)
) On SECUNDARIO;

Create Table dbo.conteo_inventario
(
  id_conteo int Primary Key Identity(1, 1),
  id_almacen int Not Null,
  fecha_conteo datetime2 Not Null Default Sysdatetime(),
  responsable sysname Not Null,
  estado varchar(15) Not Null Default 'ABIERTO',
  Constraint fk_conteo_almacen Foreign Key (id_almacen)
    References dbo.almacen(id_almacen),
  Constraint ck_conteo_estado Check
    (estado In ('ABIERTO', 'APLICADO', 'CANCELADO'))
) On SECUNDARIO;

Create Table dbo.detalle_conteo
(
  id_detalle_conteo int Primary Key Identity(1, 1),
  id_conteo int Not Null,
  id_inventario int Not Null,
  cantidad_sistema int Not Null,
  cantidad_fisica int Not Null,
  diferencia As (cantidad_fisica - cantidad_sistema) Persisted,
  observacion varchar(200) Null,
  Constraint fk_detalle_conteo_conteo Foreign Key (id_conteo)
    References dbo.conteo_inventario(id_conteo),
  Constraint fk_detalle_conteo_inventario Foreign Key (id_inventario)
    References dbo.inventario_lote(id_inventario),
  Constraint uq_detalle_conteo Unique (id_conteo, id_inventario),
  Constraint ck_detalle_conteo_cantidades Check
    (cantidad_sistema >= 0 And cantidad_fisica >= 0)
) On SECUNDARIO;
GO

-- ? 2.3 Crear indices para las consultas del proyecto.
Create Index ix_lote_producto_caducidad
On dbo.lote(id_producto, fecha_caducidad);

Create Index ix_inventario_producto_almacen
On dbo.inventario_lote(id_producto, id_almacen);

Create Index ix_pedido_estado_fecha
On dbo.pedido(estado, fecha_pedido);

Create Index ix_entrega_pedido_estado
On dbo.entrega(id_pedido, estado);

Create Index ix_incidencia_tipo_estado
On dbo.incidencia(tipo, estado);

Create Index ix_movimiento_lote_fecha
On dbo.movimiento_inventario(id_lote, fecha_movimiento);
GO

-- ? 2.4 Verificar tablas, grupos de archivos y llaves.
Select
  tabla.name As tabla,
  grupo.name As grupo_archivos
From sys.tables tabla
Inner Join sys.indexes indice
  On tabla.object_id = indice.object_id
  And indice.index_id In (0, 1)
Inner Join sys.filegroups grupo
  On indice.data_space_id = grupo.data_space_id
Order By tabla.name;

Select
  tabla.name As tabla,
  llave.name As llave,
  llave.type_desc As tipo
From sys.key_constraints llave
Inner Join sys.tables tabla
  On llave.parent_object_id = tabla.object_id
Order By tabla.name, llave.type_desc;

Select
  Object_Name(parent_object_id) As tabla,
  name As llave_foranea
From sys.foreign_keys
Order By tabla, llave_foranea;

-- * Evidencia: tomar captura de las 13 tablas con su grupo y de las llaves creadas.

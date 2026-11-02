-- ? Punto 3. Datos y operaciones de prueba.
-- ? Objetivo: demostrar un pedido normal, uno parcial, uno dañado y una diferencia de inventario.
-- ! Requisito: ejecutar primero los puntos 1 y 2. Los datos son ficticios.

Use pepsi_distribucion;
GO

Set Xact_Abort On;
Begin Transaction;

-- ? 3.1 Insertar catalogos ficticios.
Insert Into dbo.tienda
  (clave_tienda, nombre, direccion, ciudad)
Values
  ('T001', 'Tienda Centro', 'Calle Reforma 100', 'Nuevo Laredo'),
  ('T002', 'Tienda Aeropuerto', 'Avenida Aeropuerto 250', 'Nuevo Laredo'),
  ('T003', 'Tienda Universidad', 'Boulevard Universidad 500', 'Nuevo Laredo');

Insert Into dbo.producto
  (clave_producto, nombre, presentacion, precio)
Values
  ('BEB-001', 'Bebida cola', '600 ml', 18.50),
  ('BEB-002', 'Bebida cola sin azucar', '600 ml', 19.00),
  ('BEB-003', 'Agua mineral', '600 ml', 16.50);

Insert Into dbo.almacen
  (clave_almacen, nombre, ubicacion)
Values
  ('A001', 'Almacen principal', 'Parque Industrial de Nuevo Laredo');

Declare @almacen int =
  (Select id_almacen From dbo.almacen Where clave_almacen = 'A001');
Declare @producto1 int =
  (Select id_producto From dbo.producto Where clave_producto = 'BEB-001');
Declare @producto2 int =
  (Select id_producto From dbo.producto Where clave_producto = 'BEB-002');
Declare @producto3 int =
  (Select id_producto From dbo.producto Where clave_producto = 'BEB-003');

Insert Into dbo.lote
  (id_producto, numero_lote, fecha_recepcion, fecha_caducidad)
Values
  (@producto1, 'L-COLA-001', '2026-09-01', '2027-03-01'),
  (@producto2, 'L-SINAZ-001', '2026-09-01', '2027-03-01'),
  (@producto3, 'L-AGUA-001', '2026-09-02', '2027-06-01');

Declare @lote1 int =
  (Select id_lote From dbo.lote Where numero_lote = 'L-COLA-001');
Declare @lote2 int =
  (Select id_lote From dbo.lote Where numero_lote = 'L-SINAZ-001');
Declare @lote3 int =
  (Select id_lote From dbo.lote Where numero_lote = 'L-AGUA-001');

Insert Into dbo.inventario_lote
  (id_almacen, id_lote, id_producto, cantidad)
Values
  (@almacen, @lote1, @producto1, 100),
  (@almacen, @lote2, @producto2, 80),
  (@almacen, @lote3, @producto3, 60);

Insert Into dbo.movimiento_inventario
  (id_inventario, id_lote, id_producto, id_almacen,
   tipo_movimiento, cantidad, motivo, responsable)
Select
  id_inventario, id_lote, id_producto, id_almacen,
  'ENTRADA', cantidad, 'Inventario inicial ficticio', 'encargado_almacen'
From dbo.inventario_lote;

-- ? 3.2 Pedido normal y entrega completa.
Declare @tienda1 int =
  (Select id_tienda From dbo.tienda Where clave_tienda = 'T001');

Insert Into dbo.pedido
  (folio, id_tienda, fecha_requerida, estado, usuario_captura)
Values
  ('PED-001', @tienda1, '2026-09-26', 'COMPLETADO', 'usuario_captura');

Declare @pedido1 int = Scope_Identity();

Insert Into dbo.detalle_pedido
  (id_pedido, id_producto, cantidad_solicitada, precio_unitario)
Values
  (@pedido1, @producto1, 10, 18.50),
  (@pedido1, @producto2, 5, 19.00);

Insert Into dbo.entrega
  (folio, id_pedido, fecha_entrega, estado, repartidor_usuario)
Values
  ('ENT-001', @pedido1, Sysdatetime(), 'ENTREGADA', 'usuario_reparto');

Declare @entrega1 int = Scope_Identity();

Insert Into dbo.detalle_entrega
  (id_entrega, id_pedido, id_detalle_pedido, id_producto,
   id_lote, cantidad_entregada, cantidad_danada)
Select
  @entrega1, id_pedido, id_detalle_pedido, id_producto,
  Case When id_producto = @producto1 Then @lote1 Else @lote2 End,
  cantidad_solicitada, 0
From dbo.detalle_pedido
Where id_pedido = @pedido1;

Update dbo.inventario_lote
Set cantidad = cantidad - 10,
    fecha_actualizacion = Sysdatetime()
Where id_almacen = @almacen And id_lote = @lote1;

Update dbo.inventario_lote
Set cantidad = cantidad - 5,
    fecha_actualizacion = Sysdatetime()
Where id_almacen = @almacen And id_lote = @lote2;

-- ? 3.3 Pedido con entrega parcial.
Declare @tienda2 int =
  (Select id_tienda From dbo.tienda Where clave_tienda = 'T002');

Insert Into dbo.pedido
  (folio, id_tienda, fecha_requerida, estado, usuario_captura)
Values
  ('PED-002', @tienda2, '2026-09-26', 'PARCIAL', 'usuario_captura');

Declare @pedido2 int = Scope_Identity();

Insert Into dbo.detalle_pedido
  (id_pedido, id_producto, cantidad_solicitada, precio_unitario)
Values
  (@pedido2, @producto1, 20, 18.50),
  (@pedido2, @producto3, 10, 16.50);

Insert Into dbo.entrega
  (folio, id_pedido, fecha_entrega, estado, repartidor_usuario)
Values
  ('ENT-002', @pedido2, Sysdatetime(), 'PARCIAL', 'usuario_reparto');

Declare @entrega2 int = Scope_Identity();

Insert Into dbo.detalle_entrega
  (id_entrega, id_pedido, id_detalle_pedido, id_producto,
   id_lote, cantidad_entregada, cantidad_danada)
Select
  @entrega2, id_pedido, id_detalle_pedido, id_producto,
  Case When id_producto = @producto1 Then @lote1 Else @lote3 End,
  Case When id_producto = @producto1 Then 12 Else 10 End,
  0
From dbo.detalle_pedido
Where id_pedido = @pedido2;

Insert Into dbo.incidencia
  (id_entrega, id_detalle_entrega, tipo, descripcion, cantidad_afectada)
Select
  @entrega2, id_detalle_entrega, 'FALTANTE',
  'Quedaron ocho unidades pendientes de entrega', 8
From dbo.detalle_entrega
Where id_entrega = @entrega2 And id_producto = @producto1;

Update dbo.inventario_lote
Set cantidad = cantidad - 12,
    fecha_actualizacion = Sysdatetime()
Where id_almacen = @almacen And id_lote = @lote1;

Update dbo.inventario_lote
Set cantidad = cantidad - 10,
    fecha_actualizacion = Sysdatetime()
Where id_almacen = @almacen And id_lote = @lote3;

-- ? 3.4 Pedido con producto dañado.
Declare @tienda3 int =
  (Select id_tienda From dbo.tienda Where clave_tienda = 'T003');

Insert Into dbo.pedido
  (folio, id_tienda, fecha_requerida, estado, usuario_captura)
Values
  ('PED-003', @tienda3, '2026-09-27', 'PARCIAL', 'usuario_captura');

Declare @pedido3 int = Scope_Identity();

Insert Into dbo.detalle_pedido
  (id_pedido, id_producto, cantidad_solicitada, precio_unitario)
Values
  (@pedido3, @producto2, 15, 19.00);

Declare @detalle_pedido3 int = Scope_Identity();

Insert Into dbo.entrega
  (folio, id_pedido, fecha_entrega, estado, repartidor_usuario)
Values
  ('ENT-003', @pedido3, Sysdatetime(), 'CON_INCIDENCIA', 'usuario_reparto');

Declare @entrega3 int = Scope_Identity();

Insert Into dbo.detalle_entrega
  (id_entrega, id_pedido, id_detalle_pedido, id_producto,
   id_lote, cantidad_entregada, cantidad_danada)
Values
  (@entrega3, @pedido3, @detalle_pedido3, @producto2,
   @lote2, 12, 3);

Declare @detalle_entrega3 int = Scope_Identity();

Insert Into dbo.incidencia
  (id_entrega, id_detalle_entrega, tipo, descripcion, cantidad_afectada)
Values
  (@entrega3, @detalle_entrega3, 'DANADO',
   'Tres botellas llegaron dañadas', 3);

Update dbo.inventario_lote
Set cantidad = cantidad - 15,
    fecha_actualizacion = Sysdatetime()
Where id_almacen = @almacen And id_lote = @lote2;

-- ? 3.5 Registrar las salidas de inventario.
Insert Into dbo.movimiento_inventario
  (id_inventario, id_lote, id_producto, id_almacen,
   tipo_movimiento, cantidad, motivo, responsable)
Select id_inventario, id_lote, id_producto, id_almacen,
  'SALIDA', -22, 'Entregas ENT-001 y ENT-002', 'encargado_almacen'
From dbo.inventario_lote
Where id_almacen = @almacen And id_lote = @lote1;

Insert Into dbo.movimiento_inventario
  (id_inventario, id_lote, id_producto, id_almacen,
   tipo_movimiento, cantidad, motivo, responsable)
Select id_inventario, id_lote, id_producto, id_almacen,
  'SALIDA', -20, 'Entregas ENT-001 y ENT-003', 'encargado_almacen'
From dbo.inventario_lote
Where id_almacen = @almacen And id_lote = @lote2;

Insert Into dbo.movimiento_inventario
  (id_inventario, id_lote, id_producto, id_almacen,
   tipo_movimiento, cantidad, motivo, responsable)
Select id_inventario, id_lote, id_producto, id_almacen,
  'SALIDA', -10, 'Entrega ENT-002', 'encargado_almacen'
From dbo.inventario_lote
Where id_almacen = @almacen And id_lote = @lote3;

-- ? 3.6 Registrar una diferencia en el conteo fisico.
Insert Into dbo.conteo_inventario
  (id_almacen, responsable, estado)
Values
  (@almacen, 'usuario_almacen', 'APLICADO');

Declare @conteo int = Scope_Identity();
Declare @inventario1 int =
  (Select id_inventario From dbo.inventario_lote
   Where id_almacen = @almacen And id_lote = @lote1);

Insert Into dbo.detalle_conteo
  (id_conteo, id_inventario, cantidad_sistema,
   cantidad_fisica, observacion)
Values
  (@conteo, @inventario1, 78, 76,
   'Diferencia ficticia de dos unidades');

Update dbo.inventario_lote
Set cantidad = 76,
    fecha_actualizacion = Sysdatetime()
Where id_inventario = @inventario1;

Insert Into dbo.movimiento_inventario
  (id_inventario, id_lote, id_producto, id_almacen,
   tipo_movimiento, cantidad, motivo, responsable)
Values
  (@inventario1, @lote1, @producto1, @almacen,
   'AJUSTE', -2, 'Diferencia encontrada en conteo fisico', 'usuario_almacen');

Commit Transaction;
GO

-- ? 3.7 Verificar los cuatro casos.
Select folio, estado, usuario_captura
From dbo.pedido
Order By id_pedido;

Select
  pedido.folio As pedido,
  entrega.folio As entrega,
  producto.nombre As producto,
  detalle_pedido.cantidad_solicitada,
  detalle_entrega.cantidad_entregada,
  detalle_entrega.cantidad_danada
From dbo.pedido pedido
Inner Join dbo.detalle_pedido detalle_pedido
  On pedido.id_pedido = detalle_pedido.id_pedido
Left Join dbo.detalle_entrega detalle_entrega
  On detalle_pedido.id_detalle_pedido = detalle_entrega.id_detalle_pedido
Left Join dbo.entrega entrega
  On detalle_entrega.id_entrega = entrega.id_entrega
Inner Join dbo.producto producto
  On detalle_pedido.id_producto = producto.id_producto
Order By pedido.folio, producto.nombre;

Select tipo, descripcion, cantidad_afectada, estado
From dbo.incidencia
Order By id_incidencia;

Select cantidad_sistema, cantidad_fisica, diferencia, observacion
From dbo.detalle_conteo;

-- * Evidencia: tomar captura de los pedidos, entregas, incidencias y diferencia del conteo.

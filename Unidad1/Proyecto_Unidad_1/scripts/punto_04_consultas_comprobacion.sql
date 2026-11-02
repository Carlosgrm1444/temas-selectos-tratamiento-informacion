-- ? Punto 4. Consultas de comprobacion.
-- ? Objetivo: consultar pendientes, existencias, faltantes, daños y diferencias.
-- ! Requisito: ejecutar primero los puntos 1, 2 y 3.

Use pepsi_distribucion;
GO

-- ? 4.1 Pedidos pendientes o parciales.
Select
  pedido.folio,
  tienda.nombre As tienda,
  pedido.fecha_requerida,
  pedido.estado
From dbo.pedido pedido
Inner Join dbo.tienda tienda
  On pedido.id_tienda = tienda.id_tienda
Where pedido.estado In ('PENDIENTE', 'PARCIAL')
Order By pedido.fecha_requerida;

-- ? 4.2 Existencias actuales por lote.
Select
  almacen.nombre As almacen,
  producto.nombre As producto,
  lote.numero_lote,
  lote.fecha_caducidad,
  inventario.cantidad
From dbo.inventario_lote inventario
Inner Join dbo.almacen almacen
  On inventario.id_almacen = almacen.id_almacen
Inner Join dbo.lote lote
  On inventario.id_lote = lote.id_lote
Inner Join dbo.producto producto
  On inventario.id_producto = producto.id_producto
Order By producto.nombre, lote.fecha_caducidad;

-- ? 4.3 Faltantes de los pedidos.
Select
  pedido.folio,
  producto.nombre As producto,
  detalle.cantidad_solicitada,
  Isnull(entregado.cantidad_entregada, 0) As cantidad_entregada,
  detalle.cantidad_solicitada - Isnull(entregado.cantidad_entregada, 0) As faltante
From dbo.detalle_pedido detalle
Inner Join dbo.pedido pedido
  On detalle.id_pedido = pedido.id_pedido
Inner Join dbo.producto producto
  On detalle.id_producto = producto.id_producto
Outer Apply
(
  Select Sum(detalle_entrega.cantidad_entregada) As cantidad_entregada
  From dbo.detalle_entrega detalle_entrega
  Where detalle_entrega.id_detalle_pedido = detalle.id_detalle_pedido
) entregado
Where detalle.cantidad_solicitada > Isnull(entregado.cantidad_entregada, 0)
Order By pedido.folio;

-- ? 4.4 Productos dañados por tienda y lote.
Select
  tienda.nombre As tienda,
  producto.nombre As producto,
  lote.numero_lote,
  Sum(detalle_entrega.cantidad_danada) As cantidad_danada
From dbo.detalle_entrega detalle_entrega
Inner Join dbo.entrega entrega
  On detalle_entrega.id_entrega = entrega.id_entrega
Inner Join dbo.pedido pedido
  On entrega.id_pedido = pedido.id_pedido
Inner Join dbo.tienda tienda
  On pedido.id_tienda = tienda.id_tienda
Inner Join dbo.producto producto
  On detalle_entrega.id_producto = producto.id_producto
Inner Join dbo.lote lote
  On detalle_entrega.id_lote = lote.id_lote
Where detalle_entrega.cantidad_danada > 0
Group By tienda.nombre, producto.nombre, lote.numero_lote
Order By tienda.nombre, producto.nombre;

-- ? 4.5 Diferencias entre inventario fisico y registrado.
Select
  conteo.fecha_conteo,
  almacen.nombre As almacen,
  producto.nombre As producto,
  lote.numero_lote,
  detalle.cantidad_sistema,
  detalle.cantidad_fisica,
  detalle.diferencia
From dbo.detalle_conteo detalle
Inner Join dbo.conteo_inventario conteo
  On detalle.id_conteo = conteo.id_conteo
Inner Join dbo.inventario_lote inventario
  On detalle.id_inventario = inventario.id_inventario
Inner Join dbo.almacen almacen
  On inventario.id_almacen = almacen.id_almacen
Inner Join dbo.producto producto
  On inventario.id_producto = producto.id_producto
Inner Join dbo.lote lote
  On inventario.id_lote = lote.id_lote
Where detalle.diferencia <> 0;

-- ? 4.6 Seguimiento de pedidos e incidencias.
Select
  pedido.folio As pedido,
  tienda.nombre As tienda,
  entrega.folio As entrega,
  entrega.estado As estado_entrega,
  incidencia.tipo,
  incidencia.descripcion,
  incidencia.estado As estado_incidencia
From dbo.pedido pedido
Inner Join dbo.tienda tienda
  On pedido.id_tienda = tienda.id_tienda
Left Join dbo.entrega entrega
  On pedido.id_pedido = entrega.id_pedido
Left Join dbo.incidencia incidencia
  On entrega.id_entrega = incidencia.id_entrega
Order By pedido.folio;

-- * Evidencia: tomar una captura de cada resultado de los apartados 4.1 a 4.6.

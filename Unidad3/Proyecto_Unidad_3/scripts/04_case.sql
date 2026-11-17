-- ? Carlos Gabriel Rodriguez Macias
-- ! Juan Manuel Ortega Garcia
-- * Bernardo Guillermo Nuñez Lopez
-- ? Proyecto Unidad 3 - Procedures con Case
Use pepsi_distribucion;
GO

-- ? 1 Clasificar existencias para programar compras.
-- * Los productos sin unidades necesitan atencion inmediata.
Create Or Alter Procedure proyecto_u2.usp_estado_inventario
As
Begin
  Set Nocount On;
  Select p.nombre, p.presentacion, Isnull(Sum(i.cantidad), 0) As unidades,
    Case
      When Isnull(Sum(i.cantidad), 0) = 0 Then 'Sin existencias'
      When Sum(i.cantidad) < 20 Then 'Reponer pronto'
      Else 'Existencia suficiente'
    End As estado
  From proyecto_u2.producto p
  Left Join proyecto_u2.inventario_lote i On p.id_producto = i.id_producto
  Where p.activo = 1
  Group By p.id_producto, p.nombre, p.presentacion
  Order By unidades, p.nombre;
End;
GO
Exec proyecto_u2.usp_estado_inventario;
GO

-- ? 2 Clasificar la caducidad de los lotes.
-- * Da prioridad a los lotes vencidos o proximos a vencer.
Create Or Alter Procedure proyecto_u2.usp_estado_lotes
As
Begin
  Set Nocount On;
  Select l.numero_lote, p.nombre, l.fecha_caducidad,
    Case
      When l.fecha_caducidad < Cast(Getdate() As date) Then 'Vencido'
      When l.fecha_caducidad <= Dateadd(day, 30, Cast(Getdate() As date))
        Then 'Prioridad alta'
      Else 'Vigente'
    End As estado
  From proyecto_u2.lote l
  Inner Join proyecto_u2.producto p On l.id_producto = p.id_producto
  Order By l.fecha_caducidad;
End;
GO
Exec proyecto_u2.usp_estado_lotes;
GO

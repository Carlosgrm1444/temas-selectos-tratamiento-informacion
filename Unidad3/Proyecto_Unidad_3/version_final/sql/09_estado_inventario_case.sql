-- ? Carlos Gabriel Rodríguez Macías
-- ! Juan Manuel Ortega García
-- * Bernardo Guillermo Núñez López
-- ? Proyecto Unidad 3 - 23 de noviembre de 2026

Use pepsi_distribucion;
GO

-- ? Clasificar las existencias de cada lote por almacen.
Create Or Alter Procedure proyecto_u2.usp_estado_inventario
As Begin
  Select id_almacen, id_lote, cantidad,
    Case
      When cantidad = 0 Then 'Sin existencias'
      When cantidad < 20 Then 'Reponer pronto'
      Else 'Existencia suficiente'
    End As estado
  From proyecto_u2.inventario_lote
  Order By cantidad;
End;
GO

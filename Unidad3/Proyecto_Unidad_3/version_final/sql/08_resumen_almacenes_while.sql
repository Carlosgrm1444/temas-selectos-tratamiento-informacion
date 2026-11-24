-- ? Carlos Gabriel Rodríguez Macías
-- ! Juan Manuel Ortega García
-- * Bernardo Guillermo Núñez López
-- ? Proyecto Unidad 3 - 23 de noviembre de 2026

Use pepsi_distribucion;
GO

-- ? Revisar por separado los almacenes registrados.
Create Or Alter Procedure proyecto_u2.usp_resumen_almacenes
As Begin
  Declare @contador int = 1, @ultimo int;
  Select @ultimo = Max(id_almacen) From proyecto_u2.almacen;

  While @contador <= @ultimo
  Begin
    Select a.id_almacen, a.nombre,
      Isnull(Sum(i.cantidad), 0) As unidades
    From proyecto_u2.almacen a
    Left Join proyecto_u2.inventario_lote i
      On a.id_almacen = i.id_almacen
    Where a.id_almacen = @contador
    Group By a.id_almacen, a.nombre;
    Set @contador = @contador + 1;
  End;
End;
GO

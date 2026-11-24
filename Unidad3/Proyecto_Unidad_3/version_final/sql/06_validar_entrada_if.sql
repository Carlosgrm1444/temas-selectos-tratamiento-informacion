-- ? Carlos Gabriel Rodríguez Macías
-- ! Juan Manuel Ortega García
-- * Bernardo Guillermo Núñez López
-- ? Proyecto Unidad 3 - 23 de noviembre de 2026

Use pepsi_distribucion;
GO

-- ? Comprobar los datos antes de recibir unidades en un almacen.
Create Or Alter Procedure proyecto_u2.usp_validar_entrada
  @id_almacen int, @id_lote int, @cantidad int
As Begin
  If @cantidad Is Null Or @cantidad <= 0
    Print 'La cantidad no es valida.';
  Else If Not Exists
    (Select 1 From proyecto_u2.almacen
     Where id_almacen = @id_almacen And activo = 1)
    Print 'El almacen no esta disponible.';
  Else If Not Exists
    (Select 1 From proyecto_u2.lote Where id_lote = @id_lote)
    Print 'El lote no existe.';
  Else
    Print 'Entrada valida.';
End;
GO

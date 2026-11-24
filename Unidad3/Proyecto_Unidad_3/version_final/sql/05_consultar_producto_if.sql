-- ? Carlos Gabriel Rodríguez Macías
-- ! Juan Manuel Ortega García
-- * Bernardo Guillermo Núñez López
-- ? Proyecto Unidad 3 - 23 de noviembre de 2026

Use pepsi_distribucion;
GO

-- ? Revisar el ID antes de consultar un producto.
Create Or Alter Procedure proyecto_u2.usp_consultar_producto
  @id_producto int
As Begin
  If @id_producto Is Null Or @id_producto <= 0
  Begin
    Print 'El ID no es valido.';
    Return;
  End;

  Select id_producto, nombre, precio
  From proyecto_u2.producto
  Where id_producto = @id_producto;

  If @@Rowcount = 0
    Print 'El producto no existe.';
End;
GO

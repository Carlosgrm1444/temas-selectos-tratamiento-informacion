-- ? Carlos Gabriel Rodríguez Macías
-- ! Juan Manuel Ortega García
-- * Bernardo Guillermo Núñez López
-- ? Proyecto Unidad 3 - 23 de noviembre de 2026

Use pepsi_distribucion;
GO

-- ? Cambiar el precio y mostrar el error si no cumple las reglas.
Create Or Alter Procedure proyecto_u2.usp_cambiar_precio
  @id_producto int, @precio decimal(10, 2) = Null
With Encryption
As Begin
  Begin Try
    Update proyecto_u2.producto
    Set precio = Isnull(@precio, precio)
    Where id_producto = @id_producto;

    If @@Rowcount = 0
      Print 'El producto no existe.';
    Else
      Print 'Precio actualizado.';
  End Try
  Begin Catch
    Select Error_Number() As numero, Error_Message() As mensaje;
  End Catch
End;
GO

-- ? Carlos Gabriel Rodríguez Macías
-- ! Juan Manuel Ortega García
-- * Bernardo Guillermo Núñez López
-- ? Proyecto Unidad 3 - 23 de noviembre de 2026

Use pepsi_distribucion;
GO

-- ? Registrar un lote respetando el producto y sus fechas.
Create Or Alter Procedure proyecto_u2.usp_registrar_lote
  @id_producto int, @numero_lote varchar(30),
  @fecha_recepcion date, @fecha_caducidad date
With Encryption
As Begin
  Begin Try
    Insert Into proyecto_u2.lote
      (id_producto, numero_lote, fecha_recepcion, fecha_caducidad)
    Values
      (@id_producto, @numero_lote, @fecha_recepcion, @fecha_caducidad);

    Select id_lote, numero_lote, fecha_caducidad
    From proyecto_u2.lote
    Where id_lote = Scope_Identity();
  End Try
  Begin Catch
    Select Error_Number() As numero, Error_Message() As mensaje;
  End Catch
End;
GO

-- ? Carlos Gabriel Rodriguez Macias
-- ! Juan Manuel Ortega Garcia
-- * Bernardo Guillermo Nuñez Lopez
-- ? Proyecto Unidad 3 - Subconsultas, encriptacion y errores
Use pepsi_distribucion;
GO

-- ? 1 Encontrar productos cuyo precio supera el promedio.
-- * Se necesita para revisar precios atipicos antes de tomar decisiones.
Create Or Alter Procedure proyecto_u2.usp_productos_precio_alto
With Encryption
As
Begin
  Set Nocount On;
  Begin Try
    Select id_producto, nombre, presentacion, precio
    From proyecto_u2.producto
    Where activo = 1
      And precio > (Select Avg(precio) From proyecto_u2.producto Where activo = 1)
    Order By precio Desc;
  End Try
  Begin Catch
    Select Error_Number() As numero_error, Error_Message() As mensaje_error;
  End Catch
End;
GO
Exec proyecto_u2.usp_productos_precio_alto;
GO

-- ? 2 Localizar lotes con fecha de caducidad proxima y existencias.
-- * Se necesita para priorizar la salida de productos del almacen.
Create Or Alter Procedure proyecto_u2.usp_lotes_con_existencia
  @dias int
With Encryption
As
Begin
  Set Nocount On;
  Begin Try
    If @dias Is Null Or @dias < 1
      Throw 50001, 'Los dias deben ser mayores que cero.', 1;

    Select l.id_lote, l.numero_lote, l.fecha_caducidad,
      (Select Sum(i.cantidad) From proyecto_u2.inventario_lote i
       Where i.id_lote = l.id_lote) As unidades
    From proyecto_u2.lote l
    Where l.fecha_caducidad Between Cast(Getdate() As date)
      And Dateadd(day, @dias, Cast(Getdate() As date))
      And Exists (Select 1 From proyecto_u2.inventario_lote i
                  Where i.id_lote = l.id_lote And i.cantidad > 0)
    Order By l.fecha_caducidad;
  End Try
  Begin Catch
    Select Error_Number() As numero_error, Error_Message() As mensaje_error;
  End Catch
End;
GO
Exec proyecto_u2.usp_lotes_con_existencia @dias = 120;
GO

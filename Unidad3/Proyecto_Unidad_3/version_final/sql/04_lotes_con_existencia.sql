-- ? Carlos Gabriel Rodríguez Macías
-- ! Juan Manuel Ortega García
-- * Bernardo Guillermo Núñez López
-- ? Proyecto Unidad 3 - 23 de noviembre de 2026

Use pepsi_distribucion;
GO

-- ? Subconsulta de lista para buscar lotes que tienen unidades.
Create Or Alter Procedure proyecto_u2.usp_lotes_con_existencia
  @dias int
As Begin
  If @dias Is Null Or @dias Not Between 1 And 365
    Return;

  Select id_lote, numero_lote, fecha_caducidad
  From proyecto_u2.lote
  Where fecha_caducidad Between Cast(Getdate() As date)
    And Dateadd(day, @dias, Cast(Getdate() As date))
    And id_lote In
      (Select id_lote From proyecto_u2.inventario_lote Where cantidad > 0)
  Order By fecha_caducidad;
End;
GO

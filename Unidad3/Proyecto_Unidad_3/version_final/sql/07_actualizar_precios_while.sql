-- ? Carlos Gabriel Rodríguez Macías
-- ! Juan Manuel Ortega García
-- * Bernardo Guillermo Núñez López
-- ? Proyecto Unidad 3 - 23 de noviembre de 2026

Use pepsi_distribucion;
GO

-- ? Recorrer el catalogo y aumentar el precio de los productos activos.
Create Or Alter Procedure proyecto_u2.usp_actualizar_precios
  @aumento decimal(10, 2)
As Begin
  If @aumento Is Null Or @aumento <= 0
    Return;

  Declare @contador int = 1, @ultimo int;
  Select @ultimo = Max(id_producto) From proyecto_u2.producto;

  While @contador <= @ultimo
  Begin
    Update proyecto_u2.producto
    Set precio = precio + @aumento
    Where id_producto = @contador And activo = 1;
    Set @contador = @contador + 1;
  End;
End;
GO

-- * Usamos Max porque los IDs conservados tienen saltos despues del ETL.
-- * La prueba se revierte en 90_ejecutar_ejemplos.sql.

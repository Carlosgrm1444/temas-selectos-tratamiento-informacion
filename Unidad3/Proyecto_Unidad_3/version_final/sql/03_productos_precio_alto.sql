-- ? Carlos Gabriel Rodríguez Macías
-- ! Juan Manuel Ortega García
-- * Bernardo Guillermo Núñez López
-- ? Proyecto Unidad 3 - 23 de noviembre de 2026

Use pepsi_distribucion;
GO

-- ? Subconsulta escalar para comparar los precios con el promedio.
Create Or Alter Procedure proyecto_u2.usp_productos_precio_alto
As Begin
  Select id_producto, nombre, precio
  From proyecto_u2.producto
  Where activo = 1 And precio >
    (Select Avg(precio) From proyecto_u2.producto Where activo = 1)
  Order By precio Desc;
End;
GO

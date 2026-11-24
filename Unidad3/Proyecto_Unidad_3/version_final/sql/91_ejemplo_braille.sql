-- ? Carlos Gabriel Rodríguez Macías
-- ! Juan Manuel Ortega García
-- * Bernardo Guillermo Núñez López
-- ? Ejemplo de las tres guias impresas en braille
-- * Se usa una tabla temporal para distinguirla del catalogo completo.

-- ? Crear las tres columnas mostradas en la guia.
Create Table #producto
(
  id_producto int Identity(1, 1) Not Null Primary Key,
  nombre varchar(100) Not Null,
  precio decimal(10, 2) Not Null
);
GO

-- ? Insertar el producto del material didactico.
Insert Into #producto (nombre, precio)
Values ('Pepsi 600 mililitros', 20);
GO

-- ? Consultar el nombre guardado.
Select nombre From #producto;
GO

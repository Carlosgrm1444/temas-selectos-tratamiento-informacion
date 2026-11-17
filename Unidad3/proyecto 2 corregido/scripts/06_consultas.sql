-- Proyecto Unidad 2
-- ? Juan Manuel Ortega García
-- ! Bernardo Guillermo Núñez López
-- * Carlos Gabriel Rodríguez Macias
Use pepsi_distribucion;
GO

-- ? 1 Revisar el valor del inventario por producto.
Select p.id_producto, p.nombre, p.presentacion,
  Sum(i.cantidad) As unidades,
  Sum(i.cantidad * p.precio) As valor_inventario
From proyecto_u2.producto p
Inner Join proyecto_u2.inventario_lote i On p.id_producto = i.id_producto
Where p.activo = 1 And i.cantidad > 0
Group By p.id_producto, p.nombre, p.presentacion
Order By valor_inventario Desc;

-- ? 2 Revisar lotes con caducidad próxima desde el corte del ejercicio.
Select p.nombre, l.numero_lote, l.fecha_caducidad,
  Sum(i.cantidad) As unidades_por_caducar,
  Min(l.fecha_caducidad) As primera_caducidad
From proyecto_u2.lote l
Inner Join proyecto_u2.producto p On l.id_producto = p.id_producto
Inner Join proyecto_u2.inventario_lote i
  On l.id_lote = i.id_lote And l.id_producto = i.id_producto
Where l.fecha_caducidad >= '2026-11-02' And l.fecha_caducidad < '2027-03-01'
Group By p.nombre, l.numero_lote, l.fecha_caducidad
Order By l.fecha_caducidad Asc;

-- ? 3 Comparar precios de productos activos.
Select nombre, Count(*) As presentaciones,
  Avg(precio) As precio_promedio, Min(precio) As precio_minimo,
  Max(precio) As precio_maximo
From proyecto_u2.producto
Where activo = 1 And precio > 0
Group By nombre
Order By precio_promedio Desc;

-- ? Crear una tabla temporal para preparar la revisión del almacén.
-- * La tabla temporal solo se utiliza durante esta conexión.
Create Table #revision_inventario
(
  id_producto int,
  nombre varchar(100),
  unidades int,
  valor_inventario decimal(18, 2)
);

Insert Into #revision_inventario
Select p.id_producto, p.nombre, Sum(i.cantidad), Sum(i.cantidad * p.precio)
From proyecto_u2.producto p
Inner Join proyecto_u2.inventario_lote i On p.id_producto = i.id_producto
Group By p.id_producto, p.nombre;

Select * From #revision_inventario
Where unidades > 0
Order By valor_inventario Desc;
GO

-- ? Crear la vista encriptada para la consulta de existencias.
-- * With Encryption oculta la definición; no cifra las filas ni reemplaza permisos.
Create View proyecto_u2.vw_existencias_equipo
With Encryption
As
Select p.id_producto, p.nombre, p.presentacion, p.precio,
  Sum(i.cantidad) As existencia,
  Sum(i.cantidad * p.precio) As valor_inventario
From proyecto_u2.producto p
Inner Join proyecto_u2.inventario_lote i On p.id_producto = i.id_producto
Group By p.id_producto, p.nombre, p.presentacion, p.precio;
GO

Select * From proyecto_u2.vw_existencias_equipo
Order By valor_inventario Desc;

-- ? Comprobar que SQL Server no expone el texto de la vista.
Select Objectproperty(Object_Id('proyecto_u2.vw_existencias_equipo'), 'IsEncrypted')
  As vista_encriptada;
GO


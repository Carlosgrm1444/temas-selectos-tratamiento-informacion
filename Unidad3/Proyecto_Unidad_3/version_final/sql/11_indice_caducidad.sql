-- ? Carlos Gabriel Rodríguez Macías
-- ! Juan Manuel Ortega García
-- * Bernardo Guillermo Núñez López
-- ? Proyecto Unidad 3 - 23 de noviembre de 2026

Use pepsi_distribucion;
GO

-- ? Revisar el plan y las lecturas antes de crear el indice.
Set Statistics Io On;
Set Statistics Time On;
GO

Select id_lote, id_producto, numero_lote, fecha_caducidad
From proyecto_u2.lote
Where fecha_caducidad >= '2027-01-01'
  And fecha_caducidad < '2027-03-01'
Order By fecha_caducidad;
GO

-- ? Crear el indice para filtrar y ordenar los lotes por caducidad.
Create Nonclustered Index ix_lote_caducidad_producto
On proyecto_u2.lote(fecha_caducidad, id_producto)
Include(numero_lote);
GO

-- ? Repetir la consulta para comparar el mismo conjunto de datos.
Select id_lote, id_producto, numero_lote, fecha_caducidad
From proyecto_u2.lote
Where fecha_caducidad >= '2027-01-01'
  And fecha_caducidad < '2027-03-01'
Order By fecha_caducidad;
GO

Set Statistics Io Off;
Set Statistics Time Off;
GO

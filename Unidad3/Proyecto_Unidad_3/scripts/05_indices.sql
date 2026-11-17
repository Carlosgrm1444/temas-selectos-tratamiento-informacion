-- ? Carlos Gabriel Rodriguez Macias
-- ! Juan Manuel Ortega Garcia
-- * Bernardo Guillermo Nuñez Lopez
-- ? Proyecto Unidad 3 - Indices y optimizacion
Use pepsi_distribucion;
GO

-- ? Medir la consulta antes de agregar el indice.
Set Statistics Io On;
Set Statistics Time On;
Select id_lote, id_producto, numero_lote, fecha_caducidad
From proyecto_u2.lote
Where fecha_caducidad >= '2026-11-01'
  And fecha_caducidad < '2027-03-01'
Order By fecha_caducidad;
GO

-- ? La llave primaria ya crea un indice para buscar cada lote por id.
-- ? Este indice ayuda a filtrar lotes por caducidad y producto.
If Not Exists (Select 1 From sys.indexes
  Where object_id = Object_Id('proyecto_u2.lote')
    And name = 'ix_lote_caducidad_producto')
  Create Nonclustered Index ix_lote_caducidad_producto
  On proyecto_u2.lote(fecha_caducidad, id_producto)
  Include(numero_lote);
GO

-- ? Repetir la misma consulta y comparar lecturas y tiempo.
Select id_lote, id_producto, numero_lote, fecha_caducidad
From proyecto_u2.lote
Where fecha_caducidad >= '2026-11-01'
  And fecha_caducidad < '2027-03-01'
Order By fecha_caducidad;
Set Statistics Io Off;
Set Statistics Time Off;
GO

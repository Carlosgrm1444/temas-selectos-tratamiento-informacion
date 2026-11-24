-- ? Carlos Gabriel Rodríguez Macías
-- ! Juan Manuel Ortega García
-- * Bernardo Guillermo Núñez López
-- ? Proyecto Unidad 3 - Tareas principales de mantenimiento

Use pepsi_distribucion;
GO

-- ? Domingo a las 02:00. Revisar la integridad de la base.
Dbcc Checkdb('pepsi_distribucion') With No_Infomsgs;
GO

-- ? Domingo a las 03:00. Revisar el indice antes de reorganizarlo.
Select index_id, page_count, avg_fragmentation_in_percent
From sys.dm_db_index_physical_stats
  (DB_ID(), Object_Id('proyecto_u2.lote'), Null, Null, 'LIMITED');
GO

-- ? Reorganizar el indice del ejemplo cuando la revision lo justifique.
-- * No se ejecuta automaticamente para una tabla de solo 42 filas.
-- Alter Index ix_lote_caducidad_producto On proyecto_u2.lote Reorganize;

-- ? Domingo a las 04:30. Actualizar las estadisticas del ETL.
Update Statistics proyecto_u2.producto;
Update Statistics proyecto_u2.lote;
Update Statistics proyecto_u2.inventario_lote;
GO

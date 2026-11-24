-- ? Carlos Gabriel Rodríguez Macías
-- ! Juan Manuel Ortega García
-- * Bernardo Guillermo Núñez López
-- ? Proyecto Unidad 3 - Prueba local de recuperacion
-- ! Ejecutar solo con la base de demostracion preparada para esta entrega.
-- * La base operativa pepsi_distribucion no participa en esta prueba.

Use master;
GO

-- ? Permitir los respaldos del log en la base de prueba.
Alter Database pepsi_u3_demo Set Recovery Full;
GO

-- ? Crear un respaldo completo, uno diferencial y uno del log.
Backup Database pepsi_u3_demo
To Disk = '/var/opt/mssql/data/pepsi_u3_full_20261123.bak'
With Checksum;
GO

Backup Database pepsi_u3_demo
To Disk = '/var/opt/mssql/data/pepsi_u3_diff_20261123.bak'
With Differential, Checksum;
GO

Backup Log pepsi_u3_demo
To Disk = '/var/opt/mssql/data/pepsi_u3_log_20261123.trn'
With Checksum;
GO

-- ? Restaurar con otro nombre y medir el tiempo hasta la validacion.
Declare @inicio datetime2 = Sysdatetime();

Restore Database pepsi_u3_restaurada
From Disk = '/var/opt/mssql/data/pepsi_u3_full_20261123.bak'
With Move 'pepsi_u3_demo'
  To '/var/opt/mssql/data/pepsi_u3_restaurada.mdf',
Move 'pepsi_u3_demo_log'
  To '/var/opt/mssql/data/pepsi_u3_restaurada_log.ldf',
Norecovery, Checksum;

Restore Database pepsi_u3_restaurada
From Disk = '/var/opt/mssql/data/pepsi_u3_diff_20261123.bak'
With Norecovery, Checksum;

Restore Log pepsi_u3_restaurada
From Disk = '/var/opt/mssql/data/pepsi_u3_log_20261123.trn'
With Recovery, Checksum;

Dbcc Checkdb('pepsi_u3_restaurada') With No_Infomsgs;

Select Datediff(millisecond, @inicio, Sysdatetime()) As tiempo_ms,
  (Select Count(*) From pepsi_u3_restaurada.proyecto_u2.producto) As productos,
  (Select Count(*) From pepsi_u3_restaurada.proyecto_u2.lote) As lotes,
  (Select Count(*) From pepsi_u3_restaurada.proyecto_u2.inventario_lote) As inventarios;
GO

-- * El ensayo usa cuatro tablas pequeñas del ETL.
-- * El RTO de produccion necesita otra prueba con el volumen completo.

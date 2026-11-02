-- ! Carlos Rodriguez
-- ! 29 / Enero / 2026

-- ? Crear la bd de agencia_aduanal (mdf, ldf, ndf)
Create Database Agencia_aduanal on Primary (
  Name = Agencia_aduanalData,
  filename = 'C:\7BD\Agencia_aduanal.mdf',
  size = 50mb,
  Filegrowth = 25 %
) log on (
  Name = Agencia_aduanalLog,
  filename = 'C:\7BD\Agencia_aduanal_log.ldf',
  size = 25MB,
  Filegrowth = 25 %
);
Alter Database Agencia_aduanal
add filegroup SECONDARY;
Alter Database Agencia_aduanal
add file (
    name = Agencia_aduanal,
    filename = 'C:\7BD\Agencia_aduanal_secundario.ndf',
    size = 10MB
  ) to filegroup SECONDARY;
-- ? Crear la tabla aduanas:id_aduana, prueba
Create Table aduanas (
  id_aduana int primary key identity(1, 1),
  prueba varchar(20)
);
-- ? Elimina la columna de prueba
Alter Table aduanas Drop Column prueba;
-- ? Agrega la columna de aduana
Alter Table aduanas
Add aduana varchar(100) not null;
-- ? Agrega la restricción unique a aduana
Alter Table aduana
Add Constraint UQ_aduana Unique (aduana) 
-- ? Agrega el sp para desvincular (no lo ejecutes)
  Exec Sp_detatch_bd Agencia_aduanal 
-- ? Agregar el sp para vincular (no lo ejecutes)
  Exec Sp_attach_bd Agencia_aduanal,
  'C:\7BD\Agencia_aduanal.mdf',
  'C:\7BD\Agencia_aduanal_log.ldf',
  'C:\7BD\Agencia_aduanal_secundario.ndf' 
  -- ? Agrega el código para ver TODAS las restricciones
  Select * From
  Information_schema.table_constraints
  Where table_name = 'aduanas'

  -- ? Renombre la BD a agencia_aduanal_tu nombre
  Alter Database Agencia_aduanal
  Modify name = Carlos_rodriguez
  -- ? Renombra la tabla de aduanas por aduanas_tu_nombre
  Use Carlos_rodriguez;
  Exec Sp_rename 'aduanas',
  'aduanas_carlos_rodriguez'
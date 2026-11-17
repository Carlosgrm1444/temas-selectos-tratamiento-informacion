-- ? Carlos Gabriel Rodriguez Macias
-- ! Athala Dulce Edith Gómez Arellano
-- * Practica 8 - Base de datos TechStore

-- ? Crear la bd de TechStore (mdf, ldf, ndf)
Use master;

Create Database techstore_sql On Primary (
  Name = techstoreData,
  Filename = '/media/carlos-rodriguez/nvme0n1p1/2db/Unidad1/data/techstoreData.mdf',
  Size = 50MB,
  Filegrowth = 25 %
) Log On (
  Name = techstoreLog,
  Filename = '/media/carlos-rodriguez/nvme0n1p1/2db/Unidad1/data/techstoreLog.ldf',
  Size = 25MB,
  Filegrowth = 25 %
);

-- ? Crear el grupo de archivos SECONDARY.
Alter Database techstore_sql
Add Filegroup SECONDARY;

-- ? Crear el archivo secundario ndf.
Alter Database techstore_sql
Add File (
  Name = techstoreSecundario,
  Filename = '/media/carlos-rodriguez/nvme0n1p1/2db/Unidad1/data/techstoreSecundario.ndf',
  Size = 10MB
) To Filegroup SECONDARY;

-- ? Usar la base de datos.
Use techstore_sql;

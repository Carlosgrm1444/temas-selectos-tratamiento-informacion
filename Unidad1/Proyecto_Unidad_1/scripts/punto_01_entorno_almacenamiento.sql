-- ? Punto 1. Entorno y almacenamiento.
-- ? Objetivo: crear la base pepsi_distribucion con archivos MDF, NDF y LDF.
-- ! Requisito: la carpeta /media/carlos-rodriguez/nvme0n1p1/2db/data debe existir y permitir acceso a SQL Server.

Use master;
GO

-- ? 1.1 Crear la base de datos y el archivo principal.
Create Database pepsi_distribucion On Primary
(
  Name = pepsiData,
  Filename = '/media/carlos-rodriguez/nvme0n1p1/2db/data/pepsi_distribucion.mdf',
  Size = 50MB,
  Filegrowth = 25MB
)
Log On
(
  Name = pepsiLog,
  Filename = '/media/carlos-rodriguez/nvme0n1p1/2db/data/pepsi_distribucion.ldf',
  Size = 25MB,
  Filegrowth = 25MB
);
GO

-- ? 1.2 Crear el grupo de archivos secundario.
Alter Database pepsi_distribucion
Add Filegroup SECUNDARIO;
GO

-- ? 1.3 Crear el archivo NDF.
Alter Database pepsi_distribucion
Add File
(
  Name = pepsiSecundario,
  Filename = '/media/carlos-rodriguez/nvme0n1p1/2db/data/pepsi_distribucion_secundario.ndf',
  Size = 25MB,
  Filegrowth = 25MB
)
To Filegroup SECUNDARIO;
GO

-- ? 1.4 Verificar los archivos y grupos de la base de datos.
Use pepsi_distribucion;
GO

Select
  archivo.name As nombre_archivo,
  archivo.type_desc As tipo_archivo,
  archivo.physical_name As ruta,
  Isnull(grupo.name, 'LOG') As grupo_archivos
From sys.database_files archivo
Left Join sys.filegroups grupo
  On archivo.data_space_id = grupo.data_space_id
Order By archivo.file_id;

-- * Evidencia: tomar captura de los tres archivos, sus rutas y sus grupos.

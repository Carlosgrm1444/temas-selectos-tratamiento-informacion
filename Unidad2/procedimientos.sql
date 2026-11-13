-- ? Carlos Gabriel Rodriguez Macias
-- ! Importar la base fronteresa_repaso desde el archivo bacpac.
-- * El archivo bacpac se importa con importar_fronteresa_repaso.sh en Linux.

-- ? Usar la base que se importó.
Use fronteresa_repaso;
GO

-- ? Ver las tablas que se importaron.
Select
  name As tabla
From sys.tables;
GO

-- ? Ver la cantidad de registros de cada tabla.
Select 'clientes_athala' As tabla, Count(*) As registros
From dbo.clientes_athala
Union All
Select 'productos_athala', Count(*)
From dbo.productos_athala
Union All
Select 'envios_athala', Count(*)
From dbo.envios_athala
Union All
Select 'detalle_envio_athala', Count(*)
From dbo.detalle_envio_athala;
GO

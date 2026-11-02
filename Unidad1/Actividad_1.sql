-- ? Carlos Gabriel Rodriguez Macias
-- * Edith Dulce Athala Gomez
-- ? Actividad 1 - Creacion de BD - 27/08/2026

-- ? Crear la base de datos steren (mdf, ldf)
Use master;
Create Database steren On Primary (
  Name = sterenData,
  filename = '/media/carlos-rodriguez/nvme0n1p1/1BD/2db/data/sterenData.mdf',
  size = 50mb,
  Filegrowth = 25 %
) log on (
  Name = sterenLog,
  filename = '/media/carlos-rodriguez/nvme0n1p1/1BD/2db/data/sterenLog.ldf',
  size = 25MB,
  Filegrowth = 25 %
);

-- ? Crear grupo de archivos SECUNDARIO
Alter Database steren
add Filegroup SECUNDARIO;

-- ? Crear archivo secundario sterenSecundario (ndf)
Alter Database steren
add file (
  name = sterenSecundario,
  filename = '/media/carlos-rodriguez/nvme0n1p1/1BD/2db/data/sterenSecundario.ndf',
  size = 10MB,
  Filegrowth = 25 %
) to Filegroup SECUNDARIO;

use steren;

-- ? Crear las tablas de la base de datos steren
Create Table clientes (
  id_cliente int primary key identity(1, 1),
  razon_social varchar(150) not null,
  correo varchar(150) not null
);

Create Table productos (
  id_producto int primary key identity(1, 1),
  producto varchar(150) not null,
  precio_unitario decimal(10, 2) not null,
  existencia int not null
);

Create Table ventas (
  id_venta int primary key identity(1, 1),
  id_cliente int not null,
  fecha datetime not null,
  total decimal(10, 2) not null,
  foreign key (id_cliente) references clientes(id_cliente)
);

Create Table detalle_venta (
  id_detalle int primary key identity(1, 1),
  id_venta int not null,
  id_producto int not null,
  cantidad int not null,
  foreign key (id_venta) references ventas(id_venta),
  foreign key (id_producto) references productos(id_producto)
);

-- ? Crear usuarios y asignar permisos segun la matriz

-- ? Usuario: Ana Lopez
Use master;
Create Login ana_lopez_login With Password = 'Ana123.';
Use steren;
Create User ana_lopez For Login ana_lopez_login;
Grant Select, Insert On clientes To ana_lopez;
Grant Select, Insert On productos To ana_lopez;

-- ? Usuario: Carlos Mendoza
Use master;
Create Login carlos_mendoza_login With Password = 'Carlos123.';
Use steren;
Create User carlos_mendoza For Login carlos_mendoza_login;
Grant Select On clientes To carlos_mendoza;
Grant Select On productos To carlos_mendoza;
Grant Select On ventas To carlos_mendoza;
Grant Select On detalle_venta To carlos_mendoza;

-- ? Usuario: Mariana Torres
Use master;
Create Login mariana_torres_login With Password = 'Mariana123.';
Use steren;
Create User mariana_torres For Login mariana_torres_login;
Grant Select On productos To mariana_torres;
Grant Update On productos (existencia) To mariana_torres;

-- ? Usuario: Luis Ramirez
Use master;
Create Login luis_ramirez_login With Password = 'Luis123.';
Use steren;
Create User luis_ramirez For Login luis_ramirez_login;
Exec sp_addrolemember 'db_backupoperator', 'luis_ramirez';

-- ? Usuario: Sofia Herrera
Use master;
Create Login sofia_herrera_login With Password = 'Sofia123.';
Use steren;
Create User sofia_herrera For Login sofia_herrera_login;
Use master;
Exec sp_addsrvrolemember 'sofia_herrera_login', 'securityadmin';

-- ? Usuario: AppSteren
Use master;
Create Login app_steren_login With Password = 'AppSteren123.';
Use steren;
Create User app_steren For Login app_steren_login;
Grant Select, Insert, Update On clientes To app_steren;
Grant Select, Insert, Update On productos To app_steren;
Grant Select, Insert, Update On ventas To app_steren;
Grant Select, Insert, Update On detalle_venta To app_steren;


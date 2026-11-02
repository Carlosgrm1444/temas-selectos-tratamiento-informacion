-- ? Carlos Gabriel Rodriguez Macias
-- * Edith Dulce Athala Gomez
-- ? Proyecto - 05/02/2026

-- ? Creacion de la base de datos
Create Database Romex On Primary (
  name = RomexData,
  filename = 'C:\7BD\Romex.mdf',
  size = 50mb,
  filegrowth = 25%
) log on (
  name = RomexLog,
  filename = 'C:\7BD\Romex.ldf',
  size = 25mb,
  filegrowth = 25%
);

-- ? Creacion de grupo de archivos SECUNDARIO
Alter Database Romex add Filegroup SECUNDARIO;

-- ? Creacion del archivo RomexParte1 y asociarlo al grupo de archivos SECUNDARIO
Alter Database Romex add File (
  name = RomexParte1,
  filename = 'C:\7BD\RomexParte1.ndf',
  size = 10mb
) to filegroup SECUNDARIO;

-- ? Creacion de usuario por medio de base de datos
Use master;
Create Login romex_sql_carlos With
Password = 'Dulce123';

Use Master;
-- ? Login

-- ? Para crear el User se debe usar la base de datos
-- ? Carlos Gabriel Rodriguez Macias
Create User romex_sql_carlos For
Login romex_sql_carlos;

-- ? Carlos Gabriel Rodriguez Macias
-- ? Listado de sesiones
Select spid, blocked, loginame, login_time, 
last_batch, status from sys.sysprocesses 
where loginame = 'romex_sql_carlos';

-- ? Carlos Gabriel Rodriguez Macias
-- ? Eliminar login
Drop Login romex_sql_carlos;

-- ? Matar sesiones abiertas
Kill 103

-- ?  Agregar roles de servidor a un usuario
Exec sp_addsrvrolemember 'romex_sql_carlos', 'sysadmin';

-- ? quitar roles de servidor a un usuario
Exec sp_dropsrvrolemember 'romex_sql_carlos', 'sysadmin';

-- ? Agregar roles de base de datos a un usuario
Exec sp_addrolemember 'db_datareader', 'romex_sql_carlos';

-- ? Quitar roles de base de datos a un usuario
Exec sp_droprolemember 'db_datareader', 'romex_sql_carlos';

-- ? Carlos Gabriel Rodriguez Macias
-- ? Dar permiso individual
Grant Create Table To romex_sql_carlos;

-- ? Denegar permiso individual
Deny Create Table To romex_sql_carlos;

-- ? Revocar permiso individual
Revoke Create Table To romex_sql_carlos;

-- ?  Crear tablas
use Romex;

create table tipo_producto(
  id_tipo_producto int primary key identity(1, 1),
  nombre varchar(100) not null,
  descripcion varchar(255) not null,
  activo bit not null,
  creado_en datetime not null
);
create table tipo_movimiento(
  id_tipo_movimiento int primary key identity(1, 1),
  nombre varchar(60) not null,
  factor smallint not null,
  descripcion varchar(100) not null,
  activo bit not null
);
create table producto(
  id_producto int primary key identity(1, 1),
  nombre varchar(100) not null,
  descripcion varchar(500) not null,
  costo_material decimal(10, 2) not null,
  costo_total decimal(10, 2) not null,
  precio_venta decimal(10, 2) not null,
  activo bit not null,
  creado_en datetime not null,
  id_tipo_producto int foreign key references tipo_producto(id_tipo_producto)
);
create table movimiento_inventario(
  id_movimiento_inventario int primary key identity(1, 1),
  fecha datetime not null,
  cantidad int not null,
  nota varchar(255) not null,
  id_producto int foreign key references producto(id_producto),
  id_tipo_movimiento int foreign key references tipo_movimiento(id_tipo_movimiento)
);

-- ? Respaldos FULL
Backup Database Romex To Disk = 'C:\7BD\RespaldoRomex.bak' 
With Format, 
Name = 'Respaldo Completo de Romex',
Description = 'Respaldo 12/02/2025';

-- ? Respaldos - Differencial
Backup Database Romex To Disk = 'C:\7BD\RespaldoRomexDiff.bak'
With Format,
Name = 'Respaldo Diferencial de Romex',
Description = 'Respaldo Diferencial 12/02/2025';

-- ? Respaldos - Log
Backup Log Romex 
To Disk = 'C:\7BD\RespaldoRomexLog.bak';

-- ? Respaldo - Solo copia
Backup Database Romex 
To Disk = 'C:\7BD\RespaldoRomexCopia.bak'
With copy_only, name='Respaldo Solo Copia de Romex',
Description = 'Respaldo Solo Copia 12/02/2025';

-- ? Respaldo - Grupo de archivos
Backup Database Romex Filegroup = 'Primary'
To Disk = 'C:\7BD\RespaldoRomexFilegroup.bak';
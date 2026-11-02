-- ? Carlos Gabriel Rodriguez Macias
-- * Edith Dulce Athala Gomez
-- ? Actividad 2 - Creacion de BD - 25/08/2026

-- ? Crear la base de datos hospital_sql (mdf, ldf, ndf)
Create Database hospital_sql On Primary (
  Name = hospitalData,
  filename = '/media/carlos-rodriguez/nvme0n1p1/1BD/2db/data/hospitalData.mdf',
  size = 50mb,
  Filegrowth = 25 %
) log on (
  Name = hospitalLog,
  filename = '/media/carlos-rodriguez/nvme0n1p1/1BD/2db/data/hospitalLog.ldf',
  size = 25MB,
  Filegrowth = 25 %
);

-- ? Crear grupo de archivos HISTORIAL
Alter Database hospital_sql
add Filegroup HISTORIAL;

-- ? Crear archivo hospitalHistorial y asociarlo al grupo HISTORIAL
Alter Database hospital_sql
add file (
  name = hospitalHistorial,
  filename = '/media/carlos-rodriguez/nvme0n1p1/1BD/2db/data/hospitalHistorial.ndf',
  size = 10MB
) to Filegroup HISTORIAL;

-- ? Crear tablas del hospital
Create Table doctores (
  id_doctor int primary key identity(1, 1),
  nombre varchar(100) not null,
  paterno varchar(100) not null,
  materno varchar(100) not null
);

Create Table especialidades (
  id_especialidad int primary key identity(1, 1),
  especialidad varchar(100) not null
);

Create Table rel_doctores_especialidades (
  id_rel int primary key identity(1, 1),
  id_doctor int not null foreign key references doctores(id_doctor),
  id_especialidad int not null foreign key references especialidades(id_especialidad)
);

-- ? Bloque final con los usuarios solicitados
Use master;
Create Login carlos_login With
Password = 'Carlos123.';
Create Login gabriel_login With
Password = 'Gabriel123.';

Use hospital_sql;
Create User carlos For
Login carlos_login;
Create User gabriel For
Login gabriel_login;

Exec sp_addsrvrolemember 'carlos_login', 'dbcreator';
Exec sp_addsrvrolemember 'gabriel_login', 'securityadmin';

-- * Desconectar el servidor y volver a entrar con los otros logins

-- ? Respaldo full de la base de datos
Backup Database hospital_sql
To Disk = '/media/carlos-rodriguez/nvme0n1p1/1BD/2db/data/respaldo.bak'
With Init, Format,
Name = 'Respaldo full',
Description = 'Respaldo full';

-- ? Carlos Gabriel Rodriguez Macias
-- * Edith Dulce Athala Gomez
-- ? Practica 4 - 05/02/2026

-- ? 1.-Crear una base de datos con el nombre de cine (crear archivos primary y log)
Create Database Cine On Primary (
  name = CineData,
  filename = 'C:\7BD\cine.mdf',
  size = 50mb,
  filegrowth = 25 %
) log on (
  name = CineLog,
  filename = 'C:\7BD\cine.ldf',
  size = 50mb,
  filegrowth = 25 %
);

-- ? 2.-Crea el grupo de archivos SECUNDARIO
Alter Database Cine
add Filegroup SECUNDARIO;

-- ? 3.-Crea el archivo cineParte1 y asociarlo al grupo de archivos SECUNDARIO
Alter Database Cine
add File (
    name = cineParte1,
    filename = 'C:\7BD\cineParte1.ndf',
    size = 25mb
  );

-- ? 4.-Crear tabla de generos: id_genero de tipo int es la clave primaria y 
-- ? tiene un incremento de 1 en 1, iniciando en 1; genero de tipo varchar y 
-- ? no acepta valores nulos
Create Table generos (
  id_genero int primary key identity(1, 1),
  genero varchar(100) not null
);

-- ? 5.- Insertar los siguientes datos: 'Suspenso', 'Comedia', 'Romance', 'Accion'
insert Into generos (genero)
Values ('Suspenso'),
  ('Comedia'),
  ('Romance'),
  ('Accion');

-- ? 6.Crea un login con el nombre pruebaLogin y con la contraseña '1234', no olvides utilizar master
Create Login pruebaLogin With
Password = '1234';

-- ? 7.Crea un usuario asociandolo al login creado anteriormente, utilizando master, provoca el error y detiene la sesión de pruebaLogin y elimina ese login
Use cine;
Create User pruebaLogin For
Login pruebaLogin;

-- ? 8.Repite el punto 6 y Crea un usuario asociandolo al login creado anteriormente, no olvides utilizar la bd
Create Login pruebaLogin2 With
Password = '1234';

Use cine;
Create User pruebaLogin2 For
Login pruebaLogin2;

-- ? 9.denegar el permiso de crear tablas al login
Deny Create Table To pruebaLogin2;

-- ? 10.asignar el permiso de crear tablas  al login
Grant Create Table To pruebaLogin2;

-- ? 11.Agregar rol ('Sysadmin') de servidor a un usuario, no olvides usar el Exec sp_addsrvrolemember 
Exec sp_addsrvrolemember 'pruebaLogin2', 'sysadmin';

-- ? 12.Quitar rol ('Sysadmin')  de servidor a un usuario, no olvides usar el Exec sp_dropsrvrolemember 
Exec sp_dropsrvrolemember 'pruebaLogin2', 'sysadmin';

-- ? 13.Agregar rol ('db_datareader')  de bd a un usuario, no olvides usar exec  sp_addrolemember
Exec sp_addrolemember 'db_datareader', 'pruebaLogin2';

-- ? 14.Quitar rol ('db_datareader')  de bd a un usuario, no olvides usar exec  sp_droprolemember
Exec sp_droprolemember 'db_datareadroleer', 'pruebaLogin2';


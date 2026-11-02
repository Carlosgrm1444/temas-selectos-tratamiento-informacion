-- ? Crear una base de datos con un grupo de archivos secundario
Create Database Logistica on Primary (
  Name = NorthwindData,
  filename = 'C:\7BD\Northwind.mdf',
  size = 50mb,
  --el minimo es 512Kb, el predeterminado es 1MB,
  Filegrowth = 25 % --default es 10%, minimo es 64KB
) log on (
  Name = NorthwindLog,
  filename = 'C:\7BD\Northwind_log.ldf',
  size = 25MB,
  -- el minimo es 512Kb, el predeterminado es 1MB,
  Filegrowth = 25 %
);
-- ? Modificar la base de datos para agregar un grupo de archivos secundario
Alter Database Logistica
add filegroup SECONDARY;
Alter Database Logistica
add file (
    name = logisticaSecundario1,
    filename = 'C:\7BD\logistica_Secundario1.ndf',
    size = 10MB
  ) to filegroup SECONDARY;
-- ? Crear tablas en el grupo de archivos secundario
Use master;
ALTER DATABASE Logistica
MODIFY FILEGROUP [SECONDARY] DEFAULT;
-- ? Crear tabla de paises
Use Logistica;
Create Table paises(
  id_pais int primary key identity(1, 1),
  pais varchar(100) not null
);
-- ? Crear tabla de estados
create Table estados(
  id_estado int primary key identity(1, 1),
  estado varchar(100) not null,
  id_pais int foreign key references paises(id_pais)
);
-- ? Crear tabla de clientes
Create Table clientes(
  id_cliente int primary key identity(1, 1),
  razon_social varchar(100) not null,
  rfc varchar(13) unique,
  cp varchar(5) default '88000',
  id_estado int foreign key references estados(id_estado)
);
-- ? Crear tabla de servicios
Create Table servicios(
  id_servicio int primary key identity(1, 1),
  servicio varchar(50)
);
-- ? Alterar tablas
Alter Table paises
add aduana bit;
Alter Table servicios
add clave varchar(20) not null;
Alter Table clientes
add prueba varchar(20);
Alter Table clientes drop column prueba;
-- ? Crear tabla tipos de transporte
create table tipos_transporte(
  id_tipo_transporte int primary key identity(1, 1),
  tipo_transport varchar(50) not null
);
-- ? Crear tabla de productos
create table productos(
  id_producto int primary key identity(1, 1),
  producto varchar(80) not null,
  costo decimal(10, 2) not null,
  peligroso bit
);
-- ?  Alterar tabla de paises
Alter Table paises Drop Column aduanas;
-- ? Insertar paises y estados
insert Into paises (pais)
values ('Mexico'),
  ('Estados Unidos');
Insert Into estados (id_pais, estado)
values (1, 'Chihuahua'),
  (1, 'Tamaulipas'),
  (2, 'Texas'),
  (2, 'California');
-- ? Mostrar estados
Select *
From estados;
-- ? Instruccion que nos permite ver los grupos de archivos de la BD
use master;
exec sp_helpdb Logistica;
use logistica;
exec sp_helpfilegroup SECONDARY;
-- ? Insertar tipos de transporte y hacer consultas
Insert Into tipos_transporte (tipo_transport)
values ('Trailes'),
  ('Tren'),
  ('Avion');
Select *
From tipos_transporte
Where tipo_transport Like 'T%'
Order By tipo_transport Asc;
-- ? Insertar servicios y hacer consultas
Insert Into servicios (servicio, clave)
Values ('Importacion', 'imp'),
  ('Exportacion', 'exp');
Select UPPER(clave) as clave
from servicios;
Select Concat(servicio, '-', clave) As servicios
From servicios;
-- ? Insertar clientes y hacer consultas
Insert Into clientes (razon_social, rfc, id_estado)
Values ('tesla', 'TESLA129303', 1);
Select razon_social,
  estado,
  pais
From clientes
  Inner Join estados On clientes.id_estado = estados.id_estado
  Inner Join paises On paises.id_pais = estados.id_pais;
-- ? Actualizar estados
Update estados
Set estado = 'Tamaulipas'
Where id_estado = 1;
-- ? insertar productos y consultar
Insert Into productos (producto, costo, peligroso)
Values ('Mercurio', 1000000, 1);
Select count (*) As total
from productos;


Use master;
Exec sp_helpdb Logistica;

Use Logistica;
Exec sp_helpfilegroup SECONDARY;

Use master;

Alter Database Logistica
Modify Filegroup [SECONDARY] Default;

Use Master;

Exec sp_detach_db Logistica;

Alter Database Logistica
set single_user;
exec sp_attach_db Logistica,
'C:\Data\Northwind.mdf',
'C:\Data\logistica_Secundario1.ndf',
'C:\Data\Northwind_log.ldf';

Alter Database Logistica
Modify name = NuevaLogistica;

USE NuevaLogistica;
Exec Sp_rename 'paises',
'country';
Exec Sp_rename 'country.pais',
'country', 'COLUMN';

Alter Table clientes
Add Constraint UQ_Razon_social 
Unique (razon_social);

Alter Table productos
Add Constraint costo 
Default 0.00 for costo;

Select * FROM 
information_schema.table_constraints 
WHERE table_name = 'clientes';

Exec 
sp_helpconstraint 'clientes';
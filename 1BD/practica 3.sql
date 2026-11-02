-- ? Carlos Gabriel Rodriguez Macias
-- * Edith Dulce Athala Gomez
-- ? Practica 3 - 03/02/2026



-- ? Renombrar una tabla
Use agencia_aduanal_carlos;
Exec Sp_rename 'aduanas',
  'aduanas_carlos';
-- ? Agregar otra columna pero ahora de tipo datetime
Create Table productos (
  id_producto int primary key identity(1, 1),
  producto varchar(100) not null,
  fecha_caducidad datetime not null
);
-- ? Renombrar una columna
Exec Sp_rename 'productos.fecha_caducidad',
  fecha_vencimiento,
  'COLUMN';
-- ? Obtener nombre de TODAS las restricciones
Select * From Information_schema.table_constraints
Where table_name = 'aduanas_carlos';
-- ? Agregar restricción not null
Alter Table productos
Alter Column producto Varchar(150) Not Null;
-- ? Agregar restricción unique
Alter Table productos
Add Constraint uq_clave
Unique (producto);
-- ? Agregar restricción default
Alter Table aduanas_carlos
Add activo SMALLINT;

Alter Table aduanas_jesus
Add Constraint df_activo
Default 1 For activo;
-- ? Renombrar una restricción
Exec sp_rename df_activo, df_activo1, 'CONSTRAINT';
-- ? Eliminar la restricción unique
Alter Table productos
Drop Constraint uq_clave;
-- ? Eliminar la restricción default
Alter Table aduanas_carlos
Drop Constraint df_activo1;
-- ? Habilitación de multiusuario para una base de datos
Use Master;
Alter Database agencia_aduanal_carlos
Set MULTI_USER;
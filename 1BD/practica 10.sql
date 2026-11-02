-- ? Carlos Gabriel Rodriguez Macias
-- * Edith Dulce Athala Gomez
-- ? Practica 10 - Procedimientos almacenados

Use NuevaLogistica;

-- ? Procedimientos sin parametros
Create Procedure sp_ejemplo
As Begin Select *
From servicios;
End;

-- ? Ejecutar procedimiento
Exec sp_ejemplo;

-- ? Eliminar procedimiento
Drop Procedure sp_ejemplo;

-- ? Alterar procedimiento
Alter Procedure sp_ejemplo
As Begin
	Select * From productos;
End;

-- ? Consulta del contenido del objeto
Exec sp_helptext 'sp_ejemplo';

-- ? Procedimientos con parametros
Create Procedure sp_ejemplo2 @id int
As Begin Select *
From servicios Where id_servicio = @id;
End;

-- ? Procedimientos encriptados con parametros
Create Procedure sp_ejemplo3 @id1 int, @id2 int
With Encryption
As Begin Select *
From productos Where id_producto Between @id And @id2;
End;

-- ? Ejecutar procedimientos
Exec sp_ejemplo3 @id = 1, @id2 =2;
Exec sp_helptext 'sp_ejemplo3';

-- ? vistas encriptadas
Create View vw_ejemplo4 With Encryption As
Select * From productos
Exect sp_helptext 'vw_ejemplo4';

-- ? Procedimientos con if
Create Procedure sp_ejemplo5 @total DECIMAL
As BEGIN 
If @total > 1000
	Select costo - 10 As descuento 
	From productos;
Else 
	Select costo + 10 As aumento 
	From productos;
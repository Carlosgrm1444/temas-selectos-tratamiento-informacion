-- ? Carlos Gabriel Rodriguez Macias
-- * Edith Dulce Athala Gomez
-- ? Repaso - 19/02/2026


-- ? Se necesita obtener cuantos estados tiene cada pais
Use NuevaLogistica;

Select country, count(estado) as estados
From country Inner Join estados On Country.id_pais= estados.id_pais
Group By country;

-- ? Se necesita una vista con el nombre del país, estado
Create View Vista_Pais_Estado_Ciudad AS
Select country, estado
From country Inner Join estados On Country.id_pais= estados.id_pais;

-- ? Se agrega la columna de fechas a la tabla de productos
Alter Table productos
Add fecha_caducidad date;

-- ? Se necesita saber que productos caducan entre el 19-02-2026 al 19-03-2026
Select producto, fecha_caducidad
From productos Where fecha_caducidad Between '2026-02-19' And '2026-03-19';

-- ? Crear la tabla rel_clientes_servicios
Create Table rel_clientes_servicios_transportes (
id_cliente_servicio_transportes Int Primary Key Identity(1, 1),
id_cliente Int Foreign Key References clientes(id_cliente),
id_servicio Int Foreign Key References servicios(id_servicio),
id_tipo_transporte Int Foreign Key References tipos_transporte(id_tipo_transporte),
fecha_alta Date
);

-- ? Se necesita obtener un folio, nombre del cliente en mayúsculas (solo 3 caracteres) - El  servicio (solo los 2 primeros caracteres) - la clave primaria.
Select Concat(UPPER(Substring(razon_social,1, 3)), '-', Substring(servicio,1, 2), '-', id_cliente_servicio_transportes)
As folio
From clientes Inner Join rel_clientes_servicios_transportes 
On clientes.id_cliente = rel_clientes_servicios_transportes.id_cliente
Inner Join servicios 
On rel_clientes_servicios_transportes.id_servicio = servicios.id_servicio;

-- ? Se necesita saber cuantas aduanas hay 
Select count(aduana) as aduanas
From country Where aduana = 1;

-- ? Se necesita obtener el promedio del costo de los productos
Select AVG(costo) as promedio_costo
From productos;

-- ? Se necesita realizar un respaldo completo de la base de datos
Backup Database NuevaLogistica To Disk = 'C:\7BD\NuevaLogistica_completo.bak'
With Init, Format, Name = 'Backup Completo NuevaLogistica',
Description = 'Backup completo de la base de datos NuevaLogistica';

-- ? Se necesita obtener los 3 productos más baratos
Select Top 3 producto, costo
From productos Order By costo Asc;

-- ? Se necesita realizar un respaldo diferencial de la base de datos
Backup Database NuevaLogistica To Disk = 'C:\7BD\NuevaLogistica_diferencial.bak'
With Differential, Name = 'Backup Diferencial NuevaLogistica',
Description = 'Backup diferencial de la base de datos NuevaLogistica';

-- ? Se necesita realizar un respaldo del log de la base de datos
Backup Log NuevaLogistica To Disk = 'C:\7BD\NuevaLogistica_log.bak'
With Name = 'Backup Log NuevaLogistica',
Description = 'Backup del log de la base de datos NuevaLogistica';

-- ? Se necesita ver la información importante de la Base de datos
exec sp_helpdb NuevaLogistica;
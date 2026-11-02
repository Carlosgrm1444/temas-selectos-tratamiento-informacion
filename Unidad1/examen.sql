-- ? 1 Crear la base de datos y ver la informacion importante
Use master;
Create Database frontera_express_rodriguez On Primary (
    Name = FronteraExpressRodriguezData,
    filename = 'C:\Data\frontera_express_rodriguez.mdf',
    size = 50mb,
    Filegrowth = 25 %
) log on (
    Name = FronteraExpressRodriguezLog,
    filename = 'C:\Data\frontera_express_rodriguez_log.ldf',
    size = 25MB,
    Filegrowth = 25 %
);

Exec sp_helpdb frontera_express_rodriguez;

-- ? 2 Crear grupo de archivo y asociar un archivo
Alter Database frontera_express_rodriguez
Add Filegroup Operaciones_Rodriguez;

Alter Database frontera_express_rodriguez
Add File (
    Name = FronteraOperacion_Rodriguez,
    filename = 'C:\Data\FronteraOperacion_Rodriguez.ndf',
    size = 10MB,
    Filegrowth = 25 %
) To Filegroup Operaciones_Rodriguez;

-- ? 3 Crear tablas y asignar grupo de archivos 
Use frontera_express_rodriguez;

Create Table Clientes_Carlos(
    id_cliente int Identity(1, 1) Primary Key,
    razon_social varchar(100) Not Null,
    correo_electronico varchar(100) Not Null
);

Create Table Productos_Carlos(
    id_producto int Identity(1, 1) Primary Key,
    descripcion varchar(100) Not Null,
    peso_unitario decimal(10, 2) Not Null Check (peso_unitario > 0),
    existencia_disponible int Not Null Check (existencia_disponible >= 0)
);

Create Table Envios_Carlos(
    id_envio int Identity(1, 1) Primary Key,
    id_cliente int Not Null Foreign Key References Clientes_Carlos(id_cliente),
    fecha date Not Null,
    ciudad_destino varchar(100) Not Null,
    estado varchar(20) Not Null Check (estado In ('Pendiente', 'Entregado', 'Cancelado')),
    costo_servicio decimal(10, 2) Not Null Check (costo_servicio >= 0)
);

Create Table DetalleEnvio_Carlos(
    id_detalle int Identity(1, 1) Primary Key,
    id_envio int Not Null Foreign Key References Envios_Carlos(id_envio),
    id_producto int Not Null Foreign Key References Productos_Carlos(id_producto),
    cantidad_enviada int Not Null Check (cantidad_enviada > 0)
);

-- ! profe, creo que al final de cada tabla va algo como "In Operaciones_Rodriguez" 
-- ! para asignar, pero no estoy seguro, si si era asi, tenga piedad de mi 😭

-- ? 4 Desvincular y vincular los archivos en la carpeta examen_Rodriguez
Use master;
Exec sp_detach_db 'FronteraExpress_Rodriguez';

-- ? Despues de desvincular se mueven los archivos fisicos a C:\examen_Rodriguez
Create Database FronteraExpress_Rodriguez
On (Filename = 'C:\examen_Rodriguez\FronteraExpress_Rodriguez.mdf'), 
    (Filename = 'C:\examen_Rodriguez\FronteraOperacion_Rodriguez.ndf'), 
    (Filename = 'C:\examen_Rodriguez\FronteraExpress_Rodriguez_log.ldf')
    For Attach;

-- ? 5 Crear un respaldo diferencial
Backup Database FronteraExpress_Rodriguez To Disk = 'C:\Data\Carlos_Diferencial.bak'
With Differential, Name = 'Backup Diferencial Carlos',
Description = 'Backup diferencial de FronteraExpress_Rodriguez';

-- ? 6 Crear tabla temporal
-- ! La vdd no me acuerdo como crear tablas temporales profe, 
-- ! piedad 😭, le cambio el punto por una plana 🙏

-- ? 7 Crear usuarios
Create User Rodriguez_operaciones Without Login;
Create User Rodriguez_auditoria Without Login;
Create User Rodriguez_seguimiento Without Login;

-- ? 8 Mostrar cliente, suma de costos, promedio del costo por envio
Select Clientes_Carlos.razon_social,
       Sum(Envios_Carlos.costo_servicio) As suma_costos,
       Avg(Envios_Carlos.costo_servicio) As promedio_costo_envio
From Clientes_Carlos Inner Join Envios_Carlos
On Clientes_Carlos.id_cliente = Envios_Carlos.id_cliente
Group By Clientes_Carlos.razon_social;

-- ? 9 Permisos para usuario operaciones
Grant Select On dbo.Clientes_Carlos To Rodriguez_operaciones;
Grant Select On dbo.Productos_Carlos To Rodriguez_operaciones;
Grant Select On dbo.Envios_Carlos To Rodriguez_operaciones;
Grant Select On dbo.DetalleEnvio_Carlos To Rodriguez_operaciones;

Grant Insert On dbo.Envios_Carlos To Rodriguez_operaciones;
Grant Insert On dbo.DetalleEnvio_Carlos To Rodriguez_operaciones;

Grant Update (estado) On dbo.Envios_Carlos To Rodriguez_operaciones;

-- ? 10 Procedimiento de envio de email
sp_send_dbmail

-- ? 11 Retirar permiso de insertar detalles de envio
Revok Insert In dbo.DetalleEnvio_Carlos From Rodriguez_operaciones;
-- ? No me acuerdo las diferencias exactas 😅

-- ? 12 Crear respaldo full
Backup Database FronteraExpress_Rodriguez To Disk = 'C:\Data\Carlos_Full.bak'
With Init, Name = 'Backup Full Carlos',
Description = 'Backup full de FronteraExpress_Rodriguez';

-- ? 13 Restaurar bd
Use master;

Restore Database FronteraExpress_Rodriguez
From Disk = 'C:\Data\Carlos_Full.bak';

-- ? 14 Crear logins
Create Login login_operaciones_Rodriguez With Password = 'PadreNuestro';
Create Login login_auditoria_Rodriguez With Password = 'QestasEnElCielo';
Create Login login_seguimiento_Rodriguez With Password = 'Amen';

-- ? 15 El usuario auditoria solo puede leer datos
Use FronteraExpress_Rodriguez;

Alter Rol db_datareader
Add Member Rodriguez_auditoria;

-- ? 16 Envios de septiembre
Declare @ciudad_indicada varchar(100) = 'Guadalajara'; -- Ajiaaa

Select Envios_Carlos.id_envio,
       Envios_Carlos.fecha,
       Envios_Carlos.ciudad_destino,
       Clientes_Carlos.razon_social
From Envios_Carlos Inner Join Clientes_Carlos
On Envios_Carlos.id_cliente = Clientes_Carlos.id_cliente
Where Envios_Carlos.fecha >= '2026-09-01'
And Envios_Carlos.fecha < '2026-10-01'
And Envios_Carlos.ciudad_destino = @ciudad_indicada
Order By Envios_Carlos.costo_servicio Desc;

-- ? 17 Crear vista encriptada con mi nombre
Create View VistaEnvios_Carlos
With Encryption
As
Select Envios_Carlos.id_envio,
       Clientes_Carlos.razon_social,
       Sum(d.cantidad_enviada) As total_productos_enviados
From Envios_Carlos Inner Join Clientes_Carlos
On Envios_Carlos.id_cliente = Clientes_Carlos.id_cliente
Inner Join DetalleEnvio_Carlos d
On Envios_Carlos.id_envio = d.id_envio
Group By Envios_Carlos.id_envio, Clientes_Carlos.razon_social
Having Sum(d.cantidad_enviada) > 1500;

-- ? 18 Inserciones
Insert Into Clientes_Carlos(razon_social, correo_electronico) Values
('Transportes nld', 'contacto@nld.com'),
('Comercial gld', 'ventas@gdl.com');

Insert Into Productos_Carlos(descripcion, peso_unitario, existencia_disponible) Values
('Refacciones automotrices', 12.50, 5000),
('Equipo electronico', 4.75, 3000),
('Material textil', 2.30, 7000);

Insert Into Envios_Carlos(id_cliente, fecha, ciudad_destino, estado, costo_servicio) Values
(1, '2026-09-05', 'Nuevo Laredo', N'Pendiente', 1850.00),
(2, '2026-09-12', 'Monterrey', N'En transito', 2300.00),
(1, '2026-09-20', 'Matamoros', N'Entregado', 1950.00);

Insert Into DetalleEnvio_Carlos(id_envio, id_producto, cantidad_enviada) Values
(1, 1, 800),
(1, 2, 900),
(2, 2, 700),
(2, 3, 950),
(3, 1, 500),
(3, 3, 1200);

-- ? 19 El usuario seguimiento solo puede realizar respaldos
Alter Role db_backupoperatorr
Add Member Rodriguez_seguimiento;

-- ? 20 Cliente en mayusculas con su ciudad en una sola columna, solo ciudades que terminen en o
-- ! ya me desespere profe


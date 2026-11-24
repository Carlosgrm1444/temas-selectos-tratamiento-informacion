-- ? Carlos Gabriel Rodríguez Macías
-- ! Juan Manuel Ortega García
-- * Bernardo Guillermo Núñez López
-- ? Proyecto Unidad 3 - Copia de demostracion con los CSV compartidos
-- ! Ejecutar una sola vez. Crea una base nueva llamada pepsi_u3_demo.

Use master;
GO
Create Database pepsi_u3_demo;
GO

Use pepsi_u3_demo;
GO

Create Schema proyecto_u2;
GO

-- ? Almacén de referencia. No es un cuarto CSV ni una cuarta tabla analizada.
Create Table proyecto_u2.almacen
(
  id_almacen int Primary Key Identity(1, 1),
  clave_almacen varchar(10) Not Null Unique,
  nombre varchar(100) Not Null,
  ubicacion varchar(200) Not Null,
  activo bit Not Null Default 1
);

Create Table proyecto_u2.producto
(
  id_producto int Primary Key Identity(1, 1),
  clave_producto varchar(15) Not Null Unique,
  nombre varchar(100) Not Null,
  presentacion varchar(50) Not Null,
  precio decimal(10, 2) Not Null,
  activo bit Not Null Default 1,
  Constraint ck_u2_producto_precio Check (precio > 0)
);

Create Table proyecto_u2.lote
(
  id_lote int Primary Key Identity(1, 1),
  id_producto int Not Null,
  numero_lote varchar(30) Not Null,
  fecha_recepcion date Not Null,
  fecha_caducidad date Not Null,
  Constraint fk_u2_lote_producto Foreign Key (id_producto)
    References proyecto_u2.producto(id_producto),
  Constraint uq_u2_lote_producto_numero Unique (id_producto, numero_lote),
  Constraint uq_u2_lote_validacion Unique (id_lote, id_producto),
  Constraint ck_u2_lote_fechas Check (fecha_caducidad > fecha_recepcion)
);

Create Table proyecto_u2.inventario_lote
(
  id_inventario int Primary Key Identity(1, 1),
  id_almacen int Not Null,
  id_lote int Not Null,
  id_producto int Not Null,
  cantidad int Not Null Default 0,
  fecha_actualizacion datetime2 Not Null Default Sysdatetime(),
  Constraint fk_u2_inventario_almacen Foreign Key (id_almacen)
    References proyecto_u2.almacen(id_almacen),
  Constraint fk_u2_inventario_lote_producto Foreign Key (id_lote, id_producto)
    References proyecto_u2.lote(id_lote, id_producto),
  Constraint uq_u2_inventario_almacen_lote Unique (id_almacen, id_lote),
  Constraint uq_u2_inventario_validacion
    Unique (id_inventario, id_lote, id_producto, id_almacen),
  Constraint ck_u2_inventario_cantidad Check (cantidad >= 0)
);
GO


-- ? Agregar el almacen de referencia.
Insert Into proyecto_u2.almacen (clave_almacen, nombre, ubicacion)
Values ('A001', 'Almacen principal', 'Nuevo Laredo');
GO

-- ? Insertar los registros limpios de producto.
Set Identity_Insert proyecto_u2.producto On;
Insert Into proyecto_u2.producto
  (id_producto, clave_producto, nombre, presentacion, precio, activo)
Values
  (2, 'BEB002', 'Pepsi', '355 ml', 59.43, 1),
  (3, 'BEB003', '7 Up', '600 ml', 139.37, 1),
  (8, 'BEB008', '7 Up', '600 ml', 185.59, 1),
  (9, 'BEB009', 'Gatorade', '600 ml', 40.84, 1),
  (10, 'BEB010', 'Mountain Dew', '600 ml', 129.82, 1),
  (11, 'BEB011', 'Pepsi', '1 litro', 200.96, 1),
  (12, 'BEB012', 'Mirinda', '1 litro', 29.0, 1),
  (13, 'BEB013', '7 Up', '1 litro', 176.27, 1),
  (14, 'BEB014', 'Gatorade', '1 litro', 80.35, 1),
  (15, 'BEB015', 'Mountain Dew', '1 litro', 22.28, 1),
  (16, 'BEB016', 'Pepsi', '1.5 litros', 38.16, 1),
  (17, 'BEB017', 'Mirinda', '1.5 litros', 152.09, 1),
  (18, 'BEB018', '7 Up', '1.5 litros', 147.02, 1),
  (19, 'BEB019', 'Gatorade', '1.5 litros', 32.89, 1),
  (20, 'BEB020', 'Mountain Dew', '1.5 litros', 88.86, 1),
  (21, 'BEB021', 'Pepsi', '2 litros', 39.72, 1),
  (22, 'BEB022', 'Mirinda', '2 litros', 190.56, 1),
  (23, 'BEB023', '7 Up', '2 litros', 149.1, 1),
  (24, 'BEB024', 'Gatorade', '2 litros', 29.36, 1),
  (25, 'BEB025', 'Mountain Dew', '2 litros', 280.94, 1),
  (26, 'BEB026', 'Pepsi', '3 litros', 195.28, 1),
  (27, 'BEB027', 'Mirinda', '3 litros', 50.56, 1),
  (28, 'BEB028', '7 Up', '3 litros', 83.15, 1),
  (29, 'BEB029', 'Gatorade', '3 litros', 216.64, 1),
  (30, 'BEB030', 'Mountain Dew', '3 litros', 215.59, 1),
  (31, 'BEB031', 'Pepsi', '6 latas', 201.03, 1),
  (32, 'BEB032', 'Mirinda', '6 latas', 30.27, 1),
  (33, 'BEB033', '7 Up', '6 latas', 199.1, 1),
  (34, 'BEB034', 'Gatorade', '6 latas', 201.87, 1),
  (35, 'BEB035', 'Mountain Dew', '6 latas', 139.98, 1),
  (36, 'BEB036', 'Pepsi', '12 latas', 26.24, 1),
  (37, 'BEB037', 'Mirinda', '12 latas', 82.44, 1),
  (38, 'BEB038', '7 Up', '12 latas', 25.26, 1),
  (39, 'BEB039', 'Gatorade', '12 latas', 192.4, 1),
  (40, 'BEB040', 'Mountain Dew', '12 latas', 291.3, 1),
  (41, 'BEB041', 'Pepsi', '24 latas', 53.63, 1),
  (42, 'BEB042', 'Mirinda', '24 latas', 104.89, 1),
  (43, 'BEB043', '7 Up', '24 latas', 147.34, 1),
  (44, 'BEB044', 'Gatorade', '24 latas', 57.26, 1),
  (45, 'BEB045', 'Mountain Dew', '24 latas', 187.17, 1),
  (46, 'BEB046', 'Pepsi', '12 botellas', 48.59, 1),
  (47, 'BEB047', 'Mirinda', '12 botellas', 197.07, 1),
  (48, 'BEB048', '7 Up', '12 botellas', 111.08, 1),
  (49, 'BEB049', 'Gatorade', '12 botellas', 193.58, 1);
Set Identity_Insert proyecto_u2.producto Off;
GO

-- ? Insertar los registros limpios de lote.
Set Identity_Insert proyecto_u2.lote On;
Insert Into proyecto_u2.lote
  (id_lote, id_producto, numero_lote, fecha_recepcion, fecha_caducidad)
Values
  (2, 2, 'LOT002', '2026-01-29', '2027-01-29'),
  (3, 3, 'LOT003', '2026-06-05', '2027-06-05'),
  (10, 10, 'LOT010', '2026-05-25', '2027-05-25'),
  (11, 11, 'LOT011', '2026-07-31', '2027-07-31'),
  (12, 12, 'LOT012', '2026-05-07', '2027-05-07'),
  (13, 13, 'LOT013', '2026-09-09', '2027-09-09'),
  (14, 14, 'LOT014', '2026-04-09', '2027-04-09'),
  (15, 15, 'LOT015', '2026-03-09', '2027-03-09'),
  (16, 16, 'LOT016', '2026-02-18', '2027-02-18'),
  (17, 17, 'LOT017', '2026-08-01', '2027-08-01'),
  (18, 18, 'LOT018', '2026-01-23', '2027-01-23'),
  (19, 19, 'LOT019', '2026-03-23', '2027-03-23'),
  (20, 20, 'LOT020', '2026-05-15', '2027-05-15'),
  (21, 21, 'LOT021', '2026-04-04', '2027-04-04'),
  (22, 22, 'LOT022', '2026-05-03', '2027-05-03'),
  (23, 23, 'LOT023', '2026-06-15', '2027-06-15'),
  (24, 24, 'LOT024', '2026-01-20', '2027-01-20'),
  (25, 25, 'LOT025', '2026-05-20', '2027-05-20'),
  (26, 26, 'LOT026', '2026-02-14', '2027-02-14'),
  (27, 27, 'LOT027', '2026-04-04', '2027-04-04'),
  (28, 28, 'LOT028', '2026-09-11', '2027-09-11'),
  (29, 29, 'LOT029', '2026-04-25', '2027-04-25'),
  (30, 30, 'LOT030', '2026-09-19', '2027-09-19'),
  (31, 31, 'LOT031', '2026-01-22', '2027-01-22'),
  (32, 32, 'LOT032', '2026-06-01', '2027-06-01'),
  (33, 33, 'LOT033', '2026-08-03', '2027-08-03'),
  (34, 34, 'LOT034', '2026-08-11', '2027-08-11'),
  (35, 35, 'LOT035', '2026-04-03', '2027-04-03'),
  (36, 36, 'LOT036', '2026-04-06', '2027-04-06'),
  (37, 37, 'LOT037', '2026-05-16', '2027-05-16'),
  (38, 38, 'LOT038', '2026-08-05', '2027-08-05'),
  (39, 39, 'LOT039', '2026-01-19', '2027-01-19'),
  (40, 40, 'LOT040', '2026-01-26', '2027-01-26'),
  (41, 41, 'LOT041', '2026-03-15', '2027-03-15'),
  (42, 42, 'LOT042', '2026-07-09', '2027-07-09'),
  (43, 43, 'LOT043', '2026-01-18', '2027-01-18'),
  (44, 44, 'LOT044', '2026-07-18', '2027-07-18'),
  (45, 45, 'LOT045', '2026-03-26', '2027-03-26'),
  (46, 46, 'LOT046', '2026-06-07', '2027-06-07'),
  (47, 47, 'LOT047', '2026-07-05', '2027-07-05'),
  (48, 48, 'LOT048', '2026-05-02', '2027-05-02'),
  (49, 49, 'LOT049', '2026-07-14', '2027-07-14');
Set Identity_Insert proyecto_u2.lote Off;
GO

-- ? Insertar los registros limpios de inventario_lote.
Set Identity_Insert proyecto_u2.inventario_lote On;
Insert Into proyecto_u2.inventario_lote
  (id_inventario, id_almacen, id_lote, id_producto, cantidad, fecha_actualizacion)
Values
  (2, 1, 2, 2, 11, '2026-10-31 12:00:00'),
  (3, 1, 3, 3, 481, '2026-10-31 12:00:00'),
  (10, 1, 10, 10, 30, '2026-10-31 12:00:00'),
  (11, 1, 11, 11, 111, '2026-10-31 12:00:00'),
  (12, 1, 12, 12, 393, '2026-10-31 12:00:00'),
  (13, 1, 13, 13, 147, '2026-10-31 12:00:00'),
  (14, 1, 14, 14, 66, '2026-10-31 12:00:00'),
  (15, 1, 15, 15, 378, '2026-10-31 12:00:00'),
  (16, 1, 16, 16, 126, '2026-10-31 12:00:00'),
  (17, 1, 17, 17, 203, '2026-10-31 12:00:00'),
  (18, 1, 18, 18, 200, '2026-10-31 12:00:00'),
  (19, 1, 19, 19, 469, '2026-10-31 12:00:00'),
  (20, 1, 20, 20, 446, '2026-10-31 12:00:00'),
  (21, 1, 21, 21, 254, '2026-10-31 12:00:00'),
  (22, 1, 22, 22, 41, '2026-10-31 12:00:00'),
  (23, 1, 23, 23, 85, '2026-10-31 12:00:00'),
  (24, 1, 24, 24, 229, '2026-10-31 12:00:00'),
  (25, 1, 25, 25, 205, '2026-10-31 12:00:00'),
  (26, 1, 26, 26, 281, '2026-10-31 12:00:00'),
  (27, 1, 27, 27, 142, '2026-10-31 12:00:00'),
  (28, 1, 28, 28, 452, '2026-10-31 12:00:00'),
  (29, 1, 29, 29, 70, '2026-10-31 12:00:00'),
  (30, 1, 30, 30, 419, '2026-10-31 12:00:00'),
  (31, 1, 31, 31, 220, '2026-10-31 12:00:00'),
  (32, 1, 32, 32, 442, '2026-10-31 12:00:00'),
  (33, 1, 33, 33, 281, '2026-10-31 12:00:00'),
  (34, 1, 34, 34, 142, '2026-10-31 12:00:00'),
  (35, 1, 35, 35, 361, '2026-10-31 12:00:00'),
  (36, 1, 36, 36, 212, '2026-10-31 12:00:00'),
  (37, 1, 37, 37, 183, '2026-10-31 12:00:00'),
  (38, 1, 38, 38, 349, '2026-10-31 12:00:00'),
  (39, 1, 39, 39, 452, '2026-10-31 12:00:00'),
  (40, 1, 40, 40, 194, '2026-10-31 12:00:00'),
  (41, 1, 41, 41, 490, '2026-10-31 12:00:00'),
  (42, 1, 42, 42, 118, '2026-10-31 12:00:00'),
  (43, 1, 43, 43, 77, '2026-10-31 12:00:00'),
  (44, 1, 44, 44, 42, '2026-10-31 12:00:00'),
  (45, 1, 45, 45, 90, '2026-10-31 12:00:00'),
  (46, 1, 46, 46, 77, '2026-10-31 12:00:00'),
  (47, 1, 47, 47, 118, '2026-10-31 12:00:00'),
  (48, 1, 48, 48, 337, '2026-10-31 12:00:00'),
  (49, 1, 49, 49, 119, '2026-10-31 12:00:00');
Set Identity_Insert proyecto_u2.inventario_lote Off;
GO

Create Or Alter Procedure proyecto_u2.usp_cambiar_precio
  @id_producto int, @precio decimal(10, 2) = Null
With Encryption
As Begin
  Begin Try
    Update proyecto_u2.producto
    Set precio = Isnull(@precio, precio)
    Where id_producto = @id_producto;

    If @@Rowcount = 0
      Print 'El producto no existe.';
    Else
      Print 'Precio actualizado.';
  End Try
  Begin Catch
    Select Error_Number() As numero, Error_Message() As mensaje;
  End Catch
End;
GO

Create Or Alter Procedure proyecto_u2.usp_registrar_lote
  @id_producto int, @numero_lote varchar(30),
  @fecha_recepcion date, @fecha_caducidad date
With Encryption
As Begin
  Begin Try
    Insert Into proyecto_u2.lote
      (id_producto, numero_lote, fecha_recepcion, fecha_caducidad)
    Values
      (@id_producto, @numero_lote, @fecha_recepcion, @fecha_caducidad);

    Select id_lote, numero_lote, fecha_caducidad
    From proyecto_u2.lote
    Where id_lote = Scope_Identity();
  End Try
  Begin Catch
    Select Error_Number() As numero, Error_Message() As mensaje;
  End Catch
End;
GO

Create Or Alter Procedure proyecto_u2.usp_productos_precio_alto
As Begin
  Select id_producto, nombre, precio
  From proyecto_u2.producto
  Where activo = 1 And precio >
    (Select Avg(precio) From proyecto_u2.producto Where activo = 1)
  Order By precio Desc;
End;
GO

Create Or Alter Procedure proyecto_u2.usp_lotes_con_existencia
  @dias int
As Begin
  If @dias Is Null Or @dias Not Between 1 And 365
    Return;

  Select id_lote, numero_lote, fecha_caducidad
  From proyecto_u2.lote
  Where fecha_caducidad Between Cast(Getdate() As date)
    And Dateadd(day, @dias, Cast(Getdate() As date))
    And id_lote In
      (Select id_lote From proyecto_u2.inventario_lote Where cantidad > 0)
  Order By fecha_caducidad;
End;
GO

Create Or Alter Procedure proyecto_u2.usp_consultar_producto
  @id_producto int
As Begin
  If @id_producto Is Null Or @id_producto <= 0
  Begin
    Print 'El ID no es valido.';
    Return;
  End;

  Select id_producto, nombre, precio
  From proyecto_u2.producto
  Where id_producto = @id_producto;

  If @@Rowcount = 0
    Print 'El producto no existe.';
End;
GO

Create Or Alter Procedure proyecto_u2.usp_validar_entrada
  @id_almacen int, @id_lote int, @cantidad int
As Begin
  If @cantidad Is Null Or @cantidad <= 0
    Print 'La cantidad no es valida.';
  Else If Not Exists
    (Select 1 From proyecto_u2.almacen
     Where id_almacen = @id_almacen And activo = 1)
    Print 'El almacen no esta disponible.';
  Else If Not Exists
    (Select 1 From proyecto_u2.lote Where id_lote = @id_lote)
    Print 'El lote no existe.';
  Else
    Print 'Entrada valida.';
End;
GO

Create Or Alter Procedure proyecto_u2.usp_actualizar_precios
  @aumento decimal(10, 2)
As Begin
  If @aumento Is Null Or @aumento <= 0
    Return;

  Declare @contador int = 1, @ultimo int;
  Select @ultimo = Max(id_producto) From proyecto_u2.producto;

  While @contador <= @ultimo
  Begin
    Update proyecto_u2.producto
    Set precio = precio + @aumento
    Where id_producto = @contador And activo = 1;
    Set @contador = @contador + 1;
  End;
End;
GO

-- * Usamos Max porque los IDs conservados tienen saltos despues del ETL.
-- * La prueba se revierte en 90_ejecutar_ejemplos.sql.

Create Or Alter Procedure proyecto_u2.usp_resumen_almacenes
As Begin
  Declare @contador int = 1, @ultimo int;
  Select @ultimo = Max(id_almacen) From proyecto_u2.almacen;

  While @contador <= @ultimo
  Begin
    Select a.id_almacen, a.nombre,
      Isnull(Sum(i.cantidad), 0) As unidades
    From proyecto_u2.almacen a
    Left Join proyecto_u2.inventario_lote i
      On a.id_almacen = i.id_almacen
    Where a.id_almacen = @contador
    Group By a.id_almacen, a.nombre;
    Set @contador = @contador + 1;
  End;
End;
GO

Create Or Alter Procedure proyecto_u2.usp_estado_inventario
As Begin
  Select id_almacen, id_lote, cantidad,
    Case
      When cantidad = 0 Then 'Sin existencias'
      When cantidad < 20 Then 'Reponer pronto'
      Else 'Existencia suficiente'
    End As estado
  From proyecto_u2.inventario_lote
  Order By cantidad;
End;
GO

Create Or Alter Procedure proyecto_u2.usp_estado_lotes
  @fecha_revision date
As Begin
  Select numero_lote, fecha_caducidad,
    Case
      When fecha_caducidad < @fecha_revision Then 'Vencido'
      When fecha_caducidad <= Dateadd(day, 30, @fecha_revision)
        Then 'Prioridad alta'
      Else 'Vigente'
    End As estado
  From proyecto_u2.lote
  Order By fecha_caducidad;
End;
GO

-- ? Verificar los tres archivos cargados.
Select 'producto' As tabla, Count(*) As registros From proyecto_u2.producto
Union All Select 'lote', Count(*) From proyecto_u2.lote
Union All Select 'inventario_lote', Count(*) From proyecto_u2.inventario_lote;
GO

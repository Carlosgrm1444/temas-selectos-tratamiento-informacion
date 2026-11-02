-- ? Punto 5. Usuarios, roles y privilegios.
-- ? Objetivo: separar las actividades de captura, almacen, reparto y supervision.
-- ! Requisito: ejecutar primero los puntos 1 al 4 con una cuenta administradora.

Use master;
GO

-- ? 5.1 Crear inicios de sesion ficticios para las pruebas.
Create Login usuario_captura
With Password = 'Proyecto_2026!Captura', Check_Policy = On;

Create Login usuario_almacen
With Password = 'Proyecto_2026!Almacen', Check_Policy = On;

Create Login usuario_reparto
With Password = 'Proyecto_2026!Reparto', Check_Policy = On;

Create Login usuario_supervision
With Password = 'Proyecto_2026!Supervision', Check_Policy = On;
GO

Use pepsi_distribucion;
GO

-- ? 5.2 Crear usuarios y roles de la base de datos.
Create User usuario_captura For Login usuario_captura;
Create User usuario_almacen For Login usuario_almacen;
Create User usuario_reparto For Login usuario_reparto;
Create User usuario_supervision For Login usuario_supervision;

Create Role rol_captura;
Create Role rol_almacen;
Create Role rol_reparto;
Create Role rol_supervision;

Alter Role rol_captura Add Member usuario_captura;
Alter Role rol_almacen Add Member usuario_almacen;
Alter Role rol_reparto Add Member usuario_reparto;
Alter Role rol_supervision Add Member usuario_supervision;
GO

-- ? 5.3 Mostrar a captura unicamente los pedidos que registro.
Create View dbo.vw_pedidos_captura
As
Select
  pedido.id_pedido,
  pedido.folio,
  pedido.id_tienda,
  pedido.fecha_pedido,
  pedido.fecha_requerida,
  pedido.estado
From dbo.pedido pedido
Where pedido.usuario_captura = User_Name();
GO

Create Procedure dbo.crear_pedido
  @folio varchar(20),
  @id_tienda int,
  @fecha_requerida date
As
Begin
  Set Nocount On;

  Insert Into dbo.pedido
    (folio, id_tienda, fecha_requerida, usuario_captura)
  Values
    (@folio, @id_tienda, @fecha_requerida, User_Name());

  Select Scope_Identity() As id_pedido_creado;
End;
GO

Create Procedure dbo.agregar_detalle_pedido
  @folio varchar(20),
  @id_producto int,
  @cantidad int
As
Begin
  Set Nocount On;

  Declare @id_pedido int;
  Declare @precio decimal(10, 2);

  Select @id_pedido = id_pedido
  From dbo.pedido
  Where folio = @folio
    And usuario_captura = User_Name();

  Select @precio = precio
  From dbo.producto
  Where id_producto = @id_producto
    And activo = 1;

  If @id_pedido Is Null
    Throw 50001, 'El pedido no pertenece al usuario.', 1;

  If @precio Is Null
    Throw 50002, 'El producto no existe o esta inactivo.', 1;

  Insert Into dbo.detalle_pedido
    (id_pedido, id_producto, cantidad_solicitada, precio_unitario)
  Values
    (@id_pedido, @id_producto, @cantidad, @precio);
End;
GO

-- ? 5.4 Mostrar a reparto solamente las entregas asignadas a su usuario.
Create View dbo.vw_entregas_repartidor
As
Select
  entrega.id_entrega,
  entrega.folio,
  pedido.folio As pedido,
  tienda.nombre As tienda,
  tienda.direccion,
  entrega.fecha_salida,
  entrega.fecha_entrega,
  entrega.estado
From dbo.entrega entrega
Inner Join dbo.pedido pedido
  On entrega.id_pedido = pedido.id_pedido
Inner Join dbo.tienda tienda
  On pedido.id_tienda = tienda.id_tienda
Where entrega.repartidor_usuario = User_Name();
GO

Create Procedure dbo.actualizar_estado_entrega
  @folio varchar(20),
  @estado varchar(20)
As
Begin
  Set Nocount On;

  If @estado Not In ('EN_RUTA', 'PARCIAL', 'ENTREGADA', 'CON_INCIDENCIA')
    Throw 50003, 'El estado de la entrega no es valido.', 1;

  Update dbo.entrega
  Set estado = @estado,
      fecha_entrega = Case
        When @estado In ('PARCIAL', 'ENTREGADA', 'CON_INCIDENCIA')
          Then Sysdatetime()
        Else fecha_entrega
      End
  Where folio = @folio
    And repartidor_usuario = User_Name();

  If @@ROWCOUNT = 0
    Throw 50004, 'La entrega no pertenece al usuario.', 1;
End;
GO

-- ? 5.5 Asignar solamente los permisos necesarios a cada rol.
Grant Select On Object::dbo.tienda To rol_captura;
Grant Select On Object::dbo.producto To rol_captura;
Grant Select On Object::dbo.vw_pedidos_captura To rol_captura;
Grant Execute On Object::dbo.crear_pedido To rol_captura;
Grant Execute On Object::dbo.agregar_detalle_pedido To rol_captura;
Deny Select, Insert, Update, Delete On Object::dbo.pedido To rol_captura;
Deny Select, Insert, Update, Delete On Object::dbo.detalle_pedido To rol_captura;

Grant Select On Object::dbo.producto To rol_almacen;
Grant Select On Object::dbo.almacen To rol_almacen;
Grant Select On Object::dbo.lote To rol_almacen;
Grant Select, Update On Object::dbo.inventario_lote To rol_almacen;
Grant Select, Insert On Object::dbo.movimiento_inventario To rol_almacen;
Grant Select, Insert, Update On Object::dbo.conteo_inventario To rol_almacen;
Grant Select, Insert, Update On Object::dbo.detalle_conteo To rol_almacen;

Grant Select On Object::dbo.vw_entregas_repartidor To rol_reparto;
Grant Execute On Object::dbo.actualizar_estado_entrega To rol_reparto;
Deny Select, Insert, Update, Delete On Object::dbo.entrega To rol_reparto;

Grant Select On Schema::dbo To rol_supervision;
GO

-- ? 5.6 Probar una accion permitida para captura.
Execute As User = 'usuario_captura';

Declare @tienda int =
  (Select id_tienda From dbo.tienda Where clave_tienda = 'T001');
Declare @producto int =
  (Select id_producto From dbo.producto Where clave_producto = 'BEB-001');

Exec dbo.crear_pedido
  @folio = 'PED-SEG-001',
  @id_tienda = @tienda,
  @fecha_requerida = '2026-09-30';

Exec dbo.agregar_detalle_pedido
  @folio = 'PED-SEG-001',
  @id_producto = @producto,
  @cantidad = 5;

Select * From dbo.vw_pedidos_captura;
Revert;
GO

-- ? 5.7 Probar que captura no puede consultar directamente todos los pedidos.
Execute As User = 'usuario_captura';

Begin Try
  Select * From dbo.pedido;
End Try
Begin Catch
  Select Error_Message() As permiso_denegado_esperado;
End Catch;

Revert;
GO

-- ? 5.8 Probar las acciones permitida y denegada para almacen.
Execute As User = 'usuario_almacen';

Select Top 1 id_inventario, cantidad
From dbo.inventario_lote
Order By id_inventario;

Begin Try
  Delete From dbo.inventario_lote
  Where id_inventario = -1;
End Try
Begin Catch
  Select Error_Message() As permiso_denegado_esperado;
End Catch;

Revert;
GO

-- ? 5.9 Probar las acciones permitida y denegada para reparto.
Execute As User = 'usuario_reparto';

Select * From dbo.vw_entregas_repartidor;

Exec dbo.actualizar_estado_entrega
  @folio = 'ENT-001',
  @estado = 'ENTREGADA';

Begin Try
  Select * From dbo.entrega;
End Try
Begin Catch
  Select Error_Message() As permiso_denegado_esperado;
End Catch;

Revert;
GO

-- ? 5.10 Probar las acciones permitida y denegada para supervision.
Execute As User = 'usuario_supervision';

Select Top 1 folio, estado
From dbo.pedido
Order By id_pedido;

Begin Try
  Update dbo.pedido
  Set estado = 'CANCELADO'
  Where id_pedido = -1;
End Try
Begin Catch
  Select Error_Message() As permiso_denegado_esperado;
End Catch;

Revert;
GO

-- ? 5.11 Verificar los integrantes y permisos de los roles.
Select
  rol.name As rol,
  usuario.name As usuario
From sys.database_role_members integrante
Inner Join sys.database_principals rol
  On integrante.role_principal_id = rol.principal_id
Inner Join sys.database_principals usuario
  On integrante.member_principal_id = usuario.principal_id
Where rol.name Like 'rol_%'
Order By rol.name;

Select
  usuario.name As rol,
  permiso.state_desc,
  permiso.permission_name,
  Object_Name(permiso.major_id) As objeto
From sys.database_permissions permiso
Inner Join sys.database_principals usuario
  On permiso.grantee_principal_id = usuario.principal_id
Where usuario.name Like 'rol_%'
Order By usuario.name, objeto, permiso.permission_name;

-- * Evidencia: capturar los roles y las pruebas permitida y denegada de cada uno.

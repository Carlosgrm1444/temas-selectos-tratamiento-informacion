-- ? Carlos Gabriel Rodriguez Macias
-- ! Juan Manuel Ortega Garcia
-- * Bernardo Guillermo Nuñez Lopez
-- ? Proyecto Unidad 2 corregido - Usuarios y privilegios

Use pepsi_distribucion;
GO

-- ? Retirar al administrador tecnico de db_owner si estaba agregado.
If Is_RoleMember('db_owner', 'usuario_admin_tecnico') = 1
  Alter Role db_owner Drop Member usuario_admin_tecnico;
GO

-- ? Crear los roles solamente cuando no existan.
If Database_Principal_Id('rol_captura') Is Null
  Create Role rol_captura;

If Database_Principal_Id('rol_almacen') Is Null
  Create Role rol_almacen;

If Database_Principal_Id('rol_reparto') Is Null
  Create Role rol_reparto;

If Database_Principal_Id('rol_supervision') Is Null
  Create Role rol_supervision;

If Database_Principal_Id('rol_admin_tecnico') Is Null
  Create Role rol_admin_tecnico;
GO

-- ? Crear los usuarios solamente cuando no existan.
If Database_Principal_Id('usuario_captura') Is Null
  Create User usuario_captura For Login usuario_captura;

If Database_Principal_Id('usuario_almacen') Is Null
  Create User usuario_almacen For Login usuario_almacen;

If Database_Principal_Id('usuario_reparto') Is Null
  Create User usuario_reparto For Login usuario_reparto;

If Database_Principal_Id('usuario_supervision') Is Null
  Create User usuario_supervision For Login usuario_supervision;

If Database_Principal_Id('usuario_admin_tecnico') Is Null
  Create User usuario_admin_tecnico For Login usuario_admin_tecnico;
GO

-- ? Retirar concesiones anteriores de las tablas del proyecto.
Declare @limpieza nvarchar(max) = '';

Select @limpieza = @limpieza +
  'Revoke Select, Insert, Update, Delete On Object::' +
  Quotename(Schema_Name(tablas.schema_id)) + '.' + Quotename(tablas.name) +
  ' From ' + Quotename(roles.name) + ';' + Char(10)
From sys.tables tablas
Cross Join sys.database_principals roles
Where roles.name In
(
  'rol_captura',
  'rol_almacen',
  'rol_reparto',
  'rol_supervision',
  'rol_admin_tecnico'
);

Exec sp_executesql @limpieza;
GO

-- ? Permisos del personal de captura.
Grant Select On Object::dbo.tienda To rol_captura;
Grant Select On Object::dbo.producto To rol_captura;
Grant Select On Object::dbo.almacen To rol_captura;
Grant Select On Object::dbo.lote To rol_captura;
Grant Select On Object::dbo.inventario_lote To rol_captura;
Grant Select, Insert, Update On Object::dbo.pedido To rol_captura;
Grant Select, Insert, Update On Object::dbo.detalle_pedido To rol_captura;
Grant Select On Object::dbo.entrega To rol_captura;
Grant Select On Object::dbo.detalle_entrega To rol_captura;
Grant Select On Object::dbo.incidencia To rol_captura;
GO

-- ? Permisos del personal de almacen.
Grant Select On Object::dbo.tienda To rol_almacen;
Grant Select On Object::dbo.producto To rol_almacen;
Grant Select On Object::dbo.almacen To rol_almacen;
Grant Select, Insert On Object::dbo.lote To rol_almacen;
Grant Select On Object::dbo.inventario_lote To rol_almacen;
Grant Select On Object::dbo.pedido To rol_almacen;
Grant Select On Object::dbo.detalle_pedido To rol_almacen;
Grant Select, Insert, Update On Object::dbo.entrega To rol_almacen;
Grant Select, Insert, Update On Object::dbo.detalle_entrega To rol_almacen;
Grant Select, Insert On Object::dbo.incidencia To rol_almacen;
Grant Select, Insert On Object::dbo.movimiento_inventario To rol_almacen;
Grant Select, Insert On Object::dbo.conteo_inventario To rol_almacen;
Grant Select, Insert On Object::dbo.detalle_conteo To rol_almacen;
GO

-- ? Permisos del personal de reparto.
Grant Select On Object::dbo.tienda To rol_reparto;
Grant Select On Object::dbo.producto To rol_reparto;
Grant Select On Object::dbo.lote To rol_reparto;
Grant Select On Object::dbo.pedido To rol_reparto;
Grant Select On Object::dbo.detalle_pedido To rol_reparto;
Grant Select, Update On Object::dbo.entrega To rol_reparto;
Grant Select, Update On Object::dbo.detalle_entrega To rol_reparto;
Grant Select, Insert On Object::dbo.incidencia To rol_reparto;
GO

-- ? Permisos del personal de supervision.
Grant Select On Object::dbo.tienda To rol_supervision;
Grant Select, Insert, Update On Object::dbo.producto To rol_supervision;
Grant Select On Object::dbo.almacen To rol_supervision;
Grant Select, Update On Object::dbo.lote To rol_supervision;
Grant Select On Object::dbo.inventario_lote To rol_supervision;
Grant Select On Object::dbo.pedido To rol_supervision;
Grant Select On Object::dbo.detalle_pedido To rol_supervision;
Grant Select, Update On Object::dbo.entrega To rol_supervision;
Grant Select, Update On Object::dbo.detalle_entrega To rol_supervision;
Grant Select, Update On Object::dbo.incidencia To rol_supervision;
Grant Select, Insert On Object::dbo.movimiento_inventario To rol_supervision;
Grant Select, Update On Object::dbo.conteo_inventario To rol_supervision;
Grant Select, Update On Object::dbo.detalle_conteo To rol_supervision;
GO

-- ? Permisos del administrador tecnico.
-- ! Se asignan de forma explicita y no mediante db_owner.
Grant Select, Insert, Update On Object::dbo.tienda To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.producto To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.almacen To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.lote To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.inventario_lote To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.pedido To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.detalle_pedido To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.entrega To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.detalle_entrega To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.incidencia To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.movimiento_inventario To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.conteo_inventario To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.detalle_conteo To rol_admin_tecnico;
GO

-- ? Agregar cada usuario a su rol sin duplicar membresias.
If Is_RoleMember('rol_captura', 'usuario_captura') <> 1
  Alter Role rol_captura Add Member usuario_captura;

If Is_RoleMember('rol_almacen', 'usuario_almacen') <> 1
  Alter Role rol_almacen Add Member usuario_almacen;

If Is_RoleMember('rol_reparto', 'usuario_reparto') <> 1
  Alter Role rol_reparto Add Member usuario_reparto;

If Is_RoleMember('rol_supervision', 'usuario_supervision') <> 1
  Alter Role rol_supervision Add Member usuario_supervision;

If Is_RoleMember('rol_admin_tecnico', 'usuario_admin_tecnico') <> 1
  Alter Role rol_admin_tecnico Add Member usuario_admin_tecnico;
GO

-- ? Comprobar los permisos asignados a cada rol.
Select
  roles.name As rol,
  objetos.name As tabla,
  permisos.permission_name As permiso,
  permisos.state_desc As estado
From sys.database_permissions permisos
Inner Join sys.database_principals roles
  On permisos.grantee_principal_id = roles.principal_id
Inner Join sys.objects objetos
  On permisos.major_id = objetos.object_id
Where roles.name In
(
  'rol_captura',
  'rol_almacen',
  'rol_reparto',
  'rol_supervision',
  'rol_admin_tecnico'
)
Order By roles.name, objetos.name, permisos.permission_name;
GO

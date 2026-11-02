-- ? Punto 9. Auditoria.
-- ? Objetivo: registrar cambios de permisos y operaciones sobre datos importantes.
-- ! Requisito: ejecutar primero preparar_directorio_auditoria.sh en Ubuntu.
-- ! SQL Audit registra quien ejecuto una instruccion; el historial guarda valores anteriores y nuevos.

Use master;
GO

-- ? 9.1 Crear la auditoria del servidor.
Create Server Audit auditoria_pepsi
To File
(
  Filepath = '/var/opt/mssql/audit/proyecto_unidad_1/',
  Maxsize = 20 MB,
  Max_Rollover_Files = 5,
  Reserve_Disk_Space = Off
)
With
(
  Queue_Delay = 1000,
  On_Failure = Continue
);

Alter Server Audit auditoria_pepsi
With (State = On);
GO

-- ? 9.2 Auditar cambios de permisos realizados en el servidor.
Create Server Audit Specification especificacion_servidor_pepsi
For Server Audit auditoria_pepsi
  Add (Server_Permission_Change_Group)
With (State = On);
GO

Use pepsi_distribucion;
GO

-- ? 9.3 Auditar cambios de permisos y operaciones importantes de la base.
Create Database Audit Specification especificacion_bd_pepsi
For Server Audit auditoria_pepsi
  Add (Database_Object_Permission_Change_Group),
  Add (Insert On Object::dbo.pedido By public),
  Add (Update On Object::dbo.pedido By public),
  Add (Delete On Object::dbo.pedido By public),
  Add (Insert On Object::dbo.inventario_lote By public),
  Add (Update On Object::dbo.inventario_lote By public),
  Add (Delete On Object::dbo.inventario_lote By public),
  Add (Insert On Object::dbo.incidencia By public),
  Add (Update On Object::dbo.incidencia By public),
  Add (Delete On Object::dbo.incidencia By public)
With (State = On);
GO

-- ? 9.4 Crear un historial para conservar cantidades anteriores y nuevas.
Create Table dbo.historial_inventario
(
  id_historial bigint Primary Key Identity(1, 1),
  id_inventario int Not Null,
  cantidad_anterior int Not Null,
  cantidad_nueva int Not Null,
  usuario sysname Not Null,
  equipo sysname Null,
  fecha datetime2 Not Null Default Sysdatetime()
) On SECUNDARIO;
GO

Create Trigger dbo.tr_historial_inventario
On dbo.inventario_lote
After Update
As
Begin
  Set Nocount On;

  Insert Into dbo.historial_inventario
    (id_inventario, cantidad_anterior, cantidad_nueva, usuario, equipo)
  Select
    anterior.id_inventario,
    anterior.cantidad,
    nuevo.cantidad,
    Original_Login(),
    Host_Name()
  From deleted anterior
  Inner Join inserted nuevo
    On anterior.id_inventario = nuevo.id_inventario
  Where anterior.cantidad <> nuevo.cantidad;
End;
GO

-- ? 9.5 Generar eventos controlados para comprobar la auditoria.
Declare @inventario int =
  (Select Top 1 id_inventario From dbo.inventario_lote Order By id_inventario);

Update dbo.inventario_lote
Set cantidad = cantidad + 1,
    fecha_actualizacion = Sysdatetime()
Where id_inventario = @inventario;

Update dbo.inventario_lote
Set cantidad = cantidad - 1,
    fecha_actualizacion = Sysdatetime()
Where id_inventario = @inventario;

Grant Select On Object::dbo.historial_inventario To rol_supervision;
Revoke Select On Object::dbo.historial_inventario From rol_supervision;
GO

-- ? 9.6 Ver los valores anteriores y nuevos registrados por el trigger.
Select
  id_historial,
  id_inventario,
  cantidad_anterior,
  cantidad_nueva,
  usuario,
  equipo,
  fecha
From dbo.historial_inventario
Order By id_historial Desc;
GO

-- ? 9.7 Consultar las instrucciones guardadas por SQL Audit.
Use master;
GO

Waitfor Delay '00:00:02';

Select
  event_time,
  action_id,
  succeeded,
  session_server_principal_name,
  database_name,
  object_name,
  statement
From sys.fn_get_audit_file
(
  '/var/opt/mssql/audit/proyecto_unidad_1/*.sqlaudit',
  Default,
  Default
)
Where database_name = 'pepsi_distribucion'
Order By event_time Desc;

-- * Evidencia: capturar la auditoria habilitada, el historial y el archivo de auditoria.

-- ? Carlos Gabriel Rodriguez Macias
-- * Edith Dulce Athala Gomez
-- ? Actividad 5 - Auditorías

-- ! Primero ejecutar el archivo preparar_directorio_auditorias.sh
-- ! Este archivo se debe ejecutar por secciones.

Use master;

-- ? Ver la versión y edición de SQL Server.
Select
  @@VERSION As version_sql_server,
  ServerProperty('Edition') As edicion;

-- ? Ver las bases de datos disponibles.
Select name, state_desc
From sys.databases
Order By name;

-- ! SQL Profiler se reemplaza por eventos extendidos en Ubuntu.
-- ? Crear la sesión que guardará los eventos en un archivo XEL.
Create Event Session actividad_5_profiler
On Server
Add Event sqlserver.sql_batch_completed
(
  Action
  (
    sqlserver.client_app_name,
    sqlserver.client_hostname,
    sqlserver.database_name,
    sqlserver.server_principal_name,
    sqlserver.sql_text
  )
),
Add Event sqlserver.rpc_completed
(
  Action
  (
    sqlserver.client_app_name,
    sqlserver.client_hostname,
    sqlserver.database_name,
    sqlserver.server_principal_name,
    sqlserver.sql_text
  )
)
Add Target package0.event_file
(
  Set Filename = N'/var/opt/mssql/audit/actividad_5/actividad_5_profiler.xel',
      Max_File_Size = (10),
      Max_Rollover_Files = (2)
);

-- ? Ver la sesión creada.
Select name, event_retention_mode_desc, startup_state
From sys.server_event_sessions
Where name = 'actividad_5_profiler';

-- ? Iniciar la sesión.
Alter Event Session actividad_5_profiler
On Server
State = Start;

-- ? Ejecutar una consulta para generar eventos.
Use hospital_sql;

Select name
From sys.tables;

-- ? Detener la sesión para guardar los eventos.
Use master;

Alter Event Session actividad_5_profiler
On Server
State = Stop;

-- ? Consultar los eventos guardados en el archivo XEL.
With eventos As
(
  Select Cast(event_data As xml) As evento
  From sys.fn_xe_file_target_read_file
  (
    '/var/opt/mssql/audit/actividad_5/actividad_5_profiler*.xel',
    Null,
    Null,
    Null
  )
)
Select
  evento.value('(event/@timestamp)[1]', 'datetime2') As fecha,
  evento.value('(event/@name)[1]', 'varchar(100)') As evento,
  evento.value('(event/action[@name="database_name"]/value)[1]', 'varchar(100)') As base_datos,
  evento.value('(event/action[@name="server_principal_name"]/value)[1]', 'varchar(100)') As usuario,
  evento.value('(event/action[@name="sql_text"]/value)[1]', 'varchar(max)') As instruccion
From eventos
Order By fecha Desc;

-- ! Configurar C2.
-- ? Primero consultar su estado actual.
Use master;

Select name, value, value_in_use, is_dynamic
From sys.configurations
Where name = 'c2 audit mode';

-- ? Habilitar las opciones avanzadas y el seguimiento C2.
Exec sp_configure 'show advanced options', 1;
Reconfigure;

Exec sp_configure 'c2 audit mode', 1;
Reconfigure;

-- ! Después de este paso ejecutar reiniciar_sql_server.sh.
-- ? Después del reinicio, comprobar el estado de C2.
Select name, value, value_in_use, is_dynamic
From sys.configurations
Where name = 'c2 audit mode';

Select id, status, path, start_time
From sys.traces
Where is_default = 0;

-- ! Auditoría del servidor.
-- ? Crear la auditoría y guardar los archivos en la carpeta de Ubuntu.
Create Server Audit auditoria_actividad_5
To File
(
  Filepath = '/var/opt/mssql/audit/actividad_5/',
  Maxsize = 10 MB,
  Max_Rollover_Files = 5,
  Reserve_Disk_Space = Off
)
With
(
  Queue_Delay = 1000,
  On_Failure = Continue
);

-- ? Habilitar la auditoría.
Alter Server Audit auditoria_actividad_5
With (State = On);

-- ? Crear la especificación con las acciones indicadas por la profesora.
Create Server Audit Specification especificacion_servidor_actividad_5
For Server Audit auditoria_actividad_5
  Add (Transaction_Commit_Group),
  Add (User_Change_Password_Group),
  Add (Backup_Restore_Group),
  Add (Failed_Login_Group)
With (State = Off);

-- ? Habilitar la especificación del servidor.
Alter Server Audit Specification especificacion_servidor_actividad_5
With (State = On);

-- ? Ver la auditoría creada.
Select
  name,
  type_desc,
  on_failure_desc,
  is_state_enabled
From sys.server_audits
Where name = 'auditoria_actividad_5';

-- ? Ver las acciones de la especificación.
Select
  especificacion.name,
  detalle.audit_action_name,
  detalle.audited_result
From sys.server_audit_specifications especificacion
Inner Join sys.server_audit_specification_details detalle
  On especificacion.server_specification_id = detalle.server_specification_id
Where especificacion.name = 'especificacion_servidor_actividad_5';

-- ? Revisar si el servidor puede registrar los commits de transacciones.
Select name, value, value_in_use
From sys.configurations
Where name = 'common criteria compliance enabled';

-- ! Si value_in_use es 0, el grupo queda configurado,
-- ! pero el commit puede no aparecer en el archivo de auditoría.

-- ? Generar un evento de transacción.
Use hospital_sql;

Begin Transaction;
Select name From sys.tables;
Commit Transaction;

-- ? Generar un evento de respaldo.
Backup Database hospital_sql
To Disk = '/media/carlos-rodriguez/nvme0n1p1/2db/data/hospital_auditoria_actividad_5.bak'
With Init, Format,
Name = 'Respaldo para auditoria',
Description = 'Prueba de la actividad 5';

-- ! Para generar FAILED_LOGIN_GROUP ejecutar prueba_login_fallido.sh.

-- ? Consultar los registros de la auditoría del servidor.
Use master;

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
  '/var/opt/mssql/audit/actividad_5/*.sqlaudit',
  Default,
  Default
)
Order By event_time Desc;

-- ! Auditar una sola base de datos.
-- ? Crear una tabla sencilla para realizar las pruebas.
Use hospital_sql;

Create Table dbo.tbl_auditoria_prueba
(
  id_registro int Primary Key Identity(1, 1),
  descripcion varchar(100) Not Null,
  fecha datetime Not Null Default Getdate()
);

-- ? Crear la especificación de auditoría para INSERT, UPDATE y DELETE.
Create Database Audit Specification especificacion_bd_actividad_5
For Server Audit auditoria_actividad_5
  Add (Insert On Object::dbo.tbl_auditoria_prueba By public),
  Add (Update On Object::dbo.tbl_auditoria_prueba By public),
  Add (Delete On Object::dbo.tbl_auditoria_prueba By public)
With (State = Off);

-- ? Habilitar la especificación de la base de datos.
Alter Database Audit Specification especificacion_bd_actividad_5
With (State = On);

-- ? Ver las acciones configuradas para la base de datos.
Select
  especificacion.name,
  detalle.audit_action_name,
  Object_Name(detalle.major_id) As objeto,
  User_Name(detalle.audited_principal_id) As usuario
From sys.database_audit_specifications especificacion
Inner Join sys.database_audit_specification_details detalle
  On especificacion.database_specification_id = detalle.database_specification_id
Where especificacion.name = 'especificacion_bd_actividad_5';

-- ? Ejecutar las operaciones que se van a auditar.
Insert Into dbo.tbl_auditoria_prueba (descripcion)
Values ('Registro de prueba');

Update dbo.tbl_auditoria_prueba
Set descripcion = 'Registro actualizado'
Where id_registro = 1;

Delete From dbo.tbl_auditoria_prueba
Where id_registro = 1;

-- ? Consultar únicamente los registros de la tabla auditada.
Use master;

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
  '/var/opt/mssql/audit/actividad_5/*.sqlaudit',
  Default,
  Default
)
Where database_name = 'hospital_sql'
  And object_name = 'tbl_auditoria_prueba'
Order By event_time Desc;

-- ! Eventos extendidos personalizados.
-- ? Revisar que los eventos utilizados se encuentran disponibles.
Use master;

Select name, description
From sys.dm_xe_objects
Where object_type = 'event'
  And name In
  (
    'sql_transaction',
    'database_stopped',
    'alter_table_update_data',
    'object_deleted'
  )
Order By name;

-- ? Crear la sesión personalizada para hospital_sql.
Create Event Session auditar_hospital_sql
On Server
Add Event sqlserver.sql_transaction
(
  Action
  (
    sqlserver.database_name,
    sqlserver.session_id,
    sqlserver.server_principal_name,
    sqlserver.sql_text
  )
),
Add Event sqlserver.database_stopped
(
  Action
  (
    sqlserver.database_name,
    sqlserver.session_id,
    sqlserver.server_principal_name,
    sqlserver.sql_text
  )
),
Add Event sqlserver.alter_table_update_data
(
  Action
  (
    sqlserver.database_name,
    sqlserver.session_id,
    sqlserver.server_principal_name,
    sqlserver.sql_text
  )
),
Add Event sqlserver.object_deleted
(
  Action
  (
    sqlserver.database_name,
    sqlserver.session_id,
    sqlserver.server_principal_name,
    sqlserver.sql_text
  )
)
Add Target package0.event_file
(
  Set Filename = N'/var/opt/mssql/audit/actividad_5/auditar_hospital_sql.xel',
      Max_File_Size = (10),
      Max_Rollover_Files = (2)
);

-- ? Iniciar la sesión personalizada.
Alter Event Session auditar_hospital_sql
On Server
State = Start;

-- ? Generar eventos sin modificar las tablas principales del hospital.
Use hospital_sql;

Create Table dbo.tbl_evento_prueba
(
  id_registro int Primary Key
);

Insert Into dbo.tbl_evento_prueba (id_registro)
Values (1);

Alter Table dbo.tbl_evento_prueba
Add activo bit Not Null Default 1 With Values;

Begin Transaction;
Update dbo.tbl_evento_prueba
Set activo = 0
Where id_registro = 1;
Commit Transaction;

Drop Table dbo.tbl_evento_prueba;

-- ? Detener la sesión y consultar los eventos capturados.
Use master;

Alter Event Session auditar_hospital_sql
On Server
State = Stop;

With eventos As
(
  Select Cast(event_data As xml) As evento
  From sys.fn_xe_file_target_read_file
  (
    '/var/opt/mssql/audit/actividad_5/auditar_hospital_sql*.xel',
    Null,
    Null,
    Null
  )
)
Select
  evento.value('(event/@timestamp)[1]', 'datetime2') As fecha,
  evento.value('(event/@name)[1]', 'varchar(100)') As evento,
  evento.value('(event/action[@name="database_name"]/value)[1]', 'varchar(100)') As base_datos,
  evento.value('(event/action[@name="server_principal_name"]/value)[1]', 'varchar(100)') As usuario,
  evento.value('(event/action[@name="sql_text"]/value)[1]', 'varchar(max)') As instruccion
From eventos
Order By fecha Desc;

-- ! Eventos extendidos equivalentes a la plantilla TSQL.
-- ? Crear la sesión con los eventos mostrados en la plantilla.
Create Event Session hospital_sql_plantilla
On Server
Add Event sqlserver.existing_connection
(
  Action
  (
    sqlserver.database_name,
    sqlserver.session_id,
    sqlserver.server_principal_name,
    sqlserver.sql_text
  )
),
Add Event sqlserver.login
(
  Action
  (
    sqlserver.database_name,
    sqlserver.session_id,
    sqlserver.server_principal_name,
    sqlserver.sql_text
  )
),
Add Event sqlserver.logout
(
  Action
  (
    sqlserver.database_name,
    sqlserver.session_id,
    sqlserver.server_principal_name,
    sqlserver.sql_text
  )
),
Add Event sqlserver.rpc_starting
(
  Action
  (
    sqlserver.database_name,
    sqlserver.session_id,
    sqlserver.server_principal_name,
    sqlserver.sql_text
  )
),
Add Event sqlserver.sql_batch_starting
(
  Action
  (
    sqlserver.database_name,
    sqlserver.session_id,
    sqlserver.server_principal_name,
    sqlserver.sql_text
  )
)
Add Target package0.event_file
(
  Set Filename = N'/var/opt/mssql/audit/actividad_5/hospital_sql_plantilla.xel',
      Max_File_Size = (10),
      Max_Rollover_Files = (2)
);

-- ? Iniciar la sesión equivalente a la plantilla.
Alter Event Session hospital_sql_plantilla
On Server
State = Start;

-- ? Ejecutar una consulta para generar eventos TSQL.
Use hospital_sql;

Select name
From sys.tables;

-- ? Detener la sesión y consultar el archivo XEL.
Use master;

Alter Event Session hospital_sql_plantilla
On Server
State = Stop;

With eventos_plantilla As
(
  Select Cast(event_data As xml) As evento
  From sys.fn_xe_file_target_read_file
  (
    '/var/opt/mssql/audit/actividad_5/hospital_sql_plantilla*.xel',
    Null,
    Null,
    Null
  )
)
Select
  evento.value('(event/@timestamp)[1]', 'datetime2') As fecha,
  evento.value('(event/@name)[1]', 'varchar(100)') As evento,
  evento.value('(event/action[@name="database_name"]/value)[1]', 'varchar(100)') As base_datos,
  evento.value('(event/action[@name="server_principal_name"]/value)[1]', 'varchar(100)') As usuario,
  evento.value('(event/action[@name="sql_text"]/value)[1]', 'varchar(max)') As instruccion
From eventos_plantilla
Order By fecha Desc;

-- ! C2 puede generar muchos archivos.
-- ! Cuando terminen las evidencias ejecutar deshabilitar_c2.sql.

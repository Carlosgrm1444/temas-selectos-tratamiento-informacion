-- ? Punto 10. Eventos extendidos.
-- ? Objetivo: observar instrucciones terminadas y errores de pepsi_distribucion.
-- ! Requisito: preparar primero el directorio de auditoria de Ubuntu.

Use master;
GO

-- ? 10.1 Crear una sesion equivalente al seguimiento de actividad en SSMS.
Create Event Session eventos_pepsi
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
  Where ([sqlserver].[database_name] = N'pepsi_distribucion')
),
Add Event sqlserver.error_reported
(
  Action
  (
    sqlserver.client_app_name,
    sqlserver.client_hostname,
    sqlserver.database_name,
    sqlserver.server_principal_name,
    sqlserver.sql_text
  )
  Where ([severity] >= 11)
)
Add Target package0.event_file
(
  Set Filename = N'/var/opt/mssql/audit/proyecto_unidad_1/eventos_pepsi.xel',
      Max_File_Size = (10),
      Max_Rollover_Files = (3)
)
With (Startup_State = On);
GO

-- ? 10.2 Iniciar la sesion y generar eventos de prueba.
Alter Event Session eventos_pepsi
On Server
State = Start;
GO

Use pepsi_distribucion;
GO

Select folio, estado
From dbo.pedido
Where estado In ('PENDIENTE', 'PARCIAL');

Begin Try
  Select 1 / 0 As error_controlado;
End Try
Begin Catch
  Select Error_Message() As error_generado;
End Catch;
GO

-- ? 10.3 Detener la sesion y consultar el archivo XEL.
Use master;
GO

Alter Event Session eventos_pepsi
On Server
State = Stop;
GO

With eventos As
(
  Select Cast(event_data As xml) As evento
  From sys.fn_xe_file_target_read_file
  (
    '/var/opt/mssql/audit/proyecto_unidad_1/eventos_pepsi*.xel',
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

Select name, startup_state
From sys.server_event_sessions
Where name = 'eventos_pepsi';

-- * Evidencia: capturar la sesion creada y los eventos leidos del archivo XEL.

-- ? Punto 8. Plan de mantenimiento.
-- ? Objetivo: revisar respaldos, espacio, integridad, estadisticas e indices.
-- ! Requisito: SQL Server Agent debe estar activo para crear las programaciones.
-- ! La configuracion del servicio en Ubuntu se realiza fuera de T-SQL.

Use master;
GO

-- ? 8.1 Verificar que SQL Server Agent se encuentra habilitado.
Select name, value, value_in_use
From sys.configurations
Where name = 'Agent XPs';

Select servicename, startup_type_desc, status_desc
From sys.dm_server_services;
GO

-- ? 8.2 Revisar los respaldos recientes y el espacio disponible.
Select Top 20
  database_name,
  Case type
    When 'D' Then 'FULL'
    When 'I' Then 'DIFFERENTIAL'
    When 'L' Then 'LOG'
  End As tipo_respaldo,
  backup_finish_date
From msdb.dbo.backupset
Where database_name = 'pepsi_distribucion'
Order By backup_finish_date Desc;

Select Distinct
  volumen.volume_mount_point,
  Convert(decimal(10, 2), volumen.total_bytes / 1073741824.0) As total_gb,
  Convert(decimal(10, 2), volumen.available_bytes / 1073741824.0) As disponible_gb
From sys.master_files archivo
Cross Apply sys.dm_os_volume_stats(archivo.database_id, archivo.file_id) volumen
Where archivo.database_id = DB_ID('pepsi_distribucion');
GO

-- ? 8.3 Comprobar integridad y actualizar estadisticas.
DBCC CHECKDB ('pepsi_distribucion') With No_Infomsgs;

Use pepsi_distribucion;
GO

Exec sp_updatestats;
GO

-- ? 8.4 Crear el procedimiento que da mantenimiento a los indices.
Create Procedure dbo.mantenimiento_indices
As
Begin
  Set Nocount On;

  Declare @esquema sysname;
  Declare @tabla sysname;
  Declare @indice sysname;
  Declare @fragmentacion decimal(10, 2);
  Declare @comando nvarchar(max);

  Declare indices Cursor Local Fast_Forward For
  Select
    Object_Schema_Name(estadistica.object_id),
    Object_Name(estadistica.object_id),
    indice.name,
    estadistica.avg_fragmentation_in_percent
  From sys.dm_db_index_physical_stats
    (DB_ID(), Null, Null, Null, 'LIMITED') estadistica
  Inner Join sys.indexes indice
    On estadistica.object_id = indice.object_id
    And estadistica.index_id = indice.index_id
  Where estadistica.index_id > 0
    And indice.name Is Not Null
    And estadistica.page_count >= 8
    And estadistica.avg_fragmentation_in_percent >= 5;

  Open indices;
  Fetch Next From indices
  Into @esquema, @tabla, @indice, @fragmentacion;

  While @@FETCH_STATUS = 0
  Begin
    If @fragmentacion >= 30
      Set @comando = N'Alter Index ' + Quotename(@indice) +
        N' On ' + Quotename(@esquema) + N'.' + Quotename(@tabla) +
        N' Rebuild;';
    Else
      Set @comando = N'Alter Index ' + Quotename(@indice) +
        N' On ' + Quotename(@esquema) + N'.' + Quotename(@tabla) +
        N' Reorganize;';

    Exec sp_executesql @comando;

    Fetch Next From indices
    Into @esquema, @tabla, @indice, @fragmentacion;
  End;

  Close indices;
  Deallocate indices;
End;
GO

-- ? 8.5 Ejecutar una prueba manual del mantenimiento de indices.
Exec dbo.mantenimiento_indices;
GO

-- ? 8.6 Programar las revisiones en SQL Server Agent.
Use msdb;
GO

Exec dbo.sp_add_job
  @job_name = 'pepsi_revision_diaria',
  @enabled = 1,
  @description = 'Revisa respaldos recientes y espacio disponible';

Exec dbo.sp_add_jobstep
  @job_name = 'pepsi_revision_diaria',
  @step_name = 'Revisar respaldo y espacio',
  @subsystem = 'TSQL',
  @database_name = 'master',
  @command = N'
If Not Exists
(
  Select 1 From msdb.dbo.backupset
  Where database_name = ''pepsi_distribucion''
    And backup_finish_date >= Dateadd(day, -1, Getdate())
)
  Throw 50020, ''No existe un respaldo reciente.'', 1;

Select Distinct
  volumen.volume_mount_point,
  volumen.available_bytes / 1073741824.0 As disponible_gb
From sys.master_files archivo
Cross Apply sys.dm_os_volume_stats(archivo.database_id, archivo.file_id) volumen
Where archivo.database_id = DB_ID(''pepsi_distribucion'');';

Exec dbo.sp_add_jobschedule
  @job_name = 'pepsi_revision_diaria',
  @name = 'pepsi_revision_diaria_0030',
  @freq_type = 4,
  @freq_interval = 1,
  @active_start_time = 003000;

Exec dbo.sp_add_jobserver
  @job_name = 'pepsi_revision_diaria';
GO

Exec dbo.sp_add_job
  @job_name = 'pepsi_integridad_estadisticas',
  @enabled = 1,
  @description = 'Comprueba integridad y actualiza estadisticas cada domingo';

Exec dbo.sp_add_jobstep
  @job_name = 'pepsi_integridad_estadisticas',
  @step_name = 'CHECKDB y estadisticas',
  @subsystem = 'TSQL',
  @database_name = 'pepsi_distribucion',
  @command = N'
DBCC CHECKDB (''pepsi_distribucion'') With No_Infomsgs;
Exec sp_updatestats;';

Exec dbo.sp_add_jobschedule
  @job_name = 'pepsi_integridad_estadisticas',
  @name = 'pepsi_integridad_domingo_0200',
  @freq_type = 8,
  @freq_interval = 1,
  @freq_recurrence_factor = 1,
  @active_start_time = 020000;

Exec dbo.sp_add_jobserver
  @job_name = 'pepsi_integridad_estadisticas';
GO

Exec dbo.sp_add_job
  @job_name = 'pepsi_mantenimiento_indices',
  @enabled = 1,
  @description = 'Reorganiza o reconstruye indices cada domingo';

Exec dbo.sp_add_jobstep
  @job_name = 'pepsi_mantenimiento_indices',
  @step_name = 'Mantenimiento de indices',
  @subsystem = 'TSQL',
  @database_name = 'pepsi_distribucion',
  @command = N'Exec dbo.mantenimiento_indices;';

Exec dbo.sp_add_jobschedule
  @job_name = 'pepsi_mantenimiento_indices',
  @name = 'pepsi_indices_domingo_0400',
  @freq_type = 8,
  @freq_interval = 1,
  @freq_recurrence_factor = 1,
  @active_start_time = 040000;

Exec dbo.sp_add_jobserver
  @job_name = 'pepsi_mantenimiento_indices';
GO

-- ? 8.7 Verificar los trabajos de mantenimiento.
Select
  trabajo.name As trabajo,
  horario.name As horario,
  trabajo.enabled,
  horario.active_start_time
From dbo.sysjobs trabajo
Inner Join dbo.sysjobschedules relacion
  On trabajo.job_id = relacion.job_id
Inner Join dbo.sysschedules horario
  On relacion.schedule_id = horario.schedule_id
Where trabajo.name Like 'pepsi_%'
Order By trabajo.name;

-- * Evidencia: capturar Agent activo, CHECKDB sin errores y los trabajos creados.

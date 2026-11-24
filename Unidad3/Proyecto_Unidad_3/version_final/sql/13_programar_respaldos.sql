-- ? Carlos Gabriel Rodríguez Macías
-- ! Juan Manuel Ortega García
-- * Bernardo Guillermo Núñez López
-- ? Proyecto Unidad 3 - Programacion propuesta de respaldos
-- ! Requiere SQL Server Agent y la base en modelo Full con un respaldo inicial.
-- * SQL Server Express no tiene Agent. Las pruebas locales usaron Developer.
-- * Los trabajos se crean deshabilitados para revisar primero las rutas.
-- * En produccion la carpeta de respaldos debe estar en otro volumen.

Use msdb;
GO

-- ? Respaldo full diario a la 01:00.
Exec sp_add_job @job_name = 'pepsi_full', @enabled = 0;
Exec sp_add_jobstep
  @job_name = 'pepsi_full', @step_name = 'Respaldo full',
  @subsystem = 'TSQL', @database_name = 'master',
  @command = N'Declare @ruta nvarchar(260);
    Set @ruta = N''/var/opt/mssql/data/pepsi_full_''
      + Convert(varchar(8), Getdate(), 112) + ''.bak'';
    Backup Database pepsi_distribucion To Disk = @ruta With Checksum;';
Exec sp_add_jobschedule
  @job_name = 'pepsi_full', @name = 'pepsi_full_diario',
  @freq_type = 4, @freq_interval = 1, @active_start_time = 010000;
Exec sp_add_jobserver @job_name = 'pepsi_full';
GO

-- ? Respaldo diferencial a las 07:00, 13:00 y 19:00.
Exec sp_add_job @job_name = 'pepsi_differential', @enabled = 0;
Exec sp_add_jobstep
  @job_name = 'pepsi_differential', @step_name = 'Respaldo differential',
  @subsystem = 'TSQL', @database_name = 'master',
  @command = N'Declare @ruta nvarchar(260);
    Set @ruta = N''/var/opt/mssql/data/pepsi_diff_''
      + Convert(varchar(8), Getdate(), 112) + ''_''
      + Replace(Convert(varchar(8), Getdate(), 108), '':'', '''') + ''.bak'';
    Backup Database pepsi_distribucion To Disk = @ruta With Differential, Checksum;';
Exec sp_add_jobschedule
  @job_name = 'pepsi_differential', @name = 'pepsi_diff_cada_6_horas',
  @freq_type = 4, @freq_interval = 1,
  @freq_subday_type = 8, @freq_subday_interval = 6,
  @active_start_time = 070000, @active_end_time = 235959;
Exec sp_add_jobserver @job_name = 'pepsi_differential';
GO

-- ? Respaldo del log cada 15 minutos.
Exec sp_add_job @job_name = 'pepsi_log', @enabled = 0;
Exec sp_add_jobstep
  @job_name = 'pepsi_log', @step_name = 'Respaldo log',
  @subsystem = 'TSQL', @database_name = 'master',
  @command = N'Declare @ruta nvarchar(260);
    Set @ruta = N''/var/opt/mssql/data/pepsi_log_''
      + Convert(varchar(8), Getdate(), 112) + ''_''
      + Replace(Convert(varchar(8), Getdate(), 108), '':'', '''') + ''.trn'';
    Backup Log pepsi_distribucion To Disk = @ruta With Checksum;';
Exec sp_add_jobschedule
  @job_name = 'pepsi_log', @name = 'pepsi_log_cada_15_minutos',
  @freq_type = 4, @freq_interval = 1,
  @freq_subday_type = 4, @freq_subday_interval = 15,
  @active_start_time = 000000, @active_end_time = 235959;
Exec sp_add_jobserver @job_name = 'pepsi_log';
GO

-- ? Consultar los trabajos y horarios de respaldo.
Select j.name, j.enabled, s.name As horario,
  s.freq_subday_interval, s.active_start_time
From dbo.sysjobs j
Inner Join dbo.sysjobschedules js On j.job_id = js.job_id
Inner Join dbo.sysschedules s On js.schedule_id = s.schedule_id
Where j.name In ('pepsi_full', 'pepsi_differential', 'pepsi_log');
GO

-- ? Punto 6. Estrategia de respaldos.
-- ? Objetivo: crear respaldos full, diferencial y de log con sus programaciones.
-- ! Requisito: ejecutar los puntos anteriores y tener SQL Server Agent activo.
-- ! Las rutas se deben adaptar si el proyecto se mueve a otro equipo.

Use master;
GO

-- ? 6.1 Usar el modelo FULL para conservar la cadena del log.
Alter Database pepsi_distribucion
Set Recovery Full;
GO

-- ? 6.2 Crear una muestra de cada tipo de respaldo.
-- ! No se usa INIT ni FORMAT para no sobrescribir respaldos anteriores.
Backup Database pepsi_distribucion
To Disk = '/media/carlos-rodriguez/nvme0n1p1/2db/data/pepsi_distribucion_demo_full.bak'
With Checksum, Compression, Stats = 10,
Name = 'Respaldo full de pepsi_distribucion';
GO

Backup Database pepsi_distribucion
To Disk = '/media/carlos-rodriguez/nvme0n1p1/2db/data/pepsi_distribucion_demo_differential.bak'
With Differential, Checksum, Compression, Stats = 10,
Name = 'Respaldo diferencial de pepsi_distribucion';
GO

Backup Log pepsi_distribucion
To Disk = '/media/carlos-rodriguez/nvme0n1p1/2db/data/pepsi_distribucion_demo_log_01.trn'
With Checksum, Compression, Stats = 10,
Name = 'Respaldo log 01 de pepsi_distribucion';
GO

-- ? Crear un segundo respaldo para demostrar la cadena continua del log.
Backup Log pepsi_distribucion
To Disk = '/media/carlos-rodriguez/nvme0n1p1/2db/data/pepsi_distribucion_demo_log_02.trn'
With Checksum, Compression, Stats = 10,
Name = 'Respaldo log 02 de pepsi_distribucion';
GO

-- ? 6.3 Crear el trabajo del respaldo full diario a la 01:00.
Use msdb;
GO

Exec dbo.sp_add_job
  @job_name = 'pepsi_respaldo_full',
  @enabled = 1,
  @description = 'Respaldo full diario de pepsi_distribucion';

Exec dbo.sp_add_jobstep
  @job_name = 'pepsi_respaldo_full',
  @step_name = 'Respaldo full',
  @subsystem = 'TSQL',
  @database_name = 'master',
  @command = N'
Declare @archivo nvarchar(500) =
  N''/media/carlos-rodriguez/nvme0n1p1/2db/data/pepsi_full_'' +
  Convert(char(8), Getdate(), 112) + N''_'' +
  Replace(Convert(char(8), Getdate(), 108), '':'', '''') + N''.bak'';
Backup Database pepsi_distribucion
To Disk = @archivo
With Checksum, Compression, Name = ''Respaldo full programado'';';

Declare @fecha_inicio int = Convert(int, Convert(char(8), Getdate(), 112));

Exec dbo.sp_add_jobschedule
  @job_name = 'pepsi_respaldo_full',
  @name = 'pepsi_full_diario_0100',
  @freq_type = 4,
  @freq_interval = 1,
  @active_start_date = @fecha_inicio,
  @active_start_time = 010000;

Exec dbo.sp_add_jobserver
  @job_name = 'pepsi_respaldo_full';
GO

-- ? 6.4 Crear el diferencial diario a las 07:00, 13:00 y 19:00.
Exec dbo.sp_add_job
  @job_name = 'pepsi_respaldo_differential',
  @enabled = 1,
  @description = 'Respaldo diferencial tres veces al dia';

Exec dbo.sp_add_jobstep
  @job_name = 'pepsi_respaldo_differential',
  @step_name = 'Respaldo diferencial',
  @subsystem = 'TSQL',
  @database_name = 'master',
  @command = N'
Declare @archivo nvarchar(500) =
  N''/media/carlos-rodriguez/nvme0n1p1/2db/data/pepsi_differential_'' +
  Convert(char(8), Getdate(), 112) + N''_'' +
  Replace(Convert(char(8), Getdate(), 108), '':'', '''') + N''.bak'';
Backup Database pepsi_distribucion
To Disk = @archivo
With Differential, Checksum, Compression,
Name = ''Respaldo diferencial programado'';';

Declare @fecha_diferencial int = Convert(int, Convert(char(8), Getdate(), 112));

Exec dbo.sp_add_jobschedule
  @job_name = 'pepsi_respaldo_differential',
  @name = 'pepsi_differential_0713_19',
  @freq_type = 4,
  @freq_interval = 1,
  @freq_subday_type = 8,
  @freq_subday_interval = 6,
  @active_start_date = @fecha_diferencial,
  @active_start_time = 070000,
  @active_end_time = 190000;

Exec dbo.sp_add_jobserver
  @job_name = 'pepsi_respaldo_differential';
GO

-- ? 6.5 Crear el respaldo del log cada 15 minutos.
Exec dbo.sp_add_job
  @job_name = 'pepsi_respaldo_log',
  @enabled = 1,
  @description = 'Respaldo del log cada 15 minutos';

Exec dbo.sp_add_jobstep
  @job_name = 'pepsi_respaldo_log',
  @step_name = 'Respaldo log',
  @subsystem = 'TSQL',
  @database_name = 'master',
  @command = N'
Declare @archivo nvarchar(500) =
  N''/media/carlos-rodriguez/nvme0n1p1/2db/data/pepsi_log_'' +
  Convert(char(8), Getdate(), 112) + N''_'' +
  Replace(Convert(char(8), Getdate(), 108), '':'', '''') + N''.trn'';
Backup Log pepsi_distribucion
To Disk = @archivo
With Checksum, Compression, Name = ''Respaldo log programado'';';

Declare @fecha_log int = Convert(int, Convert(char(8), Getdate(), 112));

Exec dbo.sp_add_jobschedule
  @job_name = 'pepsi_respaldo_log',
  @name = 'pepsi_log_cada_15_minutos',
  @freq_type = 4,
  @freq_interval = 1,
  @freq_subday_type = 4,
  @freq_subday_interval = 15,
  @active_start_date = @fecha_log,
  @active_start_time = 000000,
  @active_end_time = 235959;

Exec dbo.sp_add_jobserver
  @job_name = 'pepsi_respaldo_log';
GO

-- ? 6.6 Verificar respaldos y programaciones.
Select
  database_name,
  Case type
    When 'D' Then 'FULL'
    When 'I' Then 'DIFFERENTIAL'
    When 'L' Then 'LOG'
  End As tipo_respaldo,
  backup_start_date,
  backup_finish_date
From dbo.backupset
Where database_name = 'pepsi_distribucion'
Order By backup_finish_date Desc;

Select
  trabajo.name As trabajo,
  horario.name As horario,
  horario.enabled,
  horario.freq_type,
  horario.freq_interval,
  horario.freq_subday_type,
  horario.freq_subday_interval,
  horario.active_start_time,
  horario.active_end_time
From dbo.sysjobs trabajo
Inner Join dbo.sysjobschedules relacion
  On trabajo.job_id = relacion.job_id
Inner Join dbo.sysschedules horario
  On relacion.schedule_id = horario.schedule_id
Where trabajo.name Like 'pepsi_respaldo_%'
Order By trabajo.name;

-- * Con el respaldo del log cada 15 minutos, el RPO propuesto es de 15 minutos.
-- * Evidencia: capturar los tipos de respaldo, la cadena de log y las programaciones.

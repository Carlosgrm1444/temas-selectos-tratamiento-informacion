-- ? Carlos Gabriel Rodriguez Macias
-- * Edith Dulce Athala Gomez
-- ? Actividad 4 - Planes de Mantenimiento

-- ! Antes de ejecutar este archivo, iniciar SQL Server Agent con:
-- * ./Actividad_4_Planes_de_Mantenimiento/scripts/habilitar_sql_agent.sh

Use master;

-- ? Usar recuperación FULL para poder realizar el respaldo del log.
Alter Database hospital_sql
Set Recovery Full;

-- ? Respaldo full.
Backup Database hospital_sql
To Disk = '/media/carlos-rodriguez/nvme0n1p1/2db/data/hospial_codigo_full_0309.bak'
With Init, Format,
Name = 'Respaldo full hospital_sql',
Description = 'Respaldo full de la base hospital_sql';

-- ? Respaldo differential.
Backup Database hospital_sql
To Disk = '/media/carlos-rodriguez/nvme0n1p1/2db/data/hospial_codigo_differential_0309.bak'
With Differential,
Name = 'Respaldo differential hospital_sql',
Description = 'Respaldo differential de la base hospital_sql';

-- ? Respaldo log.
Backup Log hospital_sql
To Disk = '/media/carlos-rodriguez/nvme0n1p1/2db/data/hospial_codigo_log_0309.trn'
With Init, Format,
Name = 'Respaldo log hospital_sql',
Description = 'Respaldo log de la base hospital_sql';

-- ? Habilitar Agent XPs.
Exec sp_configure 'show advanced options', 1;
Reconfigure;

Exec sp_configure 'Agent XPs', 1;
Reconfigure;

Use msdb;

-- ? Crear el plan hospital_respaldo.
Exec sp_add_job
  @job_name = 'hospital_respaldo',
  @description = 'Respaldos full, differential y log de la base hospital_sql.';

-- ? Paso 1. Respaldo full.
Exec sp_add_jobstep
  @job_name = 'hospital_respaldo',
  @step_name = 'Respaldo full',
  @subsystem = 'TSQL',
  @command = N'
Backup Database hospital_sql
To Disk = ''/media/carlos-rodriguez/nvme0n1p1/2db/data/hospial_codigo_full_0309.bak''
With Init, Format,
Name = ''Respaldo full'',
Description = ''Respaldo completo de hospital_sql'';',
  @database_name = 'master',
  @on_success_action = 3;

-- ? Paso 2. Respaldo differential.
Exec sp_add_jobstep
  @job_name = 'hospital_respaldo',
  @step_name = 'Respaldo differential',
  @subsystem = 'TSQL',
  @command = N'
Backup Database hospital_sql
To Disk = ''/media/carlos-rodriguez/nvme0n1p1/2db/data/hospial_codigo_differential_0309.bak''
With Differential, Init, Format,
Name = ''Respaldo differential'',
Description = ''Respaldo differential de hospital_sql'';',
  @database_name = 'master',
  @on_success_action = 3;

-- ? Paso 3. Respaldo log.
Exec sp_add_jobstep
  @job_name = 'hospital_respaldo',
  @step_name = 'Respaldo log',
  @subsystem = 'TSQL',
  @command = N'
Backup Log hospital_sql
To Disk = ''/media/carlos-rodriguez/nvme0n1p1/2db/data/hospial_codigo_log_0309.trn''
With Init, Format,
Name = ''Respaldo log'',
Description = ''Respaldo del log de hospital_sql'';',
  @database_name = 'master';

-- ? Programar el plan: martes, jueves y viernes a las 08:00.
Exec sp_add_jobschedule
  @job_name = 'hospital_respaldo',
  @name = 'hospital_respaldo_mar_jue_vie',
  @freq_type = 8,
  @freq_interval = 52,
  @freq_recurrence_factor = 1,
  @active_start_time = 080000;

Exec sp_add_jobserver
  @job_name = 'hospital_respaldo';

-- ? Ejecutar el plan paso a paso.
Exec sp_start_job @job_name = 'hospital_respaldo';

-- ? Ver el historial del plan después de que termine.
Select * From sysjobhistory;

-- ! Plan de mantenimiento en un mismo archivo de respaldo.
-- ? El respaldo differential se crea y el respaldo log se agrega al mismo archivo.
Exec sp_add_job
  @job_name = 'hospital_mantenimiento',
  @description = 'Respaldo differential, log y reorganización de índices de hospital_sql.';

-- ? Paso 1. Respaldo differential en un mismo archivo.
Exec sp_add_jobstep
  @job_name = 'hospital_mantenimiento',
  @step_name = 'Respaldo differential',
  @subsystem = 'TSQL',
  @command = N'
Backup Database hospital_sql
To Disk = ''/media/carlos-rodriguez/nvme0n1p1/2db/data/hospial_codigo_mantenimiento_0309.bak''
With Differential, Init, Format,
Name = ''Respaldo differential de mantenimiento'',
Description = ''Respaldo differential de hospital_sql'';',
  @database_name = 'master',
  @on_success_action = 3;

-- ? Paso 2. Respaldo log en el mismo archivo.
Exec sp_add_jobstep
  @job_name = 'hospital_mantenimiento',
  @step_name = 'Respaldo log',
  @subsystem = 'TSQL',
  @command = N'
Backup Log hospital_sql
To Disk = ''/media/carlos-rodriguez/nvme0n1p1/2db/data/hospial_codigo_mantenimiento_0309.bak''
With NoInit,
Name = ''Respaldo log de mantenimiento'',
Description = ''Respaldo log de hospital_sql en el mismo archivo'';',
  @database_name = 'master',
  @on_success_action = 3;

-- ? Paso 3. Reorganizar los índices de las tablas de hospital_sql.
Exec sp_add_jobstep
  @job_name = 'hospital_mantenimiento',
  @step_name = 'Reorganizar índices',
  @subsystem = 'TSQL',
  @command = N'
Alter Index All On dbo.doctores Reorganize;
Alter Index All On dbo.especialidades Reorganize;
Alter Index All On dbo.rel_doctores_especialidades Reorganize;',
  @database_name = 'hospital_sql';

-- ? Programar el plan de mantenimiento: martes, jueves y viernes a las 08:00.
Exec sp_add_jobschedule
  @job_name = 'hospital_mantenimiento',
  @name = 'hospital_mantenimiento_mar_jue_vie',
  @freq_type = 8,
  @freq_interval = 52,
  @freq_recurrence_factor = 1,
  @active_start_time = 080000;

Exec sp_add_jobserver
  @job_name = 'hospital_mantenimiento';

-- ? Ver los planes creados.
Select name, enabled, description
From sysjobs
Where name In ('hospital_respaldo', 'hospital_mantenimiento');

-- ? Para ejecutar el nuevo plan, quitar los comentarios.
Exec sp_start_job @job_name = 'hospital_mantenimiento';



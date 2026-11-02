-- ? Carlos Gabriel Rodriguez Macias
-- * Edith Dulce Athala Gomez
-- ? Proyecto - 05/02/2026

exec msdb.dbo.sp_start_job @job_name='Backuo_romex_carlos';

use msdb;
exec sp_stop_job  @job_name='Backuo_romex_carlos';

exec sp_update_job  @job_name='Backuo_romex_carlos',
@new_name = 'Backup_romex_dulce',
@enabled =1,
@description = '',
@start_step_id = 1,
@owner_login_name = 'login';

exec sp_delete_job @job_name= 'Backup_romex_dulce';

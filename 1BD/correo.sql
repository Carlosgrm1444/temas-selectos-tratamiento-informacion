-- ? Carlos Gabriel Rodriguez Macias
-- * Edith Dulce Athala Gomez
-- ? Practica 7 -10/03/2026 

sp_configure 'show advanced', 1; 
reconfigure 
sp_configure 

Exec msdb.dbo.sp_send_dbmail
  @profile_name = 'AdministradorBD',
  @recipients = 'carlosgabrielrm1444@gmail.com',
  @body = 'Esta es una prueba de envio de correo sp_send_dbmail',
  @subject = 'Uso de sp_send_dbmail'

Select * From msdb.dbo.sysmail_event_log

zxmspttgmwifhhuy


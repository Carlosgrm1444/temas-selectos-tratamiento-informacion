-- ? Carlos Gabriel Rodriguez Macias
-- * Edith Dulce Athala Gomez
-- ? Practica 2 - 03/02/2026

Use agencia_aduanal;
-- ? 1.-Utilizando la BD escribe la consulta que nos permite saber si esta activo o no la propiedad 'ISAUTOSHRINK'
Alter Database agencia_aduanal
Set Auto_Shrink On;
-- ? 2.-Escribe la instrucción para alterar la BD con el fin de activar el AUTO_SHRINK
Alter Database agencia_aduanal
Set Auto_Shrink Off;
-- ? 3.-Escribe la instrucción (SP) que permite consultar información importante de la BD 
Exec sp_helpdb agencia_aduanal;
-- ? 4.-Escribe la instrucción que permite Destachar los archivos de la BD (recuerda antes usar la BD master)
Exec sp_detach_db 'agencia_aduanal';
-- ? 5.-Escribe la instrucción que permite Atachar la BD en la siguiente ubicación 'C:\data\   (recuerda indicar que se usará  la BD master)
Exec sp_attach_db 'agencia_aduanal', 
  'C:\data\agencia_aduanal.mdf',
  'C:\data\agencia_aduanal_log.ldf';
-- ? 6.-Utiliza el código para indicar que la BD solo es usada por un usuario
Alter Database agencia_aduanal
Set Single_User;
-- ? 7.-Investiga para que sirve una instantánea
-- * Una instantánea (snapshot) en SQL Server sirve para crear una copia de solo 
-- * lectura, estática y consistente transaccionalmente de una base de datos en un 
-- * momento específico. Se utiliza principalmente para informes operativos rápidos, 
-- * auditorías históricas, pruebas y como mecanismo de recuperación ante errores 
-- * humanos o actualizaciones fallidas.

-- ? 8.-Crea una instantánea con el nombre de agencia_dbss0226
Create Database agencia_dbss0226_carlos
On
(
  Name = agencia_aduanal_data,
  Filename = 'C:\7BD\agencia_aduanal_ss0226.ss'
)
,
(
  Name = agencia_aduanalSecundario,
  Filename = 'C:\7BD\agencia_aduanalSecundario_ss0226.ss'
)
As Snapshot Of agencia_aduanal;
-- ? 9.-Utiliza el código para indicar que la BD puede ser usada por múltiples usuarios
Use master;
Alter Database agencia_aduanal
Set Multi_User;
-- ? 10.-Inserta 1 registro en cada tabla
Insert Into clientes (aduana) VALUES ('Nuevo Laredo');
-- ? Carlos Gabriel Rodriguez Macias
-- * Edith Dulce Athala Gomez
-- ? Practica 5 - 17/02/2026

-- ? 1.Usa la base de datos que indique el docente ( indico NuevaLogistica)
Use NuevaLogistica;

-- ? 2.Realiza un backup completo
Backup Database NuevaLogistica To Disk = 'C:\7BD\NuevaLogistica.bak' 
With Format, Name = 'Backup Completo NuevaLogistica',
Description = 'Backup completo de la base de datos NuevaLogistica';

-- ? 3. Inserta 3 registros a una tabla
Insert Into Country (country, aduana)
Values ('Mexico', 1),
  ('Estados Unidos', 1),
  ('Canada', 1);

-- ? 4. Realiza un backup diferencial
Backup Database NuevaLogistica To Disk = 'C:\7BD\NuevaLogistica_Diferencial.bak'
With Format, Name = 'Backup Diferencial NuevaLogistica',
Description = 'Backup diferencial de la base de datos NuevaLogistica';

-- ? 5. Inserta 1 registro a una tabla
Insert Into Country (country, aduana)
Values ('Brasil', 1);

-- ? 6. Realiza el backup del log
Backup Log NuevaLogistica To Disk = 'C:\7BD\NuevaLogistica_Log.bak'
With Format, Name = 'Backup Log NuevaLogistica',
Description = 'Backup del log de la base de datos NuevaLogistica';

-- ? 7. Se elimina la BD
Use Master;
Drop Database NuevaLogistica;

-- ? 8. Se escribe el codigo de crear bd (como repaso pero no se ejecuta)
Create Database NuevaLogistica On Primary (
  name = NuevaLogisticaData,
  filename = 'C:\7BD\NuevaLogistica.mdf',
  size = 50mb,
  filegrowth = 25 %
) log on (
  name = NuevaLogisticaLog,
  filename = 'C:\7BD\NuevaLogistica.ldf',
  size = 50mb,
  filegrowth = 25 %
);

-- ? 9. Se escribe el codigo de  restore
-- ? Permite ver la informacion de un archivo
Restore Headeronly
from disk = 'C:\7BD\NuevaLogistica_Log.bak'

-- ? Permite restaurar la base de datos
-- ? Full
Restore Database NuevaLogistica
From Disk = 'C:\7BD\NuevaLogistica.bak'
With File = 1, Norecovery;
-- ? Differential
Restore Database NuevaLogistica
From Disk = 'C:\7BD\NuevaLogistica_Diferencial.bak'
With File = 1, Norecovery;
-- ? Log
Restore Log NuevaLogistica
From Disk = 'C:\7BD\NuevaLogistica_Log.bak'
With File = 1, Recovery;
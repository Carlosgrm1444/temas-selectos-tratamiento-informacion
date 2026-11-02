-- ? Carlos Gabriel Rodriguez Macias
-- * Edith Dulce Athala Gomez
-- ? Respaldos - 19/02/2026

-- ? 1.Crear y usar una BD con tu nombre
Create Database CarlosGabrielRodriguezMacias on Primary (
  Name = CarlosGabrielRodriguezMaciasData,
  filename = 'C:\7BD\CarlosGabrielRodriguezMacias.mdf',
  size = 50mb,
  Filegrowth = 25 %
) log on (
  Name = CarlosGabrielRodriguezMaciasLog,
  filename = 'C:\7BD\CarlosGabrielRodriguezMacias_log.ldf',
  size = 25MB,
  Filegrowth = 25 %
);
USE CarlosGabrielRodriguezMacias;

-- ? Crear una tabla de ejemplo:
CREATE TABLE Ejemplo (
    Id INT PRIMARY KEY,
    Nombre VARCHAR(50),
    Edad INT
);

-- ? 2.Realiza un backup completo
BACKUP DATABASE CarlosGabrielRodriguezMacias To Disk = 'C:\7BD\CarlosGabrielRodriguezMacias_Completo.bak'
With Init, Format, Name = 'Backup Completo CarlosGabrielRodriguezMacias',
Description = 'Backup completo de la base de datos CarlosGabrielRodriguezMacias';

-- ? 3. Inserta 3 registros a una tabla
INSERT INTO Ejemplo (Id, Nombre, Edad) VALUES 
(1, 'Carlos', 25),
(2, 'Gabriel', 30),
(3, 'Rodriguez', 35);

-- ? 4. Realiza un backup diferencial
BACKUP DATABASE CarlosGabrielRodriguezMacias To Disk = 'C:\7BD\CarlosGabrielRodriguezMacias_Diferencial.bak'
With Differential, Name = 'Backup Diferencial CarlosGabrielRodriguezMacias',
Description = 'Backup diferencial de la base de datos CarlosGabrielRodriguezMacias';

-- ? 5. Inserta 1 registro a una tabla
INSERT INTO Ejemplo (Id, Nombre, Edad) VALUES 
(4, 'Macias', 40);

-- ? 6. Realiza el backup del log
BACKUP LOG CarlosGabrielRodriguezMacias To Disk = 'C:\7BD\CarlosGabrielRodriguezMacias_Log.bak'
With Name = 'Backup Log CarlosGabrielRodriguezMacias',
Description = 'Backup del log de la base de datos CarlosGabrielRodriguezMacias';

-- ? 7. Se elimina la BD
Use master;
DROP DATABASE CarlosGabrielRodriguezMacias;

-- ? 8. Se escribe el codigo de crear bd (como repaso pero no se ejecuta) con archivo secundario y 
Create Database CarlosGabrielRodriguezMacias on Primary (
  Name = CarlosGabrielRodriguezMaciasData,
  filename = 'C:\7BD\CarlosGabrielRodriguezMacias.mdf',
  size = 50mb,
  Filegrowth = 25 %
) log on (
  Name = CarlosGabrielRodriguezMaciasLog,
  filename = 'C:\7BD\CarlosGabrielRodriguezMacias_log.ldf',
  size = 25MB,
  Filegrowth = 25 %
);

-- ? 9. Se escribe el codigo de  restore que permite ver la informacion de un archivo
RESTORE HEADERONLY FROM DISK = 'C:\7BD\CarlosGabrielRodriguezMacias_Completo.bak';
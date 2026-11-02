-- ? Carlos Gabriel Rodriguez Macias
-- * Edith Dulce Athala Gomez
-- ? Practica 5 -24/02/2026

-- ? Crear una tabla para los usuarios
CREATE TABLE #usuarios (
    id_usuario INT PRIMARY KEY identity(1, 1),
    nombre VARCHAR(50) not null,
    paterno VARCHAR(50) not null,
    materno VARCHAR(50) not null,
    contrasena VARCHAR(255) not null,
);

-- ? Insertar un usuario de ejemplo
INSERT INTO #usuarios (nombre, paterno, materno, contrasena) VALUES 
('Carlos', 'Rodriguez', 'Macias', 'contrasena123');

-- ? actualizar un usuario de ejemplo
UPDATE #usuarios SET nombre = 'Carlos Eduardo' WHERE id_usuario = 1;

-- ? eliminar un usuario de ejemplo
DELETE FROM #usuarios WHERE id_usuario = 1;

-- ? listar registros
SELECT * FROM #usuarios;

-- ? Crear usuario para la base de datos
Create User usuarioClase For
Login pruebaClase;

-- ? En un documento con portada, realiza lo siguiente:
-- ? Crea una tabla temporal para la Base de Datos que indique el docente
-- ? usuarios_tunombre: id_usuario, usuario, contrasena (utiliza el tipo de dato VARBINARY)
Create Table  #usuarios_carlos(
    id_usuario INT PRIMARY KEY identity(1, 1),
    usuario VARCHAR(50) not null,
    contrasena VARBINARY(256) not null
);  

-- ? Investiga 2 características del tipo de dato VARBINARY  y porque es necesario asignarlo cuando se va a emplear la función HASHBYTES
-- * Almacena datos binarios de longitud variable (bytes), no texto. Se define como VARBINARY(n) o VARBINARY(MAX).
-- * Puede almacenar hasta 8,000 bytes con VARBINARY(n) y hasta 2 GB con VARBINARY(MAX).

-- ? Inserta 4 registros (utiliza la función HASHBYTES), con los siguientes algoritmos:
-- ? 'SHA2_256'
-- ? 'SHA2_512'
Insert Into #usuarios_carlos (usuario, contrasena)
values
('usuario1', HASHBYTES('SHA2_256', 'contrasena1')),
('usuario2', HASHBYTES('SHA2_256', 'contrasena2')),
('usuario3', HASHBYTES('SHA2_512', 'contrasena3')),
('usuario4', HASHBYTES('SHA2_512', 'contrasena4'));

-- ? Investiga 2 características de cada algoritmo: SHA2_256  y SHA2_512
-- * SHA2_256
-- * Genera un hash de 256 bits (32 bytes).
-- * Mayor seguridad que MD5 y SHA1, resistente a colisiones conocidas prácticas.
-- * SHA2_512
-- * Genera un hash de 512 bits (64 bytes).

-- ? Investiga a partir de que versión los algoritmos md5 están en desuso en SQL SERVER
-- * Los algoritmos MD5, SHA y SHA1 fueron marcados como obsoletos (deprecated) a partir de SQL Server 2016 (13.x).
-- * Microsoft recomienda usar SHA2_256 o SHA2_512.


-- ? Investiga a partir de que versión se tenia un límite de entrada de 8000 bytes en SQL SERVER.
-- * En versiones anteriores a SQL Server 2016 (13.x), la función HASHBYTES tenía un límite de entrada de 8000 bytes.

-- ? Lista los registros 
SELECT * FROM #usuarios_carlos;

-- ? Lista registros donde compares una contraseña 
SELECT * FROM #usuarios_carlos WHERE contrasena = HASHBYTES('SHA2_256', 'contrasena1');

-- ? Actualiza 1 registro
UPDATE #usuarios_carlos SET contrasena = HASHBYTES('SHA2_256', 'nueva_contrasena') WHERE id_usuario = 1;

-- ? Elimina un registro
DELETE FROM #usuarios_carlos WHERE id_usuario = 2;
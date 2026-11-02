-- ? en MySQL
-- ? La UAT necesita almacenar informaci�n relevante para llevar un registro de las calificaciones de los estudiantes por asignatura.
-- ? En la universidad existen siete carreras: LA, LPS, LTI, CP, LD, LAT y CE; cada una cuenta con su propia clave.
-- ? Asimismo, laboran m�s de 100 docentes que imparten diversas asignaturas; algunos de ellos pueden impartir la misma materia debido a la existencia de dos turnos: matutino y vespertino.
-- ? Las asignaturas pertenecen a un plan de estudios (carrera) y cuentan con una carga horaria y una clave �nica; esta clave se mantiene aunque la misma asignatura forme parte de distintos planes de estudio. Cada docente posee un n�mero de empleado, y se requiere almacenar datos relevantes como RFC y tel�fono.
-- ? De igual manera, es necesario registrar informaci�n de los estudiantes, como CURP, RFC, grado actual y c�digo postal.
-- ? Se solicita crear una base de datos con el nombre uat_tu_nombre (en min�sculas) y, adem�s, definir las tablas correspondientes para dicha base de datos.
-- ? Cada tabla debe tener tu primer nombre, ejemplo: carreras_athala, docentes_athala, alumnos_athala, etc
-- ? Los campos �nicos son rfc, curp, clave (integrar la restricci�n correspondiente)
-- ? La calificaci�n no puede ser 0 (integrar la restricci�n correspondiente)
-- ? Los datos personales no deben permitir el almacenamiento de valores nulos
-- ? Las claves primarias deben ser auto incrementables
-- ? El cp del alumno tendr� el valor por defecto de '88000'
Use master;
Create Database  uat_carlos 
On
(
	Name = carlosPrimary,
	Location = 'C:\7BD\carlosPrimary.mdf',
	Size = 10MB,
	FileGrowth = 25MB
)
Log On
(
	Name = carlosLog,
	Location = 'C:\7BD\carlosLog.ldf',
	Size = 5MB,
	FileGrowth = 25MB
)

-- ! ---------------

Use uat_carlos;
Create Table alumnos_carlos(
	id_alumno int primary key identity(1, 1),
	curp varchar(18) not null unique ,
	rfc varchar(13) not null unique,
	grado_actual int not null,
	codigo_postal varchar(5) not null default '88000'
);

Create Table docentes_carlos(
    id_docente int primary key identity(1, 1),
    num_emp int not null,
    rfc varchar(13) not null unique,
    telefono varchar(15) not null
);

Create Table carreras_carlos(
    id_carrera int primary key identity(1, 1),
    nombre_carrera varchar(50) not null,
    clave_carrera varchar(10) not null unique
);

Create Table asignaturas_carlos(
    id_asignatura int primary key identity(1, 1),
    nombre_asignatura varchar(50) not null,
    clave_asignatura varchar(10) not null unique,
    carga_horaria int not null,
    id_carrera int not null,
    foreign key (id_carrera) references carreras_carlos(id_carrera)
);

Create Table calificaciones_carlos(
    id_calificacion int primary key identity(1, 1),
    id_alumno int not null,
    id_asignatura int not null,
    id_docente int not null,
    calificacion decimal(5, 2) not null check (calificacion > 0),
    foreign key (id_alumno) references alumnos_carlos(id_alumno),
    foreign key (id_asignatura) references asignaturas_carlos(id_asignatura),
    foreign key (id_docente) references docentes_carlos(id_docente)
);

-- ? Se vio la necesidad  de crear un archivo secundario para la base de datos.
-- ? Debe estar en la ruta 7BD
-- ? El grupo de archivos se debe llamar como tu primer nombre
-- ? El archivo secundario debe tener un size de 15MB
-- ? *Agrega los códigos necesarios para cumplir con la necesidad planteada
Alter Database uat_carlos
Add File
(
    Name = carlos_secundario,
    Filename = 'C:\7BD\carlosSecondary.ndf',
    Size = 15MB,
    FileGrowth = 25MB
);

-- ? Ingresó un pasante de la carrera de LTI, por lo que se requiere darle un inicio de sesión, inserte el codigo para ello
Create Login carlos_login With Password = 'carlos123.';

-- ? Se planea cambiar de servidor por lo que se requiere realizar un respaldo completo
Backup Database uat_carlos To Disk = 'C:\7BD\uat_carlos_backup.bak'
With Format, Name = 'Respaldo ful de uat_carlos', 
Description = 'Respaldo completo de la bd';

-- ? Han pasado ya varios días y se recomienda hacer un respaldo de los datos (no se requieren todos los datos solo se necesitan desde el ultimo respaldo hasta hoy
Backup Database uat_carlos To Disk = 'C:\7BD\uat_carlos_backup.bak'
With Differential, Name = 'Respaldo diferetncial de uat_carlos', 
Description = 'Respaldo diffe de la bd';

-- ? Se requiere crear una tabla temporal con tu primerapellido, para almacenar los inicios de sesiones
-- ? Debe tener una clave primaria
-- ? debe tener la fecha
-- ? debe tener un id_usuario (sin clave foranea)
-- ? contrasena de tipo varbinary 
Create Table #sesiones_carlos(
    id_sesion int primary key identity(1, 1),
    id_usuario int not null,
    fecha datetime not null,
    contrasena varbinary(255) not null
);

-- ? Utiliza HASHBYTES para inserta un registros en la tabla temporal, utilizando el algoritmo que indique el docente (SHA2_256)
Insert Into #sesiones_carlos (id_usuario, fecha, contrasena)
Values (1, GETDATE(), HASHBYTES('SHA2_256', 'carlos123.'));

-- ? Código para vincular

-- ? Se requiere ver toda la información de la Base de Datos por medio del SP para ver informaicion importante de la bd
Exec sp_helpdb uat_carlos;

-- ? Se requiere un usuario para el inicio de sesión creado
Create User carlos_user For Login carlos_login;
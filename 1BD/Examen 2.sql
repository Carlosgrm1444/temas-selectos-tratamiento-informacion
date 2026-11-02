-- ? Creacion de la base de datos
Create Database biblioteca_municipal_rodriguez on Primary (
    Name = BibliotecaMunicipalRodriguezData,
    filename = 'C:\7BD\biblioteca_municipal_rodriguez.mdf',
    size = 50mb,
    Filegrowth = 25 %
) log on (
    Name = BibliotecaMunicipalRodriguezLog,
    filename = 'C:\7BD\biblioteca_municipal_rodriguez_log.ldf',
    size = 25MB,
    Filegrowth = 25 %
);

Use biblioteca_municipal_rodriguez;

-- ? Creacion de tablas
Create Table Rodriguez_Bibliotecarios(
    id_bibliotecario Int Identity(1, 1) Primary Key,
    nombre_completo Varchar(150) Not null,
    usuario_login Varchar(50) Not Null,
    contrasena_hash Varchar(50) Not Null,
    activo Int Not Null Default 1, 
    -- ? No me acorde como se pone el boolean aqui, pero bueno, supon que ese sirve jaja
    Constraint Unique_Rodriguez_Bibliotecarios_usuario_login 
        Unique (usuario_login)
);

Create Table Rodriguez_Editoriales(
    id_editorial Int Identity(1, 1) Primary Key,
    nombre_editorial Varchar(100) Not Null,
    Constraint Unique_Rodriguez_Editoriales_nombre
        Unique(nombre_editorial)
);

Create Table Rodriguez_Clasificaciones (
    id_clasificacion Int Identity(1, 1) Primary Key,
    nombre_clasificacion Varchar(100) Not Null,
    Constraint Unique_Rodriguez_Clasificaciones_nombre
        Unique (nombre_clasificacion)
);

Create Table Rodriguez_Libros (
    id_libro Int Identity(1, 1) Primary Key,
    nombre_libro Varchar(200) Not Null,
    fecha_publicacion Date Not Null,
    id_editorial Int Not Null,
    id_clasificacion Int Not Null,
    Constraint Foreign_Rodriguez_Libros_Editoriales
        Foreign Key (id_editorial)
        References Rodriguez_Editoriales(id_editorial),
    Constraint Foreign_Rodriguez_Libros_Clasificaciones
        Foreign Key (id_clasificacion)
        References Rodriguez_Clasificaciones(id_clasificacion)      
);

Create Table Rodriguez_Autores (
    id_autor Int Identity(1,1) Primary Key,
    nombre_completo Varchar(150) NOT NULL
);

Create Table Rodriguez_rel_LibrosAutores (
    id_libro Int NOT NULL,
    id_autor Int NOT NULL,
    Constraint Primary_Rodriguez_rel_LibrosAutores
        Primary Key (id_libro, id_autor),
    Constraint Foreign_Rodriguez_rel_LibrosAutores_Libros
        Foreign Key (id_libro)
        References Rodriguez_Libros(id_libro),
    Constraint Foreign_Rodriguez_rel_LibrosAutores_Autores
        Foreign Key (id_autor)
        References Rodriguez_Autores(id_autor)
);

Create Table Rodriguez_Colonias (
    id_colonia Int Identity(1,1) Primary Key,
    nombre_colonia Varchar(100) NOT NULL,
    Constraint Unique_Rodriguez_Colonias_nombre 
        Unique (nombre_colonia)
);

Create Table rel_Rodriguez_Ciudadanos (
    id_ciudadano Int Identity(1,1) Primary Key,
    nombre_completo Varchar(150) NOT NULL,
    calle Varchar(100) NOT NULL,
    numero Varchar(20) NOT NULL,
    id_colonia Int NOT NULL,
    telefono Varchar(20) NOT NULL,
    referencia_identificacion_oficial Varchar(100) NOT NULL,
    Constraint Foreign_rel_Rodriguez_Ciudadanos_Colonias
        Foreign Key (id_colonia)
        References Rodriguez_Colonias(id_colonia)
);

Create Table Rodriguez_Prestamos (
    id_prestamo Int Identity(1,1) Primary Key,
    id_ciudadano Int NOT NULL,
    fecha_prestamo Date NOT NULL,
    fecha_estimada_entrega Date NOT NULL,
    observaciones Varchar(300) NULL,
    Constraint Foreign_Rodriguez_Prestamos_Ciudadanos
        Foreign Key (id_ciudadano)
        References rel_Rodriguez_Ciudadanos(id_ciudadano),
    Constraint Check_Rodriguez_Prestamos_Fechas
        Check (fecha_estimada_entrega >= fecha_prestamo)
);

Create Table Rodriguez_DetallePrestamos (
    id_prestamo Int NOT NULL,
    id_libro Int NOT NULL,
    Constraint Primary_Rodriguez_DetallePrestamos
        Primary Key (id_prestamo, id_libro),
    Constraint Foreign_Rodriguez_DetallePrestamos_Prestamos
        Foreign Key (id_prestamo)
        References Rodriguez_Prestamos(id_prestamo),
    Constraint Foreign_Rodriguez_DetallePrestamos_Libros
        Foreign Key (id_libro)
        References Rodriguez_Libros(id_libro)
);

-- ? 1. Restaura el respaldo completo
Use master;

Restore Database biblioteca_municipal_rodriguez
From Disk = 'C:\7BD\Carlos.bak'
With Replace, Recovery;

Use biblioteca_municipal_rodriguez;

-- ? 3. Se requiere obtener un respaldo completo de la base de datos (el nombre del archivo del respaldo debe tener tu primer nombre)
Backup Database biblioteca_municipal_rodriguez
To Disk = 'C:\7BD\Carlos.bak' With Init, Name = 'Respaldo completo biblioteca municipal';

-- ? 4. Se desea ejecutar el job creado (escribe la sentencia SQL) No es válido si no se creó
Exec msdb.dbo.sp_start_job @job_name = 'job_Rodriguez_Autores';

-- ? 5. Se requiere tener una consulta almacenada en el gestor que permita eliminar los datos del ciudadano (por su identificador único)
Create Procedure sp_EliminarCiudadano
    @id_ciudadano Int
As
Begin
    Set NoCount On;
    Delete From Rodriguez_DetallePrestamos
    Where id_prestamo In (
        Select id_prestamo
        From Rodriguez_Prestamos
        Where id_ciudadano = @id_ciudadano
    );
    Delete From Rodriguez_Prestamos
    Where id_ciudadano = @id_ciudadano;
End;

-- ? 6. Se desea una consulta almacenada (procedure encriptado) donde de como resultado los libros que cuya clasificación  empiece con T ó C
Create Procedure sp_LibrosClasificacionTC
With Encryption
As
Begin
    Select
        l.id_libro,
        l.nombre_libro,
        l.fecha_publicacion,
        e.nombre_editorial,
        c.nombre_clasificacion
    From Rodriguez_Libros As l
    Inner Join Rodriguez_Editoriales As e
        On l.id_editorial = e.id_editorial
    Inner Join Rodriguez_Clasificaciones As c
        On l.id_clasificacion = c.id_clasificacion
    Where c.nombre_clasificacion Like 'T%'
       Or c.nombre_clasificacion Like 'C%';
End;

-- ? 7. Teniendo como servidor  vinculado la Ip del docente (Servidor SQL SERVER).  Escribe la consulta que permita listar la información de la tabla de paises (base de datos logistica_athala)
Select *
From [IP_DOCENTE].logistica_athala.dbo.paises;

-- ? 8. Procedimiento que permite enviar un correo electrónico
-- ? sp_sendmail
-- ? sp_mailsend
-- ? sp_send_mailxp
Exec msdb.dbo.sp_send_dbmail
    @profile_name = 'PerfilCorreo',
    @recipients = 'correo@dominio.com',
    @subject = 'Prueba de correo',
    @body = 'Envío de correo desde SQL Server';

-- ? 9. Se requiere tener una consulta almacenada en el gestor que permita obtener los libros y la cantidad de veces que han sido prestados por un rango de fecha que debe enviar el usuario
Create Procedure sp_LibrosPrestadosPorRangoFecha
    @fecha_inicio Date,
    @fecha_fin Date
As
Begin
    Select
        l.id_libro,
        l.nombre_libro,
        Count(dp.id_libro) As cantidad_veces_prestado
    From Rodriguez_Libros As l
    Inner Join Rodriguez_DetallePrestamos As dp
        On l.id_libro = dp.id_libro
    Inner Join Rodriguez_Prestamos As p
        On dp.id_prestamo = p.id_prestamo
    Where p.fecha_prestamo Between @fecha_inicio And @fecha_fin
    Group By
        l.id_libro,
        l.nombre_libro;
End;

-- ? 10. Se desea saber cuáles clasificaciones tienen un promedio mayor a 20 libros, en una vista encriptada con tu primer nombre (no utilizar subconsulta)
Create View View_Carlos_ClasificacionesPromedioMayor20
With Encryption
As
Select
    c.id_clasificacion,
    c.nombre_clasificacion,
    Count(l.id_libro) As total_libros
From Rodriguez_Clasificaciones As c
Inner Join Rodriguez_Libros As l
    On c.id_clasificacion = l.id_clasificacion
Group By
    c.id_clasificacion,
    c.nombre_clasificacion
Having Count(l.id_libro) > 20;

-- ? 11. Se requiere tener una consulta almacenada en el gestor que permita insertar datos de los prestamos
Create Procedure sp_InsertarPrestamo
    @id_ciudadano Int,
    @fecha_prestamo Date,
    @fecha_estimada_entrega Date,
    @observaciones Varchar(300) = Null
As
Begin
    Insert Into Rodriguez_Prestamos
    (id_ciudadano, fecha_prestamo, fecha_estimada_entrega, observaciones
    )
    Values
    (@id_ciudadano, @fecha_prestamo, @fecha_estimada_entrega, @observaciones
    );
End;

-- ? 12. Se requiere tener una consulta almacenada donde  si el valor recibido es  'especifica', debe listar la clasificación especifica en mayúsculas; sino que liste todas las clasificaciones en orden alfabético y en mayúsculas
Create Procedure sp_ListarClasificaciones
    @tipo Varchar(20)
As
Begin
    If Lower(@tipo) = 'especifica'
    Begin
        Select Upper(nombre_clasificacion) As clasificacion
        From Rodriguez_Clasificaciones
        Where Lower(nombre_clasificacion) = 'especifica';
    End
    Else
    Begin
        Select Upper(nombre_clasificacion) As clasificacion
        From Rodriguez_Clasificaciones
        Order By nombre_clasificacion;
    End
End;

-- ? 13. Se requiere tener una consulta almacenada en donde se envie el id del prestamo o bien sino se vacie la tabla de prestamos 
Create Procedure sp_EliminarPrestamo
    @id_prestamo Int = Null
As
Begin
    If @id_prestamo Is Null
    Begin
        Delete From Rodriguez_DetallePrestamos;
        Delete From Rodriguez_Prestamos;
    End
    Else
    Begin
        Delete From Rodriguez_DetallePrestamos
        Where id_prestamo = @id_prestamo;

        Delete From Rodriguez_Prestamos
        Where id_prestamo = @id_prestamo;
    End
End;

-- ? 14. Se desea tener el nombre del ciudadano y la cantidad de libros que ha solicitado, en una vista encriptada con tu primer nombre (no utilizar subconsulta)
Create View View_Carlos_CiudadanoCantidadLibros
With Encryption
As
Select
    ci.id_ciudadano,
    ci.nombre_completo,
    Count(dp.id_libro) As cantidad_libros_solicitados
From rel_Rodriguez_Ciudadanos ci
Inner Join Rodriguez_Prestamos p
    On ci.id_ciudadano = p.id_ciudadano
Inner Join Rodriguez_DetallePrestamos dp
    On p.id_prestamo = dp.id_prestamo
Group By
    ci.id_ciudadano,
    ci.nombre_completo;

-- ? 15. Se requiere tener una consulta almacenada en el gestor que permita actualizar los datos del ciudadano 
Create Procedure sp_ActualizarCiudadano
    @id_ciudadano Int,
    @nombre_completo Varchar(150),
    @calle Varchar(100),
    @numero Varchar(20),
    @id_colonia Int,
    @telefono Varchar(20),
    @referencia_identificacion_oficial Varchar(100)
As
Begin
    Set NoCount On;

    Update rel_Rodriguez_Ciudadanos
    Set
        nombre_completo = @nombre_completo,
        calle = @calle,
        numero = @numero,
        id_colonia = @id_colonia,
        telefono = @telefono,
        referencia_identificacion_oficial = @referencia_identificacion_oficial
    Where id_ciudadano = @id_ciudadano;
End;

-- ? 16. Crea un job que liste el nombre del autor y cuantos libros realizo. Se le debe mostrar completo a su maestra
Exec msdb.dbo.sp_add_job
    @job_name = 'job_Rodriguez_Autores';

Exec msdb.dbo.sp_add_jobstep
    @job_name = 'job_Rodriguez_Autores',
    @step_name = 'Paso_ListarAutores',
    @subsystem = 'TSQL',
    @database_name = 'biblioteca_municipal_rodriguez',
    @command = '
        Select
            a.nombre_completo As autor,
            Count(la.id_libro) As cantidad_libros
        From Rodriguez_Autores a
        Inner Join Rodriguez_rel_LibrosAutores la
            On a.id_autor = la.id_autor
        Group By a.nombre_completo;
    ';

Exec msdb.dbo.sp_add_jobserver
    @job_name = 'job_Rodriguez_Autores';

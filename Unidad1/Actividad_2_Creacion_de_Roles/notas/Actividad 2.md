# Actividad 2. Creación de Roles

**Carrera:** Tecnologías de la Información  
**Materia:** Temas Selectos de Tratamiento de Información  
**Actividad:** Actividad 2. Creación de Roles  
**Alumno:** Rodríguez Macias Carlos Gabriel  
**Docente:** Gómez Arellano Athala Dulce Edith  
**Lugar:** Nuevo Laredo, Tamaulipas  
**Fecha:** 3 de septiembre de 2026

---

# Creación de Roles
Los roles permiten asignar permisos a varios usuarios sin tener que dar los permisos uno por uno. De esta forma, si varios empleados realizan la misma actividad, se les puede agregar al mismo rol.

## Configuración en SQL Server
En esta actividad se trabajará con la base de datos `control_academico`, la cual contiene las tablas `ESTUDIANTES`, `PROFESORES`, `MATERIAS` e `INSCRIPCIONES`.

Debido a que el servidor se trabajó en Ubuntu, la configuración se realizó mediante código T-SQL y no con la interfaz visual de SSMS.

### Paso 1. Usar la base de datos

Primero se seleccionó la base de datos donde se crearán los roles y se asignarán los permisos.

```sql
Use control_academico;
```

### Paso 2. Crear los roles

Se crearon tres roles para separar las responsabilidades de los auxiliares administrativos, auxiliares académicos y profesores.

```sql
Create Role rol_auxiliar_administrativo;
Create Role rol_auxiliar_academico;
Create Role rol_profesor;
```

### Paso 3. Permisos del auxiliar administrativo

El auxiliar administrativo puede consultar, registrar y actualizar la información de los estudiantes y las inscripciones. No se le dio permiso de eliminar registros para mantener el principio de mínimo privilegio.

```sql
Grant Select, Insert, Update On dbo.ESTUDIANTES To rol_auxiliar_administrativo;
Grant Select, Insert, Update On dbo.INSCRIPCIONES To rol_auxiliar_administrativo;
```

### Paso 4. Permisos del auxiliar académico y profesor

El auxiliar académico puede consultar estudiantes, materias e inscripciones. El profesor puede consultar la información necesaria de estudiantes, materias e inscripciones, sin modificar las tablas.

```sql
Grant Select On dbo.ESTUDIANTES To rol_auxiliar_academico;
Grant Select On dbo.MATERIAS To rol_auxiliar_academico;
Grant Select On dbo.INSCRIPCIONES To rol_auxiliar_academico;

Grant Select On dbo.ESTUDIANTES To rol_profesor;
Grant Select On dbo.MATERIAS To rol_profesor;
Grant Select On dbo.INSCRIPCIONES To rol_profesor;
```

## Cambio de permisos para auxiliares académicos

Al siguiente semestre, los auxiliares académicos también deberán consultar los datos de los profesores. Para resolverlo, solamente se agregó el permiso `SELECT` al rol ya creado.

```sql
Grant Select On dbo.PROFESORES To rol_auxiliar_academico;
```

Si los permisos estuvieran asignados directamente a cada usuario, se tendría que buscar a todos los auxiliares académicos y dar el permiso `SELECT` uno por uno.

La ventaja de tener roles es que se modifica un solo rol y todos los usuarios que pertenecen a ese rol reciben el permiso.

## Cambio de rol de Javier

Javier deja de ser auxiliar administrativo y pasa a ser profesor. Por ello, primero se elimina del rol anterior y después se agrega al nuevo rol.

```sql
Alter Role rol_auxiliar_administrativo
Drop Member USR_JAVIER;

Alter Role rol_profesor
Add Member USR_JAVIER;
```

El usuario se escribe como `USR_JAVIER`, siguiendo el formato del ejemplo `USR_ANA` de la actividad.

## Evidencias

[PENDIENTE DE AGREGAR CAPTURAS DE LA EJECUCIÓN]

## Conclusión

Creo que los roles son importantes porque facilitan el manejo de permisos dentro de una base de datos. En lugar de configurar cada usuario por separado, los permisos se asignan según las responsabilidades de cada puesto. Esto ayuda a que la administración sea más sencilla, evita dar permisos de más y permite hacer cambios rápidamente cuando un empleado cambia de puesto o deja de trabajar.

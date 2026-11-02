-- ? Carlos Gabriel Rodriguez Macias
-- * Edith Dulce Athala Gomez
-- ? Actividad 2 - Creación de Roles

Use control_academico;

-- ? Paso 1. Crear los roles y asignar sus permisos.
Create Role rol_auxiliar_administrativo;
Create Role rol_auxiliar_academico;
Create Role rol_profesor;

-- ? Permisos del auxiliar administrativo.
Grant Select, Insert, Update On dbo.ESTUDIANTES To rol_auxiliar_administrativo;
Grant Select, Insert, Update On dbo.INSCRIPCIONES To rol_auxiliar_administrativo;

-- ? Permisos del auxiliar académico.
Grant Select On dbo.ESTUDIANTES To rol_auxiliar_academico;
Grant Select On dbo.MATERIAS To rol_auxiliar_academico;
Grant Select On dbo.INSCRIPCIONES To rol_auxiliar_academico;

-- ? Permisos del profesor.
Grant Select On dbo.ESTUDIANTES To rol_profesor;
Grant Select On dbo.MATERIAS To rol_profesor;
Grant Select On dbo.INSCRIPCIONES To rol_profesor;

-- ? Paso 2. Dar permiso de consulta de PROFESORES a los auxiliares académicos.
Grant Select On dbo.PROFESORES To rol_auxiliar_academico;

-- ? Respuesta: si los permisos fueran directos, se tendría que dar SELECT a cada auxiliar.
-- ? Ventaja: se modifica un solo rol y todos sus miembros reciben el permiso.

-- ? Paso 3. Quitar a Javier del rol auxiliar y agregarlo al rol profesor.
Alter Role rol_auxiliar_administrativo
Drop Member USR_JAVIER;

Alter Role rol_profesor
Add Member USR_JAVIER;

-- ? Paso 4. Conclusión en el archivo notas/Actividad 2.md.

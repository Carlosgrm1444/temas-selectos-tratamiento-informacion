# Proyecto Unidad 3

Esta carpeta toma como base el proyecto corregido de las unidades I y II. La presentación editable está en `presentacion/`. Los ocho procedimientos se encuentran en cuatro archivos SQL dentro de `scripts/`, con dos ejemplos por estructura. El índice está en el archivo `05_indices.sql`. La carpeta `sql/` reúne una copia directa de esos archivos para entregarlos junto con la presentación.

Los CSV originales y limpios se copiaron del proyecto anterior en `csv_originales/` y `csv_limpios/`. No se modifica la base existente al abrir los archivos; los procedimientos solo se crean cuando se ejecutan los scripts.

## Orden de ejecución

1. Confirmar que existen `pepsi_distribucion` y las tablas de `proyecto_u2` del proyecto anterior.
2. Ejecutar `01_subconsultas_encriptados.sql` a `04_case.sql`, uno por uno.
3. Ejecutar `05_indices.sql` y comparar la consulta con su plan y estadísticas antes/después.
4. Tomar captura del código de cada procedimiento y de su resultado. Las diapositivas identifican los espacios para estas 16 capturas. Si un procedimiento devuelve cero filas, capturar también la consulta de datos y explicar por qué.
5. Agregar fotografías reales de las señas y las tres cartulinas, además de la grabación del cuento.

## Pendiente para entrega completa

- Ocho capturas de código y ocho capturas de ejecución de los procedimientos.
- Medición real de restauración para comprobar el RTO de 2 horas. La presentación señala que es una meta propuesta.
- Comparación real de lecturas/tiempo y plan de ejecución para el índice.
- Fotografías y audio del material de inclusión hechos por el equipo.

La herramienta Database Engine Tuning Advisor se describe para cumplir el tema. En Linux se puede revisar el plan y `SET STATISTICS IO/TIME` con T-SQL. La interfaz de DTA requiere un equipo Windows; no se presenta una captura ficticia.

Fuentes técnicas: https://learn.microsoft.com/en-us/sql/relational-databases/performance/database-engine-tuning-advisor y https://learn.microsoft.com/en-us/sql/t-sql/statements/create-procedure-transact-sql

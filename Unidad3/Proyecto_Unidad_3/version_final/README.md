# Proyecto Unidad 3 - Entrega preparada

La presentación en PowerPoint y PDF contiene 34 diapositivas, los resultados reales de la muestra y las tres fotos de braille compartidas por el equipo. Las fotos originales también están en `inclusion/`.

La presentación toma como base el proyecto corregido de las unidades I y II, los cuatro ejemplos recientes de clase, los CSV compartidos por el equipo y el modelo de `pepsi.bacpac`.

## Archivos para entregar

- `presentacion/`: PowerPoint editable y PDF final de la misma presentación.
- `sql/01_...` a `sql/10_...`: diez procedimientos, cada uno en su archivo, con los nombres del equipo y los comentarios del código.
- `sql/11_indice_caducidad.sql`: consulta, índice y comparación antes/después.
- `csv_originales/` y `csv_limpios/`: tres archivos de cada versión.
- `inclusion/`: material de apoyo y guion del cuento. Las fotografías y el audio deben corresponder al trabajo real del equipo.
- `documento_base/`: PDF final corregido de las unidades I y II, para acompañar la entrega si lo solicita la docente.
- `bases_recibidas/`: los dos BACPAC originales compartidos por el equipo.

## Base y congruencia de los códigos

El BACPAC principal es `pepsi.bacpac`. Su modelo contiene las 13 tablas operativas, cuatro tablas del esquema `proyecto_u2` y tres copias de importación terminadas en `1`. Los procedimientos trabajan con `proyecto_u2.producto`, `proyecto_u2.lote`, `proyecto_u2.inventario_lote` y `proyecto_u2.almacen`.

Los archivos del 01 al 11 y el 90 seleccionan `pepsi_distribucion`. Si al importar el BACPAC se eligió el nombre `Pepsi`, esa instrucción `Use` se cambia por `Use Pepsi`.

`pepsi_distribucion.bacpac` contiene únicamente las tablas `dbo.producto`, `dbo.lote` y `dbo.inventario_lote`. Ninguno de los dos paquetes contiene trabajos de SQL Server Agent. Esos trabajos se almacenan en `msdb`; su programación se entrega aparte en el archivo 13 y se presenta como propuesta.

## Pruebas locales

Se preparó `pepsi_u3_demo` para comprobar el código con los CSV recibidos: 44 productos, 42 lotes, 42 inventarios y un almacén de referencia. La base operativa previa conserva sus datos.

1. Para crear la muestra desde cero en otro servidor, ejecutar `00_preparar_demostracion.sql` una sola vez. Incluye estructura, registros limpios y los diez procedimientos.
2. En este equipo la muestra ya existe. Ejecutar `92_probar_copia_local.sql` para reproducir las consultas y los errores controlados. Los cambios de prueba se revierten.
3. Para la base importada del proyecto, ejecutar los archivos 01 al 10 y después `90_ejecutar_ejemplos.sql`.
4. El archivo 11 crea un índice una sola vez y compara el mismo filtro antes y después. En la muestra local el índice ya se creó durante la validación.

Resultados completos: `evidencias/resultados_sql.txt`. Los planes reales están en `evidencias/antes.sqlplan` y `evidencias/despues.sqlplan`.

El ensayo de FULL, diferencial, log y restauración se realizó únicamente con la muestra en `pepsi_u3_demo` y se restauró como `pepsi_u3_restaurada`. Se verificaron 44, 42 y 42 registros y la integridad de la copia. El tiempo medido fue de 1569 ms (1,569 segundos). La meta de RTO productivo sigue siendo de dos horas y requiere una prueba con volumen, almacenamiento y operación completos.

## Clases y ejemplos adaptados

- Clase 1: parámetros, `With Encryption`, `If`, `Return`, `Isnull` y `@@Rowcount`.
- Clase 2: `Case`, descuentos como ejemplo de operación y subconsulta con `Avg`.
- Clase 3: subconsultas con `In`, relaciones y `Try...Catch`.
- Clase 4: contador, `While` y actualización de precios. Se usa `Max(id_producto)` porque los IDs del ETL tienen saltos.

## Respaldo, mantenimiento e inclusión

El archivo 13 propone los horarios de respaldo mediante Agent y crea sus trabajos deshabilitados para revisar rutas. Requiere una edición con Agent: el BACPAC recibido proviene de Express, que no lo incluye. El archivo 14 contiene las tareas de integridad, fragmentación y estadísticas.

Las tres guías de braille trabajan con una tabla didáctica de tres columnas. El archivo 91 reproduce el ejemplo en una tabla temporal, porque el catálogo real exige más campos. El material físico debe tener relieve si se utilizará para lectura táctil. Las fotografías de las señas tomadas del diccionario de SEP son referencias de aprendizaje, no evidencia de que los integrantes ya realizaron la actividad.

El equipo todavía debe aportar la grabación real del cuento y comprobar su participación individual en las señas y el material físico.

# Actividad 4. Planes de Mantenimiento

Esta actividad realiza por código los respaldos solicitados y configura un trabajo de SQL Server Agent para la base de datos `hospital_sql`.

## Archivos

- `scripts/habilitar_sql_agent.sh`: habilita SQL Server Agent en Ubuntu.
- `scripts/actividad_4_planes_mantenimiento.sql`: realiza los respaldos y crea los trabajos `hospital_respaldo` y `hospital_mantenimiento`.
- `../data/`: aquí se guardarán los archivos `.bak` y `.trn` generados.

## Equivalencia con el asistente de SSMS

| En SSMS | Adaptación por código |
| --- | --- |
| Seleccionar tareas de respaldo | Instrucciones `BACKUP DATABASE`, `BACKUP LOG` y `ALTER INDEX`. |
| Habilitar SQL Server Agent | `habilitar_sql_agent.sh` con `mssql-conf`. |
| Crear un plan | Procedimientos `sp_add_job`, `sp_add_jobstep` y `sp_add_jobschedule`. |
| Elegir ruta | Rutas directas a la carpeta `data/` del proyecto. |

## Orden de ejecución

1. Ejecutar el archivo de Ubuntu:

   ```bash
   chmod +x Actividad_4_Planes_de_Mantenimiento/scripts/habilitar_sql_agent.sh
   ./Actividad_4_Planes_de_Mantenimiento/scripts/habilitar_sql_agent.sh
   ```

2. Ejecutar el archivo SQL con un login que tenga permisos para realizar respaldos:

   ```bash
   sqlcmd -S localhost -U sa -C \
     -i "Actividad_4_Planes_de_Mantenimiento/scripts/actividad_4_planes_mantenimiento.sql"
   ```

3. Revisar los archivos generados en `data/` y los trabajos `hospital_respaldo` y `hospital_mantenimiento`.

El respaldo del log requiere el modelo de recuperación `FULL`; el script lo configura antes de realizar los respaldos.

Los trabajos se ejecutan los martes, jueves y viernes a las 08:00. El segundo trabajo conserva el respaldo differential y el log en un solo archivo, y reorganiza los índices de las tablas de `hospital_sql`.

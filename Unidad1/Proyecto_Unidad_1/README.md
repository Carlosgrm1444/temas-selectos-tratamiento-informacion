# Proyecto Unidad 1

Este proyecto contiene la parte práctica en T-SQL para una distribuidora ficticia de bebidas. Los nombres, tiendas, productos, pedidos y operaciones utilizados son únicamente datos académicos. El proyecto no describe procesos internos reales de PepsiCo, GEPP ni de alguna empresa relacionada.

## Requisitos

- SQL Server para Linux con SQL Server Agent activo.
- Una cuenta con permisos para crear bases de datos, logins, trabajos, auditorías y eventos extendidos.
- La carpeta `/media/carlos-rodriguez/nvme0n1p1/2db/data` debe existir y permitir escritura al usuario `mssql`.
- Antes de los puntos 9 y 10 se debe ejecutar `preparar_directorio_auditoria.sh`.
- Los scripts están preparados para ejecutarse una sola vez en un ambiente de prueba limpio.

Las contraseñas del Punto 5 son solamente para la demostración escolar. Si se reutiliza el proyecto se deben cambiar y guardar de forma segura.

## Decisión de almacenamiento

No se encontró una matriz de investigación adicional dentro de la carpeta del proyecto. Por eso se utilizó el grupo `PRIMARY` para catálogos, pedidos y sus detalles, mientras que `SECUNDARIO` contiene lotes, inventario, entregas, incidencias, movimientos y conteos. Esta separación permite demostrar el uso del archivo NDF sin cambiar el funcionamiento lógico de las relaciones.

## Rutas que se deben adaptar

En este equipo SQL Server se encuentra instalado en Ubuntu y el disco del proyecto está montado en:

`/media/carlos-rodriguez/nvme0n1p1/2db/data`

Por esta razón no se utiliza `C:/data`. Si el proyecto se ejecuta en otro equipo se deben cambiar las rutas de los puntos 1, 6 y 7. La ruta de las auditorías y eventos extendidos es:

`/var/opt/mssql/audit/proyecto_unidad_1/`

## Orden de ejecución

1. `punto_01_entorno_almacenamiento.sql`
2. `punto_02_modelo_relacional.sql`
3. `punto_03_datos_prueba.sql`
4. `punto_04_consultas_comprobacion.sql`
5. `punto_05_usuarios_privilegios.sql`
6. `punto_06_respaldos.sql`
7. `punto_07_restauracion.sql`
8. `punto_08_mantenimiento.sql`
9. Ejecutar `./preparar_directorio_auditoria.sh` desde la terminal.
10. `punto_09_auditoria.sql`
11. `punto_10_eventos_extendidos.sql`
12. `punto_11_revision_final.sql`

También se puede usar `proyecto_unidad_1.sql` en modo SQLCMD desde la raíz del repositorio. El archivo principal llama los once scripts en el orden correcto, pero el directorio de auditoría se debe preparar antes:

```bash
cd /media/carlos-rodriguez/nvme0n1p1/2db
./Proyecto_Unidad_1/scripts/preparar_directorio_auditoria.sh
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -C -i Proyecto_Unidad_1/scripts/proyecto_unidad_1.sql
```

SQLCMD solicitará la contraseña; no debe escribirse dentro del repositorio.

## Estrategia de recuperación

- Respaldo full todos los días a la 01:00.
- Respaldo diferencial a las 07:00, 13:00 y 19:00.
- Respaldo del log cada 15 minutos.
- RPO propuesto: 15 minutos, porque ese es el intervalo del respaldo del log.
- RTO propuesto: 2 horas. El Punto 7 mide la restauración real en segundos e indica si se cumplió.

Los trabajos programados generan nombres con fecha y hora y no utilizan `INIT` ni `FORMAT`, por lo que no sobrescriben los respaldos anteriores.

## Evidencias sugeridas

| Punto | Evidencia |
|---|---|
| 1 | Archivos MDF, NDF y LDF junto con sus grupos. |
| 2 | Las 13 tablas, llaves y grupos de archivos. |
| 3 | Casos normal, parcial, dañado y diferencia de conteo. |
| 4 | Resultados de las seis consultas de comprobación. |
| 5 | Roles, permisos, una operación permitida y una denegada. |
| 6 | Historial de los tres respaldos y sus programaciones. |
| 7 | Restauración, tiempo RTO, conteos y CHECKDB. |
| 8 | Agent activo, CHECKDB y trabajos de mantenimiento. |
| 9 | Auditoría activa, historial anterior/nuevo y registros `.sqlaudit`. |
| 10 | Sesión creada y eventos leídos desde el archivo `.xel`. |
| 11 | Tabla final de revisión y estado de ambas bases. |

## Estado de revisión

El servicio `mssql-server` está activo, SQLCMD se encuentra instalado y la carpeta `data` existe en este equipo. Los archivos fueron revisados de forma estática. La ejecución completa en SQL Server queda pendiente porque no se guardaron credenciales administrativas dentro del proyecto.

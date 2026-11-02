# Versión completa

Se resolvieron los pasos pendientes de Pandas y se preparó la integración con SQL Server. La carga real requiere ejecutarse con una cuenta autorizada; todavía no hay evidencia de conexión o inserción.

## Ejecutar los datos

Desde esta carpeta:

```bash
../../.venv/bin/python scripts/01_generar_csv.py
../../.venv/bin/python scripts/02_revisar_producto.py
../../.venv/bin/python scripts/03_revisar_lote.py
../../.venv/bin/python scripts/04_revisar_inventario_lote.py
```

Hay que respetar el orden: lote depende del producto limpio e inventario_lote depende de ambos. Los resultados se conservan en resultados, incluidos resúmenes, hallazgos por fila y descartes.

Conservados = corregidos + sin cambios. Iniciales = conservados + descartados. Corregidos cuenta únicamente los registros conservados cuyo contenido cambió. La primera copia de un duplicado queda sin cambios y la repetición adicional se descarta. El porcentaje final usa los conservados como denominador.

## SQL Server

1. Abrir y revisar scripts/00_preparar_sql.sql. Usa la base pepsi_distribucion y crea un esquema nuevo proyecto_u2; no modifica dbo ni crea una copia de la base. Ejecutar una sola vez.
2. Ejecutar:

```bash
../../.venv/bin/python scripts/05_cargar_sql.py
```

El programa solicita el usuario y la contraseña sin guardarla en el código. Usa localhost,1433 por defecto. Puede configurarse SQLSERVER_HOST y SQLSERVER_DATABASE. El esquema destino debe estar vacío; el script no borra datos para repetir la carga.

3. Abrir scripts/06_consultas.sql y ejecutar sus bloques en la misma conexión para conservar la tabla temporal.

El controlador es ODBC Driver 18 for SQL Server. La opción TrustServerCertificate corresponde únicamente al certificado de esta instancia académica local.

## Evidencia pendiente

Capturar el código con Ortega García, Núñez López y Rodríguez Macias visibles; generación de 50 filas por archivo; hallazgos; porcentaje antes y después; archivos exportados; conexión y conteo en SQL Server; tres consultas; tabla temporal y vista encriptada.

Las imágenes ya integradas son listados auténticos del código, no capturas del escritorio. Sustituirlas o complementarlas con las capturas solicitadas por la docente.


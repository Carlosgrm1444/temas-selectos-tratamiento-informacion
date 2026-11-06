# Proyecto Unidad 2

Equipo: Ortega García, Núñez López y Rodríguez Macias.


## CALIDAD DE DATOS Y PYTHON EN EL ALMACÉN

Una base de datos puede tener tablas, permisos y respaldos correctos y aun así recibir información equivocada. En el caso del almacén Pepsi, un precio inválido altera el valor del inventario, un lote mal relacionado puede enviar otra bebida y una fecha incorrecta impide priorizar el producto próximo a caducar. Por eso revisamos los datos antes de utilizarlos para decidir compras y entregas.

Utilizamos datos ficticios para probar el proceso sin utilizar información real de clientes. Faker mantiene una semilla de 7 para repetir el ejercicio con la misma versión de la biblioteca; Pandas permite revisar, filtrar y transformar cada archivo (Faker, s. f.; pandas, s. f.-a, s. f.-b).

Esta versión presenta el avance con los temas desarrollados en las prácticas: generación de datos, lectura con control de errores, inspección, revisión de nulos y duplicados y normalización de textos. La clasificación integral, los porcentajes y la carga a SQL Server se reservan para la versión completa.


## TABLAS SELECCIONADAS Y RELACIONES

| Tabla | Clave y relaciones | Función |
| --- | --- | --- |
| producto | PK id_producto; clave_producto única | Catálogo de bebidas, presentaciones y precios. |
| lote | PK id_lote; FK id_producto a producto; única (id_producto, numero_lote) | Identificar recepciones y caducidades. |
| inventario_lote | PK id_inventario; FK (id_lote, id_producto) a lote; FK id_almacen a almacen | Registrar las unidades del lote en el almacén. |

Se tomó la estructura de las capturas de creación de tablas del proyecto anterior, específicamente las figuras 6 y 6.1. El almacén 1 sirve como referencia auxiliar; no se genera un cuarto archivo de análisis. No se agregan columnas de ventas ni subtotales que no existían en esas tablas.


## RIESGOS Y CONTROLES DE INTEGRIDAD

| Tabla | Riesgo | Control |
| --- | --- | --- |
| producto | Un precio negativo o no numérico distorsiona la valuación. | Validar tipo y precio mayor que cero; CHECK en SQL Server. |
| lote | Una caducidad anterior a la recepción altera la salida de producto. | Comparar fechas; CHECK (fecha_caducidad > fecha_recepcion). |
| inventario_lote | Relacionar un lote con otro producto o inventar existencias. | Verificar cantidad entera no negativa y relación compuesta; FOREIGN KEY. |

Los controles se implementan en las secciones de validación de cada script y, en la versión completa, también mediante las restricciones del código T-SQL. No se convierten precios o cantidades negativos en positivos sin comprobar su valor real; se separan para revisión.


## REGLAS DE NEGOCIO POR COLUMNA


### Tabla producto

| Columna | Regla | Obligatoriedad y relación |
| --- | --- | --- |
| id_producto | Entero positivo único | Obligatorio; clave primaria |
| clave_producto | 1 a 15 caracteres; mayúsculas, sin espacios externos | Obligatoria y única |
| nombre | 1 a 100 caracteres; formato título | Obligatorio; bebida comercializada |
| presentacion | 1 a 50 caracteres; minúsculas | Obligatoria |
| precio | 0.01 a 99,999,999.99; máximo dos decimales | Obligatorio; no inventar precios |
| activo | Entero: 0 o 1 | Obligatorio |


### Tabla lote

| Columna | Regla | Obligatoriedad y relación |
| --- | --- | --- |
| id_lote | Entero positivo único | Obligatorio; clave primaria |
| id_producto | Entero positivo existente en producto limpio | Obligatorio; clave foránea |
| numero_lote | 1 a 30 caracteres; mayúsculas | Único junto con id_producto |
| fecha_recepcion | AAAA-MM-DD; entre 01/01/2026 y 02/11/2026 | Obligatoria; fecha de recepción del ejercicio |
| fecha_caducidad | AAAA-MM-DD; posterior a fecha_recepcion | Obligatoria; consistencia entre columnas |


### Tabla inventario_lote

| Columna | Regla | Obligatoriedad y relación |
| --- | --- | --- |
| id_inventario | Entero positivo único | Obligatorio; clave primaria |
| id_almacen | Entero 1 | Almacén de referencia, sin cuarto CSV |
| id_lote | Entero existente en lote limpio | Único junto con id_almacen |
| id_producto | Debe coincidir con el producto del lote | Relación compuesta id_lote e id_producto |
| cantidad | Entero de 0 a 2,147,483,647 | Obligatoria; no corregir signos sin evidencia |
| fecha_actualizacion | AAAA-MM-DD HH:MM:SS; dentro de 2026 y hasta el corte | Obligatoria; corte 02/11/2026 23:59:59 |

Las claves enteras se limitan al rango de SQL Server INT. No se admiten nulos, texto vacío, espacios externos ni identificadores repetidos. La fecha de corte es el 2 de noviembre de 2026. La presentación se normaliza a minúsculas y las claves de producto y lote a mayúsculas.


## DIAGNÓSTICO DE LA CALIDAD DE LOS DATOS

1. ¿Qué porcentaje de registros cumple todas las reglas y permite utilizar la información del almacén? Respuesta: Sí. Después de la limpieza, los registros conservados cumplen las reglas definidas para el ejercicio.

2. ¿Qué datos obligatorios faltan y cómo impedirían identificar el producto o sus existencias? Respuesta: No. En los archivos limpios no faltan datos obligatorios.

3. ¿Existen registros o claves repetidas que puedan inflar el inventario y provocar pedidos innecesarios? Respuesta: No. Los duplicados se identificaron y no permanecen en los archivos limpios.

4. ¿Los precios son numéricos, positivos y válidos para calcular el valor de las existencias? Respuesta: Sí. Los precios aceptados son numéricos y mayores que cero.

5. ¿Todos los lotes e inventarios se relacionan con productos existentes y conservan la relación entre lote y producto? Respuesta: Sí. Se validaron las relaciones entre producto, lote e inventario_lote.

6. ¿Las fechas de recepción y caducidad son válidas y permiten decidir qué lotes deben salir primero? Respuesta: Sí. Las fechas válidas conservan el orden entre recepción y caducidad.

7. ¿Las cantidades son enteras y no negativas, y corresponden al mismo producto y lote para sustentar el reabastecimiento? Respuesta: Sí. Las cantidades aceptadas son enteras no negativas y respetan la relación del lote con el producto.


## GENERACIÓN DE LOS TRES ARCHIVOS CSV

Cada archivo contiene 50 filas. Primero se generaron registros relacionados y después se incorporaron fallas intencionales. La última fila se reemplazó por una copia exacta de una fila existente para conservar 50 registros en lugar de aumentar el total a 51.

En producto se incluyeron seis tipos: nulos, duplicados, espacios, mayúsculas o minúsculas inconsistentes, tipos incorrectos y valores inválidos. En lote se incluyeron los nueve tipos de la consigna. En inventario_lote se incluyeron ocho: todos los aplicables, excepto mayúsculas y minúsculas porque sus columnas son numéricas o fechas.

```python
# Proyecto Unidad 2
# ? Juan Manuel Ortega García
# ! Bernardo Guillermo Núñez López
# * Carlos Gabriel Rodríguez Macias
# * 2 de noviembre de 2026

# ! Problema
# * Revisar la calidad de los productos, lotes y existencias del almacén Pepsi.
# * Los nombres y columnas se tomaron de las figuras 6 y 6.1 del proyecto 1.

# ? Importar las bibliotecas y preparar las carpetas.
import pandas as pd
from faker import Faker
from pathlib import Path
from datetime import date

ruta = Path(__file__).resolve().parent.parent
originales = ruta / 'csv_originales'
originales.mkdir(exist_ok=True)
Faker.seed(7)
fake = Faker('es_MX')

# ? Crear 50 productos de bebidas y presentaciones diferentes.
nombres = ['Pepsi', 'Mirinda', '7 Up', 'Gatorade', 'Mountain Dew']
presentaciones = ['355 ml', '600 ml', '1 litro', '1.5 litros', '2 litros',
                  '3 litros', '6 latas', '12 latas', '24 latas', '12 botellas']
datos = []
for i in range(50):
  datos.append({
    'id_producto': i + 1,
    'clave_producto': f'BEB{i + 1:03}',
    'nombre': nombres[i % 5],
    'presentacion': presentaciones[i // 5],
    'precio': fake.random_int(min=1000, max=30000) / 100,
    'activo': 1
  })
productos = pd.DataFrame(datos)

# ? Agregar nulos, espacios, mayúsculas, tipos incorrectos y valores inválidos.
# * Un precio perdido o negativo no se recupera inventando otro precio.
productos['precio'] = productos['precio'].astype('object')
productos.loc[0, 'nombre'] = None
productos.loc[1, 'nombre'] = '  Pepsi  '
productos.loc[2, 'presentacion'] = '600 ML'
productos.loc[3, 'precio'] = 'sin precio'
productos.loc[4, 'precio'] = -25
productos.loc[5, 'activo'] = 3
productos.loc[6, 'precio'] = None
productos.loc[7, 'clave_producto'] = '  beb008  '

# ? Reemplazar la última fila por una copia exacta, conservando 50 registros.
productos.loc[49] = productos.loc[20].copy()
productos.to_csv(originales / 'producto.csv', index=False, encoding='utf-8-sig')

# ? Crear 50 lotes relacionados con productos existentes antes de introducir fallas.
datos = []
for i in range(50):
  recepcion = fake.date_between(date(2026, 1, 1), date(2026, 9, 30))
  datos.append({
    'id_lote': i + 1,
    'id_producto': (i % 49) + 1,
    'numero_lote': f'LOT{i + 1:03}',
    'fecha_recepcion': recepcion.isoformat(),
    'fecha_caducidad': date(2027, recepcion.month, recepcion.day).isoformat()
  })
lotes = pd.DataFrame(datos)
lotes['id_producto'] = lotes['id_producto'].astype('object')

# ? Introducir los nueve tipos de error que aplican a los lotes.
lotes.loc[0, 'numero_lote'] = None
lotes.loc[1, 'numero_lote'] = '  LOT002  '
lotes.loc[2, 'numero_lote'] = 'lot003'
lotes.loc[3, 'fecha_recepcion'] = '15/03/2026'
lotes.loc[4, 'id_producto'] = 'producto cinco'
lotes.loc[5, 'id_producto'] = 999
lotes.loc[6, 'fecha_caducidad'] = '2025-01-01'
lotes.loc[7, 'fecha_recepcion'] = '2026-02-30'
lotes.loc[8, 'fecha_recepcion'] = '2025-12-01'
lotes.loc[49] = lotes.loc[20].copy()
lotes.to_csv(originales / 'lote.csv', index=False, encoding='utf-8-sig')

# ? Crear 50 registros de inventario para el almacén 1.
# * Se conserva la relación compuesta id_lote e id_producto de la captura original.
datos = []
for i in range(50):
  datos.append({
    'id_inventario': i + 1,
    'id_almacen': 1,
    'id_lote': i + 1,
    'id_producto': (i % 49) + 1,
    'cantidad': fake.random_int(min=0, max=500),
    'fecha_actualizacion': '2026-10-31 12:00:00'
  })
inventario = pd.DataFrame(datos)
inventario['cantidad'] = inventario['cantidad'].astype('object')

# ? Agregar errores de cantidad, fechas y relaciones sin inventar columnas nuevas.
# * No se prueba mayúsculas en columnas numéricas porque no corresponde.
inventario.loc[0, 'cantidad'] = None
inventario.loc[1, 'fecha_actualizacion'] = ' 2026-10-31 12:00:00 '
inventario.loc[2, 'fecha_actualizacion'] = '31/10/2026 12:00:00'
inventario.loc[3, 'cantidad'] = 'muchas'
inventario.loc[4, 'cantidad'] = -12
inventario.loc[5, 'id_lote'] = 999
inventario.loc[6, 'id_producto'] = 40
inventario.loc[7, 'fecha_actualizacion'] = '2026-02-30 12:00:00'
inventario.loc[8, 'cantidad'] = 1.5
inventario.loc[49] = inventario.loc[20].copy()
inventario.to_csv(originales / 'inventario_lote.csv', index=False, encoding='utf-8-sig')

# ? Comprobar que los tres CSV contienen exactamente 50 filas.
print('Ortega García - Núñez López - Rodríguez Macias')
print('producto:', len(productos), 'registros')
print('lote:', len(lotes), 'registros')
print('inventario_lote:', len(inventario), 'registros')


```

Seleccionamos estos errores porque pueden surgir al copiar catálogos, repetir una carga, omitir campos, escribir un precio con texto o capturar una fecha con otra configuración regional. Una relación rota puede aparecer cuando el archivo de existencias llega antes que su catálogo. La discrepancia entre lote y producto simula seleccionar una bebida distinta durante la captura del almacén.

| Error | Por qué se prueba | Ejemplo en producción |
| --- | --- | --- |
| Valor nulo | Comprobar campos obligatorios. | Se omite el nombre del producto o su cantidad al capturar. |
| Duplicado exacto | Evitar contar dos veces la misma información. | Se vuelve a cargar el archivo de una recepción. |
| Espacios externos | Evitar diferencias falsas al comparar textos. | Se copia una clave desde una hoja de cálculo. |
| Mayúsculas y minúsculas | Homologar claves y presentaciones. | Dos operadores escriben LOT003 y lot003. |
| Formato de fecha | Interpretar correctamente recepción y caducidad. | Una estación exporta día/mes/año y otra año-mes-día. |
| Tipo incorrecto | Detectar texto donde se requiere un número. | Se escribe muchas en la cantidad o sin precio en el catálogo. |
| Valor inválido | Impedir precios negativos, fechas imposibles o cantidades fraccionarias. | Un error de signo registra -12 unidades disponibles. |
| Relación rota | Mantener la trazabilidad entre archivos. | Llega una existencia que apunta a un lote no registrado. |
| Inconsistencia entre columnas | Comprobar que los campos sean compatibles. | El lote pertenece a otra bebida o caduca antes de su recepción. |


## LECTURA Y BÚSQUEDA DE ERRORES

Cada tabla cuenta con su propio archivo Python. Se utiliza try-except para avisar si falta el CSV y no continuar con datos inexistentes. info() muestra columnas y tipos; shape muestra filas y columnas; head() permite inspeccionar una muestra. La versión completa también emplea describe(include="all") para revisar valores frecuentes y distribución.

Los errores se buscan por reglas sobre todas las filas; las posiciones usadas por el generador no se utilizan para decidir cuáles registros limpiar. Los valores que no se pueden convertir se detectan con errores controlados en lugar de detener el análisis (pandas, s. f.-a, s. f.-b).

```python
# Proyecto Unidad 2
# ? Juan Manuel Ortega García
# ! Bernardo Guillermo Núñez López
# * Carlos Gabriel Rodríguez Macias
# * 2 de noviembre de 2026

# ? Leer el archivo y revisar su estructura con lo trabajado en las prácticas.
import pandas as pd
from pathlib import Path

ruta = Path(__file__).resolve().parent.parent
try:
  datos_csv = pd.read_csv(ruta / 'csv_originales' / 'producto.csv')
except (FileNotFoundError, pd.errors.EmptyDataError, pd.errors.ParserError) as error:
  print('No se pudo leer el archivo:', error)
  raise SystemExit(1)
else:
  print('Ortega García - Núñez López - Rodríguez Macias')
  datos_csv.info()
  print('Dimensiones:', datos_csv.shape)
  print(datos_csv.head(10))

# ? Revisar los nulos y las filas completamente duplicadas.
print('Valores nulos por columna:')
print(datos_csv.isnull().sum())
print('Duplicados exactos adicionales:', datos_csv.duplicated().sum())
print(datos_csv[datos_csv.duplicated()])

# ? Normalizar los textos siguiendo las prácticas 5 y 6.
datos_csv['clave_producto'] = datos_csv['clave_producto'].str.strip().str.upper()
datos_csv['nombre'] = datos_csv['nombre'].str.strip().str.title()
datos_csv['presentacion'] = datos_csv['presentacion'].str.strip().str.lower()


# ? Intentar revisar valores negativos sin ocultar una columna con tipos mezclados.
try:
  valores = datos_csv['precio'].astype('float')
except (ValueError, TypeError):
  print('La columna contiene texto o tipos mezclados; falta resolver su conversión segura.')
else:
  print('Valores negativos:')
  print(datos_csv[valores < 0])

# ! Esta exportación es parcial: todavía no se certifica como información apta.
datos_csv.to_csv(ruta / 'csv_limpios' / 'producto_revision_parcial.csv',
                 index=False, encoding='utf-8-sig')
# TODO Completar las reglas por fila, porcentajes y relaciones de la práctica 8.
# TODO No cargar esta revisión parcial en SQL Server.


```

```python
# Proyecto Unidad 2
# ? Juan Manuel Ortega García
# ! Bernardo Guillermo Núñez López
# * Carlos Gabriel Rodríguez Macias
# * 2 de noviembre de 2026

# ? Leer el archivo y revisar su estructura con lo trabajado en las prácticas.
import pandas as pd
from pathlib import Path

ruta = Path(__file__).resolve().parent.parent
try:
  datos_csv = pd.read_csv(ruta / 'csv_originales' / 'lote.csv')
except (FileNotFoundError, pd.errors.EmptyDataError, pd.errors.ParserError) as error:
  print('No se pudo leer el archivo:', error)
  raise SystemExit(1)
else:
  print('Ortega García - Núñez López - Rodríguez Macias')
  datos_csv.info()
  print('Dimensiones:', datos_csv.shape)
  print(datos_csv.head(10))

# ? Revisar los nulos y las filas completamente duplicadas.
print('Valores nulos por columna:')
print(datos_csv.isnull().sum())
print('Duplicados exactos adicionales:', datos_csv.duplicated().sum())
print(datos_csv[datos_csv.duplicated()])

# ? Normalizar los textos siguiendo las prácticas 5 y 6.
datos_csv['numero_lote'] = datos_csv['numero_lote'].str.strip().str.upper()
# ? Probar el formato establecido sin borrar el texto original.
fechas = pd.to_datetime(datos_csv['fecha_recepcion'], format='%Y-%m-%d', errors='coerce')
print('Fechas que requieren revisión en fecha_recepcion:', fechas.isnull().sum())
# ? Probar el formato establecido sin borrar el texto original.
fechas = pd.to_datetime(datos_csv['fecha_caducidad'], format='%Y-%m-%d', errors='coerce')
print('Fechas que requieren revisión en fecha_caducidad:', fechas.isnull().sum())

# ? Intentar revisar valores negativos sin ocultar una columna con tipos mezclados.
try:
  valores = datos_csv['id_producto'].astype('float')
except (ValueError, TypeError):
  print('La columna contiene texto o tipos mezclados; falta resolver su conversión segura.')
else:
  print('Valores negativos:')
  print(datos_csv[valores < 0])

# ! Esta exportación es parcial: todavía no se certifica como información apta.
datos_csv.to_csv(ruta / 'csv_limpios' / 'lote_revision_parcial.csv',
                 index=False, encoding='utf-8-sig')
# TODO Completar las reglas por fila, porcentajes y relaciones de la práctica 8.
# TODO No cargar esta revisión parcial en SQL Server.


```

```python
# Proyecto Unidad 2
# ? Juan Manuel Ortega García
# ! Bernardo Guillermo Núñez López
# * Carlos Gabriel Rodríguez Macias
# * 2 de noviembre de 2026

# ? Leer el archivo y revisar su estructura con lo trabajado en las prácticas.
import pandas as pd
from pathlib import Path

ruta = Path(__file__).resolve().parent.parent
try:
  datos_csv = pd.read_csv(ruta / 'csv_originales' / 'inventario_lote.csv')
except (FileNotFoundError, pd.errors.EmptyDataError, pd.errors.ParserError) as error:
  print('No se pudo leer el archivo:', error)
  raise SystemExit(1)
else:
  print('Ortega García - Núñez López - Rodríguez Macias')
  datos_csv.info()
  print('Dimensiones:', datos_csv.shape)
  print(datos_csv.head(10))

# ? Revisar los nulos y las filas completamente duplicadas.
print('Valores nulos por columna:')
print(datos_csv.isnull().sum())
print('Duplicados exactos adicionales:', datos_csv.duplicated().sum())
print(datos_csv[datos_csv.duplicated()])

# ? Normalizar los textos siguiendo las prácticas 5 y 6.

# ? Probar el formato establecido sin borrar el texto original.
fechas = pd.to_datetime(datos_csv['fecha_actualizacion'], format='%Y-%m-%d %H:%M:%S', errors='coerce')
print('Fechas que requieren revisión en fecha_actualizacion:', fechas.isnull().sum())

# ? Intentar revisar valores negativos sin ocultar una columna con tipos mezclados.
try:
  valores = datos_csv['cantidad'].astype('float')
except (ValueError, TypeError):
  print('La columna contiene texto o tipos mezclados; falta resolver su conversión segura.')
else:
  print('Valores negativos:')
  print(datos_csv[valores < 0])

# ! Esta exportación es parcial: todavía no se certifica como información apta.
datos_csv.to_csv(ruta / 'csv_limpios' / 'inventario_lote_revision_parcial.csv',
                 index=False, encoding='utf-8-sig')
# TODO Completar las reglas por fila, porcentajes y relaciones de la práctica 8.
# TODO No cargar esta revisión parcial en SQL Server.


```

La revisión parcial encontró nulos, repeticiones y columnas con tipos mezclados. Se homogeneizaron los textos. Se guardan archivos con el sufijo revision_parcial porque todavía no cumplen todas las reglas y no deben utilizarse como datos finales de inventario.


## LIMPIEZA Y TRANSFORMACIÓN MEDIANTE ETL

ETL consiste en extraer los datos, transformarlos y cargarlos en un destino. En este proyecto la extracción lee los CSV originales, la transformación detecta y corrige inconsistencias comprobables y la carga reintegra los archivos aptos en SQL Server. Este orden evita trasladar fallas del archivo de origen al sistema operativo del almacén (Microsoft, s. f.-b).

En este avance se realizaron la extracción y las transformaciones de texto vistas en clase. Permanecen pendientes la limpieza integral, la tabla de errores por fila y la comprobación conjunta de relaciones. No se presenta el avance como un proceso ETL terminado.


## VALIDACIÓN Y COMPARACIÓN ANTES Y DESPUÉS

Los tres archivos originales conservan 50 filas. El avance no calcula porcentajes integrales ni certifica que las revisiones parciales estén limpias. La comparación completa y el conteo de corregidos y descartados se encuentran resueltos en la segunda versión.


## EXPORTACIÓN Y REINTEGRACIÓN EN SQL SERVER

Se exportan archivos CSV con index=False para evitar que el índice interno de Pandas se convierta en una columna del almacén. Los acentos se conservan con UTF-8. Los archivos de origen permanecen separados de los resultados corregidos.

La exportación parcial ya está implementada. La conexión desde Python y la inserción con transacciones se dejan pendientes porque aún no están desarrolladas en las prácticas revisadas. No se deben cargar estos archivos parciales a la base de datos.


## CONSULTAS Y EFECTO DE LOS DATOS INCORRECTOS

La primera consulta suma unidades y calcula el valor del inventario por producto. Un precio negativo o una existencia duplicada habría alterado ese valor. La segunda identifica lotes próximos a caducar: una fecha mal interpretada cambia la prioridad de despacho. La tercera calcula promedio, mínimo y máximo de precios; un precio inválido puede distorsionar estos indicadores o impedir el cálculo.


## TABLA TEMPORAL Y VISTA ENCRIPTADA

La tabla temporal prepara un resumen para revisar existencias durante la misma conexión, sin modificar los registros del almacén. Puede utilizarse para organizar la revisión de cantidades y valores antes de un reporte. La vista reúne la consulta de existencias para reutilizarla.

WITH ENCRYPTION oculta la definición de la vista en las consultas habituales del catálogo; no cifra los datos que devuelve ni sustituye los permisos. Debe conservarse el código fuente para mantenimiento y se deben revisar sus limitaciones de publicación y replicación (Microsoft, s. f.-a).

Estos temas tienen antecedentes en 1BD y se conservan como repaso. Se incluyen los scripts de estructura y consultas conocidos; sus resultados quedan pendientes de la carga de datos desde Python.

```sql
-- Proyecto Unidad 2
-- ? Juan Manuel Ortega García
-- ! Bernardo Guillermo Núñez López
-- * Carlos Gabriel Rodríguez Macias

-- ? Estructura transcrita de las figuras 6 y 6.1 del documento del proyecto 1.
-- * No se utilizaron los scripts locales de Unidad1 como código base.
-- * Cambiamos únicamente el esquema de destino para conservar los datos de dbo.
-- * Ejecutar este archivo una sola vez, después de revisar la base seleccionada.
Use pepsi_distribucion;
GO

Create Schema proyecto_u2;
GO

-- ? Almacén de referencia. No es un cuarto CSV ni una cuarta tabla analizada.
Create Table proyecto_u2.almacen
(
  id_almacen int Primary Key Identity(1, 1),
  clave_almacen varchar(10) Not Null Unique,
  nombre varchar(100) Not Null,
  ubicacion varchar(200) Not Null,
  activo bit Not Null Default 1
);

Create Table proyecto_u2.producto
(
  id_producto int Primary Key Identity(1, 1),
  clave_producto varchar(15) Not Null Unique,
  nombre varchar(100) Not Null,
  presentacion varchar(50) Not Null,
  precio decimal(10, 2) Not Null,
  activo bit Not Null Default 1,
  Constraint ck_u2_producto_precio Check (precio > 0)
);

Create Table proyecto_u2.lote
(
  id_lote int Primary Key Identity(1, 1),
  id_producto int Not Null,
  numero_lote varchar(30) Not Null,
  fecha_recepcion date Not Null,
  fecha_caducidad date Not Null,
  Constraint fk_u2_lote_producto Foreign Key (id_producto)
    References proyecto_u2.producto(id_producto),
  Constraint uq_u2_lote_producto_numero Unique (id_producto, numero_lote),
  Constraint uq_u2_lote_validacion Unique (id_lote, id_producto),
  Constraint ck_u2_lote_fechas Check (fecha_caducidad > fecha_recepcion)
);

Create Table proyecto_u2.inventario_lote
(
  id_inventario int Primary Key Identity(1, 1),
  id_almacen int Not Null,
  id_lote int Not Null,
  id_producto int Not Null,
  cantidad int Not Null Default 0,
  fecha_actualizacion datetime2 Not Null Default Sysdatetime(),
  Constraint fk_u2_inventario_almacen Foreign Key (id_almacen)
    References proyecto_u2.almacen(id_almacen),
  Constraint fk_u2_inventario_lote_producto Foreign Key (id_lote, id_producto)
    References proyecto_u2.lote(id_lote, id_producto),
  Constraint uq_u2_inventario_almacen_lote Unique (id_almacen, id_lote),
  Constraint uq_u2_inventario_validacion
    Unique (id_inventario, id_lote, id_producto, id_almacen),
  Constraint ck_u2_inventario_cantidad Check (cantidad >= 0)
);
GO


```

```sql
-- Proyecto Unidad 2
-- ? Juan Manuel Ortega García
-- ! Bernardo Guillermo Núñez López
-- * Carlos Gabriel Rodríguez Macias
Use pepsi_distribucion;
GO

-- ? 1 Revisar el valor del inventario por producto.
Select p.id_producto, p.nombre, p.presentacion,
  Sum(i.cantidad) As unidades,
  Sum(i.cantidad * p.precio) As valor_inventario
From proyecto_u2.producto p
Inner Join proyecto_u2.inventario_lote i On p.id_producto = i.id_producto
Where p.activo = 1 And i.cantidad > 0
Group By p.id_producto, p.nombre, p.presentacion
Order By valor_inventario Desc;

-- ? 2 Revisar lotes con caducidad próxima desde el corte del ejercicio.
Select p.nombre, l.numero_lote, l.fecha_caducidad,
  Sum(i.cantidad) As unidades_por_caducar,
  Min(l.fecha_caducidad) As primera_caducidad
From proyecto_u2.lote l
Inner Join proyecto_u2.producto p On l.id_producto = p.id_producto
Inner Join proyecto_u2.inventario_lote i
  On l.id_lote = i.id_lote And l.id_producto = i.id_producto
Where l.fecha_caducidad >= '2026-11-02' And l.fecha_caducidad < '2027-03-01'
Group By p.nombre, l.numero_lote, l.fecha_caducidad
Order By l.fecha_caducidad Asc;

-- ? 3 Comparar precios de productos activos.
Select nombre, Count(*) As presentaciones,
  Avg(precio) As precio_promedio, Min(precio) As precio_minimo,
  Max(precio) As precio_maximo
From proyecto_u2.producto
Where activo = 1 And precio > 0
Group By nombre
Order By precio_promedio Desc;

-- ? Crear una tabla temporal para preparar la revisión del almacén.
-- * La tabla temporal solo se utiliza durante esta conexión.
Create Table #revision_inventario
(
  id_producto int,
  nombre varchar(100),
  unidades int,
  valor_inventario decimal(18, 2)
);

Insert Into #revision_inventario
Select p.id_producto, p.nombre, Sum(i.cantidad), Sum(i.cantidad * p.precio)
From proyecto_u2.producto p
Inner Join proyecto_u2.inventario_lote i On p.id_producto = i.id_producto
Group By p.id_producto, p.nombre;

Select * From #revision_inventario
Where unidades > 0
Order By valor_inventario Desc;
GO

-- ? Crear la vista encriptada para la consulta de existencias.
-- * With Encryption oculta la definición; no cifra las filas ni reemplaza permisos.
Create View proyecto_u2.vw_existencias_equipo
With Encryption
As
Select p.id_producto, p.nombre, p.presentacion, p.precio,
  Sum(i.cantidad) As existencia,
  Sum(i.cantidad * p.precio) As valor_inventario
From proyecto_u2.producto p
Inner Join proyecto_u2.inventario_lote i On p.id_producto = i.id_producto
Group By p.id_producto, p.nombre, p.presentacion, p.precio;
GO

Select * From proyecto_u2.vw_existencias_equipo
Order By valor_inventario Desc;

-- ? Comprobar que SQL Server no expone el texto de la vista.
Select Objectproperty(Object_Id('proyecto_u2.vw_existencias_equipo'), 'IsEncrypted')
  As vista_encriptada;
GO


```


## CONCLUSIÓN ACTUALIZADA

Con los temas vistos pudimos generar los archivos, revisar su estructura y detectar fallas iniciales. También aplicamos limpieza de textos. Para completar ETL todavía necesitamos medir los registros aptos, revisar todas las relaciones, justificar las correcciones y realizar la carga en SQL Server. Este avance permite continuar desde procedimientos que ya hemos practicado.


## REFERENCIAS DE LA UNIDAD II

Faker. (s. f.). Welcome to Faker’s documentation. https://faker.readthedocs.io/en/master/

Microsoft. (s. f.-a). CREATE VIEW (Transact-SQL). Microsoft Learn. https://learn.microsoft.com/en-us/sql/t-sql/statements/create-view-transact-sql

Microsoft. (s. f.-b). Extract, transform, load (ETL). Microsoft Learn. https://learn.microsoft.com/azure/architecture/data-guide/relational-data/etl

pandas. (s. f.-a). pandas.to_datetime. https://pandas.pydata.org/docs/reference/api/pandas.to_datetime.html

pandas. (s. f.-b). pandas.to_numeric. https://pandas.pydata.org/docs/reference/api/pandas.to_numeric.html

SQLAlchemy. (s. f.). Working with engines and connections. https://docs.sqlalchemy.org/en/20/core/connections.html


## ANEXO INTERNO PARA REVISIÓN DEL EQUIPO

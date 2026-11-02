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


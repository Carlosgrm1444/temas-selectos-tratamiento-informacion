# Proyecto Unidad 2
# ? Juan Manuel Ortega García
# ! Bernardo Guillermo Núñez López
# * Carlos Gabriel Rodríguez Macias
# * 2 de noviembre de 2026

# ? Importar el CSV y controlar la ausencia del archivo o de sus referencias.
import pandas as pd
from pathlib import Path

ruta = Path(__file__).resolve().parent.parent
try:
  datos_csv = pd.read_csv(ruta / 'csv_originales' / 'producto.csv', dtype='string')
except (FileNotFoundError, pd.errors.EmptyDataError, pd.errors.ParserError) as error:
  print('No se pudo leer el archivo:', error)
  raise SystemExit(1)

# ? Mostrar la estructura, dimensiones y estadísticas antes de limpiar.
print('Ortega García - Núñez López - Rodríguez Macias')
datos_csv.info()
print('Dimensiones:', datos_csv.shape)
print(datos_csv.describe(include='all'))

# ? Buscar errores por reglas generales, sin usar las posiciones de las fallas.
# * Esta función se ejecuta antes y después con las mismas reglas.
def validar(datos):
  errores = pd.DataFrame(index=datos.index)
  for columna in datos.columns:
    errores[columna + '_nulo'] = datos[columna].isna() | datos[columna].str.strip().eq('').fillna(False)
    errores[columna + '_espacios'] = datos[columna].ne(datos[columna].str.strip()).fillna(False)
  errores['duplicado_exacto'] = datos.duplicated(keep=False)
  errores['clave_primaria_repetida'] = datos.duplicated(subset=['id_producto'], keep=False)
  numeros = {}
  fechas = {}
  numeros['id_producto'] = pd.to_numeric(datos['id_producto'], errors='coerce')
  errores['id_producto_tipo'] = numeros['id_producto'].isna() | numeros['id_producto'].isin([float('inf'), -float('inf')])
  numeros['precio'] = pd.to_numeric(datos['precio'], errors='coerce')
  errores['precio_tipo'] = numeros['precio'].isna() | numeros['precio'].isin([float('inf'), -float('inf')])
  numeros['activo'] = pd.to_numeric(datos['activo'], errors='coerce')
  errores['activo_tipo'] = numeros['activo'].isna() | numeros['activo'].isin([float('inf'), -float('inf')])
  errores['clave_producto_formato'] = datos['clave_producto'].ne(datos['clave_producto'].str.strip().str.upper()).fillna(False)
  errores['nombre_formato'] = datos['nombre'].ne(datos['nombre'].str.strip().str.title()).fillna(False)
  errores['presentacion_formato'] = datos['presentacion'].ne(datos['presentacion'].str.strip().str.lower()).fillna(False)
  errores['clave_producto_longitud'] = datos['clave_producto'].str.len().gt(15).fillna(False)
  errores['nombre_longitud'] = datos['nombre'].str.len().gt(100).fillna(False)
  errores['presentacion_longitud'] = datos['presentacion'].str.len().gt(50).fillna(False)
  errores['clave_negocio_1_repetida'] = datos.duplicated(subset=['clave_producto'], keep=False)

  errores['id_producto_invalido'] = ~numeros['id_producto'].between(1, 2147483647) | numeros['id_producto'].mod(1).ne(0)
  errores['precio_invalido'] = ~numeros['precio'].between(0.01, 99999999.99)
  errores['precio_decimales'] = numeros['precio'].sub(numeros['precio'].round(2)).abs().gt(0.000001)
  errores['activo_invalido'] = ~numeros['activo'].isin([0, 1])
  return errores.fillna(False)

# ? Contar filas aptas una sola vez aunque tengan varios errores.
antes = validar(datos_csv)
no_aptos = antes.any(axis=1)
print('Errores por regla:')
print(antes.sum())
print('Filas afectadas:')
print(datos_csv.loc[no_aptos].to_string(index=False))
original = datos_csv.copy()

# ? Normalizar texto y conservar el original para comparar los cambios.
limpios = datos_csv.copy()
for columna in limpios.columns:
  limpios[columna] = limpios[columna].str.strip()
limpios['clave_producto'] = limpios['clave_producto'].str.upper()
limpios['nombre'] = limpios['nombre'].str.title()
limpios['presentacion'] = limpios['presentacion'].str.lower()


# ? Retirar únicamente las repeticiones exactas y separar filas sin solución comprobable.
limpios = limpios.drop_duplicates(keep='first').copy()
pendientes = validar(limpios).any(axis=1)
limpios = limpios.loc[~pendientes].copy()
despues = validar(limpios)
if despues.any(axis=1).any():
  raise ValueError('Todavía existen errores; no se exportará como archivo limpio.')

# ? Registrar conservados, corregidos y descartados sin contar una fila dos veces.
conservados = len(limpios)
descartados = len(original) - conservados
modificados = original.loc[limpios.index].fillna('').ne(limpios.fillna('')).any(axis=1)
corregidos = int(modificados.sum())
sin_cambios = conservados - corregidos
resumen = pd.DataFrame([{
  'archivo': 'producto', 'iniciales': len(original),
  'aptos_antes': int((~no_aptos).sum()), 'no_aptos_antes': int(no_aptos.sum()),
  'porcentaje_apto_antes': round((~no_aptos).mean() * 100, 2),
  'porcentaje_no_apto_antes': round(no_aptos.mean() * 100, 2),
  'conservados': conservados, 'corregidos': corregidos,
  'sin_cambios': sin_cambios, 'descartados': descartados,
  'aptos_despues': conservados, 'no_aptos_despues': 0,
  'porcentaje_apto_despues': 100.0 if conservados else 0.0,
  'porcentaje_no_apto_despues': 0.0
}])
print('Resumen de calidad:')
for columna, valor in resumen.iloc[0].items():
  print(f'{columna}: {valor}')

# ? Guardar los hallazgos por fila y los archivos listos para SQL Server.
hallazgos = antes.copy()
hallazgos.insert(0, 'fila_csv', original.index + 2)
hallazgos.to_csv(ruta / 'resultados' / 'producto_errores.csv', index=False)
descartes = original.loc[~original.index.isin(limpios.index)].copy()
descartes.insert(0, 'fila_csv', descartes.index + 2)
descartes.to_csv(ruta / 'resultados' / 'producto_descartados.csv', index=False)
resumen.to_csv(ruta / 'resultados' / 'producto_resumen.csv', index=False)
for columna in ['id_producto','activo']:
  limpios[columna] = pd.to_numeric(limpios[columna]).astype('int64')
limpios['precio'] = pd.to_numeric(limpios['precio']).round(2)
limpios.to_csv(ruta / 'csv_limpios' / 'producto.csv', index=False, encoding='utf-8-sig')
print('Validación final: 0 filas no aptas.')


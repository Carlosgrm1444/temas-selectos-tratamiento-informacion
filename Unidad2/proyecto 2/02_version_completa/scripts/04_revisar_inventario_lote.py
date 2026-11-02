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
  datos_csv = pd.read_csv(ruta / 'csv_originales' / 'inventario_lote.csv', dtype='string')
  productos = pd.read_csv(ruta / 'csv_limpios' / 'producto.csv')
  lotes = pd.read_csv(ruta / 'csv_limpios' / 'lote.csv')
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
  errores['clave_primaria_repetida'] = datos.duplicated(subset=['id_inventario'], keep=False)
  numeros = {}
  fechas = {}
  numeros['id_inventario'] = pd.to_numeric(datos['id_inventario'], errors='coerce')
  errores['id_inventario_tipo'] = numeros['id_inventario'].isna() | numeros['id_inventario'].isin([float('inf'), -float('inf')])
  numeros['id_almacen'] = pd.to_numeric(datos['id_almacen'], errors='coerce')
  errores['id_almacen_tipo'] = numeros['id_almacen'].isna() | numeros['id_almacen'].isin([float('inf'), -float('inf')])
  numeros['id_lote'] = pd.to_numeric(datos['id_lote'], errors='coerce')
  errores['id_lote_tipo'] = numeros['id_lote'].isna() | numeros['id_lote'].isin([float('inf'), -float('inf')])
  numeros['id_producto'] = pd.to_numeric(datos['id_producto'], errors='coerce')
  errores['id_producto_tipo'] = numeros['id_producto'].isna() | numeros['id_producto'].isin([float('inf'), -float('inf')])
  numeros['cantidad'] = pd.to_numeric(datos['cantidad'], errors='coerce')
  errores['cantidad_tipo'] = numeros['cantidad'].isna() | numeros['cantidad'].isin([float('inf'), -float('inf')])


  errores['clave_negocio_1_repetida'] = datos.duplicated(subset=['id_almacen','id_lote'], keep=False)
  fechas['fecha_actualizacion'] = pd.to_datetime(datos['fecha_actualizacion'], format='%Y-%m-%d %H:%M:%S', errors='coerce')
  errores['fecha_actualizacion_invalida'] = fechas['fecha_actualizacion'].isna()
  errores['fecha_actualizacion_formato'] = datos['fecha_actualizacion'].ne(fechas['fecha_actualizacion'].dt.strftime('%Y-%m-%d %H:%M:%S')).fillna(True)
  for columna in ['id_inventario', 'id_almacen', 'id_lote', 'id_producto']:
    errores[columna + '_invalido'] = ~numeros[columna].between(1, 2147483647) | numeros[columna].mod(1).ne(0)
  errores['cantidad_invalida'] = ~numeros['cantidad'].between(0, 2147483647) | numeros['cantidad'].mod(1).ne(0)
  errores['almacen_inexistente'] = ~numeros['id_almacen'].isin([1])
  errores['producto_inexistente'] = ~numeros['id_producto'].isin(productos['id_producto'])
  errores['lote_inexistente'] = ~numeros['id_lote'].isin(lotes['id_lote'])
  producto_por_lote = lotes.set_index('id_lote')['id_producto']
  errores['producto_no_corresponde_lote'] = numeros['id_producto'].ne(numeros['id_lote'].map(producto_por_lote))
  errores['actualizacion_fuera_periodo'] = ~fechas['fecha_actualizacion'].between('2026-01-01', '2026-11-02 23:59:59')
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

# * Aceptar dos formatos conocidos sin adivinar el orden de día y mes.
fechas = pd.to_datetime(limpios['fecha_actualizacion'], format='%Y-%m-%d %H:%M:%S', errors='coerce')
alternativas = pd.to_datetime(limpios['fecha_actualizacion'], format='%d/%m/%Y %H:%M:%S', errors='coerce')
limpios['fecha_actualizacion'] = fechas.fillna(alternativas).dt.strftime('%Y-%m-%d %H:%M:%S').astype('string')

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
  'archivo': 'inventario_lote', 'iniciales': len(original),
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
hallazgos.to_csv(ruta / 'resultados' / 'inventario_lote_errores.csv', index=False)
descartes = original.loc[~original.index.isin(limpios.index)].copy()
descartes.insert(0, 'fila_csv', descartes.index + 2)
descartes.to_csv(ruta / 'resultados' / 'inventario_lote_descartados.csv', index=False)
resumen.to_csv(ruta / 'resultados' / 'inventario_lote_resumen.csv', index=False)
for columna in ['id_inventario','id_almacen','id_lote','id_producto','cantidad']:
  limpios[columna] = pd.to_numeric(limpios[columna]).astype('int64')
limpios.to_csv(ruta / 'csv_limpios' / 'inventario_lote.csv', index=False, encoding='utf-8-sig')
print('Validación final: 0 filas no aptas.')


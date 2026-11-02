"""Ejecutar las dos versiones y conservar resultados reales del proyecto."""
from pathlib import Path
import ast
import importlib.metadata
import json
import subprocess
import sys
import pandas as pd

ruta = Path(__file__).resolve().parent.parent
for version in ['01_version_actual', '02_version_completa']:
  carpeta = ruta / version
  for archivo in sorted((carpeta / 'scripts').glob('*.py')):
    ast.parse(archivo.read_text(), filename=str(archivo))
    if archivo.name.startswith('05_'):
      continue
    resultado = subprocess.run([sys.executable, str(archivo)], capture_output=True, text=True)
    (carpeta / 'resultados' / (archivo.stem + '.txt')).write_text(
      resultado.stdout + resultado.stderr, encoding='utf-8')
    if resultado.returncode:
      raise RuntimeError(archivo.name + '\n' + resultado.stderr)
    print(version, archivo.name, 'correcto')
  for tabla in ['producto', 'lote', 'inventario_lote']:
    datos = pd.read_csv(carpeta / 'csv_originales' / (tabla + '.csv'))
    assert len(datos) == 50, 'Cada archivo debe tener exactamente 50 registros.'

carpeta = ruta / '02_version_completa'
resumen = pd.concat([pd.read_csv(carpeta / 'resultados' / (t + '_resumen.csv'))
                     for t in ['producto', 'lote', 'inventario_lote']], ignore_index=True)
assert (resumen['conservados'] + resumen['descartados'] == 50).all()
assert (resumen['corregidos'] + resumen['sin_cambios'] == resumen['conservados']).all()
assert (resumen['no_aptos_despues'] == 0).all()
resumen.to_csv(carpeta / 'resultados' / 'comparacion_antes_despues.csv', index=False)
productos = pd.read_csv(carpeta / 'csv_limpios/producto.csv')
lotes = pd.read_csv(carpeta / 'csv_limpios/lote.csv')
inventario = pd.read_csv(carpeta / 'csv_limpios/inventario_lote.csv')
assert lotes.id_producto.isin(productos.id_producto).all()
assert inventario.id_lote.isin(lotes.id_lote).all()
assert inventario.id_producto.eq(inventario.id_lote.map(lotes.set_index('id_lote').id_producto)).all()
assert inventario.cantidad.ge(0).all() and inventario.cantidad.mod(1).eq(0).all()

# Guardar versiones para que la semilla pueda reproducirse en el mismo entorno.
versiones = {n: importlib.metadata.version(n) for n in ['pandas', 'Faker', 'pyodbc', 'SQLAlchemy']}
(ruta / 'referencias/entorno_comprobado.json').write_text(json.dumps(versiones, indent=2))
print(resumen.to_string(index=False))
print('Integridad de los tres archivos limpios comprobada. SQL Server: pendiente de ejecución autenticada.')

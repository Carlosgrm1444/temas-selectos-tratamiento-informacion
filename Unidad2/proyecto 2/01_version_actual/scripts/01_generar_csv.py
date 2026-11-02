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


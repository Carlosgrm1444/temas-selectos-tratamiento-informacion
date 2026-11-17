# Proyecto Unidad 2
# ? Juan Manuel Ortega García
# ! Bernardo Guillermo Núñez López
# * Carlos Gabriel Rodríguez Macias

# ? Usar SQLAlchemy y el controlador de SQL Server disponible en Linux.
from pathlib import Path
from getpass import getpass
from decimal import Decimal
import os
import pandas as pd
import pyodbc
from sqlalchemy import create_engine, URL, text
from sqlalchemy.exc import SQLAlchemyError

ruta = Path(__file__).resolve().parent.parent
print('Ortega García - Núñez López - Rodríguez Macias')
print('Controladores disponibles:', pyodbc.drivers())
servidor = os.getenv('SQLSERVER_HOST', 'localhost,1433')
base_datos = os.getenv('SQLSERVER_DATABASE', 'pepsi_distribucion')
usuario = input('Usuario de SQL Server: ')
contrasena = getpass('Contraseña de SQL Server: ')

# * En Linux no se supone una sesión integrada de Windows.
url = URL.create(
  'mssql+pyodbc', username=usuario, password=contrasena,
  host=servidor.split(',')[0], port=int(servidor.split(',')[1]) if ',' in servidor else 1433,
  database=base_datos,
  query={'driver': 'ODBC Driver 18 for SQL Server',
         'Encrypt': 'yes', 'TrustServerCertificate': 'yes'}
)
# * TrustServerCertificate se usa solo en esta instancia local académica.
motor = create_engine(url)

# ? Cargar las referencias antes de las tablas dependientes en una transacción.
try:
  with motor.begin() as conexion:
    for tabla in ['producto', 'lote', 'inventario_lote', 'almacen']:
      cantidad = conexion.execute(text(f'Select Count(*) From proyecto_u2.{tabla}')).scalar_one()
      if cantidad != 0:
        raise ValueError('El destino ya contiene datos. No se duplicará la carga.')
    conexion.execute(text('Set Identity_Insert proyecto_u2.almacen On'))
    conexion.execute(text(
      "Insert Into proyecto_u2.almacen "
      "(id_almacen, clave_almacen, nombre, ubicacion, activo) "
      "Values (1, 'ALM001', 'Almacén Nuevo Laredo', 'Nuevo Laredo, Tamaulipas', 1)"
    ))
    conexion.execute(text('Set Identity_Insert proyecto_u2.almacen Off'))
    for tabla in ['producto', 'lote', 'inventario_lote']:
      datos = pd.read_csv(ruta / 'csv_limpios' / f'{tabla}.csv')
      if datos.empty or datos.isnull().any().any():
        raise ValueError(f'El archivo {tabla} está vacío o contiene nulos.')
      if tabla == 'producto':
        datos['precio'] = datos['precio'].apply(lambda valor: Decimal(str(valor)))
      columnas = ', '.join(datos.columns)
      parametros = ', '.join(':' + columna for columna in datos.columns)
      instruccion = text(f'Insert Into proyecto_u2.{tabla} ({columnas}) Values ({parametros})')
      conexion.execute(text(f'Set Identity_Insert proyecto_u2.{tabla} On'))
      conexion.execute(instruccion, datos.to_dict(orient='records'))
      conexion.execute(text(f'Set Identity_Insert proyecto_u2.{tabla} Off'))
      print(tabla, ':', len(datos), 'filas insertadas dentro de la transacción.')
  print('Transacción confirmada: carga completa en SQL Server.')
except (SQLAlchemyError, ValueError, FileNotFoundError) as error:
  print('La carga no se confirmó:', error)
  raise SystemExit(1)
finally:
  motor.dispose()


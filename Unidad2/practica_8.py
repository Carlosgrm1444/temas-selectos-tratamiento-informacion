# practica 8
# ? Carlos Gabriel Rodriguez Macias
# ! Athala Dulce Edith Gómez Arellano
# * 27 de Octubre del 2026

# ! Problema
# * TechStore necesita conocer sus ingresos por producto y decidir qué artículos 
# * debe reabastecer. El personal ha detectado diferencias en los reportes, pero 
# * desconoce su origen y alcance. Antes de utilizar la información, solicita 
# * revisar las ventas, comprobar su relación con el catálogo y determinar qué 
# * registros son confiables.

# * Se trabajará con este catálogo:
  # * 1	Teclado	350.00
  # * 2	Mouse	200.00
  # * 3	Monitor	3500.00
  # * 4	Memoria USB	180.00
  # * 5	Cámara web	750.00
  # * 6	Audífonos	600.00
# * El archivo de ventas contendrá: id_venta, id_producto, vendedor, cantidad, 
# * precio_unitario, subtotal, fecha_venta


# ! Instrucciones
# ? Crea el archivo practica8, incluye tu nombre completo como comentario, 
# ? importa pandas, faker, configura faker para español México,
# ? establece un seed(7)

from datetime import date

import pandas as pd
import pyodbc as oc
from faker import Faker
from sqlalchemy import URL, create_engine
from sqlalchemy.exc import SQLAlchemyError

# print(oc.drivers())
fake = Faker("es_Mx")
Faker.seed(7)


# ? Crea el DataFrame de productos 

productos = pd.DataFrame(
  {
    "id_producto" : [1, 2, 3, 4, 5, 6],
    "producto" : ["Teclado", "Mouse", "Monitor", "Memoria USB", "Camara web", "Audifonos"],
    "Precio" : [350.00, 200.00, 3500.00, 180.00, 750.00, 600.00]
  }
)

# ? Crea 50 ventas y convierte la lista en un DataFrame, no olvides emplear un ciclo for:
# ? Crea una variable id_producto con un valor random entero entre 1 y 6
# ? Crea una variable de precio  donde dentro de productos filtres aquellos que 
# ? son igual al id_producto y que nos regrese el precio_referencia (emplea el .iloc[0])
# ? Crea una variable cantidad, donde le valor random debe ser entre 1 y 10
# ? Las fechas deben ser de diciembre 2025 a septiembre 2026 (importa date)

datos_ventas = []
fecha_inicio = date(2025, 12, 31)
fecha_final = date(2026, 9, 30)

for i in range(0, 50):
  id_producto = fake.random_int(min = 1, max = 6)
  # loc sirve para filtrar, regresa valor
  precio = productos.loc[productos["id_producto"] == id_producto, "Precio"].iloc[0]
  print(precio)
  cantidad = fake.random_int(min = 1, max = 10)
  
  subtotal = cantidad * precio
  
  datos_ventas.append(
    {
      "id_venta" : i + 1,
      "id_producto" : id_producto,
      "precio_unitario" : precio,
      "cantidad" : cantidad,
      "subtotal" : subtotal,
      "fecha_venta" : fake.date_between(start_date = fecha_inicio, end_date = fecha_final)
    }
  )

ventas = pd.DataFrame(datos_ventas)

# ? La posición 5 y 6 la cantidad será negativa (fuera del ciclo)
ventas.loc[5, "cantidad"] *= -1
ventas.loc[6, "cantidad"] *= -1

# ? La posición 1 de id_producto sera 999 (fuera del ciclo)
ventas.loc[1, "id_producto"] = 999

# ? La posición 2 la cantidad será -5 y id_producto 8 (fuera del ciclo)
ventas.loc[2, "cantidad"] = -5
ventas.loc[2, "id_producto"] = 8

# Duplica la fila 10 (fuera del ciclo), no olvides emplear .concat() y el .copy() y que ignore los indices
ventas = pd.concat([ventas,ventas.iloc[[10]]].copy(), ignore_index=True)

# Guarda el archivo sin el índice de pandas, con la codificación de utf8 con el nombre Ventas_Originales_tu_primer_apellido.csv, ejemplo: Ventas_Originales_gomez.csv
ventas.to_csv("Unidad2/ventas_originales_rodriguez.csv",encoding='utf-8', index=False)


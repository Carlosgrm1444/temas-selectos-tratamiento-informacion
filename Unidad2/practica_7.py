# Practica 7
# ? Athala Dulce Edith Gómez Arellano
# ! Carlos Gabriel Rodriguez Macias
# * 20 de Octubre de 2026

# ! Problema:
# * La empresa Sigma Alimentos distribuye alimentos perecederos a supermercados en todo el país.
# * El departamento de tecnologías de información necesita realizar pruebas sobre la calidad de los
# * datos que recibe su sistema. Para ello, solicita desarrollar un programa en Python capaz de
# * generar un archivo CSV que simule los envíos realizados por la empresa.

# ? 1 Crea el archivo practica7.py.
# * Listo jijiji

# ? 2 Importa las bibliotecas pandas y Faker.
import pandas as pd
from datetime import date
from pathlib import Path
from faker import Faker

# ? 3 Investiga para que sirve el método seed() de Faker.
# * El método seed() sirve para que Faker genere los mismos datos aleatorios cada vez que se ejecuta
# * el programa. Esto permite repetir las pruebas con los mismos registros.
Faker.seed(7)
fake = Faker('es_MX')

# ? 4 Crea una lista llamada productos con 7 productos, en donde uno tenga espacios al inicio y final.
productos = [' manzana ', 'naranja', 'plátano', 'pera', 'uva', 'mango', 'sandía']

# ? 5 Crea una lista llamada datos.
datos = []

# ? 6 Investiga para que sirve el método date_between().
# * El método date_between() genera una fecha aleatoria entre una fecha inicial y una fecha final.
fecha_inicio = date(2026, 1, 1)
fecha_fin = date(2026, 10, 20)

# ? 7 Crea un ciclo for con 40 registros que contengan los datos de los envíos.
for i in range(40):
    cantidad = fake.random_int(min=1, max=100)
    precio = round(fake.pyfloat(min_value=10, max_value=500, right_digits=2, positive=True), 2)

    datos.append({
        'id_cliente': i + 1,
        'estado': fake.state(),
        'producto': fake.random_element(elements=productos),
        'cantidad': cantidad,
        'precio_unitario': precio,
        'subtotal': round(cantidad * precio, 2),
        'fecha_envio': fake.date_between(start_date=fecha_inicio, end_date=fecha_fin)
    })

# ? 8 Convierte la lista en DataFrame.
datos_csv = pd.DataFrame(datos)

# ? 9 Imprime la cantidad de registros que existen en el DataFrame.
print('Cantidad de registros:', len(datos_csv))

# ? 10 Provoca el error de nulo en la posición 0 de la columna producto.
datos_csv.loc[0, 'producto'] = None

# ? 11 Convierte el producto de la posición 1 en mayúsculas.
datos_csv.loc[1, 'producto'] = datos_csv.loc[1, 'producto'].upper()

# ? 12 Convierte el producto de la posición 2 en minúsculas.
datos_csv.loc[2, 'producto'] = datos_csv.loc[2, 'producto'].lower()

# ? 13 Cambia la fecha de la posición 3 a un formato inconsistente.
fecha_diferente = pd.to_datetime(datos_csv.loc[3, 'fecha_envio'])
datos_csv.loc[3, 'fecha_envio'] = fecha_diferente.strftime('%d-%m-%Y')

# ? 14 Convierte el tipo de dato de la columna precio_unitario a objeto.
datos_csv['precio_unitario'] = datos_csv['precio_unitario'].astype('object')

# ? 15 Convierte el subtotal de la posición 5 en un valor negativo.
datos_csv.loc[5, 'subtotal'] = -abs(datos_csv.loc[5, 'subtotal'])

# ? 16 Duplica completamente el registro de la posición 6.
datos_csv = pd.concat([datos_csv, datos_csv.loc[[6]]], ignore_index=True)

# ? 17 Imprime para validar que existen datos duplicados.
print('Registros duplicados:', datos_csv.duplicated().sum())

# ? 18 Imprime para validar si existen datos negativos.
print('Registros con subtotal negativo:')
print(datos_csv[datos_csv['subtotal'] < 0])

# ? 19 Imprime si hay valores nulos en las columnas.
print('Valores nulos por columna:')
print(datos_csv.isnull().sum())

# ? 20 Imprime los primeros 10 registros.
print('Primeros 10 registros:')
print(datos_csv.head(10))

# ? 21 Crea el archivo CSV.
ruta_csv = Path(__file__).with_name('practica7.csv')
datos_csv.to_csv(ruta_csv, index=False, encoding='utf-8-sig')
print('Archivo CSV creado:', ruta_csv.name)

# Practica 6
# ? Athala Dulce Edith Gómez Arellano
# ! Carlos Gabriel Rodriguez Macias
# * 15 de Octubre de 2026

# ? 1 Crea el archivo practica6.py.
# * Listo jijiji

# ? 2 Importa las bibliotecas pandas y Faker. Configura Faker para generar datos de México (es_MX).
import pandas as pd
from pathlib import Path
from faker import Faker

fake = Faker('es_MX')

# ? 3 Emplea el control de errores try-except-else:
# ? Crea una variable llamada datos_csv y lee el archivo Datos_Ventas_Tienda.csv.
# ? Emplea el error FileNotFoundError y muestra el mensaje: "El archivo no se encuentra en la ruta especificada".
# ? Utiliza else para mostrar la información general del DataFrame.
try:
    datos_csv = pd.read_csv(Path("Datos_Ventas_Tienda.csv"), encoding='utf-8')
except FileNotFoundError:
    print("El archivo no se encuentra en la ruta especificada")
else:
    print(datos_csv.info())

# ? 4 Convierte la columna Fecha del archivo CSV al formato día-mes-año (dd-mm-aaaa) y 
# ? muestra los resultados. Emplea errors="coerce" para controlar las fechas incorrectas.
datos_csv['Fecha'] = pd.to_datetime(datos_csv['Fecha'], format='%m/%d/%Y', errors='coerce').dt.strftime('%d-%m-%Y')
print(datos_csv['Fecha'])

# ? 5 Filtra los registros del archivo CSV donde el Precio Unitario sea diferente de 200. 
# ? Guarda los resultados en una variable llamada filtro y muestra los registros obtenidos.
filtro = datos_csv[datos_csv['Precio Unitario'] != 200]
print(filtro)

# ? 6 Utiliza Faker para generar y mostrar los siguientes datos:
# ? Un nombre aleatorio.
# ? Una palabra aleatoria.
# ? Una oración aleatoria.
print(fake.name())
print(fake.word())
print(fake.sentence())

# ? 7 Genera un número entero aleatorio que se encuentre entre 18 y 65, utilizando Faker.
print(fake.random_int(min=18, max=65))

# ? 8 Crea una lista llamada estado_civil que contenga los valores: Casado, Soltero, Divorciado y Viudo.
estado_civil = ['Casado', 'Soltero', 'Divorciado', 'Viudo']
print(estado_civil)

# ? 9 Utiliza Faker para seleccionar aleatoriamente un elemento de la lista estado_civil. Permite 
# ? que los valores puedan repetirse y muestra el resultado.
estado_random = fake.random_element(elements=estado_civil, length=2, unique=False)
print(estado_random)

# ? 10 Convierte los valores de la columna Fecha del archivo CSV, considerando que originalmente 
# ? están en formato mes/día/año (MM/DD/YYYY). Transforma las fechas al formato día-mes-año 
# ? (dd-mm-yyyy) y almacénalas en una variable llamada fechas.
fechas = pd.to_datetime(datos_csv['Fecha'], format='%d/%m/%Y', errors='coerce').dt.strftime('%d/%m/%Y')

# ? 11 Crea una lista vacía llamada datos.
datos = []

# ? 12 Emplea un ciclo for para generar 10 registros, utilizando diccionarios que deberán contener los siguientes campos:
# ? Nombre: generCreaa un nombre aleatorio utilizando Faker.
# ? Apellido: genera un apellido aleatorio utilizando Faker.
# ? Edad: genera un número aleatorio entre 18 y 65 años.
# ? Estado Civil: selecciona aleatoriamente un elemento de la lista estado_civil.
# ? Fecha de Compra: obtiene la fecha correspondiente del archivo CSV, utilizando la variable fechas y el método iloc.
# ? Total Compras: obtiene el valor correspondiente de la columna Total Venta del archivo CSV, utilizando iloc.
# ? 13 En cada iteración, agrega el diccionario generado a la lista datos mediante el método append().
# ? Haremos el 12 y 13 en uno solo ciclo for.
for i in range(0, 10):
    datos.append({
        'Nombre': fake.first_name(),
        'Apellido': fake.last_name(),
        'Edad': fake.random_int(min=18, max=65),
        'Estado Civil': fake.random_element(elements=estado_civil, unique=False),
        'Fecha de Compra': fechas.iloc[i],
        'Total Compras': datos_csv['Total Venta'].iloc[i]
    })

# ? 14 Finalmente, muestra los 10 registros almacenados en la lista datos.
print(datos)
# Practica 3
# ? Carlos Gabriel Rodriguez Macias
# ! Athala Dulce Edith Gómez Arellano
# * 6 de Octubre del 2026

# ? 1 Crea el archivo practica3.py
# * Listo jijiji

# ? 2 Importa la bibilioteca pandas
import pandas as pd
from pathlib import Path

# ? 3 Crea una variable llamada datos csv y lee el archivo envios_logistica.csv
ruta_csv = Path(__file__).with_name("envios_logistica.csv")
datos_csv = pd.read_csv(ruta_csv, encoding="utf-8-sig")

# ? 4 Muestra la informacion general del archivo
datos_csv.info()

# ? 5 Muestra los primeros 5 registros
print(datos_csv.head())

# ? 6 Muestra los primeros 10 registros
print(datos_csv.head(10))

# ? 7 Muestra los ultimos 5 registros
print(datos_csv.tail())

# ? 8 Muestra los ultimos 7 registros
print(datos_csv.tail(7))

# ? 9 Muestra las dimensiones de datos_csv
print(datos_csv.shape)

# ? 10 Muestra el tipo de dato de cad apregunta
print(datos_csv.dtypes)

# ? 11 Investiga y escribe como comentario para que sirve el metodo isnull().sum()
# * El metodo isnull().sum() sirve para contar la cantidad de valores nulos (NaN) 
# * en cada columna de un DataFrame.
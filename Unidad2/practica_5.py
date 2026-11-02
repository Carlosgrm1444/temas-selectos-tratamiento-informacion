# Practica 5
# ? Carlos Gabriel Rodriguez Macias
# ! Dulce Athala Edith Gomez Arellano
# * 9 de octubre de 2026

# ! Instrucciones
# ? 1 Crea el archivo practica5.py
# * Listo jiji

# ? 2 Importa la biblioteca pandas
import pandas as pd
import pathlib as Path

# ? 3 Emplea el control de errores:
# ? Crea una variable llamada datos_csv y lee el archivo proporcionado.
# ? Emplea el error FileNotFoundError y muestra el mensaje “El archivo no existe”.
ruta_csv = Path.Path(__file__).with_name("Datos_Ventas_Tienda.csv")
try:
    datos_csv = pd.read_csv(ruta_csv, encoding="utf-8-sig")
except FileNotFoundError as e:
    print(f"El archivo no existe: {e}")

# ? 4 Emplea else en el control de errores y muestra la información de la variable datos_csv y emplea el finally
else:
    print("Información del DataFrame:")
    print(datos_csv.info())
finally:
    print("Carlos Gabriel Rodriguez Macias")
        

# ? 5 Muestra si existen registros nulos y ¿cuantos hay?
datos_nulos = datos_csv.isnull().values.any()
if datos_nulos:
    print("Cantidad de registros nulos por columna:")
    print(datos_csv.isnull().sum())
else:
    print("No existen registros nulos en el DataFrame.")

# ? 6 Ordena los valores empleando el método sort_values()
# ? Ordenar por la columna Producto de forma ascendente
datos_ordenados_producto = datos_csv.sort_values(by="Producto", ascending=True)
print("Datos ordenados por la columna Producto (ascendente):")
print(datos_ordenados_producto)

# ? 7 Quita los espacios vacíos del inicio de los valores de la columna Producto e imprime
datos_csv["Producto"] = datos_csv["Producto"].str.strip()

# ? 8.Convierte el texto en mayúsculas de la columna Producto e imprime
datos_csv["Producto"] = datos_csv["Producto"].str.upper()
print(datos_csv["Producto"])

# ? 9.Convierte el texto en minúsculas de la columna Producto e imprime
datos_csv["Producto"] = datos_csv["Producto"].str.lower()
print(datos_csv["Producto"])

# ? 10.Convierte el texto solo la primera letra en mayúsculas de la columna Producto e imprime
datos_csv["Producto"] = datos_csv["Producto"].str.title()
print(datos_csv["Producto"])

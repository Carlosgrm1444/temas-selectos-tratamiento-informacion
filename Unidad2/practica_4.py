# Practica 4
# ? Carlos Gabriel Rodriguez Macias
# ! Athala Dulce Edith Gómez Arellano
# * 8 de Octubre del 2026

# ! Instrucciones
# ? 1 Crea el archivo practica4.py
# * Listo jijiji

# ? 2 Importa la biblioteca pandas
import pandas as pd
import pathlib as path

# ? 3 Emplea el control de errores:
# ?   Crea una variable llamada datos_csv y lee el archivo proporcionado.
# ?   Emplea el error FileNotFoundError y muestra el mensaje “El archivo no existe”.
ruta_csv = path.Path(__file__).with_name("envios_logistica.csv")
try:
    datos_csv = pd.read_csv(ruta_csv, encoding="utf-8-sig")
except FileNotFoundError as e:
    print(f"El archivo no existe: {e}")

# ? 4 Emplea else en el control de errores y muestra la información de la variable datos_csv
else:
    print("Información del DataFrame:")
    print(datos_csv)

# ? 5 Muestra si existen registros nulos y ¿cuantos hay?
datos_nulos = datos_csv.isnull().sum()

if datos_nulos.sum() > 0:
  print(f"Existen {datos_nulos.sum()} registros nulos en el DataFrame.")
else:
  print("No existen registros nulos en el DataFrame.")

# ? 6 Ordena los valores empleando el método sort_values()
# ?   Ordenar por la columna Cliente
# ?   De forma ascendente
datos_ordenados = datos_csv.sort_values(by="Cliente", ascending=True)

# ? 7 Imprime el DataFrame ordenado
print("DataFrame ordenado:")
print(datos_ordenados)

# ? 8 Investiga y escribe como comentario ¿para qué sirve el método duplicated()?
# * El método duplicated() sirve para identificar filas duplicadas en un DataFrame.

# ? 9 Investiga y escribe como comentario ¿para qué sirve el método rename()?
# * El método rename() sirve para cambiar el nombre de las columnas o índices de un DataFrame.
# * Ejemplo: datos_csv.rename(columns={"Cliente": "Nombre_Cliente"}, inplace=True)

# ? 10 Investiga y escribe como comentario ¿para qué sirve el método drop_duplicates()?
# * El método drop_duplicates() sirve para eliminar filas duplicadas de un 
# * DataFrame, manteniendo solo la primera ocurrencia de cada fila duplicada.
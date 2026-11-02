# Actividad 5
# ? Athala Dulce Edith Gómez Arellano
# ! Carlos Gabriel Rodriguez Macias
# * 13 de Octubre de 2026

# ! Problema
# * Una cadena de tiendas desea analizar las ventas realizadas durante el último año para 
# * identificar los productos con mayor demanda y generar reportes para la toma de decisiones.

# ! Instrucciones:
# ? 1 Importa la biblioteca pandas.
import pandas as pd
from pathlib import Path

# ? 2 Empleando el control de errores, crea una variable llamada datos_csv y carga el archivo 
# ? CSV dando un cotejamiento de utf-8, agrega un mensaje en caso de que no exista el archivo
try:
  ruta_csv = Path(__file__).with_name("Datos_Ventas_Tienda.csv")
  datos_csv = pd.read_csv(ruta_csv, encoding="utf-8-sig")
except FileNotFoundError:
  print("El archivo CSV no se encuentra en la ruta especificada.")

# ? 3 Muestra la información general del DataFrame utilizando el método adecuado.p as p
print(datos_csv.info())

# ? 4 Consulta si existen valores nulos y cuántos hay
datos_nulos = datos_csv.isnull().sum().sum()
if datos_nulos > 0:
    print(f"Existen {datos_nulos} valores nulos en el DataFrame.")
else:
    print("No existen valores nulos en el DataFrame.")

# ? 5 Quita los espacios al inicio, aplica en columna Productos
print(datos_csv["Producto"].str.strip())

# ? 6 Aplica un método para convertir la primera letra de cada palabra de la 
# ? oración en mayúsculas, emplea la columna Productos
for producto in datos_csv["Producto"]:
    print(producto.title())
    
# ? 7 Verifica si existen valores duplicados en la columna Precio Unitario e imprime el resultado.
print(datos_csv["Precio Unitario"].duplicated())

# ? 8 Investiga para qué sirve el método astype()
# * Sirve para convertir el tipo de datos de una columna o serie a otro tipo de datos especificado.
# * Por ejemplo, se puede usar para convertir una columna de enteros a flotantes, o de cadenas a fechas, entre otros tipos.

# ? 9 Investiga para que sirve el método to_datetime()
# * El método to_datetime() se utiliza para convertir una columna o serie de 
# * datos en un objeto de fecha y hora (datetime) en pandas.


# ! Preguntas de reflexión:
# ? 1 ¿Por qué es una buena práctica homologar los textos en la limpieza de datos?
# * Homologar los textos ayuda a mantener la consistencia en los datos, lo que 
# * facilita el análisis y la toma de decisiones.

# ? 2 ¿Por qué es una buena práctica eliminar los espacios vacíos al inicio de los textos?
# * Eliminar los espacios vacíos al inicio de los textos evita problemas de 
# * comparación y búsqueda, asegurando que los datos sean consistentes.

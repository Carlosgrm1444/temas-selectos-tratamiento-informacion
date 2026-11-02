# Actividad 4
# ? Carlos Gabriel Rodriguez Macias
# ! Athala Dulce Edith Gómez Arellano
# * 8 de Octubre del 2026

# ! Problema:
# * Una cadena de tiendas desea analizar las ventas realizadas durante el último 
# * año para identificar los productos con mayor demanda y generar reportes para la toma de decisiones.

# ! Instrucciones
# ? 1 Importa la biblioteca pandas.
import pandas as pd
from pathlib import Path

# ? 2 Empleando el control de errores, crea una variable llamada datos_csv y carga 
# ? el archivo CSV, agrega un mensaje en caso de que no se encontró el archivo
try:
  ruta_csv = Path(__file__).with_name("Datos_Ventas_Tienda.csv")
  datos_csv = pd.read_csv(ruta_csv, encoding="utf-8-sig")
except FileNotFoundError:
  print("No se encontro el archivo Datos_Ventas_Tienda.csv")
  raise SystemExit

# ? 3 Muestra la información general del DataFrame utilizando el método adecuado.
print("Información general del DataFrame:")
print(datos_csv.info())

# ? 4 Muestra la cantidad de filas y columnas
print("Cantidad de filas y columnas:")
print(datos_csv.shape)

# ? 5 Consulta si hay valores nulos e imprime el resultado.
if datos_csv.isnull().sum().any():
  print("Existen valores nulos en el DataFrame.")
else:
  print("No existen valores nulos en el DataFrame.")

print(datos_csv.isnull().values.any())

# ? 6 Verifica si existen valores duplicados en la columna Producto e imprime el resultado.
print("Valores duplicados en la columna Producto:")
print(datos_csv["Producto"]. duplicated())

# ? 7 Imprime la cantidad de productos duplicados
print("Cantidad de productos duplicados:")
print(datos_csv.duplicated(subset=["Producto"]).any())
print("-------------------------------------------------")
print(datos_csv.duplicated(["Producto"]).sum())

# ? 8 Si existen valores nulos y cuántos hay con el método isnull().sum()
print("Valores nulos en la columna Fecha:")
print(datos_csv['Fecha'].isnull().sum())


# ! Preguntas de reflexión:
# ? 1 ¿Por qué es una buena práctica comprobar la existencia de valores nulos 
# ?   antes de realizar un análisis de datos?
# * Comprobar la existencia de valores nulos antes de realizar un análisis de 
# * datos es una buena práctica porque los valores nulos pueden afectar la precisión 
# * y validez de los resultados del análisis.

# ? 2 ¿Qué problemas podría ocasionar trabajar con una columna de fechas 
# ?   almacenada como texto en lugar de un tipo de dato date?
# * Trabajar con una columna de fechas almacenada como texto en lugar de un tipo
# * de dato date puede ocasionar problemas al realizar operaciones de comparación,
# * filtrado y ordenamiento de fechas, ya que el formato de texto puede no ser consistente
# * y dificultar la interpretación correcta de las fechas.

# Actividad 3 
# ? Carlos Gabriel Rodriguez Macias
# ! Athala Dulce Edith Gómez Arellano
# * 6 de Octubre del 2026

# ! Problema
# * Una empresa de logística ha recibido un archivo CSV con el registro de los 
# * envíos realizados durante el último mes. Antes de realizar cualquier análisis 
# * o limpieza de datos, el departamento de análisis necesita conocer la 
# * estructura del archivo para verificar que la información sea correcta y que 
# * las columnas contengan los datos esperados.

# ! Instrucciones:
# ? 1 Importa la biblioteca pandas.
import pandas as pd
from pathlib import Path

# ? 2 Crea una variable llamada datos_csv y carga el archivo CSV
ruta_csv = Path(__file__).with_name("envios_logistica.csv")
datos_csv = pd.read_csv(ruta_csv, encoding="utf-8-sig")

# ? 3 Muestra la información general del DataFrame utilizando el método adecuado.
print("Información general del DataFrame:")
print(datos_csv.info())

# ? 4 Muestra los primeros seis registros del archivo.
print("Primeros seis registros:")
print(datos_csv.head(6))

# ? 5 Muestra los últimos cinco registros del archivo.
print("Últimos cinco registros:")
print(datos_csv.tail(5))

# ? 6 Imprime el número de filas y columnas.
print("Número de filas y columnas:")
print(datos_csv.shape)

# ? 7 Los nombres de las columnas.
print("Nombres de las columnas:")
print(datos_csv.columns)

# ? 8 El tipo de dato de cada columna.
print("Tipo de dato de cada columna:")
print(datos_csv.dtypes)

# ? 9 Si existen valores nulos y cuántos hay con el método isnull().sum()
print("Valores nulos por columna:")
print(datos_csv.isnull().sum())

# ? 10 Investiga y escribe como comentario para que sirven los métodos fillna() y dropna()
# * sirven para manejar los valores nulos en un DataFrame. El método fillna() 
# * se utiliza para reemplazar los valores nulos con un valor específico, como 
# * un número o una cadena, mientras que dropna() se utiliza para eliminar las 
# * filas o columnas que contienen valores nulos.


# ! Preguntas de reflexión:
# ? 1 ¿Qué información proporciona el método info() y por qué es útil revisarla 
# ? antes de comenzar a analizar o limpiar un conjunto de datos?
# * la información que proporciona el método info() incluye el número de 
# * entradas, el número de columnas, los nombres de las columnas, el tipo de 
# * datos de cada columna y la cantidad de valores no nulos en cada columna. 
# * Esta información es útil porque permite al analista comprender la estructura 
# * del conjunto de datos, identificar posibles problemas como valores nulos o 
# * tipos de datos incorrectos, y planificar cómo abordar el análisis o la 
# * limpieza de los datos.

# ? 2 ¿Qué diferencia existe entre utilizar head() y tail()? ¿En qué situaciones 
# ? sería útil consultar los primeros o los últimos registros de un archivo?
# * La diferencia entre head() y tail() es que head() muestra los primeros registros 
# * y tail() muestra los últimos registros de un DataFrame. Sería útil consultar los 
# * primeros registros para tener una idea inicial de la estructura y contenido del 
# * archivo, mientras que consultar los últimos registros puede ser útil para verificar 
# * la integridad de los datos o detectar patrones específicos al final del conjunto.
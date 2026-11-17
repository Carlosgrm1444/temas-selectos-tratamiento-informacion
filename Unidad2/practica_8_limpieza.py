# practica 8 limpieza
# ? Carlos Gabriel Rodriguez Macias
# ! Athala Dulce Edith Gómez Arellano
# * 27 de Octubre del 2026

from datetime import date

import pandas as pd
import pyodbc as py
from faker import Faker
from sqlalchemy import URL, create_engine
from sqlalchemy.exc import SQLAlchemyError

Faker.seed(7)
fake = Faker("es_MX")


# ? Establecer las reglas de negocio en formato de tabla en el documento (word)
# ? Formular 4 preguntas para el diagnóstico
# ? Lee el archivo, implementa el control de errores, si el archivo no existe 
# ? implementa un mensaje de error y si existe mostar la información del archivo, 
# ? las filas y columnas y emplea la función describe y explica para que sirve
try:
    df = pd.read_csv("Unidad2/ventas_originales_rodriguez.csv", encoding="utf-8")
except FileNotFoundError:
    print("Archivo no encontrado. Revise la ruta y el nombre del archivo.")
except (pd.errors.EmptyDataError, pd.errors.ParserError, UnicodeDecodeError) as error:
    print(f"Error al leer el archivo: {error}")
else:
    print("informacion del archivo")
    df.info()
    print("Filas",df.shape[0])
    print("Columnas",df.shape[1])
    print("Resumen estadistico")
    print(df.describe())

# ! Valida:
# ? Si hay nulos y cuantos son
if df.isnull().any().any():
    print(f"Hay {df.isnull().sum().sum()} valores nulos en el DataFrame.")
else:
    print("No hay valores nulos en el DataFrame.")

# ? Si hay duplicados
if df.duplicated().any():
    print(f"Hay {df.duplicated().sum()} filas duplicadas en el DataFrame.")
else:
    print("No hay filas duplicadas en el DataFrame.")

# ? Si hay claves primarias repetidas  (.duplicated(keep=False))
if df.duplicated(subset=["id_venta"], keep=False).any():
    print(f"Hay {df.duplicated(subset=['id_venta'], keep=False).sum()} claves primarias repetidas en el DataFrame.")
else:
    print("No hay claves primarias repetidas en el DataFrame.")

# ? Cantidades fuera del rango permitido (emplea ~)
# print(df[~((df["cantidad"] >= 1) & (df["cantidad"] <= 100))])
# print(df[~df["cantidad"].between(1, 100)])
# print(df[(~df["cantidad"].between(1, 100)) | df["cantidad"].isna()])
# cantidades = df["cantidad"]
# print(df[cantidades.between(1, 100) | cantidades.isna()])

cantidades_fuera_rango = (
    df["cantidad"].notna()
    & ~df["cantidad"].between(1, 100)
)

if cantidades_fuera_rango.any():
    print(f"Hay {cantidades_fuera_rango.sum()} registros con cantidades fuera del rango permitido (1-100).")
else:
    print("No hay registros con cantidades fuera del rango permitido (1-100).") 


# ? Fechas inválidas o fuera del periodo (crea una variable fechas y emplea 
# ? to_datetime() con errors "coerce"
print("Fechas inválidas o fuera del periodo:")
print(pd.to_datetime(df["fecha_venta"], errors="coerce"))

# ? Productos inexistentes  (emplea isin(productos["id_producto"])
productos = pd.DataFrame(
    {
    "id_producto" : [1, 2, 3, 4, 5, 6],
    "producto" : ["Teclado", "Mouse", "Monitor", "Memoria USB", "Camara web", "Audifonos"],
    "Precio" : [350.00, 200.00, 3500.00, 180.00, 750.00, 600.00]
    }
)
print("Productos inexistentes:")
productos_inexistentes = ~df["id_producto"].isin(productos["id_producto"])
if productos_inexistentes.any():
    print(f"Hay {productos_inexistentes.sum()} productos inexistentes en el DataFrame.")  

# ? Actualizar a cantidades positivas (emplea .abs()) y por ende corrige ["subtotal"]
df["subtotal"] = df["subtotal"].abs()
df["cantidad"] = df["cantidad"].abs()

# ? Quitar la fila duplicada (.drop_duplicates(keep="first").copy())
df.drop_duplicates(keep="first", inplace=True)

# ? Quitar la fila con un producto inexistente (.isin(productos["id_producto"]).copy())
df.isin(productos["id_producto"]).copy()

# ? Imprime la cantidad de registros en el nuevo DataFrame limpio
print(f"Cantidad de registros en el DataFrame limpio: {len(df)}")

# ? Investiga para que sirve la biblioteca pyodbc y ejecuta: pip install pyodbc (hacerlo en word)
# ? Importa pyodbc  e imprime print(pyodbc.drivers())
print("Controladores ODBC instalados:")
print(py.drivers())

# ? Datos de mi conexión de SQL Server en Linux.
servidor = "localhost"
base_datos = "techstore_sql"
usuario = "sa"
contrasena = "cgrmSql44!"

# ! Estas variables son para esta práctica. No se deben subir con credenciales a GitHub.
# ? Se usa SQL Server Authentication porque no se emplea Trusted_Connection en Linux.
cadena_conexion = (
    "DRIVER={ODBC Driver 18 for SQL Server};"
    f"SERVER={servidor};"
    f"DATABASE={base_datos};"
    f"UID={usuario};"
    f"PWD={contrasena};"
    "Encrypt=yes;"
    "TrustServerCertificate=yes;"
)

url = URL.create(
    "mssql+pyodbc",
    query={"odbc_connect": cadena_conexion}
)

motor = create_engine(url)

# ? Conectarse con SQL Server.
try:
    with motor.connect() as conexion:
        print("Conexión exitosa con SQL Server.")

except SQLAlchemyError as error:
    print("No fue posible conectarse:", error)


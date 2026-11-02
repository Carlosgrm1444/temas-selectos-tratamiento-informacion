# Actividad 7
# ? Athala Dulce Edith Gómez Arellano
# ! Carlos Gabriel Rodriguez Macias
# * 22 de Octubre de 2026

# ! Problema
# * La empresa TechStore, dedicada a comercializar equipos de cómputo y accesorios, 
# * ha detectado diferencias entre los importes registrados en su sistema y los 
# * valores reales de sus movimientos comerciales. El departamento de sistemas 
# * sospecha que algunas operaciones están calculando importes incorrectos. Sin 
# * embargo, desconoce cuántos registros están afectados y cuánto dinero 
# * representan esas diferencias. Se solicita desarrollar un programa en 
# * Python que permita simular las operaciones, identificar las inconsistencias
# * y generar información confiable para su revisión.

from datetime import date
from pathlib import Path

# ! Instrucciones
# ? Crea un archivo llamado actividad7.py e importa las bibliotecas necesarias.
import pandas as panda
from faker import Faker

# ? Configura Faker para generar información ficticia de México y establece un
# ? seed para que los datos puedan reproducirse.
Faker.seed(4)
fake = Faker('es_MX')

# ? Define una lista con seis productos tecnológicos y otra con dos tipos de 
# ? movimiento: Entrada y Salida.
productos_tecnologicos = ["Mause", "Teclado", "Monitor", "Audifonos", "Microfono", "Camara"]
tipos_movimientos = ["Entrada", "Salida"]

# ? Utilizando un ciclo for, genera 50 movimientos comerciales. Cada registro deberá contener:
  # ? id_movimiento: identificador consecutivo.
  # ? responsable: nombre completo del empleado.
  # ? sucursal: ciudad donde se realizó la operación.
  # ? producto: producto involucrado.
  # ? tipo_movimiento: Entrada o Salida.
  # ? cantidad: número de unidades, entre 1 y 30.
  # ? precio_unitario: valor entre $200 y $5,000.
  # ? total_registrado: importe almacenado por el sistema.
  # ? fecha_movimiento: fecha ficticia entre enero y septiembre de 2026.

# ? Simula una falla del sistema mediante una condición if: cuando un movimiento
# ? sea de tipo Salida y su cantidad supere las 15 unidades, el programa deberá 
# ? agregar incorrectamente $250 al importe registrado. Los demás movimientos 
# ? conservarán su cálculo correcto.

registros = []
fecha_inicio = date(2026, 1, 1)
fecha_fin = date(2026, 9, 30)

for i in range(0, 50):
  cantidad = fake.random_int(1, 30)
  precio = fake.pydecimal(
    left_digits=4, 
    right_digits=2,
    min_value=200,
    max_value=5000
    )
  importe = cantidad * precio
  tipo_movimiento = fake.random_element(elements=tipos_movimientos)
  
  if tipo_movimiento == 'Salida' and cantidad > 15:
    importe = importe + 250
    # print(f"Ocurrio error {tipo_movimiento} {cantidad}")
  
  registros.append({
    "id_movimiento": i + 1,
    "responsable": fake.name(),
    "sucursal": fake.city(),
    "producto": fake.random_element(elements=productos_tecnologicos),
    "tipo_movimiento": tipo_movimiento,
    "cantidad": cantidad,
    "precio_unitario": precio,
    "total_registrado": importe,
    "fecha_movimiento": fake.date_between(fecha_inicio, fecha_fin)
  })

# ? Convierte la información generada en un DataFrame y guárdala en un archivo 
# ? llamado Movimientos_Originales.csv.
datos_csv = panda.DataFrame(registros)
ruta_csv = Path(__file__).with_name('Movimientos_Originales.csv')
datos_csv.to_csv(ruta_csv, index=False, encoding='utf-8')

# ? Carga el archivo CSV generado empleando try-except-else, contemplando la 
# ? posibilidad de que no exista.
try:
  datos_csv = panda.read_csv(ruta_csv, encoding="utf-8")
except FileNotFoundError as e:
  print(f"El archivo no existe: {e}")

# ? Muestra la estructura general del archivo, sus dimensiones y el tipo de 
# ? dato de cada columna.
else:
  print("Informacion general del DatFrame")
  print(datos_csv.info())
  print(datos_csv.shape)
  print(datos_csv.head())

# ? Comprueba si existen valores nulos o registros completamente duplicados e 
# ? imprime los resultados, aun cuando no se encuentre ninguno.
valores_nulos = datos_csv.isnull().sum().sum()
valores_duplicados = datos_csv.duplicated().sum()

if (valores_nulos + valores_duplicados) > 0:
  print(f"Existen {valores_nulos} valores nulos y {valores_duplicados} valores duplicados")
else:
  print(f"No existen valores nulos ni duplicados: {valores_duplicados, valores_nulos}")

# ? Crea una nueva columna llamada total_esperado, calculando el valor que 
# ? debería tener cada movimiento de acuerdo con la cantidad y el precio unitario.
datos_csv["total_esperado"] = (datos_csv["cantidad"] * datos_csv["precio_unitario"]).round(2)

# ? Incorpora una columna llamada diferencia que permita conocer cuánto varía 
# ? el importe registrado respecto al importe esperado.
datos_csv["diferencia"] = (datos_csv["total_registrado"] - datos_csv["total_esperado"]).round(2)


# ? Muestra únicamente los movimientos que presentan diferencias económicas.
filtro = datos_csv[datos_csv["diferencia"]!=0]
print("Diferencias")
print(filtro)

# ? Calcula el importe total de las diferencias detectadas y determina cuántas 
# ? operaciones resultaron afectadas.
suma_diferencias_afectadas = filtro["diferencia"].sum()
operaciones_afectadas = len(filtro)

print(f"Importe total de las diferencias: {suma_diferencias_afectadas}")
print(f"Operaciones afectadas: {operaciones_afectadas}")

# ? Normaliza los nombres de los productos eliminando espacios innecesarios y 
# ? utilizando un mismo formato de mayúsculas y minúsculas.
datos_csv['producto'] = datos_csv['producto'].str.strip().str.title()

# ? Corrige únicamente los importes incorrectos de total_registrado, tomando 
# ? como referencia los valores de total_esperado.
datos_csv.loc[filtro.index, 'total_registrado'] = datos_csv.loc[filtro.index, 'total_esperado']

# ? Cambia el nombre de la columna total_registrado por importe_final.
datos_csv.rename(columns={'total_registrado': 'importe_final'}, inplace=True)

# ? Genera un nuevo DataFrame que contenga exclusivamente las operaciones de tipo 
# ? Salida con cantidades superiores a 15 unidades.
salidas_mayores_15 = datos_csv[
  (datos_csv['tipo_movimiento'] == 'Salida') & (datos_csv['cantidad'] > 15)
]
print('Operaciones de Salida con cantidades mayores a 15:')
print(salidas_mayores_15)

# ? Exporta la información corregida a un archivo 
# ? llamado Movimientos_Corregidos.csv.
ruta_csv_corregido = Path(__file__).with_name('Movimientos_Corregidos.csv')
datos_csv.to_csv(ruta_csv_corregido, index=False, encoding='utf-8-sig')
print('Archivo creado:', ruta_csv_corregido.name)

# ! Preguntas de análisis
# ? ¿Qué cantidad de movimientos presentó diferencias económicas?
# * Se detectaron 11 movimientos con diferencias económicas. Las diferencias
# * sumaron $2,750.00 porque cada operación afectada tuvo un incremento de $250.00.

# ? ¿Qué condición provocaba que las operaciones tuvieran un importe equivocado?
# * La diferencia se provocaba cuando el movimiento era de tipo Salida y la
# * cantidad era mayor a 15 unidades. En esos casos se agregaban $250.00 al importe.

# ? ¿Por qué es importante conservar el archivo original antes de modificar los datos?
# * Porque permite conservar la información original como evidencia, comparar los
# * resultados y recuperar los datos iniciales si ocurre un error en la corrección.

# ? Si TechStore no detectara estas inconsistencias, ¿qué consecuencias podrían 
# ? presentarse en sus reportes financieros?
# * Los reportes podrían mostrar importes incorrectos y afectar el análisis de
# * ventas, inventario y ganancias. También se podrían tomar decisiones equivocadas.

# TODO Se requiere como entrega:
# TODO Archivo Python actividad7.py.

# TODO Los dos archivos CSV generados.

# TODO Capturas de pantalla de los registros incorrectos, los resultados 
# TODO de la validación y los archivos exportados. (PDF)

# TODO Respuestas a las cinco preguntas de análisis en un documento PDF.


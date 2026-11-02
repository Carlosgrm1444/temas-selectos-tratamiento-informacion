# Actividad 2
# ? Carlos Gabriel Rodriguez Macias
# ! Athala Dulce Edith Gómez Arellano
# * 2 de Octubre del 2026

# * Problema:
# * Un zoológico desea desarrollar un programa en Python para llevar un registro 
# * de la cantidad de ejemplares de algunas especies que habitan en sus instalaciones. 
# * El sistema permitirá actualizar la información cuando lleguen nuevos animales, 
# * eliminar especies que sean trasladadas a otro zoológico y consultar el inventario actual.

# ! Instrucciones:
# ? 1 Solicita el nombre del cuidador e imprime un mensaje de bienvenida
cuidador = input("Ingrese el nombre del cuidador: ")
print(f"Bienvenido, {cuidador}!")

# ? 2 Crea un diccionario llamado especies que contenga tres especies y la cantidad de ejemplares.
especies = {
    "León": 5,
    "Elefante": 3,
    "Tigre": 4
}

# ? 3 Agrega la especie Jirafa con una cantidad inicial de 9
especies.setdefault("Jirafa", 9)

# ? 4 Actualiza la cantidad de Jirafa a 10 ejemplares.
especies.update({"Jirafa": 10})

# ? 5 Recorre el diccionario e imprime el nombre y la cantidad de ejemplares. No olvides usar la función ítems()
for especie, cantidad in especies.items():
    print(f"Especie: {especie}, Cantidad de ejemplares: {cantidad}")
    print("Especie", cuidador, " Cantidad de ejemplares: ", cantidad)
    print("Especie" + cuidador + " Cantidad de ejemplares: " + str(cantidad))

for especie in especies.items():
    print(f"Especie: {especie}, Cantidad de ejemplares: {cantidad}")

# ? 6 Elimina la primera especie registrada en el diccionario.
especies.pop("León", 5)

# ? 7 Comprueba si la clave "Jirafa" existe e imprime un mensaje indicando si la especie se encuentra registrada.
if "Jirafa" in especies:
    print("La especie Jirafa se encuentra registrada.")
else:
    print("La especie Jirafa no se encuentra registrada.")

# ? 8 Crea una copia del diccionario.
especies_copia = especies.copy()

# ? 9  Imprime únicamente los valores del diccionario copia.
print("Valores del diccionario copia:")
for cantidad in especies_copia.values():
    print(cantidad)

# ? 10  Utiliza el método update() para modificar la cantidad de dos especies del diccionario e imprime el resultado.
especies.update({"Elefante": 7, "Tigre": 6})
print("Diccionario actualizado:")
for especie, cantidad in especies.items():
    print(f"Especie: {especie}, Cantidad de ejemplares: {cantidad}")


# ! Preguntas de reflexión:
# ? 1 ¿Qué ventajas ofrece un diccionario frente a una lista cuando se necesita 
# ? almacenar información asociada a una clave, como el nombre de una especie 
# ? y su cantidad de ejemplares?
# * Los diccionarios permiten almacenar información en pares clave valor, 
# * lo que facilita la búsqueda y actualización de datos asociados a una clave específica.

# ? 2 ¿En qué situaciones de la vida real o de tu futura profesión podrías 
# ? utilizar un diccionario en Python para organizar y consultar información 
# ? de manera eficiente?
# * En situaciones donde se necesite almacenar información estructurada y
# * asociada a claves únicas, como registros de bases de datos, los diccionarios 
# * permiten un acceso rápido y eficiente a la información
# Practica 2
# ? Carlos Gabriel Rodriguez Macias
# ! Athala Dulce Edith Gómez Arellano
# * 1 de Octubre del 2026

# ? 1 Crea el archivo practica2.py
# * Listo jijiji

# ? 2 Crea una variable que solicite el nombre del estudiante e imprime ¡Bienvenid@ nombre!
nombre = input("Ingrese el nombre del estudiante: ")
print(f"Bienvendo {nombre}!")

# ? 3 Crea un diccionario llamado calificaciones que contenga tres elementos. Cada clave deberá corresponder al nombre de una asignatura y cada valor a la calificación obtenida.
calificaciones = {
    "Algebra" : 8,
    "Ciencias" : 9,
    "Historia" : 10
}

# ? 4 Agrega la asignatura BD con la calificación de 9
calificaciones.setdefault("BD", 9)

# ? 5 Modifica la calificación anterior a 10 e imprime el resultado
calificaciones.update({"BD": 10})

# ? 6 Recorre el diccionario e imprime tanto la clave como el valor, no olvides emplear una función de conversión
for asignatura, calificacion in calificaciones.items():
    print(f"La asignatura {asignatura} tiene una calificación de {calificacion}") 

# ? 7 Imprime cuantos elementos tiene el diccionario
print(f"El diccionario tiene {len(calificaciones)} elementos")

# ? 8.Elimina la primera asignatura
calificaciones.pop("Algebra", 9)

# ? 9 Comprueba si la clave “BD” existe o no e imprime un mensaje
if "BD" in calificaciones:
    print("La clave 'BD' existe en el diccionario")
else:
    print("La clave 'BD' no existe en el diccionario")

# ? 10 Crea una copia del diccionario
calificaciones_copia = calificaciones.copy()

# ? 11 Imprime las claves del diccionario copia
print("Claves del diccionario copia:")
for clave in calificaciones_copia:
    print(clave)

# ? 12 Imprime los valores del diccionario copia
print("Valores del diccionario copia:")
for valor in calificaciones_copia.values():
    print(valor)

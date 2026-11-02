# Practica 1 Python
# ? Carlos Gabriel rodriguez Macias
# ? 1 de Octubre del 2026

# ? 3 Ingresar nombre y saludarlo
nombre = input("Escribe su nombre: ")
print(f"Hola, {nombre}!") 


# ? 4 Crea una lista de peliculas, con 3 elementos, donde 2 de ellas sean la misma

lista = ["Cars", "Nemo", "Cars"]

# ? 5 append es una funcion para agregar un elementos
lista.append(" ")

# ? 6 imprimir pelicula 
print(lista[0])

# ? 7 Recorrer la lista empleando for
for pelicula in lista:
    print(pelicula)

# ? 8 Imprimir la cantidad de peliculas
print("La cantidad de peliculas es: " + str(len(lista)))

# ? 9 para que sirve la funcion set() 
# * es para eliminar elementos duplicados de una lista

# ? 10 Eliminan las peliculas duplicadas, crea una variable con el nombre, de peliculas_unicas y conviertelo en lista
peliculas_unicas = list(set(lista))
print("Las peliculas unicas son: " + str(peliculas_unicas))

# ? 11 iterar sobre las peliculas no repetidas
for pelicula_unica in peliculas_unicas:
    print(pelicula_unica)

# ? 12 Repite el paso 10 pero con una nueva lista
nueva_lista = list(set(lista))

# ? 13 Elimina el valor vacio empleando remove
lista.remove(" ")

# ? 14 Ordena los valores de la nueva lista
lista.sort()

# ?  15 Imprime la nueva lista ordenada
print("La nueva lista ordenada es: " + str(lista))





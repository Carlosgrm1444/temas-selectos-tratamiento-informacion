# Actividad 1
# ? Carlos Gabriel Rodriguez Macias
# ! Athala Dulce Edith Gómez Arellano 
# * 1 de Octubre del 2026

# * Problema:
# * Una tienda desea organizar su inventario mediante un programa en Python.
# * La lista de productos contiene nombres repetidos y un registro vacío, por lo que es necesario limpiarla antes de mostrar el inventario definitivo.
# * El programa deberá trabajar con la siguiente lista:
productos = ["Teclado", "Mouse", "Monitor", "Mouse", "Memoria USB"]

# ! Instrucciones:
# ? 1. Solicite el nombre del empleado responsbale del inventario
empleado = input("Ingrese el nombre del empleado responsable del inventario: ")

# ? 2.Muestre un mensaje de Bienvenida
print(f"Bienvenido, {empleado}!")

# ? 3.Agregue un valor vacío a la lista
productos.append("")

# ? 4.Muestre el segundo producto registrado
print(f"El segundo producto registrado es: {productos[1]}")

# ? 5.Muestre el ultimo producto registrado
print(f"El último producto registrado es: {productos[-1]}")

# ? 6.Muestre la cantidad total de productos
print(f"La cantidad total de productos es: {len(productos)}")

# ? 7.Elimine los productos repetidos y convierta el resultado en una nueva lista
productos_unicos = list(set(productos))

# ? 8.Elimine el registro vacío de la nueva lista
productos_unicos.remove("")

# ? 9.Ordene alfabéticamente los productos de la nueva lista
productos_unicos.sort()

# ? 10.Recorra la nuevalista, imprima cada producto y emplea la función title
for producto in productos_unicos:
    print(producto.title())



# ! Preguntas de reflexión:

# ? 1 ¿Por qué se utiliza set() en este problema?
# * Se utiliza set() para eliminar los elementos duplicados de la lista de 
# * productos, ya que un conjunto (set) no permite elementos repetidos. Esto 
# * ayuda a limpiar la lista y obtener solo los productos únicos antes de 
# * mostrar el inventario definitivo.

# ? 2 ¿Por qué debe convertirse nuevamente el resultado en una lista?
# * Se convierte nuevamente en una lista porque set() devuelve un conjunto 
# * (set) que no tiene un orden específico y no permite indexación. Al 
# * convertirlo de nuevo en una lista, podemos ordenar los elementos y 
# * acceder a ellos mediante índices, lo que facilita su manipulación 
# * y presentación.

# ? 3 ¿Qué sucede si se ejecuta print(productos_unicos.sort())?
# * Si se ejecuta print(productos_unicos.sort()), el resultado será None, 
# * ya que el método sort() ordena la lista en su lugar y no devuelve ningún 
# * valor. Para ver la lista ordenada, se debe llamar a sort() primero y luego 
# * imprimir la lista por separado.

# ? 4 ¿Para qué sirve la función title()?
# * La función title() se utiliza para convertir la primera letra de cada 
# * palabra en mayúscula y el resto en minúscula. Esto es útil para mejorar 
# * la presentación de los nombres de los productos, asegurando que se vean 
# * uniformes y estéticamente agradables al mostrarlos en el inventario 
# * definitivo.


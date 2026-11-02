# Origen del código y diferencias

Las capturas image7.png e image8.png del documento recibido muestran las figuras 6 y 6.1. Se leyeron visualmente para transcribir producto, lote, inventario_lote y la referencia almacen. No se tomó código de los scripts locales del proyecto anterior.

En el destino se propone usar el esquema proyecto_u2, con nombres de restricciones distintos para evitar colisiones y conservando las columnas, tipos y relaciones de las capturas. Los grupos de archivos de la base original no se recrean para este análisis.

Se corrigió la tabla descriptiva del documento para coincidir con las capturas: lote está en SECUNDARIO; pedido y detalle_pedido están en PRIMARY.

La figura 6.2 no incluye un CHECK que compare cantidad_danada con cantidad_entregada, aunque el texto anterior lo afirma. Tampoco se observa en las capturas la creación del trigger tr_historial_inventario. Esas diferencias se conservan como observaciones en el anexo interno para que el equipo aporte evidencia o ajuste el texto.

Las evidencias históricas muestran Windows/SSMS. Las nuevas rutas y la conexión están adaptadas a Linux. No se afirmó que las capturas históricas se hubieran ejecutado nuevamente en este equipo.


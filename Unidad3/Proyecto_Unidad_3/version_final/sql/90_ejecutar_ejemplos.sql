-- ? Carlos Gabriel Rodríguez Macías
-- ! Juan Manuel Ortega García
-- * Bernardo Guillermo Núñez López
-- ? Proyecto Unidad 3 - Pruebas de los diez procedures
-- ! Ejecutar primero los archivos 01 al 10 en la base elegida.

Use pepsi_distribucion;
GO

-- ? Encriptado 1. El precio negativo activa el Check y llega al Catch.
Exec proyecto_u2.usp_cambiar_precio @id_producto = 2, @precio = -5;
GO

-- ? Encriptado 2. El producto 999 no existe y activa la llave foranea.
Exec proyecto_u2.usp_registrar_lote
  @id_producto = 999, @numero_lote = 'DEMO-ERROR',
  @fecha_recepcion = '2026-11-23', @fecha_caducidad = '2027-05-23';
GO

-- ? Probar una insercion valida sin conservar el registro de demostracion.
Begin Transaction;
Exec proyecto_u2.usp_registrar_lote
  @id_producto = 2, @numero_lote = 'DEMO-VALIDO',
  @fecha_recepcion = '2026-11-23', @fecha_caducidad = '2027-05-23';
Rollback Transaction;
GO

-- ? Consultar las dos subconsultas.
Exec proyecto_u2.usp_productos_precio_alto;
Exec proyecto_u2.usp_lotes_con_existencia @dias = 120;
GO

-- ? Probar las condiciones If con parametros validos e invalidos.
Exec proyecto_u2.usp_consultar_producto @id_producto = 2;
Exec proyecto_u2.usp_consultar_producto @id_producto = 0;
Exec proyecto_u2.usp_validar_entrada
  @id_almacen = 1, @id_lote = 2, @cantidad = 10;
Exec proyecto_u2.usp_validar_entrada
  @id_almacen = 1, @id_lote = 2, @cantidad = -10;
GO

-- ? Probar While. El aumento se revierte al terminar la consulta.
Begin Transaction;
Exec proyecto_u2.usp_actualizar_precios @aumento = 10;
Select Top 5 id_producto, nombre, precio
From proyecto_u2.producto
Order By id_producto;
Rollback Transaction;
GO

Exec proyecto_u2.usp_resumen_almacenes;
GO

-- ? Revisar las clasificaciones Case.
Exec proyecto_u2.usp_estado_inventario;
Exec proyecto_u2.usp_estado_lotes @fecha_revision = '2026-11-23';
GO

-- ? Comprobar que los dos primeros procedures tienen With Encryption.
Select name, Objectproperty(object_id, 'IsEncrypted') As encriptado
From sys.procedures
Where name In ('usp_cambiar_precio', 'usp_registrar_lote');
GO

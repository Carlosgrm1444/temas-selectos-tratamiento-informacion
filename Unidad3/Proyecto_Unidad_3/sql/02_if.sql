-- ? Carlos Gabriel Rodriguez Macias
-- ! Juan Manuel Ortega Garcia
-- * Bernardo Guillermo Nuñez Lopez
-- ? Proyecto Unidad 3 - Procedures con If
Use pepsi_distribucion;
GO

-- ? 1 Consultar un producto solo si existe.
-- * Evita presentar una busqueda vacia como si fuera un producto valido.
Create Or Alter Procedure proyecto_u2.usp_consultar_producto
  @id_producto int
As
Begin
  Set Nocount On;
  If @id_producto Is Null Or @id_producto <= 0
  Begin
    Print 'El id del producto no es valido.';
    Return;
  End;
  If Not Exists (Select 1 From proyecto_u2.producto Where id_producto = @id_producto)
  Begin
    Print 'El producto no existe.';
    Return;
  End;
  Select id_producto, nombre, presentacion, precio, activo
  From proyecto_u2.producto Where id_producto = @id_producto;
End;
GO
Exec proyecto_u2.usp_consultar_producto @id_producto = 2;
GO

-- ? 2 Revisar si un lote puede recibir unidades en un almacen.
-- * Valida las relaciones antes de intentar registrar inventario.
Create Or Alter Procedure proyecto_u2.usp_validar_entrada
  @id_almacen int, @id_lote int, @cantidad int
As
Begin
  Set Nocount On;
  If @cantidad Is Null Or @cantidad <= 0
  Begin
    Print 'La cantidad debe ser mayor que cero.';
    Return;
  End;
  If Not Exists (Select 1 From proyecto_u2.almacen
                 Where id_almacen = @id_almacen And activo = 1)
  Begin
    Print 'El almacen no existe o esta inactivo.';
    Return;
  End;
  If Not Exists (Select 1 From proyecto_u2.lote Where id_lote = @id_lote)
  Begin
    Print 'El lote no existe.';
    Return;
  End;
  Select @id_almacen As id_almacen, @id_lote As id_lote,
    @cantidad As cantidad, 'Entrada valida' As resultado;
End;
GO
Exec proyecto_u2.usp_validar_entrada @id_almacen = 1, @id_lote = 2, @cantidad = 10;
GO

-- ? Carlos Gabriel Rodriguez Macias
-- ! Juan Manuel Ortega Garcia
-- * Bernardo Guillermo Nuñez Lopez
-- ? Proyecto Unidad 3 - Procedures con While
Use pepsi_distribucion;
GO

-- ? 1 Mostrar un corte por cada dia del periodo solicitado.
-- * Ayuda a preparar revisiones diarias de lotes por caducar.
Create Or Alter Procedure proyecto_u2.usp_cortes_caducidad
  @dias int
As
Begin
  Set Nocount On;
  If @dias Is Null Or @dias Not Between 1 And 7
  Begin
    Print 'El periodo permitido es de 1 a 7 dias.';
    Return;
  End;
  Declare @dia int = 0;
  While @dia < @dias
  Begin
    Select Dateadd(day, @dia, Cast(Getdate() As date)) As fecha_corte,
      Count(*) As lotes_por_caducar
    From proyecto_u2.lote
    Where fecha_caducidad = Dateadd(day, @dia, Cast(Getdate() As date));
    Set @dia = @dia + 1;
  End;
End;
GO
Exec proyecto_u2.usp_cortes_caducidad @dias = 3;
GO

-- ? 2 Recorrer los primeros almacenes para contar sus existencias.
-- * Permite revisar cada almacen por separado sin modificar datos.
Create Or Alter Procedure proyecto_u2.usp_resumen_almacenes
  @cantidad_almacenes int
As
Begin
  Set Nocount On;
  If @cantidad_almacenes Is Null Or @cantidad_almacenes Not Between 1 And 10
  Begin
    Print 'Solicita entre 1 y 10 almacenes.';
    Return;
  End;
  Declare @numero int = 1;
  While @numero <= @cantidad_almacenes
  Begin
    Select a.id_almacen, a.nombre, Isnull(Sum(i.cantidad), 0) As unidades
    From proyecto_u2.almacen a
    Left Join proyecto_u2.inventario_lote i On a.id_almacen = i.id_almacen
    Where a.id_almacen = @numero
    Group By a.id_almacen, a.nombre;
    Set @numero = @numero + 1;
  End;
End;
GO
Exec proyecto_u2.usp_resumen_almacenes @cantidad_almacenes = 3;
GO

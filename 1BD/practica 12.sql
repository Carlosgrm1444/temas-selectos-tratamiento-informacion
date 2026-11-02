Use Romex;

-- ? SP Print
Create Procedure sp_print @valor int
With Encryption
As
Begin
	If @valor = 1
	Begin
		Select * From tipo_producto;
	End
	Else
	Begin
		Print 'No aplica';
	End
End

Exec sp_print @valor =0;

-- ? SP Variable
Create Procedure sp_variable
With Encryption
As
Begin
  Declare @id int;
  
  Select Top 1 @id = id_tipo_producto From tipo_producto;

  if @id = 1
  Begin
    Print 'El id es 1';
  End
  Else
  Begin
    Print N'El id no es el indicado, ingreso: ' + @id;
  End
End

Exec sp_variable;


-- ? SP if
Create Procedure sp_if @valor Int
With Encryption
As
Begin
  Declare @precio_maximo decimal(10, 2)
  Select @precio_maximo =MAX(precio_venta) From producto
  Where id_tipo_producto = @valor;

  if @precio_maximo > 1000
  begin
    Print 'El precio máximo es mayor a 1000';
  End
  Else
  begin
    Print 'El precio máximo es menor o igual a 1000';
  End
End

Exec sp_if 1 ;

-- ? SP Case
Create Procedure sp_case
With Encryption
As
Begin
  Select nombre, activo = case
    when activo = 0 then 'Inactivo'
    when activo = 1 then 'Activo'
    else 'Desconocido'
  end
  From tipo_producto
End

Exec sp_case;

-- ? Ejemplo simple
Create Procedure sp_case_simple
With Encryption
AS
BEGIN 
  Select nombre,
    tipo_producto = case id_tipo_producto
      when 1 then 'Tipo 1'
      when 2 then 'Tipo 2'
      else 'Otro tipo'
    end
  From producto
End

Exec sp_case_simple;

-- ? Ejemplo de busqueda
Create Procedure sp_case_busqueda
AS
Begin 
  Update producto
  Set costo_total = (
    Case
      When costo_total < 100 Then costo_total * 1.1
      Else costo_total
    End
  );
  Select * from producto
End

Exec sp_case_busqueda

-- ? SP while
Create Procedure sp_aumentar_costo_total @aumento decimal (10,2)
AS
Begin
  While (Select Avg(costo_total) From producto) < 100
  Begin
    Update producto
    Set costo_total = costo_total + (1 + @aumento/100);

    Select * From producto;
  End
End

Exec sp_aumentar_costo_total @aumento = 5;

-- ? Ejemplo 2 con contador usando la tabla producto
Create Procedure sp_contador
AS
Begin
  Declare @contador int = 1;
  While @contador <= (Select Count(*) From producto)
  Begin
    Print 'Producto número: ' + CAST(@contador AS varchar(10));
    Set @contador = @contador + 1;
  End
End

Exec sp_contador;

-- ? funciones
Create Function fn_calcular_iva (@precio Decimal (10, 2))
Returns Decimal (10, 2)
AS
Begin
  Return @precio * 0.16;
End

Select nombre, precio_venta, dbo.fn_calcular_iva(precio_venta) AS IVA
From producto;

-- ? ejemplo 2
Create Function fn_calcular_descuento (@precio Decimal (10, 2), @descuento decimal (5, 2))
Returns Decimal (10, 2)
AS
Begin
  Return @precio - (@precio * @descuento / 100);
End   

Select nombre, precio_venta, dbo.fn_calcular_descuento(precio_venta, 10) AS PrecioConDescuento
From producto;
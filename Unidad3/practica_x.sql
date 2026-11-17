Use fronteresa_repaso;

-- ? Case condiciones
Go
Create Or Alter procedure sp_prueba_case
As
Begin
  Select
    descripcion as producto,
    existencia,
    case
      when existencia <= 5 then 'Se requiere solicitar mas'
      when existencia >= 15 then 'No se requiere solicitar mas'
      else 'Esta bien'
    End as estado
  From productos_athala;
End;

-- * --------------------------------------------------------------------------
Alter Table productos_athala
Add precio Decimal(10, 2);

Update productos_athala set precio = 10 where id_producto = 4
Go
Update productos_athala set precio = 20 where id_producto = 5
Go
Update productos_athala set precio = 5 where id_producto = 6
Go

-- ? Case condiciones con operaciones
Go
Create Or Alter Procedure sp_case_descuentos
As
Begin
  Select
    descripcion As producto,
    existenciam

  From productos_athala
End;
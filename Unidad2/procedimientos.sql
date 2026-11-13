-- ? Carlos Gabriel Rodriguez Macias
-- ! Athala Dulce Edith Gómez Arellano
-- * 13 de noviembre de 2026

-- ? Crear sp
Use fronteresa_repaso;
Go
Create or Alter Procedure sp_insertar_cliente
  @razon_social nvarchar(100),
  @correo varchar(100)

  With Encryption
  As Begin

    Insert Into clientes_athala (razon_social, correo)
    Values (@razon_social, @correo);

  If @@Rowcount = 0
    Print 'No se logro insertar el registro.'
  Else
    Print 'Se logro insertar el registro.'
End

Go
Execute sp_insertar_cliente 'Ejemplo_carlos', 'ejemplo@carlos.com';

GO
Create or Alter Procedure sp_actualizar_cliente
  @id_cliente int,
  @razon_social varchar(100) = Null,
  @correo varchar(100) = Null

As Begin
  If @id_cliente <= 0 Or @id_cliente Is Null
  Begin
    Print 'Los parametros no son validos.'
    Return;
  End

  Update clientes_athala
  Set razon_social = IsNull(@razon_social, razon_social),
      correo = IsNull(@correo, correo)
  Where id_cliente = @id_cliente;

  If @@Rowcount = 0
    Print 'No se logro actualizar el registro.'
  Else
    Print 'Se logro actualizar el registro.'
End
GO


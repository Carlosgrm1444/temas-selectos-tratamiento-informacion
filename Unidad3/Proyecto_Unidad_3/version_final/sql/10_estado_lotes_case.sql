-- ? Carlos Gabriel Rodríguez Macías
-- ! Juan Manuel Ortega García
-- * Bernardo Guillermo Núñez López
-- ? Proyecto Unidad 3 - 23 de noviembre de 2026

Use pepsi_distribucion;
GO

-- ? Clasificar los lotes de acuerdo con su fecha de caducidad.
Create Or Alter Procedure proyecto_u2.usp_estado_lotes
  @fecha_revision date
As Begin
  Select numero_lote, fecha_caducidad,
    Case
      When fecha_caducidad < @fecha_revision Then 'Vencido'
      When fecha_caducidad <= Dateadd(day, 30, @fecha_revision)
        Then 'Prioridad alta'
      Else 'Vigente'
    End As estado
  From proyecto_u2.lote
  Order By fecha_caducidad;
End;
GO

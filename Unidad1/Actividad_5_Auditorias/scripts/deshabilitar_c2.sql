-- ? Carlos Gabriel Rodriguez Macias
-- * Edith Dulce Athala Gomez
-- ? Deshabilitar C2 después de terminar las evidencias

Use master;

Exec sp_configure 'show advanced options', 1;
Reconfigure;

Exec sp_configure 'c2 audit mode', 0;
Reconfigure;

-- ? Verificar que C2 quedó deshabilitado.
Select name, value, value_in_use, is_dynamic
From sys.configurations
Where name = 'c2 audit mode';

-- ! Si value_in_use continúa en 1, reiniciar SQL Server.

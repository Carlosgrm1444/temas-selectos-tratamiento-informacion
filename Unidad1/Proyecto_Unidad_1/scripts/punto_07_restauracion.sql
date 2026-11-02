-- ? Punto 7. Prueba de restauracion.
-- ? Objetivo: restaurar full, diferencial y log sin reemplazar la base original.
-- ! Requisito: ejecutar el Punto 6 y comprobar que existen los cuatro archivos demo.
-- ! Este archivo crea pepsi_distribucion_prueba y se debe ejecutar una sola vez.

Use master;
GO

If DB_ID('pepsi_distribucion_prueba') Is Not Null
  Throw 50010, 'La base de prueba ya existe. No se reemplazara.', 1;
GO

-- ? 7.1 Comprobar que los archivos de respaldo son legibles.
Restore VerifyOnly
From Disk = '/media/carlos-rodriguez/nvme0n1p1/2db/data/pepsi_distribucion_demo_full.bak'
With Checksum;

Restore VerifyOnly
From Disk = '/media/carlos-rodriguez/nvme0n1p1/2db/data/pepsi_distribucion_demo_differential.bak'
With Checksum;

Restore VerifyOnly
From Disk = '/media/carlos-rodriguez/nvme0n1p1/2db/data/pepsi_distribucion_demo_log_01.trn'
With Checksum;

Restore VerifyOnly
From Disk = '/media/carlos-rodriguez/nvme0n1p1/2db/data/pepsi_distribucion_demo_log_02.trn'
With Checksum;
GO

-- ? 7.2 Medir el tiempo y restaurar en el orden correcto.
Declare @inicio datetime2 = Sysdatetime();

Restore Database pepsi_distribucion_prueba
From Disk = '/media/carlos-rodriguez/nvme0n1p1/2db/data/pepsi_distribucion_demo_full.bak'
With
  Move 'pepsiData'
    To '/media/carlos-rodriguez/nvme0n1p1/2db/data/pepsi_distribucion_prueba.mdf',
  Move 'pepsiSecundario'
    To '/media/carlos-rodriguez/nvme0n1p1/2db/data/pepsi_distribucion_prueba_secundario.ndf',
  Move 'pepsiLog'
    To '/media/carlos-rodriguez/nvme0n1p1/2db/data/pepsi_distribucion_prueba.ldf',
  Norecovery, Checksum, Stats = 10;

Restore Database pepsi_distribucion_prueba
From Disk = '/media/carlos-rodriguez/nvme0n1p1/2db/data/pepsi_distribucion_demo_differential.bak'
With Norecovery, Checksum, Stats = 10;

Restore Log pepsi_distribucion_prueba
From Disk = '/media/carlos-rodriguez/nvme0n1p1/2db/data/pepsi_distribucion_demo_log_01.trn'
With Norecovery, Checksum, Stats = 10;

Restore Log pepsi_distribucion_prueba
From Disk = '/media/carlos-rodriguez/nvme0n1p1/2db/data/pepsi_distribucion_demo_log_02.trn'
With Recovery, Checksum, Stats = 10;

Declare @fin datetime2 = Sysdatetime();

Select
  @inicio As inicio_restauracion,
  @fin As fin_restauracion,
  Datediff(second, @inicio, @fin) As rto_segundos,
  Case When Datediff(second, @inicio, @fin) <= 7200
    Then 'CUMPLE RTO DE 2 HORAS'
    Else 'NO CUMPLE RTO DE 2 HORAS'
  End As comprobacion_rto;
GO

-- ? 7.3 Verificar que la copia restaurada funciona.
Select name, state_desc, recovery_model_desc
From sys.databases
Where name = 'pepsi_distribucion_prueba';

Select
  (Select Count(*) From pepsi_distribucion_prueba.dbo.tienda) As tiendas,
  (Select Count(*) From pepsi_distribucion_prueba.dbo.producto) As productos,
  (Select Count(*) From pepsi_distribucion_prueba.dbo.pedido) As pedidos,
  (Select Count(*) From pepsi_distribucion_prueba.dbo.entrega) As entregas;

DBCC CHECKDB ('pepsi_distribucion_prueba') With No_Infomsgs;

-- * El RTO se obtiene del tiempo real mostrado por la consulta.
-- * Evidencia: capturar la restauracion, el RTO, los conteos y CHECKDB sin errores.

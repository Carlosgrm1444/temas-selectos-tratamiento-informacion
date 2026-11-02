-- ? Punto 11. Revision final.
-- ? Objetivo: comprobar que cada requisito practico quedo implementado.
-- ! Requisito: ejecutar este archivo despues de completar los puntos anteriores.

Use pepsi_distribucion;
GO

-- ? 11.1 Revisar restricciones y llaves foraneas.
DBCC CHECKCONSTRAINTS With All_Constraints;

Select
  name As llave_foranea,
  is_disabled,
  is_not_trusted
From sys.foreign_keys
Order By name;
GO

-- ? 11.2 Crear la tabla de comprobacion del proyecto.
Declare @revision Table
(
  punto int,
  requisito varchar(100),
  archivo varchar(100),
  consulta_verificacion varchar(200),
  resultado_actual varchar(100),
  captura varchar(80)
);

Insert Into @revision
Select 1, 'Base y grupos de archivos', 'punto_01_entorno_almacenamiento.sql',
  'sys.database_files',
  Concat(Count(*), ' archivos'), 'Pendiente de tomar'
From sys.database_files;

Insert Into @revision
Select 2, 'Modelo relacional', 'punto_02_modelo_relacional.sql',
  'sys.tables',
  Concat(Count(*), ' tablas'), 'Pendiente de tomar'
From sys.tables
Where name <> 'historial_inventario';

Insert Into @revision
Select 3, 'Datos de prueba', 'punto_03_datos_prueba.sql',
  'dbo.pedido',
  Concat(Count(*), ' pedidos'), 'Pendiente de tomar'
From dbo.pedido;

Insert Into @revision
Select 4, 'Consultas de comprobacion', 'punto_04_consultas_comprobacion.sql',
  'dbo.incidencia',
  Concat(Count(*), ' incidencias'), 'Pendiente de tomar'
From dbo.incidencia;

Insert Into @revision
Select 5, 'Roles con minimo privilegio', 'punto_05_usuarios_privilegios.sql',
  'sys.database_principals',
  Concat(Count(*), ' roles'), 'Pendiente de tomar'
From sys.database_principals
Where name Like 'rol_%';

Insert Into @revision
Select 6, 'Respaldos programados', 'punto_06_respaldos.sql',
  'msdb.dbo.sysjobs',
  Concat(Count(*), ' trabajos'), 'Pendiente de tomar'
From msdb.dbo.sysjobs
Where name Like 'pepsi_respaldo_%';

Insert Into @revision
Select 7, 'Restauracion de prueba', 'punto_07_restauracion.sql',
  'sys.databases',
  Case When DB_ID('pepsi_distribucion_prueba') Is Null
    Then 'Pendiente' Else 'Base restaurada' End,
  'Pendiente de tomar';

Insert Into @revision
Select 8, 'Plan de mantenimiento', 'punto_08_mantenimiento.sql',
  'msdb.dbo.sysjobs',
  Concat(Count(*), ' trabajos'), 'Pendiente de tomar'
From msdb.dbo.sysjobs
Where name In
  ('pepsi_revision_diaria', 'pepsi_integridad_estadisticas',
   'pepsi_mantenimiento_indices');

Insert Into @revision
Select 9, 'Auditoria', 'punto_09_auditoria.sql',
  'sys.server_audits',
  Case When Exists
    (Select 1 From sys.server_audits Where name = 'auditoria_pepsi')
    Then 'Creada' Else 'Pendiente' End,
  'Pendiente de tomar';

Insert Into @revision
Select 10, 'Eventos extendidos', 'punto_10_eventos_extendidos.sql',
  'sys.server_event_sessions',
  Case When Exists
    (Select 1 From sys.server_event_sessions Where name = 'eventos_pepsi')
    Then 'Creada' Else 'Pendiente' End,
  'Pendiente de tomar';

Insert Into @revision
Select 11, 'Revision final', 'punto_11_revision_final.sql',
  'DBCC CHECKCONSTRAINTS', 'Ejecutada', 'Pendiente de tomar';

Select *
From @revision
Order By punto;
GO

-- ? 11.3 Verificar el estado final de la base.
Select
  base.name,
  base.state_desc,
  base.recovery_model_desc,
  base.user_access_desc
From sys.databases base
Where base.name In ('pepsi_distribucion', 'pepsi_distribucion_prueba');

-- * Evidencia: completar la columna de capturas en el documento y guardar este resultado.

-- ? Carlos Gabriel Rodriguez Macias
-- * Edith Dulce Athala Gomez
-- ? Proyecto - 05/02/2026

SELECT * FROM Openquery([192.168.0.22], 
'SELECT * FROM pepsi.dbo.roles');

Insert Into [192.168.0.22].[pepsi].[dbo].[roles]
(rol) values ('carlos');

Update [192.168.0.22].[pepsi].[dbo].[roles] 
set rol='carlos rodriguez' where id_rol=9;

delete from [192.168.0.22].[pepsi].[dbo].[roles] 
where id_rol=9;

-- ? Conexion con una bd de mysql

SELECT * FROM OPENQUERY(MYSQL, 
'SELECT * FROM romex_mysql.tipo_producto');

INSERT OPENQUERY(MYSQL, 
'SELECT nombre, descripcion, activo, creado_en FROM romex_mysql.tipo_producto')
VALUES ('Producto prueba', 'Descripción de prueba', 1, '2026-03-20');


EXEC master.dbo.sp_serveroption 
    @server = 'MYSQL', 
    @optname = 'rpc out', 
    @optvalue = 'true';

EXEC ('UPDATE romex_mysql.tipo_producto
       SET nombre = ''Producto actualizado'',
           descripcion = ''Nueva descripción'',
           activo = 1,
           creado_en = ''2026-03-20''
       WHERE id_tipo_producto = 1;') AT MYSQL;

DELETE FROM OPENQUERY(MYSQL, 
    'SELECT * 
     FROM romex_mysql.tipo_producto 
     WHERE id_tipo_producto = 1');

#!/bin/bash

# ? Crear el directorio que utilizaran SQL Audit y eventos extendidos.
sudo mkdir -p /var/opt/mssql/audit/proyecto_unidad_1

# ? Permitir que el servicio de SQL Server escriba los archivos.
sudo chown mssql:mssql /var/opt/mssql/audit/proyecto_unidad_1
sudo chmod 770 /var/opt/mssql/audit/proyecto_unidad_1

# ? Mostrar los permisos finales del directorio.
sudo ls -ld /var/opt/mssql/audit/proyecto_unidad_1

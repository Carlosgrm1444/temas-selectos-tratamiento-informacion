#!/bin/bash

# ? Crear la carpeta donde SQL Server guardará las auditorías y eventos.
sudo mkdir -p /var/opt/mssql/audit/actividad_5

# ? Dar permisos al usuario de SQL Server.
sudo chown mssql:mssql /var/opt/mssql/audit/actividad_5
sudo chmod 770 /var/opt/mssql/audit/actividad_5

# ? Verificar la carpeta.
sudo ls -ld /var/opt/mssql/audit/actividad_5

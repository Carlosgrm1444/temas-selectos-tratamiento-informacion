#!/bin/bash

# ? Dar acceso de lectura a los archivos creados por SQL Server.
sudo setfacl -m u:carlos-rodriguez:rx /var/opt/mssql
sudo setfacl -m u:carlos-rodriguez:rx /var/opt/mssql/audit
sudo setfacl -m u:carlos-rodriguez:rx /var/opt/mssql/audit/actividad_5
sudo setfacl -R -m u:carlos-rodriguez:rX /var/opt/mssql/audit/actividad_5

# ? Dar acceso de lectura a los archivos que se creen después.
sudo setfacl -m d:u:carlos-rodriguez:r-x /var/opt/mssql/audit/actividad_5

# ? Mostrar y abrir la carpeta de evidencias.
ls -lah /var/opt/mssql/audit/actividad_5
xdg-open /var/opt/mssql/audit/actividad_5

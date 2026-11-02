#!/bin/bash

# ! Ejecutar después de habilitar o deshabilitar C2.
sudo systemctl restart mssql-server

# ? Verificar que SQL Server volvió a iniciar.
sudo systemctl status mssql-server --no-pager

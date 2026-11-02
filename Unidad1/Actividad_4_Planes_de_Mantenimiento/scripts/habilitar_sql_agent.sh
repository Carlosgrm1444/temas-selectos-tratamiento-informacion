#!/bin/bash

# ? Habilitar SQL Server Agent en Ubuntu
sudo /opt/mssql/bin/mssql-conf set sqlagent.enabled true
sudo systemctl restart mssql-server
sudo systemctl status mssql-server

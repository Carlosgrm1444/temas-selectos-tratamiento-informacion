#!/bin/bash

# ? Generar un inicio de sesión fallido para la auditoría.
/opt/mssql-tools18/bin/sqlcmd \
  -S localhost \
  -U usuario_inexistente_auditoria \
  -P 'ClaveIncorrecta123.' \
  -C \
  -Q "Select 1;"

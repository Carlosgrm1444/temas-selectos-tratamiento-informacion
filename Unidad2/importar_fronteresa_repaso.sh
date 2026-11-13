#!/usr/bin/env bash

# ? Carlos Gabriel Rodriguez Macias
# ! Importar la base fronteresa_repaso desde un archivo bacpac.
# * En Linux se usa sqlpackage porque el bacpac no se importa con T-SQL.

ruta_actual="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ruta_bacpac="$ruta_actual/data/fronteresa_repaso.bacpac"
servidor="localhost"
base_datos="fronteresa_repaso"
usuario="sa"
sqlpackage_bin="${SQLPACKAGE_BIN:-$(command -v sqlpackage || true)}"

# ? Usar sqlpackage instalado de forma local en Linux si no está en el PATH.
if [ -z "$sqlpackage_bin" ] && [ -x "$HOME/.local/bin/sqlpackage" ]; then
  sqlpackage_bin="$HOME/.local/bin/sqlpackage"
fi

# ? Revisar que exista el archivo bacpac.
if [ ! -f "$ruta_bacpac" ]; then
  echo "No se encontró el archivo fronteresa_repaso.bacpac"
  exit 1
fi

# ? Revisar que esté instalado sqlpackage.
if [ -z "$sqlpackage_bin" ]; then
  echo "No se encontró sqlpackage. Instalarlo antes de importar la base."
  exit 1
fi

# ? Pedir la contraseña para no guardarla dentro del script.
read -r -s -p "Contraseña de SQL Server: " contrasena
echo

# ? Importar la base de datos en el servidor local.
"$sqlpackage_bin" \
  /Action:Import \
  /SourceFile:"$ruta_bacpac" \
  /TargetServerName:"$servidor" \
  /TargetDatabaseName:"$base_datos" \
  /TargetUser:"$usuario" \
  /TargetPassword:"$contrasena" \
  /TargetTrustServerCertificate:True

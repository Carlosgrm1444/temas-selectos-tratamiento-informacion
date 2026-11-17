# Proyecto 2 corregido

Esta carpeta contiene la versión corregida del Proyecto de las Unidades I y II.

## Correcciones aplicadas

- Se agregó el nombre de la docente en la portada.
- Se dejó una sola conclusión actualizada para todo el proyecto.
- Se reunieron todas las referencias en un único apartado al final.
- Se normalizó la tipografía del documento a Times New Roman.
- Se corrigieron acentos, títulos y descripciones de varias imágenes.
- Se actualizó el índice y la numeración de las páginas.
- Se corrigieron los permisos para que coincidan con la matriz:
  - Almacén solamente tiene lectura sobre `Inventario_Lote`.
  - El administrador técnico utiliza `rol_admin_tecnico` y no pertenece a `db_owner`.
  - Los permisos del administrador técnico se asignan de manera explícita.
- Se sustituyó la evidencia de la imagen 51 por una consulta limitada a:
  - La base `pepsi_distribucion`.
  - Eventos correspondientes a 2026.
  - Los 13 objetos que forman parte del modelo del proyecto.
- Se revisó el documento corregido compartido por Memo y se conservaron sus aportaciones útiles:
  - Código de permisos reutilizable y alineado con la matriz definitiva.
  - Validación de auditoría separada de la evidencia antigua de 2025.
  - Conclusión general reforzada para las unidades I y II.
  - Referencias reunidas en una página independiente.
- Se mantuvieron las correcciones que ya estaban mejor resueltas en esta carpeta:
  - La consulta de auditoría filtra tanto el año 2026 como los 13 objetos del proyecto.
  - Los permisos incluyen la lectura de `almacen` para el rol de captura.
  - La comprobación de permisos se puede ejecutar de nuevo sin duplicar roles ni membresías.
- Se volvió a actualizar el índice y se revisaron visualmente las 115 páginas del documento final.

## Documentos finales

- `documentos/Proyecto_Unidad_I_y_II_corregido.docx`
- `documentos/Proyecto_Unidad_I_y_II_corregido.pdf`
- `documentos/Proyecto_Unidades_I_y_II_Final_Corregido.docx`
- `documentos/Proyecto_Unidades_I_y_II_Final_Corregido.pdf`

## Código corregido de permisos

- `scripts/punto_05_usuarios_privilegios_corregido.sql`

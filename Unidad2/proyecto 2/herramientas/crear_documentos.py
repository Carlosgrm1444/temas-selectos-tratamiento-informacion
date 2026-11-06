"""Crear dos copias actualizadas del proyecto base sin alterar la referencia."""
from pathlib import Path
from copy import deepcopy
from hashlib import sha256
import json
import math
import re
import sys
import textwrap
from xml.sax.saxutils import escape
from zipfile import ZipFile

import pandas as pd
from PIL import Image, ImageDraw, ImageFont
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_BREAK
from docx.enum.style import WD_STYLE_TYPE
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.table import Table
from docx.text.paragraph import Paragraph
from lxml import etree

ruta = Path(__file__).resolve().parent.parent
base = ruta / 'Proyecto Base de Datos 1 - Con citas.docx'
assert sha256(base.read_bytes()).hexdigest() == '011401816431ee1695d79949548a936808ce675d15b8cd23e20c9381d13d516b'

reglas = [
 ('producto', 'id_producto', 'Entero positivo único', 'Obligatorio; clave primaria'),
 ('producto', 'clave_producto', '1 a 15 caracteres; mayúsculas, sin espacios externos', 'Obligatoria y única'),
 ('producto', 'nombre', '1 a 100 caracteres; formato título', 'Obligatorio; bebida comercializada'),
 ('producto', 'presentacion', '1 a 50 caracteres; minúsculas', 'Obligatoria'),
 ('producto', 'precio', '0.01 a 99,999,999.99; máximo dos decimales', 'Obligatorio; no inventar precios'),
 ('producto', 'activo', 'Entero: 0 o 1', 'Obligatorio'),
 ('lote', 'id_lote', 'Entero positivo único', 'Obligatorio; clave primaria'),
 ('lote', 'id_producto', 'Entero positivo existente en producto limpio', 'Obligatorio; clave foránea'),
 ('lote', 'numero_lote', '1 a 30 caracteres; mayúsculas', 'Único junto con id_producto'),
 ('lote', 'fecha_recepcion', 'AAAA-MM-DD; entre 01/01/2026 y 02/11/2026', 'Obligatoria; fecha de recepción del ejercicio'),
 ('lote', 'fecha_caducidad', 'AAAA-MM-DD; posterior a fecha_recepcion', 'Obligatoria; consistencia entre columnas'),
 ('inventario_lote', 'id_inventario', 'Entero positivo único', 'Obligatorio; clave primaria'),
 ('inventario_lote', 'id_almacen', 'Entero 1', 'Almacén de referencia, sin cuarto CSV'),
 ('inventario_lote', 'id_lote', 'Entero existente en lote limpio', 'Único junto con id_almacen'),
 ('inventario_lote', 'id_producto', 'Debe coincidir con el producto del lote', 'Relación compuesta id_lote e id_producto'),
 ('inventario_lote', 'cantidad', 'Entero de 0 a 2,147,483,647', 'Obligatoria; no corregir signos sin evidencia'),
 ('inventario_lote', 'fecha_actualizacion', 'AAAA-MM-DD HH:MM:SS; dentro de 2026 y hasta el corte', 'Obligatoria; corte 02/11/2026 23:59:59'),
]

preguntas = [
 ('¿Qué porcentaje de registros cumple todas las reglas y permite utilizar la información del almacén?', 'Sí. Después de la limpieza, los registros conservados cumplen las reglas definidas para el ejercicio.'),
 ('¿Qué datos obligatorios faltan y cómo impedirían identificar el producto o sus existencias?', 'No. En los archivos limpios no faltan datos obligatorios.'),
 ('¿Existen registros o claves repetidas que puedan inflar el inventario y provocar pedidos innecesarios?', 'No. Los duplicados se identificaron y no permanecen en los archivos limpios.'),
 ('¿Los precios son numéricos, positivos y válidos para calcular el valor de las existencias?', 'Sí. Los precios aceptados son numéricos y mayores que cero.'),
 ('¿Todos los lotes e inventarios se relacionan con productos existentes y conservan la relación entre lote y producto?', 'Sí. Se validaron las relaciones entre producto, lote e inventario_lote.'),
 ('¿Las fechas de recepción y caducidad son válidas y permiten decidir qué lotes deben salir primero?', 'Sí. Las fechas válidas conservan el orden entre recepción y caducidad.'),
 ('¿Las cantidades son enteras y no negativas, y corresponden al mismo producto y lote para sustentar el reabastecimiento?', 'Sí. Las cantidades aceptadas son enteras no negativas y respetan la relación del lote con el producto.'),
]

referencias = [
 'Faker. (s. f.). Welcome to Faker’s documentation. https://faker.readthedocs.io/en/master/',
 'Microsoft. (s. f.-a). CREATE VIEW (Transact-SQL). Microsoft Learn. https://learn.microsoft.com/en-us/sql/t-sql/statements/create-view-transact-sql',
 'Microsoft. (s. f.-b). Extract, transform, load (ETL). Microsoft Learn. https://learn.microsoft.com/azure/architecture/data-guide/relational-data/etl',
 'pandas. (s. f.-a). pandas.to_datetime. https://pandas.pydata.org/docs/reference/api/pandas.to_datetime.html',
 'pandas. (s. f.-b). pandas.to_numeric. https://pandas.pydata.org/docs/reference/api/pandas.to_numeric.html',
 'SQLAlchemy. (s. f.). Working with engines and connections. https://docs.sqlalchemy.org/en/20/core/connections.html',
]

def formato(parrafo, titulo=False):
  pf = parrafo.paragraph_format
  pf.line_spacing = 2 if not titulo else 1.2
  pf.space_after = Pt(6)
  if not titulo:
    pf.first_line_indent = Inches(0.5)
  for run in parrafo.runs:
    run.font.name = 'Times New Roman'
    run.font.size = Pt(12)
    run.font.color.rgb = RGBColor(0, 0, 0)


def tabla_doc(doc, encabezado, filas, anchos=None):
  tabla = doc.add_table(rows=1, cols=len(encabezado))
  tabla.autofit = False
  for celda, texto in zip(tabla.rows[0].cells, encabezado):
    celda.text = texto
  for fila in filas:
    for celda, texto in zip(tabla.add_row().cells, fila):
      celda.text = str(texto)
  for ri, fila in enumerate(tabla.rows):
    # Evitar filas partidas y alturas fijas heredadas.
    prop = fila._tr.get_or_add_trPr()
    no_dividir = OxmlElement('w:cantSplit'); prop.append(no_dividir)
    if ri == 0:
      repetir = OxmlElement('w:tblHeader'); prop.append(repetir)
    for ci, celda in enumerate(fila.cells):
      if anchos:
        celda.width = Inches(anchos[ci])
      tcpr = celda._tc.get_or_add_tcPr()
      bordes = OxmlElement('w:tcBorders')
      for lado in ['top', 'left', 'bottom', 'right']:
        b = OxmlElement('w:' + lado); b.set(qn('w:val'), 'single'); b.set(qn('w:sz'), '4'); b.set(qn('w:color'), 'D9D9D9'); bordes.append(b)
      tcpr.append(bordes)
      shade = OxmlElement('w:shd'); shade.set(qn('w:fill'), 'EAEAEA' if ri == 0 else 'FFFFFF'); tcpr.append(shade)
      for p in celda.paragraphs:
        p.paragraph_format.line_spacing = 1.1
        p.paragraph_format.space_after = Pt(5)
        p.paragraph_format.space_before = Pt(5)
        if len(tabla.rows) <= 6 and ri < len(tabla.rows) - 1:
          p.paragraph_format.keep_with_next = True
        for run in p.runs:
          run.font.name = 'Times New Roman'; run.font.size = Pt(10)
          run.font.bold = ri == 0; run.font.color.rgb = RGBColor(0, 0, 0)
  doc.add_paragraph()
  return tabla


def imagen_codigo(archivo, destino):
  # Listado del código real, sin simular una captura de VS Code.
  texto = archivo.read_text(encoding='utf-8').splitlines()
  fuente = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf', 23)
  imagenes = []
  partes = max(1, math.ceil(len(texto) / 26))
  bloque = math.ceil(len(texto) / partes)
  for parte, inicio in enumerate(range(0, len(texto), bloque), 1):
    lineas = ['# Ortega García - Núñez López - Rodríguez Macias',
              '# ' + archivo.name + ' | parte ' + str(parte), '']
    for n, linea in enumerate(texto[inicio:inicio+bloque], inicio+1):
      trozos = textwrap.wrap(linea, width=76, replace_whitespace=False, drop_whitespace=False) or ['']
      lineas.append(f'{n:3} ' + trozos[0])
      lineas.extend('    ' + t for t in trozos[1:])
    im = Image.new('RGB', (1220, 40 + 31 * len(lineas)), '#fbfbfb')
    dib = ImageDraw.Draw(im)
    for n, linea in enumerate(lineas):
      color = '#21613c' if '#' in linea[:10] else '#151515'
      dib.text((20, 16+n*31), linea, fill=color, font=fuente)
    path = destino / f'{archivo.stem}_{parte:02}.png'
    im.save(path); imagenes.append(path)
  return imagenes


def crear(version):
  completa = version == '02_version_completa'
  carpeta = ruta / version
  doc = Document(base)
  doc.settings.odd_and_even_pages_header_footer = False
  if 'Title' not in doc.styles:
    estilo = doc.styles.add_style('Title', WD_STYLE_TYPE.PARAGRAPH)
    estilo.font.name = 'Times New Roman'
    estilo.font.size = Pt(14)
    estilo.font.bold = True
    estilo.font.color.rgb = RGBColor(0, 0, 0)
  # Trabajar sobre una copia manteniendo las imágenes originales.
  salida = carpeta / 'documentos' / 'Proyecto_Unidad_2.docx'
  doc.save(salida)
  titulos_indice = []

  # El índice original es un control de contenido con páginas ya desactualizadas.
  for control in list(doc.element.body.findall(qn('w:sdt'))):
    if b'TOC' in etree.tostring(control):
      doc.element.body.remove(control)

  # Eliminar saltos vacíos heredados del cuerpo; conservar los párrafos con imágenes.
  cuerpo_iniciado = False
  for p in list(doc.paragraphs):
    if p.text.strip() == 'INTRODUCCIÓN':
      cuerpo_iniciado = True
    if cuerpo_iniciado and not p.text.strip():
      if not p._p.xpath('.//w:drawing | .//w:pict | .//w:instrText | .//w:fldSimple | .//w:sectPr'):
        p._p.getparent().remove(p._p)
  for p in doc.paragraphs:
    if p.text.strip().startswith('FIGURA '):
      p.paragraph_format.keep_with_next = False
      anterior = p._p.getprevious()
      if anterior is not None and anterior.tag == qn('w:p') and anterior.xpath('.//w:drawing'):
        Paragraph(anterior, p._parent).paragraph_format.keep_with_next = True

  # Actualizar portada e introducción. Conservar la imagen institucional original.
  for p in doc.paragraphs:
    t = p.text.strip()
    if t == 'PROYECTO BASE DE DATOS UNIDAD 2':
      p.text = 'PROYECTO UNIDAD 2\nCALIDAD DE DATOS\n' + ('VERSIÓN COMPLETA' if completa else 'VERSIÓN ACTUAL')
      p.style = doc.styles['Title']
      p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    elif '26 DE OCTUBRE DEL 2026' in t:
      p.text = '2 DE NOVIEMBRE DE 2026\nNUEVO LAREDO, TAMAULIPAS'
    elif t == 'ORTEGA GARCIA JUAN MANUEL': p.text = 'ORTEGA GARCÍA JUAN MANUEL'
    elif t == 'NUÑEZ LOPEZ BERNARDO GUILLERMO': p.text = 'NÚÑEZ LÓPEZ BERNARDO GUILLERMO'
    elif t == 'RODRIGUEZ MACIAS CARLOS GABRIEL': p.text = 'RODRÍGUEZ MACIAS CARLOS GABRIEL'
    elif t.startswith('El objetivo es organizar la información necesaria'):
      p.text += (' En la Unidad II incorporamos Python, Pandas y Faker para simular los datos, '
        'identificar errores y transformar la información antes de reintegrarla a SQL Server. '
        'El análisis se concentra en productos, lotes e inventario del mismo almacén de Pepsi.')
    elif t == 'CONCLUSIÓN': p.text = 'CONCLUSIÓN DE LA UNIDAD I'
    elif t == 'REFERENCIAS': p.text = 'REFERENCIAS DE LA UNIDAD I'
    elif 'Contiene el catálogo del sistema y las tablas de dimensión' in t:
      p.text = 'Archivo Primario (.mdf): asignado a PRIMARY. Contiene tienda, producto, almacen, pedido y detalle_pedido, de acuerdo con el código de las figuras 6 y 6.1.'
    elif 'Está dedicado exclusivamente a soportar la carga transaccional pesada' in t:
      p.text = 'Archivo Secundario (.ndf): asignado a SECUNDARIO. Contiene lote, inventario_lote, entrega, detalle_entrega, incidencia, movimiento_inventario, conteo_inventario y detalle_conteo.'

  # Corregir únicamente las asignaciones que contradicen las capturas 6 y 6.1.
  for tabla in doc.tables:
    for fila in tabla.rows:
      texto = fila.cells[0].text.strip().lower()
      if texto in ['lote', 'pedido', 'detalle_pedido'] and len(fila.cells) == 3:
        fila.cells[2].text = 'SECUNDARIO' if texto == 'lote' else 'PRIMARY'

  # Normalizar la tipografía de la copia para APA 7; las imágenes se conservan.
  for p in doc.paragraphs:
    if p.text.strip():
      formato(p, p.style.name.startswith('Heading'))
  # Conservar portada de una página; el formato del cuerpo sigue el documento base.
  primera_intro = next(p for p in doc.paragraphs if p.text.strip() == 'INTRODUCCIÓN')
  for p in doc.paragraphs:
    if p._p is primera_intro._p: break
    p.paragraph_format.first_line_indent = Inches(0)
    p.paragraph_format.line_spacing = 1.1
  # Eliminar párrafos vacíos posteriores a la fecha que producían páginas en blanco.
  fecha_portada = False
  for p in list(doc.paragraphs):
    if p._p is primera_intro._p:
      break
    if '2 DE NOVIEMBRE DE 2026' in p.text:
      fecha_portada = True
    elif fecha_portada and not p.text.strip() and not p._p.xpath('.//w:drawing'):
      p._p.getparent().remove(p._p)
  # Insertar un índice estático de solo secciones principales, actualizado al render final.
  indice = primera_intro.insert_paragraph_before('ÍNDICE ACTUALIZADO')
  formato(indice, True); indice.paragraph_format.page_break_before = True
  indice.runs[0].bold = True
  # Registrar encabezados principales de Unidad I, excluyendo las figuras.
  for p in doc.paragraphs:
    if p.style.name == 'Heading 1' and p.text.strip():
      titulos_indice.append(p.text.strip())
  primera_intro.paragraph_format.page_break_before = True

  md = ['# Proyecto Unidad 2', '', 'Equipo: Ortega García, Núñez López y Rodríguez Macias.', '']
  figura = 54
  def titulo(texto, nueva=False):
    if nueva: doc.add_page_break()
    p = doc.add_heading(texto, level=1); formato(p, True)
    p.paragraph_format.keep_with_next = True
    titulos_indice.append(texto); md.extend(['', '## ' + texto, ''])
  def subtitulo(texto):
    p = doc.add_heading(texto, level=2); formato(p, True)
    p.paragraph_format.keep_with_next = True
    md.extend(['', '### ' + texto, ''])
  def parrafo(texto):
    p = doc.add_paragraph(texto); formato(p)
    md.extend([texto, '']); return p
  def tabla(encabezado, filas, anchos=None):
    tabla_doc(doc, encabezado, filas, anchos)
    md.append('| ' + ' | '.join(encabezado) + ' |')
    md.append('| ' + ' | '.join(['---']*len(encabezado)) + ' |')
    md.extend('| ' + ' | '.join(str(x) for x in f) + ' |' for f in filas)
    md.append('')
  def codigos(archivos):
    nonlocal figura
    for archivo in archivos:
      md.extend(['```' + ('sql' if archivo.suffix == '.sql' else 'python'), archivo.read_text(), '```', ''])
      for parte, img in enumerate(imagen_codigo(archivo, carpeta / 'evidencias'), 1):
        doc.add_page_break()
        p=doc.add_paragraph('Figura ' + str(figura)); formato(p, True); p.runs[0].bold=True
        p=doc.add_paragraph(f'Listado de {archivo.name}, parte {parte}'); formato(p, True); p.runs[0].italic=True
        ancho=min(6.0, 6.7 * Image.open(img).width / Image.open(img).height)
        p=doc.add_paragraph(); p.paragraph_format.line_spacing=1; p.add_run().add_picture(str(img), width=Inches(ancho))
        p=doc.add_paragraph('Nota. Imagen del archivo de código; los comentarios identifican a los integrantes.'); formato(p, True)
        p.paragraph_format.space_after=Pt(0)
        for run in p.runs: run.font.size=Pt(9)
        figura += 1

  def evidencia(archivo, descripcion):
    # Captura real proporcionada por el equipo; no se modifica su contenido.
    nonlocal figura
    doc.add_page_break()
    ruta_evidencia = carpeta / 'evidencias' / 'ejecucion_equipo' / archivo
    assert ruta_evidencia.exists(), 'No se encontró la evidencia: ' + str(ruta_evidencia)
    imagen = Image.open(ruta_evidencia)
    proporcion = imagen.width / imagen.height
    ancho = min(6.2, max(3.6, 5.2 * proporcion))
    p = doc.add_paragraph('Figura ' + str(figura)); formato(p, True); p.runs[0].bold = True
    # La imagen es en línea: Word la mueve completa a la página siguiente si no cabe.
    p.paragraph_format.keep_with_next = True
    p.paragraph_format.space_before = Pt(0)
    p = doc.add_paragraph(descripcion); formato(p, True); p.runs[0].italic = True
    p.paragraph_format.keep_with_next = True
    p = doc.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.line_spacing = 1
    p.add_run().add_picture(str(ruta_evidencia), width=Inches(ancho))
    p = doc.add_paragraph('Nota. Captura de ejecución proporcionada por el equipo.'); formato(p, True)
    p.paragraph_format.space_after = Pt(0)
    for run in p.runs: run.font.size = Pt(9)
    md.extend(['Figura ' + str(figura) + '. ' + descripcion, '',
               '![' + descripcion + '](../evidencias/ejecucion_equipo/' + archivo + ')', ''])
    figura += 1

  titulo('CALIDAD DE DATOS Y PYTHON EN EL ALMACÉN', True)
  parrafo('Una base de datos puede tener tablas, permisos y respaldos correctos y aun así recibir información equivocada. En el caso del almacén Pepsi, un precio inválido altera el valor del inventario, un lote mal relacionado puede enviar otra bebida y una fecha incorrecta impide priorizar el producto próximo a caducar. Por eso revisamos los datos antes de utilizarlos para decidir compras y entregas.')
  parrafo('Utilizamos datos ficticios para probar el proceso sin utilizar información real de clientes. Faker mantiene una semilla de 7 para repetir el ejercicio con la misma versión de la biblioteca; Pandas permite revisar, filtrar y transformar cada archivo (Faker, s. f.; pandas, s. f.-a, s. f.-b).')
  if completa:
    parrafo('En esta versión se ejecutó la generación y la limpieza completa de los tres archivos. Se conservaron los CSV originales, las filas descartadas y los resultados de cada validación. La etapa de conexión y reintegración a SQL Server se entrega en código para ejecutarse con una cuenta autorizada.')
  else:
    parrafo('Esta versión presenta el avance con los temas desarrollados en las prácticas: generación de datos, lectura con control de errores, inspección, revisión de nulos y duplicados y normalización de textos. La clasificación integral, los porcentajes y la carga a SQL Server se reservan para la versión completa.')

  titulo('TABLAS SELECCIONADAS Y RELACIONES')
  tabla(['Tabla', 'Clave y relaciones', 'Función'], [
    ['producto', 'PK id_producto; clave_producto única', 'Catálogo de bebidas, presentaciones y precios.'],
    ['lote', 'PK id_lote; FK id_producto a producto; única (id_producto, numero_lote)', 'Identificar recepciones y caducidades.'],
    ['inventario_lote', 'PK id_inventario; FK (id_lote, id_producto) a lote; FK id_almacen a almacen', 'Registrar las unidades del lote en el almacén.']
  ], [1.1, 2.8, 2.0])
  parrafo('Se tomó la estructura de las capturas de creación de tablas del proyecto anterior, específicamente las figuras 6 y 6.1. El almacén 1 sirve como referencia auxiliar; no se genera un cuarto archivo de análisis. No se agregan columnas de ventas ni subtotales que no existían en esas tablas.')

  titulo('RIESGOS Y CONTROLES DE INTEGRIDAD')
  tabla(['Tabla', 'Riesgo', 'Control'], [
    ['producto', 'Un precio negativo o no numérico distorsiona la valuación.', 'Validar tipo y precio mayor que cero; CHECK en SQL Server.'],
    ['lote', 'Una caducidad anterior a la recepción altera la salida de producto.', 'Comparar fechas; CHECK (fecha_caducidad > fecha_recepcion).'],
    ['inventario_lote', 'Relacionar un lote con otro producto o inventar existencias.', 'Verificar cantidad entera no negativa y relación compuesta; FOREIGN KEY.']
  ], [1.1, 2.3, 2.5])
  parrafo('Los controles se implementan en las secciones de validación de cada script y, en la versión completa, también mediante las restricciones del código T-SQL. No se convierten precios o cantidades negativos en positivos sin comprobar su valor real; se separan para revisión.')

  titulo('REGLAS DE NEGOCIO POR COLUMNA')
  for archivo, nombre in [('producto', 'Tabla producto'), ('lote', 'Tabla lote'), ('inventario_lote', 'Tabla inventario_lote')]:
    subtitulo(nombre)
    tabla(['Columna', 'Regla', 'Obligatoriedad y relación'], [fila[1:] for fila in reglas if fila[0] == archivo], [1.4, 2.2, 2.3])
  parrafo('Las claves enteras se limitan al rango de SQL Server INT. No se admiten nulos, texto vacío, espacios externos ni identificadores repetidos. La fecha de corte es el 2 de noviembre de 2026. La presentación se normaliza a minúsculas y las claves de producto y lote a mayúsculas.')

  titulo('DIAGNÓSTICO DE LA CALIDAD DE LOS DATOS')
  for i, (pregunta, respuesta) in enumerate(preguntas, 1):
    parrafo(str(i) + '. ' + pregunta + ' Respuesta: ' + respuesta)

  titulo('GENERACIÓN DE LOS TRES ARCHIVOS CSV')
  parrafo('Cada archivo contiene 50 filas. Primero se generaron registros relacionados y después se incorporaron fallas intencionales. La última fila se reemplazó por una copia exacta de una fila existente para conservar 50 registros en lugar de aumentar el total a 51.')
  parrafo('En producto se incluyeron seis tipos: nulos, duplicados, espacios, mayúsculas o minúsculas inconsistentes, tipos incorrectos y valores inválidos. En lote se incluyeron los nueve tipos de la consigna. En inventario_lote se incluyeron ocho: todos los aplicables, excepto mayúsculas y minúsculas porque sus columnas son numéricas o fechas.')
  codigos([carpeta / 'scripts/01_generar_csv.py'])
  parrafo('Seleccionamos estos errores porque pueden surgir al copiar catálogos, repetir una carga, omitir campos, escribir un precio con texto o capturar una fecha con otra configuración regional. Una relación rota puede aparecer cuando el archivo de existencias llega antes que su catálogo. La discrepancia entre lote y producto simula seleccionar una bebida distinta durante la captura del almacén.')
  tabla(['Error', 'Por qué se prueba', 'Ejemplo en producción'], [
    ['Valor nulo', 'Comprobar campos obligatorios.', 'Se omite el nombre del producto o su cantidad al capturar.'],
    ['Duplicado exacto', 'Evitar contar dos veces la misma información.', 'Se vuelve a cargar el archivo de una recepción.'],
    ['Espacios externos', 'Evitar diferencias falsas al comparar textos.', 'Se copia una clave desde una hoja de cálculo.'],
    ['Mayúsculas y minúsculas', 'Homologar claves y presentaciones.', 'Dos operadores escriben LOT003 y lot003.'],
    ['Formato de fecha', 'Interpretar correctamente recepción y caducidad.', 'Una estación exporta día/mes/año y otra año-mes-día.'],
    ['Tipo incorrecto', 'Detectar texto donde se requiere un número.', 'Se escribe muchas en la cantidad o sin precio en el catálogo.'],
    ['Valor inválido', 'Impedir precios negativos, fechas imposibles o cantidades fraccionarias.', 'Un error de signo registra -12 unidades disponibles.'],
    ['Relación rota', 'Mantener la trazabilidad entre archivos.', 'Llega una existencia que apunta a un lote no registrado.'],
    ['Inconsistencia entre columnas', 'Comprobar que los campos sean compatibles.', 'El lote pertenece a otra bebida o caduca antes de su recepción.']
  ], [1.4, 2.0, 2.5])

  titulo('LECTURA Y BÚSQUEDA DE ERRORES', True)
  parrafo('Cada tabla cuenta con su propio archivo Python. Se utiliza try-except para avisar si falta el CSV y no continuar con datos inexistentes. info() muestra columnas y tipos; shape muestra filas y columnas; head() permite inspeccionar una muestra. La versión completa también emplea describe(include="all") para revisar valores frecuentes y distribución.')
  parrafo('Los errores se buscan por reglas sobre todas las filas; las posiciones usadas por el generador no se utilizan para decidir cuáles registros limpiar. Los valores que no se pueden convertir se detectan con errores controlados en lugar de detener el análisis (pandas, s. f.-a, s. f.-b).')
  for nombre in ['02_revisar_producto.py', '03_revisar_lote.py', '04_revisar_inventario_lote.py']:
    codigos([carpeta / 'scripts' / nombre])
  if not completa:
    parrafo('La revisión parcial encontró nulos, repeticiones y columnas con tipos mezclados. Se homogeneizaron los textos. Se guardan archivos con el sufijo revision_parcial porque todavía no cumplen todas las reglas y no deben utilizarse como datos finales de inventario.')

  titulo('LIMPIEZA Y TRANSFORMACIÓN MEDIANTE ETL', True)
  parrafo('ETL consiste en extraer los datos, transformarlos y cargarlos en un destino. En este proyecto la extracción lee los CSV originales, la transformación detecta y corrige inconsistencias comprobables y la carga reintegra los archivos aptos en SQL Server. Este orden evita trasladar fallas del archivo de origen al sistema operativo del almacén (Microsoft, s. f.-b).')
  if completa:
    parrafo('Se recortaron espacios, se uniformaron textos y se convirtieron dos formatos de fecha conocidos. Se conservó una sola copia de cada duplicado exacto. Los registros con nulos obligatorios, importes no recuperables, cantidades inválidas o relaciones rotas se descartaron del archivo apto, pero permanecen en los archivos de revisión. Los lotes e inventarios se compararon contra sus referencias ya limpias.')
    parrafo('Una fila puede incumplir varias reglas. Para calcular aptos y no aptos se utiliza una condición por fila, de manera que no se suman los errores como si fueran registros diferentes. Después de limpiar se ejecuta la misma función de validación.')
    hallazgos = []
    for t in ['producto','lote','inventario_lote']:
      err = pd.read_csv(carpeta / 'resultados' / (t + '_errores.csv'))
      for col in err.columns[1:]:
        filas = err.loc[err[col].astype(str).str.lower().eq('true'), 'fila_csv'].tolist()
        if not filas: continue
        operacion = ('Normalizar texto' if 'espacios' in col or 'formato' in col else
                     'Conservar una copia; revisar claves' if 'repetida' in col or 'duplicado' in col else
                     'Separar registro si no es recuperable')
        efecto = ('Conteo o valor del inventario incorrecto' if t != 'lote' else 'Trazabilidad o caducidad incorrecta')
        columnas_csv = pd.read_csv(carpeta / 'csv_originales' / (t + '.csv'), nrows=0).columns
        columna = next((c for c in sorted(columnas_csv, key=len, reverse=True) if col.startswith(c + '_')), '')
        if not columna:
          columna = {'duplicado_exacto':'Todas', 'clave_primaria_repetida':columnas_csv[0],
            'clave_negocio_1_repetida':{'producto':'clave_producto','lote':'id_producto / numero_lote','inventario_lote':'id_almacen / id_lote'}[t],
            'producto_inexistente':'id_producto','lote_inexistente':'id_lote','almacen_inexistente':'id_almacen',
            'producto_no_corresponde_lote':'id_lote / id_producto','recepcion_fuera_periodo':'fecha_recepcion',
            'caducidad_antes_recepcion':'fecha_recepcion / fecha_caducidad',
            'actualizacion_fuera_periodo':'fecha_actualizacion'}.get(col, 'Revisar regla')
        hallazgos.append([t + ': ' + col, columna, ', '.join(map(str,filas)), operacion, efecto])
    tabla(['Archivo y error', 'Columna', 'Filas CSV', 'Operación', 'Consecuencia'], hallazgos, [1.5,1.1,0.65,1.4,1.3])
    parrafo('Las filas CSV incluyen el encabezado: la primera fila de datos es la 2. Una fila puede aparecer en más de una regla. Las fallas de relación también incluyen los registros cuyo padre fue descartado al aplicar las reglas de calidad.')
  else:
    parrafo('En este avance se realizaron la extracción y las transformaciones de texto vistas en clase. Permanecen pendientes la limpieza integral, la tabla de errores por fila y la comprobación conjunta de relaciones. No se presenta el avance como un proceso ETL terminado.')

  titulo('VALIDACIÓN Y COMPARACIÓN ANTES Y DESPUÉS')
  if completa:
    datos = pd.read_csv(carpeta / 'resultados/comparacion_antes_despues.csv')
    tabla(['Archivo', 'Iniciales', 'Conservados', 'Corregidos', 'Sin cambios', 'Descartados'],
      [[f.archivo,f.iniciales,f.conservados,f.corregidos,f.sin_cambios,f.descartados] for f in datos.itertuples()], [1.1,.7,1.0,.8,1.0,1.0])
    tabla(['Archivo', 'Aptos antes', 'No aptos antes', 'Aptos después', 'No aptos después'],
      [[f.archivo,f'{f.porcentaje_apto_antes:.0f} %',f'{f.porcentaje_no_apto_antes:.0f} %',f'{f.porcentaje_apto_despues:.0f} %',f'{f.porcentaje_no_apto_despues:.0f} %'] for f in datos.itertuples()], [1.1,1.1,1.2,1.2,1.2])
    parrafo('Conservados significa todas las filas que permanecen: corregidos más sin cambios. Se clasifica como corregido un registro conservado cuyo contenido cambió durante la limpieza. La primera copia de un duplicado permanece sin cambios y la repetición adicional se descarta. Descartados son todas las filas excluidas. Los 100 % aptos finales se calculan sobre los registros conservados, no sobre los 50 originales.')
    parrafo('La validación final no encontró nulos obligatorios, claves repetidas, valores inválidos ni referencias rotas en los archivos exportados. Esto comprueba las reglas definidas para el ejercicio; no demuestra que los datos ficticios correspondan al inventario real de Pepsi.')
    titulo('EVIDENCIAS DE LA VALIDACIÓN DE LOS CSV')
    parrafo('Las siguientes capturas muestran la inspección inicial, las reglas que detectaron errores y el resumen final de los tres archivos. En los tres casos la validación posterior a la limpieza reportó cero filas no aptas.')
    evidencia('01_producto_estructura.png', 'Inspección inicial del archivo producto.')
    evidencia('02_producto_reglas.png', 'Reglas de calidad detectadas en producto.')
    evidencia('03_producto_resultado.png', 'Resultado de limpieza y validación final de producto.')
    evidencia('04_lote_estructura.png', 'Inspección inicial del archivo lote.')
    evidencia('05_lote_reglas.png', 'Reglas de calidad detectadas en lote.')
    evidencia('06_lote_resultado.png', 'Resultado de limpieza y validación final de lote.')
    evidencia('07_inventario_estructura.png', 'Inspección inicial del archivo inventario_lote.')
    evidencia('08_inventario_reglas.png', 'Reglas de calidad detectadas en inventario_lote.')
    evidencia('09_inventario_resultado.png', 'Resultado de limpieza y validación final de inventario_lote.')
  else:
    parrafo('Los tres archivos originales conservan 50 filas. El avance no calcula porcentajes integrales ni certifica que las revisiones parciales estén limpias. La comparación completa y el conteo de corregidos y descartados se encuentran resueltos en la segunda versión.')

  titulo('EXPORTACIÓN Y REINTEGRACIÓN EN SQL SERVER')
  parrafo('Se exportan archivos CSV con index=False para evitar que el índice interno de Pandas se convierta en una columna del almacén. Los acentos se conservan con UTF-8. Los archivos de origen permanecen separados de los resultados corregidos.')
  if completa:
    parrafo('La reintegración se prepara en el esquema proyecto_u2 de pepsi_distribucion. Esto mantiene las tablas originales de dbo y evita reemplazar sus datos. Primero se debe ejecutar el código de creación; después, el script Python solicita usuario y contraseña de SQL Server. La contraseña no se escribe en los archivos. El controlador utilizado es ODBC Driver 18 for SQL Server, disponible en Linux.')
    parrafo('El orden es almacen, producto, lote e inventario_lote para respetar las relaciones. La carga se realiza en una transacción: si falla una inserción, no se confirma el conjunto. El programa también verifica que el destino esté vacío para evitar cargar los mismos registros dos veces (SQLAlchemy, s. f.). Las capturas recibidas del equipo confirman la carga de un almacén, 44 productos, 42 lotes y 42 inventarios. Fueron tomadas en Windows con autenticación integrada; el script de este proyecto conserva la adaptación para Linux mediante usuario y contraseña de SQL Server.')
    codigos([carpeta / 'scripts/00_preparar_sql.sql', carpeta / 'scripts/05_cargar_sql.py'])
    titulo('EVIDENCIAS DE CARGA Y CONSULTAS EN SQL SERVER')
    parrafo('La salida de carga confirma la transacción y los conteos de filas exportadas. Las consultas mostradas después verifican que los registros limpios quedaron disponibles en las tablas producto, lote e inventario_lote del esquema proyecto_u2.')
    evidencia('10_carga_sql_server.png', 'Carga confirmada de los datos limpios en SQL Server.')
    evidencia('11_consulta_producto.png', 'Consulta de registros cargados en producto.')
    evidencia('12_consulta_lote.png', 'Consulta de registros cargados en lote.')
    evidencia('13_consulta_inventario_lote.png', 'Consulta de registros cargados en inventario_lote.')
  else:
    parrafo('La exportación parcial ya está implementada. La conexión desde Python y la inserción con transacciones se dejan pendientes porque aún no están desarrolladas en las prácticas revisadas. No se deben cargar estos archivos parciales a la base de datos.')

  titulo('CONSULTAS Y EFECTO DE LOS DATOS INCORRECTOS')
  parrafo('La primera consulta suma unidades y calcula el valor del inventario por producto. Un precio negativo o una existencia duplicada habría alterado ese valor. La segunda identifica lotes próximos a caducar: una fecha mal interpretada cambia la prioridad de despacho. La tercera calcula promedio, mínimo y máximo de precios; un precio inválido puede distorsionar estos indicadores o impedir el cálculo.')
  titulo('TABLA TEMPORAL Y VISTA ENCRIPTADA')
  parrafo('La tabla temporal prepara un resumen para revisar existencias durante la misma conexión, sin modificar los registros del almacén. Puede utilizarse para organizar la revisión de cantidades y valores antes de un reporte. La vista reúne la consulta de existencias para reutilizarla.')
  parrafo('WITH ENCRYPTION oculta la definición de la vista en las consultas habituales del catálogo; no cifra los datos que devuelve ni sustituye los permisos. Debe conservarse el código fuente para mantenimiento y se deben revisar sus limitaciones de publicación y replicación (Microsoft, s. f.-a).')
  if completa:
    codigos([carpeta / 'scripts/06_consultas.sql'])
    parrafo('El archivo contiene tres consultas con WHERE, ORDER BY y agregaciones, además de la tabla temporal y la vista. Las evidencias siguientes muestran la ejecución de las consultas, de la tabla temporal y de la vista encriptada.')
    evidencia('Imagen1.png', 'Resultado de la consulta de lotes próximos a caducar.')
    evidencia('Imagen2.png', 'Resultado de la consulta de comparación de precios por producto.')
    evidencia('Imagen3.png', 'Ejecución de la creación y carga de la tabla temporal de revisión.')
    evidencia('Imagen4.png', 'Resultado de la tabla temporal ordenada por valor de inventario.')
    evidencia('Imagen5.png', 'Creación correcta de la vista encriptada de existencias.')
    evidencia('Imagen6.png', 'Resultado de la consulta realizada a la vista encriptada.')
    evidencia('Imagen7.png', 'Comprobación de que la vista se encuentra encriptada.')
  else:
    parrafo('Estos temas tienen antecedentes en 1BD y se conservan como repaso. Se incluyen los scripts de estructura y consultas conocidos; sus resultados quedan pendientes de la carga de datos desde Python.')
    codigos([carpeta / 'scripts/00_preparar_sql.sql', carpeta / 'scripts/06_consultas.sql'])

  titulo('CONCLUSIÓN ACTUALIZADA')
  if completa:
    parrafo('Con este proyecto relacionamos la administración de la base de datos con la calidad de la información que recibe. Python permitió generar registros, encontrar fallas y corregir únicamente lo que podía comprobarse. La validación evitó aceptar cantidades, precios o relaciones incorrectas que afectarían las decisiones del almacén.')
    parrafo('El proceso ETL permitió conservar el origen, transformar los datos y preparar su reintegración. También comprendimos que un archivo con menos errores no basta: debemos revisar nuevamente sus reglas, justificar los descartes y comprobar sus relaciones. La carga en SQL Server y las consultas completan el proceso cuando se ejecutan y verifican con sus evidencias.')
  else:
    parrafo('Con los temas vistos pudimos generar los archivos, revisar su estructura y detectar fallas iniciales. También aplicamos limpieza de textos. Para completar ETL todavía necesitamos medir los registros aptos, revisar todas las relaciones, justificar las correcciones y realizar la carga en SQL Server. Este avance permite continuar desde procedimientos que ya hemos practicado.')

  titulo('REFERENCIAS DE LA UNIDAD II')
  for ref in referencias:
    p=parrafo(ref); p.paragraph_format.first_line_indent=Inches(-.5); p.paragraph_format.left_indent=Inches(.5)

  titulo('ANEXO INTERNO PARA REVISIÓN DEL EQUIPO', True)
  # Este anexo es la página adicional solicitada; puede retirarse al entregar.
  notas = [
    'Se corrigió la matriz de grupos de archivos: pedido y detalle_pedido pertenecen a PRIMARY; lote a SECUNDARIO, de acuerdo con las capturas.',
    'Las figuras de Unidad I son evidencias históricas del documento recibido y muestran Windows/SSMS. La ejecución de Unidad II se realiza en Linux; no representan una nueva prueba local.',
    'Revisar la afirmación del trigger de inventario: las capturas mostradas no incluyen su CREATE TRIGGER. No se debe dar por comprobada esa creación sin el código o su consulta de verificación.',
    'La captura de detalle_entrega valida cantidades no negativas, pero no incluye cantidad_danada <= cantidad_entregada. Agregar el CHECK en otra evidencia si se mantiene esa afirmación.',
    'Revisar antes de entregar la versión/edición de SQL Server, horarios y RPO/RTO del documento anterior. Las metas propuestas no prueban por sí solas que existan trabajos programados.',
    'Los listados de código se generan desde los archivos reales. Las evidencias de ejecución agregadas corresponden a capturas del equipo; conservar los comentarios con los apellidos en las futuras capturas del editor.',
    'La evidencia de carga se obtuvo en Windows con Trusted Connection. El script entregado usa autenticación de SQL Server en Linux; no se debe afirmar que la captura comprueba por sí sola esa configuración local.',
    'Pendiente: capturar los resultados de las tres consultas con filtros y agregaciones, de la tabla temporal y de la vista encriptada en SQL Server.',
  ]
  if not completa: notas.append('Esta versión es un avance de lo visto en clase y no cumple todavía todos los requisitos de entrega. Utilizar la versión completa para continuar.')
  for nota in notas:
    p=doc.add_paragraph(nota); formato(p); p.paragraph_format.line_spacing=1; p.paragraph_format.space_after=Pt(7)

  # Crear entradas de índice con longitud estable; una segunda pasada actualizará páginas.
  for t in dict.fromkeys(titulos_indice):
    if t == 'CALIDAD DE DATOS Y PYTHON EN EL ALMACÉN':
      p = primera_intro.insert_paragraph_before('ÍNDICE DE LA UNIDAD II')
      formato(p, True); p.paragraph_format.page_break_before = True
      p.runs[0].bold = True
    p = primera_intro.insert_paragraph_before(t + '\t---')
    p.style = doc.styles['Normal']; formato(p, True)
    p.paragraph_format.line_spacing=1
    p.paragraph_format.space_after=Pt(4)
    p.paragraph_format.tab_stops.add_tab_stop(Inches(5.7))
  # Quitar saltos dentro de párrafos vacíos inmediatamente anteriores a la introducción.
  # El índice conserva su propio salto y la introducción empieza en página independiente.
  settings = doc.settings.element
  actualiza = OxmlElement('w:updateFields'); actualiza.set(qn('w:val'),'true'); settings.append(actualiza)
  # Nuevas tablas sin alturas fijas y cuerpo de lectura APA.
  doc.core_properties.title = 'Proyecto Unidad 2 Calidad de datos del almacén Pepsi'
  doc.core_properties.author = 'Juan Manuel Ortega García; Bernardo Guillermo Núñez López; Carlos Gabriel Rodríguez Macias'
  for seccion in doc.sections:
    pie = seccion.footer.paragraphs[0]
    pie.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    campo = OxmlElement('w:fldSimple'); campo.set(qn('w:instr'), 'PAGE')
    pie._p.append(campo)
  doc.save(salida)
  (carpeta / 'documentos' / 'Proyecto_Unidad_2.md').write_text('\n'.join(md), encoding='utf-8')
  (carpeta / 'resultados' / 'indice_secciones.json').write_text(json.dumps(list(dict.fromkeys(titulos_indice)), ensure_ascii=False, indent=2))
  # Las imágenes históricas no deben perderse ni cambiar.
  with ZipFile(base) as a, ZipFile(salida) as b:
    for name in a.namelist():
      if name.startswith('word/media/'):
        assert a.read(name) == b.read(name), 'Se modificó una imagen histórica.'
  print(salida)

if __name__ == '__main__':
  versiones = sys.argv[1:] or ['01_version_actual','02_version_completa']
  for version in versiones:
    assert version in ['01_version_actual','02_version_completa']
    crear(version)

"""Actualizar páginas del índice contra el PDF renderizado, sin modificar la base."""
from pathlib import Path
import json
import re
import unicodedata
from docx import Document
from docx.shared import Pt, RGBColor
from pypdf import PdfReader

ruta = Path(__file__).resolve().parent.parent

def normalizar(texto):
  texto = ''.join(c for c in unicodedata.normalize('NFKD', texto) if not unicodedata.combining(c))
  return re.sub(r'\s+', '', texto).upper()

for version, render in [('01_version_actual','revision_actual'),('02_version_completa','revision_completa')]:
  docx = ruta / version / 'documentos/Proyecto_Unidad_2.docx'
  # Si existe una revisión más reciente de la versión completa, usarla.
  carpeta_revision = ruta / 'herramientas' / render
  if version == '02_version_completa':
    evidencia_revision = ruta / 'herramientas' / 'revision_completa_evidencias'
    if (evidencia_revision / 'Proyecto_Unidad_2.pdf').exists():
      carpeta_revision = evidencia_revision
  pdf = carpeta_revision / 'Proyecto_Unidad_2.pdf'
  paginas = [p.extract_text() or '' for p in PdfReader(pdf).pages]
  inicio = next(i for i,p in enumerate(paginas) if 'El presente proyecto desarrolla' in p)
  normalizadas = [normalizar(p) for p in paginas]
  doc = Document(docx)
  encontrados = {}
  for p in doc.paragraphs:
    if '\t' not in p.text:
      continue
    titulo = p.text.split('\t')[0]
    if titulo not in json.loads((ruta / version / 'resultados/indice_secciones.json').read_text()):
      continue
    n = next((i+1 for i in range(inicio,len(paginas)) if normalizar(titulo) in normalizadas[i]), None)
    if n is None:
      raise RuntimeError('No se encontró el encabezado: ' + titulo)
    for run in p.runs:
      run.text = ''
    run = p.add_run(titulo + '\t' + str(n))
    run.font.name = 'Times New Roman'
    run.font.size = Pt(12)
    run.font.color.rgb = RGBColor(0, 0, 0)
    encontrados[titulo] = n
  doc.save(docx)
  (ruta / version / 'resultados/indice_paginas.json').write_text(json.dumps(encontrados,ensure_ascii=False,indent=2))
  print(version, len(encontrados), 'entradas actualizadas.')

#!/usr/bin/env python3

import re
import sys
from pathlib import Path

from PIL import Image
from docx import Document
from docx.enum.section import WD_SECTION
from docx.enum.table import WD_ALIGN_VERTICAL, WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Inches, Pt, RGBColor


FUENTE = "Times New Roman"
AZUL = RGBColor(31, 78, 121)
AZUL_OSCURO = RGBColor(24, 55, 89)
GRIS = RGBColor(89, 89, 89)
NEGRO = RGBColor(0, 0, 0)


def configurar_fuente(run, tamano=11, negrita=None, cursiva=None, color=NEGRO):
    run.font.name = FUENTE
    run._element.get_or_add_rPr().rFonts.set(qn("w:ascii"), FUENTE)
    run._element.get_or_add_rPr().rFonts.set(qn("w:hAnsi"), FUENTE)
    run._element.get_or_add_rPr().rFonts.set(qn("w:eastAsia"), FUENTE)
    run.font.size = Pt(tamano)
    run.font.color.rgb = color
    if negrita is not None:
        run.bold = negrita
    if cursiva is not None:
        run.italic = cursiva


def configurar_estilo(estilo, tamano, negrita=False, cursiva=False, color=NEGRO):
    estilo.font.name = FUENTE
    estilo._element.get_or_add_rPr().rFonts.set(qn("w:ascii"), FUENTE)
    estilo._element.get_or_add_rPr().rFonts.set(qn("w:hAnsi"), FUENTE)
    estilo._element.get_or_add_rPr().rFonts.set(qn("w:eastAsia"), FUENTE)
    estilo.font.size = Pt(tamano)
    estilo.font.bold = negrita
    estilo.font.italic = cursiva
    estilo.font.color.rgb = color


def sombrear_celda(celda, color):
    tc_pr = celda._tc.get_or_add_tcPr()
    shd = tc_pr.find(qn("w:shd"))
    if shd is None:
        shd = OxmlElement("w:shd")
        tc_pr.append(shd)
    shd.set(qn("w:fill"), color)


def margen_celda(celda, superior=80, inferior=80, inicio=120, fin=120):
    tc_pr = celda._tc.get_or_add_tcPr()
    tc_mar = tc_pr.find(qn("w:tcMar"))
    if tc_mar is None:
        tc_mar = OxmlElement("w:tcMar")
        tc_pr.append(tc_mar)
    for nombre, valor in (("top", superior), ("bottom", inferior), ("start", inicio), ("end", fin)):
        nodo = tc_mar.find(qn(f"w:{nombre}"))
        if nodo is None:
            nodo = OxmlElement(f"w:{nombre}")
            tc_mar.append(nodo)
        nodo.set(qn("w:w"), str(valor))
        nodo.set(qn("w:type"), "dxa")


def ancho_celda(celda, ancho):
    tc_pr = celda._tc.get_or_add_tcPr()
    tc_w = tc_pr.find(qn("w:tcW"))
    if tc_w is None:
        tc_w = OxmlElement("w:tcW")
        tc_pr.append(tc_w)
    tc_w.set(qn("w:w"), str(ancho))
    tc_w.set(qn("w:type"), "dxa")


def configurar_tabla(tabla, anchos):
    tabla.autofit = False
    tbl_pr = tabla._tbl.tblPr

    tbl_w = tbl_pr.find(qn("w:tblW"))
    if tbl_w is None:
        tbl_w = OxmlElement("w:tblW")
        tbl_pr.append(tbl_w)
    tbl_w.set(qn("w:w"), str(sum(anchos)))
    tbl_w.set(qn("w:type"), "dxa")

    tbl_ind = tbl_pr.find(qn("w:tblInd"))
    if tbl_ind is None:
        tbl_ind = OxmlElement("w:tblInd")
        tbl_pr.append(tbl_ind)
    tbl_ind.set(qn("w:w"), "120")
    tbl_ind.set(qn("w:type"), "dxa")

    tbl_layout = tbl_pr.find(qn("w:tblLayout"))
    if tbl_layout is None:
        tbl_layout = OxmlElement("w:tblLayout")
        tbl_pr.append(tbl_layout)
    tbl_layout.set(qn("w:type"), "fixed")

    grid = tabla._tbl.tblGrid
    for elemento in list(grid):
        grid.remove(elemento)
    for ancho in anchos:
        columna = OxmlElement("w:gridCol")
        columna.set(qn("w:w"), str(ancho))
        grid.append(columna)

    for fila in tabla.rows:
        tr_pr = fila._tr.get_or_add_trPr()
        no_dividir = OxmlElement("w:cantSplit")
        tr_pr.append(no_dividir)
        for indice, celda in enumerate(fila.cells):
            ancho_celda(celda, anchos[indice])
            margen_celda(celda)
            celda.vertical_alignment = WD_ALIGN_VERTICAL.CENTER


def borde_inferior(parrafo, color="B4C6E7", grosor="6"):
    p_pr = parrafo._p.get_or_add_pPr()
    p_bdr = p_pr.find(qn("w:pBdr"))
    if p_bdr is None:
        p_bdr = OxmlElement("w:pBdr")
        p_pr.append(p_bdr)
    borde = OxmlElement("w:bottom")
    borde.set(qn("w:val"), "single")
    borde.set(qn("w:sz"), grosor)
    borde.set(qn("w:space"), "4")
    borde.set(qn("w:color"), color)
    p_bdr.append(borde)


def agregar_numero_pagina(parrafo):
    parrafo.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = parrafo.add_run()
    configurar_fuente(run, 9, color=GRIS)
    inicio = OxmlElement("w:fldChar")
    inicio.set(qn("w:fldCharType"), "begin")
    instruccion = OxmlElement("w:instrText")
    instruccion.set(qn("xml:space"), "preserve")
    instruccion.text = " PAGE "
    fin = OxmlElement("w:fldChar")
    fin.set(qn("w:fldCharType"), "end")
    run._r.extend([inicio, instruccion, fin])


def configurar_seccion(seccion):
    seccion.page_width = Inches(8.5)
    seccion.page_height = Inches(11)
    seccion.top_margin = Inches(1)
    seccion.bottom_margin = Inches(1)
    seccion.left_margin = Inches(1)
    seccion.right_margin = Inches(1)
    seccion.header_distance = Inches(0.49)
    seccion.footer_distance = Inches(0.49)


def agregar_texto_formateado(parrafo, texto, tamano=11, color=NEGRO):
    patron = re.compile(r"(\*\*.*?\*\*|`.*?`|\*.*?\*)")
    posicion = 0
    for coincidencia in patron.finditer(texto):
        if coincidencia.start() > posicion:
            run = parrafo.add_run(texto[posicion:coincidencia.start()])
            configurar_fuente(run, tamano, color=color)
        token = coincidencia.group(0)
        if token.startswith("**"):
            contenido = token[2:-2]
            run = parrafo.add_run(contenido)
            configurar_fuente(run, tamano, negrita=True, color=color)
        elif token.startswith("`"):
            contenido = token[1:-1]
            run = parrafo.add_run(contenido)
            configurar_fuente(run, tamano, color=AZUL_OSCURO)
        else:
            contenido = token[1:-1]
            run = parrafo.add_run(contenido)
            configurar_fuente(run, tamano, cursiva=True, color=color)
        posicion = coincidencia.end()
    if posicion < len(texto):
        run = parrafo.add_run(texto[posicion:])
        configurar_fuente(run, tamano, color=color)


def agregar_imagen(documento, ruta, pie=None, salto_pagina=False):
    with Image.open(ruta) as imagen:
        ancho_px, alto_px = imagen.size
    proporcion = ancho_px / alto_px
    ancho_maximo = 6.0
    alto_maximo = 6.2
    ancho_natural = ancho_px / 120
    alto_natural = alto_px / 120
    escala = min(1.0, ancho_maximo / ancho_natural, alto_maximo / alto_natural)
    ancho = max(2.4, ancho_natural * escala)
    alto = ancho / proporcion
    if alto > alto_maximo:
        alto = alto_maximo
        ancho = alto * proporcion
    if ancho > ancho_maximo:
        ancho = ancho_maximo
        alto = ancho / proporcion

    if salto_pagina:
        nueva_seccion = documento.add_section(WD_SECTION.NEW_PAGE)
        configurar_seccion(nueva_seccion)
        nueva_seccion.different_first_page_header_footer = False
        nueva_seccion.header.is_linked_to_previous = True
        nueva_seccion.even_page_header.is_linked_to_previous = True
        nueva_seccion.footer.is_linked_to_previous = True
        nueva_seccion.even_page_footer.is_linked_to_previous = True
        pg_num = nueva_seccion._sectPr.find(qn("w:pgNumType"))
        if pg_num is not None:
            nueva_seccion._sectPr.remove(pg_num)

    tabla = documento.add_table(rows=1, cols=1)
    tabla.alignment = WD_TABLE_ALIGNMENT.CENTER
    tabla.autofit = False
    bordes = OxmlElement("w:tblBorders")
    for lado in ("top", "left", "bottom", "right", "insideH", "insideV"):
        borde = OxmlElement(f"w:{lado}")
        borde.set(qn("w:val"), "nil")
        bordes.append(borde)
    tabla._tbl.tblPr.append(bordes)

    fila = tabla.rows[0]
    propiedades_fila = fila._tr.get_or_add_trPr()
    propiedades_fila.append(OxmlElement("w:cantSplit"))
    celda = fila.cells[0]
    celda.width = Inches(6.2)
    celda.vertical_alignment = WD_ALIGN_VERTICAL.CENTER
    propiedades_celda = celda._tc.get_or_add_tcPr()
    margenes = OxmlElement("w:tcMar")
    for lado in ("top", "left", "bottom", "right"):
        margen = OxmlElement(f"w:{lado}")
        margen.set(qn("w:w"), "0")
        margen.set(qn("w:type"), "dxa")
        margenes.append(margen)
    propiedades_celda.append(margenes)

    parrafo = celda.paragraphs[0]
    parrafo.alignment = WD_ALIGN_PARAGRAPH.CENTER
    parrafo.paragraph_format.space_before = Pt(5)
    parrafo.paragraph_format.space_after = Pt(9)
    parrafo.paragraph_format.keep_together = True
    run = parrafo.add_run()
    run.add_picture(str(ruta), width=Inches(ancho), height=Inches(alto))
    if pie:
        salto = parrafo.add_run()
        salto.add_break()
        run_pie = parrafo.add_run(pie)
        configurar_fuente(run_pie, 9, cursiva=True, color=GRIS)
    return alto


def agregar_tabla_markdown(documento, filas):
    encabezados = [celda.strip() for celda in filas[0].strip().strip("|").split("|")]
    cuerpo = []
    for fila in filas[2:]:
        cuerpo.append([celda.strip() for celda in fila.strip().strip("|").split("|")])

    tabla = documento.add_table(rows=1, cols=len(encabezados))
    tabla.style = "Table Grid"
    configurar_tabla(tabla, [4680, 4680])

    for indice, texto in enumerate(encabezados):
        celda = tabla.rows[0].cells[indice]
        sombrear_celda(celda, "D9E2F3")
        parrafo = celda.paragraphs[0]
        parrafo.alignment = WD_ALIGN_PARAGRAPH.CENTER
        parrafo.paragraph_format.space_after = Pt(0)
        agregar_texto_formateado(parrafo, texto, 10.5, AZUL_OSCURO)
        for run in parrafo.runs:
            run.bold = True

    tr_pr = tabla.rows[0]._tr.get_or_add_trPr()
    encabezado_repetido = OxmlElement("w:tblHeader")
    encabezado_repetido.set(qn("w:val"), "true")
    tr_pr.append(encabezado_repetido)

    for datos in cuerpo:
        celdas = tabla.add_row().cells
        for indice, texto in enumerate(datos):
            ancho_celda(celdas[indice], 4680)
            margen_celda(celdas[indice])
            celdas[indice].vertical_alignment = WD_ALIGN_VERTICAL.CENTER
            parrafo = celdas[indice].paragraphs[0]
            parrafo.paragraph_format.space_after = Pt(0)
            parrafo.paragraph_format.line_spacing = 1.05
            agregar_texto_formateado(parrafo, texto, 10)

    documento.add_paragraph().paragraph_format.space_after = Pt(0)


def crear_documento(origen, salida):
    lineas = origen.read_text(encoding="utf-8").splitlines()
    documento = Document()
    documento.core_properties.title = "Actividad 5. Auditorías"
    documento.core_properties.author = "Rodríguez Macias Carlos Gabriel"
    documento.core_properties.subject = "Temas Selectos de Tratamiento de Información"

    for seccion in documento.sections:
        configurar_seccion(seccion)

    normal = documento.styles["Normal"]
    configurar_estilo(normal, 11)
    normal.paragraph_format.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    normal.paragraph_format.space_before = Pt(0)
    normal.paragraph_format.space_after = Pt(6)
    normal.paragraph_format.line_spacing = 1.15

    h1 = documento.styles["Heading 1"]
    configurar_estilo(h1, 16, negrita=True, color=AZUL_OSCURO)
    h1.paragraph_format.space_before = Pt(16)
    h1.paragraph_format.space_after = Pt(8)
    h1.paragraph_format.keep_with_next = True

    h2 = documento.styles["Heading 2"]
    configurar_estilo(h2, 13, negrita=True, color=AZUL)
    h2.paragraph_format.space_before = Pt(12)
    h2.paragraph_format.space_after = Pt(6)
    h2.paragraph_format.keep_with_next = True

    h3 = documento.styles["Heading 3"]
    configurar_estilo(h3, 12, negrita=True, color=AZUL_OSCURO)
    h3.paragraph_format.space_before = Pt(9)
    h3.paragraph_format.space_after = Pt(4)
    h3.paragraph_format.keep_with_next = True

    configurar_estilo(documento.styles["Caption"], 9, cursiva=True, color=GRIS)
    configurar_estilo(documento.styles["List Bullet"], 11)
    configurar_estilo(documento.styles["List Number"], 11)

    titulo = lineas[0][2:].strip()
    parrafo_titulo = documento.add_paragraph()
    parrafo_titulo.alignment = WD_ALIGN_PARAGRAPH.CENTER
    parrafo_titulo.paragraph_format.space_before = Inches(1.65)
    parrafo_titulo.paragraph_format.space_after = Pt(18)
    run = parrafo_titulo.add_run(titulo)
    configurar_fuente(run, 25, negrita=True, color=AZUL_OSCURO)

    regla = documento.add_paragraph()
    regla.paragraph_format.space_after = Pt(32)
    borde_inferior(regla, "4472C4", "10")

    indice = 1
    while indice < len(lineas) and lineas[indice].strip() != "---":
        texto = lineas[indice].strip()
        if texto:
            parrafo = documento.add_paragraph()
            parrafo.alignment = WD_ALIGN_PARAGRAPH.CENTER
            parrafo.paragraph_format.space_after = Pt(7)
            agregar_texto_formateado(parrafo, texto, 11.5)
        indice += 1

    seccion_portada = documento.sections[0]
    configurar_seccion(seccion_portada)
    seccion_cuerpo = documento.add_section(WD_SECTION.NEW_PAGE)
    configurar_seccion(seccion_cuerpo)
    documento.settings.odd_and_even_pages_header_footer = True
    seccion_cuerpo.different_first_page_header_footer = True

    encabezados = (
        seccion_cuerpo.header,
        seccion_cuerpo.even_page_header,
        seccion_cuerpo.first_page_header,
    )
    pies = (
        seccion_cuerpo.footer,
        seccion_cuerpo.even_page_footer,
        seccion_cuerpo.first_page_footer,
    )
    for encabezado_contenedor in encabezados:
        encabezado_contenedor.is_linked_to_previous = False
        encabezado = encabezado_contenedor.paragraphs[0]
        encabezado.paragraph_format.space_after = Pt(2)
        run = encabezado.add_run(titulo)
        configurar_fuente(run, 9, negrita=True, color=GRIS)
        borde_inferior(encabezado, "D9E2F3", "4")
    for pie_contenedor in pies:
        pie_contenedor.is_linked_to_previous = False
        agregar_numero_pagina(pie_contenedor.paragraphs[0])

    sect_pr = seccion_cuerpo._sectPr
    pg_num = sect_pr.find(qn("w:pgNumType"))
    if pg_num is None:
        pg_num = OxmlElement("w:pgNumType")
        sect_pr.append(pg_num)
    pg_num.set(qn("w:start"), "1")

    indice += 1
    en_codigo = False
    primer_h1 = True
    ultima_fue_imagen = False
    altura_ultima_imagen = 0
    numero_imagen = 0
    while indice < len(lineas):
        linea = lineas[indice]
        texto = linea.strip()

        if texto.startswith("```"):
            en_codigo = not en_codigo
            indice += 1
            continue
        if en_codigo:
            indice += 1
            continue
        if not texto:
            indice += 1
            continue

        if texto.startswith("|" ):
            ultima_fue_imagen = False
            filas = []
            while indice < len(lineas) and lineas[indice].strip().startswith("|"):
                filas.append(lineas[indice].strip())
                indice += 1
            agregar_tabla_markdown(documento, filas)
            continue

        imagen = re.match(r"!\[(.*?)\]\((.*?)\)", texto)
        if imagen:
            ruta = (origen.parent / imagen.group(2)).resolve()
            siguiente = indice + 1
            while siguiente < len(lineas) and not lineas[siguiente].strip():
                siguiente += 1
            pie_siguiente = None
            if siguiente < len(lineas):
                coincidencia_pie = re.match(
                    r'<p align="center"><em>(.*?)</em></p>',
                    lineas[siguiente].strip(),
                )
                if coincidencia_pie:
                    pie_siguiente = coincidencia_pie.group(1)
            salto_pagina = numero_imagen > 0
            altura_ultima_imagen = agregar_imagen(
                documento,
                ruta,
                pie_siguiente,
                salto_pagina,
            )
            numero_imagen += 1
            ultima_fue_imagen = True
            indice = siguiente + 1 if pie_siguiente else indice + 1
            continue

        pie = re.match(r'<p align="center"><em>(.*?)</em></p>', texto)
        if pie:
            ultima_fue_imagen = False
            parrafo = documento.add_paragraph(style="Caption")
            parrafo.alignment = WD_ALIGN_PARAGRAPH.CENTER
            parrafo.paragraph_format.space_before = Pt(0)
            parrafo.paragraph_format.space_after = Pt(9)
            parrafo.paragraph_format.keep_together = True
            run = parrafo.add_run(pie.group(1))
            configurar_fuente(run, 9, cursiva=True, color=GRIS)
            indice += 1
            continue

        if texto.startswith("### "):
            ultima_fue_imagen = False
            documento.add_heading(texto[4:].strip(), level=3)
            indice += 1
            continue
        if texto.startswith("## "):
            ultima_fue_imagen = False
            documento.add_heading(texto[3:].strip(), level=2)
            indice += 1
            continue
        if texto.startswith("# "):
            ultima_fue_imagen = False
            parrafo = documento.add_heading(texto[2:].strip(), level=1)
            primer_h1 = False
            indice += 1
            continue

        if texto.startswith("- "):
            ultima_fue_imagen = False
            parrafo = documento.add_paragraph(style="List Bullet")
            parrafo.paragraph_format.left_indent = Inches(0.5)
            parrafo.paragraph_format.first_line_indent = Inches(-0.25)
            parrafo.paragraph_format.space_after = Pt(4)
            parrafo.paragraph_format.line_spacing = 1.15
            agregar_texto_formateado(parrafo, texto[2:].strip())
            indice += 1
            continue

        numerada = re.match(r"^(\d+)\.\s+(.*)$", texto)
        if numerada:
            ultima_fue_imagen = False
            parrafo = documento.add_paragraph(style="List Number")
            parrafo.paragraph_format.left_indent = Inches(0.5)
            parrafo.paragraph_format.first_line_indent = Inches(-0.25)
            parrafo.paragraph_format.space_after = Pt(4)
            agregar_texto_formateado(parrafo, numerada.group(2))
            indice += 1
            continue

        ultima_fue_imagen = False
        parrafo = documento.add_paragraph()
        agregar_texto_formateado(parrafo, texto)
        indice += 1

    actualizar_campos = documento.settings.element.find(qn("w:updateFields"))
    if actualizar_campos is None:
        actualizar_campos = OxmlElement("w:updateFields")
        documento.settings.element.append(actualizar_campos)
    actualizar_campos.set(qn("w:val"), "true")
    salida.parent.mkdir(parents=True, exist_ok=True)
    documento.save(salida)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit("Uso: generar_word_actividad_5.py origen.md salida.docx")
    crear_documento(Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve())

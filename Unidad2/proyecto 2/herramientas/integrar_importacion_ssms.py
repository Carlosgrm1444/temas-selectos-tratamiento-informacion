from pathlib import Path
from shutil import copy2
import re

from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn
from docx.shared import Inches, Pt


ruta_proyecto = Path(__file__).resolve().parents[1]
ruta_origen = Path("/home/carlos-rodriguez/Descargas/Proyecto_Unidad_I_y_II.docx")
ruta_salida = ruta_proyecto / "03_version_final_ssms/documentos/Proyecto_Unidad_I_y_II.docx"
ruta_imagenes = ruta_proyecto / "03_version_final_ssms/evidencias/importacion_ssms"
ruta_codigo_original = ruta_proyecto / "02_version_completa/evidencias/05_cargar_sql_03.png"
ruta_codigo_final = ruta_proyecto / "03_version_final_ssms/evidencias/codigo_sql/05_cargar_sql_03.png"


def mover_despues(parrafo_base, parrafo_nuevo):
    parrafo_base._p.addnext(parrafo_nuevo._p)


def configurar_fuente(run, negritas=False):
    run.font.name = "Times New Roman"
    run._element.rPr.rFonts.set(qn("w:ascii"), "Times New Roman")
    run._element.rPr.rFonts.set(qn("w:hAnsi"), "Times New Roman")
    run.font.size = Pt(10)
    run.bold = negritas


def agregar_parrafo(documento, parrafo_base, texto, estilo="Normal", alineacion=None):
    parrafo = documento.add_paragraph(style=estilo)
    run = parrafo.add_run(texto)
    configurar_fuente(run, negritas=texto.startswith("IMAGEN"))
    if alineacion is not None:
        parrafo.alignment = alineacion
    mover_despues(parrafo_base, parrafo)
    return parrafo


def agregar_imagen(documento, parrafo_base, imagen, descripcion):
    parrafo_imagen = documento.add_paragraph()
    parrafo_imagen.alignment = WD_ALIGN_PARAGRAPH.CENTER
    parrafo_imagen.add_run().add_picture(str(imagen), width=Inches(5.9))
    mover_despues(parrafo_base, parrafo_imagen)

    caption = agregar_parrafo(
        documento,
        parrafo_imagen,
        descripcion,
        alineacion=WD_ALIGN_PARAGRAPH.CENTER,
    )
    caption.paragraph_format.space_before = Pt(4)
    caption.paragraph_format.space_after = Pt(6)
    return caption


copy2(ruta_origen, ruta_salida)
ruta_codigo_final.parent.mkdir(parents=True, exist_ok=True)
copy2(ruta_codigo_original, ruta_codigo_final)
documento = Document(ruta_salida)

# ? Actualizar las imágenes posteriores porque se insertarán doce evidencias nuevas.
for parrafo in documento.paragraphs:
    coincidencia = re.match(r"(IMAGEN )([0-9]+)(\. .*)", parrafo.text)
    if coincidencia and int(coincidencia.group(2)) >= 94:
        numero_nuevo = int(coincidencia.group(2)) + 12
        texto_nuevo = f"{coincidencia.group(1)}{numero_nuevo}{coincidencia.group(3)}"
        for run in parrafo.runs:
            run.text = ""
        run = parrafo.add_run(texto_nuevo)
        configurar_fuente(run, negritas=True)

# ? Insertar la importación visual después del código de carga por T-SQL/Python.
ancla = next(
    parrafo
    for parrafo in documento.paragraphs
    if parrafo.text.strip() == "IMAGEN 93. LISTADO DE 05_CARGAR_SQL.PY, PARTE 3"
)

ancla = agregar_parrafo(
    documento,
    ancla,
    "IMPORTACIÓN VISUAL DE LOS ARCHIVOS CSV EN SSMS",
    estilo="Heading 2",
)
ancla = agregar_parrafo(
    documento,
    ancla,
    "Además de la carga realizada con T-SQL y Python, se utilizó el asistente Importar archivo plano de SQL Server Management Studio. Se importaron los archivos limpios de inventario_lote, lote y producto. El asistente permite seleccionar el archivo CSV, revisar los registros, verificar los tipos de datos y confirmar la creación de cada tabla.",
)

# ? Reintegrar la tercera parte del código de carga que corresponde a la imagen 93.
caption_93 = next(
    parrafo
    for parrafo in documento.paragraphs
    if parrafo.text.strip() == "IMAGEN 93. LISTADO DE 05_CARGAR_SQL.PY, PARTE 3"
)
imagen_93 = documento.add_paragraph()
imagen_93.alignment = WD_ALIGN_PARAGRAPH.CENTER
imagen_93.add_run().add_picture(str(ruta_codigo_final), width=Inches(5.9))
caption_93._p.addprevious(imagen_93._p)

evidencias = [
    ("Imagen1.png", "IMAGEN 94. ACCESO AL ASISTENTE IMPORTAR ARCHIVO PLANO EN SQL SERVER MANAGEMENT STUDIO."),
    ("Imagen2.png", "IMAGEN 95. SELECCIÓN DEL ARCHIVO CSV Y DE LA TABLA INVENTARIO_LOTE."),
    ("Imagen3.png", "IMAGEN 96. VISTA PREVIA DE LOS REGISTROS DEL ARCHIVO INVENTARIO_LOTE."),
    ("Imagen4.png", "IMAGEN 97. REVISIÓN DE LAS COLUMNAS Y TIPOS DE DATOS DE INVENTARIO_LOTE."),
    ("Imagen5.png", "IMAGEN 98. RESULTADO CORRECTO DE LA IMPORTACIÓN DE INVENTARIO_LOTE."),
    ("Imagen6.png", "IMAGEN 99. SELECCIÓN DEL ARCHIVO CSV Y DE LA TABLA LOTE."),
    ("Imagen7.png", "IMAGEN 100. VISTA PREVIA DE LOS REGISTROS DEL ARCHIVO LOTE."),
    ("Imagen8.png", "IMAGEN 101. RESULTADO CORRECTO DE LA IMPORTACIÓN DE LOTE."),
    ("Imagen9.png", "IMAGEN 102. SELECCIÓN DEL ARCHIVO CSV Y DE LA TABLA PRODUCTO."),
    ("Imagen10.png", "IMAGEN 103. VISTA PREVIA DE LOS REGISTROS DEL ARCHIVO PRODUCTO."),
    ("Imagen11.png", "IMAGEN 104. REVISIÓN DE LAS COLUMNAS Y TIPOS DE DATOS DE PRODUCTO."),
    ("Imagen12.png", "IMAGEN 105. RESULTADO CORRECTO DE LA IMPORTACIÓN DE PRODUCTO."),
]

for nombre, descripcion in evidencias:
    ancla = agregar_imagen(documento, ancla, ruta_imagenes / nombre, descripcion)


# ? Mantener todas las leyendas de la importación debajo de su evidencia.
# ? La imagen 93 no tiene una captura asociada en el documento recibido, por eso no se mueve.
for numero in list(range(88, 93)) + list(range(106, 121)):
    descripcion = f"IMAGEN {numero}."
    for posicion, parrafo in enumerate(documento.paragraphs[:-1]):
        if parrafo.text.startswith(descripcion):
            posible_imagen = documento.paragraphs[posicion + 1]
            if posible_imagen._p.xpath(".//w:drawing"):
                posible_imagen._p.addnext(parrafo._p)
            break

# ? Solicitar a Word que actualice el índice al abrir el archivo.
settings = documento.settings.element
update_fields = settings.find(qn("w:updateFields"))
if update_fields is None:
    update_fields = documento.settings.element.makeelement(qn("w:updateFields"), {qn("w:val"): "true"})
    documento.settings.element.append(update_fields)
else:
    update_fields.set(qn("w:val"), "true")

documento.save(ruta_salida)
print(f"Documento actualizado: {ruta_salida}")

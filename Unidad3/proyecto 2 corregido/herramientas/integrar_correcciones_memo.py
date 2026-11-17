from pathlib import Path
import sys

from docx import Document
from docx.enum.table import WD_CELL_VERTICAL_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_BREAK
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.opc.constants import RELATIONSHIP_TYPE as RT
from docx.shared import Inches, Pt, RGBColor
from docx.text.paragraph import Paragraph


RAIZ = Path(__file__).resolve().parents[1]
DOCUMENTO = RAIZ / "documentos" / "Proyecto_Unidades_I_y_II_Final_Corregido.docx"
SCRIPT_PERMISOS = RAIZ / "scripts" / "punto_05_usuarios_privilegios_corregido.sql"
AZUL = "244C63"
AZUL_RGB = RGBColor(36, 76, 99)
FONDO_CODIGO = "F3F7F8"
BORDE = "B9CBD3"


def quitar_parrafo(parrafo):
    elemento = parrafo._element
    elemento.getparent().remove(elemento)


def establecer_fuente(run, tamano=None, negrita=None, color=None):
    run.font.name = "Times New Roman"
    propiedades = run._element.get_or_add_rPr()
    fuentes = propiedades.get_or_add_rFonts()
    for atributo in ("ascii", "hAnsi", "eastAsia", "cs"):
        fuentes.set(qn(f"w:{atributo}"), "Times New Roman")
    if tamano is not None:
        run.font.size = Pt(tamano)
    if negrita is not None:
        run.bold = negrita
    if color is not None:
        run.font.color.rgb = color


def insertar_parrafo(antes_de, texto=""):
    return antes_de.insert_paragraph_before(texto)


def insertar_salto(antes_de):
    parrafo = insertar_parrafo(antes_de)
    parrafo.add_run().add_break(WD_BREAK.PAGE)
    return parrafo


def insertar_titulo(antes_de, texto, tamano=14):
    parrafo = insertar_parrafo(antes_de)
    parrafo.paragraph_format.space_before = Pt(4)
    parrafo.paragraph_format.space_after = Pt(7)
    parrafo.paragraph_format.keep_with_next = True
    run = parrafo.add_run(texto)
    establecer_fuente(run, tamano=tamano, negrita=True, color=AZUL_RGB)
    return parrafo


def bordes_tabla(tabla, color=BORDE, tamano="5"):
    propiedades = tabla._tbl.tblPr
    bordes = propiedades.first_child_found_in("w:tblBorders")
    if bordes is None:
        bordes = OxmlElement("w:tblBorders")
        propiedades.append(bordes)
    for nombre in ("top", "left", "bottom", "right", "insideH", "insideV"):
        borde = bordes.find(qn(f"w:{nombre}"))
        if borde is None:
            borde = OxmlElement(f"w:{nombre}")
            bordes.append(borde)
        borde.set(qn("w:val"), "single")
        borde.set(qn("w:sz"), tamano)
        borde.set(qn("w:color"), color)


def margen_celda(celda, superior=70, izquierdo=100, inferior=70, derecho=100):
    propiedades = celda._tc.get_or_add_tcPr()
    margenes = propiedades.first_child_found_in("w:tcMar")
    if margenes is None:
        margenes = OxmlElement("w:tcMar")
        propiedades.append(margenes)
    for nombre, valor in (
        ("top", superior),
        ("start", izquierdo),
        ("bottom", inferior),
        ("end", derecho),
    ):
        margen = margenes.find(qn(f"w:{nombre}"))
        if margen is None:
            margen = OxmlElement(f"w:{nombre}")
            margenes.append(margen)
        margen.set(qn("w:w"), str(valor))
        margen.set(qn("w:type"), "dxa")


def sombrear(celda, color):
    propiedades = celda._tc.get_or_add_tcPr()
    sombreado = propiedades.find(qn("w:shd"))
    if sombreado is None:
        sombreado = OxmlElement("w:shd")
        propiedades.append(sombreado)
    sombreado.set(qn("w:fill"), color)


def insertar_bloque_codigo(documento, antes_de, codigo, tamano=7.7):
    tabla = documento.add_table(rows=1, cols=1)
    antes_de._p.addprevious(tabla._tbl)
    tabla.autofit = False
    tabla.columns[0].width = Inches(6.55)
    bordes_tabla(tabla)
    celda = tabla.cell(0, 0)
    celda.width = Inches(6.55)
    celda.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
    sombrear(celda, FONDO_CODIGO)
    margen_celda(celda, superior=55, inferior=55)
    parrafo = celda.paragraphs[0]
    parrafo.paragraph_format.space_before = Pt(0)
    parrafo.paragraph_format.space_after = Pt(0)
    parrafo.paragraph_format.line_spacing = 0.92
    run = parrafo.add_run(codigo.strip())
    establecer_fuente(run, tamano=tamano)
    return tabla


def insertar_tabla_verificacion(documento, antes_de):
    filas = [
        ("Rol", "Objeto", "Acceso previsto"),
        ("rol_almacen", "inventario_lote", "SELECT"),
        ("rol_reparto", "movimiento_inventario", "Sin acceso"),
        ("rol_captura", "pedido", "SELECT, INSERT, UPDATE"),
        ("rol_supervision", "incidencia", "SELECT, UPDATE"),
        ("rol_admin_tecnico", "13 tablas", "SELECT, INSERT, UPDATE"),
    ]
    tabla = documento.add_table(rows=len(filas), cols=3)
    antes_de._p.addprevious(tabla._tbl)
    tabla.autofit = False
    anchos = (Inches(2.0), Inches(2.2), Inches(2.35))
    for indice, ancho in enumerate(anchos):
        tabla.columns[indice].width = ancho
    bordes_tabla(tabla)
    for numero_fila, datos in enumerate(filas):
        for numero_columna, texto in enumerate(datos):
            celda = tabla.cell(numero_fila, numero_columna)
            celda.width = anchos[numero_columna]
            celda.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
            margen_celda(celda, superior=85, inferior=85)
            if numero_fila == 0:
                sombrear(celda, "245B6B")
            elif numero_fila % 2 == 1:
                sombrear(celda, "F3F7F8")
            parrafo = celda.paragraphs[0]
            parrafo.paragraph_format.space_after = Pt(0)
            run = parrafo.add_run(texto)
            establecer_fuente(
                run,
                tamano=9,
                negrita=(numero_fila == 0),
                color=(RGBColor(255, 255, 255) if numero_fila == 0 else RGBColor(0, 0, 0)),
            )
    encabezado = tabla.rows[0]._tr.get_or_add_trPr()
    repetir = OxmlElement("w:tblHeader")
    repetir.set(qn("w:val"), "true")
    encabezado.append(repetir)
    return tabla


def secciones_script():
    texto = SCRIPT_PERMISOS.read_text(encoding="utf-8")
    lineas = texto.splitlines()

    def entre(inicio, final):
        indice_inicio = next(i for i, linea in enumerate(lineas) if inicio in linea)
        indice_final = next(i for i, linea in enumerate(lineas[indice_inicio + 1:], indice_inicio + 1) if final in linea)
        return "\n".join(lineas[indice_inicio + 1:indice_final]).strip()

    indice_preparacion = next(i for i, linea in enumerate(lineas) if linea.startswith("Use pepsi_distribucion"))
    indice_captura = next(i for i, linea in enumerate(lineas) if "Permisos del personal de captura" in linea)
    preparacion = "\n".join(lineas[indice_preparacion:indice_captura]).strip()
    captura = entre("Permisos del personal de captura", "Permisos del personal de almacen")
    almacen = entre("Permisos del personal de almacen", "Permisos del personal de reparto")
    reparto = entre("Permisos del personal de reparto", "Permisos del personal de supervision")
    supervision = entre("Permisos del personal de supervision", "Permisos del administrador tecnico")
    administrador = entre("Permisos del administrador tecnico", "Agregar cada usuario")
    membresias = entre("Agregar cada usuario", "Comprobar los permisos")
    return preparacion, captura, almacen, reparto, supervision, administrador, membresias


def integrar_permisos(documento):
    parrafos = documento.paragraphs
    pie_login = next(p for p in parrafos if p.text.strip().upper().startswith("IMAGEN 12."))
    estrategia = next(p for p in parrafos if p.text.strip() == "DISEÑAR UNA ESTRATEGIA DE RESPALDO")
    indice_login = parrafos.index(pie_login)
    indice_estrategia = parrafos.index(estrategia)
    for parrafo in reversed(parrafos[indice_login + 1:indice_estrategia]):
        quitar_parrafo(parrafo)

    preparacion, captura, almacen, reparto, supervision, administrador, membresias = secciones_script()

    insertar_salto(estrategia)
    insertar_titulo(estrategia, "PRINCIPIO DEL MÍNIMO PRIVILEGIO: CÓDIGO CORREGIDO", 14)
    introduccion = insertar_parrafo(
        estrategia,
        "La asignación de permisos se ajusta a la matriz del Cuadro 2. Lectura equivale a SELECT, alta a INSERT y modificación a UPDATE. No se conceden privilegios de eliminación ni pertenencia a db_owner.",
    )
    introduccion.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    introduccion.paragraph_format.space_after = Pt(7)
    insertar_titulo(estrategia, "PREPARACIÓN DE ROLES Y LIMPIEZA DE CONCESIONES PREVIAS", 11.5)
    insertar_bloque_codigo(documento, estrategia, preparacion, tamano=7.25)

    insertar_salto(estrategia)
    insertar_titulo(estrategia, "ASIGNACIÓN DE PERMISOS OPERATIVOS", 14)
    insertar_titulo(estrategia, "ROL CAPTURA", 11.5)
    insertar_bloque_codigo(documento, estrategia, captura, tamano=7.8)
    insertar_titulo(estrategia, "ROL ALMACÉN", 11.5)
    insertar_bloque_codigo(documento, estrategia, almacen, tamano=7.8)

    insertar_salto(estrategia)
    insertar_titulo(estrategia, "ASIGNACIÓN DE PERMISOS POR ROL (CONTINUACIÓN)", 14)
    insertar_titulo(estrategia, "ROL REPARTO", 11.5)
    insertar_bloque_codigo(documento, estrategia, reparto, tamano=8)
    insertar_titulo(estrategia, "ROL SUPERVISIÓN", 11.5)
    insertar_bloque_codigo(documento, estrategia, supervision, tamano=7.8)
    insertar_titulo(estrategia, "ROL ADMINISTRADOR TÉCNICO", 11.5)
    insertar_bloque_codigo(documento, estrategia, administrador, tamano=7.8)
    insertar_titulo(estrategia, "ASIGNACIÓN DE USUARIOS SIN DUPLICAR MEMBRESÍAS", 11.5)
    insertar_bloque_codigo(documento, estrategia, membresias, tamano=7.8)
    nota = insertar_parrafo(
        estrategia,
        "La tabla inventario_lote queda con SELECT únicamente para Almacén. El administrador técnico conserva un rol personalizado con permisos explícitos y no debe pertenecer a db_owner.",
    )
    nota.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    nota.paragraph_format.space_before = Pt(5)

    insertar_salto(estrategia)
    insertar_titulo(estrategia, "COMPROBACIÓN DEL CONTROL DE ACCESO", 14)
    explicacion = insertar_parrafo(
        estrategia,
        "Revisión de las reglas esperadas después de ejecutar el script corregido. Las concesiones anteriores se sustituyen porque ya no representan la matriz definitiva.",
    )
    explicacion.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    explicacion.paragraph_format.space_after = Pt(8)
    insertar_tabla_verificacion(documento, estrategia)
    consulta = """Select roles.name As rol, objetos.name As tabla,
  permisos.permission_name As permiso
From sys.database_permissions permisos
Inner Join sys.database_principals roles
  On permisos.grantee_principal_id = roles.principal_id
Inner Join sys.objects objetos
  On permisos.major_id = objetos.object_id
Where roles.name Like 'rol_%'
Order By roles.name, objetos.name, permisos.permission_name;"""
    insertar_bloque_codigo(documento, estrategia, consulta, tamano=8.2)
    pie = insertar_parrafo(estrategia, "IMAGEN 18. VERIFICACIÓN PROPUESTA DE PERMISOS.")
    pie.alignment = WD_ALIGN_PARAGRAPH.CENTER
    pie.paragraph_format.space_before = Pt(5)
    pie.paragraph_format.space_after = Pt(7)
    for run in pie.runs:
        establecer_fuente(run, tamano=10, negrita=True)


def reemplazar_imagen_antes(parrafo_titulo, ruta_imagen):
    elemento = parrafo_titulo._p.getprevious()
    while elemento is not None:
        candidato = Paragraph(elemento, parrafo_titulo._parent)
        if candidato._p.xpath(".//w:drawing"):
            for hijo in list(candidato._p):
                if hijo.tag != qn("w:pPr"):
                    candidato._p.remove(hijo)
            candidato.alignment = WD_ALIGN_PARAGRAPH.CENTER
            candidato.add_run().add_picture(str(ruta_imagen), width=Inches(6.15))
            return
        elemento = elemento.getprevious()
    raise RuntimeError("No se encontró la imagen anterior al título indicado.")


def integrar_auditoria(documento):
    sys.path.insert(0, str(RAIZ / "herramientas"))
    import corregir_documento as base

    codigo = """
-- ? Ortega Garcia - Nuñez Lopez - Rodriguez Macias
Use pepsi_distribucion;
GO

-- ? Consultar solamente los eventos validos del año 2026.
Select event_time, action_id, succeeded, database_name,
  schema_name, object_name, statement
From sys.fn_get_audit_file(
  'C:\\Data\\pepsi_auditoria_*.sqlaudit', Default, Default)
Where database_name = 'pepsi_distribucion'
  And event_time >= '2026-01-01'
  And event_time < '2027-01-01'
  And object_name In ('tienda', 'producto', 'almacen', 'lote',
    'inventario_lote', 'pedido', 'detalle_pedido', 'entrega',
    'detalle_entrega', 'incidencia', 'movimiento_inventario',
    'conteo_inventario', 'detalle_conteo')
Order By event_time Desc;
GO
"""
    ruta = base.crear_imagen_codigo("imagen_51_auditoria_integrada.png", codigo)
    parrafo = next(
        p for p in documento.paragraphs
        if p.text.strip().startswith("Para evitar mezclar evidencias")
    )
    titulo = parrafo.insert_paragraph_before()
    run = titulo.add_run("VALIDACIÓN DE EVENTOS DE AUDITORÍA · 2026")
    establecer_fuente(run, tamano=14, negrita=True, color=AZUL_RGB)
    titulo.paragraph_format.page_break_before = True
    titulo.paragraph_format.space_after = Pt(7)
    parrafo.text = (
        "Se excluye la evidencia anterior porque contenía registros de octubre de 2025 y objetos ajenos a las 13 tablas. La consulta siguiente permite obtener evidencia real de 2026; sus resultados deberán capturarse después de ejecutarla en SQL Server."
    )
    parrafo.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    parrafo.paragraph_format.space_after = Pt(7)
    for run in parrafo.runs:
        establecer_fuente(run, tamano=11)

    pie = next(
        p for p in documento.paragraphs
        if p.text.strip().upper().startswith("IMAGEN 51.")
    )
    reemplazar_imagen_antes(pie, ruta)
    pie.text = "IMAGEN 51. CONSULTA PARA VALIDAR EVENTOS DE AUDITORÍA DE 2026."
    pie.alignment = WD_ALIGN_PARAGRAPH.CENTER


def agregar_hipervinculo(parrafo, texto, url):
    relacion = parrafo.part.relate_to(url, RT.HYPERLINK, is_external=True)
    hipervinculo = OxmlElement("w:hyperlink")
    hipervinculo.set(qn("r:id"), relacion)
    run = OxmlElement("w:r")
    propiedades = OxmlElement("w:rPr")
    fuentes = OxmlElement("w:rFonts")
    for atributo in ("ascii", "hAnsi", "eastAsia", "cs"):
        fuentes.set(qn(f"w:{atributo}"), "Times New Roman")
    propiedades.append(fuentes)
    color = OxmlElement("w:color")
    color.set(qn("w:val"), "245B6B")
    propiedades.append(color)
    subrayado = OxmlElement("w:u")
    subrayado.set(qn("w:val"), "single")
    propiedades.append(subrayado)
    tamano = OxmlElement("w:sz")
    tamano.set(qn("w:val"), "22")
    propiedades.append(tamano)
    run.append(propiedades)
    contenido = OxmlElement("w:t")
    contenido.text = texto
    run.append(contenido)
    hipervinculo.append(run)
    parrafo._p.append(hipervinculo)


def insertar_despues(parrafo, texto=""):
    nuevo = OxmlElement("w:p")
    parrafo._p.addnext(nuevo)
    resultado = Paragraph(nuevo, parrafo._parent)
    if texto:
        resultado.add_run(texto)
    return resultado


def integrar_conclusion_y_referencias(documento):
    parrafos = documento.paragraphs
    conclusion = next(p for p in parrafos if p.text.strip() == "CONCLUSIÓN")
    referencias = next(p for p in parrafos if p.text.strip() == "REFERENCIAS")
    inicio = parrafos.index(conclusion)
    final = parrafos.index(referencias)
    for parrafo in reversed(parrafos[inicio + 1:final]):
        quitar_parrafo(parrafo)

    conclusion.text = "CONCLUSIÓN GENERAL DEL PROYECTO"
    conclusion.paragraph_format.page_break_before = True
    textos = [
        "El proyecto de las unidades I y II permitió relacionar la administración de una base de datos con la calidad de los datos que utilizan las actividades de un almacén de distribución de bebidas. En la primera unidad se diseñó la base pepsi_distribucion con 13 tablas vinculadas a tiendas, productos, lotes, inventario, pedidos, entregas e incidencias. También se definieron controles de integridad, respaldos, recuperación, mantenimiento y auditoría para mejorar la organización y trazabilidad de la información.",
        "Una parte importante de la revisión fue comprobar que los permisos realmente correspondieran a las funciones de cada usuario. Por ello se ajustó el código GRANT a la matriz de privilegios: el almacén solo puede consultar inventario_lote, y el administrador técnico utiliza un rol personalizado, sin quedar asignado a db_owner. Esta corrección ayuda a aplicar el principio del mínimo privilegio. Para considerarla verificada en el servidor se debe ejecutar el script actualizado y revisar las concesiones efectivas.",
        "En la segunda unidad, Python y sus bibliotecas permitieron generar datos de prueba, detectar registros incompletos, duplicados, cantidades incorrectas y relaciones inválidas. A través de la limpieza y transformación ETL se prepararon archivos CSV para validarlos y reintegrarlos en SQL Server. De este modo se entendió que no basta con almacenar la información: también es necesario revisar su consistencia antes de usarla en consultas, reportes y decisiones operativas.",
        "Por último, se retiró una evidencia de auditoría que no correspondía a la fecha ni a los objetos del proyecto. En su lugar se incorporó una consulta reproducible para buscar eventos válidos del año 2026, sin presentar resultados que no se hayan comprobado. En conjunto, el trabajo muestra la importancia de diseñar la base correctamente, restringir los accesos, contar con respaldos y verificar la calidad y el origen de las evidencias.",
    ]
    ancla = conclusion
    for texto in textos:
        ancla = insertar_despues(ancla, texto)
        ancla.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        ancla.paragraph_format.line_spacing = 1.5
        ancla.paragraph_format.space_after = Pt(8)
        for run in ancla.runs:
            establecer_fuente(run, tamano=11.5)

    referencias = next(p for p in documento.paragraphs if p.text.strip() == "REFERENCIAS")
    referencias.paragraph_format.page_break_before = True
    parrafos_actuales = documento.paragraphs
    indice_referencias = next(i for i, p in enumerate(parrafos_actuales) if p._p is referencias._p)
    posteriores = parrafos_actuales[indice_referencias + 1:]
    for parrafo in reversed(posteriores):
        quitar_parrafo(parrafo)

    fuentes = [
        ("Faker. (s. f.). Welcome to Faker’s documentation.", "https://faker.readthedocs.io/en/master/"),
        ("Microsoft. (s. f.-a). CREATE VIEW (Transact-SQL). Microsoft Learn.", "https://learn.microsoft.com/en-us/sql/t-sql/statements/create-view-transact-sql"),
        ("Microsoft. (s. f.-b). Extract, transform, load (ETL). Microsoft Learn.", "https://learn.microsoft.com/en-us/azure/architecture/data-guide/relational-data/etl"),
        ("Microsoft Corporation. (2026). Descargas de Microsoft SQL Server y documentación técnica de ediciones. Microsoft.", "https://www.microsoft.com/es-mx/sql-server/sql-server-downloads"),
        ("pandas. (s. f.-a). pandas.to_datetime.", "https://pandas.pydata.org/docs/reference/api/pandas.to_datetime.html"),
        ("pandas. (s. f.-b). pandas.to_numeric.", "https://pandas.pydata.org/docs/reference/api/pandas.to_numeric.html"),
        ("PepsiCo. (s. f.). Portafolio de marcas y productos en México. Pepsi.", "https://www.pepsi.com.mx/"),
        ("PepsiCo México. (s. f.). Quiénes somos: misión y visión. PepsiCo.", "https://www.pepsico.com.mx/quienes-somos/mision-y-vision"),
        ("SQLAlchemy. (s. f.). Working with engines and connections.", "https://docs.sqlalchemy.org/en/20/core/connections.html"),
        ("Wikipedia. (2026, 12 de febrero). PepsiCo. Wikipedia, la enciclopedia libre.", "https://es.wikipedia.org/wiki/PepsiCo"),
    ]
    ancla = referencias
    for referencia, url in fuentes:
        ancla = insertar_despues(ancla)
        ancla.paragraph_format.left_indent = Inches(0.38)
        ancla.paragraph_format.first_line_indent = Inches(-0.38)
        ancla.paragraph_format.space_after = Pt(10)
        run = ancla.add_run(referencia)
        establecer_fuente(run, tamano=11)
        run.add_break()
        agregar_hipervinculo(ancla, url, url)


def normalizar(documento):
    for estilo in documento.styles:
        if hasattr(estilo, "font"):
            estilo.font.name = "Times New Roman"
            propiedades = estilo.element.get_or_add_rPr()
            fuentes = propiedades.get_or_add_rFonts()
            for atributo in ("ascii", "hAnsi", "eastAsia", "cs"):
                fuentes.set(qn(f"w:{atributo}"), "Times New Roman")
    for parrafo in documento.paragraphs:
        for run in parrafo.runs:
            establecer_fuente(run)
    for tabla in documento.tables:
        for fila in tabla.rows:
            for celda in fila.cells:
                for parrafo in celda.paragraphs:
                    for run in parrafo.runs:
                        establecer_fuente(run)
    for seccion in documento.sections:
        for parrafo in seccion.header.paragraphs + seccion.footer.paragraphs:
            for run in parrafo.runs:
                establecer_fuente(run)


def main():
    documento = Document(DOCUMENTO)
    documento.core_properties.title = "Proyecto de bases de datos - Unidades I y II - versión final corregida"
    integrar_permisos(documento)
    integrar_auditoria(documento)
    integrar_conclusion_y_referencias(documento)
    normalizar(documento)
    documento.save(DOCUMENTO)
    print(DOCUMENTO)


if __name__ == "__main__":
    main()

from pathlib import Path
import re

from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Inches, Pt
from docx.text.paragraph import Paragraph
from PIL import Image, ImageDraw, ImageFont


RAIZ = Path(__file__).resolve().parents[1]
DOCUMENTO = RAIZ / "documentos" / "Proyecto_Unidad_I_y_II_corregido.docx"
EVIDENCIAS = RAIZ / "evidencias" / "correcciones"


def quitar_parrafo(parrafo):
    elemento = parrafo._element
    elemento.getparent().remove(elemento)


def insertar_despues(parrafo, texto, estilo="Normal"):
    nuevo_elemento = OxmlElement("w:p")
    parrafo._p.addnext(nuevo_elemento)
    nuevo = Paragraph(nuevo_elemento, parrafo._parent)
    nuevo.style = estilo
    nuevo.add_run(texto)
    return nuevo


def configurar_texto(parrafo):
    parrafo.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    parrafo.paragraph_format.line_spacing = 1.5
    parrafo.paragraph_format.space_after = Pt(6)


def fuente_codigo(tamano):
    rutas = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",
        "/usr/share/fonts/truetype/liberation2/LiberationMono-Regular.ttf",
    ]
    for ruta in rutas:
        if Path(ruta).exists():
            return ImageFont.truetype(ruta, tamano)
    return ImageFont.load_default()


def segmentos_sql(linea):
    if linea.lstrip().startswith("--"):
        return [(linea, "comentario")]

    patron = re.compile(
        r"('(?:''|[^'])*')|\b(Use|GO|Create|Role|Alter|Add|Member|Grant|Select|Insert|Update|On|Object|To|From|Inner|Join|Where|In|Order|By|As|And|Default|Desc)\b",
        re.IGNORECASE,
    )
    segmentos = []
    posicion = 0
    for coincidencia in patron.finditer(linea):
        if coincidencia.start() > posicion:
            segmentos.append((linea[posicion:coincidencia.start()], "normal"))
        tipo = "cadena" if coincidencia.group(1) else "palabra"
        segmentos.append((coincidencia.group(0), tipo))
        posicion = coincidencia.end()
    if posicion < len(linea):
        segmentos.append((linea[posicion:], "normal"))
    return segmentos


def crear_imagen_codigo(nombre, codigo):
    EVIDENCIAS.mkdir(parents=True, exist_ok=True)
    ruta = EVIDENCIAS / nombre
    lineas = codigo.strip("\n").splitlines()
    fuente = fuente_codigo(27)
    ancho = 1680
    margen_x = 46
    margen_y = 38
    alto_linea = 39
    alto = margen_y * 2 + alto_linea * len(lineas)
    imagen = Image.new("RGB", (ancho, alto), "#fbfbfb")
    dibujo = ImageDraw.Draw(imagen)
    colores = {
        "normal": "#1f2328",
        "comentario": "#146c3a",
        "cadena": "#a31515",
        "palabra": "#5b21b6",
        "numero": "#6b7280",
    }

    for numero, linea in enumerate(lineas, 1):
        y = margen_y + (numero - 1) * alto_linea
        dibujo.text((margen_x, y), f"{numero:>2} ", font=fuente, fill=colores["numero"])
        x = margen_x + dibujo.textlength(f"{numero:>2} ", font=fuente)
        for texto, tipo in segmentos_sql(linea):
            dibujo.text((x, y), texto, font=fuente, fill=colores[tipo])
            x += dibujo.textlength(texto, font=fuente)

    imagen.save(ruta, quality=95)
    return ruta


def parrafo_con_imagen_antes(parrafo_titulo):
    elemento = parrafo_titulo._p.getprevious()
    intentos = 0
    while elemento is not None and intentos < 4:
        candidato = Paragraph(elemento, parrafo_titulo._parent)
        if candidato._p.xpath(".//w:drawing"):
            return candidato
        elemento = elemento.getprevious()
        intentos += 1
    raise RuntimeError(f"No se encontró la imagen anterior a: {parrafo_titulo.text}")


def sustituir_imagen(documento, numero, ruta, titulo):
    titulo_actual = None
    for parrafo in documento.paragraphs:
        if parrafo.text.strip().upper().startswith(f"IMAGEN {numero}."):
            titulo_actual = parrafo
            break
    if titulo_actual is None:
        raise RuntimeError(f"No se encontró el título de la imagen {numero}")

    parrafo_imagen = parrafo_con_imagen_antes(titulo_actual)
    for hijo in list(parrafo_imagen._p):
        if hijo.tag != qn("w:pPr"):
            parrafo_imagen._p.remove(hijo)
    parrafo_imagen.alignment = WD_ALIGN_PARAGRAPH.CENTER
    parrafo_imagen.add_run().add_picture(str(ruta), width=Inches(6.15))
    titulo_actual.text = titulo
    titulo_actual.alignment = WD_ALIGN_PARAGRAPH.CENTER


def establecer_times_new_roman_run(run):
    run.font.name = "Times New Roman"
    propiedades = run._element.get_or_add_rPr()
    fuentes = propiedades.get_or_add_rFonts()
    for atributo in ("ascii", "hAnsi", "eastAsia", "cs"):
        fuentes.set(qn(f"w:{atributo}"), "Times New Roman")


def normalizar_fuentes(documento):
    for estilo in documento.styles:
        if hasattr(estilo, "font"):
            estilo.font.name = "Times New Roman"
            propiedades = estilo.element.get_or_add_rPr()
            fuentes = propiedades.get_or_add_rFonts()
            for atributo in ("ascii", "hAnsi", "eastAsia", "cs"):
                fuentes.set(qn(f"w:{atributo}"), "Times New Roman")

    def normalizar_parrafos(parrafos):
        for parrafo in parrafos:
            for run in parrafo.runs:
                establecer_times_new_roman_run(run)

    normalizar_parrafos(documento.paragraphs)
    for tabla in documento.tables:
        for fila in tabla.rows:
            for celda in fila.cells:
                normalizar_parrafos(celda.paragraphs)
    for seccion in documento.sections:
        normalizar_parrafos(seccion.header.paragraphs)
        normalizar_parrafos(seccion.footer.paragraphs)


def corregir_portada(documento):
    parrafos = documento.paragraphs
    indice_equipo = next(
        i for i, parrafo in enumerate(parrafos)
        if parrafo.text.strip().upper() == "EQUIPO:"
    )
    parrafo_docente = parrafos[indice_equipo + 4]
    parrafo_docente.text = ""
    parrafo_docente.alignment = WD_ALIGN_PARAGRAPH.CENTER
    parrafo_docente.paragraph_format.space_before = Pt(6)
    parrafo_docente.paragraph_format.space_after = Pt(6)
    etiqueta = parrafo_docente.add_run("DOCENTE:\n")
    etiqueta.bold = True
    etiqueta.font.size = Pt(13)
    nombre = parrafo_docente.add_run("GÓMEZ ARELLANO ATHALA DULCE EDITH")
    nombre.font.size = Pt(13)

    for parrafo in documento.paragraphs:
        if parrafo.text.strip() == "RODRÍGUEZ MACIAS CARLOS GABRIEL":
            parrafo.text = "RODRÍGUEZ MACÍAS CARLOS GABRIEL"


def corregir_conclusion_y_referencias(documento):
    parrafos = documento.paragraphs
    inicio = next(i for i, p in enumerate(parrafos) if p.text.strip() == "CONCLUSIÓN DE LA UNIDAD I")
    final = next(i for i, p in enumerate(parrafos) if p.text.strip() == "PROYECTO DOS")
    for parrafo in reversed(parrafos[inicio:final]):
        quitar_parrafo(parrafo)

    parrafos = documento.paragraphs
    conclusion = next(p for p in parrafos if p.text.strip() == "CONCLUSIÓN DE LA UNIDAD II")
    referencias = next(p for p in parrafos if p.text.strip() == "REFERENCIAS DE LA UNIDAD II")
    indice_conclusion = parrafos.index(conclusion)
    indice_referencias = parrafos.index(referencias)
    for parrafo in reversed(parrafos[indice_conclusion + 1:indice_referencias]):
        quitar_parrafo(parrafo)

    conclusion.text = "CONCLUSIÓN"
    textos = [
        "Con este proyecto integramos la administración de SQL Server y la calidad de datos para atender el control de inventarios, lotes, pedidos y entregas del almacén. El modelo relacional, las reglas de integridad, los respaldos, el mantenimiento, la auditoría y los permisos por roles permiten conservar información organizada y limitar las acciones de cada usuario según sus responsabilidades.",
        "En la segunda parte utilizamos Python, Faker y pandas para generar archivos CSV, localizar errores y aplicar un proceso ETL. La limpieza permitió corregir formatos y textos cuando existía una regla comprobable, separar registros no aptos y validar nuevamente las relaciones entre producto, lote e inventario antes de reintegrar la información a SQL Server.",
        "La principal conclusión es que una base de datos no resulta confiable únicamente por tener tablas y respaldos: también requiere datos válidos, permisos coherentes con el principio de mínimo privilegio y evidencias que correspondan al sistema evaluado. Al comparar los resultados antes y después de la limpieza comprobamos que la administración y la calidad de los datos deben trabajarse juntas para apoyar decisiones correctas sobre existencias, caducidades y valor del inventario.",
    ]
    ancla = conclusion
    for texto in textos:
        ancla = insertar_despues(ancla, texto)
        configurar_texto(ancla)

    referencias.text = "REFERENCIAS"
    parrafos = documento.paragraphs
    referencias = next(p for p in parrafos if p.text.strip() == "REFERENCIAS")
    indice_referencias = parrafos.index(referencias)
    posteriores = parrafos[indice_referencias + 1:]
    for parrafo in reversed(posteriores):
        tiene_seccion = bool(parrafo._p.xpath("./w:pPr/w:sectPr"))
        if not tiene_seccion:
            quitar_parrafo(parrafo)

    fuentes = [
        "Faker. (s. f.). Faker documentation. https://faker.readthedocs.io/",
        "Microsoft Corporation. (2026). Descargas de SQL Server. Microsoft. https://www.microsoft.com/es-es/sql-server/sql-server-downloads",
        "Microsoft. (s. f.-a). CREATE VIEW (Transact-SQL). Microsoft Learn. https://learn.microsoft.com/es-es/sql/t-sql/statements/create-view-transact-sql",
        "Microsoft. (s. f.-b). Extracción, transformación y carga de datos (ETL). Microsoft Learn. https://learn.microsoft.com/es-es/azure/architecture/data-guide/relational-data/etl",
        "pandas. (s. f.-a). pandas.to_datetime. https://pandas.pydata.org/docs/reference/api/pandas.to_datetime.html",
        "pandas. (s. f.-b). pandas.to_numeric. https://pandas.pydata.org/docs/reference/api/pandas.to_numeric.html",
        "PepsiCo. (s. f.). Portafolio global de alimentos y bebidas. https://www.pepsico.com/",
        "PepsiCo México. (s. f.). Quiénes somos. https://www.pepsico.com.mx/",
        "SQLAlchemy. (s. f.). SQLAlchemy documentation. https://docs.sqlalchemy.org/",
        "Wikipedia. (2026, 12 de febrero). PepsiCo. https://es.wikipedia.org/wiki/PepsiCo",
    ]
    ancla = referencias
    for fuente in fuentes:
        ancla = insertar_despues(ancla, fuente)
        ancla.paragraph_format.left_indent = Inches(0.5)
        ancla.paragraph_format.first_line_indent = Inches(-0.5)
        ancla.paragraph_format.space_after = Pt(6)


def corregir_matriz_y_explicaciones(documento):
    for tabla in documento.tables:
        if tabla.rows and tabla.rows[0].cells[0].text.strip() == "Tabla":
            for fila in tabla.rows[1:]:
                if fila.cells[0].text.strip() == "Almacen":
                    fila.cells[0].text = "Almacén"
            break

    reemplazos = {
        "Administrador técnico:": "Administrador técnico: administra cuentas y tareas de mantenimiento mediante el rol personalizado rol_admin_tecnico. Sus permisos se asignan de forma explícita conforme a la matriz y el usuario no pertenece a db_owner.",
        "Se le asignó el rol db_owner": "Se definió el rol personalizado rol_admin_tecnico y se le concedieron únicamente los permisos de lectura, alta y modificación establecidos en la matriz. El usuario administrador técnico no se agregó directamente a db_owner.",
        "El script se ejecutó en la base": "El script corregido se ejecuta en la base pepsi_distribucion y asigna los permisos por medio de roles personalizados. Para Almacén, Inventario_Lote conserva solamente el permiso de lectura, mientras que el administrador técnico recibe permisos explícitos sin pertenecer a db_owner.",
    }
    for parrafo in documento.paragraphs:
        texto = parrafo.text.strip()
        for inicio, nuevo in reemplazos.items():
            if texto.startswith(inicio):
                parrafo.text = nuevo
                configurar_texto(parrafo)
                break


def corregir_titulos(documento):
    cambios_exactos = {
        "MISIÓN CORPORATIVA:": "MISIÓN CORPORATIVA",
        "VISIÓN CORPORATIVA:": "VISIÓN CORPORATIVA",
        "UBICACIÓN:": "UBICACIÓN",
        "LOGO:": "LOGO",
        "PRODUCTOS DE PEPSI:": "PRODUCTOS DE PEPSI",
        "CARACTERÍSTICAS GENERALES DE LA OPERACIÓN CONSIDERADA EN EL CASO.": "CARACTERÍSTICAS GENERALES DE LA OPERACIÓN CONSIDERADA EN EL CASO",
        "DESCRIPCIÓN DEL PROBLEMA DE LA EMPRESA RELACIONADA CON LA ADMINISTRACIÓN DE SUS DATOS.": "DESCRIPCIÓN DEL PROBLEMA DE LA EMPRESA RELACIONADA CON LA ADMINISTRACIÓN DE SUS DATOS",
        "DEFINICIÓN Y JUSTIFICACIÓN DEL MODELO OLTP:": "DEFINICIÓN Y JUSTIFICACIÓN DEL MODELO OLTP",
        "DEFINIR AL MENOS TRES TIPOS DE USUARIO QUE INTERACTÚAN CON EL SISTEMA:": "DEFINIR AL MENOS TRES TIPOS DE USUARIO QUE INTERACTÚAN CON EL SISTEMA",
        "DEFINIR AL MENOS TRES TIPOS DE USUARIOS O PUESTOS QUE UTILIZARÁN EL SISTEMA:": "DEFINIR AL MENOS TRES TIPOS DE USUARIOS O PUESTOS QUE UTILIZARÁN EL SISTEMA",
        "DESARROLLAR LA PROBLEMÁTICA UTILIZANDO EL MODELO CIA EN UN GRÁFICO.": "DESARROLLAR LA PROBLEMÁTICA UTILIZANDO EL MODELO CIA EN UN GRÁFICO",
        "DIFERENCIAS ENTRE .BAK Y. TRN": "DIFERENCIAS ENTRE .BAK Y .TRN",
        "DISEÑEN UN PLAN DE MANTENIMIENTO.": "DISEÑEN UN PLAN DE MANTENIMIENTO",
        "DEFINICIÓN DE QUÉ INFORMACIÓN DEBERÁ SER AUDITADA.": "DEFINICIÓN DE QUÉ INFORMACIÓN DEBERÁ SER AUDITADA",
        "IMPLEMENTEN MECANISMOS DE AUDITORÍA.": "IMPLEMENTEN MECANISMOS DE AUDITORÍA",
    }
    pies = {
        3: "IMAGEN 3. CREACIÓN DE LA BASE DE DATOS.",
        12: "IMAGEN 12. CREACIÓN DE LOS LOGIN.",
        13: "IMAGEN 13. CREACIÓN DE LOS USUARIOS.",
        14: "IMAGEN 14. ASIGNACIÓN DE LOS USUARIOS A ROLES PERSONALIZADOS.",
        15: "IMAGEN 15. PERMISOS CORREGIDOS PARA CAPTURA Y ALMACÉN.",
        16: "IMAGEN 16. PERMISOS CORREGIDOS DEL ADMINISTRADOR TÉCNICO.",
        17: "IMAGEN 17. CONSULTA PARA COMPROBAR LOS PERMISOS ASIGNADOS.",
        18: "IMAGEN 18. COMPROBACIÓN DE LOS PERMISOS CRÍTICOS CORREGIDOS.",
        19: "IMAGEN 19. CÓDIGOS DE RESPALDO COMPLETO, DIFERENCIAL Y DE LOG.",
        20: "IMAGEN 20. CREACIÓN DEL TRABAJO PARA LOS RESPALDOS.",
        29: "IMAGEN 29. RESULTADO DE CUÁNTOS REGISTROS SE RECUPERARON EN LA BASE DE DATOS PEPSI_DISTRIBUCION_PRUEBA.",
        32: "IMAGEN 32. FUNCIÓN PARA REVISAR EL ESTADO DE LA AUDITORÍA.",
        33: "IMAGEN 33. VERSIÓN INSTALADA DE SQL SERVER.",
        34: "IMAGEN 34. CÓDIGO PARA REVISAR LA CONSISTENCIA FÍSICA Y LÓGICA.",
        35: "IMAGEN 35. RESULTADO DE LA REVISIÓN DE CONSISTENCIA FÍSICA Y LÓGICA.",
        36: "IMAGEN 36. CÓDIGO PARA REVISAR LA FRAGMENTACIÓN.",
        37: "IMAGEN 37. RESULTADO DE LA REVISIÓN DE FRAGMENTACIÓN.",
        38: "IMAGEN 38. CÓDIGO PARA REVISAR LAS ESTADÍSTICAS.",
        39: "IMAGEN 39. RESULTADO DE LA REVISIÓN DE ESTADÍSTICAS.",
        40: "IMAGEN 40. REVISIÓN DE LAS ESTADÍSTICAS RESTANTES.",
        41: "IMAGEN 41. RESULTADO DE LA REVISIÓN DE LAS ESTADÍSTICAS RESTANTES.",
        48: "IMAGEN 48. CONSULTA DEL HISTORIAL DE INVENTARIO.",
        50: "IMAGEN 50. CÓDIGO PARA CONSULTAR LOS EVENTOS DE AUDITORÍA.",
        51: "IMAGEN 51. CONSULTA CORREGIDA DE EVENTOS DE AUDITORÍA DE PEPSI_DISTRIBUCION.",
        52: "IMAGEN 52. CREACIÓN DE LA SESIÓN DE EVENTOS EXTENDIDOS.",
        53: "IMAGEN 53. SESIÓN DE EVENTOS EXTENDIDOS INICIADA.",
        54: "IMAGEN 54. INICIO DE LA SESIÓN DE EVENTOS EXTENDIDOS, CONSULTAS Y MANEJO DE ERRORES CON TRY-CATCH.",
        55: "IMAGEN 55. RESULTADO DEL CONTROL DE ERRORES CON TRY-CATCH.",
        56: "IMAGEN 56. CÓDIGO PARA DETENER Y LEER LA SESIÓN DE EVENTOS EXTENDIDOS.",
        57: "IMAGEN 57. LECTURA DE LA SESIÓN DE EVENTOS EXTENDIDOS.",
    }

    for parrafo in documento.paragraphs:
        texto = parrafo.text.strip()
        if texto in cambios_exactos:
            parrafo.text = cambios_exactos[texto]
            texto = parrafo.text.strip()
        coincidencia = re.match(r"IMAGEN\s+(\d+)\.", texto, re.IGNORECASE)
        if coincidencia:
            numero = int(coincidencia.group(1))
            if numero in pies:
                parrafo.text = pies[numero]
                parrafo.alignment = WD_ALIGN_PARAGRAPH.CENTER


def crear_evidencias():
    imagenes = {}
    imagenes[14] = crear_imagen_codigo(
        "imagen_14_roles_corregidos.png",
        """
-- ? Ortega Garcia - Nuñez Lopez - Rodriguez Macias
-- ? Asignar cada usuario al rol que le corresponde.
Alter Role rol_captura Add Member usuario_captura;
Alter Role rol_almacen Add Member usuario_almacen;
Alter Role rol_reparto Add Member usuario_reparto;
Alter Role rol_supervision Add Member usuario_supervision;
Alter Role rol_admin_tecnico Add Member usuario_admin_tecnico;
GO

-- ! El administrador tecnico no se agrega a db_owner.
""",
    )
    imagenes[15] = crear_imagen_codigo(
        "imagen_15_captura_almacen_corregidos.png",
        """
-- ? Permisos de captura.
Grant Select On Object::dbo.tienda To rol_captura;
Grant Select On Object::dbo.producto To rol_captura;
Grant Select On Object::dbo.inventario_lote To rol_captura;
Grant Select, Insert, Update On Object::dbo.pedido To rol_captura;
Grant Select, Insert, Update On Object::dbo.detalle_pedido To rol_captura;

-- ? Permisos de almacen.
Grant Select On Object::dbo.producto To rol_almacen;
Grant Select, Insert On Object::dbo.lote To rol_almacen;
Grant Select On Object::dbo.inventario_lote To rol_almacen;
Grant Select, Insert On Object::dbo.movimiento_inventario To rol_almacen;
Grant Select, Insert On Object::dbo.conteo_inventario To rol_almacen;
GO
""",
    )
    imagenes[16] = crear_imagen_codigo(
        "imagen_16_roles_restantes_corregidos.png",
        """
-- ? El administrador recibe solamente los permisos de la matriz.
-- ! No se agrega directamente a db_owner.
Grant Select, Insert, Update On Object::dbo.tienda To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.producto To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.almacen To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.lote To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.inventario_lote To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.pedido To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.detalle_pedido To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.entrega To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.detalle_entrega To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.incidencia To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.movimiento_inventario To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.conteo_inventario To rol_admin_tecnico;
Grant Select, Insert, Update On Object::dbo.detalle_conteo To rol_admin_tecnico;
GO
""",
    )
    consulta = """
-- ? Comprobar los permisos asignados a cada rol.
Select roles.name As rol, objetos.name As tabla,
  permisos.permission_name As permiso,
  permisos.state_desc As estado
From sys.database_permissions permisos
Inner Join sys.database_principals roles
  On permisos.grantee_principal_id = roles.principal_id
Inner Join sys.objects objetos
  On permisos.major_id = objetos.object_id
Where roles.name In ('rol_captura', 'rol_almacen',
  'rol_reparto', 'rol_supervision', 'rol_admin_tecnico')
Order By roles.name, objetos.name, permisos.permission_name;
GO
"""
    imagenes[17] = crear_imagen_codigo("imagen_17_comprobar_permisos.png", consulta)
    imagenes[18] = crear_imagen_codigo(
        "imagen_18_comprobar_permisos_criticos.png",
        """
-- ? Revisar los dos permisos corregidos.
Select roles.name As rol, objetos.name As tabla,
  permisos.permission_name As permiso
From sys.database_permissions permisos
Inner Join sys.database_principals roles
  On permisos.grantee_principal_id = roles.principal_id
Inner Join sys.objects objetos
  On permisos.major_id = objetos.object_id
Where roles.name In ('rol_almacen', 'rol_admin_tecnico')
  And objetos.name = 'inventario_lote'
Order By roles.name, permisos.permission_name;
GO
""",
    )
    imagenes[51] = crear_imagen_codigo(
        "imagen_51_auditoria_corregida.png",
        """
-- ? Ortega Garcia - Nuñez Lopez - Rodriguez Macias
Use pepsi_distribucion;
GO

-- ? Leer solamente eventos de la practica de 2026.
Select event_time, action_id, succeeded, database_name,
  schema_name, object_name, statement
From sys.fn_get_audit_file(
  'C:\\Data\\pepsi_auditoria_*.sqlaudit', Default, Default)
Where database_name = 'pepsi_distribucion'
  And event_time >= '2026-01-01'
  And object_name In ('tienda', 'producto', 'almacen', 'lote',
    'inventario_lote', 'pedido', 'detalle_pedido', 'entrega',
    'detalle_entrega', 'incidencia', 'movimiento_inventario',
    'conteo_inventario', 'detalle_conteo')
Order By event_time Desc;
GO
""",
    )
    return imagenes


def corregir_evidencia_auditoria(documento):
    for parrafo in documento.paragraphs:
        if "fn_get_audit_file" in parrafo.text or parrafo.text.strip().startswith("Para leer el archivo"):
            parrafo.text = (
                "Para evitar mezclar evidencias de otras bases de datos, la lectura del archivo de auditoría se filtra por la base pepsi_distribucion, por eventos correspondientes a 2026 y por los 13 objetos incluidos en el modelo del proyecto."
            )
            configurar_texto(parrafo)


def main():
    documento = Document(DOCUMENTO)
    corregir_portada(documento)
    corregir_conclusion_y_referencias(documento)
    corregir_matriz_y_explicaciones(documento)
    corregir_titulos(documento)
    corregir_evidencia_auditoria(documento)
    imagenes = crear_evidencias()
    titulos = {
        14: "IMAGEN 14. ASIGNACIÓN DE LOS USUARIOS A ROLES PERSONALIZADOS.",
        15: "IMAGEN 15. PERMISOS CORREGIDOS PARA CAPTURA Y ALMACÉN.",
        16: "IMAGEN 16. PERMISOS CORREGIDOS DEL ADMINISTRADOR TÉCNICO.",
        17: "IMAGEN 17. CONSULTA PARA COMPROBAR LOS PERMISOS ASIGNADOS.",
        18: "IMAGEN 18. COMPROBACIÓN DE LOS PERMISOS CRÍTICOS CORREGIDOS.",
        51: "IMAGEN 51. CONSULTA CORREGIDA DE EVENTOS DE AUDITORÍA DE PEPSI_DISTRIBUCION.",
    }
    for numero, ruta in imagenes.items():
        sustituir_imagen(documento, numero, ruta, titulos[numero])
    normalizar_fuentes(documento)
    documento.save(DOCUMENTO)
    print(DOCUMENTO)


if __name__ == "__main__":
    main()

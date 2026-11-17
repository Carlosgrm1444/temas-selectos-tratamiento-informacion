from pathlib import Path
import re
import subprocess
import tempfile
import time

import uno
from com.sun.star.awt import Point, Size
from com.sun.star.beans import PropertyValue


RAIZ = Path(__file__).resolve().parent
SALIDA = RAIZ / "presentacion" / "Proyecto_Unidad_3.pptx"
PDF = RAIZ / "presentacion" / "Proyecto_Unidad_3.pdf"
BASE = RAIZ.parent / "proyecto 2 corregido"
AZUL = 0x244C63
VERDE = 0x28765E
GRIS = 0x343A40


def propiedad(nombre, valor):
    dato = PropertyValue()
    dato.Name = nombre
    dato.Value = valor
    return dato


def texto(doc, pagina, contenido, x, y, ancho, alto, tam=22, color=GRIS, negrita=False, fuente="Liberation Sans"):
    forma = doc.createInstance("com.sun.star.drawing.TextShape")
    forma.Position = Point(x, y)
    forma.Size = Size(ancho, alto)
    pagina.add(forma)
    forma.String = contenido
    cursor = forma.createTextCursor()
    cursor.gotoStart(False)
    cursor.gotoEnd(True)
    cursor.CharFontName = fuente
    cursor.CharHeight = tam
    cursor.CharColor = color
    cursor.CharWeight = 150 if negrita else 100
    return forma


def imagen(doc, pagina, ruta, x, y, ancho, alto):
    forma = doc.createInstance("com.sun.star.drawing.GraphicObjectShape")
    forma.Position = Point(x, y)
    forma.Size = Size(ancho, alto)
    forma.GraphicURL = uno.systemPathToFileUrl(str(ruta.resolve()))
    pagina.add(forma)


def linea(doc, pagina, x1, y1, x2, y2, color=AZUL):
    forma = doc.createInstance("com.sun.star.drawing.LineShape")
    forma.Position = Point(x1, y1)
    forma.Size = Size(x2 - x1, y2 - y1)
    forma.LineColor = color
    forma.LineWidth = 65
    pagina.add(forma)


def nodo(doc, pagina, titulo, subtitulo, x, y, ancho=8000):
    texto(doc, pagina, titulo, x, y, ancho, 1050, 21, AZUL, True)
    texto(doc, pagina, subtitulo, x, y + 1200, ancho, 1400, 15, GRIS)


def pagina_nueva(doc, numero, titulo):
    pagina = doc.DrawPages.getByIndex(0) if numero == 1 else doc.DrawPages.insertNewByIndex(doc.DrawPages.getCount())
    pagina.Width = 33867
    pagina.Height = 19050
    if titulo:
        texto(doc, pagina, titulo, 1500, 900, 30500, 1900, 31, AZUL, True)
        texto(doc, pagina, f"PROYECTO UNIDAD 3   /   {numero:02d}", 1500, 18000, 30000, 500, 10, VERDE, True)
    return pagina


def diapositiva(doc, numero, titulo, cuerpo, destacado=None):
    pagina = pagina_nueva(doc, numero, titulo)
    texto(doc, pagina, cuerpo, 1700, 3600, 29500, 11500, 22)
    if destacado:
        texto(doc, pagina, destacado, 1700, 15200, 29500, 1800, 17, VERDE, True)
    return pagina


def extraer_codigo(archivo, nombre):
    contenido = (RAIZ / "scripts" / archivo).read_text(encoding="utf-8")
    inicio = contenido.index("Create Or Alter Procedure proyecto_u2." + nombre)
    fin = contenido.index("\nGO", inicio)
    bloque = contenido[inicio:fin]
    return bloque


def procedimiento(doc, numero, titulo, archivo, nombre, motivo):
    pagina = pagina_nueva(doc, numero, titulo)
    texto(doc, pagina, motivo, 1600, 3100, 30400, 1400, 18, VERDE)
    codigo = extraer_codigo(archivo, nombre)
    tam = 13 if len(codigo.splitlines()) <= 20 else 12
    texto(doc, pagina, codigo, 1650, 4600, 30000, 10900, tam, GRIS, False, "Liberation Mono")
    texto(doc, pagina, "Resultado: insertar aquí la captura de la ejecución real en SQL Server.", 1650, 16100, 30000, 1000, 16, AZUL, True)


def main():
    perfil = Path(tempfile.mkdtemp(prefix="impress_u3_"))
    puerto = "20991"
    proceso = subprocess.Popen([
        "soffice", "--headless", f"-env:UserInstallation={perfil.as_uri()}",
        f"--accept=socket,host=127.0.0.1,port={puerto};urp;StarOffice.ComponentContext",
        "--norestore", "--nodefault", "--nofirststartwizard",
    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    local = uno.getComponentContext()
    resolvedor = local.ServiceManager.createInstanceWithContext(
        "com.sun.star.bridge.UnoUrlResolver", local
    )
    contexto = None
    for _ in range(50):
        try:
            contexto = resolvedor.resolve(
                f"uno:socket,host=127.0.0.1,port={puerto};urp;StarOffice.ComponentContext"
            )
            break
        except Exception:
            time.sleep(0.2)
    if contexto is None:
        raise RuntimeError("No se pudo iniciar LibreOffice.")
    escritorio = contexto.ServiceManager.createInstanceWithContext(
        "com.sun.star.frame.Desktop", contexto
    )
    doc = escritorio.loadComponentFromURL("private:factory/simpress", "_blank", 0, (propiedad("Hidden", True),))
    n = 1
    pagina = pagina_nueva(doc, n, "")
    texto(doc, pagina, "Proyecto Unidad 3", 1600, 3200, 30000, 2300, 42, AZUL, True)
    texto(doc, pagina, "Datos confiables para un almacén de bebidas", 1600, 6100, 30000, 1800, 25, VERDE)
    texto(doc, pagina, "Carlos Gabriel Rodríguez Macias\nJuan Manuel Ortega García\nBernardo Guillermo Núñez López", 1600, 10400, 30000, 2800, 20)
    texto(doc, pagina, "Docente: Athala Dulce Edith Gómez Arellano  |  Noviembre 2026", 1600, 15300, 30000, 1100, 17, GRIS)
    n += 1
    diapositiva(doc, n, "Empresa y problemática", "Caso hipotético: un almacén distribuye bebidas a tiendas.\n\nPedidos, lotes y existencias llegan con registros repetidos, fechas distintas o cantidades inválidas.\n\nEsos errores pueden hacer que el inventario del sistema no coincida con el físico.")
    n += 1
    diapositiva(doc, n, "Consecuencias y objetivo", "Un lote vencido podría salir a reparto.\nUna venta podría registrarse sin producto suficiente.\nUn reporte podría contar dos veces el mismo movimiento.\n\nObjetivo: validar los datos antes de incorporarlos a SQL Server y mantener una copia recuperable.")
    n += 1
    pagina = pagina_nueva(doc, n, "Infraestructura propuesta")
    nodo(doc, pagina, "Servidor SQL", "32 GB de RAM\nDatos y log en SSD", 1500, 4400, 9000)
    nodo(doc, pagina, "Respaldo local", "Volumen separado\nRestauración rápida", 12100, 4400, 9000)
    nodo(doc, pagina, "Copia externa", "Otra ubicación\nProtege ante falla total", 22800, 4400, 9000)
    linea(doc, pagina, 10200, 6200, 11700, 6200)
    linea(doc, pagina, 20600, 6200, 22400, 6200)
    texto(doc, pagina, "Los permisos se asignan por rol. La separación de copias permite recuperar datos si falla el disco principal.", 1700, 11700, 30000, 2700, 19)
    texto(doc, pagina, "Propuesta académica: requiere medición en el equipo real.", 1700, 15500, 30000, 900, 17, VERDE, True)
    n += 1
    diapositiva(doc, n, "Reglas del negocio", "Producto: clave única, precio mayor que cero y nombre obligatorio.\nLote: pertenece a un producto, número único por producto y caducidad posterior a recepción.\nInventario: almacén y lote existentes, cantidad no negativa y una fila por almacén y lote.\n\nLas claves foráneas y las validaciones de Python evitan relaciones rotas.")
    n += 1
    pagina = pagina_nueva(doc, n, "Estructura de la base de datos")
    nodo(doc, pagina, "PRODUCTO", "id_producto (PK)\nclave, nombre, precio", 1700, 4900)
    nodo(doc, pagina, "LOTE", "id_lote (PK)\nid_producto (FK), fechas", 12700, 4900)
    nodo(doc, pagina, "INVENTARIO_LOTE", "id_inventario (PK)\nid_lote e id_almacen (FK)", 12700, 10700, 11000)
    nodo(doc, pagina, "ALMACÉN", "id_almacen (PK)\nnombre, ubicación", 24000, 10700)
    linea(doc, pagina, 9300, 6000, 12000, 6000)
    linea(doc, pagina, 16000, 7900, 16000, 10000)
    linea(doc, pagina, 22100, 11800, 23800, 11800)
    texto(doc, pagina, "1 a N", 9850, 5100, 2200, 700, 14, VERDE)
    texto(doc, pagina, "1 a N", 16500, 8500, 2200, 700, 14, VERDE)
    texto(doc, pagina, "N a 1", 22500, 10900, 2200, 700, 14, VERDE)
    texto(doc, pagina, "El modelo total tiene 13 tablas. Estas cuatro explican la ruta de los tres CSV.", 1700, 15800, 30000, 800, 17, VERDE)
    n += 1
    pagina = pagina_nueva(doc, n, "Respaldos y frecuencia")
    linea(doc, pagina, 2400, 8500, 31300, 8500)
    for x, hora, tipo in [(2500, "01:00", "FULL"), (8200, "07:00", "DIFF"), (14100, "13:00", "DIFF"), (20000, "19:00", "DIFF"), (25800, "19:15", "LOG")]:
        linea(doc, pagina, x, 7800, x, 9200, VERDE)
        texto(doc, pagina, hora, x-600, 6400, 3700, 850, 18, AZUL, True)
        texto(doc, pagina, tipo, x-500, 9800, 3900, 850, 18, VERDE, True)
    texto(doc, pagina, "FULL diario, diferencial cada 6 horas y log cada 15 minutos.", 1800, 3600, 29600, 1500, 22)
    texto(doc, pagina, "Guardar en un volumen distinto y una copia externa.", 1800, 14400, 29600, 1500, 19)
    n += 1
    pagina = pagina_nueva(doc, n, "RPO y RTO")
    texto(doc, pagina, "RPO: hasta 15 minutos de datos. Log cada 15 minutos.", 1700, 3300, 30000, 1400, 22)
    texto(doc, pagina, "RTO: volver a operar en 2 horas como máximo.", 1700, 5000, 30000, 1400, 22)
    linea(doc, pagina, 2400, 10800, 31400, 10800)
    for x, etiqueta in [(1900, "Falla"), (7300, "Verificar"), (13100, "FULL"), (18000, "DIFF"), (23300, "LOG"), (28500, "Validar")]:
        linea(doc, pagina, x+800, 10200, x+800, 11500, VERDE)
        texto(doc, pagina, etiqueta, x, 12000, 4500, 1100, 17, AZUL, True)
    texto(doc, pagina, "Se debe cronometrar una restauración de prueba para comprobar la meta.", 1700, 15200, 30000, 1300, 18, VERDE)
    n += 1
    diapositiva(doc, n, "Mantenimiento", "Diario, 00:30: comprobar respaldos recientes y espacio libre.\nDomingo, 02:00: DBCC CHECKDB para revisar integridad.\nDomingo, 03:00: revisar fragmentación y reorganizar o reconstruir índices.\nDomingo, 04:30: actualizar estadísticas.\nPrimer domingo del mes: depurar historial según retención aprobada.")
    n += 1
    pagina = pagina_nueva(doc, n, "ETL y calidad de datos")
    texto(doc, pagina, "Faker generó 50 registros por CSV. Pandas detectó nulos, duplicados, fechas distintas, valores inválidos y relaciones rotas.\n\nSe corrigieron los recuperables y se exportaron los CSV limpios sin índice para cargarlos en SQL Server.", 1500, 3100, 30000, 6800, 20)
    imagen(doc, pagina, BASE / "evidencias" / "proyecto_python" / "ejecucion_equipo" / "10_carga_sql_server.png", 1700, 11300, 28700, 3310)
    texto(doc, pagina, "Evidencia de carga del proyecto corregido", 1700, 15700, 28000, 800, 14, VERDE)
    n += 1
    diapositiva(doc, n, "Resultado de la limpieza", "Producto: 40 aptos antes, 44 después; 6 descartados.\nLote: 39 aptos antes, 42 después; 8 descartados.\nInventario_lote: 39 aptos antes, 42 después; 8 descartados.\n\nLos tres CSV finales quedaron con 100 % de registros aptos según las reglas definidas.", "Python detecta y transforma. SQL Server conserva relaciones y permite consultar el resultado.")
    ejemplos = [
        ("Subconsulta 1: precios sobre el promedio", "01_subconsultas_encriptados.sql", "usp_productos_precio_alto", "Busca precios altos para revisar el catálogo."),
        ("Subconsulta 2: lotes con existencia", "01_subconsultas_encriptados.sql", "usp_lotes_con_existencia", "Prioriza los lotes próximos a caducar con unidades disponibles."),
        ("IF 1: consultar producto", "02_if.sql", "usp_consultar_producto", "Revisa el identificador antes de mostrar información."),
        ("IF 2: validar entrada", "02_if.sql", "usp_validar_entrada", "Comprueba almacén, lote y cantidad antes de registrar una entrada."),
        ("WHILE 1: cortes de caducidad", "03_while.sql", "usp_cortes_caducidad", "Repite una consulta para cada día del periodo solicitado."),
        ("WHILE 2: resumen por almacén", "03_while.sql", "usp_resumen_almacenes", "Consulta almacenes por separado en un recorrido limitado."),
        ("CASE 1: estado del inventario", "04_case.sql", "usp_estado_inventario", "Clasifica unidades para decidir qué producto reponer."),
        ("CASE 2: estado de lotes", "04_case.sql", "usp_estado_lotes", "Clasifica fechas para atender primero los lotes vencidos."),
    ]
    for titulo, archivo, nombre, motivo in ejemplos:
        n += 1
        procedimiento(doc, n, titulo, archivo, nombre, motivo)
    n += 1
    diapositiva(doc, n, "Encriptación y manejo de errores", "Los dos procedimientos con subconsultas usan WITH ENCRYPTION y TRY...CATCH.\n\nWITH ENCRYPTION oculta la definición en el catálogo de SQL Server. El código fuente se conserva en el archivo SQL.\n\nTRY...CATCH devuelve número y mensaje si la ejecución falla. El segundo ejemplo rechaza un número de días inválido.")
    n += 1
    diapositiva(doc, n, "Índices y optimización", "La clave primaria permite ubicar una fila por su identificador. Un índice no agrupado ayuda a filtrar lotes por fecha de caducidad e id de producto.\n\nEjemplo: ix_lote_caducidad_producto.\n\nComparar el plan de ejecución y SET STATISTICS IO/TIME antes y después. Un índice adicional también ocupa espacio y cuesta mantenerlo.")
    n += 1
    diapositiva(doc, n, "Database Engine Tuning Advisor", "DTA analiza una carga de consultas y propone índices u otros cambios de diseño físico.\n\nEn este proyecto se explica la herramienta. Como trabajamos en Linux, el ejemplo práctico usa un índice T-SQL, plan de ejecución y estadísticas de lectura y tiempo.\n\nLa recomendación de DTA se puede comprobar desde un equipo Windows del laboratorio.")
    n += 1
    diapositiva(doc, n, "Participación en LSM", "Carlos: explica la problemática.\nJuan Manuel: explica el respaldo.\nBernardo: explica la limpieza.\n\nCada integrante practica sus señas y presenta una fotografía propia con el significado correspondiente. Se verifica la expresión antes de exponer.")
    n += 1
    diapositiva(doc, n, "Consulta en braille", "Consulta táctil: select nombre from producto\n\n⠎⠑⠇⠑⠉⠞  ⠝⠕⠍⠃⠗⠑  ⠋⠗⠕⠍  ⠏⠗⠕⠙⠥⠉⠞⠕\n\nCada integrante prepara una cartulina con puntos en relieve y una fotografía del trabajo terminado.\n\nLa consulta completa en SQL Server usa proyecto_u2.producto.")
    n += 1
    diapositiva(doc, n, "Cuento: La caja de los datos", "Pía Producto sabe qué bebida es. Leo Lote recuerda la fecha. Inés Inventario cuenta las cajas.\n\nDescubren un registro duplicado y una fecha extraña. Revisan los datos y guardan un respaldo. Al día siguiente, una falla ocurre y recuperan la información.\n\nLos tres integrantes narran. Habrá audio y fotografías de la actividad.", "Mensaje: cualquier persona puede aprender bases de datos con distintas formas de comunicación.")
    n += 1
    diapositiva(doc, n, "Conclusión", "Aprendimos a conectar el diseño de la base con la calidad de los datos que entran en ella.\n\nLos procedimientos ayudan a consultar con reglas claras. Los respaldos e índices apoyan la continuidad y el desempeño.\n\nEn el trabajo profesional nos llevamos una práctica: comprobar con datos y capturas que la solución sí funciona.")
    n += 1
    diapositiva(doc, n, "Evidencias para completar", "Faltan capturas reales de los ocho procedimientos y sus ocho resultados.\nFalta medir la restauración para comprobar las 2 horas del RTO.\nFalta comparar el índice antes y después con el mismo conjunto de datos.\nFaltan fotografías de LSM, tres cartulinas braille y audio del cuento.")
    n += 1
    diapositiva(doc, n, "Fuentes", "Proyecto corregido de las unidades I y II, documento del equipo.\n\nMicrosoft Learn: CREATE PROCEDURE (Transact-SQL).\nMicrosoft Learn: Database Engine Tuning Advisor.\nSEP: Sistema Braille, material de apoyo didáctico.\n\nLos archivos originales y limpios de producto, lote e inventario_lote se entregan junto con la presentación.")

    doc.storeAsURL(uno.systemPathToFileUrl(str(SALIDA.resolve())),
                   (propiedad("FilterName", "Impress MS PowerPoint 2007 XML"), propiedad("Overwrite", True)))
    doc.storeToURL(uno.systemPathToFileUrl(str(PDF.resolve())),
                   (propiedad("FilterName", "impress_pdf_Export"), propiedad("Overwrite", True)))
    doc.close(True)
    proceso.terminate()
    proceso.wait(timeout=5)
    print(f"{n} diapositivas: {SALIDA}")


if __name__ == "__main__":
    main()

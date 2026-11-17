from pathlib import Path
import sys

from docx import Document
from docx.oxml.ns import qn
from docx.shared import Pt


RAIZ = Path(__file__).resolve().parents[1]
DOCUMENTO = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else RAIZ / "documentos" / "Proyecto_Unidad_I_y_II_corregido.docx"


def aplicar_fuente(run):
    run.font.name = "Times New Roman"
    propiedades = run._element.get_or_add_rPr()
    fuentes = propiedades.get_or_add_rFonts()
    for atributo in ("ascii", "hAnsi", "eastAsia", "cs"):
        fuentes.set(qn(f"w:{atributo}"), "Times New Roman")


def main():
    documento = Document(DOCUMENTO)
    for estilo in documento.styles:
        if hasattr(estilo, "font"):
            estilo.font.name = "Times New Roman"
            propiedades = estilo.element.get_or_add_rPr()
            fuentes = propiedades.get_or_add_rFonts()
            for atributo in ("ascii", "hAnsi", "eastAsia", "cs"):
                fuentes.set(qn(f"w:{atributo}"), "Times New Roman")
        if estilo.name.startswith("TOC ") and estilo.name != "TOC Heading":
            estilo.font.size = Pt(9.5)
            estilo.paragraph_format.space_before = Pt(0)
            estilo.paragraph_format.space_after = Pt(0)
            estilo.paragraph_format.line_spacing = 1

    for parrafo in documento.paragraphs:
        for run in parrafo.runs:
            aplicar_fuente(run)
    for tabla in documento.tables:
        for fila in tabla.rows:
            for celda in fila.cells:
                for parrafo in celda.paragraphs:
                    for run in parrafo.runs:
                        aplicar_fuente(run)
    for seccion in documento.sections:
        for parrafo in seccion.header.paragraphs + seccion.footer.paragraphs:
            for run in parrafo.runs:
                aplicar_fuente(run)

    documento.save(DOCUMENTO)
    print(DOCUMENTO)


if __name__ == "__main__":
    main()

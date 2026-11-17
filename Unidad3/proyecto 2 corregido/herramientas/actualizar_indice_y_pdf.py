from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time

import uno
from com.sun.star.beans import PropertyValue


RAIZ = Path(__file__).resolve().parents[1]
DOCX = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else RAIZ / "documentos" / "Proyecto_Unidad_I_y_II_corregido.docx"
PDF = Path(sys.argv[2]).resolve() if len(sys.argv) > 2 else DOCX.with_suffix(".pdf")


def propiedad(nombre, valor):
    dato = PropertyValue()
    dato.Name = nombre
    dato.Value = valor
    return dato


def main():
    perfil = Path(tempfile.mkdtemp(prefix="libreoffice_proyecto_corregido_"))
    puerto = "20987"
    proceso = subprocess.Popen(
        [
            "soffice",
            "--headless",
            f"-env:UserInstallation={perfil.as_uri()}",
            f"--accept=socket,host=127.0.0.1,port={puerto};urp;StarOffice.ComponentContext",
            "--norestore",
            "--nodefault",
            "--nofirststartwizard",
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    documento = None
    try:
        contexto_local = uno.getComponentContext()
        resolvedor = contexto_local.ServiceManager.createInstanceWithContext(
            "com.sun.star.bridge.UnoUrlResolver", contexto_local
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
            raise RuntimeError("No fue posible iniciar LibreOffice para actualizar el índice.")

        escritorio = contexto.ServiceManager.createInstanceWithContext(
            "com.sun.star.frame.Desktop", contexto
        )
        documento = escritorio.loadComponentFromURL(
            uno.systemPathToFileUrl(str(DOCX)),
            "_blank",
            0,
            (propiedad("Hidden", True), propiedad("UpdateDocMode", 3)),
        )
        indices = documento.getDocumentIndexes()
        for indice in range(indices.getCount()):
            indices.getByIndex(indice).update()
        documento.store()
        documento.storeToURL(
            uno.systemPathToFileUrl(str(PDF)),
            (propiedad("FilterName", "writer_pdf_Export"), propiedad("Overwrite", True)),
        )
        print(DOCX)
        print(PDF)
    finally:
        if documento is not None:
            documento.close(True)
        proceso.terminate()
        try:
            proceso.wait(timeout=5)
        except subprocess.TimeoutExpired:
            proceso.kill()
        shutil.rmtree(perfil, ignore_errors=True)


if __name__ == "__main__":
    main()

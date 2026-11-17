from pathlib import Path
import sys

from PIL import Image, ImageDraw, ImageFont


RAIZ = Path(__file__).resolve().parents[1]
CARPETA = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else RAIZ / "documentos" / "qa_revision_final"


def main():
    paginas = sorted(
        CARPETA.glob("page-*.png"),
        key=lambda ruta: int(ruta.stem.split("-")[-1]),
    )
    fuente = ImageFont.load_default(size=18)
    por_hoja = 16
    columnas = 4
    ancho_celda = 250
    alto_celda = 340
    for inicio in range(0, len(paginas), por_hoja):
        grupo = paginas[inicio:inicio + por_hoja]
        hoja = Image.new("RGB", (columnas * ancho_celda, 4 * alto_celda), "#d1d5db")
        dibujo = ImageDraw.Draw(hoja)
        for posicion, ruta in enumerate(grupo):
            pagina = Image.open(ruta).convert("RGB")
            pagina.thumbnail((225, 300))
            columna = posicion % columnas
            fila = posicion // columnas
            x = columna * ancho_celda + (ancho_celda - pagina.width) // 2
            y = fila * alto_celda + 30
            hoja.paste(pagina, (x, y))
            numero = int(ruta.stem.split("-")[-1])
            dibujo.text((columna * ancho_celda + 10, fila * alto_celda + 6), f"Página {numero}", font=fuente, fill="black")
        final = inicio + len(grupo)
        hoja.save(CARPETA / f"contacto_{inicio + 1:03d}_{final:03d}.png")


if __name__ == "__main__":
    main()

import json
import re
import sys


def main() -> int:
    path = "assets/words/es-AR.json"
    text = open(path, "r", encoding="utf-8").read()

    easy = [
        "Carnaval de Gualeguaychú",
        "Charly García",
        "Kiosco",
        "Subte",
        "Pochoclo",
        "Verdulería",
        "Cumbia villera",
        "Tren argentino",
        "Peaje",
        "Chamamé",
        "Pampa",
        "Piquete",
        "Previa",
        "Boliche",
        "Camión hidrante",
        "Murga",
        "Bombos",
        "Choripán",
        "Picada",
        "Paro general",
        "Club de barrio",
        "Kermés",
        "Cancha de fútbol",
        "Chorizo al pan",
        "Adoquines",
        "Bajada a la playa",
        "Feria americana",
        "Plaza de juegos",
        "Mate en la plaza",
        "Canillita",
        "Colectivo",
        "Sube",
        "Día de lluvia",
        "Cortado",
        "Parrillita",
    ]

    medium = [
        "Punilla",
        "Tren a las Nubes",
        "Candombe uruguayo en San Telmo",
        "Fútbol 5 techado",
        "Quiniela",
        "Factura de AFIP",
        "Ticket canasta",
        "Patacón",
        "Lecop",
        "Carnet de la biblioteca",
        "Radio FM trucha",
        "Colectivo 60",
        "Línea B de subte",
        "Palermo Hollywood",
        "Microcentro",
        "Río Paraná",
        "Camalote",
        "Campera de friza",
        "Fila del banco",
        "Elecciones PASO",
        "Reintegro bancario",
        "Cuenta DNI",
        "Tarjeta Alimentar",
        "Mercado Central",
        "Tren Roca",
        "Peaje electrónico",
        "Paseo de compras",
        "DNI viejo",
        "VTV",
        "Ferretería",
        "Polideportivo",
        "Taller mecánico",
        "Carnet de conducir",
        "Sorteo del televisor",
        "Fila del cajero",
    ]

    # hard: still widely recognized by most Argentines (group of 10), just less immediate.
    hard = [
        "ANSES",
        "AFIP",
        "PAMI",
        "Piluso",
        "Yapa",
        "Campeonato de truco",
        "Chinchón",
        "Cooperadora escolar",
        "Centro de jubilados",
        "Guardia del hospital",
        "Tarifa social",
        "Boleto estudiantil",
        "Garrafa social",
        "La Salada",
        "Feria de Mataderos",
        "Parque Rivadavia",
        "Registro civil",
        "Pago Fácil",
        "Rapipago",
        "Turno online",
        "DNI vencido",
        "Libreta sanitaria",
        "Certificado de domicilio",
        "Multa de tránsito",
        "Boleta de luz",
        "Boleta de gas",
        "Expensas",
        "ABL",
        "Patente del auto",
        "Voto obligatorio",
        "Boleta sábana",
        "Cacerolazo",
        "Corte de ruta",
        "Tren Sarmiento",
        "Tren Mitre",
    ]

    items: list[tuple[str, str]] = [(t, "easy") for t in easy] + [
        (t, "medium") for t in medium
    ] + [(t, "hard") for t in hard]

    formatted_lines: list[str] = []
    for idx, (name, diff) in enumerate(items):
        comma = "," if idx < len(items) - 1 else ""
        name_json = json.dumps(name, ensure_ascii=False)
        formatted_lines.append(
            f'        {{"text": {name_json}, "difficulty": "{diff}"}}{comma}'
        )

    replacement = "\n" + "\n".join(formatted_lines) + "\n      "

    pattern = r'("id"\s*:\s*"random"[\s\S]*?"words"\s*:\s*\[)([\s\S]*?)(\n\s*\]\s*\n\s*\})'
    m = re.search(pattern, text)
    if not m:
        print("Could not locate random block", file=sys.stderr)
        return 1

    new_text = text[: m.start(2)] + replacement + text[m.end(2) :]
    open(path, "w", encoding="utf-8", newline="\n").write(new_text)
    print("updated random")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())



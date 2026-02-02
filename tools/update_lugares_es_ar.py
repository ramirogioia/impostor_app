import json
import re
import sys


def main() -> int:
    path = "assets/words/es-AR.json"
    text = open(path, "r", encoding="utf-8").read()

    easy = [
        "Obelisco",
        "Casa Rosada",
        "Congreso",
        "Teatro Colón",
        "Caminito",
        "Puerto Madero",
        "Mar del Plata",
        "Bariloche",
        "Iguazú",
        "Mendoza",
        "La Bombonera",
        "El Monumental",
        "Avenida Corrientes",
        "Patagonia",
        "El Calafate",
        "Tigre",
        "San Telmo",
        "Palermo",
        "Recoleta",
        "Rosario",
        "Córdoba",
        "La Plata",
        "Ushuaia",
        "Salta",
        "Tucumán",
        "Neuquén",
        "San Juan",
        "San Luis",
        "Santa Fe",
        "Posadas",
        "Resistencia",
        "Río Gallegos",
        "Comodoro Rivadavia",
        "Jujuy",
    ]

    medium = [
        "Tilcara",
        "Córdoba Capital",
        "San Rafael",
        "Pinamar",
        "Cariló",
        "Salinas Grandes",
        "Villa Carlos Paz",
        "Aconcagua",
        "Perito Moreno (glaciar)",
        "Cafayate",
        "San Martín de los Andes",
        "Puerto Madryn",
        "La Quiaca",
        "Parque Chaco",
        "Laguna Brava",
        "Villa La Angostura",
        "San Isidro",
        "Luján",
        "Tandil",
        "Merlo (San Luis)",
        "El Bolsón",
        "Villa Gesell",
        "Las Grutas",
        "Villa General Belgrano",
        "Capilla del Monte",
        "Potrero de los Funes",
        "San Pedro (Buenos Aires)",
        "Paraná",
    ]

    # hard must still be extremely recognizable by most Argentines (group of 10 people),
    # but less immediate than easy/medium.
    hard = [
        "Plaza de Mayo",
        "Cabildo",
        "Cementerio de Recoleta",
        "La Boca",
        "Retiro",
        "Constitución",
        "Ezeiza",
        "Aeroparque",
        "Puente de la Mujer",
        "La Rural",
        "Purmamarca",
        "Península Valdés",
        "Parque Nacional Iberá",
        "Volcán Lanín",
        "Cerro Uritorco",
        "Bosque de Arrayanes",
        "Sierras de la Ventana",
        "Ischigualasto",
        "Cueva de las Manos",
        "Gualeguaychú",
        "San Antonio de Areco",
        "Bahía Blanca",
        "Necochea",
        "Miramar",
        "Mar de Ajó",
        "San Bernardo",
        "Termas de Río Hondo",
        "San Nicolás",
        "Zárate",
        "Campana",
        "Villa María",
        "Río Cuarto",
        "Rafaela",
        "Concordia",
        "Chascomús",
    ]

    items: list[tuple[str, str]] = [(t, "easy") for t in easy] + [
        (t, "medium") for t in medium
    ] + [(t, "hard") for t in hard]

    # Format entries compactly.
    formatted_lines: list[str] = []
    for idx, (name, diff) in enumerate(items):
        comma = "," if idx < len(items) - 1 else ""
        name_json = json.dumps(name, ensure_ascii=False)
        formatted_lines.append(
            f'        {{"text": {name_json}, "difficulty": "{diff}"}}{comma}'
        )

    replacement = "\n" + "\n".join(formatted_lines) + "\n      "

    pattern = r'("id"\s*:\s*"lugares"[\s\S]*?"words"\s*:\s*\[)([\s\S]*?)(\n\s*\]\s*\n\s*\})'
    m = re.search(pattern, text)
    if not m:
        print("Could not locate lugares block", file=sys.stderr)
        return 1

    new_text = text[: m.start(2)] + replacement + text[m.end(2) :]
    open(path, "w", encoding="utf-8", newline="\n").write(new_text)
    print("updated lugares")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())



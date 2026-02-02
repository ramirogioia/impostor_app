import json
import re
import sys


def main() -> int:
    path = "assets/words/es-AR.json"
    text = open(path, "r", encoding="utf-8").read()

    easy = [
        "Arcor",
        "Quilmes",
        "Bagley",
        "La Serenísima",
        "Paty",
        "Molinos",
        "Taragüí",
        "Volkswagen",
        "Chevrolet",
        "Coca-Cola",
        "Pepsi",
        "YPF",
        "Shell",
        "Topper",
        "Puma",
        "Adidas",
        "Nike",
        "Andreani",
        "Mercado Libre",
        "Coto",
        "La Paulina",
        "Serenito",
        "Bimbo",
        "Cindor",
        "Don Satur",
        "Terrabusi",
        "Sufur",
        "Gancia",
        "Speed",
        "Patagonia",
        "Musimundo",
        "Grido",
        "McDonald's",
        "Burger King",
        "Dia",
    ]

    medium = [
        "Sancor",
        "Paladini",
        "Bon o Bon",
        "Georgalos",
        "Manaos",
        "Nobleza Gaucha",
        "Playadito",
        "Ala",
        "Asepxia",
        "Farmacity",
        "Mostaza",
        "Havanna",
        "Grimoldi",
        "Mishka",
        "Rasti",
        "Siam",
        "Philco",
        "BGH",
        "Garbarino",
        "Frávega",
        "Artesa",
        "Rex",
        "Sica",
        "Flecha Bus",
        "Plusmar",
        "La Anónima",
        "Tramontina",
        "Stanley",
        "Mamá Lucchetti",
        "Alicante",
        "Dánica",
        "Topline",
        "Coca-Cola Zero",
        "Fanta",
        "Sprite",
    ]

    # hard: still recognizable by most Argentines, just not the first brand that comes to mind.
    hard = [
        "Felfort",
        "Toddy",
        "Poxipol",
        "Geniol",
        "Mantecol",
        "Jorgito",
        "Cinzano",
        "Noblex",
        "La Gotita",
        "La Salteña",
        "Knorr",
        "Hellmann's",
        "Savora",
        "Baggio",
        "Cepita",
        "Levité",
        "Villavicencio",
        "Eco de los Andes",
        "Ser",
        "Villa del Sur",
        "Ayudín",
        "Cif",
        "Skip",
        "Poett",
        "Head & Shoulders",
        "Pantene",
        "Colgate",
        "Oral-B",
        "Dove",
        "Rexona",
        "Axe",
        "Samsung",
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

    pattern = r'("id"\s*:\s*"marcas"[\s\S]*?"words"\s*:\s*\[)([\s\S]*?)(\n\s*\]\s*\n\s*\})'
    m = re.search(pattern, text)
    if not m:
        print("Could not locate marcas block", file=sys.stderr)
        return 1

    new_text = text[: m.start(2)] + replacement + text[m.end(2) :]
    open(path, "w", encoding="utf-8", newline="\n").write(new_text)
    print("updated marcas")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())



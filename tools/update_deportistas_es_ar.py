import json
import re
import sys


def main() -> int:
    path = "assets/words/es-AR.json"
    text = open(path, "r", encoding="utf-8").read()

    # (text, difficulty)
    new_items: list[tuple[str, str]] = [
        # easy (11)
        ("Lionel Messi", "easy"),
        ("Diego Armando Maradona", "easy"),
        ("Manu Ginóbili", "easy"),
        ("Luis Scola", "easy"),
        ("Juan Martín del Potro", "easy"),
        ("Gabriela Sabatini", "easy"),
        ("Guillermo Vilas", "easy"),
        ("Luciana Aymar", "easy"),
        ("Kun Agüero", "easy"),
        ("Ángel Di María", "easy"),
        ("Paula Pareto", "easy"),
        # medium (50)
        ("Carlos Tevez", "medium"),
        ("Juan Román Riquelme", "medium"),
        ("Gabriel Batistuta", "medium"),
        ("Ariel Ortega", "medium"),
        ("Martín Palermo", "medium"),
        ("Hernán Crespo", "medium"),
        ("Javier Mascherano", "medium"),
        ("Javier Zanetti", "medium"),
        ("Roberto Ayala", "medium"),
        ("Walter Samuel", "medium"),
        ("Pablo Aimar", "medium"),
        ("Esteban Cambiasso", "medium"),
        ("Fernando Redondo", "medium"),
        ("Mario Kempes", "medium"),
        ("Daniel Passarella", "medium"),
        ("Oscar Ruggeri", "medium"),
        ("Claudio Caniggia", "medium"),
        ("Jorge Burruchaga", "medium"),
        ("Ubaldo Fillol", "medium"),
        ("Sergio Goycochea", "medium"),
        ("Carlos Bilardo", "medium"),
        ("César Luis Menotti", "medium"),
        ("Marcelo Bielsa", "medium"),
        ("Alejandro Sabella", "medium"),
        ("Marcelo Gallardo", "medium"),
        ("Carlos Bianchi", "medium"),
        ("Ramón Díaz", "medium"),
        ("Ricardo Bochini", "medium"),
        ("Juan Sebastián Verón", "medium"),
        ("Javier Saviola", "medium"),
        ("Pablo Zabaleta", "medium"),
        ("Sergio Romero", "medium"),
        ("Ezequiel Lavezzi", "medium"),
        ("Gonzalo Higuaín", "medium"),
        ("Ever Banega", "medium"),
        ("Paulo Dybala", "medium"),
        ("Mauro Icardi", "medium"),
        ("Emiliano Martínez", "medium"),
        ("Rodrigo De Paul", "medium"),
        ("Leandro Paredes", "medium"),
        ("Enzo Fernández", "medium"),
        ("Julián Álvarez", "medium"),
        ("Lautaro Martínez", "medium"),
        ("Alexis Mac Allister", "medium"),
        ("Nicolás Otamendi", "medium"),
        ("Lisandro Martínez", "medium"),
        ("Marcos Acuña", "medium"),
        ("Nicolás Tagliafico", "medium"),
        ("Agustín Pichot", "medium"),
        ("Felipe Contepomi", "medium"),
        # hard (49)
        ("David Nalbandian", "hard"),
        ("Gastón Gaudio", "hard"),
        ("Guillermo Coria", "hard"),
        ("Diego Schwartzman", "hard"),
        ("Juan Mónaco", "hard"),
        ("Guillermo Cañas", "hard"),
        ("Gisela Dulko", "hard"),
        ("Marcos Maidana", "hard"),
        ("Sergio Maravilla Martínez", "hard"),
        ("Carlos Monzón", "hard"),
        ("Nicolino Locche", "hard"),
        ("Juan Manuel Fangio", "hard"),
        ("Carlos Reutemann", "hard"),
        ("Diego Milito", "hard"),
        ("Gabriel Milito", "hard"),
        ("Javier Pastore", "hard"),
        ("Ángel Correa", "hard"),
        ("Giovanni Lo Celso", "hard"),
        ("Cristian Romero", "hard"),
        ("Marcos Rojo", "hard"),
        ("Germán Pezzella", "hard"),
        ("Exequiel Palacios", "hard"),
        ("Alejandro Garnacho", "hard"),
        ("Nicolás González", "hard"),
        ("Nahuel Molina", "hard"),
        ("Enzo Pérez", "hard"),
        ("Fernando Gago", "hard"),
        ("Juan Pablo Sorín", "hard"),
        ("Gabriel Heinze", "hard"),
        ("Martín Demichelis", "hard"),
        ("Nicolás Burdisso", "hard"),
        ("Kily González", "hard"),
        ("Pablo Prigioni", "hard"),
        ("Andrés Nocioni", "hard"),
        ("Carlos Delfino", "hard"),
        ("Fabricio Oberto", "hard"),
        ("Pepe Sánchez", "hard"),
        ("Facundo Campazzo", "hard"),
        ("Gabriel Deck", "hard"),
        ("Andrés D'Alessandro", "hard"),
        ("Ricardo Gareca", "hard"),
        ("Alfio Basile", "hard"),
        ("Sergio Batista", "hard"),
        ("Jorge Valdano", "hard"),
        ("Osvaldo Ardiles", "hard"),
        ("Norberto Alonso", "hard"),
        ("René Houseman", "hard"),
        ("Amadeo Carrizo", "hard"),
        ("Antonio Rattin", "hard"),
    ]

    # Format entries in a compact, readable way, preserving overall file formatting.
    formatted_lines: list[str] = []
    for idx, (name, diff) in enumerate(new_items):
        comma = "," if idx < len(new_items) - 1 else ""
        name_json = json.dumps(name, ensure_ascii=False)
        formatted_lines.append(
            f'        {{"text": {name_json}, "difficulty": "{diff}"}}{comma}'
        )

    replacement = "\n" + "\n".join(formatted_lines) + "\n      "

    pattern = r'("id"\s*:\s*"deportistas"[\s\S]*?"words"\s*:\s*\[)([\s\S]*?)(\n\s*\]\s*\n\s*\})'
    m = re.search(pattern, text)
    if not m:
        print("Could not locate deportistas block", file=sys.stderr)
        return 1

    new_text = text[: m.start(2)] + replacement + text[m.end(2) :]
    open(path, "w", encoding="utf-8", newline="\n").write(new_text)
    print("updated deportistas")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())



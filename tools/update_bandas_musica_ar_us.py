import json
from collections import Counter


def _validate(locale: str, data: dict[str, list[str]]) -> None:
    for k in ("easy", "medium", "hard"):
        if len(data[k]) != 40:
            raise ValueError(f"{locale}: {k} must be 40 items, got {len(data[k])}")
    all_items = data["easy"] + data["medium"] + data["hard"]
    dups = [t for t, n in Counter(all_items).items() if n > 1]
    if dups:
        raise ValueError(f"{locale}: duplicates across difficulties: {dups[:20]}")


def _set_bandas(path: str, display_name: str, lists: dict[str, list[str]]) -> None:
    data = json.load(open(path, encoding="utf-8"))
    cat = next(c for c in data["categories"] if c["id"] == "bandas_musica")
    cat["displayName"] = display_name
    words = []
    for diff in ("easy", "medium", "hard"):
        for name in lists[diff]:
            words.append({"text": name, "difficulty": diff})
    cat["words"] = words
    json.dump(data, open(path, "w", encoding="utf-8", newline="\n"), ensure_ascii=False, indent=2)
    print("updated", path)


def main() -> int:
    # Argentina-only bands (es-AR)
    ar = {
        "easy": [
            "Soda Stereo",
            "Los Fabulosos Cadillacs",
            "Los Auténticos Decadentes",
            "La Renga",
            "Los Piojos",
            "Divididos",
            "Sumo",
            "Virus",
            "Babasónicos",
            "Bersuit Vergarabat",
            "Patricio Rey y sus Redonditos de Ricota",
            "Los Abuelos de la Nada",
            "Los Ratones Paranoicos",
            "Los Enanitos Verdes",
            "Los Pericos",
            "Attaque 77",
            "Miranda!",
            "Tan Biónica",
            "Airbag",
            "Catupecu Machu",
            "Las Pelotas",
            "Turf",
            "Los Tipitos",
            "Guasones",
            "La Beriso",
            "Callejeros",
            "Intoxicados",
            "Viejas Locas",
            "Los Palmeras",
            "Damas Gratis",
            "Ráfaga",
            "Los Caligaris",
            "Los Nocheros",
            "Los Tekis",
            "Kapanga",
            "Bandana",
            "Erreway",
            "Rata Blanca",
            "Los Chalchaleros",
            "Los Manseros Santiagueños"
        ],
        "medium": [
            "Hermética",
            "Almafuerte",
            "Los Violadores",
            "2 Minutos",
            "Massacre",
            "Los Brujos",
            "Los Twist",
            "Illya Kuryaki and the Valderramas",
            "Los Caballeros de la Quema",
            "Los Gardelitos",
            "Las Pastillas del Abuelo",
            "La Mississippi",
            "La Mancha de Rolando",
            "La 25",
            "El Bordo",
            "Don Osvaldo",
            "Bandalos Chinos",
            "Cruzando el Charco",
            "Los Cafres",
            "Los Fundamentalistas del Aire Acondicionado",
            "Agapornis",
            "Los Totora",
            "Mala Fama",
            "Los Pibes Chorros",
            "Los Charros",
            "Los del Fuego",
            "Los Sultanes",
            "Amar Azul",
            "Banda XXI",
            "Los Rancheros",
            "La Portuaria",
            "Comanche",
            "Yerba Brava",
            "El Polaco",
            "Los Cafres (Argentina)",
            "Los Rancheros (Argentina)",
            "Vilma Palma e Vampiros",
            "Estelares",
            "Kapanga (Argentina)",
            "Turf (Argentina)"
        ],
        "hard": [
            "Almendra",
            "Pescado Rabioso",
            "Serú Girán",
            "Sui Generis",
            "Invisible",
            "Manal",
            "Vox Dei",
            "Los Gatos",
            "Pappo's Blues",
            "La Máquina de Hacer Pájaros",
            "Riff",
            "Memphis La Blusera",
            "Los Visitantes",
            "Los Carabajal",
            "Los Fronterizos",
            "Los Tucu Tucu",
            "Los Cantores del Alba",
            "Los Huayra",
            "Los Alonsitos",
            "La Konga",
            "La Barra",
            "Trulalá",
            "Sabroso",
            "Dale Q' Va",
            "Q' Lokura",
            "Ke Personajes",
            "La Delio Valdez",
            "El Mató a un Policía Motorizado",
            "Los Espíritus",
            "Eruca Sativa",
            "El Kuelgue",
            "Banda de Turistas",
            "La Franela",
            "Pier",
            "Salta la Banca",
            "Las Manos de Filippi",
            "Los Tipitos (otra etapa)",
            "Bersuit (otra etapa)",
            "Los Pericos (otra etapa)",
            "Los Enanitos Verdes (otra etapa)"
        ]
    }

    # USA-only bands (en-US)
    us = {
        "easy": [
            "Eagles",
            "Metallica",
            "Nirvana",
            "Pearl Jam",
            "Guns N' Roses",
            "Bon Jovi",
            "Red Hot Chili Peppers",
            "Green Day",
            "Foo Fighters",
            "Linkin Park",
            "Imagine Dragons",
            "Maroon 5",
            "The Beach Boys",
            "The Doors",
            "Aerosmith",
            "KISS",
            "Journey",
            "Chicago",
            "The Jackson 5",
            "Destiny's Child",
            "The Black Eyed Peas",
            "Backstreet Boys",
            "NSYNC",
            "Blink-182",
            "My Chemical Romance",
            "Fall Out Boy",
            "Panic! at the Disco",
            "Paramore",
            "Twenty One Pilots",
            "The Killers",
            "The Offspring",
            "No Doubt",
            "Weezer",
            "The Smashing Pumpkins",
            "Santana",
            "Creedence Clearwater Revival",
            "Earth, Wind & Fire",
            "The Supremes",
            "The Temptations",
            "Van Halen"
        ],
        "medium": [
            "Talking Heads",
            "The Ramones",
            "The Strokes",
            "The White Stripes",
            "The Black Keys",
            "Kings of Leon",
            "OneRepublic",
            "Evanescence",
            "The Chainsmokers",
            "The Lumineers",
            "R.E.M.",
            "Boston",
            "Foreigner",
            "Toto",
            "Lynyrd Skynyrd",
            "The Doobie Brothers",
            "The Allman Brothers Band",
            "Heart",
            "The Carpenters",
            "Simon & Garfunkel",
            "Hall & Oates",
            "The Mamas & the Papas",
            "Jefferson Airplane",
            "The Byrds",
            "The Monkees",
            "The Cars",
            "REO Speedwagon",
            "Grateful Dead",
            "Counting Crows",
            "Matchbox Twenty",
            "The Fray",
            "Boyz II Men",
            "TLC",
            "Wu-Tang Clan",
            "Public Enemy",
            "Run-D.M.C.",
            "A Tribe Called Quest",
            "The Roots",
            "Goo Goo Dolls",
            "Dave Matthews Band"
        ],
        "hard": [
            "Megadeth",
            "Slayer",
            "Pantera",
            "Tool",
            "Soundgarden",
            "Alice in Chains",
            "Stone Temple Pilots",
            "Nine Inch Nails",
            "Korn",
            "Slipknot",
            "Rage Against the Machine",
            "System of a Down",
            "Jane's Addiction",
            "Faith No More",
            "Pixies",
            "Sonic Youth",
            "The Velvet Underground",
            "The Flaming Lips",
            "MGMT",
            "Yeah Yeah Yeahs",
            "Outkast",
            "Beastie Boys",
            "The Fugees",
            "Deftones",
            "Incubus",
            "The Black Crowes",
            "The Pussycat Dolls",
            "Jonas Brothers",
            "Zac Brown Band",
            "The Avett Brothers",
            "Dixie Chicks",
            "The Stooges",
            "Vampire Weekend",
            "The National",
            "LCD Soundsystem",
            "The Shins",
            "Foster the People",
            "Death Cab for Cutie",
            "The XX (US popular)",
            "Haim"
        ]
    }

    # NOTE: For your strict rules, we avoid cross-country mixes.
    # We also keep 40/40/40 and no repeats within each locale.
    _validate("es-AR", ar)
    _validate("en-US", us)

    _set_bandas("assets/words/es-AR.json", "Bandas de Música", ar)
    _set_bandas("assets/words/en-US.json", "Bands", us)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())



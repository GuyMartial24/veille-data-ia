"""Génère init-db/03-donnees.sql à partir de data/sources.json et data/notions.json.

Usage (depuis la racine du dépôt) :
    python scripts/generer_donnees_sql.py

Le fichier produit est idempotent : relancé, il met à jour les lignes existantes
(INSERT ... ON CONFLICT DO UPDATE) au lieu de créer des doublons. Pour le charger :
    docker compose exec -T postgres psql -U veille -d veille -f /docker-entrypoint-initdb.d/03-donnees.sql
"""

import json
from pathlib import Path

RACINE = Path(__file__).resolve().parent.parent
SORTIE = RACINE / "init-db" / "03-donnees.sql"


def q(valeur) -> str:
    """Valeur SQL littérale (les apostrophes sont doublées)."""
    if valeur is None or valeur == "":
        return "NULL"
    if isinstance(valeur, bool):
        return "true" if valeur else "false"
    if isinstance(valeur, int):
        return str(valeur)
    return "'" + str(valeur).replace("'", "''") + "'"


def main() -> None:
    sources = json.loads((RACINE / "data" / "sources.json").read_text(encoding="utf-8"))["sources"]
    notions = json.loads((RACINE / "data" / "notions.json").read_text(encoding="utf-8"))

    lignes = [
        "-- Fichier généré par scripts/generer_donnees_sql.py : ne pas modifier à la main.",
        "-- Sources : data/sources.json ; leçons : data/notions.json.",
        "\\connect veille",
        "BEGIN;",
        "",
        "-- Sources",
    ]
    for s in sources:
        lignes.append(
            "INSERT INTO sources (nom, type, url, categorie, filtre_titre, actif) VALUES ("
            + ", ".join(q(s.get(c)) for c in ("nom", "type", "url", "categorie", "filtre_titre", "actif"))
            + ") ON CONFLICT (url) DO UPDATE SET nom = EXCLUDED.nom, type = EXCLUDED.type, "
            "categorie = EXCLUDED.categorie, filtre_titre = EXCLUDED.filtre_titre;"
        )

    lignes += ["", "-- Modules"]
    for m in notions["modules"]:
        lignes.append(
            f"INSERT INTO modules (nom, rang, emoji) VALUES ({q(m['nom'])}, {m['rang']}, {q(m['emoji'])}) "
            "ON CONFLICT (nom) DO UPDATE SET rang = EXCLUDED.rang, emoji = EXCLUDED.emoji;"
        )

    lignes += ["", "-- Notions"]
    colonnes = ("module", "numero", "titre", "definition", "fonctionnement", "analogie", "a_retenir", "lien")
    for n in notions["notions"]:
        lignes.append(
            f"INSERT INTO notions ({', '.join(colonnes)}) VALUES ("
            + ", ".join(q(n[c]) for c in colonnes)
            + ") ON CONFLICT (module, numero) DO UPDATE SET "
            + ", ".join(f"{c} = EXCLUDED.{c}" for c in colonnes[2:])
            + ";"
        )

    lignes += ["", "COMMIT;", ""]
    SORTIE.write_text("\n".join(lignes), encoding="utf-8")
    print(f"{SORTIE.relative_to(RACINE)} : {len(sources)} sources, "
          f"{len(notions['modules'])} modules, {len(notions['notions'])} notions")


if __name__ == "__main__":
    main()

"""Exporte les workflows n8n dans le dossier workflows/ du dépôt.

Usage (depuis la racine du dépôt, avec les conteneurs démarrés) :
    python scripts/exporter_workflows.py

Pour chaque workflow, le script :
  1. l'exporte avec la commande officielle `n8n export:workflow` ;
  2. retire les informations personnelles et les champs qui changent à chaque
     sauvegarde (propriétaire, e-mail, dates, compteurs) ;
  3. l'enregistre sous un nom lisible : workflows/01-test-lecture-rss-kafka.json

Les secrets ne sont jamais exportés : les credentials n'apparaissent que par
leur nom, et les valeurs sensibles passent par des variables d'environnement.
"""

import json
import re
import shutil
import subprocess
import tempfile
import unicodedata
from pathlib import Path

RACINE = Path(__file__).resolve().parent.parent
DOSSIER_SORTIE = RACINE / "workflows"

# Champs conservés : de quoi réimporter le workflow à l'identique
CHAMPS_GARDES = ["id", "name", "nodes", "connections", "settings", "pinData", "meta", "tags"]


def nom_de_fichier(nom: str) -> str:
    """« 01 - Test lecture RSS Kafka » -> « 01-test-lecture-rss-kafka.json »"""
    sans_accents = unicodedata.normalize("NFKD", nom).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", "-", sans_accents.lower()).strip("-") + ".json"


def docker(*args: str) -> None:
    subprocess.run(["docker", "compose", *args], cwd=RACINE, check=True, capture_output=True)


def main() -> None:
    docker("exec", "-T", "n8n", "sh", "-c",
           "rm -rf /tmp/export && n8n export:workflow --all --separate --output=/tmp/export/")

    with tempfile.TemporaryDirectory() as tmp:
        docker("cp", "n8n:/tmp/export/.", tmp)
        DOSSIER_SORTIE.mkdir(exist_ok=True)

        for fichier in sorted(Path(tmp).glob("*.json")):
            workflow = json.loads(fichier.read_text(encoding="utf-8"))
            if workflow.get("isArchived"):
                continue
            propre = {champ: workflow[champ] for champ in CHAMPS_GARDES if champ in workflow}
            cible = DOSSIER_SORTIE / nom_de_fichier(workflow["name"])
            cible.write_text(json.dumps(propre, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
            print(f"Exporté : {cible.relative_to(RACINE)}")


if __name__ == "__main__":
    if shutil.which("docker") is None:
        raise SystemExit("Docker est introuvable.")
    main()

#!/usr/bin/env bash
# Sauvegarde des bases PostgreSQL du projet (veille et n8n).
#
# Usage (sur le VPS, depuis n'importe quel dossier) :
#   ~/Projets_en_Production/veille-data-ia/scripts/sauvegarder_base.sh
#
# Programmé chaque nuit par cron (voir docs/deploiement.md).
#
# - pg_dump au format « custom » (-Fc) : compressé, restaurable avec pg_restore
# - un fichier par base et par jour, dans ~/sauvegardes/veille-data-ia
# - les sauvegardes de plus de 14 jours sont supprimées automatiquement
#
# Attention : la base n8n contient les credentials, chiffrés avec la
# N8N_ENCRYPTION_KEY du .env. Sans cette clé, ils ne pourront pas être relus.

set -euo pipefail

PROJET="$(cd "$(dirname "$0")/.." && pwd)"
DESTINATION="${HOME}/sauvegardes/veille-data-ia"
CONSERVATION_JOURS=14
DATE="$(date +%Y-%m-%d)"

mkdir -p "$DESTINATION"
chmod 700 "$DESTINATION"
cd "$PROJET"

for BASE in veille n8n; do
  FICHIER="${DESTINATION}/${BASE}_${DATE}.dump"
  # On écrit d'abord dans un fichier temporaire : une sauvegarde interrompue
  # ne remplace jamais une sauvegarde valide.
  docker compose exec -T postgres pg_dump -U veille -Fc "$BASE" > "${FICHIER}.tmp"
  mv "${FICHIER}.tmp" "$FICHIER"
  chmod 600 "$FICHIER"
  echo "$(date '+%F %T') sauvegarde OK : ${FICHIER} ($(du -h "$FICHIER" | cut -f1))"
done

# Rotation : suppression des sauvegardes trop anciennes
find "$DESTINATION" -name '*.dump' -mtime +"$CONSERVATION_JOURS" -print -delete

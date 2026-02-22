#!/bin/bash
# =============================================================================
# Restauration du canvas Excalidraw depuis un backup JSON
#
# Usage :
#   ./restore-canvas.sh                          # Restaure le dernier backup
#   ./restore-canvas.sh backups/canvas_2026-02-22_14-00-00.json  # Restaure un backup specifique
# =============================================================================

set -euo pipefail

CANVAS_URL="${CANVAS_URL:-http://localhost:3000}"
BACKUP_DIR="${BACKUP_DIR:-/opt/excalidraw-mcp/backups}"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Determiner le fichier a restaurer
if [ -n "${1:-}" ]; then
  RESTORE_FILE="$1"
else
  RESTORE_FILE="${BACKUP_DIR}/latest.json"
fi

if [ ! -f "${RESTORE_FILE}" ]; then
  log "ERREUR : Fichier non trouve : ${RESTORE_FILE}"
  echo ""
  echo "Backups disponibles :"
  ls -1t "${BACKUP_DIR}"/canvas_*.json 2>/dev/null | head -10
  exit 1
fi

# Extraire les elements du backup
ELEMENTS=$(python3 -c "
import json, sys
with open('${RESTORE_FILE}') as f:
    backup = json.load(f)
data = backup.get('data', backup)
elements = data.get('elements', [])
print(json.dumps(elements))
")

ELEMENT_COUNT=$(echo "${ELEMENTS}" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))")

log "Restauration de ${ELEMENT_COUNT} elements depuis ${RESTORE_FILE}"

# Effacer le canvas actuel
log "Nettoyage du canvas..."
curl -sf -X DELETE "${CANVAS_URL}/api/elements/clear" > /dev/null

# Restaurer les elements un par un (via batch si disponible)
log "Import des elements..."
curl -sf -X POST "${CANVAS_URL}/api/elements/batch" \
  -H "Content-Type: application/json" \
  -d "{\"elements\": ${ELEMENTS}}" > /dev/null

log "Restauration terminee ! Ouvre le canvas pour verifier."

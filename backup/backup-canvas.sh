#!/bin/bash
# =============================================================================
# Sauvegarde automatique du canvas Excalidraw vers un depot Git
#
# Ce script :
#   1. Recupere les elements du canvas via l'API REST
#   2. Sauvegarde dans un fichier JSON horodate
#   3. Commit et pousse vers le depot Git
#
# Installation :
#   chmod +x backup-canvas.sh
#   crontab -e
#   # Ajouter : 0 * * * * /opt/excalidraw-mcp/backup-canvas.sh >> /var/log/excalidraw-backup.log 2>&1
#
# Prerequis :
#   - curl installe
#   - git configure avec acces au depot distant
# =============================================================================

set -euo pipefail

# --- Configuration -----------------------------------------------------------
CANVAS_URL="${CANVAS_URL:-http://localhost:3000}"
BACKUP_DIR="${BACKUP_DIR:-/opt/excalidraw-mcp/backups}"
MAX_BACKUPS="${MAX_BACKUPS:-168}"  # Garder 7 jours de backups horaires (24 x 7)

# --- Fonctions ---------------------------------------------------------------

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# --- Script principal --------------------------------------------------------

log "Debut de la sauvegarde"

# Verifier que le canvas est accessible
if ! curl -sf "${CANVAS_URL}/health" > /dev/null 2>&1; then
  log "ERREUR : Le canvas n'est pas accessible (${CANVAS_URL}/health)"
  exit 1
fi

# Creer le repertoire si necessaire
mkdir -p "${BACKUP_DIR}"

# Recuperer les elements
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
BACKUP_FILE="${BACKUP_DIR}/canvas_${TIMESTAMP}.json"

ELEMENTS=$(curl -sf "${CANVAS_URL}/api/elements")
ELEMENT_COUNT=$(echo "${ELEMENTS}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('count', 0))" 2>/dev/null || echo "?")

# Sauvegarder avec des metadonnees
cat > "${BACKUP_FILE}" << JSONEOF
{
  "backup_timestamp": "${TIMESTAMP}",
  "canvas_url": "${CANVAS_URL}",
  "element_count": ${ELEMENT_COUNT},
  "data": ${ELEMENTS}
}
JSONEOF

log "Sauvegarde creee : ${BACKUP_FILE} (${ELEMENT_COUNT} elements)"

# Garder aussi un fichier "latest" pour restauration rapide
cp "${BACKUP_FILE}" "${BACKUP_DIR}/latest.json"

# Nettoyer les anciens backups (garder les N derniers)
cd "${BACKUP_DIR}"
BACKUP_COUNT=$(ls -1 canvas_*.json 2>/dev/null | wc -l)
if [ "${BACKUP_COUNT}" -gt "${MAX_BACKUPS}" ]; then
  EXCESS=$((BACKUP_COUNT - MAX_BACKUPS))
  ls -1t canvas_*.json | tail -n "${EXCESS}" | xargs rm -f
  log "Nettoyage : ${EXCESS} anciens backups supprimes"
fi

# Git commit et push (si le repertoire est un depot git)
if [ -d "${BACKUP_DIR}/.git" ]; then
  cd "${BACKUP_DIR}"
  git add -A
  if git diff --cached --quiet; then
    log "Aucun changement depuis le dernier backup"
  else
    git commit -m "backup: canvas ${TIMESTAMP} (${ELEMENT_COUNT} elements)"
    git push origin main 2>/dev/null || git push origin master 2>/dev/null || log "ATTENTION : Push echoue (verifier les credentials git)"
    log "Backup pousse vers le depot distant"
  fi
else
  log "INFO : Le repertoire n'est pas un depot git. Les backups sont sauvegardes localement uniquement."
  log "Pour activer le push GitHub : cd ${BACKUP_DIR} && git init && git remote add origin https://github.com/..."
fi

log "Sauvegarde terminee"

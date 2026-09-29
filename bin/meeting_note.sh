#!/usr/bin/env bash

# Create a new zettelkasten meeting note
# Usage: meeting_note.sh [TITLE] [VAULT_PATH]

set -euo pipefail

# Configuration
TITLE="${1:-}"
VAULT_PATH="${2:-${ZK_VAULT:-.}}"
TEMPLATE_FILE="${VAULT_PATH}/templates/meeting_note.md"

# Helper functions
log() {
    echo "[meeting_note] $*" >&2
}

error() {
    log "ERROR: $*"
    exit 1
}

# If no title provided, prompt for it
if [[ -z "$TITLE" ]]; then
    read -p "Enter meeting title: " TITLE
    [[ -z "$TITLE" ]] && error "Meeting title cannot be empty"
fi

# Ensure vault path exists
[[ ! -d "$VAULT_PATH" ]] && error "Vault path does not exist: $VAULT_PATH"

# Generate note ID (Zettelkasten format: YYYYMMDDHHMMSS)
NOTE_ID=$(date +%Y%m%d%H%M%S)

# Create slugified title for filename (remove special chars, lowercase)
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-+/-/g' | sed 's/^-\|-$//')

# Full filename
FILENAME="${NOTE_ID}-${SLUG}.md"
FILEPATH="${VAULT_PATH}/${FILENAME}"

# Check if file already exists
if [[ -f "$FILEPATH" ]]; then
    error "Note already exists: $FILEPATH"
fi

# Create note from template
if [[ ! -f "$TEMPLATE_FILE" ]]; then
    error "Template not found at $TEMPLATE_FILE"
fi

# Read template and replace placeholders
CONTENT=$(cat "$TEMPLATE_FILE")
CONTENT="${CONTENT//\{\{title\}\}/$TITLE}"
CONTENT="${CONTENT//\{\{date\}\}/$(date '+%Y-%m-%d')}"
CONTENT="${CONTENT//\{\{time24\}\}/$(date '+%H:%M')}"

# Write the note
echo "$CONTENT" > "$FILEPATH"

# Detect if running directly in terminal or in subshell
if [[ $SHLVL -eq 1 ]] && [[ -t 0 ]]; then
    # Direct terminal: open file in vim
    vim "$FILEPATH"
else
    # Subshell or non-interactive: output the filepath
    echo "$FILEPATH"
fi

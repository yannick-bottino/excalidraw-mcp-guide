# Mon Canvas Excalidraw + MCP

Un canvas Excalidraw collaboratif heberge sur un VPS, pilotable par l'IA via le protocole MCP (Model Context Protocol).

**Ce que ca permet :** demander a Claude (ou tout autre assistant IA compatible MCP) de dessiner des diagrammes, schemas d'architecture, wireframes, organigrammes, etc. directement sur un canvas Excalidraw visible dans ton navigateur.

---

## Table des matieres

1. [Acceder au canvas](#1--acceder-au-canvas)
2. [Installer le MCP selon ta plateforme](#2--installer-le-mcp)
   - [Claude.ai (navigateur)](#methode-1--claudeai-navigateur---la-plus-simple)
   - [Claude Code (terminal)](#methode-2--claude-code-terminal)
   - [Claude Desktop (application)](#methode-3--claude-desktop-application)
   - [Cursor](#methode-4--cursor)
   - [Windsurf](#methode-5--windsurf)
   - [VS Code (Copilot)](#methode-6--vs-code-copilot)
   - [JetBrains (IntelliJ, PyCharm...)](#methode-7--jetbrains-intellij-pycharm)
   - [Autres clients MCP](#methode-8--autres-clients-mcp-cline-roo-code)
3. [Utilisation : exemples de prompts](#3--utilisation--exemples-de-prompts)
4. [Sauvegardes et persistance](#4--sauvegardes-et-persistance)
   - [Pourquoi sauvegarder ?](#pourquoi-sauvegarder-)
   - [Sauvegarde manuelle](#sauvegarde-manuelle)
   - [Sauvegarde automatique (cron)](#sauvegarde-automatique-cron)
   - [Sauvegarde automatique (n8n)](#sauvegarde-automatique-n8n)
5. [Outils MCP disponibles](#5--outils-mcp-disponibles)
6. [Depannage](#6--depannage)
7. [Architecture technique](#7--architecture-technique)

---

## 1 / Acceder au canvas

### Lien direct

> **https://excalidraw.srv990361.hstgr.cloud**

C'est tout. Ouvre ce lien dans ton navigateur et tu verras le canvas Excalidraw en temps reel.

### Astuce : epingle-le pour y acceder facilement

**Chrome / Edge / Brave :**
1. Ouvre le lien ci-dessus
2. Clique sur les **3 points** en haut a droite du navigateur
3. Selectionne **"Plus d'outils"** > **"Creer un raccourci..."**
4. Coche **"Ouvrir dans une fenetre"**
5. Clique **"Creer"**

Tu auras maintenant une icone Excalidraw sur ton bureau et dans ta barre des taches, comme une vraie application.

**Firefox :**
1. Ouvre le lien
2. Glisse l'icone du cadenas (barre d'adresse) vers ta **barre de favoris**

**Mobile (iOS / Android) :**
1. Ouvre le lien dans Safari (iOS) ou Chrome (Android)
2. Appuie sur **Partager** > **"Sur l'ecran d'accueil"** (iOS) ou **"Ajouter a l'ecran d'accueil"** (Android)

### Verifier que le canvas fonctionne

Ouvre cette URL dans ton navigateur :

```
https://excalidraw.srv990361.hstgr.cloud/health
```

Tu devrais voir quelque chose comme :

```json
{"status":"healthy","timestamp":"2026-02-22T...","elementCount":0,"wsClients":0}
```

Si tu vois `"status":"healthy"`, tout fonctionne.

---

## 2 / Installer le MCP

Le MCP (Model Context Protocol) permet a un assistant IA de controler le canvas Excalidraw. Choisis la methode correspondant a l'outil que tu utilises.

### Quel abonnement faut-il ?

| Plateforme | Abonnement requis |
|------------|------------------|
| Claude.ai | Pro, Max, Team ou Enterprise |
| Claude Code | Tout abonnement Claude |
| Claude Desktop | Pro, Max, Team ou Enterprise |
| Cursor, Windsurf, VS Code | Aucun (abonnement a l'IDE suffit) |
| JetBrains | AI Assistant requis |

---

### Methode 1 : Claude.ai (navigateur) - La plus simple

**Temps : 2 minutes. Aucune installation requise.**

1. Va sur **https://claude.ai/settings/connectors**
2. Clique sur **"Add custom connector"** (ou "Ajouter un connecteur personnalise")
3. Remplis les champs :
   - **Name** : `Excalidraw Canvas`
   - **URL** : `https://mcp-excalidraw.srv990361.hstgr.cloud/mcp`
4. Laisse les champs OAuth **vides** (pas d'authentification)
5. Clique **"Add"**
6. Demarre une nouvelle conversation et teste :
   > "Dessine un rectangle bleu avec le texte Hello World sur le canvas Excalidraw"
7. Ouvre le canvas dans ton navigateur pour voir le resultat en temps reel

---

### Methode 2 : Claude Code (terminal)

**Temps : 2 minutes. Aucune installation requise.**

Ouvre ton terminal et tape :

```bash
claude mcp add --transport http excalidraw-canvas https://mcp-excalidraw.srv990361.hstgr.cloud/mcp
```

C'est tout ! Verifie avec :

```bash
claude mcp list
```

Tu devrais voir `excalidraw-canvas` dans la liste.

**Teste :**

```bash
claude
# Puis dans la conversation :
# "Decris le canvas Excalidraw actuel"
```

#### Alternative : configuration par fichier `.mcp.json`

Si tu preferes configurer via un fichier (utile pour partager la config dans un projet) :

Cree un fichier `.mcp.json` a la racine de ton projet :

```json
{
  "mcpServers": {
    "excalidraw-canvas": {
      "type": "http",
      "url": "https://mcp-excalidraw.srv990361.hstgr.cloud/mcp"
    }
  }
}
```

---

### Methode 3 : Claude Desktop (application)

**Temps : 3 minutes.**

1. Ouvre Claude Desktop
2. Va dans **Settings** (icone engrenage) > **Connectors**
3. Clique **"Add custom connector"**
4. Entre l'URL : `https://mcp-excalidraw.srv990361.hstgr.cloud/mcp`
5. Laisse les champs OAuth vides
6. Clique **"Add"**

#### Alternative si le menu Connectors n'est pas disponible

Si tu ne vois pas le menu Connectors, utilise la methode par fichier de configuration :

**Trouve le fichier de config :**
- **Windows** : `%APPDATA%\Claude\claude_desktop_config.json`
  - Pour y acceder : appuie sur `Win + R`, tape `%APPDATA%\Claude`, puis ouvre `claude_desktop_config.json`
- **Mac** : `~/Library/Application Support/Claude/claude_desktop_config.json`
  - Pour y acceder : dans le Finder, `Cmd + Shift + G`, tape le chemin

**Ajoute cette configuration** (cree le fichier s'il n'existe pas) :

```json
{
  "mcpServers": {
    "excalidraw-canvas": {
      "command": "npx",
      "args": [
        "mcp-remote@latest",
        "https://mcp-excalidraw.srv990361.hstgr.cloud/mcp"
      ]
    }
  }
}
```

> **Note :** Cette methode necessite Node.js installe sur ton ordinateur.
> Pour installer Node.js : va sur https://nodejs.org et telecharge la version LTS.

**Redemarre Claude Desktop** apres avoir modifie le fichier.

---

### Methode 4 : Cursor

**Temps : 2 minutes.**

1. Ouvre Cursor
2. Va dans **Settings** > cherche **"MCP"**
3. Clique **"Add new MCP server"**
4. Remplis :
   - **Name** : `excalidraw-canvas`
   - **Type** : `http` ou `streamable-http`
   - **URL** : `https://mcp-excalidraw.srv990361.hstgr.cloud/mcp`

#### Alternative : configuration par fichier

Cree ou modifie le fichier `~/.cursor/mcp.json` :

- **Windows** : `C:\Users\TON_NOM\.cursor\mcp.json`
- **Mac** : `~/.cursor/mcp.json`

```json
{
  "mcpServers": {
    "excalidraw-canvas": {
      "url": "https://mcp-excalidraw.srv990361.hstgr.cloud/mcp"
    }
  }
}
```

Redemarre Cursor.

---

### Methode 5 : Windsurf

**Temps : 2 minutes.**

Modifie le fichier `mcp_config.json` de Windsurf :

- **Windows** : `%APPDATA%\Windsurf\mcp_config.json`
- **Mac** : `~/Library/Application Support/Windsurf/mcp_config.json`

```json
{
  "mcpServers": {
    "excalidraw-canvas": {
      "serverUrl": "https://mcp-excalidraw.srv990361.hstgr.cloud/mcp"
    }
  }
}
```

> **Attention** : Windsurf utilise `serverUrl` (et non `url`).

Redemarre Windsurf.

---

### Methode 6 : VS Code (Copilot)

**Temps : 3 minutes. Necessite GitHub Copilot actif.**

Cree un fichier `.vscode/mcp.json` a la racine de ton projet :

```json
{
  "servers": {
    "excalidraw-canvas": {
      "type": "http",
      "url": "https://mcp-excalidraw.srv990361.hstgr.cloud/mcp"
    }
  }
}
```

> **Attention** : VS Code utilise `servers` (pas `mcpServers`) et necessite le champ `type`.

---

### Methode 7 : JetBrains (IntelliJ, PyCharm...)

**Temps : 2 minutes. Necessite le plugin AI Assistant.**

Va dans **Settings** > **Tools** > **AI Assistant** > **MCP Servers** > **Add** :

```json
{
  "mcpServers": {
    "excalidraw-canvas": {
      "url": "https://mcp-excalidraw.srv990361.hstgr.cloud/mcp"
    }
  }
}
```

---

### Methode 8 : Autres clients MCP (Cline, Roo Code...)

Si ton client MCP supporte le transport **Streamable HTTP**, utilise simplement :

| Parametre | Valeur |
|-----------|--------|
| **URL** | `https://mcp-excalidraw.srv990361.hstgr.cloud/mcp` |
| **Transport** | Streamable HTTP |
| **Authentification** | Aucune |

Si ton client ne supporte **que le transport stdio**, utilise le bridge `mcp-remote` :

```json
{
  "mcpServers": {
    "excalidraw-canvas": {
      "command": "npx",
      "args": [
        "mcp-remote@latest",
        "https://mcp-excalidraw.srv990361.hstgr.cloud/mcp"
      ]
    }
  }
}
```

> Necessite Node.js installe (https://nodejs.org).

---

## 3 / Utilisation : exemples de prompts

Une fois le MCP connecte, tu peux demander a ton assistant IA de dessiner sur le canvas. Voici des exemples de prompts que tu peux copier-coller :

### Creer des formes simples

> "Dessine un rectangle bleu au centre du canvas avec le texte 'Mon Projet'"

> "Ajoute un cercle rouge a droite du rectangle"

> "Cree une fleche qui va du rectangle vers le cercle"

### Diagrammes d'architecture

> "Dessine un schema d'architecture avec : un utilisateur, une API, une base de donnees. Connecte-les avec des fleches et ajoute des labels."

### Organigrammes

> "Cree un organigramme de decision : si l'utilisateur est connecte, afficher le dashboard, sinon afficher la page de login."

### A partir de Mermaid

> "Convertis ce diagramme Mermaid sur le canvas : `graph TD; A[Debut] --> B{Condition}; B -->|Oui| C[Action 1]; B -->|Non| D[Action 2];`"

### Gestion du canvas

> "Decris ce qu'il y a actuellement sur le canvas"

> "Efface tout le canvas"

> "Exporte le canvas en JSON"

> "Prends une capture d'ecran du canvas"

---

## 4 / Sauvegardes et persistance

### Pourquoi sauvegarder ?

> **IMPORTANT** : Le canvas Excalidraw fonctionne **en memoire**. Cela signifie que si le serveur redemarre (mise a jour, reboot du VPS, crash...), **tous les dessins sont perdus**.

Il est donc essentiel de mettre en place un systeme de sauvegarde.

### Sauvegarde manuelle

**Depuis le navigateur :**

Le canvas affiche un bouton d'export. Tu peux aussi aller sur :

```
https://excalidraw.srv990361.hstgr.cloud/api/elements
```

Cela retourne un JSON avec tous les elements du canvas. Copie-le et sauvegarde-le dans un fichier.

**Depuis Claude (via MCP) :**

> "Exporte la scene Excalidraw actuelle en JSON et affiche-la moi"

Sauvegarde le JSON retourne dans un fichier `.json` sur ton ordinateur.

**Pour restaurer :**

> "Importe cette scene Excalidraw : [colle le JSON ici]"

### Snapshots integres

Le canvas a un systeme de snapshots integre. Depuis Claude :

> "Cree un snapshot du canvas avec le nom 'mon-projet-v1'"

> "Liste tous les snapshots disponibles"

> "Restaure le snapshot 'mon-projet-v1'"

### Sauvegarde automatique (cron)

Le script `backup/backup-canvas.sh` de ce repo sauvegarde automatiquement le canvas vers un depot GitHub.

**Installation sur le VPS :**

```bash
# 1. Copie le script sur le VPS
scp backup/backup-canvas.sh root@srv990361.hstgr.cloud:/opt/excalidraw-mcp/

# 2. Connecte-toi au VPS
ssh root@srv990361.hstgr.cloud

# 3. Rends le script executable
chmod +x /opt/excalidraw-mcp/backup-canvas.sh

# 4. Configure git sur le VPS (une seule fois)
cd /opt/excalidraw-mcp
git init backups
cd backups
git remote add origin https://github.com/TON_USERNAME/excalidraw-backups.git
# OU avec un token :
# git remote add origin https://TON_TOKEN@github.com/TON_USERNAME/excalidraw-backups.git

# 5. Programme la sauvegarde toutes les heures
crontab -e
# Ajoute cette ligne :
# 0 * * * * /opt/excalidraw-mcp/backup-canvas.sh >> /var/log/excalidraw-backup.log 2>&1
```

Le script sauvegarde les elements du canvas dans un fichier JSON horodate et le pousse vers GitHub automatiquement toutes les heures.

### Sauvegarde automatique (n8n)

Si tu as **n8n** installe sur ton VPS (c'est le cas ici), tu peux creer un workflow visuel :

1. Ouvre n8n : **https://n8n.srv990361.hstgr.cloud**
2. Cree un nouveau workflow
3. Ajoute ces noeuds :

```
[Schedule Trigger]  -->  [HTTP Request]  -->  [Write File]  -->  [Git Commit/Push]
   Toutes les heures       GET /api/elements     backup.json       Vers GitHub
```

**Configuration du noeud HTTP Request :**
- Method : `GET`
- URL : `http://excalidraw-canvas:3000/api/elements`
  - (URL interne Docker, pas besoin de HTTPS ici)

**Avantage** : pas besoin de toucher au terminal, tout se configure visuellement dans n8n.

---

## 5 / Outils MCP disponibles

Le serveur MCP Excalidraw met a disposition **26 outils** que l'IA peut utiliser :

### Elements (CRUD)

| Outil | Description |
|-------|-------------|
| `describe_scene` | Decrire les elements actuels du canvas |
| `add_element` | Ajouter un element (rectangle, cercle, texte...) |
| `update_element` | Modifier un element existant |
| `delete_element` | Supprimer un element |
| `clear_canvas` | Effacer tout le canvas |
| `search_elements` | Rechercher des elements par critere |
| `batch_add_elements` | Ajouter plusieurs elements d'un coup |

### Layout et positionnement

| Outil | Description |
|-------|-------------|
| `auto_layout` | Reorganiser automatiquement les elements |
| `group_elements` | Grouper des elements |
| `align_elements` | Aligner des elements entre eux |

### Export et import

| Outil | Description |
|-------|-------------|
| `export_scene` | Exporter le canvas complet en JSON |
| `import_scene` | Importer une scene depuis un JSON |
| `export_to_image` | Exporter en image (PNG) |
| `take_screenshot` | Capture d'ecran du canvas |

### Mermaid

| Outil | Description |
|-------|-------------|
| `mermaid_to_excalidraw` | Convertir un diagramme Mermaid en elements Excalidraw |

### Snapshots

| Outil | Description |
|-------|-------------|
| `create_snapshot` | Creer un point de sauvegarde |
| `list_snapshots` | Lister les sauvegardes |
| `restore_snapshot` | Restaurer une sauvegarde |

### Viewport

| Outil | Description |
|-------|-------------|
| `set_viewport` | Controler la vue / le zoom |

---

## 6 / Depannage

### Le canvas n'affiche rien / erreur de connexion

1. Verifie que le serveur tourne : ouvre https://excalidraw.srv990361.hstgr.cloud/health
2. Si ca ne repond pas, le VPS est peut-etre eteint ou les containers stoppes
3. Connecte-toi au VPS et redemarre :
   ```bash
   ssh root@srv990361.hstgr.cloud
   cd /opt/excalidraw-mcp && docker compose up -d
   ```

### Claude ne trouve pas les outils MCP

1. Verifie la configuration MCP (voir la section correspondant a ta plateforme)
2. Redemarre ton client (Claude Desktop, Cursor, etc.)
3. Dans Claude Code, tape `claude mcp list` pour verifier

### "MCP server not responding" dans Claude.ai

1. Verifie que le MCP gateway tourne :
   ```
   https://mcp-excalidraw.srv990361.hstgr.cloud/mcp
   ```
   (une erreur 400 en GET est **normale** — le serveur attend du POST)
2. Si timeout : les containers sont probablement arretes sur le VPS

### Les dessins ont disparu

Le canvas est **en memoire**. Si le serveur a redemarre, les dessins sont perdus.

- Si tu avais un backup automatique : restaure depuis le dernier backup
- Si tu avais cree un snapshot : utilise `restore_snapshot`
- Sinon : les dessins sont malheureusement perdus. Mets en place le systeme de sauvegarde (voir section 4)

### Erreur "npx: command not found"

Tu dois installer Node.js : https://nodejs.org (version LTS recommandee).

---

## 7 / Architecture technique

```
TON NAVIGATEUR                           VPS HOSTINGER
+---------------------------+            +--------------------------------------+
|                           |            |                                      |
| https://excalidraw.       |  HTTPS     | Traefik (reverse proxy + SSL auto)   |
|   srv990361.hstgr.cloud   |----------->|   |                                  |
|                           |            |   +--> Canvas Server (:3000)          |
+---------------------------+            |   |    Excalidraw UI + REST API + WS  |
                                         |   |                                  |
TON ASSISTANT IA                         |   +--> MCP Gateway (:8001)           |
+---------------------------+            |        Supergateway (Streamable HTTP) |
|                           |            |        + MCP Server (stdio)          |
| Claude.ai / Claude Code / |  HTTPS     |                                      |
| Cursor / Windsurf / etc.  |----------->|                                      |
|                           |    MCP     +--------------------------------------+
+---------------------------+
```

**Comment ca marche :**

1. Le **Canvas Server** est une application Excalidraw modifiee qui expose une API REST et un WebSocket pour la mise a jour en temps reel.
2. Le **MCP Gateway** (Supergateway) wrappe le serveur MCP (qui parle en stdio) en protocole **Streamable HTTP**, accessible depuis internet.
3. **Traefik** est un reverse proxy qui gere automatiquement les certificats SSL (HTTPS) via Let's Encrypt.
4. Quand tu demandes a Claude de dessiner quelque chose, il envoie des commandes via MCP au Gateway, qui les transmet au Canvas Server, qui met a jour le canvas en temps reel.

### URLs de l'infrastructure

| Service | URL |
|---------|-----|
| Canvas (navigateur) | https://excalidraw.srv990361.hstgr.cloud |
| MCP endpoint (IA) | https://mcp-excalidraw.srv990361.hstgr.cloud/mcp |
| Health check | https://excalidraw.srv990361.hstgr.cloud/health |
| API Elements | https://excalidraw.srv990361.hstgr.cloud/api/elements |
| API Snapshots | https://excalidraw.srv990361.hstgr.cloud/api/snapshots |

---

## Liens utiles

- [Projet mcp_excalidraw (GitHub)](https://github.com/yctimlin/mcp_excalidraw) — le serveur MCP original
- [Documentation MCP](https://modelcontextprotocol.io) — specification du protocole
- [Node.js](https://nodejs.org) — necessaire uniquement pour la methode stdio locale

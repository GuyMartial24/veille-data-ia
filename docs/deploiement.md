# Déploiement sur le VPS

> Procédure suivie le 11 novembre 2026 pour la première mise en production. Elle sert aussi à réinstaller le projet sur une nouvelle machine.

## Les deux environnements

| | Développement | Production |
|---|---|---|
| Machine | PC Windows (Docker Desktop, x86_64) | VPS Ubuntu (ARM, aarch64), dossier `~/Projets_en_Production/veille-data-ia` |
| Ollama | Ollama pour Windows | Ollama installé sur le VPS (service systemd), partagé avec d'autres projets |
| Accès à n8n | http://localhost:5678 | Tunnel SSH : `ssh -L 5679:localhost:5678 oracle`, puis http://localhost:5679 |
| Workflows | Non publiés : on les teste à la main | **Publiés** : déclenchés à 3 h et 7 h |
| Secrets | `.env` du PC | `.env` du VPS, avec des secrets **différents** |

Règle : les workflows ne sont publiés **que** sur le VPS. Si les deux environnements étaient publiés, chacun enverrait son digest (chaque environnement a sa propre base, donc sa propre mémoire des envois).

## Prérequis vérifiés sur le VPS

- Port `5678` libre.
- Ollama écoute sur toutes les interfaces (`OLLAMA_HOST=0.0.0.0:11434`), et le pare-feu n'accepte le port `11434` que depuis les réseaux Docker (`172.16.0.0/12`) : les conteneurs peuvent joindre Ollama, Internet non.
- Modèle `llama3.1` présent (`ollama list`).

## Étapes

### 1. Récupérer le projet

```bash
cd ~/Projets_en_Production
git clone https://github.com/GuyMartial24/veille-data-ia.git
cd veille-data-ia
git switch main          # ou develop pour une version de test
```

### 2. Créer le `.env` avec de nouveaux secrets

```bash
cp .env.example .env
chmod 600 .env
sed -i "s/^POSTGRES_PASSWORD=a_remplacer$/POSTGRES_PASSWORD=$(openssl rand -hex 32)/" .env
sed -i "s/^N8N_ENCRYPTION_KEY=a_remplacer$/N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)/" .env
sed -i "s/^TELEGRAM_CHAT_ID=.*/TELEGRAM_CHAT_ID=<chat id>/" .env
sed -i "s/^EMAIL_DESTINATAIRE=.*/EMAIL_DESTINATAIRE=<adresse>/" .env
grep -n '=a_remplacer' .env   # ne doit rien afficher
```

Sauvegarder la `N8N_ENCRYPTION_KEY` dans un gestionnaire de mots de passe : sans elle, les credentials de production sont perdus.

### 3. Démarrer

```bash
docker compose up -d
docker compose ps
```

Au premier démarrage, PostgreSQL exécute les scripts de `init-db/` : création de la base `veille`, du schéma, et chargement des sources et des leçons.

Vérifications :

```bash
docker compose exec postgres psql -U veille -d veille -c "SELECT (SELECT count(*) FROM sources) AS sources, (SELECT count(*) FROM notions) AS notions;"
docker compose exec n8n node -e "fetch('http://host.docker.internal:11434/api/tags').then(r=>r.json()).then(d=>console.log(d.models.map(m=>m.name)))"
```

### 4. Créer le compte n8n

Ouvrir le tunnel SSH, aller sur http://localhost:5679 et créer le compte propriétaire.

### 5. Transférer les credentials

Les credentials sont chiffrés avec la clé de chaque environnement : on les exporte **déchiffrés**, on les transfère par SSH, et on supprime le fichier aussitôt.

Sur le PC :

```powershell
docker compose exec n8n n8n export:credentials --all --decrypted --output=/tmp/creds.json
docker compose cp n8n:/tmp/creds.json "$env:TEMP\creds.json"
scp "$env:TEMP\creds.json" oracle:/tmp/creds.json
Remove-Item "$env:TEMP\creds.json"
docker compose exec -u root n8n rm /tmp/creds.json
```

Sur le VPS :

```bash
docker compose cp /tmp/creds.json n8n:/tmp/creds.json
docker compose exec n8n n8n import:credentials --input=/tmp/creds.json
rm /tmp/creds.json
docker compose exec -u root n8n rm /tmp/creds.json
```

Puis, dans n8n du VPS, remplacer le mot de passe du credential **Postgres account** par le `POSTGRES_PASSWORD` du `.env` du VPS.

### 6. Importer les workflows

```bash
docker compose cp workflows/. n8n:/tmp/workflows/
docker compose exec n8n n8n import:workflow --separate --input=/tmp/workflows/
```

Les workflows gardent leurs identifiants : l'appel du sous-workflow 03 et les credentials sont retrouvés automatiquement.

### 7. Initialiser la base

Au premier passage, la collecte trouve toutes les annonces présentes dans les flux. Pour ne pas les faire résumer ni les envoyer :

1. Dans le workflow 02, désactiver le nœud **Call '03 - Résumés IA'** (touche **D**).
2. Exécuter le workflow 02 à la main.
3. Marquer les annonces comme déjà envoyées :
   ```bash
   docker compose exec postgres psql -U veille -d veille -c "UPDATE annonces SET envoyee_le = now() WHERE envoyee_le IS NULL;"
   ```
4. Réactiver le nœud, puis enregistrer.

### 8. Publier

Publier dans cet ordre : **00** (alertes), **03**, puis **02**, puis **04**. Ne pas publier le workflow 01 (exercice).

Dans les réglages (**Settings**) des workflows 02, 03 et 04, le champ **Error Workflow** doit désigner **00 - Alertes** : en cas d'échec en production, une alerte part sur Telegram et par e-mail. Les exécutions manuelles ne déclenchent pas d'alerte.

## Mettre à jour la production

1. Développer et tester sur le PC, exporter les workflows (`python scripts/exporter_workflows.py`), commiter. Si une modification est faite directement sur le VPS, l'exporter du VPS vers le dépôt aussitôt après, pour que le dépôt reste la référence.
2. Sur le VPS : `git pull`, puis réimporter les workflows modifiés (étape 6) et les republier.
3. Si les sources ou les leçons ont changé : `python scripts/generer_donnees_sql.py` sur le PC, commiter, puis sur le VPS :
   ```bash
   docker compose exec -T postgres psql -U veille -d veille -f /docker-entrypoint-initdb.d/03-donnees.sql
   ```
   Le chargement est idempotent et ne modifie pas la colonne `actif` des sources existantes.

## Vérifier que tout tourne

- Onglet **Executions** de chaque workflow, dans n8n du VPS : les exécutions de production y apparaissent (pas sur le canevas).
- Dans la base :
  ```bash
  docker compose exec postgres psql -U veille -d veille -c "SELECT count(*) FILTER (WHERE envoyee_le::date = current_date) AS envoyees_aujourdhui, count(*) FILTER (WHERE envoyee_le IS NULL) AS en_attente FROM annonces;"
  ```

## Sauvegarde

Activée le 11 novembre 2026. Chaque nuit à **1 h 30** (avant la collecte de 3 h, et hors du créneau 2 h - 3 h des changements d'heure), cron lance `scripts/sauvegarder_base.sh` :

- `pg_dump` des bases `veille` (sources, annonces, leçons, progression) et `n8n` (workflows, exécutions, credentials chiffrés) ;
- un fichier par base et par jour dans `~/sauvegardes/veille-data-ia`, lisible par le seul propriétaire ;
- conservation de 14 jours ; journal dans `~/sauvegardes/veille-data-ia/sauvegarde.log`.

Ligne cron (`crontab -l`) :

```
30 1 * * * /home/ubuntu/Projets_en_Production/veille-data-ia/scripts/sauvegarder_base.sh >> /home/ubuntu/sauvegardes/veille-data-ia/sauvegarde.log 2>&1
```

Restauration testée le 11 novembre 2026 dans une base temporaire : contenu identique à l'original (43 sources, 69 annonces, 371 notions, progression dans le parcours).

### Restaurer

```bash
cd ~/Projets_en_Production/veille-data-ia
docker compose exec -T postgres dropdb -U veille veille
docker compose exec -T postgres createdb -U veille veille
docker compose exec -T postgres pg_restore -U veille -d veille < ~/sauvegardes/veille-data-ia/veille_AAAA-MM-JJ.dump
```

La base `n8n` se restaure de la même façon, conteneur n8n arrêté (`docker compose stop n8n`). Ses credentials ne sont lisibles qu'avec la `N8N_ENCRYPTION_KEY` du `.env` de production.

### Limite

Les sauvegardes sont sur le disque du VPS : elles protègent des erreurs de manipulation, pas d'une perte du VPS. Amélioration possible : en copier régulièrement une hors du VPS (règle 3-2-1).

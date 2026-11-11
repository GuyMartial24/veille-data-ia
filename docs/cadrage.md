# Veille Data & IA automatisée — Fiche de cadrage

> Version 1 — 10 novembre 2026
> Statut : validé (quelques points techniques restent ouverts, voir la section 12)

## 1. Objectif

Recevoir chaque matin un digest des annonces importantes de l'écosystème Data Engineering et IA (nouvelles versions, changements incompatibles, articles techniques), résumées en français par un LLM local.

Le projet sert trois buts :

- **Veille personnelle** : suivre les outils que j'utilise sans y passer du temps chaque jour.
- **Apprentissage** : apprendre n8n de A à Z (c'est le but principal).
- **Portfolio** : montrer un pipeline de données complet, documenté et déployé.

## 2. Livrables

| Livrable | Canal | Contenu |
|----------|-------|---------|
| Digest quotidien | **Telegram** (sur le téléphone) | Liste des nouveautés du jour avec titre, source, résumé et lien |
| Digest quotidien | **E-mail** (envoyé via le SMTP de Gmail) | Le même contenu, mis en forme |
| Historique | **PostgreSQL** | Toutes les annonces collectées et leur résumé ; sert aussi au dédoublonnage |

## 3. Fréquence et horaires

Une fois par jour, en deux workflows n8n séparés :

```
Workflow 1 — 03:00 : collecte → dédoublonnage → résumé IA → enregistrement en base
Workflow 2 — 07:00 : lecture de la base → mise en forme → envoi Telegram + e-mail
```

Pourquoi deux workflows :

- 3 h est l'heure où Ollama est le moins sollicité sur le VPS (voir la section 6).
- L'envoi ne dépend pas de la vitesse de l'IA : il reste 4 heures de marge en cas de lenteur.
- Chaque workflow fait une seule chose, ce qui le rend plus simple à tester et à corriger.

Ne jamais planifier de tâche entre 2 h et 3 h, à cause des changements d'heure.

## 4. Rôle de l'IA

- **v1 : le résumé uniquement.** 2 ou 3 phrases en français par annonce, à partir du titre et de la description fournis par la source.
- Les annonces sont résumées **une par une**, jamais en parallèle.
- **Modèle : `llama3.1` (8B)**, configuré comme une variable dans n8n pour pouvoir en changer sans modifier le workflow.
- **La consigne (le prompt) compte autant que le modèle.** Elle doit au minimum demander : un résumé en français, sans introduction, sans ajouter d'information absente du texte.

### Tests du 10 novembre 2026 (même consigne, VPS chargé par l'autre programme)

| Modèle | Vitesse d'écriture | Qualité | Décision |
|--------|--------------------|---------|----------|
| `llama3.1` (8B) | 4,3 à 4,6 tokens/s, stable | Français correct, sans introduction, rien d'inventé | ✅ Retenu |
| `qwen2.5:3b` | 0,4 à 0,6 tokens/s | Bonne | ❌ Trop lent sur ce VPS (cause non identifiée), supprimé |
| `qwen2.5:14b` | Non testé | — | ❌ 9,9 Go en mémoire, déjà très sollicité par l'autre programme |

Estimation : 30 à 90 secondes par annonce, soit 15 à 45 minutes pour 30 annonces.

## 5. Environnement technique

| Élément | Valeur |
|---------|--------|
| Hébergement | VPS Ubuntu, partagé avec d'autres projets |
| Ressources | Processeur ARM (`aarch64`), 4 cœurs sans GPU, 23 Go de RAM (environ 9,6 Go disponibles), 113 Go de disque libre |
| Conteneurs | Docker 29.9.3 avec **Docker Compose** (pas k3s) |
| Orchestration | n8n |
| Base de données | PostgreSQL **dédié au projet** (indépendant de `bio_postgres`) |
| LLM | L'Ollama installé directement sur le VPS (port 11434) |
| Fuseau horaire | Le VPS est en `Europe/Paris`. n8n doit être configuré avec `GENERIC_TIMEZONE=Europe/Paris` et `TZ=Europe/Paris` (sinon il utilise `America/New_York` par défaut). |
| Accès à l'interface n8n | Par **tunnel SSH** uniquement, sans exposition sur Internet |
| Secrets | Dans un fichier `.env`, jamais versionné (il est listé dans `.gitignore`) |
| Code source | https://github.com/GuyMartial24/veille-data-ia, travail sur la branche `develop` |
| Développement | Étapes 3 à 6 **en local sur le PC** (Docker Desktop + Ollama Windows avec `llama3.1`), puis déploiement sur le VPS à l'étape 7 avec le même `docker-compose.yml` ; seul le fichier `.env` change |
| Workflows | Exportés dans `workflows/` avec `python scripts/exporter_workflows.py` (sans données personnelles) |

## 6. Contraintes

**Le VPS est partagé.** Il fait déjà tourner :

- un cluster k3s (projet *murmetric* : Kafka, InfluxDB, Grafana, Traefik, Caddy…) ;
- le projet *bio* (Airflow et PostgreSQL) ;
- le projet *rgpd-crag-agent*, qui a son propre Ollama dans Docker.

Conséquences :

- Les ports 80 et 443 sont déjà pris par Traefik et Caddy : n8n n'est pas exposé sur Internet dans la v1.
- La mémoire est limitée : n8n et PostgreSQL ne doivent pas dépasser environ 1,5 Go à eux deux.

**Ollama est déjà très sollicité.** Un programme local l'appelle 24 heures sur 24, avec `qwen2.5:14b` :

- 11 à 15 requêtes par heure la nuit (le creux est entre 1 h et 5 h), jusqu'à 34 requêtes par heure en journée ;
- certaines réponses prennent jusqu'à 10 minutes ;
- beaucoup de requêtes échouent au bout de 2 minutes, parce que l'appelant abandonne.

Règles qui en découlent :

- Le traitement tourne à 3 h.
- Les articles sont résumés un par un, avec un délai d'attente long et un nouvel essai en cas d'échec.
- Il faut éviter de charger un deuxième gros modèle en même temps que `qwen2.5:14b`, ce qui ferait déborder la mémoire.

## 7. Exigences

1. **Ajouter une source sans modifier le workflow.** Les sources sont rangées dans une table `sources` (une ligne par source). Ajouter une source GitHub ou RSS = ajouter une ligne.
2. **Pas de doublon.** Une annonce déjà envoyée ne doit jamais être renvoyée.
3. **Tolérance aux pannes.** Si une source est indisponible, les autres sont quand même traitées.
4. **Aucun secret dans le dépôt Git.**
5. **Tous les résumés sont en français**, même si la source est en anglais (c'est le cas de presque toutes). Un résumé en anglais est considéré comme un échec.

La structure de la table `sources` est décrite dans [sources.md](sources.md).

## 8. Sources de départ

Les 13 sources ont été vérifiées le 10 novembre 2026 (étape 2). La liste définitive, avec les URL, les filtres et les résultats des tests, est dans [sources.md](sources.md).

| Catégorie | Sources |
|-----------|---------|
| Orchestration et transformation | Airflow, dbt Core, Dagster |
| Streaming et stockage | Kafka, Spark, Iceberg, Delta Lake |
| IA et LLMOps | LangChain, Chroma, Ollama |
| Blogs et fondations | Apache Software Foundation, Confluent, Databricks |

Ce que la vérification a changé par rapport à la liste de départ :

- Les dépôts GitHub sont suivis par leur **flux Atom** (`releases.atom`) plutôt que par l'API, sauf Airflow.
- Chaque source a son propre **filtre regex** sur le titre, pour écarter les versions de test et les sous-paquets.
- Les adresses des flux Apache et Databricks ont changé.
- Hacker News est reporté à la v2 (service instable).

## 9. Hors périmètre v1

- Pas d'interface web ni de tableau de bord : les seules sorties sont Telegram et l'e-mail.
- Pas de temps réel : un seul digest par jour.
- Pas plus de sources que la liste de départ (13 sources). Seize sources complémentaires sont déjà vérifiées et prêtes à être activées après la v1 (voir [sources.md](sources.md)) ; le système doit permettre de les ajouter facilement (voir la section 7).
- Pas de lecture des articles complets : l'IA résume à partir du titre et de la description.
- Pas de classement ni de note d'importance par l'IA.
- Pas de RAG ni de Chroma.
- Pas de Hacker News.
- Pas de filtre pour écarter le contenu marketing (Confluent, Databricks).

## 10. v1.1 : « Le fondamental du jour »

Prévue juste après la v1, pour ne pas la retarder.

- Chaque matin, le digest ajoute **une ressource d'apprentissage** (un article de fond sur une notion de Data Engineering), en plus des nouveautés.
- Les ressources sont rangées dans une table `ressources` de la base `veille` et envoyées dans l'ordre, une seule fois chacune.
- Liste de départ : 72 ressources, soit environ 10 semaines de parcours (une par jour). Voir [ressources-apprentissage.md](ressources-apprentissage.md).
- Ajouter une ressource = ajouter une ligne dans la table, sans modifier le workflow.

Exemple de rendu :

```
📚 Le fondamental du jour (7/72) : Slowly Changing Dimensions (SCD)
https://www.sqlshack.com/implementing-slowly-changing-dimensions-scds-in-data-warehouses/
```

## 11. Idées pour la v2

- Classer les annonces par l'IA (sécurité, changement incompatible, nouvelle fonctionnalité, article de fond).
- Donner une note d'importance de 1 à 5 pour trier le digest.
- Ajouter un RAG avec Chroma et `bge-m3` (déjà installé) pour interroger l'historique de la veille.
- Ajouter Hacker News par son API officielle (`hn.algolia.com/api/v1`), plus fiable que hnrss.org.
- Écarter le contenu marketing, avec des mots à exclure ou un tri par l'IA.
- Ajouter des sources : CVE, newsletters, autres dépôts.
- Gérer les sources depuis une interface (Notion ou une page web).
- Exposer n8n de façon sécurisée, derrière le reverse proxy existant.

## 12. Points ouverts

| # | Question | Comment la trancher |
|---|----------|---------------------|
| 1 | Plusieurs modèles chargés en même temps peuvent saturer la mémoire (environ 17 Go observés pendant les tests) | À traiter à l'étape 8 |
| 2 | Quel programme appelle Ollama en continu ? | `sudo ss -tnp \| grep 11434` pendant une vague de requêtes |

## 13. Critères de réussite de la v1

- Pendant **7 jours d'affilée**, je reçois chaque matin à 7 h un digest sur Telegram **et** par e-mail.
- Aucune annonce n'apparaît deux fois.
- J'ajoute une nouvelle source en **moins de 5 minutes**, sans toucher au workflow.
- La panne d'une source n'empêche pas l'envoi du digest.
- Le projet ne ralentit pas les autres projets du VPS.

## 14. Feuille de route

| # | Étape | Livrable |
|---|-------|----------|
| 1 | Cadrage ✅ | Ce document |
| 2 | Vérification des sources ✅ | [sources.md](sources.md) : les sources testées et la structure de la table `sources` |
| 3 | Environnement ✅ | n8n et PostgreSQL lancés avec Docker Compose, en local sur le PC |
| 4 | Premier flux de bout en bout ✅ | 1 source → 1 message Telegram, sans IA ([workflows/](../workflows/)) |
| 5 | Généralisation | Toutes les sources, lues depuis la table, avec dédoublonnage |
| 6 | Brique IA | Résumés par Ollama, enregistrés en base |
| 7 | Diffusion et planification | Les workflows de 3 h et de 7 h, avec Telegram et l'e-mail |
| 8 | Robustesse | Gestion des erreurs, nouveaux essais, logs, limites d'API |

# Sources de veille — v1

> Vérifiées le 10 novembre 2026. Ce fichier est la référence pour remplir la table `sources` (étape 5).

## Structure de la table `sources`

| Colonne | Type | Exemple | Rôle |
|---------|------|---------|------|
| `id` | entier | `1` | Identifiant |
| `nom` | texte | `Apache Kafka` | Nom affiché dans le digest |
| `type` | texte | `flux` ou `github_latest` | Méthode de collecte (voir plus bas) |
| `url` | texte | `https://github.com/apache/kafka/releases.atom` | Adresse interrogée par n8n |
| `categorie` | texte | `Streaming et stockage` | Regroupement dans le digest |
| `filtre_titre` | texte (regex) | `^\d+\.\d+\.\d+$` | Ne garde que les entrées dont le titre correspond ; vide = tout garder |
| `actif` | booléen | `true` | Met une source en pause sans la supprimer |
| `date_ajout` | date | `2026-11-10` | Suivi |

### Les deux types de collecte

| Type | Ce que fait n8n | Utilisé pour |
|------|-----------------|--------------|
| `flux` | Lit un flux RSS ou Atom | Presque toutes les sources |
| `github_latest` | Appelle `GET https://api.github.com/repos/{owner}/{repo}/releases/latest` | Les dépôts dont le flux Atom est noyé sous le bruit (Airflow) |

## Sources retenues

### Orchestration et transformation

| Nom | Type | URL | Filtre titre |
|-----|------|-----|--------------|
| Apache Airflow | `github_latest` | `https://api.github.com/repos/apache/airflow/releases/latest` | *(aucun)* |
| dbt Core | `flux` | `https://github.com/dbt-labs/dbt-core/releases.atom` | `^v\d+\.\d+\.\d+$` |
| Dagster | `flux` | `https://github.com/dagster-io/dagster/releases.atom` | `^\d+\.\d+\.\d+ \(core\)` |

### Streaming et stockage

| Nom | Type | URL | Filtre titre |
|-----|------|-----|--------------|
| Apache Kafka | `flux` | `https://github.com/apache/kafka/releases.atom` | `^\d+\.\d+\.\d+$` |
| Apache Spark | `flux` | `https://github.com/apache/spark/releases.atom` | `^v\d+\.\d+\.\d+$` |
| Apache Iceberg | `flux` | `https://github.com/apache/iceberg/releases.atom` | `^apache-iceberg-\d+\.\d+\.\d+$` |
| Delta Lake | `flux` | `https://github.com/delta-io/delta/releases.atom` | `^Delta Lake \d+\.\d+\.\d+$` |

### IA et LLMOps

| Nom | Type | URL | Filtre titre |
|-----|------|-----|--------------|
| LangChain | `flux` | `https://github.com/langchain-ai/langchain/releases.atom` | `^langchain==\d+\.\d+\.\d+$` |
| Chroma | `flux` | `https://github.com/chroma-core/chroma/releases.atom` | `^\d+\.\d+\.\d+$` |
| Ollama | `flux` | `https://github.com/ollama/ollama/releases.atom` | `^v\d+\.\d+\.\d+$` |

### Blogs et fondations

| Nom | Type | URL | Filtre titre |
|-----|------|-----|--------------|
| Apache Software Foundation | `flux` | `https://news.apache.org/feed` | *(aucun)* |
| Confluent | `flux` | `https://www.confluent.io/rss.xml` | *(aucun)* |
| Databricks | `flux` | `https://www.databricks.com/feed` | *(aucun)* |

## Résultats de la vérification

| Source | Résultat | Remarque |
|--------|----------|----------|
| Airflow | ✅ par l'API | Le flux Atom ne contient que les 10 dernières entrées, et Airflow publie une dizaine de *providers* par jour : la version 3.4.0 en avait déjà disparu. L'API `releases/latest` renvoie bien la 3.4.0. |
| dbt Core | ✅ 5 versions gardées sur 10 | Notes de version complètes |
| Dagster | ✅ 10 sur 10 | Une version par semaine environ |
| Kafka | ✅ 3 sur 10 | Pas de *Releases* GitHub, seulement des tags : le texte est vide, donc pas de résumé IA |
| Spark | ✅ 4 sur 10 | Même situation que Kafka |
| Iceberg | ✅ 3 sur 10 | Versions candidates (`-rc0`, `-rc1`…) rejetées. Notes très longues (jusqu'à 480 000 caractères). |
| Delta Lake | ✅ 3 sur 10 | Builds internes `dbr-…` et `dbi-…` rejetés |
| LangChain | ✅ 1 sur 10 | Dépôt contenant de nombreux paquets : seul le paquet principal `langchain` est gardé |
| Chroma | ✅ 4 sur 10 | Aucune version depuis mai 2026, à surveiller |
| Ollama | ✅ 4 sur 10 | Plusieurs versions par semaine |
| Apache Software Foundation | ✅ | L'ancienne adresse `blogs.apache.org/foundation/feed/entries/atom` renvoie une erreur 404 : le blog a déménagé sur `news.apache.org` |
| Confluent | ✅ | Beaucoup de contenu marketing (accepté en v1) |
| Databricks | ✅ | L'ancienne adresse `databricks.com/blog/rss.xml` renvoie une erreur 404. Mélange de technique et de marketing (accepté en v1). |
| Hacker News (hnrss.org) | ❌ Reporté en v2 | Erreurs 502 à répétition ; la requête combinée (4 mots-clés + `points=50`) échoue systématiquement |

## Règles qui découlent de la vérification

1. **Clé de dédoublonnage** : l'`<id>` de l'entrée Atom, le `<guid>` de l'item RSS, ou le `html_url` de l'API GitHub. En complément, on vérifie le **lien** de l'article, car une même annonce peut arriver par deux sources.
2. **Contenu vide = pas de résumé IA** : le digest affiche seulement « *Nom* *version* est sortie » avec le lien (cas de Kafka et Spark).
3. **Couper les textes trop longs** avant de les envoyer à l'IA (par exemple aux 8 000 premiers caractères) : les notes d'Airflow font 73 000 caractères et celles d'Iceberg jusqu'à 480 000.
4. **Collecter tous les jours sans exception** : les flux Atom ne gardent que les 10 dernières entrées. Pour les dépôts très actifs comme LangChain, sauter plusieurs jours peut faire rater une version.
5. **Premier lancement** : toutes les entrées présentes semblent « nouvelles ». Il faudra les enregistrer **sans les envoyer**, pour ne pas recevoir un premier digest de 100 annonces.
6. **Trouver le flux d'une nouvelle source** : afficher le code source de la page du blog (Ctrl + U), chercher `rss`, et lire l'attribut `href` de la balise `<link rel="alternate" type="application/rss+xml">`.

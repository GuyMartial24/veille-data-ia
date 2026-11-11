# Sources de veille — v1

> Vérifiées le 10 novembre 2026. Ce document explique et justifie chaque source. Les données elles-mêmes sont dans [data/sources.json](../data/sources.json), chargées dans la table `sources` par `scripts/generer_donnees_sql.py`.

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

## Sources complémentaires (à activer après la v1)

**Critère de choix : l'apprentissage d'abord.** Une source est retenue si elle aide à **comprendre comment fonctionnent** les technologies (articles techniques, documentation, explications des nouvelles versions). Les sources d'actualité générale, d'annonces commerciales ou de levées de fonds sont écartées, même si elles sont populaires.

Vérifiées le 11 novembre 2026. Elles seront ajoutées à la table `sources` avec `actif = false` : la v1 démarre avec les 13 sources ci-dessus, pour garder un volume maîtrisé pendant les tests. Une fois la v1 validée, il suffira de passer `actif` à `true`, sans modifier le workflow (c'est le test du critère « ajouter une source en moins de 5 minutes »).

### Newsletters et blogs d'ingénierie

| Nom | URL | Filtre titre | Rythme constaté | Pourquoi |
|-----|-----|--------------|-----------------|----------|
| Data Engineering Weekly | `https://www.dataengineeringweekly.com/feed` | *(aucun)* | 1 à 2 par semaine | Newsletter qui sélectionne chaque semaine les meilleurs articles du domaine |
| Seattle Data Guy | `https://seattledataguy.substack.com/feed` | *(aucun)* | 2 par mois | Analyses du métier de data engineer |
| Netflix Technology Blog | `https://netflixtechblog.com/feed` | *(aucun)* | 3 à 4 par mois | Retours d'expérience sur des architectures data à très grande échelle |
| Airbnb Engineering | `https://medium.com/feed/airbnb-engineering` | *(aucun)* | 3 par mois | Idem ; Airbnb est à l'origine d'Airflow |
| Apache Airflow (blog) | `https://airflow.apache.org/blog/index.xml` | *(aucun)* | Variable | Articles détaillés sur chaque version (plus riches que les notes GitHub). Attention : Toutes les entrées portent la même date : le dédoublonnage doit se faire sur le lien, pas sur la date. |
| DuckDB | `https://duckdb.org/feed.xml` | *(aucun)* | 3 par mois | Base analytique embarquée, très utilisée en data engineering |

### IA et LLMOps

| Nom | URL | Filtre titre | Rythme constaté | Pourquoi |
|-----|-----|--------------|-----------------|----------|
| Ollama (blog) | `https://ollama.com/blog/rss.xml` | *(aucun)* | 2 par mois | L'outil qui fait tourner le LLM de ce projet |
| Hugging Face | `https://huggingface.co/blog/feed.xml` | *(aucun)* | 5 par semaine | Nouveaux modèles et techniques ouvertes ; volume élevé |
| Simon Willison | `https://simonwillison.net/atom/entries/` | *(aucun)* | 1 à 2 par semaine | Référence sur l'usage pratique des LLM (flux « entries » : articles de fond seulement, pas les liens du jour) |
| Sebastian Raschka (Ahead of AI) | `https://magazine.sebastianraschka.com/feed` | *(aucun)* | 2 par mois | Explique le fonctionnement interne des LLM en les reconstruisant pas à pas |
| Hamel Husain | `https://hamel.dev/index.xml` | *(aucun)* | 1 par mois | Évaluer une application d'IA : méthodes concrètes |
| Model Context Protocol (blog) | `https://blog.modelcontextprotocol.io/index.xml` | *(aucun)* | 1 par mois | Le protocole qui relie les LLM aux outils ; explications des nouvelles versions de la spécification |
| LangGraph | `https://github.com/langchain-ai/langgraph/releases.atom` | `^langgraph==\d+\.\d+\.\d+$` | 2 par mois | Le framework d'agents utilisé dans le projet `rgpd-crag-agent`. Le filtre écarte `langgraph-sdk` et `langgraph-cli`. |
| pgvector | `https://github.com/pgvector/pgvector/tags.atom` | `^v\d+\.\d+\.\d+$` | Moins de 1 par mois | La recherche vectorielle dans PostgreSQL, base déjà utilisée par ce projet (pas de *Releases* GitHub, d'où `tags.atom`) |

### Conteneurs et infrastructure

| Nom | URL | Filtre titre | Rythme constaté | Pourquoi |
|-----|-----|--------------|-----------------|----------|
| Kubernetes (blog officiel) | `https://kubernetes.io/feed.xml` | *(aucun)* | 2 par semaine | Annonces de versions, nouvelles fonctionnalités, bonnes pratiques |
| Docker Compose | `https://github.com/docker/compose/releases.atom` | `^v\d+\.\d+\.\d+$` | 2 à 3 par mois | L'outil de déploiement de ce projet |
| Docker Engine | `https://github.com/moby/moby/releases.atom` | `^v\d+\.\d+\.\d+$` | 2 par mois | Le moteur Docker. Le filtre écarte les versions de test (`-rc`) et la branche `v2.0.0-beta` |
| k3s | `https://github.com/k3s-io/k3s/releases.atom` | `^v\d+\.\d+\.0\+k3s\d+$` | Environ 1 tous les 4 mois | Le Kubernetes léger du VPS (projet murmetric). Le filtre ne garde que les nouvelles versions majeures (`x.y.0`) : k3s publie chaque correctif sur trois branches à la fois, ce qui ferait beaucoup de bruit. Au moment du test, aucune version `x.y.0` ne figurait dans les 10 dernières entrées. |

### Écosystème Apache

Le blog général de la fondation (`news.apache.org/feed`) fait déjà partie de la v1. Les sources ci-dessous ajoutent les annonces de **tous** les projets Apache de la data, et les blogs des projets qui en ont un.

| Nom | URL | Filtre titre | Rythme constaté | Pourquoi |
|-----|-----|--------------|-----------------|----------|
| Annonces Apache (versions et failles de sécurité) | `https://lists.apache.org/api/atom.lua?list=announce&domain=apache.org` | voir ci-dessous | 5 à 10 par jour après filtrage, parfois beaucoup plus | Le flux de la liste officielle `announce@apache.org` : chaque nouvelle version et chaque faille de sécurité (CVE) de **tous** les projets Apache (environ 350). Le filtre ne garde que les projets data. |
| Apache Flink (blog) | `https://flink.apache.org/posts/index.xml` | *(aucun)* | 1 par mois | Le traitement de flux, complémentaire de Kafka et Spark |
| Apache Iceberg (blog) | `https://iceberg.apache.org/rss.xml` | `^(?!Apache Iceberg .*Release$)` | 1 par mois | Articles de fond seulement : le filtre écarte les annonces de versions, déjà suivies par GitHub |
| Apache Arrow (blog) | `https://arrow.apache.org/feed.xml` | *(aucun)* | 2 par mois | Le format en mémoire utilisé par Spark, pandas, DuckDB, Polars… |
| Apache Parquet (blog) | `https://parquet.apache.org/blog/index.xml` | *(aucun)* | Moins de 1 par mois | Le format de fichier des lakehouses |
| Apache DataFusion (blog) | `https://datafusion.apache.org/blog/feed.xml` | *(aucun)* | 2 par mois | Moteur de requêtes en Rust ; Comet accélère Spark |
| Apache Hudi (blog) | `https://hudi.apache.org/blog/rss.xml` | *(aucun)* | 2 par mois | Format de table concurrent d'Iceberg et Delta Lake |
| Apache Polaris (blog) | `https://polaris.apache.org/blog/index.xml` | *(aucun)* | Moins de 1 par mois | Catalogue pour les tables Iceberg |
| Apache Beam (blog) | `https://beam.apache.org/feed.xml` | *(aucun)* | 1 par mois | Modèle unifié batch et streaming |

**Filtre des annonces Apache.** Il garde :

- les **failles de sécurité** (titres qui commencent par `CVE-`) des projets data, y compris Kafka, Spark, Airflow et Iceberg ;
- les **annonces de versions** (titres qui commencent par `[ANNOUNCE]`) des projets data **non suivis ailleurs**. Kafka, Spark, Airflow et Iceberg en sont exclus, car leurs versions arrivent déjà par GitHub : on évite ainsi les doublons.

```
^(CVE-.*Apache (Kafka|Spark|Airflow|Iceberg|Flink|Arrow|Parquet|Hudi|Beam|DataFusion|Polaris|Hadoop|Hive|NiFi|Cassandra|Superset|Druid|Pinot|Doris|Paimon|Avro|ORC|ZooKeeper|Kyuubi|Sedona|Gravitino|Fluss)|\[ANNOUNCE\].*\b(Flink|Arrow|Parquet|Hudi|Beam|DataFusion|Polaris|Hadoop|Hive|NiFi|Cassandra|Superset|Druid|Pinot|Doris|Paimon|Avro|ORC|ZooKeeper|Kyuubi|Sedona|Gravitino|Fluss)\b)
```

Test du 11 novembre 2026 : sur les 100 dernières annonces (2,5 jours), 19 sont gardées, dont **18 failles de sécurité d'Airflow** publiées le même jour.

Points d'attention :

- Le flux ne contient que les **100 dernières annonces**, soit 2 à 3 jours. Si la collecte s'arrête plus longtemps, des annonces seront perdues.
- Les failles de sécurité arrivent parfois par dizaines le même jour. Une amélioration utile serait de les **regrouper par projet** dans le digest (« 18 failles de sécurité dans Airflow » plutôt que 18 lignes).
- Les expressions régulières de n8n suivent la syntaxe JavaScript : pas de `(?i)` pour ignorer la casse, d'où les noms de projets écrits avec leur casse exacte.

### Langages et outils de build

| Nom | URL | Filtre titre | Rythme constaté | Pourquoi |
|-----|-----|--------------|-----------------|----------|
| Scala (blog officiel) | `https://www.scala-lang.org/feed/index.xml` | *(aucun)* | 2 par mois | Nouvelles versions de Scala et de sbt, avis de sécurité. Plus lisible que les versions GitHub de `scala/scala3`, dont les titres ne suivent pas un format régulier. |
| Apache Maven | `https://github.com/apache/maven/releases.atom` | `^(Maven )?\d+\.\d+\.\d+$` | 1 tous les 2 à 4 mois | Le filtre écarte les versions candidates (`-rc`) et les entrées d'archivage de branches (`archive/…`, `backup/…`). Il gardera aussi « Maven 4.0.0 » à sa sortie. |

Spark ne publie pas de flux d'actualités (`spark.apache.org/news` n'a pas de flux RSS) : ses versions sont déjà suivies par la source GitHub de la v1.

### Outils du projet

| Nom | URL | Filtre titre | Rythme constaté | Pourquoi |
|-----|-----|--------------|-----------------|----------|
| n8n | `https://github.com/n8n-io/n8n/releases.atom` | `^n8n@\d+\.\d+\.0$` | 1 par semaine | Les nouvelles fonctionnalités de l'outil du projet. Le filtre ne garde que les versions `x.y.0` : n8n publie plusieurs correctifs par jour. |

### Candidats écartés

| Candidat | Raison |
|----------|--------|
| dbt Labs (`getdbt.com/blog/rss.xml`) | Surtout des témoignages clients et du contenu commercial sur l'IA |
| AWS Big Data Blog | Volume élevé et très orienté produits AWS |
| Engineering at Meta | Sujets trop éloignés de la data |
| PostgreSQL News | Surtout des annonces d'outils tiers |
| Delta Lake (`delta.io/rss.xml`) | Une seule publication en 3 mois ; les versions sont déjà suivies par GitHub |
| Chip Huyen | Plus de publication depuis janvier 2025 |
| LangChain (blog) | Pas de flux RSS trouvé ; les versions sont déjà suivies par GitHub |
| Start Data Engineering | Flux introuvable (404) ; un de ses articles est dans les ressources d'apprentissage |
| Docker (blog) | Surtout des annonces commerciales (programmes partenaires, produits) |
| CNCF (blog) | Surtout des annonces de nouveaux membres et d'événements |
| Kubernetes (versions GitHub) | Plusieurs branches publiées le même jour, et versions alpha et bêta ; le blog officiel annonce déjà chaque version |
| Helm | Outil non utilisé dans les projets actuels |
| Apache Kafka (blog) | Le flux existe (`kafka.apache.org/blog/index.xml`) mais il est vide ; versions et failles arrivent par GitHub et par les annonces Apache |
| Apache Spark, Druid, Superset, Cassandra, NiFi, Paimon | Pas de flux RSS sur leur site ; leurs versions et failles arrivent par les annonces Apache |
| Apache Pinot | Flux introuvable (404) ; ses annonces arrivent par les annonces Apache |
| Apache Hadoop | Une seule publication en 2026 ; ses annonces arrivent par les annonces Apache |
| Apache Doris (blog) | Actif, mais surtout des articles de l'éditeur commercial du projet, et hors de la pile technique actuelle |
| Planet Apache | Aucun flux trouvé |
| OpenAI (actualités) | Environ 220 articles en 3 mois, surtout des témoignages clients |
| Mistral AI (actualités) | Annonces de produits plutôt qu'explications |
| Latent Space | Newsletter quotidienne d'actualité et podcasts longs |
| Import AI | Orientée politique et recherche générale de l'IA |
| LangChain (blog) | Environ 100 articles en 3 mois, nombreux témoignages clients ; LangGraph est suivi par ses versions |
| Anthropic, Google DeepMind, LlamaIndex, The Batch | Pas de flux RSS exploitable |
| Eugene Yan | Inactif depuis juin 2026 ; un de ses articles de référence est dans les ressources d'apprentissage |
| Qdrant, vLLM | Outils non utilisés dans les projets actuels |

## Résultats de la vérification

| Source | Résultat | Remarque |
|--------|----------|----------|
| Airflow | OK, par l'API | Le flux Atom ne contient que les 10 dernières entrées, et Airflow publie une dizaine de *providers* par jour : la version 3.4.0 en avait déjà disparu. L'API `releases/latest` renvoie bien la 3.4.0. |
| dbt Core | OK, 5 versions gardées sur 10 | Notes de version complètes |
| Dagster | OK, 10 sur 10 | Une version par semaine environ |
| Kafka | OK, 3 sur 10 | Pas de *Releases* GitHub, seulement des tags : le texte est vide, donc pas de résumé IA |
| Spark | OK, 4 sur 10 | Même situation que Kafka |
| Iceberg | OK, 3 sur 10 | Versions candidates (`-rc0`, `-rc1`…) rejetées. Notes très longues (jusqu'à 480 000 caractères). |
| Delta Lake | OK, 3 sur 10 | Builds internes `dbr-…` et `dbi-…` rejetés |
| LangChain | OK, 1 sur 10 | Dépôt contenant de nombreux paquets : seul le paquet principal `langchain` est gardé |
| Chroma | OK, 4 sur 10 | Aucune version depuis mai 2026, à surveiller |
| Ollama | OK, 4 sur 10 | Plusieurs versions par semaine |
| Apache Software Foundation | OK | L'ancienne adresse `blogs.apache.org/foundation/feed/entries/atom` renvoie une erreur 404 : le blog a déménagé sur `news.apache.org` |
| Confluent | OK | Beaucoup de contenu marketing (accepté en v1) |
| Databricks | OK | L'ancienne adresse `databricks.com/blog/rss.xml` renvoie une erreur 404. Mélange de technique et de marketing (accepté en v1). |
| Hacker News (hnrss.org) | Reporté en v2 | Erreurs 502 à répétition ; la requête combinée (4 mots-clés + `points=50`) échoue systématiquement |

## Règles qui découlent de la vérification

1. **Clé de dédoublonnage** : l'`<id>` de l'entrée Atom, le `<guid>` de l'item RSS, ou le `html_url` de l'API GitHub. En complément, on vérifie le **lien** de l'article, car une même annonce peut arriver par deux sources.
2. **Contenu vide = pas de résumé IA** : le digest affiche seulement « *Nom* *version* est sortie » avec le lien (cas de Kafka et Spark).
3. **Couper les textes trop longs** avant de les envoyer à l'IA (par exemple aux 8 000 premiers caractères) : les notes d'Airflow font 73 000 caractères et celles d'Iceberg jusqu'à 480 000.
4. **Collecter tous les jours sans exception** : les flux Atom ne gardent que les 10 dernières entrées. Pour les dépôts très actifs comme LangChain, sauter plusieurs jours peut faire rater une version.
5. **Premier lancement** : toutes les entrées présentes semblent « nouvelles ». Il faudra les enregistrer **sans les envoyer**, pour ne pas recevoir un premier digest de 100 annonces.
6. **Trouver le flux d'une nouvelle source** : afficher le code source de la page du blog (Ctrl + U), chercher `rss`, et lire l'attribut `href` de la balise `<link rel="alternate" type="application/rss+xml">`.

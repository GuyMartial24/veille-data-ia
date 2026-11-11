# Ressources d'apprentissage — « Le fondamental du jour »

> Rubrique prévue en **v1.1** : chaque matin, le digest ajoute **une** ressource non encore envoyée.
> 40 ressources, soit 8 semaines de parcours.
> Ressources 1 à 21 : une publication LinkedIn « Data Engineering : des fondamentaux aux systèmes prêts pour la production » (les liens raccourcis `lnkd.in` ont été remplacés par leur adresse réelle).
> Ressources 22 à 40 : des références reconnues du domaine, ajoutées pour compléter le parcours.
> Tous les liens ont été vérifiés le 11 novembre 2026.

## Structure prévue de la table `ressources`

| Colonne | Type | Exemple | Rôle |
|---------|------|---------|------|
| `id` | entier | `1` | Identifiant |
| `ordre` | entier | `1` | Ordre d'envoi : du plus simple au plus avancé |
| `titre` | texte | `Data Lake vs Data Warehouse` | Titre affiché dans le digest |
| `url` | texte | `https://www.splunk.com/…` | Lien vers la ressource |
| `theme` | texte | `Architecture et stockage` | Regroupement |
| `envoye_le` | date | `2026-11-20` ou vide | Date d'envoi ; vide = pas encore envoyée |
| `actif` | booléen | `true` | Permet d'écarter une ressource sans la supprimer |

Règle d'envoi : chaque jour, la ressource active **non encore envoyée** qui a le plus petit `ordre`.

## La liste

| # | Titre | Thème | Site | Lien | Remarque |
|---|-------|-------|------|------|----------|
| 1 | Data Lake vs Data Warehouse | Architecture et stockage | Splunk (blog) | https://www.splunk.com/en_us/blog/learn/data-warehouse-vs-data-lake.html | |
| 2 | Delta Lake Architecture | Architecture et stockage | Databricks (documentation) | https://docs.databricks.com/aws/en/delta/ | Documentation officielle |
| 3 | Medallion Architecture | Architecture et stockage | Databricks (glossaire) | https://www.databricks.com/glossary/medallion-architecture | |
| 4 | ETL vs ELT | Transformation et orchestration | dbt Labs (blog) | https://www.getdbt.com/blog/etl-vs-elt | |
| 5 | Apache Airflow Basics | Transformation et orchestration | Apache Airflow (documentation) | https://airflow.apache.org/docs/apache-airflow/stable/tutorial/fundamentals.html | Documentation officielle |
| 6 | DAG Design Patterns | Transformation et orchestration | Medium | https://medium.com/@gharikrishnade/airflow-dag-design-patterns-keeping-it-clean-and-modular-ae07bf9b6f11 | Article de particulier ; peut être réservé aux abonnés Medium |
| 7 | dbt Core Explained | Transformation et orchestration | Medium | https://medium.com/the-ai-analytics-corner/dbt-core-introduction-for-data-engineering-f5a2e2cacf7d | Peut être réservé aux abonnés Medium |
| 8 | Incremental Models in dbt | Transformation et orchestration | dbt (documentation) | https://docs.getdbt.com/docs/build/incremental-models-overview | Documentation officielle |
| 9 | Spark Transformations vs Actions | Spark | Analytics Vidhya | https://www.analyticsvidhya.com/blog/2016/10/using-pyspark-to-perform-transformations-and-actions-on-rdd/ | ⚠️ **Article de 2016** basé sur les RDD ; aujourd'hui, Spark s'utilise avec les DataFrames (voir la ressource 22). Le principe (transformations paresseuses, actions qui déclenchent le calcul) reste valable. |
| 10 | Partitioning in Spark | Spark | Medium | https://medium.com/@dipayandev/everything-you-need-to-understand-data-partitioning-in-spark-487d4be63b9c | Peut être réservé aux abonnés Medium |
| 11 | Window Functions in SQL | SQL et modélisation | DataCamp (aide-mémoire) | https://www.datacamp.com/cheat-sheet/sql-window-functions-cheat-sheet | |
| 12 | Slowly Changing Dimensions (SCD) | SQL et modélisation | SQLShack | https://www.sqlshack.com/implementing-slowly-changing-dimensions-scds-in-data-warehouses/ | |
| 13 | Data Modeling (Star vs Snowflake) | SQL et modélisation | Keboola (blog) | https://www.keboola.com/blog/star-schema-vs-snowflake-schema | |
| 14 | Data Quality with Great Expectations | Qualité et gouvernance | Medium (publication Snowflake) | https://medium.com/snowflake/how-to-ensure-data-quality-with-great-expectations-271e3ca8b4b9 | Peut être réservé aux abonnés Medium |
| 15 | Data Lineage & Cataloging | Qualité et gouvernance | CastorDoc (blog) | https://www.castordoc.com/blog/data-lineage-vs-data-catalog | |
| 16 | Apache Kafka 101 | Streaming | Red Hat Developer | https://developers.redhat.com/learn/apache-kafka/kafka-101 | |
| 17 | Batch vs Stream Processing | Streaming | DataCamp (blog) | https://www.datacamp.com/blog/batch-vs-stream-processing | |
| 18 | PySpark Optimization Tips | Spark | Apache Spark (documentation) | https://spark.apache.org/docs/latest/sql-performance-tuning.html | Documentation officielle |
| 19 | Auto Loader in Databricks | Architecture et stockage | Chaos Genius (blog) | https://www.chaosgenius.io/blog/databricks-autoloader/ | |
| 20 | Delta Live Tables | Architecture et stockage | Chaos Genius (blog) | https://www.chaosgenius.io/blog/databricks-delta-live-table/ | |
| 21 | GenAI in Data Engineering | IA | Medium | https://medium.com/@thisis-Shitanshu/generative-ai-driven-data-engineering-c406f719e7e4 | Peut être réservé aux abonnés Medium |
| 22 | Spark SQL, DataFrames and Datasets | Spark | Apache Spark (documentation) | https://spark.apache.org/docs/latest/sql-programming-guide.html | Documentation officielle ; la façon actuelle d'utiliser Spark |
| 23 | Functional Data Engineering | Transformation et orchestration | Medium (Maxime Beauchemin, créateur d'Airflow) | https://maximebeauchemin.medium.com/functional-data-engineering-a-modern-paradigm-for-batch-data-processing-2327ec32c42a | Article de référence sur l'idempotence et les partitions immuables |
| 24 | Airflow Best Practices | Transformation et orchestration | Apache Airflow (documentation) | https://airflow.apache.org/docs/apache-airflow/stable/best-practices.html | Documentation officielle |
| 25 | How We Structure Our dbt Projects | Transformation et orchestration | dbt (documentation) | https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview | Guide officiel en plusieurs pages |
| 26 | Dimensional Modeling Techniques | SQL et modélisation | Kimball Group | https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/ | La référence historique de la modélisation dimensionnelle |
| 27 | Use The Index, Luke | SQL et modélisation | use-the-index-luke.com | https://use-the-index-luke.com/ | Guide complet et gratuit sur les index SQL |
| 28 | Using EXPLAIN | SQL et modélisation | PostgreSQL (documentation) | https://www.postgresql.org/docs/current/using-explain.html | Lire un plan d'exécution ; utile pour la base de ce projet |
| 29 | Parquet File Format | Architecture et stockage | Apache Parquet (documentation) | https://parquet.apache.org/docs/file-format/ | Le format de fichier en colonnes utilisé par les lakehouses |
| 30 | Diving Into Delta Lake: the Transaction Log | Architecture et stockage | Databricks (blog, 2019) | https://www.databricks.com/blog/2019/08/21/diving-into-delta-lake-unpacking-the-transaction-log.html | Ancien mais toujours exact : comment Delta Lake garantit les transactions |
| 31 | Apache Iceberg Table Spec | Architecture et stockage | Apache Iceberg (documentation) | https://iceberg.apache.org/spec/ | Avancé : la spécification du format |
| 32 | Lakehouse (article de recherche, CIDR 2021) | Architecture et stockage | CIDR (PDF) | https://www.cidrdb.org/cidr2021/papers/cidr2021_paper17.pdf | L'article fondateur du concept de lakehouse ; en anglais, assez long |
| 33 | Introduction to Apache Kafka | Streaming | Apache Kafka (documentation) | https://kafka.apache.org/intro | Documentation officielle |
| 34 | Exactly-Once Semantics in Kafka | Streaming | Confluent (blog) | https://www.confluent.io/blog/exactly-once-semantics-are-possible-heres-how-apache-kafka-does-it/ | Comment Kafka garantit qu'un message est traité une seule fois |
| 35 | Debezium Tutorial (Change Data Capture) | Streaming | Debezium (documentation) | https://debezium.io/documentation/reference/stable/tutorial.html | Tutoriel pratique, à faire avec Docker |
| 36 | Data Mesh Principles | Qualité et gouvernance | martinfowler.com (Zhamak Dehghani) | https://martinfowler.com/articles/data-mesh-principles.html | L'article qui a défini le data mesh |
| 37 | Data Engineering Project for Beginners | Projet pratique | Start Data Engineering | https://www.startdataengineering.com/post/data-engineering-project-for-beginners-batch-edition/ | Un projet complet à reproduire |
| 38 | Data Structure in n8n | Outils du projet | n8n (documentation) | https://docs.n8n.io/data/data-structure/ | Comment n8n représente les items ; utile pour ce projet |
| 39 | LLM Powered Autonomous Agents | IA | Lilian Weng (blog) | https://lilianweng.github.io/posts/2023-06-23-agent/ | Article de référence sur les agents à base de LLM |
| 40 | Building a Generative AI Platform | IA | Chip Huyen (blog) | https://huyenchip.com/2024/07/25/genai-platform.html | Architecture complète d'une application d'IA générative |

## Pourquoi ces liens ne sont pas des sources de veille

- Ce sont des articles **intemporels** : ils ne changent pas et n'ont rien de « nouveau » à signaler chaque jour.
- Ils ne proposent **aucun flux** à surveiller.
- Les blogs de la plupart de ces sites publient surtout du contenu marketing.
- LinkedIn n'a pas de flux RSS et interdit la collecte automatique : la publication d'origine ne peut pas devenir une source.

Les blogs qui méritent d'être suivis au quotidien sont listés dans [sources.md](sources.md), section « Sources complémentaires ».

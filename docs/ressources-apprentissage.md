# Ressources d'apprentissage — « Le fondamental du jour »

> Rubrique prévue en **v1.1** : chaque matin, le digest ajoute **une** ressource non encore envoyée.
> Source de la liste : une publication LinkedIn « Data Engineering : des fondamentaux aux systèmes prêts pour la production ».
> Liste incomplète (21 liens récupérés) : la suite sera ajoutée quand le texte complet de la publication aura été retrouvé.
> Liens vérifiés le 11 novembre 2026 (les liens raccourcis `lnkd.in` ont été remplacés par leur adresse réelle).

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
| 9 | Spark Transformations vs Actions | Spark | Analytics Vidhya | https://www.analyticsvidhya.com/blog/2016/10/using-pyspark-to-perform-transformations-and-actions-on-rdd/ | ⚠️ **Article de 2016** basé sur les RDD ; aujourd'hui, Spark s'utilise avec les DataFrames. Le principe (transformations paresseuses, actions qui déclenchent le calcul) reste valable. |
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

## Pourquoi ces liens ne sont pas des sources de veille

- Ce sont des articles **intemporels** : ils ne changent pas et n'ont rien de « nouveau » à signaler chaque jour.
- Ils ne proposent **aucun flux** à surveiller.
- Les blogs de la plupart de ces sites publient surtout du contenu marketing.
- LinkedIn n'a pas de flux RSS et interdit la collecte automatique : la publication d'origine ne peut pas devenir une source.

Exception à étudier : le blog de **dbt Labs** (`getdbt.com/blog`), officiel et de bonne qualité. Il pourra servir de test au critère « ajouter une source en moins de 5 minutes » une fois la table `sources` créée.

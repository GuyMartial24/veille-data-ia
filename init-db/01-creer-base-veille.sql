-- Exécuté une seule fois, au tout premier démarrage de PostgreSQL.
-- Crée la base « veille », séparée de la base interne de n8n.
-- Les tables (sources, annonces…) seront créées à l'étape 5.
CREATE DATABASE veille;

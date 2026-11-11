-- Schéma de la base « veille ».
-- Exécuté automatiquement au premier démarrage de PostgreSQL (base vide),
-- ou à la main :
--   docker compose exec -T postgres psql -U veille -d veille -f /docker-entrypoint-initdb.d/02-schema-veille.sql
-- Le script est idempotent : on peut le relancer sans erreur ni perte de données.

\connect veille

-- ---------------------------------------------------------------- sources
-- Une ligne par source de veille. Ajouter une source = ajouter une ligne.
CREATE TABLE IF NOT EXISTS sources (
    id            serial PRIMARY KEY,
    nom           text        NOT NULL,
    type          text        NOT NULL CHECK (type IN ('flux', 'github_latest')),
    url           text        NOT NULL UNIQUE,
    categorie     text        NOT NULL,
    filtre_titre  text,                               -- regex JavaScript ; vide = tout garder
    actif         boolean     NOT NULL DEFAULT true,  -- false = source en pause
    date_ajout    date        NOT NULL DEFAULT current_date
);

-- ---------------------------------------------------------------- annonces
-- Une ligne par annonce collectée. La contrainte UNIQUE sur « cle » assure le
-- dédoublonnage : INSERT ... ON CONFLICT DO NOTHING ignore une annonce déjà vue.
CREATE TABLE IF NOT EXISTS annonces (
    id                bigserial   PRIMARY KEY,
    cle               text        NOT NULL UNIQUE,      -- id Atom, guid RSS ou html_url GitHub
    source_id         integer     NOT NULL REFERENCES sources (id),
    titre             text        NOT NULL,
    lien              text        NOT NULL,
    date_publication  timestamptz,
    contenu           text,                             -- texte brut, sans HTML (pour l'IA)
    resume            text,                             -- rempli à l'étape 6
    notion_a_retenir  text,                             -- rempli à l'étape 6
    collectee_le      timestamptz NOT NULL DEFAULT now(),
    envoyee_le        timestamptz                       -- vide = pas encore envoyée
);

-- Une même annonce peut arriver par deux sources : on dédoublonne aussi sur le lien.
CREATE UNIQUE INDEX IF NOT EXISTS annonces_lien_unique ON annonces (lien);
-- Le digest cherche les annonces pas encore envoyées.
CREATE INDEX IF NOT EXISTS annonces_a_envoyer ON annonces (collectee_le) WHERE envoyee_le IS NULL;

-- ---------------------------------------------------------------- modules et notions
CREATE TABLE IF NOT EXISTS modules (
    nom    text    PRIMARY KEY,
    rang   integer NOT NULL UNIQUE,   -- ordre de rotation entre les modules
    emoji  text    NOT NULL
);

CREATE TABLE IF NOT EXISTS notions (
    id              serial  PRIMARY KEY,
    module          text    NOT NULL REFERENCES modules (nom),
    numero          integer NOT NULL,   -- ordre de progression dans le module
    titre           text    NOT NULL,
    definition      text    NOT NULL,
    fonctionnement  text    NOT NULL,
    analogie        text    NOT NULL,
    a_retenir       text    NOT NULL,
    lien            text    NOT NULL,
    UNIQUE (module, numero)
);

-- Ordre d'envoi : toutes les leçons n°1 (dans l'ordre des modules), puis toutes les n°2, etc.
CREATE OR REPLACE VIEW notions_ordonnees AS
SELECT n.*,
       m.emoji,
       row_number() OVER (ORDER BY n.numero, m.rang) AS ordre,
       count(*) OVER () AS total,
       count(*) OVER (PARTITION BY n.module) AS total_module
FROM notions n
JOIN modules m ON m.nom = n.module;

-- Historique des envois de « La notion du jour ».
CREATE TABLE IF NOT EXISTS envois_notions (
    id         serial      PRIMARY KEY,
    notion_id  integer     NOT NULL REFERENCES notions (id),
    envoyee_le timestamptz NOT NULL DEFAULT now()
);

-- La prochaine notion à envoyer : le parcours reboucle quand toutes ont été envoyées.
CREATE OR REPLACE VIEW prochaine_notion AS
SELECT o.*
FROM notions_ordonnees o
WHERE o.ordre = (SELECT count(*) FROM envois_notions) % (SELECT count(*) FROM notions) + 1;

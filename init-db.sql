-- Initialiser separate databaser til hver service
CREATE DATABASE n8n;
CREATE DATABASE nocodb;
CREATE DATABASE nextcloud;
CREATE DATABASE docmost;
CREATE DATABASE strapi;

-- Grant rettigheder
GRANT ALL PRIVILEGES ON DATABASE n8n TO postgres;
GRANT ALL PRIVILEGES ON DATABASE nocodb TO postgres;
GRANT ALL PRIVILEGES ON DATABASE nextcloud TO postgres;
GRANT ALL PRIVILEGES ON DATABASE docmost TO postgres;
GRANT ALL PRIVILEGES ON DATABASE strapi TO postgres;

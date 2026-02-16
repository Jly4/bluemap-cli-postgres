## Docker Container: `jly4/bluemap-cli-postgres`

**Description:**
A fully automated, production-ready Docker stack for running BlueMap CLI with PostgreSQL storage. This setup is designed for a "plug-and-play" experience: databases are provisioned automatically, drivers are self-extracted, and default configurations are generated on the fly. No manual SQL setup or external driver downloading is required.

**Services:**

1. **bluemap** (`bluemap-app`)
* The core BlueMap CLI application.
* **Automation:** On startup, it checks if the `./config` folder is empty. If so, it automatically extracts the necessary PostgreSQL driver and default configuration files to your host.
* **Dependency:** Systematically waits for the database to be "Healthy" before initializing.


2. **postgres** (`bluemap-postgres`)
* A custom PostgreSQL image optimized for BlueMap.
* **Auto-Provisioning:** Dynamically creates all databases listed in your config **every time the container starts** (if they don't already exist).
* **Unified Access:** Uses a single set of credentials for all managed databases by default.

**Links & Community:**
* **Container:** [Docker Hub](https://hub.docker.com/repository/docker/jly4/bluemap-cli-postgres)
* **Official BlueMap:** [bluemap.io](https://bluemap.io/)
* **Issue Tracker:** [GitHub Issues](https://github.com/Jly4/bluemap-cli-postgres/issues)



---

## Usage Instructions

### 1. Create Docker Compose File

Simply copy the following code into your `docker-compose.yml`. You only need to define your database names and launch arguments.

```yaml
services:
  postgres:
    container_name: bluemap-postgres
    image: jly4/bluemap-postgres:latest
    environment:
      POSTGRES_USER: bluemap
      POSTGRES_PASSWORD: bluemap
      POSTGRES_DB: bluemap_db  # Primary database
      # List additional databases separated by commas 
      POSTGRES_MULTIPLE_DATABASES: # world1_db,world2_db
    ports:
      # Uncomment the line below to access the DB from your host/external tools
      # - "5432:5432"
    volumes:
      - ./pgsql_data:/var/lib/postgresql
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U bluemap -d bluemap_db"]
      interval: 5s
      timeout: 5s
      retries: 5

  bluemap:
    container_name: bluemap-app
    image: jly4/bluemap-cli-postgres:latest
    command: ["-g", "-w"]
    ports:
      - "8100:8100"
    volumes:
      - ./config:/app/config
      - ./data:/app/data
      - ./world:/app/world
      - ./mods:/app/mods
    restart: unless-stopped
    depends_on:
      postgres:
        condition: service_healthy

```

### 2. Start and Access

* **Start:** `docker compose up -d`
* **Logs:** `docker compose logs -f`
* **Web Map:** Open `http://<host-ip>:8100`

### 3. Updating or Rendering

You can customize the BlueMap behavior directly in the `docker-compose.yml` file.

**Example command-line customizations:**

```yaml
command: ["-g", "-w", "-r", "--mc-version", "1.20.1", "--mods", "mods"]

```

**Manual Trigger:**
To run a specific command manually without restarting the container:

```bash
docker compose exec bluemap-app java -jar /app/app.jar -g -w -r

```

---

## Features & Automation Logic

### Database Management

* **Dynamic Creation:** Add any database name to `POSTGRES_MULTIPLE_DATABASES`. The container scans for these **at every startup**. If a database is missing, it is created instantly with full privileges granted to the `bluemap` user.
* **Credentials:** By default, all databases share:
* **User:** `bluemap`
* **Password:** `bluemap`



### BlueMap Configuration

* **Auto-Extraction:** If your `./config` directory is empty or missing, the container populates it with default configs and the required SQL driver `.jar` file.
* **Connection Setup:** Edit `./config/sql.conf` to point to your desired database (e.g., `jdbc:postgresql://postgres:5432/bluemap_db`).

---

## Backup & Restore

### 1. Backup

* **Full Backup (All Databases):**
```bash
docker exec bluemap-postgres pg_dumpall -U bluemap > full_backup.sql

```


* **Specific Database Backup:**
```bash
docker exec bluemap-postgres pg_dump -U bluemap name_of_db > world_backup.sql

```



### 2. Restore

* **Restore Full Backup:**
```bash
cat full_backup.sql | docker exec -i bluemap-postgres psql -U bluemap

```


* **Restore Specific Database:**
*(Ensure the database name exists in your YAML so it is auto-created first)*
```bash
cat world_backup.sql | docker exec -i bluemap-postgres psql -U bluemap -d name_of_db

```



---

## Maintenance & Security

### Port Management

* **Web Access:** Ensure port `8100` is open in your firewall.
* **Database Security:** Port `5432` is internal by default. Only expose it if you need external management tools (like DBeaver or pgAdmin).

---

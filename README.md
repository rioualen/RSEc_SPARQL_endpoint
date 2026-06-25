# SPARQL Endpoint — Apache Jena Fuseki

A SPARQL 1.1 endpoint for querying RDF files using **Apache Jena Fuseki** (`stain/jena-fuseki`), served via **Docker**.

## Quickstart

### 1 — Add your RDF files

Drop your files in `data/`. Supported formats: `.ttl`, `.rdf`, `.nt`, `.owl`, `.nquads`

### 2 — Start Fuseki

```bash
docker compose up -d
```

Wait ~10 seconds for Fuseki to finish initialising (watch logs with `docker compose logs -f`).

### 3 — Load your RDF files

Run the loader once. Files in `./data/` are mounted at `/staging` inside the container:

```bash
./load.sh
```

This calls the image's built-in `tdbloader2` to bulk-load all files into the TDB2 `ds` dataset.

### 4 — Query

Open the web UI:
```
ui/index.html    ← open directly in your browser
```

Or use Fuseki's built-in UI:
```
http://localhost:3030    (login: admin / admin)
```

---

## Re-loading after adding files

```bash
# Add new files to data/, then re-run the loader
./load.sh

# If you want a clean reload from scratch:
docker compose down -v
docker compose up -d
./load.sh
```

---

## Project Structure

```
.
├── data/             ← Put your RDF files here
│   └── example.ttl
├── ui/
│   └── index.html    ← Standalone web UI (open in browser)
├── load.sh           ← Helper: loads ./data/ into Fuseki TDB2
├── docker-compose.yml
└── README.md
```

---

## SPARQL Endpoints

| Endpoint    | URL                                    |
|-------------|----------------------------------------|
| Query       | `http://localhost:3030/ds/sparql`      |
| Update      | `http://localhost:3030/ds/update`      |
| Graph Store | `http://localhost:3030/ds/data`        |
| Fuseki UI   | `http://localhost:3030`                |
| Ping        | `http://localhost:3030/$/ping`         |

### Example curl

```bash
curl -X POST http://localhost:3030/ds/sparql \
  --data-urlencode "query=SELECT ?s ?p ?o WHERE { ?s ?p ?o } LIMIT 5" \
  -H "Accept: application/sparql-results+json"
```

---

## Configuration

| Variable           | Default  | Description                            |
|--------------------|----------|----------------------------------------|
| `ADMIN_PASSWORD`   | `admin`  | Fuseki admin UI password               |
| `FUSEKI_DATASET_1` | `ds`     | Dataset name                           |
| `TDB`              | `2`      | TDB version (2 = TDB2, recommended)    |
| `JVM_ARGS`         | `-Xmx4g` | JVM heap — increase for large datasets |

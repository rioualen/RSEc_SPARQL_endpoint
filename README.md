# SPARQL Endpoint — Apache Jena Fuseki

A SPARQL endpoint for querying RDF files using **Apache Jena Fuseki**, served via **Docker**. Includes a standalone web UI.

## Features

- Loads all RDF files from `./data/` into a persistent **TDB2** database at startup
- Full SPARQL 1.1 support (SELECT, ASK, CONSTRUCT, DESCRIBE, UPDATE)
- Persistent TDB2 store — fast restarts, no re-parsing on every boot
- Standalone HTML web UI (no server needed — open directly in browser)
- CSV export, URI linking, language tag display
- `Ctrl+Enter` to run queries

---

## Quickstart

### 1 — Add your RDF files

```
data/
  my_tools.ttl
  ontology.rdf
  ...
```

Supported formats: `.ttl`, `.turtle`, `.rdf`, `.xml`, `.n3`, `.nt`, `.jsonld`, `.trig`

### 2 — Start Fuseki

```bash
docker compose up --build
```

Fuseki will load all RDF files into TDB2 on first run, then start.

### 3 — Open the web UI

Open `ui/index.html` directly in your browser — no server needed. It talks to Fuseki at `http://localhost:3030/ds/sparql`.

You can also use Fuseki's built-in UI at:
```
http://localhost:3030
```

---

## Project Structure

```
.
├── config/
│   └── config.ttl        # Fuseki dataset configuration
├── data/                 # ← Put your RDF files here
│   └── example.ttl
├── ui/
│   └── index.html        # Standalone web form UI
├── entrypoint.sh         # Loads RDF → TDB2, then starts Fuseki
├── Dockerfile
├── docker-compose.yml
└── README.md
```

---

## Re-importing RDF files

The TDB2 database is persisted in a Docker volume (`fuseki-db`). Files are only loaded once. To re-import after adding or changing files:

```bash
# Option A: set RELOAD=1 for one restart
RELOAD=1 docker compose up

# Option B: wipe the volume and rebuild
docker compose down -v
docker compose up --build
```

---

## SPARQL Endpoints

| Endpoint | URL |
|----------|-----|
| Query (GET/POST) | `http://localhost:3030/ds/sparql` |
| Update | `http://localhost:3030/ds/update` |
| Graph Store | `http://localhost:3030/ds/data` |
| Fuseki UI | `http://localhost:3030` |
| Ping | `http://localhost:3030/$/ping` |

### Example curl

```bash
curl -X POST http://localhost:3030/ds/sparql \
  --data-urlencode "query=SELECT ?s ?p ?o WHERE { ?s ?p ?o } LIMIT 5" \
  -H "Accept: application/sparql-results+json"
```

---

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `DATA_DIR` | `/rdf-data` | Path to RDF files inside container |
| `JVM_ARGS` | `-Xmx2g` | JVM heap — increase for large datasets |
| `RELOAD` | `0` | Set to `1` to force re-import on next startup |

For very large datasets, increase `JVM_ARGS` in `docker-compose.yml`:
```yaml
environment:
  JVM_ARGS: "-Xmx8g"
```

---

## Comparison with the Flask/RDFLib version

| | Flask + RDFLib | Jena Fuseki |
|---|---|---|
| Language | Python | Java |
| Storage | In-memory | TDB2 (persistent, indexed) |
| Query speed | Slower on large graphs | Much faster |
| SPARQL support | 1.1 SELECT/ASK/CONSTRUCT | Full 1.1 + UPDATE |
| Restart time | Re-parses all files | Instant (TDB2 persisted) |
| Best for | Small datasets, quick setup | Large datasets, production |

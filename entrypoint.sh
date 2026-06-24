#!/bin/bash
set -e

DATA_DIR="${DATA_DIR:-/rdf-data}"
DB_DIR="/fuseki/databases/ds"
MARKER="$DB_DIR/.loaded"

echo "=== Fuseki Endpoint Startup ==="

# Create DB directory if needed
mkdir -p "$DB_DIR"

# Load RDF files if not already loaded (or if RELOAD=1)
if [ ! -f "$MARKER" ] || [ "${RELOAD:-0}" = "1" ]; then
    echo "Scanning for RDF files in $DATA_DIR ..."

    FILES=$(find "$DATA_DIR" -type f \( \
        -name "*.ttl"    -o -name "*.turtle" \
        -o -name "*.rdf" -o -name "*.xml"    \
        -o -name "*.n3"  -o -name "*.nt"     \
        -o -name "*.jsonld" -o -name "*.trig" \
    \) 2>/dev/null)

    if [ -z "$FILES" ]; then
        echo "WARNING: No RDF files found in $DATA_DIR"
    else
        echo "Loading files into TDB2 at $DB_DIR ..."
        # tdb2.tdbloader can take multiple files in one pass
        /jena/bin/tdb2.tdbloader \
            --loc "$DB_DIR" \
            $FILES
        echo "Done loading."
        touch "$MARKER"
    fi
else
    echo "TDB2 database already exists, skipping load (set RELOAD=1 to force)."
fi

echo "Starting Apache Jena Fuseki on port 3030 ..."
exec /jena-fuseki/fuseki-server \
    --config=/fuseki/config/config.ttl \
    --port=3030

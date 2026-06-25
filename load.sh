#!/bin/bash
# Bulk-load all RDF files from ./data/ into the Fuseki TDB2 dataset.

set -e

DATASET="${1:-ds}"
DB_LOC="/fuseki/databases/$DATASET"

echo "=== Stopping Fuseki ==="
docker compose stop fuseki

echo ""
echo "=== Collecting RDF files ==="
FILES=""
for f in data/*.ttl data/*.rdf data/*.nt data/*.n3 data/*.owl data/*.trig data/*.jsonld; do
  [ -f "$f" ] && FILES="$FILES /staging/$(basename "$f")"
done

if [ -z "$FILES" ]; then
  echo "ERROR: No RDF files found in ./data/"
  docker compose start fuseki
  exit 1
fi

echo "Files:$FILES" | tr ' ' '\n' | grep /
echo ""

# Get container ID including stopped containers
CONTAINER_ID=$(docker compose ps -a -q fuseki)
echo "Container ID: $CONTAINER_ID"

echo "=== Loading into TDB2 ==="
docker run --rm \
  --volumes-from "$CONTAINER_ID" \
  --platform linux/amd64 \
  --entrypoint /jena-fuseki/tdbloader2 \
  stain/jena-fuseki:latest \
  --loc="$DB_LOC" \
  $FILES

echo ""
echo "=== Done! Starting Fuseki ==="
docker compose start fuseki
echo ""
echo "    Query at: http://localhost:3030/$DATASET/sparql"
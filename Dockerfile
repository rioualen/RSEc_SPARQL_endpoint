# ── Stage: download & verify Jena + Fuseki ────────────────────────────────
FROM eclipse-temurin:21-jre-jammy

ARG JENA_VERSION=5.2.0

# Install wget and bash
RUN apt-get update && apt-get install -y --no-install-recommends \
        wget \
        bash \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# Download Apache Jena (includes tdb2.tdbloader CLI)
RUN wget -q "https://archive.apache.org/dist/jena/binaries/apache-jena-${JENA_VERSION}.tar.gz" \
    && tar -xzf "apache-jena-${JENA_VERSION}.tar.gz" \
    && mv "apache-jena-${JENA_VERSION}" /jena \
    && rm "apache-jena-${JENA_VERSION}.tar.gz"

# Download Apache Jena Fuseki
RUN wget -q "https://archive.apache.org/dist/jena/binaries/apache-jena-fuseki-${JENA_VERSION}.tar.gz" \
    && tar -xzf "apache-jena-fuseki-${JENA_VERSION}.tar.gz" \
    && mv "apache-jena-fuseki-${JENA_VERSION}" /jena-fuseki \
    && rm "apache-jena-fuseki-${JENA_VERSION}.tar.gz"

# ── Runtime setup ──────────────────────────────────────────────────────────

# Fuseki home (config, databases, logs)
ENV FUSEKI_HOME=/fuseki \
    FUSEKI_BASE=/fuseki \
    JVM_ARGS="-Xmx2g"

RUN mkdir -p /fuseki/databases /fuseki/config /fuseki/logs

# Copy config and entrypoint
COPY config/config.ttl /fuseki/config/config.ttl
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# RDF data volume
VOLUME ["/rdf-data"]

EXPOSE 3030

ENTRYPOINT ["/entrypoint.sh"]

FROM postgres
RUN mkdir -p /tmp/test-data
COPY *.sql /docker-entrypoint-initdb.d/
COPY *.csv /tmp/test-data/

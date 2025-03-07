help:
	@echo "Help information"

run: postgres redis
	@echo "Running PenPot..."

postgres: containers/postgres.sif

redis: containers/redis.sif

containers/postgres.sif:
	mkdir postgres_data
	mkdir postgres_run
	singularity build -f containers/postgres.sif definitions/postgres.def

containers/redis.sif:
	singularity build -f containers/redis.sif definitions/redis.def

clean:
	@# Postgres
	rm -rf containers/postgres.sif
	rm -rf postgres_data
	rm -rf postgres_run
	@# Redis
	rm -rf containers/redis.sif

.PHONY: help clean
help:
	@echo "Help information"

run: postgres redis mailcatch exporter backend
	@echo "Running PenPot..."

postgres: containers/postgres.sif

redis: containers/redis.sif

mailcatch: containers/mailcatch.sif

exporter: containers/exporter.sif

backend: containers/backend.sif

containers/backend.sif:
	mkdir penpot_assets
	singularity build -f containers/backend.sif definitions/backend.def

containers/exporter.sif:
	singularity build -f containers/exporter.sif definitions/exporter.def

containers/postgres.sif:
	mkdir postgres_data
	mkdir postgres_run
	singularity build -f containers/postgres.sif definitions/postgres.def

containers/redis.sif:
	singularity build -f containers/redis.sif definitions/redis.def

containers/mailcatch.sif:
	singularity build -f containers/mailcatch.sif definitions/mailcatch.def

clean:
	@# Postgres
	rm -rf containers/postgres.sif
	rm -rf postgres_data
	rm -rf postgres_run
	@# Redis
	rm -rf containers/redis.sif
	rm -rf dump.rdb
	@# Mail Catch
	rm -rf containers/mailcatch.sif
	@# Exporter
	rm -rf containers/exproter.sif
	@# Backend
	rm -rf penpot_assets
	rm -rf containers/backend.sif

.PHONY: help clean
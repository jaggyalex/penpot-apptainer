help:
	@echo "Help information"

run: postgres redis mailcatch exporter
	@echo "Running PenPot..."

postgres: containers/postgres.sif

redis: containers/redis.sif

mailcatch: containers/mailcatch.sif

exporter: containers/exporter.sif

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
	@# Mail Catch
	rm -rf containers/mailcatch.sif
	@# Exporter
	rm -rf containers/exproter.sif

.PHONY: help clean
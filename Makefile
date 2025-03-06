help:
	@echo "Help information"

postgres: containers/postgres.sif

containers/postgres.sif:
	mkdir postgres_data
	mkdir postgres_run
	singularity build -f containers/postgres.sif definitions/postgres.def

clean:
	@# Postgres
	rm -rf containers/postgres.sif
	rm -rf postgres_data
	rm -rf postgres_run

.PHONY: help clean
help:
	@echo "Help information"

run: mailcatch redis postgres exporter backend frontend
	@echo "Running PenPot..."

##########
# Checks #
##########
list:
	singularity instance list

stop:
	singularity instance stop -a

net-check:
	@echo "Mailcatch:"
	netstat -tnlp | grep :1080
	netstat -tnlp | grep :1025
	@echo "Redis:"
	netstat -tnlp | grep :6379
	@echo "Postgres:"
	netstat -tnlp | grep :5433
	@echo "Exporter:"
	netstat -tnlp | grep :6061
	@echo "Backend:"
	netstat -tnlp | grep :6060
	netstat -tnlp | grep :6063
	
############
# Services #
############
mailcatch: containers/mailcatch.sif
	@echo "Running service $@..."
	@singularity -s instance start \
	containers/mailcatch.sif mailcatch
	@echo "\t...service ready!"

redis: containers/redis.sif
	@echo "Running service $@..."
	@singularity -s instance start \
	containers/redis.sif redis
	@echo "\t...service ready!"
	@echo "Waiting for database to be built..."
	@until singularity -s exec containers/redis.sif \
	redis-cli ping | grep -q PONG; do \
		sleep 2; \
	done
	@echo "\t...database ready!"

postgres: containers/postgres.sif
	@echo "Running service $@..."
	@singularity -s instance start \
	-B postgres_data:/var/lib/postgresql/data \
	-B postgres_run:/var/run/postgresql \
	containers/postgres.sif postgres
	@echo "\t...service ready!"
	@echo "Waiting for database to be built..."
	@until singularity -s exec containers/postgres.sif \
	pg_isready -U penpot -q; do \
		sleep 2; \
	done
	@echo "\t...database ready!"

exporter: containers/exporter.sif
	@echo "Running service $@..."
	@singularity -s instance start \
	containers/exporter.sif exporter
	@echo "\t...service ready!"

backend: containers/backend.sif
	@echo "Running service $@..."
	@singularity -s instance start \
	-B penpot_assets:/opt/data/assets \
	containers/backend.sif backend
	@echo "\t...service ready!"
	@echo "Waiting for webserver to run..."
	@until netstat -tnlp | grep -q :6061; do \
		sleep 2; \
	done
	@echo "\t...webserver ready!"

frontend: containers/frontend.sif
	@echo "Running service $@..."
	@singularity -s instance start \
	-B penpot_assets:/opt/data/assets \
	containers/frontend.sif frontend
	@echo "\t...service ready!"

######################
# Container Building #
######################
containers/frontend.sif:
	mkdir -p penpot_assets
	singularity build -f containers/frontend.sif definitions/frontend.def

containers/backend.sif:
	mkdir -p penpot_assets
	singularity build -f containers/backend.sif definitions/backend.def

containers/exporter.sif:
	singularity build -f containers/exporter.sif definitions/exporter.def

containers/postgres.sif:
	mkdir -p postgres_data
	mkdir -p postgres_run
	singularity build -f containers/postgres.sif definitions/postgres.def

containers/redis.sif:
	singularity build -f containers/redis.sif definitions/redis.def

containers/mailcatch.sif:
	singularity build -f containers/mailcatch.sif definitions/mailcatch.def

#########
# Clean #
#########
clean:
	@# Postgres
	-singularity instance stop postgres
	rm -rf containers/postgres.sif
	rm -rf postgres_data
	rm -rf postgres_run
	@# Redis
	-singularity instance stop redis
	rm -rf containers/redis.sif
	rm -rf dump.rdb
	@# Mail Catch
	-singularity instance stop mailcatch
	rm -rf containers/mailcatch.sif
	@# Exporter
	-singularity instance stop exporter
	rm -rf containers/exporter.sif
	@# Backend
	-singularity instance stop backend
	rm -rf penpot_assets
	rm -rf containers/backend.sif
	@# Frontend
	-singularity instance stop frontend
	rm -rf penpot_assets
	rm -rf containers/frontend.sif

.PHONY: help clean
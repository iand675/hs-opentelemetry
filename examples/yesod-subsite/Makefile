.PHONY: server.run
server.run:
	docker compose --file ../../docker-compose.yaml up $(DOCKER_COMPOSE_OPTS)

.PHONY: server.stop
server.stop:
	docker compose --file ../../docker-compose.yaml down $(DOCKER_COMPOSE_OPTS)

.PHONY: app.run
app.run: bin/yesod-subsite
	OTEL_SERVICE_NAME=yesod-subsite bin/yesod-subsite $(YESOD_MINIMAL_OPTS)

bin/yesod-subsite:
	stack install --local-bin-path ./bin $(CABAL_OPTS) yesod-subsite:exe:yesod-subsite

.PHONY: clean
clean:
	stack clean
	$(RM) bin/yesod-subsite

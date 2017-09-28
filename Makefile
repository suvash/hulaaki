.DEFAULT_GOAL:=test
.PHONY: run bash test tail-mqtt tail-mqtt-tls stop prune

RUN_SERVICE:=hulaaki
MQTT_SERVICE:=mqtt_server

run:
	$(if $(CMD), docker-compose run --rm $(RUN_SERVICE) $(CMD), $(error -- CMD must be set))

bash: CMD=/bin/bash
bash: run

test: CMD=mix test
test: run

start:
	docker-compose up -d $(MQTT_SERVICE)

tail-logs:
	docker-compose logs -f $(MQTT_SERVICE)

stop:
	docker-compose down
	docker system prune -f

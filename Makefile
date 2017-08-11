.DEFAULT_GOAL:=test
.PHONY: run bash test tail-mqtt tail-mqtt-tls stop prune

RUN_SERVICE:=hulaaki
MQTT_SERVICE:=mqtt_server
MQTT_TLS_SERVICE:=mqtt_server_tls

run:
	$(if $(CMD), docker-compose run $(RUN_SERVICE) $(CMD), $(error -- CMD must be set))

bash: CMD=/bin/bash
bash: run

test: CMD=mix test
test: run

start-servers:
	docker-compose up -d $(MQTT_SERVICE) $(MQTT_TLS_SERVICE)

stop:
	docker-compose down
	docker system prune -f

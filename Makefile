.DEFAULT_GOAL:=test

PROJECT_NAME:=hulaaki
DEV_PROJECT_IMAGE_NAME:=$(PROJECT_NAME)/dev

MQTT_SERVER_IMAGE_NAME:=ansi/mosquitto
MQTT_SERVER_NAME:=mosquitto

CONTAINER_WORKDIR:=$(shell grep WORKDIR Dockerfile | cut -d' ' -f2)
HOST_DIR:=$(CURDIR)

MQTT_PORT:=1883
MQTT_HOST:=hulaaki_mqtt

DOCKER_ENV:=\
	-e MQTT_HOST=$(MQTT_HOST) \
	-e MQTT_PORT=$(MQTT_PORT)

DOCKER_LINK:=\
	--link $(MQTT_SERVER_NAME):$(MQTT_HOST) \

DOCKER_VOLUME:=\
	-v $(HOST_DIR):$(CONTAINER_WORKDIR)

DOCKER_INTERACTIVE_RUN:=\
	docker run --rm -it \
	$(DOCKER_ENV) \
	$(DOCKER_LINK) \
	$(DOCKER_VOLUME) \
	$(DEV_PROJECT_IMAGE_NAME)

.PHONY: mqtt-server dev clean run bash test

mqtt-server-start:
	docker run -d -p $(MQTT_PORT):$(MQTT_PORT) --name $(MQTT_SERVER_NAME) $(MQTT_SERVER_IMAGE_NAME)

mqtt-server-stop:
	docker stop $(MQTT_SERVER_NAME)
	docker rm $(MQTT_SERVER_NAME)

dev: Dockerfile
	$(info **** Building docker dev environment image $(DEV_PROJECT_IMAGE_NAME))
	docker build -t $(DEV_PROJECT_IMAGE_NAME) .

clean:
	$(info **** Cleaning up images)
	docker rmi $(DEV_PROJECT_IMAGE_NAME)

run: dev
	$(if $(CMD), $(DOCKER_INTERACTIVE_RUN) $(CMD), $(error -- CMD must be set))

bash: CMD=/bin/bash
bash: run

test: CMD=mix test
test: run

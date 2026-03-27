# Makefile do Frontend - MesclaInvest
# Autoria: Felipe Sousa - RA: 22018160

.DEFAULT_GOAL := help

ENV_FILE ?= .env
INTEGRATION_DEVICE ?= windows
INTEGRATION_REQUIRED ?= 0
RUN_ENV_IP_FROM_ENV := $(shell [ -f $(ENV_FILE) ] && sed -n 's/^WEB_HOSTNAME[[:space:]]*=[[:space:]]*//p' $(ENV_FILE) | head -n 1)
RUN_ENV_IP ?= $(if $(strip $(RUN_ENV_IP_FROM_ENV)),$(strip $(RUN_ENV_IP_FROM_ENV)),127.0.0.1)
WEB_PORT_FROM_ENV := $(shell [ -f $(ENV_FILE) ] && sed -n 's/^WEB_PORT[[:space:]]*=[[:space:]]*//p' $(ENV_FILE) | head -n 1)
WEB_PORT ?= $(if $(strip $(WEB_PORT_FROM_ENV)),$(strip $(WEB_PORT_FROM_ENV)),8080)
ANDROID_EMULATOR_IP_FROM_ENV := $(shell [ -f $(ENV_FILE) ] && sed -n 's/^ANDROID_EMULATOR_IP[[:space:]]*=[[:space:]]*//p' $(ENV_FILE) | head -n 1)
ANDROID_EMULATOR_IP ?= $(if $(strip $(ANDROID_EMULATOR_IP_FROM_ENV)),$(strip $(ANDROID_EMULATOR_IP_FROM_ENV)),10.0.2.2)
IOS_SIMULATOR_IP_FROM_ENV := $(shell [ -f $(ENV_FILE) ] && sed -n 's/^IOS_SIMULATOR_IP[[:space:]]*=[[:space:]]*//p' $(ENV_FILE) | head -n 1)
IOS_SIMULATOR_IP ?= $(if $(strip $(IOS_SIMULATOR_IP_FROM_ENV)),$(strip $(IOS_SIMULATOR_IP_FROM_ENV)),127.0.0.1)
DEVICE_IP_FROM_ENV := $(shell [ -f $(ENV_FILE) ] && sed -n 's/^DEVICE_IP[[:space:]]*=[[:space:]]*//p' $(ENV_FILE) | head -n 1)
DEVICE_IP ?= $(if $(strip $(DEVICE_IP_FROM_ENV)),$(strip $(DEVICE_IP_FROM_ENV)),192.168.0.10)
MACOS_IP_FROM_ENV := $(shell [ -f $(ENV_FILE) ] && sed -n 's/^MACOS_IP[[:space:]]*=[[:space:]]*//p' $(ENV_FILE) | head -n 1)
MACOS_IP ?= $(if $(strip $(MACOS_IP_FROM_ENV)),$(strip $(MACOS_IP_FROM_ENV)),127.0.0.1)

.PHONY: help deps run run-env run-env-web run-env-edge run-debug \
	run-env-android-emulator run-env-android-device run-env-ios-simulator run-env-ios-device run-env-macos \
	test-widget test-flow test-integration test-all test-coverage \
	format analyze quality coverage-path

help:
	@echo "Comandos disponiveis:"
	@echo ""
	@echo "[Execucao]"
	@echo "  make deps             - Instala dependencias (flutter pub get)"
	@echo "  make run              - Executa o app sem dart-define de arquivo"
	@echo "  make run-env          - Web server com WEB_HOSTNAME=$(RUN_ENV_IP) e WEB_PORT=$(WEB_PORT)"
	@echo "  make run-env-web      - Alias de run-env"
	@echo "  make run-env-edge     - Microsoft Edge com WEB_HOSTNAME=$(RUN_ENV_IP) e WEB_PORT=$(WEB_PORT)"
	@echo "  make run-env-android-emulator - Android emulador com DEVICE_HOST_IP=$(ANDROID_EMULATOR_IP)"
	@echo "  make run-env-android-device   - Android celular/dispositivo com DEVICE_HOST_IP=$(DEVICE_IP)"
	@echo "  make run-env-ios-simulator    - iOS simulador com DEVICE_HOST_IP=$(IOS_SIMULATOR_IP)"
	@echo "  make run-env-ios-device       - iOS dispositivo com DEVICE_HOST_IP=$(DEVICE_IP)"
	@echo "  make run-env-macos            - macOS com DEVICE_HOST_IP=$(MACOS_IP)"
	@echo "                           Override opcional: make run-env-android-device DEVICE_IP=192.168.1.20"
	@echo "  make run-debug        - Alias de run-env"
	@echo ""
	@echo "[Testes]"
	@echo "  make test-widget      - Roda testes de widget (test/widget)"
	@echo "  make test-flow        - Roda testes de fluxo (test/flow)"
	@echo "  make test-integration - Roda testes de integracao em -d $(INTEGRATION_DEVICE)"
	@echo "                           Se falhar por ambiente, faz skip quando INTEGRATION_REQUIRED=0"
	@echo "  make test-all         - Roda a ordem padrao: widget -> flow -> integration"
	@echo "  make test-coverage    - Gera cobertura em coverage/lcov.info"
	@echo ""
	@echo "[Qualidade]"
	@echo "  make format           - Formata o projeto (dart format .)"
	@echo "  make analyze          - Analisa o projeto (flutter analyze)"
	@echo "  make quality          - Executa format + analyze + test-all + test-coverage"
	@echo "  make coverage-path    - Exibe caminho do arquivo de cobertura"

deps:
	flutter pub get

run:
	flutter run

run-env:
	flutter run -d web-server --web-hostname=$(RUN_ENV_IP) --web-port=$(WEB_PORT) --dart-define-from-file=$(ENV_FILE)

run-env-web:
	flutter run -d web-server --web-hostname=$(RUN_ENV_IP) --web-port=$(WEB_PORT) --dart-define-from-file=$(ENV_FILE)

run-env-edge:
	flutter run -d edge --web-hostname=$(RUN_ENV_IP) --web-port=$(WEB_PORT) --dart-define-from-file=$(ENV_FILE)

run-debug: run-env

run-env-android-emulator:
	flutter run -d android --dart-define-from-file=$(ENV_FILE) --dart-define=DEVICE_HOST_IP=$(ANDROID_EMULATOR_IP)

run-env-android-device:
	flutter run -d android --dart-define-from-file=$(ENV_FILE) --dart-define=DEVICE_HOST_IP=$(DEVICE_IP)

run-env-ios-simulator:
	flutter run -d ios --dart-define-from-file=$(ENV_FILE) --dart-define=DEVICE_HOST_IP=$(IOS_SIMULATOR_IP)

run-env-ios-device:
	flutter run -d ios --dart-define-from-file=$(ENV_FILE) --dart-define=DEVICE_HOST_IP=$(DEVICE_IP)

run-env-macos:
	flutter run -d macos --dart-define-from-file=$(ENV_FILE) --dart-define=DEVICE_HOST_IP=$(MACOS_IP)

test-widget:
	flutter test test/widget

test-flow:
	flutter test test/flow

test-integration:
	@if flutter test integration_test -d $(INTEGRATION_DEVICE); then \
		echo "Integration tests passed."; \
	elif [ "$(INTEGRATION_REQUIRED)" = "1" ]; then \
		echo "Integration tests failed and INTEGRATION_REQUIRED=1."; \
		exit 1; \
	else \
		echo "Integration tests skipped due to local environment limitations."; \
		echo "Tip: use INTEGRATION_REQUIRED=1 to enforce failure on this step."; \
	fi

test-all: test-widget test-flow test-integration

test-coverage:
	flutter test --coverage

format:
	dart format .

analyze:
	flutter analyze

quality: format analyze test-all test-coverage coverage-path

coverage-path:
	@echo "coverage/lcov.info"

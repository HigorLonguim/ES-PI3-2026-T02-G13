# Makefile do Frontend - MesclaInvest
# Autoria: Felipe Sousa - RA: 22018160

.DEFAULT_GOAL := help

ENV_FILE ?= .env

.PHONY: help deps run run-env run-debug \
	test-widget test-flow test-integration test-all test-coverage \
	format analyze quality coverage-path

help:
	@echo "Comandos disponiveis:"
	@echo ""
	@echo "[Execucao]"
	@echo "  make deps             - Instala dependencias (flutter pub get)"
	@echo "  make run              - Executa o app sem dart-define de arquivo"
	@echo "  make run-env          - Executa o app usando --dart-define-from-file=$(ENV_FILE)"
	@echo "  make run-debug        - Alias de run-env"
	@echo ""
	@echo "[Testes]"
	@echo "  make test-widget      - Roda testes de widget (test/widget)"
	@echo "  make test-flow        - Roda testes de fluxo (test/flow)"
	@echo "  make test-integration - Roda testes de integracao (integration_test)"
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
	flutter run --dart-define-from-file=$(ENV_FILE)

run-debug: run-env

test-widget:
	flutter test test/widget

test-flow:
	flutter test test/flow

test-integration:
	flutter test integration_test

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
# Organização de testes

## Estrutura

- `test/widget/`: testes de widget (componentes e renderização)
- `test/flow/`: testes de fluxo de usuário com `flutter_test`
- `integration_test/`: testes de integração/E2E

## Comandos

- Rodar todos os testes de widget/flow:
  - `flutter test test`
- Rodar apenas testes de widget:
  - `flutter test test/widget`
- Rodar apenas testes de fluxo:
  - `flutter test test/flow`
- Rodar testes de integração (E2E):
  - `flutter test integration_test`
- Gerar cobertura:
  - `flutter test --coverage`

## Cobertura

- Arquivo gerado: `coverage/lcov.info`
- Para visualizar em HTML (opcional, requer lcov):
  - `genhtml coverage/lcov.info -o coverage/html`

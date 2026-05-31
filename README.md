# Projeto MesclaInvest - PI3 2026

[Projeto Integrador III](https://www.figma.com/design/KSc3mF9Pig0zTgGV1P39Ii/Projeto-Integrador-III?node-id=0-1&t=LzfIiMXKWNP4AvGy-1)

## Descricao

O MesclaInvest e um aplicativo mobile desenvolvido para a disciplina de Projeto Integrador 3. Ele simula um ambiente de investimento em startups por meio de tokens digitais, permitindo visualizar startups, consultar informacoes institucionais, acompanhar carteira, comprar e vender tokens simulados e interagir com ofertas no balcao de tokens.

## Integrantes

- Arthur Zambroni - RA: 22002697
- Felipe Sousa - RA: 22018160
- Higor Vedovello Longuim - RA: 23000291
- Joao Vitor Custodio - RA: 22000115
- Luigi Mazzoni - RA: 23010918

## Como Executar

O frontend depende do backend em Node.js/TypeScript executado nas Firebase Cloud Functions.
Isso atende ao requisito do documento do projeto (backend em Node.js + Firebase).

1. Suba o backend (Firebase Functions):

```bash
cd firebase/functions
npm install
npm run build
npm run serve
```

2. No `frontend/.env`, configure as URLs das Functions:

```env
FIREBASE_WEB_API_KEY=...
REGISTER_FUNCTION_URL=...
STARTUPS_FUNCTION_URL=...
WALLET_FUNCTION_URL=...
CREDIT_WALLET_FUNCTION_URL=...
BUY_TOKENS_FUNCTION_URL=...
SELL_TOKENS_FUNCTION_URL=...
TRANSACTIONS_FUNCTION_URL=...
PRIVATE_QUESTION_FUNCTION_URL=...
MARKET_OFFERS_FUNCTION_URL=...
MY_OFFERS_FUNCTION_URL=...
CREATE_OFFER_FUNCTION_URL=...
CANCEL_OFFER_FUNCTION_URL=...
ACCEPT_OFFER_FUNCTION_URL=...
```

3. Rode o frontend:

```bash
cd frontend
flutter pub get
flutter run --dart-define-from-file=.env
```

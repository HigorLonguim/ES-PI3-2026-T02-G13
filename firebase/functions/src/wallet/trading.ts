// Autoria: Felipe Sousa - RA: 22018160
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import type {Response as ExpressResponse} from "express";
import {db} from "../shared/firebase";
import {handleMethodAndCors} from "../shared/http";

type WalletDocument = {
  uid: string;
  balance: number;
  createdAt: admin.firestore.FieldValue | admin.firestore.Timestamp;
  updatedAt: admin.firestore.FieldValue | admin.firestore.Timestamp;
};

type PositionDocument = {
  startupId: string;
  startupName: string;
  quantity: number;
  averagePrice: number;
  investedAmount: number;
  updatedAt: admin.firestore.FieldValue | admin.firestore.Timestamp;
};

type TransactionDocument = {
  type: "CREDIT" | "BUY" | "SELL";
  startupId: string | null;
  startupName: string | null;
  quantity: number | null;
  unitPrice: number | null;
  amount: number;
  createdAt: admin.firestore.FieldValue | admin.firestore.Timestamp;
  metadata: Record<string, unknown>;
};

type StartupSnapshot = {
  id: string;
  name: string;
  tokenPrice: number;
  imageUrl: string;
};

const DEFAULT_INITIAL_BALANCE = 50000;
const MAX_TRANSACTION_ITEMS = 100;

function numberOrZero(value: unknown): number {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }

  if (typeof value === "string") {
    const parsed = Number(value);
    if (Number.isFinite(parsed)) {
      return parsed;
    }
  }

  return 0;
}

function parsePositiveQuantity(value: unknown): number {
  const parsed = numberOrZero(value);
  if (!Number.isInteger(parsed) || parsed <= 0) {
    return 0;
  }

  return parsed;
}

function parsePositiveAmount(value: unknown): number {
  const parsed = numberOrZero(value);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return 0;
  }

  return parsed;
}

function asNonEmptyString(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

function roundMoney(value: number): number {
  return Math.round(value * 100) / 100;
}

function parseBearerToken(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();
  if (!trimmed.toLowerCase().startsWith("bearer ")) {
    return null;
  }

  const token = trimmed.slice("bearer ".length).trim();
  return token.length > 0 ? token : null;
}

async function requireAuthenticatedUser(
  req: functions.https.Request,
  res: ExpressResponse<unknown>,
): Promise<string | null> {
  const token = parseBearerToken(req.headers.authorization);
  if (!token) {
    res.status(401).json({error: "Token de autenticacao ausente"});
    return null;
  }

  try {
    const decoded = await admin.auth().verifyIdToken(token);
    if (!decoded.uid) {
      res.status(401).json({error: "Token invalido"});
      return null;
    }

    return decoded.uid;
  } catch (_error) {
    res.status(401).json({error: "Token invalido"});
    return null;
  }
}

function startupRef(startupId: string): admin.firestore.DocumentReference {
  return db.collection("startups").doc(startupId);
}

function walletRef(uid: string): admin.firestore.DocumentReference {
  return db.collection("wallets").doc(uid);
}

function walletPositionsRef(uid: string): admin.firestore.CollectionReference {
  return walletRef(uid).collection("positions");
}

function walletTransactionsRef(uid: string): admin.firestore.CollectionReference {
  return walletRef(uid).collection("transactions");
}

async function resolveStartupSnapshot(startupId: string): Promise<StartupSnapshot | null> {
  const startupDocument = await startupRef(startupId).get();
  if (!startupDocument.exists) {
    return null;
  }

  const data = startupDocument.data() ?? {};
  const startupName =
    asNonEmptyString(data.nome_startup) ??
    asNonEmptyString(data.name) ??
    "Startup";
  const raisedCapital = numberOrZero(data.capital_aportado);
  const emittedTokens = numberOrZero(data.tokens_emitidos);
  const tokenPrice = emittedTokens > 0 ? roundMoney(raisedCapital / emittedTokens) : 0;

  return {
    id: startupDocument.id,
    name: startupName,
    tokenPrice,
    imageUrl: `https://picsum.photos/seed/${startupDocument.id}/400/400`,
  };
}

async function ensureWallet(uid: string): Promise<WalletDocument> {
  const now = admin.firestore.FieldValue.serverTimestamp();
  const reference = walletRef(uid);
  const snapshot = await reference.get();

  if (snapshot.exists) {
    const data = snapshot.data() ?? {};
    return {
      uid,
      balance: numberOrZero(data.balance),
      createdAt: (data.createdAt as admin.firestore.Timestamp) ?? now,
      updatedAt: (data.updatedAt as admin.firestore.Timestamp) ?? now,
    };
  }

  const wallet: WalletDocument = {
    uid,
    balance: DEFAULT_INITIAL_BALANCE,
    createdAt: now,
    updatedAt: now,
  };
  await reference.set(wallet);
  return wallet;
}

async function listWalletPositions(uid: string): Promise<Record<string, PositionDocument>> {
  const snapshot = await walletPositionsRef(uid).get();
  const result: Record<string, PositionDocument> = {};

  snapshot.docs.forEach((document) => {
    const data = document.data();
    result[document.id] = {
      startupId: document.id,
      startupName: asNonEmptyString(data.startupName) ?? "Startup",
      quantity: numberOrZero(data.quantity),
      averagePrice: numberOrZero(data.averagePrice),
      investedAmount: numberOrZero(data.investedAmount),
      updatedAt:
        (data.updatedAt as admin.firestore.Timestamp) ??
        admin.firestore.FieldValue.serverTimestamp(),
    };
  });

  return result;
}

async function listWalletTransactions(uid: string): Promise<Record<string, unknown>[]> {
  const snapshot = await walletTransactionsRef(uid)
    .orderBy("createdAt", "desc")
    .limit(MAX_TRANSACTION_ITEMS)
    .get();

  return snapshot.docs.map((document) => {
    const data = document.data();
    return {
      id: document.id,
      type: asNonEmptyString(data.type) ?? "UNKNOWN",
      startupId: asNonEmptyString(data.startupId),
      startupName: asNonEmptyString(data.startupName),
      quantity: numberOrZero(data.quantity),
      unitPrice: numberOrZero(data.unitPrice),
      amount: numberOrZero(data.amount),
      createdAt:
        data.createdAt instanceof admin.firestore.Timestamp
          ? data.createdAt.toDate().toISOString()
          : null,
      metadata: (data.metadata as Record<string, unknown>) ?? {},
    };
  });
}

async function buildWalletPayload(
  uid: string,
  walletData: WalletDocument,
): Promise<Record<string, unknown>> {
  const positions = await listWalletPositions(uid);
  const holdings = await Promise.all(
    Object.values(positions).map(async (position) => {
      const startup = await resolveStartupSnapshot(position.startupId);
      const currentTokenPrice = startup?.tokenPrice ?? position.averagePrice;
      const totalValue = roundMoney(currentTokenPrice * position.quantity);
      const totalInvested = roundMoney(position.investedAmount);

      return {
        startupId: position.startupId,
        startupName: startup?.name ?? position.startupName,
        quantity: position.quantity,
        averagePrice: roundMoney(position.averagePrice),
        totalInvested,
        currentTokenPrice: roundMoney(currentTokenPrice),
        totalValue,
        imageUrl:
          startup?.imageUrl ??
          `https://picsum.photos/seed/${position.startupId}/400/400`,
      };
    }),
  );

  return {
    balance: roundMoney(walletData.balance),
    holdings,
    hasAnyInvestment: holdings.some((item) => item.quantity > 0),
    transactions: await listWalletTransactions(uid),
  };
}

async function hasInvestorPosition(
  uid: string,
  startupId: string,
): Promise<boolean> {
  const positionSnapshot = await walletPositionsRef(uid).doc(startupId).get();
  if (!positionSnapshot.exists) {
    return false;
  }

  const data = positionSnapshot.data() ?? {};
  return numberOrZero(data.quantity) > 0;
}

export const getWallet = functions.https.onRequest(async (req, res) => {
  if (handleMethodAndCors(req, res, "GET")) {
    return;
  }

  const uid = await requireAuthenticatedUser(req, res);
  if (!uid) {
    return;
  }

  try {
    const wallet = await ensureWallet(uid);
    const payload = await buildWalletPayload(uid, wallet);
    res.status(200).json(payload);
  } catch (_error) {
    res.status(500).json({error: "Falha ao carregar carteira"});
  }
});

export const listTransactions = functions.https.onRequest(async (req, res) => {
  if (handleMethodAndCors(req, res, "GET")) {
    return;
  }

  const uid = await requireAuthenticatedUser(req, res);
  if (!uid) {
    return;
  }

  try {
    await ensureWallet(uid);
    const items = await listWalletTransactions(uid);
    res.status(200).json({items});
  } catch (_error) {
    res.status(500).json({error: "Falha ao listar transacoes"});
  }
});

export const creditWallet = functions.https.onRequest(async (req, res) => {
  if (handleMethodAndCors(req, res, "POST")) {
    return;
  }

  const uid = await requireAuthenticatedUser(req, res);
  if (!uid) {
    return;
  }

  const amount = parsePositiveAmount((req.body as Record<string, unknown>).amount);
  if (amount <= 0) {
    res.status(400).json({error: "Valor de credito invalido"});
    return;
  }

  try {
    const walletReference = walletRef(uid);
    const transactionReference = walletTransactionsRef(uid).doc();
    await db.runTransaction(async (transaction) => {
      const walletSnapshot = await transaction.get(walletReference);
      const currentBalance = walletSnapshot.exists
        ? numberOrZero(walletSnapshot.data()?.balance)
        : DEFAULT_INITIAL_BALANCE;
      const nextBalance = roundMoney(currentBalance + amount);
      const now = admin.firestore.FieldValue.serverTimestamp();

      const walletPayload: WalletDocument = {
        uid,
        balance: nextBalance,
        createdAt: walletSnapshot.exists
          ? (walletSnapshot.data()?.createdAt as admin.firestore.Timestamp) ??
            now
          : now,
        updatedAt: now,
      };

      transaction.set(walletReference, walletPayload, {merge: true});
      const transactionPayload: TransactionDocument = {
        type: "CREDIT",
        startupId: null,
        startupName: null,
        quantity: null,
        unitPrice: null,
        amount: roundMoney(amount),
        createdAt: now,
        metadata: {source: "manual_credit"},
      };
      transaction.set(transactionReference, transactionPayload);
    });

    const wallet = await ensureWallet(uid);
    const payload = await buildWalletPayload(uid, wallet);
    res.status(200).json({
      message: "Saldo adicionado com sucesso",
      ...payload,
    });
  } catch (_error) {
    res.status(500).json({error: "Falha ao adicionar saldo"});
  }
});

export const buyTokens = functions.https.onRequest(async (req, res) => {
  if (handleMethodAndCors(req, res, "POST")) {
    return;
  }

  const uid = await requireAuthenticatedUser(req, res);
  if (!uid) {
    return;
  }

  const body = req.body as Record<string, unknown>;
  const startupId = asNonEmptyString(body.startupId);
  const quantity = parsePositiveQuantity(body.quantity);

  if (!startupId || quantity <= 0) {
    res.status(400).json({error: "Dados de compra invalidos"});
    return;
  }

  const startup = await resolveStartupSnapshot(startupId);
  if (!startup) {
    res.status(404).json({error: "Startup nao encontrada"});
    return;
  }

  const totalAmount = roundMoney(startup.tokenPrice * quantity);

  try {
    const walletReference = walletRef(uid);
    const positionReference = walletPositionsRef(uid).doc(startup.id);
    const transactionReference = walletTransactionsRef(uid).doc();

    await db.runTransaction(async (transaction) => {
      const walletSnapshot = await transaction.get(walletReference);
      const currentBalance = walletSnapshot.exists
        ? numberOrZero(walletSnapshot.data()?.balance)
        : DEFAULT_INITIAL_BALANCE;

      if (currentBalance < totalAmount) {
        throw new Error("INSUFFICIENT_BALANCE");
      }

      const positionSnapshot = await transaction.get(positionReference);
      const currentQuantity = positionSnapshot.exists
        ? numberOrZero(positionSnapshot.data()?.quantity)
        : 0;
      const currentInvested = positionSnapshot.exists
        ? numberOrZero(positionSnapshot.data()?.investedAmount)
        : 0;

      const nextQuantity = currentQuantity + quantity;
      const nextInvested = roundMoney(currentInvested + totalAmount);
      const nextAverage = nextQuantity > 0 ? roundMoney(nextInvested / nextQuantity) : 0;
      const nextBalance = roundMoney(currentBalance - totalAmount);
      const now = admin.firestore.FieldValue.serverTimestamp();

      const walletPayload: WalletDocument = {
        uid,
        balance: nextBalance,
        createdAt: walletSnapshot.exists
          ? (walletSnapshot.data()?.createdAt as admin.firestore.Timestamp) ??
            now
          : now,
        updatedAt: now,
      };
      transaction.set(walletReference, walletPayload, {merge: true});

      const positionPayload: PositionDocument = {
        startupId: startup.id,
        startupName: startup.name,
        quantity: nextQuantity,
        averagePrice: nextAverage,
        investedAmount: nextInvested,
        updatedAt: now,
      };
      transaction.set(positionReference, positionPayload, {merge: true});

      const transactionPayload: TransactionDocument = {
        type: "BUY",
        startupId: startup.id,
        startupName: startup.name,
        quantity,
        unitPrice: startup.tokenPrice,
        amount: totalAmount,
        createdAt: now,
        metadata: {operation: "buy_tokens"},
      };
      transaction.set(transactionReference, transactionPayload);
    });

    const wallet = await ensureWallet(uid);
    const payload = await buildWalletPayload(uid, wallet);
    res.status(200).json({
      message: "Compra realizada com sucesso",
      ...payload,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "UNKNOWN";
    if (message === "INSUFFICIENT_BALANCE") {
      res.status(400).json({error: "Saldo insuficiente"});
      return;
    }

    res.status(500).json({error: "Falha ao realizar compra"});
  }
});

export const sellTokens = functions.https.onRequest(async (req, res) => {
  if (handleMethodAndCors(req, res, "POST")) {
    return;
  }

  const uid = await requireAuthenticatedUser(req, res);
  if (!uid) {
    return;
  }

  const body = req.body as Record<string, unknown>;
  const startupId = asNonEmptyString(body.startupId);
  const quantity = parsePositiveQuantity(body.quantity);

  if (!startupId || quantity <= 0) {
    res.status(400).json({error: "Dados de venda invalidos"});
    return;
  }

  const startup = await resolveStartupSnapshot(startupId);
  if (!startup) {
    res.status(404).json({error: "Startup nao encontrada"});
    return;
  }

  const totalAmount = roundMoney(startup.tokenPrice * quantity);

  try {
    const walletReference = walletRef(uid);
    const positionReference = walletPositionsRef(uid).doc(startup.id);
    const transactionReference = walletTransactionsRef(uid).doc();

    await db.runTransaction(async (transaction) => {
      const walletSnapshot = await transaction.get(walletReference);
      const currentBalance = walletSnapshot.exists
        ? numberOrZero(walletSnapshot.data()?.balance)
        : DEFAULT_INITIAL_BALANCE;

      const positionSnapshot = await transaction.get(positionReference);
      if (!positionSnapshot.exists) {
        throw new Error("INSUFFICIENT_POSITION");
      }

      const currentQuantity = numberOrZero(positionSnapshot.data()?.quantity);
      const currentInvested = numberOrZero(positionSnapshot.data()?.investedAmount);
      if (currentQuantity < quantity) {
        throw new Error("INSUFFICIENT_POSITION");
      }

      const remainingQuantity = currentQuantity - quantity;
      const newBalance = roundMoney(currentBalance + totalAmount);
      const now = admin.firestore.FieldValue.serverTimestamp();

      const walletPayload: WalletDocument = {
        uid,
        balance: newBalance,
        createdAt: walletSnapshot.exists
          ? (walletSnapshot.data()?.createdAt as admin.firestore.Timestamp) ??
            now
          : now,
        updatedAt: now,
      };
      transaction.set(walletReference, walletPayload, {merge: true});

      if (remainingQuantity <= 0) {
        transaction.delete(positionReference);
      } else {
        const remainingInvested = roundMoney(
          (currentInvested / currentQuantity) * remainingQuantity,
        );
        const remainingAverage = roundMoney(remainingInvested / remainingQuantity);
        const positionPayload: PositionDocument = {
          startupId: startup.id,
          startupName: startup.name,
          quantity: remainingQuantity,
          averagePrice: remainingAverage,
          investedAmount: remainingInvested,
          updatedAt: now,
        };
        transaction.set(positionReference, positionPayload, {merge: true});
      }

      const transactionPayload: TransactionDocument = {
        type: "SELL",
        startupId: startup.id,
        startupName: startup.name,
        quantity,
        unitPrice: startup.tokenPrice,
        amount: totalAmount,
        createdAt: now,
        metadata: {operation: "sell_tokens"},
      };
      transaction.set(transactionReference, transactionPayload);
    });

    const wallet = await ensureWallet(uid);
    const payload = await buildWalletPayload(uid, wallet);
    res.status(200).json({
      message: "Venda realizada com sucesso",
      ...payload,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "UNKNOWN";
    if (message === "INSUFFICIENT_POSITION") {
      res.status(400).json({error: "Quantidade indisponivel para venda"});
      return;
    }

    res.status(500).json({error: "Falha ao realizar venda"});
  }
});

export const submitPrivateQuestion = functions.https.onRequest(async (req, res) => {
  if (handleMethodAndCors(req, res, "POST")) {
    return;
  }

  const uid = await requireAuthenticatedUser(req, res);
  if (!uid) {
    return;
  }

  const body = req.body as Record<string, unknown>;
  const startupId = asNonEmptyString(body.startupId);
  const question = asNonEmptyString(body.question);

  if (!startupId || !question) {
    res.status(400).json({error: "Dados da pergunta privada invalidos"});
    return;
  }

  const startup = await resolveStartupSnapshot(startupId);
  if (!startup) {
    res.status(404).json({error: "Startup nao encontrada"});
    return;
  }

  try {
    const isInvestor = await hasInvestorPosition(uid, startup.id);
    if (!isInvestor) {
      res.status(403).json({
        error: "Funcionalidade disponivel apenas para investidores desta startup",
      });
      return;
    }

    await db.collection("private_questions").add({
      uid,
      startupId: startup.id,
      startupName: startup.name,
      question,
      status: "PENDING",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.status(200).json({
      message: "Pergunta privada enviada com sucesso",
    });
  } catch (_error) {
    res.status(500).json({error: "Falha ao enviar pergunta privada"});
  }
});

// Autoria: Felipe Sousa - RA: 22018160
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import type {Response as ExpressResponse} from "express";
import {db} from "../shared/firebase";
import {handleMethodAndCors} from "../shared/http";

type OfferType = "BUY" | "SELL";
type OfferStatus = "ACTIVE" | "CANCELED" | "FILLED";

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
  type: "BUY" | "SELL";
  startupId: string;
  startupName: string;
  quantity: number;
  unitPrice: number;
  amount: number;
  createdAt: admin.firestore.FieldValue | admin.firestore.Timestamp;
  metadata: Record<string, unknown>;
};

type TradingOfferDocument = {
  uid: string;
  startupId: string;
  startupName: string;
  startupImageUrl: string;
  type: OfferType;
  quantity: number;
  pricePerToken: number;
  status: OfferStatus;
  createdAt: admin.firestore.FieldValue | admin.firestore.Timestamp;
  updatedAt: admin.firestore.FieldValue | admin.firestore.Timestamp;
  canceledAt?: admin.firestore.FieldValue | admin.firestore.Timestamp | null;
  filledAt?: admin.firestore.FieldValue | admin.firestore.Timestamp | null;
};

const DEFAULT_INITIAL_BALANCE = 50000;

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

function roundMoney(value: number): number {
  return Math.round(value * 100) / 100;
}

function asNonEmptyString(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

function parsePositiveInteger(value: unknown): number {
  const parsed = numberOrZero(value);
  if (!Number.isInteger(parsed) || parsed <= 0) {
    return 0;
  }
  return parsed;
}

function parsePositiveMoney(value: unknown): number {
  const parsed = numberOrZero(value);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return 0;
  }
  return roundMoney(parsed);
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
    return decoded.uid ?? null;
  } catch (_error) {
    res.status(401).json({error: "Token invalido"});
    return null;
  }
}

async function resolveStartupSnapshot(startupId: string): Promise<{
  id: string;
  name: string;
  tokenPrice: number;
  imageUrl: string;
} | null> {
  const startupDocument = await db.collection("startups").doc(startupId).get();
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

function offerRef(offerId: string): admin.firestore.DocumentReference {
  return db.collection("market_offers").doc(offerId);
}

function offersCollection(): admin.firestore.CollectionReference {
  return db.collection("market_offers");
}

function walletPositionRef(uid: string, startupId: string): admin.firestore.DocumentReference {
  return db.collection("wallets").doc(uid).collection("positions").doc(startupId);
}

function walletRef(uid: string): admin.firestore.DocumentReference {
  return db.collection("wallets").doc(uid);
}

function walletTransactionsRef(uid: string): admin.firestore.CollectionReference {
  return walletRef(uid).collection("transactions");
}

function mapOffer(
  document: admin.firestore.QueryDocumentSnapshot,
  userNamesByUid: Record<string, string>,
): Record<string, unknown> {
  const data = document.data();
  const uid = asNonEmptyString(data.uid);
  return {
    id: document.id,
    uid,
    userName: uid ? (userNamesByUid[uid] ?? "Usuario") : "Usuario",
    startupId: asNonEmptyString(data.startupId),
    startupName: asNonEmptyString(data.startupName) ?? "Startup",
    startupImageUrl: asNonEmptyString(data.startupImageUrl) ?? "",
    type: asNonEmptyString(data.type) ?? "BUY",
    quantity: numberOrZero(data.quantity),
    pricePerToken: roundMoney(numberOrZero(data.pricePerToken)),
    total: roundMoney(numberOrZero(data.quantity) * numberOrZero(data.pricePerToken)),
    status: asNonEmptyString(data.status) ?? "ACTIVE",
    createdAt: data.createdAt instanceof admin.firestore.Timestamp ?
      data.createdAt.toDate().toISOString() : null,
    updatedAt: data.updatedAt instanceof admin.firestore.Timestamp ?
      data.updatedAt.toDate().toISOString() : null,
  };
}

async function resolveUserNamesByUid(uids: string[]): Promise<Record<string, string>> {
  const uniqueUids = Array.from(new Set(uids.filter((uid) => uid.trim().length > 0)));
  if (uniqueUids.length === 0) {
    return {};
  }

  const snapshots = await Promise.all(
    uniqueUids.map((uid) => db.collection("users").doc(uid).get()),
  );

  const result: Record<string, string> = {};
  snapshots.forEach((snapshot) => {
    if (!snapshot.exists) {
      return;
    }
    const data = snapshot.data() ?? {};
    const nome = asNonEmptyString(data.nome) ?? asNonEmptyString(data.name);
    if (!nome) {
      return;
    }
    result[snapshot.id] = nome;
  });

  return result;
}

export const listMarketOffers = functions.https.onRequest(async (req, res) => {
  if (handleMethodAndCors(req, res, "GET")) {
    return;
  }

  const uid = await requireAuthenticatedUser(req, res);
  if (!uid) {
    return;
  }

  try {
    const typeFilter = asNonEmptyString(req.query.type);
    const startupIdFilter = asNonEmptyString(req.query.startupId);
    const limit = Math.min(parsePositiveInteger(req.query.limit) || 50, 100);

    const snapshot = await offersCollection()
      .where("status", "==", "ACTIVE")
      .orderBy("createdAt", "desc")
      .limit(limit)
      .get();

    const filteredDocs = snapshot.docs
      .filter((document) => {
        const data = document.data();
        const type = asNonEmptyString(data.type);
        const startupId = asNonEmptyString(data.startupId);
        const typeOk = !typeFilter || type === typeFilter;
        const startupOk = !startupIdFilter || startupId === startupIdFilter;
        return typeOk && startupOk;
      });

    const userNamesByUid = await resolveUserNamesByUid(
      filteredDocs
        .map((document) => asNonEmptyString(document.data().uid))
        .filter((uid): uid is string => Boolean(uid)),
    );

    const items = filteredDocs.map((document) => mapOffer(document, userNamesByUid));

    res.status(200).json({items});
  } catch (_error) {
    res.status(500).json({error: "Falha ao listar ofertas do mercado"});
  }
});

export const listMyOffers = functions.https.onRequest(async (req, res) => {
  if (handleMethodAndCors(req, res, "GET")) {
    return;
  }

  const uid = await requireAuthenticatedUser(req, res);
  if (!uid) {
    return;
  }

  try {
    const onlyActive = asNonEmptyString(req.query.onlyActive) !== "false";
    let query = offersCollection().where("uid", "==", uid).orderBy("createdAt", "desc");
    if (onlyActive) {
      query = query.where("status", "==", "ACTIVE");
    }

    const snapshot = await query.limit(100).get();
    const userNamesByUid = await resolveUserNamesByUid(
      snapshot.docs
        .map((document) => asNonEmptyString(document.data().uid))
        .filter((uid): uid is string => Boolean(uid)),
    );
    const items = snapshot.docs.map((document) => mapOffer(document, userNamesByUid));
    res.status(200).json({items});
  } catch (_error) {
    res.status(500).json({error: "Falha ao listar ofertas do usuario"});
  }
});

export const createMarketOffer = functions.https.onRequest(async (req, res) => {
  if (handleMethodAndCors(req, res, "POST")) {
    return;
  }

  const uid = await requireAuthenticatedUser(req, res);
  if (!uid) {
    return;
  }

  const body = req.body as Record<string, unknown>;
  const startupId = asNonEmptyString(body.startupId);
  const offerType = asNonEmptyString(body.type);
  const quantity = parsePositiveInteger(body.quantity);
  const pricePerToken = parsePositiveMoney(body.pricePerToken);

  if (!startupId || (offerType !== "BUY" && offerType !== "SELL") || quantity <= 0 || pricePerToken <= 0) {
    res.status(400).json({error: "Dados da oferta invalidos"});
    return;
  }

  const startup = await resolveStartupSnapshot(startupId);
  if (!startup) {
    res.status(404).json({error: "Startup nao encontrada"});
    return;
  }

  if (offerType === "SELL") {
    const positionSnapshot = await walletPositionRef(uid, startup.id).get();
    const currentQuantity = positionSnapshot.exists ?
      numberOrZero(positionSnapshot.data()?.quantity) : 0;
    if (currentQuantity < quantity) {
      res.status(400).json({error: "Quantidade indisponivel para oferta de venda"});
      return;
    }
  }

  try {
    const now = admin.firestore.FieldValue.serverTimestamp();
    const payload: TradingOfferDocument = {
      uid,
      startupId: startup.id,
      startupName: startup.name,
      startupImageUrl: startup.imageUrl,
      type: offerType,
      quantity,
      pricePerToken,
      status: "ACTIVE",
      createdAt: now,
      updatedAt: now,
      canceledAt: null,
    };

    const reference = await offersCollection().add(payload);
    res.status(201).json({
      message: "Oferta criada com sucesso",
      offerId: reference.id,
    });
  } catch (_error) {
    res.status(500).json({error: "Falha ao criar oferta"});
  }
});

export const cancelMarketOffer = functions.https.onRequest(async (req, res) => {
  if (handleMethodAndCors(req, res, "POST")) {
    return;
  }

  const uid = await requireAuthenticatedUser(req, res);
  if (!uid) {
    return;
  }

  const body = req.body as Record<string, unknown>;
  const offerId = asNonEmptyString(body.offerId);
  if (!offerId) {
    res.status(400).json({error: "offerId obrigatorio"});
    return;
  }

  try {
    const reference = offerRef(offerId);
    await db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(reference);
      if (!snapshot.exists) {
        throw new Error("NOT_FOUND");
      }

      const data = snapshot.data() ?? {};
      if (asNonEmptyString(data.uid) !== uid) {
        throw new Error("FORBIDDEN");
      }
      if (asNonEmptyString(data.status) !== "ACTIVE") {
        throw new Error("INVALID_STATUS");
      }

      const now = admin.firestore.FieldValue.serverTimestamp();
      transaction.set(reference, {
        status: "CANCELED",
        updatedAt: now,
        canceledAt: now,
      }, {merge: true});
    });

    res.status(200).json({message: "Oferta cancelada com sucesso"});
  } catch (error) {
    const message = error instanceof Error ? error.message : "UNKNOWN";
    if (message === "NOT_FOUND") {
      res.status(404).json({error: "Oferta nao encontrada"});
      return;
    }
    if (message === "FORBIDDEN") {
      res.status(403).json({error: "Sem permissao para cancelar esta oferta"});
      return;
    }
    if (message === "INVALID_STATUS") {
      res.status(400).json({error: "A oferta nao esta ativa"});
      return;
    }
    res.status(500).json({error: "Falha ao cancelar oferta"});
  }
});

export const acceptMarketOffer = functions.https.onRequest(async (req, res) => {
  if (handleMethodAndCors(req, res, "POST")) {
    return;
  }

  const takerUid = await requireAuthenticatedUser(req, res);
  if (!takerUid) {
    return;
  }

  const body = req.body as Record<string, unknown>;
  const offerId = asNonEmptyString(body.offerId);
  if (!offerId) {
    res.status(400).json({error: "offerId obrigatorio"});
    return;
  }

  try {
    const offerReference = offerRef(offerId);
    await db.runTransaction(async (transaction) => {
      const offerSnapshot = await transaction.get(offerReference);
      if (!offerSnapshot.exists) {
        throw new Error("NOT_FOUND");
      }

      const offerData = offerSnapshot.data() ?? {};
      const status = asNonEmptyString(offerData.status);
      if (status !== "ACTIVE") {
        throw new Error("INVALID_STATUS");
      }

      const makerUid = asNonEmptyString(offerData.uid);
      const startupId = asNonEmptyString(offerData.startupId);
      const startupName = asNonEmptyString(offerData.startupName) ?? "Startup";
      const offerType = asNonEmptyString(offerData.type);
      const quantity = parsePositiveInteger(offerData.quantity);
      const pricePerToken = parsePositiveMoney(offerData.pricePerToken);

      if (!makerUid || !startupId || !offerType || quantity <= 0 || pricePerToken <= 0) {
        throw new Error("INVALID_OFFER");
      }
      if (makerUid === takerUid) {
        throw new Error("SELF_TRADE");
      }

      const buyerUid = offerType === "SELL" ? takerUid : makerUid;
      const sellerUid = offerType === "SELL" ? makerUid : takerUid;
      const totalAmount = roundMoney(quantity * pricePerToken);
      const now = admin.firestore.FieldValue.serverTimestamp();

      const buyerWalletRef = walletRef(buyerUid);
      const sellerWalletRef = walletRef(sellerUid);
      const buyerPositionRef = walletPositionRef(buyerUid, startupId);
      const sellerPositionRef = walletPositionRef(sellerUid, startupId);
      const buyerTransactionRef = walletTransactionsRef(buyerUid).doc();
      const sellerTransactionRef = walletTransactionsRef(sellerUid).doc();

      const buyerWalletSnapshot = await transaction.get(buyerWalletRef);
      const sellerWalletSnapshot = await transaction.get(sellerWalletRef);
      const buyerPositionSnapshot = await transaction.get(buyerPositionRef);
      const sellerPositionSnapshot = await transaction.get(sellerPositionRef);

      const buyerBalance = buyerWalletSnapshot.exists ?
        numberOrZero(buyerWalletSnapshot.data()?.balance) : DEFAULT_INITIAL_BALANCE;
      if (buyerBalance < totalAmount) {
        throw new Error("INSUFFICIENT_BALANCE");
      }

      const sellerQuantity = sellerPositionSnapshot.exists ?
        numberOrZero(sellerPositionSnapshot.data()?.quantity) : 0;
      const sellerInvested = sellerPositionSnapshot.exists ?
        numberOrZero(sellerPositionSnapshot.data()?.investedAmount) : 0;
      if (sellerQuantity < quantity) {
        throw new Error("INSUFFICIENT_POSITION");
      }

      const buyerCurrentQuantity = buyerPositionSnapshot.exists ?
        numberOrZero(buyerPositionSnapshot.data()?.quantity) : 0;
      const buyerCurrentInvested = buyerPositionSnapshot.exists ?
        numberOrZero(buyerPositionSnapshot.data()?.investedAmount) : 0;
      const nextBuyerQuantity = buyerCurrentQuantity + quantity;
      const nextBuyerInvested = roundMoney(buyerCurrentInvested + totalAmount);
      const nextBuyerAverage = nextBuyerQuantity > 0 ?
        roundMoney(nextBuyerInvested / nextBuyerQuantity) : 0;

      const remainingSellerQuantity = sellerQuantity - quantity;
      const remainingSellerInvested = remainingSellerQuantity > 0 ?
        roundMoney((sellerInvested / sellerQuantity) * remainingSellerQuantity) : 0;
      const remainingSellerAverage = remainingSellerQuantity > 0 ?
        roundMoney(remainingSellerInvested / remainingSellerQuantity) : 0;

      const buyerWalletPayload: WalletDocument = {
        uid: buyerUid,
        balance: roundMoney(buyerBalance - totalAmount),
        createdAt: buyerWalletSnapshot.exists ?
          (buyerWalletSnapshot.data()?.createdAt as admin.firestore.Timestamp) ?? now : now,
        updatedAt: now,
      };
      const sellerWalletPayload: WalletDocument = {
        uid: sellerUid,
        balance: roundMoney(
          (sellerWalletSnapshot.exists ?
            numberOrZero(sellerWalletSnapshot.data()?.balance) : DEFAULT_INITIAL_BALANCE) + totalAmount,
        ),
        createdAt: sellerWalletSnapshot.exists ?
          (sellerWalletSnapshot.data()?.createdAt as admin.firestore.Timestamp) ?? now : now,
        updatedAt: now,
      };

      transaction.set(buyerWalletRef, buyerWalletPayload, {merge: true});
      transaction.set(sellerWalletRef, sellerWalletPayload, {merge: true});

      const buyerPositionPayload: PositionDocument = {
        startupId,
        startupName,
        quantity: nextBuyerQuantity,
        averagePrice: nextBuyerAverage,
        investedAmount: nextBuyerInvested,
        updatedAt: now,
      };
      transaction.set(buyerPositionRef, buyerPositionPayload, {merge: true});

      if (remainingSellerQuantity <= 0) {
        transaction.delete(sellerPositionRef);
      } else {
        const sellerPositionPayload: PositionDocument = {
          startupId,
          startupName,
          quantity: remainingSellerQuantity,
          averagePrice: remainingSellerAverage,
          investedAmount: remainingSellerInvested,
          updatedAt: now,
        };
        transaction.set(sellerPositionRef, sellerPositionPayload, {merge: true});
      }

      const buyerTxPayload: TransactionDocument = {
        type: "BUY",
        startupId,
        startupName,
        quantity,
        unitPrice: pricePerToken,
        amount: totalAmount,
        createdAt: now,
        metadata: {operation: "market_offer_fill", offerId, counterpartyUid: sellerUid},
      };
      const sellerTxPayload: TransactionDocument = {
        type: "SELL",
        startupId,
        startupName,
        quantity,
        unitPrice: pricePerToken,
        amount: totalAmount,
        createdAt: now,
        metadata: {operation: "market_offer_fill", offerId, counterpartyUid: buyerUid},
      };
      transaction.set(buyerTransactionRef, buyerTxPayload);
      transaction.set(sellerTransactionRef, sellerTxPayload);

      transaction.set(offerReference, {
        status: "FILLED",
        updatedAt: now,
        filledAt: now,
        matchedBy: takerUid,
      }, {merge: true});
    });

    res.status(200).json({message: "Oferta executada com sucesso"});
  } catch (error) {
    const message = error instanceof Error ? error.message : "UNKNOWN";
    if (message === "NOT_FOUND") {
      res.status(404).json({error: "Oferta nao encontrada"});
      return;
    }
    if (message === "INVALID_STATUS") {
      res.status(400).json({error: "A oferta nao esta ativa"});
      return;
    }
    if (message === "INVALID_OFFER") {
      res.status(400).json({error: "Oferta invalida"});
      return;
    }
    if (message === "SELF_TRADE") {
      res.status(400).json({error: "Nao e permitido aceitar a propria oferta"});
      return;
    }
    if (message === "INSUFFICIENT_BALANCE") {
      res.status(400).json({error: "Saldo insuficiente para aceitar oferta"});
      return;
    }
    if (message === "INSUFFICIENT_POSITION") {
      res.status(400).json({error: "Quantidade indisponivel para aceitar oferta"});
      return;
    }
    res.status(500).json({error: "Falha ao executar oferta"});
  }
});

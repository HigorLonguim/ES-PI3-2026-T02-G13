// Autoria: Felipe Sousa - RA: 22018160
import * as admin from "firebase-admin";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {db} from "../shared/firebase";

type StartupDoc = {
  capital_aportado?: unknown;
  tokens_emitidos?: unknown;
  token_preco_atual?: unknown;
  token_historico?: unknown;
};

function toNumber(value: unknown): number {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }
  return 0;
}

function roundMoney(value: number): number {
  return Math.round(value * 100) / 100;
}

function randomPercentVariation(): number {
  return Number((Math.random() * 8 - 4).toFixed(2));
}

export const rebalanceStartupTokenPrices = onSchedule(
  {
    schedule: "every 1 minutes",
    timeZone: "America/Sao_Paulo",
  },
  async () => {
    const startupsSnapshot = await db.collection("startups").where("status", "==", "Ativa").get();

    const updates = startupsSnapshot.docs.map(async (doc) => {
      const data = doc.data() as StartupDoc;
      const totalTokens = toNumber(data.tokens_emitidos);
      if (totalTokens <= 0) {
        return;
      }

      const currentPriceRaw = toNumber(data.token_preco_atual);
      const fallbackPrice = toNumber(data.capital_aportado) / totalTokens;
      const currentPrice = currentPriceRaw > 0 ? currentPriceRaw : fallbackPrice;
      if (currentPrice <= 0) {
        return;
      }

      const variationPercent = randomPercentVariation();
      const nextPrice = roundMoney(currentPrice * (1 + variationPercent / 100));
      const historicalRaw = Array.isArray(data.token_historico) ? data.token_historico : [];
      const historical = historicalRaw
        .map((entry) => {
          if (typeof entry === "object" && entry !== null && "price" in entry) {
            const price = (entry as {price?: unknown}).price;
            return typeof price === "number" && Number.isFinite(price) ? entry : null;
          }
          if (typeof entry === "number" && Number.isFinite(entry)) {
            return {price: entry, createdAt: admin.firestore.Timestamp.now()};
          }
          return null;
        })
        .filter((entry): entry is {price: number; createdAt: admin.firestore.Timestamp} => entry !== null)
        .slice(-47);

      historical.push({price: nextPrice, createdAt: admin.firestore.Timestamp.now()});

      const nextCapital = roundMoney(nextPrice * totalTokens);
      await doc.ref.set(
        {
          token_preco_atual: nextPrice,
          token_variacao_percentual: variationPercent,
          token_historico: historical,
          capital_aportado: nextCapital,
          token_atualizado_em: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true},
      );
    });

    await Promise.all(updates);
  },
);


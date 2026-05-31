// Autoria: Felipe Sousa - RA: 22018160
import { db } from "../config/firebase";

export interface Startup {
  id_startup: number;
  nome_startup: string;
  descricao: string;
  estagio: "Nova" | "Operacao" | "Expansao";
  setor: string;
  capital_aportado: number;
  tokens_emitidos: number;
  socios: string;
  participacao_societaria: string;
  mentores_conselho: string;
  video_demo: string;
  perguntas_publicas: StartupPublicQaItem[];
  status: "Ativa" | "Inativa";
  token_preco_atual: number;
  token_variacao_percentual: number;
  token_historico: number[];
}

export interface StartupPublicQaItem {
  question: string;
  answer: string;
}

function toNumber(value: unknown): number {
  if (typeof value === "number") {
    return value;
  }

  if (typeof value === "string") {
    const parsed = Number(value);
    if (!Number.isNaN(parsed)) {
      return parsed;
    }
  }

  return 0;
}

function toString(value: unknown): string {
  return typeof value === "string" ? value : "";
}

function toPublicQaItems(value: unknown): StartupPublicQaItem[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .filter((item): item is Record<string, unknown> => typeof item === "object" && item !== null)
    .map((item) => ({
      question: toString(item.question).trim(),
      answer: toString(item.answer).trim(),
    }))
    .filter((item) => item.question.length > 0 || item.answer.length > 0);
}

function toTokenHistory(value: unknown): number[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .map((entry) => {
      if (typeof entry === "number" && Number.isFinite(entry) && entry > 0) {
        return entry;
      }
      if (
        typeof entry === "object" &&
        entry !== null &&
        "price" in entry &&
        Number.isFinite((entry as { price?: unknown }).price)
      ) {
        return Number((entry as { price?: unknown }).price);
      }
      return null;
    })
    .filter((entry): entry is number => entry !== null);
}

export async function listStartups(): Promise<Startup[]> {
  const snapshot = await db.collection("startups").orderBy("id_startup", "asc").get();

  return snapshot.docs.map((document) => {
    const data = document.data();

    return {
      id_startup: toNumber(data.id_startup),
      nome_startup: toString(data.nome_startup),
      descricao: toString(data.descricao),
      estagio: toString(data.estagio) as Startup["estagio"],
      setor: toString(data.setor),
      capital_aportado: toNumber(data.capital_aportado),
      tokens_emitidos: toNumber(data.tokens_emitidos),
      socios: toString(data.socios),
      participacao_societaria: toString(data.participacao_societaria),
      mentores_conselho: toString(data.mentores_conselho),
      video_demo: toString(data.video_demo),
      perguntas_publicas: toPublicQaItems(data.perguntas_publicas),
      status: toString(data.status) as Startup["status"],
      token_preco_atual: toNumber(data.token_preco_atual),
      token_variacao_percentual: toNumber(data.token_variacao_percentual),
      token_historico: toTokenHistory(data.token_historico),
    };
  });
}

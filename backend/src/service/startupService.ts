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
  status: "Ativa" | "Inativa";
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
      status: toString(data.status) as Startup["status"],
    };
  });
}

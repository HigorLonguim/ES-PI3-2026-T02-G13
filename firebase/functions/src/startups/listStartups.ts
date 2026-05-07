// Autoria: Felipe Sousa - RA: 22018160
import * as functions from "firebase-functions";
import {db} from "../shared/firebase";
import {handleMethodAndCors} from "../shared/http";

type StartupFirestore = {
  id_startup?: unknown;
  descricao?: unknown;
  estagio?: unknown;
  setor?: unknown;
  status?: unknown;
  nome_startup?: unknown;
  capital_aportado?: unknown;
  tokens_emitidos?: unknown;
  socios?: unknown;
  participacao_societaria?: unknown;
  mentores_conselho?: unknown;
  video_demo?: unknown;
  perguntas_publicas?: unknown;
};

type PublicQaItem = {
  question: string;
  answer: string;
};

type StartupItem = {
  id: string;
  name: string;
  description: string;
  stage: string;
  tokenValue: string;
  tokenPrice: number;
  variation: string;
  imageUrl: string;
  sector: string;
  totalTokens: number;
  raisedCapital: string;
  executiveSummary: string;
  founders: string;
  ownershipStructure: string;
  mentorsCouncil: string;
  demoVideoUrl: string;
  publicQaItems: PublicQaItem[];
};

const currencyFormatter = new Intl.NumberFormat("pt-BR", {
  style: "currency",
  currency: "BRL",
  minimumFractionDigits: 2,
});

const defaultPublicQaItemsByStartup: Record<string, PublicQaItem[]> = {
  ecoloop: [
    {
      question: "Qual e o principal uso do capital desta rodada?",
      answer: "Escalar operacao e tecnologia para novos condominios.",
    },
    {
      question: "Qual metrica de tracao a startup ja possui?",
      answer: "Clientes ativos em operacao piloto e crescimento recorrente.",
    },
  ],
  eduvibe: [
    {
      question: "Como a plataforma gera receita atualmente?",
      answer: "Modelo de assinatura para escolas e alunos premium.",
    },
    {
      question: "Qual e o diferencial frente a outras edtechs?",
      answer: "Personalizacao gamificada com trilhas adaptativas por perfil.",
    },
  ],
  vitaltrack: [
    {
      question: "Como e feita a validacao da solucao de saude?",
      answer: "Parcerias com clinicas e acompanhamento de profissionais.",
    },
    {
      question: "Qual mercado prioritario na expansao?",
      answer: "Instituicoes de cuidado e redes de atendimento geriatrico.",
    },
  ],
  agrosense: [
    {
      question: "Qual problema principal do agro a startup resolve?",
      answer: "Monitoramento de solo e decisao de irrigacao em tempo real.",
    },
    {
      question: "Como a solucao melhora o resultado do produtor?",
      answer: "Reduce perdas e otimiza produtividade com dados acionaveis.",
    },
  ],
  safepay: [
    {
      question: "Como a plataforma trata seguranca das transacoes?",
      answer: "Criptografia ponta a ponta e monitoramento antifraude.",
    },
    {
      question: "Qual e o foco comercial atual da startup?",
      answer: "Operacoes em ecossistemas fechados como campus e eventos.",
    },
  ],
};

const genericDefaultPublicQaItems: PublicQaItem[] = [
  {
    question: "Como o capital captado sera utilizado?",
    answer: "Expansao da operacao, produto e estrutura comercial.",
  },
  {
    question: "Qual e o principal diferencial competitivo da startup?",
    answer: "Execucao focada, especializacao no setor e eficiencia operacional.",
  },
];

function normalizeStartupKey(name: string): string {
  return name
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]/g, "");
}

function toOptionalString(value: unknown): string | null {
  return typeof value === "string" ? value.trim() : null;
}

function toPositiveNumber(value: unknown): number {
  if (typeof value !== "number" || Number.isNaN(value) || value < 0) {
    return 0;
  }

  return value;
}

function toPublicQaItems(value: unknown): PublicQaItem[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .filter(
      (item): item is Record<string, unknown> =>
        typeof item === "object" && item !== null,
    )
    .map((item) => ({
      question: toOptionalString(item.question) ?? "",
      answer: toOptionalString(item.answer) ?? "",
    }))
    .filter((item) => item.question.length > 0 || item.answer.length > 0);
}

function ensureAtLeastTwoPublicQaItems(
  startupName: string,
  currentItems: PublicQaItem[],
): PublicQaItem[] {
  const normalizedKey = normalizeStartupKey(startupName);
  const defaults =
    defaultPublicQaItemsByStartup[normalizedKey] ?? genericDefaultPublicQaItems;

  const combined = [...currentItems];
  for (const item of defaults) {
    if (combined.length >= 2) {
      break;
    }

    const alreadyExists = combined.some(
      (existing) =>
        existing.question.toLowerCase() === item.question.toLowerCase(),
    );
    if (!alreadyExists) {
      combined.push(item);
    }
  }

  return combined.slice(0, 2);
}

function mapStage(rawStage: string | null): string {
  switch ((rawStage ?? "").toLowerCase()) {
    case "operacao":
    case "operaÃ§Ã£o":
      return "Operacao";
    case "expansao":
    case "expansÃ£o":
      return "Expansao";
    default:
      return "Nova";
  }
}

function buildStartupItem(
  id: string,
  payload: StartupFirestore,
  index: number,
): StartupItem {
  const name = toOptionalString(payload.nome_startup) ?? `Startup ${index + 1}`;
  const description = toOptionalString(payload.descricao) ?? "Sem descricao";
  const stage = mapStage(toOptionalString(payload.estagio));
  const sector = toOptionalString(payload.setor) ?? "Nao informado";
  const totalTokens = toPositiveNumber(payload.tokens_emitidos);
  const raisedCapitalValue = toPositiveNumber(payload.capital_aportado);
  const tokenPrice = totalTokens > 0 ? raisedCapitalValue / totalTokens : 0;
  const founders = toOptionalString(payload.socios) ?? "";
  const ownershipStructure =
    toOptionalString(payload.participacao_societaria) ?? "";
  const mentorsCouncil = toOptionalString(payload.mentores_conselho) ?? "";
  const demoVideoUrl = toOptionalString(payload.video_demo) ?? "";
  const publicQaItems = ensureAtLeastTwoPublicQaItems(
    name,
    toPublicQaItems(payload.perguntas_publicas),
  );

  return {
    id,
    name,
    description,
    stage,
    tokenValue: currencyFormatter.format(tokenPrice),
    tokenPrice,
    variation: "+0.00%",
    imageUrl: `https://picsum.photos/seed/${id}/400/400`,
    sector,
    totalTokens: Math.trunc(totalTokens),
    raisedCapital: currencyFormatter.format(raisedCapitalValue),
    executiveSummary: description,
    founders,
    ownershipStructure,
    mentorsCouncil,
    demoVideoUrl,
    publicQaItems,
  };
}

function startupSortOrder(payload: StartupFirestore): number {
  if (typeof payload.id_startup === "number" && payload.id_startup >= 0) {
    return payload.id_startup;
  }

  return Number.MAX_SAFE_INTEGER;
}

export const listStartups = functions.https.onRequest(async (req, res) => {
  if (handleMethodAndCors(req, res, "GET")) {
    return;
  }

  try {
    const snapshot = await db
      .collection("startups")
      .where("status", "==", "Ativa")
      .limit(50)
      .get();

    const orderedDocs = snapshot.docs
      .map((doc) => ({
        id: doc.id,
        data: doc.data() as StartupFirestore,
      }))
      .sort(
        (left, right) => startupSortOrder(left.data) - startupSortOrder(right.data),
      );

    const items = orderedDocs.map((doc, index) =>
      buildStartupItem(doc.id, doc.data, index),
    );

    res.status(200).json({items});
  } catch (error: unknown) {
    const message =
      error instanceof Error ? error.message : "Falha ao listar startups";
    res.status(500).json({message});
  }
});


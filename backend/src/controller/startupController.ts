// Autoria: Felipe Sousa - RA: 22018160
import { Request, Response } from "express";
import { listStartups, type Startup } from "../service/startupService";

type StartupItem = {
  id: string;
  name: string;
  description: string;
  stage: "Nova" | "Operacao" | "Expansao";
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
  publicQaItems: { question: string; answer: string }[];
  tokenHistory: number[];
};

const currencyFormatter = new Intl.NumberFormat("pt-BR", {
  style: "currency",
  currency: "BRL",
  minimumFractionDigits: 2,
});

function mapStartupToItem(startup: Startup): StartupItem {
  const fallbackTokenPrice = startup.tokens_emitidos > 0
    ? startup.capital_aportado / startup.tokens_emitidos
    : 0;
  const tokenPrice = startup.token_preco_atual > 0
    ? startup.token_preco_atual
    : fallbackTokenPrice;
  const variation = resolveVariationText(
    startup.token_historico,
    startup.token_variacao_percentual,
  );

  return {
    id: String(startup.id_startup),
    name: startup.nome_startup,
    description: startup.descricao,
    stage: startup.estagio,
    tokenValue: currencyFormatter.format(tokenPrice),
    tokenPrice,
    variation,
    imageUrl: `https://picsum.photos/seed/${startup.id_startup}/400/400`,
    sector: startup.setor,
    totalTokens: startup.tokens_emitidos,
    raisedCapital: currencyFormatter.format(startup.capital_aportado),
    executiveSummary: startup.descricao,
    founders: startup.socios,
    ownershipStructure: startup.participacao_societaria,
    mentorsCouncil: startup.mentores_conselho,
    demoVideoUrl: startup.video_demo,
    publicQaItems: startup.perguntas_publicas,
    tokenHistory: startup.token_historico,
  };
}

function resolveVariationText(
  tokenHistory: number[],
  fallbackVariation: number,
): string {
  if (tokenHistory.length >= 2) {
    const previous = tokenHistory[tokenHistory.length - 2];
    const current = tokenHistory[tokenHistory.length - 1];
    if (previous > 0) {
      const percent = ((current - previous) / previous) * 100;
      return percent >= 0 ? `+${percent.toFixed(2)}%` : `${percent.toFixed(2)}%`;
    }
  }

  if (Number.isFinite(fallbackVariation)) {
    return fallbackVariation >= 0
      ? `+${fallbackVariation.toFixed(2)}%`
      : `${fallbackVariation.toFixed(2)}%`;
  }

  return "+0.00%";
}

export async function list(_req: Request, res: Response) {
  try {
    const startups = await listStartups();
    const items = startups.map(mapStartupToItem);

    return res.status(200).json({
      total: items.length,
      items,
      startups,
    });
  } catch (error) {
    console.error("Erro ao listar startups no Firestore:", error);
    return res.status(500).json({
      erro: "Nao foi possivel listar as startups.",
    });
  }
}

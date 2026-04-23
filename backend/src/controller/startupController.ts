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
};

const currencyFormatter = new Intl.NumberFormat("pt-BR", {
  style: "currency",
  currency: "BRL",
  minimumFractionDigits: 2,
});

function mapStartupToItem(startup: Startup): StartupItem {
  const tokenPrice = startup.tokens_emitidos > 0
    ? startup.capital_aportado / startup.tokens_emitidos
    : 0;

  return {
    id: String(startup.id_startup),
    name: startup.nome_startup,
    description: startup.descricao,
    stage: startup.estagio,
    tokenValue: currencyFormatter.format(tokenPrice),
    tokenPrice,
    variation: "+0.00%",
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
  };
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

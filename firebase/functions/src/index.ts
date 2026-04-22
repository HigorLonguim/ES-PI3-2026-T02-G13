// Autoria: Felipe Sousa - RA: 22018160
import * as admin from "firebase-admin";
import type {Response as ExpressResponse} from "express";
import * as functions from "firebase-functions";
import * as helperCpf from "./Helpers/helperCpf";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();
const currencyFormatter = new Intl.NumberFormat("pt-BR", {
  style: "currency",
  currency: "BRL",
  minimumFractionDigits: 2,
});

function setCorsHeaders(
  res: ExpressResponse<unknown>,
  allowedMethods: string,
): void {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", allowedMethods);
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
}

function handleMethodAndCors(
  req: functions.https.Request,
  res: ExpressResponse<unknown>,
  allowedMethod: "GET" | "POST",
): boolean {
  setCorsHeaders(res, `${allowedMethod},OPTIONS`);

  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return true;
  }

  if (req.method !== allowedMethod) {
    res.status(405).json({error: "Metodo invalido"});
    return true;
  }

  return false;
}

function isNonEmptyString(value: unknown): value is string {
  return typeof value === "string" && value.trim().length > 0;
}

function normalizeEmail(email: string): string {
  return email.trim().toLowerCase();
}

export const registerUser = functions.https.onRequest(async (req, res) => {
  if (handleMethodAndCors(req, res, "POST")) {
    return;
  }

  const {email, nome, cpf, senha, telefone} = req.body as Record<
    string,
    unknown
  >;

  if (
    !isNonEmptyString(email) ||
    !isNonEmptyString(nome) ||
    !isNonEmptyString(senha) ||
    !isNonEmptyString(cpf) ||
    !isNonEmptyString(telefone)
  ) {
    res.status(400).json({message: "Dados obrigatorios faltando"});
    return;
  }

  if (!helperCpf.validarCPF(cpf)) {
    res.status(400).json({message: "CPF invalido"});
    return;
  }

  const normalizedEmail = normalizeEmail(email);

  try {
    const userRecord = await admin.auth().createUser({
      email: normalizedEmail,
      password: senha,
    });

    await db.collection("users").doc(userRecord.uid).set({
      uid: userRecord.uid,
      nome: nome.trim(),
      email: normalizedEmail,
      cpf: cpf.trim(),
      telefone: telefone.trim(),
      createdAt: new Date(),
    });

    res.status(200).json({
      message: "Usuario criado com sucesso",
      uid: userRecord.uid,
    });
  } catch (error: unknown) {
    const message =
      error instanceof Error ? error.message : "Falha ao criar usuario";
    res.status(500).json({message});
  }
});

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
};

function toOptionalString(value: unknown): string | null {
  return typeof value === "string" ? value.trim() : null;
}

function toPositiveNumber(value: unknown): number {
  if (typeof value !== "number" || Number.isNaN(value) || value < 0) {
    return 0;
  }

  return value;
}

function mapStage(rawStage: string | null): string {
  switch ((rawStage ?? "").toLowerCase()) {
    case "operacao":
    case "operação":
      return "Operacao";
    case "expansao":
    case "expansão":
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
  const ownershipStructure = toOptionalString(payload.participacao_societaria) ?? "";
  const mentorsCouncil = toOptionalString(payload.mentores_conselho) ?? "";
  const demoVideoUrl = toOptionalString(payload.video_demo) ?? "";

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
      .sort((left, right) => startupSortOrder(left.data) - startupSortOrder(right.data));

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

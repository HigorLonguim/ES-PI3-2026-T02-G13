// Autoria: Felipe Sousa - RA: 22018160
import { Request, Response } from "express";
import { listStartups } from "../service/startupService";

export async function list(_req: Request, res: Response) {
  try {
    const startups = await listStartups();

    return res.status(200).json({
      total: startups.length,
      startups,
    });
  } catch (error) {
    console.error("Erro ao listar startups no Firestore:", error);
    return res.status(500).json({
      erro: "Nao foi possivel listar as startups.",
    });
  }
}

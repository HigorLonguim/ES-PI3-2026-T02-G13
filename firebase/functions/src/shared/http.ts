// Autoria: Felipe Sousa - RA: 22018160
import type {Response as ExpressResponse} from "express";
import * as functions from "firebase-functions";

function setCorsHeaders(
  res: ExpressResponse<unknown>,
  allowedMethods: string,
): void {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", allowedMethods);
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
}

export function handleMethodAndCors(
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


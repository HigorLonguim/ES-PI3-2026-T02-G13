// Autoria: Felipe Sousa - RA: 22018160
import "dotenv/config";
import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";
import admin from "firebase-admin";
import type { Auth } from "firebase-admin/auth";

type ServiceAccountFromJson = {
  project_id?: string;
  client_email?: string;
  private_key?: string;
};

function normalizePrivateKey(privateKey: string): string {
  return privateKey.replace(/\\n/g, "\n");
}

function loadCredentialsFromEnv():
  | { projectId: string; clientEmail: string; privateKey: string }
  | null {
  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = process.env.FIREBASE_PRIVATE_KEY;

  if (!projectId || !clientEmail || !privateKey) {
    return null;
  }

  return {
    projectId,
    clientEmail,
    privateKey: normalizePrivateKey(privateKey),
  };
}

function loadCredentialsFromJson():
  | { projectId: string; clientEmail: string; privateKey: string }
  | null {
  const configuredPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH?.trim();
  const jsonPath = configuredPath && configuredPath.length > 0
    ? resolve(process.cwd(), configuredPath)
    : resolve(process.cwd(), "mescla-invest.json");

  if (!existsSync(jsonPath)) {
    return null;
  }

  const rawContent = readFileSync(jsonPath, "utf-8");
  const parsed = JSON.parse(rawContent) as ServiceAccountFromJson;

  if (!parsed.project_id || !parsed.client_email || !parsed.private_key) {
    throw new Error("Arquivo de service account invalido: faltam campos obrigatorios.");
  }

  return {
    projectId: parsed.project_id,
    clientEmail: parsed.client_email,
    privateKey: normalizePrivateKey(parsed.private_key),
  };
}

const firebaseCredentials = loadCredentialsFromJson() ?? loadCredentialsFromEnv();

if (!firebaseCredentials) {
  throw new Error(
    "Credenciais do Firebase nao configuradas. Configure FIREBASE_SERVICE_ACCOUNT_PATH (JSON) ou FIREBASE_PROJECT_ID/FIREBASE_CLIENT_EMAIL/FIREBASE_PRIVATE_KEY."
  );
}

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: firebaseCredentials.projectId,
      clientEmail: firebaseCredentials.clientEmail,
      privateKey: firebaseCredentials.privateKey,
    }),
  });
}

export const db = admin.firestore();
export const auth: Auth = admin.auth();
export default admin;

// Autoria: Felipe Sousa - RA: 22018160
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import {db} from "../shared/firebase";
import {handleMethodAndCors} from "../shared/http";

function parseBearerToken(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();
  if (!trimmed.toLowerCase().startsWith("bearer ")) {
    return null;
  }

  const token = trimmed.slice("bearer ".length).trim();
  return token.length > 0 ? token : null;
}

export const getUserProfile = functions.https.onRequest(async (req, res) => {
  if (handleMethodAndCors(req, res, "GET")) {
    return;
  }

  const token = parseBearerToken(req.headers.authorization);
  if (!token) {
    res.status(401).json({error: "Token de autenticacao ausente"});
    return;
  }

  try {
    const decoded = await admin.auth().verifyIdToken(token);
    if (!decoded.uid) {
      res.status(401).json({error: "Token invalido"});
      return;
    }

    const snapshot = await db.collection("users").doc(decoded.uid).get();
    if (!snapshot.exists) {
      res.status(404).json({error: "Perfil de usuario nao encontrado"});
      return;
    }

    const data = snapshot.data() ?? {};
    res.status(200).json({
      usuario: {
        uid: decoded.uid,
        id: decoded.uid,
        nome: String(data.nome ?? ""),
        email: String(data.email ?? decoded.email ?? ""),
        cpf: String(data.cpf ?? ""),
        telefone: String(data.telefone ?? ""),
      },
    });
  } catch (_error) {
    res.status(401).json({error: "Token invalido"});
  }
});

// Autoria: Felipe Sousa - RA: 22018160
import * as functions from "firebase-functions";
import * as helperCpf from "../Helpers/helperCpf";
import {db, auth} from "../shared/firebase";
import {handleMethodAndCors} from "../shared/http";

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
    const userRecord = await auth.createUser({
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


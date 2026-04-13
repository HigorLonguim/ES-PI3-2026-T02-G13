import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as helperCpf from "./Helpers/helperCpf";

admin.initializeApp();
const db = admin.firestore();

export const registerUser = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") {
        res.status(405).send("Método inválido");
        return;
  }

  const { email, nome, cpf, senha, telefone } = req.body;

  if (!email || !nome || !senha || !cpf || !telefone) {
        res.status(400).send("Dados obrigatórios faltando");
        return;
  }

  if (!helperCpf.validarCPF(cpf)) {
        res.status(400).send("CPF inválido");
        return;
  }

  try {
    const userRecord = await admin.auth().createUser({
      email,
      password: senha,
    });

    await db.collection("users").doc(userRecord.uid).set({
        uid: userRecord.uid,
        nome,
        email,
        cpf,
        telefone,
        createdAt: new Date(),
    });

        res.status(200).send({
        message: "Usuário criado com sucesso",
        uid: userRecord.uid,
    });

  } catch (error: any) {
        res.status(500).send(error.message);
  };
  return;
});
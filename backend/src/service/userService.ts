import { db } from "../config/firebase";
import { Router } from "express";
import * as userController from "../controller/userController";

interface Usuario {
  id: string;
  nome: string;
  email: string;
  cpf: string;
  telefone: string;
  senha: string;
}

function isValidString(value: unknown): value is string {
  return typeof value === "string" && value.trim().length > 0;
}

export async function registerUser(dados: any) {

  if (!isValidString(dados?.nome) || !isValidString(dados?.email) || !isValidString(dados?.cpf) || !isValidString(dados?.telefone) || !isValidString(dados?.senha)) {
    return { erro: "Nome, email, cpf, telefone e senha são obrigatórios" };
  }

  const nome = dados.nome.trim();
  const email = dados.email.trim().toLowerCase();
  const cpf = dados.cpf.trim();
  const telefone = dados.telefone.trim();
  const senha = dados.senha;

  console.log("[userService.registerUser] iniciando cadastro", { nome, email, cpf, telefone });

  const emailSnapshot = await db.collection("users").where("email", "==", email).limit(1).get();

  if (!emailSnapshot.empty) {
    console.log("[userService.registerUser] email já cadastrado", { email });
    return { erro: "Email já cadastrado" };
  }

  const novoUsuario = {
    nome,
    email,
    cpf,
    telefone,
    senha,
    createdAt: new Date().toISOString(),
  };

  console.log("[userService.registerUser] salvando no Firestore", novoUsuario);

  try {
    const docRef = await db.collection("users").add(novoUsuario);

    const usuario: Usuario = {
      id: docRef.id,
      nome,
      email,
      cpf,
      telefone,
      senha,
    };

    console.log("[userService.registerUser] usuário salvo no Firestore", {
      id: docRef.id,
      nome,
      email,
      cpf,
      telefone,
    });

    return {
      mensagem: "Usuário cadastrado",
      usuario,
    };
  } catch (error) {
    console.error("[userService.registerUser] erro ao cadastrar usuário", error);
    return { erro: "Erro ao cadastrar usuário" };
  }
}

export async function loginUser(email: string, senha: string) {

  if (!isValidString(email) || !isValidString(senha)) {
    return { erro: "Email e senha são obrigatórios" };
  }

  const normalizedEmail = email.trim().toLowerCase();

  console.log("[userService.loginUser] iniciando login", { email: normalizedEmail });

  const snapshot = await db.collection("users").where("email", "==", normalizedEmail).limit(1).get();

  if (snapshot.empty) {
    console.log("[userService.loginUser] usuário não encontrado", { email: normalizedEmail });
    return { erro: "Usuário não encontrado" };
  }

  const document = snapshot.docs[0];
  const data = document.data();

  if (data.senha !== senha) {
    console.log("[userService.loginUser] senha inválida", { email: normalizedEmail });
    return { erro: "Senha inválida" };
  }

  const usuario: Usuario = {
    id: document.id,
    nome: String(data.nome ?? ""),
    email: String(data.email ?? ""),
    cpf: String(data.cpf ?? ""),
    telefone: String(data.telefone ?? ""),
    senha: String(data.senha ?? ""),
  };

  console.log("[userService.loginUser] login realizado", { id: usuario.id, email: usuario.email, cpf: usuario.cpf, telefone: usuario.telefone });

  return {
    mensagem: "Login realizado",
    usuario,
  };
}

export async function recoverPassword(email: string) {
  if (!isValidString(email)) {
    return { erro: "Email é obrigatório" };
  }

  const normalizedEmail = email.trim().toLowerCase();

  console.log("[userService.recoverPassword] solicitacao recebida", { email: normalizedEmail });

  try {
    const snapshot = await db.collection("users").where("email", "==", normalizedEmail).limit(1).get();
    const userExists = !snapshot.empty;

    if (userExists) {
      console.log("[userService.recoverPassword] usuario encontrado", { email: normalizedEmail });
      return {
        mensagem: "Se o e-mail estiver cadastrado, enviaremos as instruções de recuperação.",
        status: 202,
      };
    }

    console.log("[userService.recoverPassword] usuario nao encontrado", { email: normalizedEmail });
    return {
      mensagem: "Se o e-mail estiver cadastrado, enviaremos as instruções de recuperação.",
      status: 200,
    };
  } catch (error) {
    console.error("[userService.recoverPassword] erro ao buscar usuario", error);
    return { erro: "Erro ao processar recuperação de senha." };
  }
}

const router = Router();

router.post("/register", userController.register);
router.post("/login", userController.login);
router.post("/recover-password", userController.recoverPassword);

export default router;
import { Request, Response } from "express";
import * as userService from "../service/userService";

export async function register(req: Request, res: Response) {

  const dados = req.body;
  console.log("[userController.register] dados recebidos", dados);

  try {
    const usuario = await userService.registerUser(dados);

    if (usuario.erro) {
      return res.status(400).json(usuario);
    }

    return res.status(201).json(usuario);
  } catch (error) {
    console.error("[userController.register] erro inesperado", error);
    return res.status(500).json({ erro: "Erro interno ao cadastrar usuario." });
  }
}

export async function login(req: Request, res: Response) {

  const { email, senha } = req.body;

  try {
    const resultado = await userService.loginUser(email, senha);

    if (resultado.erro) {
      return res.status(401).json(resultado);
    }

    return res.json(resultado);
  } catch (error) {
    console.error("[userController.login] erro inesperado", error);
    return res.status(500).json({ erro: "Erro interno ao efetuar login." });
  }
}
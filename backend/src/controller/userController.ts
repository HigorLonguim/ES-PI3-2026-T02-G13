import { Request, Response } from "express";
import * as userService from "../service/userService";

export function register(req: Request, res: Response) {

  const dados = req.body;

  const usuario = userService.registerUser(dados);

  if (usuario.erro) {
    return res.status(400).json(usuario);
  }

  return res.status(201).json(usuario);
}

export function login(req: Request, res: Response) {

  const { email, senha } = req.body;

  const resultado = userService.loginUser(email, senha);

  if (resultado.erro) {
    return res.status(401).json(resultado);
  }

  return res.json(resultado);
}
interface Usuario {
  id: number
  nome: string
  email: string
  senha: string
}

const usuarios: Usuario[] = [];

export function registerUser(dados: any) {

  if (!dados.nome || !dados.email || !dados.senha) {
    return { erro: "Nome, email e senha são obrigatórios" };
  }

  const usuarioExistente = usuarios.find(u => u.email === dados.email);

  if (usuarioExistente) {
    return { erro: "Email já cadastrado" };
  }

  const novoUsuario: Usuario = {
    id: usuarios.length + 1,
    nome: dados.nome,
    email: dados.email,
    senha: dados.senha
  };

  usuarios.push(novoUsuario);

  return {
    mensagem: "Usuário cadastrado",
    usuario: novoUsuario
  };
}

export function loginUser(email: string, senha: string) {

  const usuario = usuarios.find(u => u.email === email);

  if (!usuario) {
    return { erro: "Usuário não encontrado" };
  }

  if (usuario.senha !== senha) {
    return { erro: "Senha inválida" };
  }

  return {
    mensagem: "Login realizado",
    usuario
  };
}
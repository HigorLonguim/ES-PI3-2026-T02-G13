// Autoria: Felipe Sousa - RA: 22018160
import { db } from "../src/config/firebase";
import { FieldValue } from "firebase-admin/firestore";

type Startup = {
  id_startup: number;
  nome_startup: string;
  descricao: string;
  estagio: "Nova" | "Operacao" | "Expansao";
  setor: string;
  capital_aportado: number;
  tokens_emitidos: number;
  socios: string;
  participacao_societaria: string;
  mentores_conselho: string;
  video_demo: string;
  perguntas_publicas: { question: string; answer: string }[];
  status: "Ativa" | "Inativa";
};

const startupsSeed: Startup[] = [
  {
    id_startup: 1,
    nome_startup: "EcoLoop",
    descricao: "Logistica reversa inteligente para condominios.",
    estagio: "Nova",
    setor: "Cleantech",
    capital_aportado: 150000,
    tokens_emitidos: 100000,
    socios: "Ana Silva; Roberto Costa",
    participacao_societaria: "60%; 40%",
    mentores_conselho: "Dr. Marcos Neves",
    video_demo:
      "https://firebasestorage.googleapis.com/v0/b/pi3-mescla-invest.firebasestorage.app/o/Video%20Ecoloop.mp4?alt=media&token=0cd4b2e2-e175-4a61-800f-2c85396784d0",
    perguntas_publicas: [
      {
        question: "Qual o foco do uso do capital nesta rodada?",
        answer: "Escalar operacao e reforcar produto para novos condominios.",
      },
      {
        question: "Ja existem clientes ativos?",
        answer: "Sim, com contratos recorrentes em operacoes piloto.",
      },
    ],
    status: "Ativa",
  },
  {
    id_startup: 2,
    nome_startup: "EduVibe",
    descricao: "Plataforma de aprendizado gamificado para o ENEM.",
    estagio: "Operacao",
    setor: "Edtech",
    capital_aportado: 450000,
    tokens_emitidos: 300000,
    socios: "Julia Mendes; Lucas Porto",
    participacao_societaria: "50%; 50%",
    mentores_conselho: "Prof. Elena Souza",
    video_demo:
      "https://firebasestorage.googleapis.com/v0/b/pi3-mescla-invest.firebasestorage.app/o/Video%20EduVibe.mp4?alt=media&token=83d55191-bd69-4376-9b4a-3f09bceef92f",
    perguntas_publicas: [
      {
        question: "Qual e o principal diferencial de aprendizagem?",
        answer: "Gamificacao com trilhas personalizadas por desempenho.",
      },
    ],
    status: "Ativa",
  },
  {
    id_startup: 3,
    nome_startup: "VitalTrack",
    descricao: "Pulseiras inteligentes para monitoramento de idosos.",
    estagio: "Expansao",
    setor: "Healthtech",
    capital_aportado: 1200000,
    tokens_emitidos: 500000,
    socios: "Ricardo Gomes; Sarah Oliveira",
    participacao_societaria: "70%; 30%",
    mentores_conselho: "Dr. Jorge Amado",
    video_demo:
      "https://firebasestorage.googleapis.com/v0/b/pi3-mescla-invest.firebasestorage.app/o/Video%20VitalTrack.mp4?alt=media&token=9a05323a-7e64-4f43-9460-72b754888df7",
    perguntas_publicas: [
      {
        question: "Como funciona a validacao com profissionais de saude?",
        answer: "Protocolos com clinicas parceiras e acompanhamento medico.",
      },
    ],
    status: "Ativa",
  },
  {
    id_startup: 4,
    nome_startup: "AgroSense",
    descricao: "Monitoramento de solo em tempo real via IoT.",
    estagio: "Operacao",
    setor: "Agrotech",
    capital_aportado: 800000,
    tokens_emitidos: 400000,
    socios: "Mateus Lima; Fabio Santos",
    participacao_societaria: "55%; 45%",
    mentores_conselho: "Ingrid Ferreira",
    video_demo:
      "https://firebasestorage.googleapis.com/v0/b/pi3-mescla-invest.firebasestorage.app/o/Video%20AgroSense.mp4?alt=media&token=466ba0ee-bfc2-4579-b602-033d14fae243",
    perguntas_publicas: [
      {
        question: "A solucao ja foi testada em campo?",
        answer: "Sim, em fazendas parceiras com melhoria de produtividade.",
      },
    ],
    status: "Ativa",
  },
  {
    id_startup: 5,
    nome_startup: "SafePay",
    descricao: "Carteira digital para micro-transacoes em campus.",
    estagio: "Nova",
    setor: "Fintech",
    capital_aportado: 200000,
    tokens_emitidos: 150000,
    socios: "Beatriz Nunes; Igor Rocha",
    participacao_societaria: "80%; 20%",
    mentores_conselho: "Samuel Prado",
    video_demo:
      "https://firebasestorage.googleapis.com/v0/b/pi3-mescla-invest.firebasestorage.app/o/Video%20SafePay.mp4?alt=media&token=0b92b6f4-8584-486c-8094-8a085eaf3233",
    perguntas_publicas: [
      {
        question: "Como e tratada a seguranca das transacoes?",
        answer: "Criptografia ponta a ponta e monitoramento antifraude.",
      },
    ],
    status: "Ativa",
  },
];

async function runSeed(): Promise<void> {
  const collectionRef = db.collection("startups");

  for (const startup of startupsSeed) {
    const existingSnapshot = await collectionRef
      .where("id_startup", "==", startup.id_startup)
      .limit(1)
      .get();

    if (!existingSnapshot.empty) {
      await existingSnapshot.docs[0].ref.set(
        {
          ...startup,
          ownership: FieldValue.delete(),
        },
        { merge: true }
      );
      continue;
    }

    await collectionRef.add(startup);
  }

  console.log(
    `Seed concluido com sucesso: ${startupsSeed.length} startups gravadas/atualizadas no Firestore.`
  );
}

runSeed()
  .then(() => process.exit(0))
  .catch((error: unknown) => {
    console.error("Erro ao executar seed de startups:", error);
    process.exit(1);
  });

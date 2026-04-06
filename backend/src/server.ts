import express from "express";
import userRoutes from "./routes/userRoutes";

// Autoria: Felipe Sousa - RA: 22018160
const app = express();
const PORT = 8080;
const isProduction = process.env.NODE_ENV === "production";

const devLocalhostOriginRegex = /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/;
const productionAllowedOrigins = new Set<string>([
  // Adicione aqui os domínios oficiais do frontend em produção.
  // Exemplo: "https://app.mesclainvest.com.br"
]);

function isAllowedOrigin(origin: string): boolean {
  if (!isProduction) {
    return devLocalhostOriginRegex.test(origin);
  }

  return productionAllowedOrigins.has(origin);
}

app.use((req, res, next) => {
  const origin = req.headers.origin;

  if (typeof origin === "string" && isAllowedOrigin(origin)) {
    res.header("Access-Control-Allow-Origin", origin);
    res.header("Vary", "Origin");
  }

  res.header("Access-Control-Allow-Methods", "GET,POST,PUT,PATCH,DELETE,OPTIONS");
  res.header("Access-Control-Allow-Headers", "Content-Type, Authorization");
  res.header("Access-Control-Allow-Credentials", "true");

  if (req.method === "OPTIONS") {
    return res.sendStatus(204);
  }

  next();
});

app.use(express.json());

app.get("/", (req, res) => {
  res.send("Backend rodando com sucesso!");
});

app.use("/users", userRoutes);

app.listen(PORT, () => {
  console.log(`Servidor rodando em http://localhost:${PORT}`);
});

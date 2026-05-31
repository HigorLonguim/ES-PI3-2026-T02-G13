import "dotenv/config";
import express from "express";
import "./config/firebase";
import startupRoutes from "./routes/startupRoutes";
import userRoutes from "./routes/userRoutes";

// Autoria: Felipe Sousa - RA: 22018160
const app = express();
const parsedPort = Number(process.env.PORT ?? 8080);
const PORT = Number.isInteger(parsedPort) && parsedPort > 0 ? parsedPort : 8080;
const isProduction = process.env.NODE_ENV === "production";
const allowLocalhostInDev =
  (process.env.CORS_ALLOW_LOCALHOST ?? "true").toLowerCase() !== "false";
const configuredAllowedOrigins = new Set(
  (process.env.CORS_ALLOWED_ORIGINS ?? "")
    .split(",")
    .map((origin) => origin.trim())
    .filter((origin) => origin.length > 0)
);

const devLocalhostOriginRegex = /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/;

function isAllowedOrigin(origin: string): boolean {
  if (configuredAllowedOrigins.has(origin)) {
    return true;
  }

  if (!isProduction && allowLocalhostInDev) {
    return devLocalhostOriginRegex.test(origin);
  }

  return false;
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

app.get("/", (_req, res) => {
  res.send("Backend rodando com sucesso!");
});

app.use("/startups", startupRoutes);
app.use("/users", userRoutes);

app.listen(PORT, () => {
  console.log(`Servidor rodando em http://localhost:${PORT}`);
});

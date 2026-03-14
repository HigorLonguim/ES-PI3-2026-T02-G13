import express from "express";
import userRoutes from "./routes/userRoutes";

const app = express();
const PORT = 8080;

app.use(express.json());

app.get("/", (req, res) => {
  res.send("Backend rodando com sucesso!");
});

app.use("/users", userRoutes);

app.listen(PORT, () => {
  console.log(`Servidor rodando em http://localhost:${PORT}`);
});
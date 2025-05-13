import express from "express";
import mongoose from "mongoose";
import dotenv from "dotenv";
import cors from "cors";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGODB_URI;

// Conectar ao MongoDB Atlas
mongoose.connect(MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(() => {
  console.log("✅ Conectado ao MongoDB Atlas");
}).catch((err) => {
  console.error("❌ Erro ao conectar no MongoDB:", err);
});

// Schema para máquina
const maquinaSchema = new mongoose.Schema({
  nome: String,
  patrimonio: String,
  setor: String,
  status: String,
  ultimaAtualizacao: { type: Date, default: Date.now }
});

const Maquina = mongoose.model("Maquina", maquinaSchema);

// Rota para criar máquina
app.post("/maquinas", async (req, res) => {
  try {
    const nova = new Maquina(req.body);
    const salva = await nova.save();
    res.status(201).json(salva);
  } catch (err) {
    res.status(500).json({ erro: "Erro ao salvar máquina." });
  }
});

// Rota para obter as 10 últimas máquinas
app.get("/maquinas", async (req, res) => {
  try {
    const maquinas = await Maquina.find().sort({ ultimaAtualizacao: -1 }).limit(10);
    res.json(maquinas);
  } catch (err) {
    res.status(500).json({ erro: "Erro ao buscar máquinas." });
  }
});

app.listen(PORT, () => {
  console.log(`🚀 Servidor rodando em http://localhost:${PORT}`);
});

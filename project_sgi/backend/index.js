import express from "express";
import mongoose from "mongoose";
import dotenv from "dotenv";
import cors from "cors";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// A variável PORT estava comentada, o que impedia o servidor de iniciar.
const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGODB_URI;

// Conectar ao MongoDB Atlas
mongoose.connect(MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(() => {
  console.log("Conectado ao MongoDB Atlas");
}).catch((err) => {
  console.error("Erro ao conectar no MongoDB:", err);
});

// Schema para máquina
const maquinaSchema = new mongoose.Schema({
  nome: String,
  patrimonio: String,
  predio: String,
  sala: String,
  monitor: String,
  modelo: String,
  processador: String,
  memoria: String,
  problema: String,
  observacoes: String,
  dataCadastro: { type: Date, default: Date.now },
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

// Rota maquinas com verificação
app.get("/maquinas", async (req, res) => {
  const { patrimonio } = req.query;
  try {
    if (patrimonio) {
      const maquinas = await Maquina.find({ patrimonio: { $regex: `^${patrimonio}`, $options: 'i' } }).limit(10);
      return res.json(maquinas);
    } else {
      const maquinas = await Maquina.find().sort({ ultimaAtualizacao: -1 }).limit(10);
      return res.json(maquinas);
    }
  } catch (err) {
    console.error("Erro ao buscar máquinas:", err);
    res.status(500).json({ erro: "Erro ao buscar máquinas." });
  }
});

// Rota para buscar máquinas por prédio (usada no mapa)
app.get("/maquinas/por-predio", async (req, res) => {
  const { nome } = req.query;

  if (!nome) {
    return res.status(400).json({ erro: "O parâmetro 'nome' do prédio é obrigatório." });
  }

  const numeroPredio = nome.replace(/^p/i, ''); 

  try {
    console.log(`Recebido: ${nome}. Buscando por prédio: '${numeroPredio}'`);
    
    // Agora, a busca é feita usando apenas o número do prédio.
    const maquinas = await Maquina.find({
      predio: numeroPredio
    }).sort({ sala: 1 });

    console.log(`Encontradas ${maquinas.length} máquinas.`);
    res.json(maquinas);

  } catch (err) {
    console.error("Erro ao buscar máquinas por prédio:", err);
    res.status(500).json({ erro: "Erro interno ao buscar máquinas por prédio." });
  }
});

app.delete("/maquinas/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const excluida = await Maquina.findByIdAndDelete(id);
    if (!excluida) return res.status(404).json({ erro: "Máquina não encontrada." });
    res.json({ mensagem: "Máquina excluída com sucesso." });
  } catch (err) {
    res.status(500).json({ erro: "Erro ao excluir máquina." });
  }
});

app.put("/maquinas/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const atualizada = await Maquina.findByIdAndUpdate(
      id,
      { ...req.body, ultimaAtualizacao: Date.now() },
      { new: true }
    );
    if (!atualizada) return res.status(404).json({ erro: "Máquina não encontrada." });
    res.json(atualizada);
  } catch (err) {
    console.error(err);
    res.status(500).json({ erro: "Erro ao atualizar máquina." });
  }
});

app.post("/verify-master-password", (req, res) => {
  const { password } = req.body;
  const masterPassword = "teste";
  if (password === masterPassword) {
    res.status(200).json({ success: true, message: "Acesso concedido." });
  } else {
    res.status(401).json({ success: false, message: "Senha incorreta." });
  }
});

app.listen(PORT, () => {
  console.log(`Servidor rodando em http://localhost:${PORT}`);
});
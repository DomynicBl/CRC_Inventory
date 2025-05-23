import express from "express";
import mongoose from "mongoose";
import dotenv from "dotenv";
import cors from "cors";
import { createClient } from '@supabase/supabase-js';

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGODB_URI;

// --- CONFIGURAÇÃO SUPABASE ---
const SUPABASE_URL = process.env.SUPABASE_URL; // <<< Adicione no seu .env
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY; // <<< Adicione no seu .env (USE A SERVICE_ROLE KEY!)
if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
    console.warn("Variáveis de ambiente do Supabase não configuradas. A exclusão de fotos não funcionará.");
}
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
// --- FIM CONFIGURAÇÃO SUPABASE ---

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
  fotoUrl: String,
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
      const maquinas = await Maquina.find({
        patrimonio: { $regex: `^${patrimonio}`, $options: 'i' },
      }).limit(10);
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


// Rota para excluir máquina pelo ID
app.delete("/maquinas/:id", async (req, res) => {
  try {
    const { id } = req.params;

    // 1. Encontre a máquina PRIMEIRO para pegar a URL da foto
    const maquina = await Maquina.findById(id);

    if (!maquina) {
      return res.status(404).json({ erro: "Máquina não encontrada." });
    }

    // 2. Se tiver fotoUrl, tente deletar do Supabase
    if (maquina.fotoUrl && supabase) { // Verifica se tem URL e se supabase está config.
      try {
        // Extrai o nome/caminho do arquivo da URL
        const urlParts = maquina.fotoUrl.split('/fotos-maquinas/');
        if (urlParts.length > 1) {
          const filePath = decodeURIComponent(urlParts[1]); // Decodifica caso tenha caracteres especiais
          console.log(`Tentando deletar do Supabase: ${filePath}`);

          const { error: deleteError } = await supabase.storage
            .from('fotos-maquinas') // Nome do seu bucket
            .remove([filePath]);

          if (deleteError) {
            // Loga o erro mas continua para deletar do Mongo
            console.error("Erro ao deletar foto do Supabase:", deleteError.message);
          } else {
            console.log("Foto deletada do Supabase com sucesso.");
          }
        }
      } catch (supabaseErr) {
        console.error("Erro geral ao processar deleção do Supabase:", supabaseErr);
      }
    }

    // 3. Delete do MongoDB
    await Maquina.findByIdAndDelete(id);

    res.json({ mensagem: "Máquina excluída com sucesso." });

  } catch (err) {
    console.error("Erro geral ao excluir máquina:", err);
    res.status(500).json({ erro: "Erro ao excluir máquina." });
  }
});

// Rota para atualizar máquina pelo ID
app.put("/maquinas/:id", async (req, res) => {
  try {
    const { id } = req.params;
    // req.body já traz o JSON com os campos atualizados
    const atualizada = await Maquina.findByIdAndUpdate(
      id,
      { 
        ...req.body,
        ultimaAtualizacao: Date.now() 
      },
      { new: true } // retorna o documento já modificado
    );
    if (!atualizada) {
      return res.status(404).json({ erro: "Máquina não encontrada." });
    }
    res.json(atualizada);
  } catch (err) {
    console.error(err);
    res.status(500).json({ erro: "Erro ao atualizar máquina." });
  }
});


app.listen(PORT, () => {
  console.log(`Servidor rodando em http://localhost:${PORT}`);
});

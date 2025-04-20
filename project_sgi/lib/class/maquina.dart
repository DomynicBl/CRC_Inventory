//----------------------- Classe auxiliar para RAM ------------------------//
class Ram {
  String brand;   // Fabricante (Corsair, Kingston)
  String type;    // Tipo (DDR3, DDR4, DDR5)
  String size;    // Tamanho (ex: 8GB, 16GB)

  Ram({required this.brand, required this.type, required this.size});

  @override
  String toString() => '$brand $type $size';
}

//---------------------- Classe auxiliar para Disco -----------------------//
class Disco {
  String type;    // Tipo (SSD, HDD)
  String size;    // Capacidade (ex: 500GB, 1TB)
  String brand;   // Fabricante (Samsung, Seagate)

  Disco({required this.type, required this.size, required this.brand});

  @override
  String toString() => '$brand $type $size';
}


//------------ Definição da classe Maquina e suas dependências ------------//
class Maquina {
  String patrimonio; // ID de patrimônio
  String tipo;       // Tipo de máquina (Desktop, Notebook, Servidor, etc)
  String marca;      // Fabricante (Dell, HP, Lenovo, etc)
  String modelo;     // Modelo (Inspiron 15, ThinkPad X1, etc)
  
  String processadorBrand;   // Fabricante do processador (Intel, AMD, etc)
  String processadorFamily;  // Família do processador (Core i7, Ryzen 5, etc)
  String processadorGeracao; // Geração do processador (10ª, 11ª, etc)
  String processadorSpec;    // Especificações do processador (850HX, 900K, etc)

  List<Ram> memoriaRam;   // Lista de módulos de RAM
  List<Disco> discos;     // Lista de discos

  DateTime dataCadastro;        // Data de aquisição
  DateTime ultimaRevisao;       // Data da última revisão
  bool temProblema;             // Indica se há problemas
  String? problemaAtual;        // Lista de problemas ativos
  String? descricaoProblema;    // Descrição opcional do problema

  // Construtor da classe - Cadastro de uma nova máquina
  Maquina({ 
    required this.patrimonio,
    required this.tipo,
    required this.marca,
    required this.modelo,
    required this.processadorBrand,
    required this.processadorFamily,
    required this.processadorGeracao,
    required this.processadorSpec,
    required this.memoriaRam,
    required this.discos,
    required this.temProblema,
    this.problemaAtual,     // Quando temProblema for false, problemaAtual será null
    this.descricaoProblema, // Quando temProblema for false, descricaoProblema será null
  }): dataCadastro = DateTime.now(), // Inicializa com a data atual
      ultimaRevisao = DateTime.now(); // Inicializa com a data atual

  // Construtor para criar um objeto Maquina a partir dos dados do BD
  Maquina.carregar({
    required this.patrimonio,
    required this.tipo,
    required this.marca,
    required this.modelo,
    required this.processadorBrand,
    required this.processadorFamily,
    required this.processadorGeracao,
    required this.processadorSpec,
    required this.memoriaRam,
    required this.discos,
    required this.dataCadastro,
    required this.ultimaRevisao,
    required this.temProblema,
    this.problemaAtual,
    this.descricaoProblema,
  });

  //---------------- Funções da classe  ----------------//

  // Define a data da última revisão como a data atual
  void atualizarUltimaRevisao() {
    ultimaRevisao = DateTime.now(); 
  }


  // Adiciona um problema à máquina
  void adicionarProblema(String problema, {String? descricao}) {
    temProblema = true;
    problemaAtual = problema; // Adiciona o problema atual
    descricaoProblema = descricao; // Adiciona uma descrição do problema, se fornecida
  }


  // Remove o problema atual da máquina
  void resolverProblema() {
    temProblema = false;      // Marca que não há mais problema
    problemaAtual = null;     // Limpa o problema atual
    descricaoProblema = null; // Limpa a descrição do problema
  }


  // Adiciona e remove RAM e discos
  void adicionarRam(Ram ram) {
    memoriaRam.add(ram); // Adiciona um módulo de RAM à lista de RAM
  }

  void removerRam(Ram ram) {
    memoriaRam.remove(ram); // Remove um módulo de RAM da lista de RAM
  }

  void adicionarDisco(Disco disco) {
    discos.add(disco); // Adiciona um disco à lista de discos
  }

  void removerDisco(Disco disco) {
    discos.remove(disco); // Remove um disco da lista de discos
  }


  // Exibe os detalhes da máquina
  String exibirDetalhesCompletos() {
  
    // Função para calcular a largura máxima de cada linha
    int larguraMaxima(String texto1, String texto2, String texto3, String texto4, String? textoDescricao) {
      int largura1 = texto1.length;
      int largura2 = texto2.length;
      int largura3 = texto3.length;
      int largura4 = texto4.length;
      int larguraDescricao = textoDescricao?.length ?? 0; // Caso a descrição seja, considera 0

      // Retorna a maior largura encontrada entre os campos
      return [largura1, largura2, largura3, largura4, larguraDescricao].reduce((a, b) => a > b ? a : b);
    }

    // Função para ajustar o tamanho das bordas
    String borda(String texto, int larguraMax) {
      int espacosRestantes = larguraMax - texto.length;
      String espacos = ' ' * espacosRestantes;
      return '| $texto$espacos |';
    }

    // Função para quebrar a descrição longa em várias linhas
    List<String> quebrarDescricao(String descricao, int limite) {
      List<String> linhas = [];
      
      while (descricao.length > limite) {
        linhas.add(descricao.substring(0, limite));
        descricao = descricao.substring(limite);
      }
      
      if (descricao.isNotEmpty) {
        linhas.add(descricao);
      }
      return linhas;
    }

    // Limite de caracteres para a descrição
    int limiteDescricao = 50; // Pode ser ajustado conforme necessário

    // Calcula a largura máxima considerando os atributos
    int larguraMax = larguraMaxima(
      'Maquina: $tipo $marca $modelo',
      'Patrimônio: $patrimonio',
      'Processador: $processadorBrand $processadorFamily $processadorGeracao $processadorSpec',
      'Memória RAM: ${memoriaRam.join(", ")}',
      temProblema ? descricaoProblema : null,  // Se temProblema for falso, não considera a descrição
    );

    // Começa a construção da exibição
    String resultado = '+${'-' * (larguraMax + 2)}+\n'
    '${borda('Maquina: $tipo $marca $modelo', larguraMax)}\n'
    '${borda('Patrimônio: $patrimonio', larguraMax)}\n'
    '+${'-' * (larguraMax + 2)}+\n'
    '${borda('Especificações:', larguraMax)}\n'
    '${borda('Processador: $processadorBrand $processadorFamily $processadorGeracao $processadorSpec', larguraMax)}\n'
    '${borda('Memória RAM: ${memoriaRam.join(", ")}', larguraMax)}\n'
    '${borda('Armazenamento: ${discos.join(", ")}', larguraMax)}\n'
    '+${'-' * (larguraMax + 2)}+\n'
    '${borda('Informações de Manutenção:', larguraMax)}\n'
    '${borda('Data de Cadastro: $dataCadastro', larguraMax)}\n'
    '${borda('Última Revisão: $ultimaRevisao', larguraMax)}\n';
    
    // Exibe problema atual
    if (temProblema) {
      resultado += '${borda('Problema Atual: $problemaAtual', larguraMax)}\n';

      // Quebra a descrição longa em várias linhas, se necessário
      List<String> descricaoQuebrada = quebrarDescricao(descricaoProblema ?? '', limiteDescricao);
      for (String linha in descricaoQuebrada) {
        resultado += '${borda('Descrição: $linha', larguraMax)}\n';
      }
    } else {
      resultado += '${borda('Problema Atual: Nenhum', larguraMax)}\n';
    }

    resultado += '+${'-' * (larguraMax + 2)}+\n';
    return resultado;
  }

}





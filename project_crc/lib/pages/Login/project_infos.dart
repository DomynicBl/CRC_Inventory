import 'package:flutter/material.dart';
import 'package:project_crc/pages/Login/login_screen.dart';


class InfosPage extends StatelessWidget {
  InfosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Botao de retorno para tela de Login
appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => {
            Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      ),
                    },
        ),
        backgroundColor: const Color(0xFF002238),
      ),

      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFF002238),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Título do projeto
                const Text(
                  'Proposta de Desenvolvimento',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Título "Objetivo do App:"
                const Text(
                  'Objetivo do App:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Descrição do projeto
                const Text(
                  '''O SGI - Sistema de Gerenciamento de Inventário é um aplicativo mobile voltado para a gestão e controle de estoque das máquinas e recursos pertencentes ao Centro de Recursos Computacionais (CRC). Ele permite o cadastro, consulta e atualização das informações de cada máquina individualmente por meio da leitura de seu patrimônio (código de identificação). Além do controle de localização, o app auxilia na gestão de troca e atualização dos equipamentos, armazenando dados detalhados sobre hardware, histórico de atualizações de software e permitindo a abertura de chamados para eventuais manutenções em máquinas específicas. O objetivo é facilitar o monitoramento dos recursos do CRC nos diferentes laboratórios e salas, abrangendo todos os prédios e unidades da PUC Minas, garantindo um controle eficiente e atualizado do inventário.''',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Desenvolvedores
                const Text(
                  '\nDesenvolvedores:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Nomes dos desenvolvedores
                const Text(
                  '- Ângelo Gabriel de Freitas Marques\n- Domynic Barros Lima\n- Juan Pablo Ramos de Oliveira\n- Vinícius Figueiredo Ferreira',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Informações sobre a disciplina
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    'Projeto desenvolvido para a disciplina de LDDM - PUC Minas',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
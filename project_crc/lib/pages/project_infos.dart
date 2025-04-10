import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class InfosPage extends StatelessWidget {
  InfosPage({super.key});

  // Função para abrir URLs no navegador
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir a URL: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF002238), // Cor de fundo
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Centralizar o conteúdo
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Título do projeto
              Text(
                'Proposta de Desenvolvimento',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Texto branco
                ),
                textAlign: TextAlign.center, // Alinhamento central
              ),
              SizedBox(height: 20),

              // Título "Objetivo do App:"
              Text(
                'Objetivo do App:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Texto branco
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),

              // Descrição do projeto
              Text(
                '''O SGI - Sistema de Gerenciamento de Inventário é um aplicativo mobile voltado para a gestão e controle de estoque das máquinas e recursos pertencentes ao Centro de Recursos Computacionais (CRC). Ele permite o cadastro, consulta e atualização das informações de cada máquina individualmente por meio da leitura de seu patrimônio (código de identificação). Além do controle de localização, o app auxilia na gestão de troca e atualização dos equipamentos, armazenando dados detalhados sobre hardware, histórico de atualizações de software e permitindo a abertura de chamados para eventuais manutenções em máquinas específicas. O objetivo é facilitar o monitoramento dos recursos do CRC nos diferentes laboratórios e salas, abrangendo todos os prédios e unidades da PUC Minas, garantindo um controle eficiente e atualizado do inventário.''',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white, // Texto branco
                ),
                textAlign: TextAlign.center, // Alinhamento central
              ),
              SizedBox(height: 20),

              // Desenvolvedores
              Text(
                '\nDesenvolvedores:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Texto branco
                ),
                textAlign: TextAlign.center, // Alinhamento central
              ),
              SizedBox(height: 10),

              // Desenvolvedores
              Text(
                '- Ângelo Gabriel de Freitas Marques\n- Domynic Barros Lima\n- Juan Pablo Ramos de Oliveira\n- Vinícius Figueiredo Ferreira',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Texto branco
                ),
                textAlign: TextAlign.center, // Alinhamento central
              ),
              SizedBox(height: 20),

              // Botões com ícones para GitHub e Figma
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botão GitHub
                  Flexible(
                    child: IconButton(
                      icon: SvgPicture.network(
                        'https://www.svgrepo.com/show/445786/github.svg', // Novo link do GitHub
                        height: 40,
                        width: 40,
                        fit: BoxFit.contain,
                      ),
                      onPressed:
                          () => _launchURL(
                            'https://github.com/DomynicBl/CRC_Inventory',
                          ),
                      tooltip: 'Ver no GitHub',
                    ),
                  ),
                  SizedBox(width: 20),

                  // Botão Figma
                  Flexible(
                    child: IconButton(
                      icon: SvgPicture.network(
                        'https://www.svgrepo.com/show/448222/figma.svg', // Novo link do Figma
                        height: 40,
                        width: 40,
                        fit: BoxFit.contain,
                      ),
                      onPressed:
                          () => _launchURL(
                            'https://www.figma.com/design/nbayqoQplmsfHXIHsNJAtw/CRC-Inventory?node-id=98-67&t=QGrvE3yI6pQFY4Hz-1',
                          ),
                      tooltip: 'Ver no Figma',
                    ),
                  ),
                ],
              ),

              // Informações sobre a disciplina
              Text(
                'Projeto desenvolvido para a disciplina de LDDM - PUC Minas',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white, // Texto branco
                ),
                textAlign: TextAlign.center, // Alinhamento central
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
//import 'package:project_crc/pages/search_screen.dart';
import 'package:project_crc/pages/Login/project_infos.dart';
import 'package:project_crc/pages/Home/home_screen.dart';


class HomePage extends StatelessWidget {
HomePage({super.key});

  // Função para exibir um diálogo de erro
  void _mostrarErro(BuildContext context, String mensagem) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Erro de Login"),
          content: Text(mensagem),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Fechar"),
            )
          ],
        );
      },
    );
  }

  // Função de validação e navegação para a HomePage
  void _efetuarLogin(BuildContext context, String usuario, String senha) {
    // Credenciais de teste
    if (usuario == 'teste' && senha == '123') {
      // Se as credenciais forem válidas, navega para a HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    } else {
      // Caso contrário, exibe mensagem de erro
      _mostrarErro(context, "Usuário ou senha incorretos");
    }
  }

  @override
  Widget build(BuildContext context) {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Color(0xFF002238),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * .05,
            decoration: BoxDecoration(color: Color.fromARGB(0, 0, 0, 0)),
            child: const Center(
              child: Text(
                'Português (Brasil)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Container(
            //Logo
            width: MediaQuery.of(context).size.width,
            height:
                MediaQuery.of(context).size.height *
                0.21, // 20% da altura da tela
            decoration: BoxDecoration(color: Color.fromARGB(0, 0, 0, 0)),
            margin: const EdgeInsets.only(top: 10),
            child: Center(
              child: SvgPicture.asset(
                'assets/images/Logo - Dark.svg',
                height:
                    MediaQuery.of(context).size.height *
                    0.2 *
                    0.83, // 80% da altura do Container (20% da tela)
                fit: BoxFit.contain, // Ajuste conforme necessário
              ),
            ),
          ),

          Container(
            //Área de Login
            width: MediaQuery.of(context).size.width * 0.8,
            height:
                MediaQuery.of(context).size.height *
                0.40, // 20% da altura da tela
            decoration: BoxDecoration(color: Color.fromARGB(0, 231, 18, 18)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Primeira div com texto e campo de input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Usuário",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: '',
                        filled: true,
                        fillColor: Color(0xFFE4E4E4), // Cor de fundo do campo
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            5,
                          ), // Arredondar as bordas
                          borderSide: BorderSide(
                            color: Color(0xFF262626),
                            width: 2,
                          ), // Cor e espessura da borda
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 18,
                      ), // Aumentar a fonte do texto
                    ),
                  ],
                ),
                SizedBox(height: 25), // Aumentar o espaço entre os campos
                // Segunda div com texto e campo de input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Senha",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: '',
                        filled: true,
                        fillColor: Color(0xFFE4E4E4), // Cor de fundo do campo
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            5,
                          ), // Arredondar as bordas
                          borderSide: BorderSide(
                            color: Color(0xFF262626),
                            width: 2,
                          ), // Cor e espessura da borda
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 18,
                      ), // Aumentar a fonte do texto
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ), // Aumentar o espaço entre o botão e o campo de senha

                Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .start, // Ajustar alinhamento para o texto de "Esqueci minha senha"
                  children: [
                    // Caixa de login com 40% da altura do seu pai
                    Container(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .start, // Distribuir os itens com espaços iguais
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 15),
                            width: double.infinity, // Largura máxima
                            height:
                                MediaQuery.of(context).size.height *
                                0.07, // Ajustar a altura do botão
                            child: ElevatedButton(
                              onPressed: () {
                                // Chama função de login usando os valores dos controladores
                                _efetuarLogin(
                                  context,
                                  emailController.text,
                                  passwordController.text,
                                );
                              },
                              child: Text(
                                "Login",
                                style: TextStyle(color: Colors.white),
                              ), // Cor do texto já está ajustada para branco
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF0083A2),
                                textStyle: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ), // Cor do texto já está ajustada para branco
                                padding: EdgeInsets.symmetric(
                                  vertical: 16,
                                ), // Espaçamento interno do botão
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    5,
                                  ), // Bordas arredondadas
                                ),
                              ),
                            ),
                          ),

                          // Espaço mínimo entre o botão e o texto "Esqueci minha senha"
                          SizedBox(height: 5),

                          // Texto "Esqueci minha senha" colado na parte de baixo do botão
                          Align(
                            alignment:
                                Alignment.bottomCenter, // Alinhar ao fundo
                            child: TextButton(
                              onPressed: () {
                                // Lógica para recuperação de senha
                              },
                              child: Text(
                                "Esqueci minha senha?",
                                style: TextStyle(
                                  color: Colors.white,
                                ), // Cor do texto ajustada para branco
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Column(
            children: [
              // Caixa de login com 40% da altura do seu pai
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      width: double.infinity, // Largura máxima
                      height:
                          MediaQuery.of(context).size.height *
                          0.07, // Ajustar a altura do botão
                      child: ElevatedButton(
                        onPressed: () {
                          // Lógica para login
                        },
                        child: Text(
                          "Criar Nova Conta",
                          style: TextStyle(color: Colors.white),
                        ), // Cor do texto já está ajustada para branco
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 3, 61, 86),
                          textStyle: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ), // Cor do texto já está ajustada para branco
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                          ), // Espaçamento interno do botão
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              5,
                            ), // Bordas arredondadas
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InfosPage()),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * .05,
              decoration: BoxDecoration(color: Color.fromARGB(0, 0, 0, 0)),
              margin: const EdgeInsets.only(top: 30),
              child: const Center(
                child: Text(
                  'SGI V0.1',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
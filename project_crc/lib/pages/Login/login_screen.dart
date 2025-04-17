/* SERVICOS */
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/* PAGINAS */
import 'package:project_crc/pages/Login/project_infos.dart';
import 'package:project_crc/pages/Home/home_screen.dart';

/* CLASSE PRINCIPAL */
class LoginScreen extends StatefulWidget {
  // Alterado para StatefulWidget
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  /* PROPORCOES */
  final double _logoHeightRatio = 0.2; // 20% da altura da tela
  final double _bottomMarginRatio = 0.05; // 5% da altura da tela
  /* PARA ENVIAR COM ENTER */
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;
  /* PARA NAO APAGAR FORMULARIO */
  late TextEditingController _emailController;
  late TextEditingController _passwordController;


  @override
void initState() {
  super.initState();
  _emailFocusNode = FocusNode();
  _passwordFocusNode = FocusNode();
  _emailController = TextEditingController();
  _passwordController = TextEditingController();
}


  @override
void dispose() {
  _emailFocusNode.dispose();
  _passwordFocusNode.dispose();
  _emailController.dispose();
  _passwordController.dispose();
  super.dispose();
}



  /// Mensagem para quando o login for invalido
  void _mostrarErro(BuildContext context, String mensagem) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Erro de Login"),
            content: Text(mensagem),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Fechar"),
              ),
            ],
          ),
    );
  }

  /// Realiza login (Apenas em teste)
  void _efetuarLogin(BuildContext context, String usuario, String senha) {
    if (usuario == 'teste' && senha == '123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    } else {
      _mostrarErro(context, "Usuário ou senha incorretos");
    }
  }

  /// Construtor da tela de login
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF002238),
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho - Idioma
            Container(
              height: screenHeight * 0.05,
              alignment: Alignment.center,
              child: const Text(
                'Português (Brasil)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Logo
            Container(
              height: screenHeight * _logoHeightRatio,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SvgPicture.asset(
                'assets/images/Logo - Dark.svg',
                fit: BoxFit.contain,
              ),
            ),

            // Seção de Login
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                margin: const EdgeInsets.only(top: 20),
                child: _buildLoginForm(
                  context,
                  _emailController,
                  _passwordController,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(
    BuildContext context,
    TextEditingController emailController,
    TextEditingController passwordController,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Campo Usuário
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Usuário",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              focusNode: _emailFocusNode, // Novo: Vincula focus node
              textInputAction: TextInputAction.next, // Novo: Ação do teclado
              onSubmitted: (_) {
                // Novo: Enter no campo usuário
                FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
              decoration: _inputDecoration(),
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),

        // Campo Senha
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Senha",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              focusNode: _passwordFocusNode, // Novo: Vincula focus node
              textInputAction: TextInputAction.done, // Novo: Ação do teclado
              onSubmitted: (_) {
                // Novo: Enter no campo senha
                _efetuarLogin(
                  context,
                  emailController.text,
                  passwordController.text,
                );
              },
              decoration: _inputDecoration(),
              style: const TextStyle(fontSize: 18),
              obscureText: true,
            ),
          ],
        ),

        // Botão Login + Esqueci a senha
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    () => _efetuarLogin(
                      context,
                      emailController.text,
                      passwordController.text,
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0083A2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "Esqueci minha senha?",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),

        // Botão "Criar Nova Conta"
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * _bottomMarginRatio,
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF033D56),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  "Criar Nova Conta",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Versão do sistema
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => InfosPage()),
                      );
                    },
                    child: const Text(
                      'SGI V0.1',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFE4E4E4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Color(0xFF262626), width: 2),
      ),
    );
  }
}

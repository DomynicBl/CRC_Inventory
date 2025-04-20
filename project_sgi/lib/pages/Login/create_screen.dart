import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/* PAGINAS */
import 'package:project_sgi/pages/Login/project_infos.dart';
import 'package:project_sgi/pages/Login/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final double _logoHeightRatio = 0.2;
  final double _bottomMarginRatio = 0.05;
  final double _topMarginRatio = 0.03;

  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;
  late FocusNode _confirmPasswordFocusNode;

  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  void _mostrarErro(BuildContext context, String mensagem) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Erro no Registro"),
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

  void _efetuarRegistro(
    BuildContext context,
    String usuario,
    String senha,
    String confirmar,
  ) {
    if (usuario.isEmpty || senha.isEmpty || confirmar.isEmpty) {
      _mostrarErro(context, "Todos os campos são obrigatórios.");
    } else if (senha != confirmar) {
      _mostrarErro(context, "As senhas não coincidem.");
    } else {
      // Registro bem-sucedido (exemplo)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF002238),
      body: SafeArea(
        child: Column(
          children: [
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
            Container(
              height: screenHeight * _logoHeightRatio,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SvgPicture.asset(
                'assets/images/Logo - Dark.svg',
                fit: BoxFit.contain,
              ),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                margin: const EdgeInsets.only(top: 20),
                child: _buildRegisterForm(
                  context,
                  _emailController,
                  _passwordController,
                  _confirmPasswordController,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm(
    BuildContext context,
    TextEditingController emailController,
    TextEditingController passwordController,
    TextEditingController confirmPasswordController,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInputField(
          "Usuário",
          emailController,
          _emailFocusNode,
          TextInputAction.next,
          () {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
        ),
        _buildInputField(
          "Senha",
          passwordController,
          _passwordFocusNode,
          TextInputAction.next,
          () {
            FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
          },
          isPassword: true,
        ),
        _buildInputField(
          "Confirmar Senha",
          confirmPasswordController,
          _confirmPasswordFocusNode,
          TextInputAction.done,
          () {
            _efetuarRegistro(
              context,
              emailController.text,
              passwordController.text,
              confirmPasswordController.text,
            );
          },
          isPassword: true,
        ),
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    () => _efetuarRegistro(
                      context,
                      emailController.text,
                      passwordController.text,
                      confirmPasswordController.text,
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0083A2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  "Registrar",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * _topMarginRatio,
            bottom: MediaQuery.of(context).size.height * _bottomMarginRatio,
          ),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text(
                'Voltar para Login',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),

        const Text(
          'SGI V0.1',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    FocusNode focusNode,
    TextInputAction action,
    void Function() onSubmitted, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: action,
          obscureText: isPassword,
          onSubmitted: (_) => onSubmitted(),
          decoration: _inputDecoration(),
          style: const TextStyle(fontSize: 18),
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

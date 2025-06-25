/* SERVICOS */
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project_sgi/api/auth_service.dart'; // Importa o nosso novo serviço
import 'package:shared_preferences/shared_preferences.dart'; // Para lembrar que o app foi desbloqueado

/* PAGINAS */
import 'package:project_sgi/pages/Login/project_infos.dart';
import 'package:project_sgi/pages/Home/home_screen.dart';

/* CLASSE PRINCIPAL */
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Instancia o serviço de API
  final AuthService _apiService = AuthService();
  
  // Controladores e Proporções
  final double _logoHeightRatio = 0.2;
  final double _bottomMarginRatio = 0.05;
  late TextEditingController _passwordController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  /// Mostra um pop-up de erro simples
  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  /// Verifica a senha mestra com o backend
  Future<void> _verificarSenhaMestra() async {
    if (_isLoading || _passwordController.text.isEmpty) {
      return; // Não faz nada se já estiver carregando ou se o campo estiver vazio
    }

    setState(() {
      _isLoading = true;
    });

    final bool isPasswordCorrect = await _apiService.verifyMasterPassword(_passwordController.text);

    if (mounted) { // Verifica se o widget ainda está na tela antes de atualizar o estado
      setState(() {
        _isLoading = false;
      });

      if (isPasswordCorrect) {
        // Salva que o app foi desbloqueado
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_authenticated', true);

        // Navega para a HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        _mostrarErro("Senha mestra incorreta.");
      }
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
            // Seção de Login (agora Senha Mestra)
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                margin: const EdgeInsets.only(top: 20),
                child: _buildMasterPasswordForm(context, _passwordController),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterPasswordForm(
    BuildContext context,
    TextEditingController passwordController,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // Centraliza o conteúdo verticalmente
      children: [
        // Campo Senha Mestra
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Senha Mestra", // Texto alterado
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              textAlign: TextAlign.center,
              onSubmitted: (_) => _verificarSenhaMestra(),
              decoration: _inputDecoration(),
              style: const TextStyle(fontSize: 18),
              obscureText: true,
            ),
          ],
        ),
        
        const SizedBox(height: 40), // Espaçamento maior

        // Botão Desbloquear
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _verificarSenhaMestra,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0083A2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Desbloquear", // Texto do botão alterado
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),

        const Spacer(), // Usa o espaço restante para empurrar a versão para baixo

        // Versão do sistema (mantida)
        Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * _bottomMarginRatio,
          ),
          child: MouseRegion(
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
       enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide.none, // Remove a borda padrão
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Color(0xFF0083A2), width: 2), // Borda azul quando focado
      ),
    );
  }
}
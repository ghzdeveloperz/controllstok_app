import 'package:flutter/material.dart';
import '../screens/login_screen.dart';

import 'conf_options/perfil_screen.dart';
import 'conf_options/categorias_screen.dart';
import 'conf_options/sobre_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfigScreen extends StatelessWidget {
  final String userLogin; // LOGIN REAL

  const ConfigScreen({super.key, required this.userLogin});

  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[100],
    appBar: AppBar(
      elevation: 0.5,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      centerTitle: false, // alinhamento à esquerda
      title: Text(
        'Configurações',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 16),

          _buildOption(
            context,
            icon: Icons.person_outline,
            title: 'Perfil',
            subtitle: 'Informações pessoais',
            page: PerfilScreen(userLogin: userLogin),
          ),

          const SizedBox(height: 16),

          _buildOption(
            context,
            icon: Icons.category_outlined,
            title: 'Categorias',
            subtitle: 'Categorias do Estoque',
            page: CategoriasScreen(userLogin: userLogin),
          ),

          const SizedBox(height: 16),

          _buildOption(
            context,
            icon: Icons.info_outline,
            title: 'Sobre',
            subtitle: 'Informações do app',
            page: SobreScreen(
              logoutCallback: () => _logout(context),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildOption(
  BuildContext context, {
  required IconData icon,
  required String title,
  String? subtitle,
    required Widget page,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => page),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.black87, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

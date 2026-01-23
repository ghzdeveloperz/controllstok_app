import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mystoreday/screens/userPerfil/confi_options/config_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/app_navigator.dart';

import '../acounts/auth_choice/auth_choice_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen>
    with TickerProviderStateMixin {
  User? _user;

  bool _isLoading = true;
  String? _errorMessage;

  // Firestore fields
  String? _companyName;
  String? _plan; // free|pro|max  (ou "Grátis"/"Pró"/"Max")
  String? _photoUrl;

  bool _isUploadingAvatar = false;

  late AnimationController _avatarAnimationController;
  late Animation<double> _avatarScaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    _avatarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _avatarScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _avatarAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _avatarAnimationController.dispose();
    super.dispose();
  }

  // =========================
  // LOAD USER + FIRESTORE DATA
  // =========================
  Future<void> _loadUserData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não encontrado');

      await user.reload();
      final freshUser = FirebaseAuth.instance.currentUser!;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(freshUser.uid)
          .get();

      final data = doc.data();

      final company = (data?['company'] ?? data?['companyName']) as String?;
      final plan = (data?['plan'] ?? data?['plano']) as String?;
      final photoUrl =
          (data?['photoUrl'] ?? data?['avatarUrl'] ?? data?['photoURL'])
              as String?;

      if (!mounted) return;
      setState(() {
        _user = freshUser;
        _companyName = company;
        _plan = plan;
        _photoUrl = photoUrl;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erro ao carregar dados: $e';
        _isLoading = false;
      });
    }
  }

  // =========
  // PLAN CHIP
  // =========
  String _planLabel(String? plan) {
    final p = (plan ?? '').trim().toLowerCase();
    switch (p) {
      case 'pro':
      case 'pró':
        return 'PRÓ';
      case 'max':
        return 'MAX';
      case 'free':
      case 'gratis':
      case 'grátis':
      case '':
      default:
        return 'Grátis';
    }
  }

  Color _planColor(String? plan) {
    final p = (plan ?? '').trim().toLowerCase();
    switch (p) {
      case 'pro':
      case 'pró':
        return const Color(0xFF1565C0);
      case 'max':
        return const Color(0xFF6A1B9A);
      case 'free':
      case 'gratis':
      case 'grátis':
      case '':
      default:
        return const Color(0xFF2E7D32);
    }
  }

  Widget _buildPlanChip(String? plan) {
    final label = _planLabel(plan);
    final color = _planColor(plan);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(64)),
      ),
      child: Text(
        '$label',
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // =====================
  // EDIT COMPANY (DIALOG)
  // =====================
  void _showEditCompanyDialog() {
    if (_user == null) return;

    final controller = TextEditingController(text: _companyName ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Editar empresa',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Nome da empresa',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(_user!.uid)
                  .set({'company': newName}, SetOptions(merge: true));

              if (!mounted) return;
              setState(() => _companyName = newName);
              Navigator.of(context).pop();
            },
            child: Text(
              'Salvar',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // =====================
  // AVATAR PICK + UPLOAD
  // =====================
  Future<void> _pickAndUploadAvatar() async {
    if (_user == null) return;
    if (_isUploadingAvatar) return;

    try {
      setState(() => _isUploadingAvatar = true);

      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked == null) {
        if (!mounted) return;
        setState(() => _isUploadingAvatar = false);
        return;
      }

      final uid = _user!.uid;

      // caminho fixo (substitui sempre)
      final ref = FirebaseStorage.instance.ref('users/$uid/avatar.jpg');

      await ref.putFile(File(picked.path));
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'photoUrl': url,
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() {
        _photoUrl = url;
        _isUploadingAvatar = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Imagem atualizada com sucesso!'),
          backgroundColor: Colors.black87,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingAvatar = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar imagem: $e'),
          backgroundColor: Colors.black87,
        ),
      );
    }
  }

  // ==========
  // UTILITIES
  // ==========
  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copiado para a área de transferência'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black87,
      ),
    );
  }

  void _showConfirmationDialog(
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Confirmar',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog({required VoidCallback onConfirmed}) {
    final TextEditingController passwordController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Desativar Conta',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Para desativar sua conta, confirme sua senha. Esta ação é irreversível.',
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText: errorMessage,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Digite sua senha';
                    return null;
                  },
                ),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      errorMessage!,
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;

                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });

                      try {
                        // Garantindo email não nulo
                        final email = _user?.email;
                        if (email == null || email.isEmpty) {
                          throw FirebaseAuthException(
                            code: 'no-email',
                            message: 'Email do usuário não encontrado.',
                          );
                        }

                        final credential = EmailAuthProvider.credential(
                          email: email,
                          password: passwordController.text,
                        );

                        await _user!.reauthenticateWithCredential(credential);

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(_user!.uid)
                            .update({'active': false});

                        // navegação para AuthChoiceScreen
                        onConfirmed();
                      } catch (e) {
                        if (!mounted) return;

                        String message;
                        if (e is FirebaseAuthException &&
                            e.code == 'wrong-password') {
                          message =
                              'Senha incorreta. Verifique e tente novamente.';
                        } else if (e is FirebaseAuthException &&
                            e.code == 'no-email') {
                          message =
                              e.message ?? 'Email do usuário não encontrado.';
                        } else {
                          message = 'Erro ao desativar a conta.';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              backgroundColor: Colors.black87,
                            ),
                          );
                        }

                        setState(() {
                          errorMessage = message;
                          isLoading = false;
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Desativar',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // =========
  // BUILD UI
  // =========
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingScreen();
    if (_errorMessage != null) return _buildErrorScreen();
    if (_user == null) return _buildEmptyScreen();

    // Garantindo que displayName nunca seja nulo
    String displayName;
    if (_companyName != null && _companyName!.trim().isNotEmpty) {
      displayName = _companyName!.trim();
    } else if (_user!.email != null && _user!.email!.isNotEmpty) {
      displayName = _user!.email!.split('@').first;
    } else {
      displayName = 'Usuário';
    }

    // Garantindo que email e uid nunca sejam nulos
    final String email = _user!.email ?? 'Sem email';
    final String uid = _user!.uid;

    final DateTime? creationTime = _user!.metadata.creationTime;
    final DateTime? lastSignInTime = _user!.metadata.lastSignInTime;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Perfil',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () async {
              final result = await Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ConfigScreen()));

              if (result != null) {
                // reage ao que veio da tela de configurações
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(displayName, email),
              const SizedBox(height: 32),
              _buildAccountInfoSection(
                email,
                uid,
                creationTime,
                lastSignInTime,
              ),
              const SizedBox(height: 32),
              //_buildActionsSection(),
              const SizedBox(height: 32),
              _buildSecuritySection(),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================
  // LOADING / ERROR / EMPTY UI
  // ==========================
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade300,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 150,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 200,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 110,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: GoogleFonts.poppins(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Tentar novamente',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Nenhum usuário logado',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ======================
  // HEADER (company + plan + avatar com foto)
  // ======================
  Widget _buildHeader(String displayName, String email) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _avatarAnimationController.forward().then(
              (_) => _avatarAnimationController.reverse(),
            ),
            child: AnimatedBuilder(
              animation: _avatarScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _avatarScaleAnimation.value,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.black,
                        backgroundImage:
                            (_photoUrl != null && _photoUrl!.isNotEmpty)
                            ? NetworkImage(_photoUrl!)
                            : null,
                        child: (_photoUrl == null || _photoUrl!.isEmpty)
                            ? Text(
                                displayName.isNotEmpty
                                    ? displayName[0].toUpperCase()
                                    : 'U',
                                style: GoogleFonts.poppins(
                                  fontSize: 48,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),

                      // Botão de câmera + estado de upload
                      InkWell(
                        onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: _isUploadingAvatar
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: Colors.black87,
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // ✅ Nome da empresa + lápis sempre colado e centralizado
          SizedBox(
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Texto ocupa toda a largura e fica realmente centralizado
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),

                // Lápis sempre colado ao texto, sem deslocar o centro
                Positioned(
                  right: 60,
                  child: IconButton(
                    onPressed: _showEditCompanyDialog,
                    icon: const Icon(
                      Icons.edit,
                      size: 20,
                      color: Colors.black54,
                    ),
                    tooltip: 'Editar empresa',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),
          Text(
            email,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
          ),

          const SizedBox(height: 8),

          // ✅ Plano
          _buildPlanChip(_plan),
        ],
      ),
    );
  }

  Widget _buildAccountInfoSection(
    String email,
    String uid,
    DateTime? creationTime,
    DateTime? lastSignInTime,
  ) {
    final createdLocal = creationTime?.toLocal();
    final lastLoginLocal = lastSignInTime?.toLocal();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações da Conta',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.email, 'Email', email),
          const Divider(height: 20),
          _buildInfoRow(
            Icons.key,
            'UID',
            uid,
            isCopyable: true,
            copyLabel: 'UID',
          ),
          const Divider(height: 20),
          _buildInfoRow(
            Icons.calendar_today,
            'Criado em',
            createdLocal != null
                ? DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(createdLocal)
                : 'N/A',
          ),
          const Divider(height: 20),
          _buildInfoRow(
            Icons.access_time,
            'Último login',
            lastLoginLocal != null
                ? DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(lastLoginLocal)
                : 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isCopyable = false,
    String? copyLabel,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (isCopyable)
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.grey, size: 20),
            onPressed: () => _copyToClipboard(value, copyLabel ?? label),
          ),
      ],
    );
  }

  /*Widget _buildActionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ações',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(Icons.lock, 'Alterar Senha', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Funcionalidade em desenvolvimento'),
              ),
            );
          }),
          const SizedBox(height: 12),
          _buildActionButton(Icons.manage_accounts, 'Gerenciar Conta', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Funcionalidade em desenvolvimento'),
              ),
            );
          }),
          const SizedBox(height: 12),
          _buildActionButton(Icons.notifications, 'Preferências', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Funcionalidade em desenvolvimento'),
              ),
            );
          }),
          const SizedBox(height: 12),
          _buildActionButton(Icons.help, 'Ajuda & Suporte', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Funcionalidade em desenvolvimento'),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.black, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }*/

  Widget _buildSecuritySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Segurança',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Botão de Sair da Conta
          _buildSecurityButton(
            Icons.logout,
            'Sair da Conta',
            const Color.fromARGB(255, 70, 70, 70),
            () => _showConfirmationDialog(
              'Sair da Conta',
              'Tem certeza que deseja sair?',
              () async {
                // Desloga o usuário
                await FirebaseAuth.instance.signOut();
                AppNavigator.resetTo(const AuthChoiceScreen());
              },
            ),
          ),

          const SizedBox(height: 12),

          // Botão de Desativar Conta
          _buildSecurityButton(
            Icons.delete_forever,
            'Desativar Conta',
            Colors.red.shade800,
            () => _showDeleteAccountDialog(
              onConfirmed: () {
                AppNavigator.resetTo(const AuthChoiceScreen());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withAlpha(51)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

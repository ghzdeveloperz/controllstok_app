// lib/ai_storay/data/storay_usage_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class StorayUsageDecision {
  final bool allowed;
  final int remainingToday; // para plano free
  final String plan; // free | expert

  const StorayUsageDecision({
    required this.allowed,
    required this.remainingToday,
    required this.plan,
  });
}

class StorayUsageRepository {
  final FirebaseFirestore _db;

  StorayUsageRepository(this._db);

  String _todayKey(DateTime now) {
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<StorayUsageDecision> canUseToday({
    required String uid,
    required DateTime now,
  }) async {
    final today = _todayKey(now);

    final subRef = _db.collection('users').doc(uid).collection('subscription').doc('current');
    final subSnap = await subRef.get();

    final plan = (subSnap.data()?['plan'] as String?)?.toLowerCase() ?? 'free';

    if (plan == 'expert') {
      return const StorayUsageDecision(
        allowed: true,
        remainingToday: 999999,
        plan: 'expert',
      );
    }

    // Free: 3 vezes ao dia
    final usageRef = _db.collection('users').doc(uid).collection('storayUsage').doc(today);
    final usageSnap = await usageRef.get();
    final count = (usageSnap.data()?['count'] as int?) ?? 0;

    final remaining = 3 - count;
    final allowed = remaining > 0;

    return StorayUsageDecision(
      allowed: allowed,
      remainingToday: remaining < 0 ? 0 : remaining,
      plan: 'free',
    );
  }

  /// Incrementa o uso de hoje (de preferência após ter certeza que vai processar).
  Future<void> incrementToday({
    required String uid,
    required DateTime now,
  }) async {
    final today = _todayKey(now);
    final usageRef = _db.collection('users').doc(uid).collection('storayUsage').doc(today);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(usageRef);
      final current = (snap.data()?['count'] as int?) ?? 0;

      tx.set(usageRef, {
        'count': current + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }
} , // lib/ai_storay/domain/storay_intent.dart
class StorayIntentResult {
  final String intent; // ex: add_stock, remove_stock
  final double confidence;
  final Map<String, dynamic> slots;

  const StorayIntentResult({
    required this.intent,
    required this.confidence,
    required this.slots,
  });
} , // lib/ai_storay/domain/storay_router.dart
import 'storay_intent.dart';

class StorayRouter {
  /// Lista branca de intents permitidas.
  static const allowedIntents = <String>{
    'open_reports',
    'show_critical',
    'search_product',
    'add_stock',
    'remove_stock',
  };

  StorayIntentResult? route(String commandText) {
    final text = _normalize(commandText);

    // Exemplos básicos. Você vai evoluir isso.
    if (text.contains('relatorio') || text.contains('relatorios')) {
      return const StorayIntentResult(
        intent: 'open_reports',
        confidence: 0.85,
        slots: {},
      );
    }

    if (text.contains('critico') || text.contains('baixo')) {
      return const StorayIntentResult(
        intent: 'show_critical',
        confidence: 0.85,
        slots: {},
      );
    }

    // add_stock: "adicionar 3 arroz"
    final addMatch = RegExp(r'(adicionar|entrada|colocar)\s+(\d+)\s+(.+)$')
        .firstMatch(text);
    if (addMatch != null) {
      final qty = int.tryParse(addMatch.group(2) ?? '');
      final name = addMatch.group(3)?.trim();
      if (qty != null && name != null && name.isNotEmpty) {
        return StorayIntentResult(
          intent: 'add_stock',
          confidence: 0.82,
          slots: {'quantity': qty, 'product_name': name},
        );
      }
    }

    // remove_stock: "retirar 2 arroz"
    final removeMatch = RegExp(r'(retirar|saida|baixar)\s+(\d+)\s+(.+)$')
        .firstMatch(text);
    if (removeMatch != null) {
      final qty = int.tryParse(removeMatch.group(2) ?? '');
      final name = removeMatch.group(3)?.trim();
      if (qty != null && name != null && name.isNotEmpty) {
        return StorayIntentResult(
          intent: 'remove_stock',
          confidence: 0.82,
          slots: {'quantity': qty, 'product_name': name},
        );
      }
    }

    // search_product: "buscar arroz"
    final searchMatch = RegExp(r'(buscar|procurar|pesquisar)\s+(.+)$')
        .firstMatch(text);
    if (searchMatch != null) {
      final name = searchMatch.group(2)?.trim();
      if (name != null && name.isNotEmpty) {
        return StorayIntentResult(
          intent: 'search_product',
          confidence: 0.78,
          slots: {'query': name},
        );
      }
    }

    return null; // não entendeu -> você responde UX
  }

  String _normalize(String input) {
    final lower = input.toLowerCase();
    // Normalização simples (sem pacote extra): remove pontuação comum.
    return lower
        .replaceAll(RegExp(r'[^\w\sáàâãéèêíìîóòôõúùûç]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
} , // lib/ai_storay/services/storay_audio_service.dart
import 'package:audioplayers/audioplayers.dart';

class StorayAudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playPip() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/pip.wav'));
    } catch (_) {
      // Se falhar, não quebra o fluxo.
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
} , // lib/ai_storay/services/storay_command_recorder.dart
import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class StorayCommandRecorder {
  final AudioRecorder _recorder = AudioRecorder();

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<File> recordFor({
    required Duration duration,
  }) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/storay_command_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );

    await Future.delayed(duration);
    final outPath = await _recorder.stop();

    if (outPath == null) {
      throw StateError('Falha ao finalizar gravação do comando (stop retornou null).');
    }

    return File(outPath);
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }
} , // lib/ai_storay/services/storay_transcribe_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class StorayTranscribeService {
  final Uri endpoint;

  StorayTranscribeService({required this.endpoint});

  /// Envia o arquivo gravado pro seu backend e recebe texto.
  Future<String> transcribe(File audioFile) async {
    final req = http.MultipartRequest('POST', endpoint);

    req.files.add(
      await http.MultipartFile.fromPath(
        'file',
        audioFile.path,
        filename: audioFile.uri.pathSegments.last,
      ),
    );

    final res = await req.send();
    final body = await res.stream.bytesToString();

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError('Transcribe falhou: ${res.statusCode} — $body');
    }

    final jsonMap = json.decode(body) as Map<String, dynamic>;
    final text = (jsonMap['text'] ?? '').toString().trim();

    if (text.isEmpty) {
      return '';
    }
    return text;
  }
} , // lib/ai_storay/services/storay_wake_service.dart
import 'package:porcupine_flutter/porcupine_manager.dart';


class StorayWakeService {
  PorcupineManager? _manager;
  bool _running = false;

  bool get isRunning => _running;

  /// Inicia wake word on-device (hotword real).
  ///
  /// [accessKey] vem do Picovoice Console.
  /// [keywordAssetPath] ex: assets/porcupine/storay.ppn
  Future<void> start({
    required String accessKey,
    required String keywordAssetPath,
    required void Function() onWake,
    double sensitivity = 0.6,
  }) async {
    if (_running) return;

    _manager = await PorcupineManager.fromKeywordPaths(
      accessKey,
      [keywordAssetPath],
      (keywordIndex) {
        if (keywordIndex == 0) onWake();
      },
      sensitivities: [sensitivity],
    );

    await _manager!.start();
    _running = true;
  }

  Future<void> stop() async {
    if (!_running) return;

    try {
      await _manager?.stop();
    } finally {
      _manager?.delete();
      _manager = null;
      _running = false;
    }
  }
} , // lib/ai_storay/state/storay_controller.dart
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/storay_usage_repository.dart';

// ⚠️ CONFIRA ESTE CAMINHO:
// o arquivo precisa existir em: lib/ai_storay/domain/storay_router.dart
// e a classe dentro dele precisa se chamar: StorayRouter
import '../domain/storay_router.dart';

import '../services/storay_audio_service.dart';
import '../services/storay_command_recorder.dart';
import '../services/storay_transcribe_service.dart';
import '../services/storay_wake_service.dart';
import 'storay_state.dart';

final storayControllerProvider =
    NotifierProvider<StorayController, StorayState>(StorayController.new);

class StorayController extends Notifier<StorayState> {
  late final StorayWakeService _wake;
  late final StorayCommandRecorder _recorder;
  late final StorayTranscribeService _transcribe;

  late final StorayAudioService _audio;
  late final StorayRouter _router;
  late final StorayUsageRepository _usage;

  bool _starting = false;
  bool _handling = false;

  @override
  StorayState build() {
    _wake = StorayWakeService();
    _recorder = StorayCommandRecorder();

    // ✅ Troque pelo seu endpoint (Cloud Function / servidor)
    _transcribe = StorayTranscribeService(
      endpoint: Uri.parse('https://SEU_BACKEND.com/storay/transcribe'),
    );

    _audio = StorayAudioService();

    // ✅ Se a classe não existir/import estiver errado, o erro aparece aqui.
    _router = StorayRouter();

    _usage = StorayUsageRepository(FirebaseFirestore.instance);

    Future.microtask(_startHotword);

    ref.onDispose(() async {
      await _wake.stop();
      await _recorder.dispose();
      await _audio.dispose();
    });

    return StorayState.initial().copyWith(
      status: StorayStatus.listeningForHotword,
      overlayVisible: false,
      lastHeard: null,
      errorMessage: null,
    );
  }

  Future<void> _startHotword() async {
    if (_starting) return;
    _starting = true;

    // Hotword roda invisível
    state = state.copyWith(
      status: StorayStatus.listeningForHotword,
      overlayVisible: false,
      lastHeard: null,
      errorMessage: null,
    );

    final canRecord = await _recorder.hasPermission();
    if (!canRecord) {
      state = state.copyWith(
        status: StorayStatus.error,
        overlayVisible: true,
        errorMessage: 'Permita o microfone para ativar a Storay.',
        lastHeard: 'Permissão necessária',
      );
      _starting = false;
      return;
    }

    // ✅ Você precisa do AccessKey e do .ppn.
    // AccessKey: Picovoice Console
    // .ppn: assets/porcupine/storay.ppn
    const accessKey = 'COLOQUE_SUA_ACCESS_KEY_DA_PICOVOICE';
    const keywordAsset = 'assets/porcupine/storay.ppn';

    try {
      await _wake.start(
        accessKey: accessKey,
        keywordAssetPath: keywordAsset,
        sensitivity: 0.6,
        onWake: _onWakeDetected,
      );
    } catch (e) {
      state = state.copyWith(
        status: StorayStatus.error,
        overlayVisible: true,
        errorMessage: 'Falha ao iniciar wake word: $e',
        lastHeard: null,
      );
    } finally {
      _starting = false;
    }
  }

  Future<void> _onWakeDetected() async {
    if (_handling) return;
    _handling = true;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      state = state.copyWith(
        status: StorayStatus.error,
        overlayVisible: true,
        errorMessage: 'Usuário não autenticado.',
        lastHeard: null,
      );
      _handling = false;
      return;
    }

    // ✅ Por enquanto você disse “foco em funcionar”.
    // Se quiser ignorar planos por agora, comente este bloco.
    final decision = await _usage.canUseToday(uid: uid, now: DateTime.now());
    if (!decision.allowed) {
      state = state.copyWith(
        status: StorayStatus.blocked,
        overlayVisible: true,
        errorMessage: 'Limite diário atingido (Free: 3/dia).',
        lastHeard: null,
      );

      await _audio.playPip();
      await Future.delayed(const Duration(milliseconds: 1200));
      await _returnToHotword();

      _handling = false;
      return;
    }

    // Para o wake word enquanto grava o comando (evita re-trigger)
    await _wake.stop();

    await _audio.playPip();

    // ✅ barra aparece só aqui
    state = state.copyWith(
      status: StorayStatus.listeningForCommand,
      overlayVisible: true,
      lastHeard: 'Ouvindo…',
      errorMessage: null,
    );

    File audioFile;
    try {
      audioFile = await _recorder.recordFor(
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      state = state.copyWith(
        status: StorayStatus.error,
        overlayVisible: true,
        errorMessage: 'Falha ao gravar comando: $e',
        lastHeard: null,
      );
      await Future.delayed(const Duration(milliseconds: 900));
      await _returnToHotword();
      _handling = false;
      return;
    }

    // Transcreve
    state = state.copyWith(
      status: StorayStatus.processing,
      lastHeard: 'Processando…',
    );

    String text = '';
    try {
      text = await _transcribe.transcribe(audioFile);
    } catch (e) {
      state = state.copyWith(
        status: StorayStatus.error,
        overlayVisible: true,
        errorMessage: 'Falha ao transcrever: $e',
        lastHeard: null,
      );
      await Future.delayed(const Duration(milliseconds: 900));
      await _returnToHotword();
      _handling = false;
      return;
    }

    // Se vier vazio, só volta pro hotword sem “som de erro”
    if (text.trim().isEmpty) {
      await _returnToHotword();
      _handling = false;
      return;
    }

    // Contabiliza uso (se você estiver usando o gate)
    await _usage.incrementToday(uid: uid, now: DateTime.now());

    // Roteia
    final normalized = _normalize(text);
    final result = _router.route(normalized);

    if (result == null) {
      state = state.copyWith(
        status: StorayStatus.error,
        overlayVisible: true,
        errorMessage: 'Não entendi. Ex: "Storay, buscar arroz".',
        lastHeard: 'Você disse: $text',
      );
      await Future.delayed(const Duration(milliseconds: 1500));
      await _returnToHotword();
      _handling = false;
      return;
    }

    state = state.copyWith(
      status: StorayStatus.responding,
      overlayVisible: true,
      errorMessage: null,
      lastHeard: 'Intent: ${result.intent} • ${result.slots}',
    );

    await Future.delayed(const Duration(milliseconds: 1200));
    await _returnToHotword();

    _handling = false;
  }

  Future<void> _returnToHotword() async {
    state = state.copyWith(
      overlayVisible: false,
      status: StorayStatus.listeningForHotword,
      lastHeard: null,
      errorMessage: null,
    );

    await _startHotword();
  }

  String _normalize(String input) {
    final lower = input.toLowerCase();
    return lower
        .replaceAll(RegExp(r'[^\w\sáàâãéèêíìîóòôõúùûç]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
} , // lib/ai_storay/state/storay_state.dart
enum StorayStatus {
  idle,
  listeningForHotword,
  listeningForCommand,
  processing,
  responding,
  blocked, // excedeu limite do plano free
  error,
}

class StorayState {
  final StorayStatus status;
  final bool overlayVisible;
  final String? lastHeard;
  final String? errorMessage;

  const StorayState({
    required this.status,
    required this.overlayVisible,
    this.lastHeard,
    this.errorMessage,
  });

  factory StorayState.initial() => const StorayState(
        status: StorayStatus.idle,
        overlayVisible: false,
      );

  StorayState copyWith({
    StorayStatus? status,
    bool? overlayVisible,
    String? lastHeard,
    String? errorMessage,
  }) {
    return StorayState(
      status: status ?? this.status,
      overlayVisible: overlayVisible ?? this.overlayVisible,
      lastHeard: lastHeard ?? this.lastHeard,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
} , // lib/ai_storay/ui/storay_bar.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class StorayBar extends StatelessWidget {
  final String statusText;

  const StorayBar({
    super.key,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottom),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF6D28D9), // roxo
                  Color(0xFF2563EB), // azul
                  Color(0xFF06B6D4), // ciano
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                _PulseDot(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    statusText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1).animate(_c),
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      ),
    );
  }
} , // lib/ai_storay/ui/storay_overlay.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/storay_controller.dart';
import 'storay_bar.dart';

class StorayOverlay extends ConsumerWidget {
  const StorayOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storayControllerProvider);

    if (!state.overlayVisible) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: true, // não bloqueia cliques no app
        child: Align(
          alignment: Alignment.bottomCenter,
          child: StorayBar(
            statusText: state.errorMessage ??
                (state.lastHeard?.isNotEmpty == true
                    ? state.lastHeard!
                    : 'Ouvindo…'),
          ),
        ),
      ),
    );
  }
} , // lib/ai_storay/ai_storay.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/storay_controller.dart';
import 'ui/storay_overlay.dart';

/// Envolva o seu app (ou uma árvore de telas) com isso
/// para habilitar a Storay no foreground.
class StorayScope extends ConsumerWidget {
  final Widget child;

  const StorayScope({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inicializa uma vez quando o scope aparece
    ref.listen(storayControllerProvider, (_, __) {});

    return Stack(
      children: [
        child,
        const StorayOverlay(),
      ],
    );
  }
} , name: mystoreday
description: "Controle de Estoque para o seu negócio."
publish_to: 'none'

version: 1.0.2+33

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
    
  flutter_localizations:
    sdk: flutter

  firebase_core: ^4.3.0
  cloud_firestore: ^6.1.1
  bcrypt: ^1.1.3
  google_fonts: ^6.1.0
  mobile_scanner: ^7.1.4
  intl: 0.20.2
  flutter_local_notifications: ^19.5.0
  permission_handler: ^12.0.1
  firebase_messaging: ^16.1.0
  cupertino_icons: ^1.0.8
  url_launcher: ^6.3.2
  shared_preferences: ^2.5.4
  fl_chart: ^1.1.1
  image_picker: ^1.2.1
  image: ^4.0.6
  firebase_storage: ^13.0.5
  path: ^1.9.1
  firebase_auth: ^6.1.3
  flutter_native_splash: ^2.4.4
  cached_network_image: ^3.4.1
  flutter_image_compress: ^2.4.0
  shimmer: ^3.0.0
  excel: ^4.0.6
  path_provider: ^2.1.5
  open_filex: ^4.7.0
  provider: ^6.1.5+1
  flutter_svg: ^2.2.3
  google_sign_in: ^7.2.0
  flutter_riverpod: ^2.6.1
  riverpod: ^2.6.1
  google_mobile_ads: ^7.0.0
  audioplayers: ^6.5.1
  porcupine_flutter: ^4.0.0
  record: ^6.2.0
  http: ^1.6.0



dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  flutter_launcher_icons: ^0.14.4

# ─────────────────────────────
# Ícone do app
# ─────────────────────────────
flutter_icons:
  android: true
  ios: true
  image_path: "assets/images/logo_controllstok.png"

# ─────────────────────────────
# Splash screen
# ─────────────────────────────
flutter_native_splash:
  color: "#ffffff"
  image: "assets/images/logo_controllstok.png"
  android: true
  ios: true

# ─────────────────────────────
# Assets
# ─────────────────────────────
flutter:
   generate: true
   uses-material-design: true
   assets:
   # sounds
   # ────────────ACTIVE STORAY──────────────
    - assets/porcupine/storay.ppn
    - assets/sounds/active_storay.wav 

    - assets/images/logo-controllstok-bac.png
    - assets/images/logo-and-name.png

    # gifs
    - assets/images/banners/gif/caixa-banner.gif
    - assets/images/banners/gif/company-banner.gif
    - assets/images/banners/gif/relatorios-banner.gif      , (assets/porcupine/storay.ppn ainda vazio, verifiquei lá no site oficial e parece ser caro pea usar em usuários logados na sua conta de estoque)
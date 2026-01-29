// lib/main.dart
// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; //
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';
import 'core/app_navigator.dart';
import 'core/locale_controller.dart';

import 'services/firebase_service.dart';
import 'notifications/notification_service.dart';
import 'notifications/save_fcm_token.dart';

import 'screens/home/home_screen.dart';
import 'screens/acounts/auth_choice/auth_choice_screen.dart';
import 'screens/acounts/register/register_screen.dart';
import 'screens/acounts/onboarding/company_screen.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 🔹 Handler para mensagens em background e app killed
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await FirebaseService.init();
  debugPrint('📩 Mensagem recebida em background/killed: ${message.data}');

  final data = message.data;
  if (data.containsKey('productName')) {
    await NotificationService.instance.showStockNotification(
      productName: data['productName'] ?? 'Produto',
      quantity: int.tryParse(data['quantity'] ?? '0') ?? 0,
      isCritical: data['isCritical'] == 'true',
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // 🔹 Mobile ADS
  await MobileAds.instance.initialize();

  // 🔹 Firebase
  await FirebaseService.init();

  // 🔹 Notificações locais (foreground e background)
  await NotificationService.instance.init();

  // 🔹 Handler background (obrigatório)
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  // 🔹 Date formatting (opcional)
  await initializeDateFormatting('pt_BR', null);

  // ✅ Carrega locale salvo ANTES de subir o app
  await LocaleController.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = GoogleFonts.poppinsTextTheme();

    return ValueListenableBuilder<Locale?>(
      valueListenable: LocaleController.notifier,
      builder: (context, overrideLocale, _) {
        return MaterialApp(
          navigatorKey: AppNavigator.key,
          debugShowCheckedModeBanner: false,

          // ✅ locale override manual (se existir). Se null, segue sistema.
          locale: overrideLocale,

          // ✅ título traduzível (sem depender de appTitle existir)
          onGenerateTitle: (context) {
            // TODO: Troque quando tiver a key no ARB:
            // return AppLocalizations.of(context)?.appName ?? 'MyStoreDay';
            return 'MyStoreDay';
          },

          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            textTheme: baseTextTheme,
          ),

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,

          // ✅ idioma do sistema; fallback en
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            // Se existe override, o Flutter já respeita `locale: overrideLocale`.
            if (overrideLocale != null) return overrideLocale;

            if (deviceLocale == null) return const Locale('en');

            for (final locale in supportedLocales) {
              if (locale.languageCode == deviceLocale.languageCode) {
                // se tiver match por país (pt_PT), melhor ainda
                if (locale.countryCode != null &&
                    deviceLocale.countryCode != null &&
                    locale.countryCode == deviceLocale.countryCode) {
                  return locale;
                }
                return locale;
              }
            }
            return const Locale('en');
          },

          home: const AuthGate(),
        );
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _tokenSaved = false;
  Map<String, dynamic>? _pendingNotification;

  // Ajuda a resetar estados quando troca de usuário (logout/login outro)
  String? _lastUid;

  // ✅ Cache do Future pra não criar Future novo a cada build
  Future<void>? _ensureDocFuture;

  @override
  void initState() {
    super.initState();

    // 🔹 Listener de notificações em foreground (app aberto)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final data = message.data;
      debugPrint('📩 Mensagem recebida em foreground: $data');

      if (data.containsKey('productName')) {
        await NotificationService.instance.showStockNotification(
          productName: data['productName'] ?? 'Produto',
          quantity: int.tryParse(data['quantity'] ?? '0') ?? 0,
          isCritical: data['isCritical'] == 'true',
        );
      }
    });

    // 🔹 Listener de clique em notificações (background ou app aberto)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _pendingNotification = message.data;
      _navigateToAlertsIfAllowed();
    });

    // 🔹 Notificação que abriu o app quando estava fechado
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _pendingNotification = message.data;
        _navigateToAlertsIfAllowed();
      }
    });
  }

  /// ✅ Detecta se existe REGISTRO PENDENTE (etapa “definir senha”)
  /// ⚠️ Só considera pendente se for do MESMO e-mail do usuário atual.
  Future<bool> _hasRegisterPendingForCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingEmail = prefs.getString('register_pending_email');
    final pass = prefs.getString('register_pending_temp_pass');

    if (pendingEmail == null || pass == null) return false;

    final currentEmail = (user.email ?? '').trim().toLowerCase();
    final storedEmail = pendingEmail.trim().toLowerCase();

    return currentEmail.isNotEmpty && currentEmail == storedEmail;
  }

  /// ✅ Garante que exista um documento do usuário no Firestore.
  Future<void> _ensureUserDoc(User user) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (snap.exists) return;

    await ref.set({
      'uid': user.uid,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
      'onboardingCompleted': false,
    }, SetOptions(merge: true));
  }

  void _navigateToAlertsIfAllowed() {
    final user = FirebaseAuth.instance.currentUser;
    if (_pendingNotification == null || user == null) return;

    AppNavigator.resetTo(const HomeScreen(initialIndex: 4));
    _pendingNotification = null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Erro ao autenticar: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        // ✅ Usuário NÃO logado
        if (!snapshot.hasData) {
          _tokenSaved = false;
          _lastUid = null;
          _ensureDocFuture = null;
          return const AuthChoiceScreen();
        }

        final user = snapshot.data!;

        // Se mudou de usuário, reseta flags + refaz future
        if (_lastUid != user.uid) {
          _lastUid = user.uid;
          _tokenSaved = false;
          _ensureDocFuture = _ensureUserDoc(user);
        }

        // Se ainda não inicializou (caso raro), inicializa
        _ensureDocFuture ??= _ensureUserDoc(user);

        // 0) garantir doc Firestore
        return FutureBuilder<void>(
          future: _ensureDocFuture,
          builder: (context, ensureSnap) {
            if (ensureSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // 1) Se existir register_pending_* => volta para RegisterScreen
            return FutureBuilder<bool>(
              future: _hasRegisterPendingForCurrentUser(user),
              builder: (context, pendingSnap) {
                if (pendingSnap.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final hasRegisterPending = pendingSnap.data == true;

                if (hasRegisterPending) {
                  _tokenSaved = false;
                  return const RegisterScreen();
                }

                // 2) onboarding no Firestore
                return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .snapshots(),
                  builder: (context, docSnap) {
                    if (docSnap.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final exists = docSnap.data?.exists == true;
                    final data = exists ? docSnap.data!.data() : null;

                    final onboardingCompleted =
                        data?['onboardingCompleted'] == true;

                    if (!onboardingCompleted) {
                      _tokenSaved = false;
                      return CompanyScreen(user: user);
                    }

                    // 3) tudo OK => Home
                    if (!_tokenSaved) {
                      _tokenSaved = true;
                      saveFcmTokenIfLoggedIn();
                    }

                    if (_pendingNotification != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _navigateToAlertsIfAllowed();
                      });

                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    return const HomeScreen();
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

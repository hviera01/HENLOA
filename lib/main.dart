import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/session/session.dart';
import 'core/session/session_scope.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_shell.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('es');
  runApp(HenloaApp(session: Session()));
}

class HenloaApp extends StatelessWidget {
  final Session session;
  const HenloaApp({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return SessionScope(
      session: session,
      child: MaterialApp(
        title: 'Henloa',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: AnimatedBuilder(
          animation: session,
          builder: (context, _) {
            if (session.cargando) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return session.haIniciadoSesion ? const HomeShell() : const LoginScreen();
          },
        ),
      ),
    );
  }
}
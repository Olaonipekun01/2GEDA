import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/app_models.dart';
import 'screens/home_shell.dart';
import 'screens/pair_screen.dart';
import 'services/auth_service.dart';
import 'services/pair_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init: $e');
  }

  runApp(
    const ProviderScope(
      child: TogetherForTwoApp(),
    ),
  );
}

class TogetherForTwoApp extends StatelessWidget {
  const TogetherForTwoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Together for Two',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE11D48),
          primary: const Color(0xFFE11D48),
          secondary: const Color(0xFFBE185D),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const RootGate(),
    );
  }
}

class RootGate extends ConsumerWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user == null) return const PairScreen();
        final profileAsync = ref.watch(currentUserProfileProvider);

        return profileAsync.when(
          data: (profile) {
            if (profile == null || profile.pairId == null || profile.pairId!.isEmpty) {
              return const PairScreen();
            }
            final pairAsync = ref.watch(activePairProvider);
            return pairAsync.when(
              data: (pair) => pair == null ? const PairScreen() : HomeShell(pair: pair, user: profile),
              loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFE11D48)))),
              error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
            );
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFE11D48)))),
          error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFE11D48)))),
      error: (err, _) => Scaffold(body: Center(child: Text('Auth error: $err'))),
    );
  }
}
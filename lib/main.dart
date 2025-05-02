import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neurodyx/core/providers/font_providers.dart';
import 'package:provider/provider.dart';
import 'core/wrappers/auth_wrapper.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi FontProvider
  final fontProvider = FontProvider();
  await fontProvider.initialize();

  runApp(MyApp(fontProvider: fontProvider));
}

class MyApp extends StatelessWidget {
  final FontProvider fontProvider;

  const MyApp({super.key, required this.fontProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider.value(value: fontProvider),
      ],
      child: Consumer<FontProvider>(
        builder: (context, fontProvider, child) {
          return MaterialApp(
            title: 'Neurodyx',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: fontProvider.selectedFont == 'Lexend Exa'
                  ? null
                  : 'OpenDyslexicMono',
              textTheme: fontProvider.selectedFont == 'Lexend Exa'
                  ? GoogleFonts.lexendExaTextTheme(
                      Theme.of(context).textTheme,
                    )
                  : Theme.of(context).textTheme.apply(
                        fontFamily: 'OpenDyslexicMono',
                      ),
            ),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

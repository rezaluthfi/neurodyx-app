import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neurodyx/core/providers/font_providers.dart';
import 'package:neurodyx/core/wrappers/auth_wrapper.dart';
import 'package:neurodyx/features/auth/presentation/providers/auth_provider.dart';
import 'package:neurodyx/features/chat/presentation/providers/chat_provider.dart';
import 'package:neurodyx/features/scan/data/repositories/scan_repository.dart';
import 'package:neurodyx/features/scan/data/services/text_action_service.dart';
import 'package:neurodyx/features/scan/data/services/text_recognition_service.dart';
import 'package:neurodyx/features/scan/data/services/tts_service.dart';
import 'package:neurodyx/features/scan/presentation/providers/scan_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize FontProvider
  final fontProvider = FontProvider();
  await fontProvider.initialize();

  // Load environment variables
  await dotenv.load(fileName: '.env');

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
        ChangeNotifierProvider(
          create: (context) => ScanProvider(
            scanRepository: ScanRepository(
              textRecognitionService: TextRecognitionService(),
            ),
            hideNavBarNotifier: ValueNotifier<bool>(false),
            fontProvider: Provider.of<FontProvider>(context, listen: false),
            ttsService: TtsService(),
            textActionService: TextActionService(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
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

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neurodyx/core/providers/font_providers.dart';
import 'package:neurodyx/core/services/connectivity_service.dart';
import 'package:neurodyx/core/wrappers/auth_wrapper.dart';
import 'package:neurodyx/features/auth/data/repositories/auth_repository.dart';
import 'package:neurodyx/features/auth/presentation/providers/auth_provider.dart';
import 'package:neurodyx/features/chat/presentation/providers/chat_provider.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/data/repositories/therapy_repository.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/data/services/therapy_services.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/multisensory_therapy_plan_page.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/providers/therapy_provider.dart';
import 'package:neurodyx/features/scan/data/repositories/scan_repository.dart';
import 'package:neurodyx/features/scan/data/services/text_action_service.dart';
import 'package:neurodyx/features/scan/data/services/text_recognition_service.dart';
import 'package:neurodyx/features/scan/data/services/tts_service.dart';
import 'package:neurodyx/features/scan/presentation/providers/scan_provider.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/data/repositories/screening_repository.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/data/services/screening_service.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/presentation/providers/screening_provider.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/data/services/assessment_service.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/data/repositories/assessment_repository.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/presentation/providers/assessment_provider.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/data/services/digital_ink_service.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/data/services/audio_service.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/domain/usecases/recognize_letter_usecase.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/domain/usecases/download_ink_model_usecase.dart';
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
        // Shared dependencies
        Provider<ConnectivityService>(create: (_) => ConnectivityService()),
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        // Screening feature dependencies
        Provider<ScreeningService>(
          create: (context) => ScreeningService(
            context.read<AuthRepository>(),
          ),
        ),
        Provider<ScreeningRepository>(
          create: (context) => ScreeningRepository(
            context.read<ScreeningService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ScreeningProvider(
            context.read<ScreeningRepository>(),
            context.read<ConnectivityService>(),
          ),
        ),
        // Assessment feature dependencies
        Provider<AssessmentService>(
          create: (context) => AssessmentService(
            context.read<AuthRepository>(),
          ),
        ),
        Provider<AssessmentRepository>(
          create: (context) => AssessmentRepository(
            context.read<AssessmentService>(),
          ),
        ),
        // Tactile Assessment and Therapy dependencies
        Provider<DigitalInkService>(create: (_) => DigitalInkService()),
        Provider<AudioService>(create: (_) => AudioService()),
        Provider<RecognizeLetterUseCase>(
          create: (context) =>
              RecognizeLetterUseCase(context.read<DigitalInkService>()),
        ),
        Provider<DownloadInkModelUseCase>(
          create: (context) =>
              DownloadInkModelUseCase(context.read<DigitalInkService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => AssessmentProvider(
            context.read<AssessmentRepository>(),
            context.read<ConnectivityService>(),
            context.read<DownloadInkModelUseCase>(),
          ),
        ),
        // Therapy feature dependencies
        Provider<TherapyService>(
          create: (context) => TherapyService(context.read<AuthRepository>()),
        ),
        Provider<TherapyRepository>(
          create: (context) =>
              TherapyRepository(context.read<TherapyService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => TherapyProvider(
            context.read<TherapyRepository>(),
            context.read<DigitalInkService>(),
          ),
        ),
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
            initialRoute: '/auth_wrapper',
            routes: {
              '/auth_wrapper': (context) => const AuthWrapper(),
              '/multisensory_therapy_plan': (context) =>
                  const MultisensoryTherapyPlanPage(),
            },
          );
        },
      ),
    );
  }
}

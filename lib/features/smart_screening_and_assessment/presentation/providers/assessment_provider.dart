import 'package:flutter/material.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/data/services/digital_ink_service.dart';
import 'package:neurodyx/core/widgets/custom_snack_bar.dart';
import 'package:neurodyx/core/services/connectivity_service.dart';
import 'package:neurodyx/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../data/models/assessment_question_model.dart';
import '../../data/repositories/assessment_repository.dart';
import '../../domain/usecases/download_ink_model_usecase.dart';

class AssessmentProvider with ChangeNotifier {
  final AssessmentRepository _assessmentRepository;
  final ConnectivityService _connectivityService;
  final DownloadInkModelUseCase _downloadInkModelUseCase;

  AssessmentProvider(
    this._assessmentRepository,
    this._connectivityService,
    this._downloadInkModelUseCase,
  );

  List<AssessmentQuestionModel> _questions = [];
  Map<String, List<Map<String, dynamic>>> _submissions = {
    'visual': [],
    'auditory': [],
    'kinesthetic': [],
    'tactile': [],
  };
  Map<String, int> _scores = {
    'visual': 0,
    'auditory': 0,
    'kinesthetic': 0,
    'tactile': 0,
  };
  Map<String, String> _statuses = {
    'visual': 'not started',
    'auditory': 'not started',
    'kinesthetic': 'not started',
    'tactile': 'not started',
  };
  Map<String, int> _totalQuestions = {
    'visual': 0,
    'auditory': 0,
    'kinesthetic': 0,
    'tactile': 0,
  };
  bool _isFetchingQuestions = false;
  bool _isSubmittingAnswers = false;
  String? _errorMessage;
  bool _isModelDownloaded = false;
  String _downloadStatus = 'checking';
  int _downloadAttempts = 0;
  double _downloadProgress = 0.0;
  static const int _maxDownloadAttempts = 3;
  // Flag to track if results have been fetched already
  bool _resultsAreLoaded = false;

  List<AssessmentQuestionModel> get questions => _questions;
  Map<String, int> get scores => _scores;
  Map<String, String> get statuses => _statuses;
  Map<String, int> get totalQuestions => _totalQuestions;
  bool get isLoading => _isFetchingQuestions || _isSubmittingAnswers;
  String? get errorMessage => _errorMessage;
  bool get isModelDownloaded => _isModelDownloaded;
  String get downloadStatus => _downloadStatus;
  int get downloadAttempts => _downloadAttempts;
  int get maxDownloadAttempts => _maxDownloadAttempts;
  double get downloadProgress => _downloadProgress;
  bool get resultsAreLoaded => _resultsAreLoaded;

  Future<void> fetchQuestions(BuildContext context) async {
    if (_isFetchingQuestions) return;

    _isFetchingQuestions = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final isConnected =
          await _connectivityService.checkInternetConnection(context);
      if (!isConnected) {
        _errorMessage = 'No internet connection';
        _isFetchingQuestions = false;
        notifyListeners();
        return;
      }

      await Provider.of<AuthProvider>(context, listen: false)
          .ensureValidToken();
      _questions = await _assessmentRepository.getQuestions();

      _totalQuestions = {
        'visual': _questions.where((q) => q.type == 'visual').length,
        'auditory': _questions.where((q) => q.type == 'auditory').length,
        'kinesthetic': _questions.where((q) => q.type == 'kinesthetic').length,
        'tactile': _questions.where((q) => q.type == 'tactile').length,
      };
      _isFetchingQuestions = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isFetchingQuestions = false;
      notifyListeners();
    }
  }

  void prepareModelInitialization() {
    if (_downloadStatus == 'done' || _downloadStatus == 'downloading') return;

    _downloadStatus = 'checking';
    _downloadAttempts = 0;
    _downloadProgress = 0.0;
    notifyListeners();
  }

  Future<void> initializeModel(BuildContext context) async {
    if (_downloadStatus == 'done' || _downloadStatus == 'downloading') return;

    if (_downloadStatus != 'downloading') {
      _downloadStatus = 'downloading';
      Future.microtask(() {
        notifyListeners();
        if (context.mounted) {
          CustomSnackBar.show(
            context,
            message: 'Downloading recognition model...',
            type: SnackBarType.success,
          );
        }
      });
    }

    try {
      final digitalInkService = context.read<DigitalInkService>();

      // Listen to progress updates
      digitalInkService.downloadProgress.listen(
        (progress) {
          _downloadProgress = progress;
          notifyListeners();
        },
        onError: (e) {
          _downloadStatus = 'error';
          _downloadProgress = 0.0;
          notifyListeners();
        },
        onDone: () {
          _downloadProgress = 1.0;
          notifyListeners();
        },
      );

      final success = await _downloadInkModelUseCase.execute();

      if (success) {
        _isModelDownloaded = true;
        _downloadStatus = 'done';
        Future.microtask(() => notifyListeners());
        return;
      }

      _downloadAttempts++;
      if (_downloadAttempts < _maxDownloadAttempts) {
        Future.delayed(const Duration(seconds: 2)).then((_) {
          if (context.mounted) {
            _downloadStatus = 'checking';
            _downloadProgress = 0.0;
            Future.microtask(() => notifyListeners());
            Future.microtask(() {
              if (context.mounted) {
                initializeModel(context);
              }
            });
          }
        });
        return;
      }

      _downloadStatus = 'error';
      _downloadProgress = 0.0;
      Future.microtask(() {
        notifyListeners();
        if (context.mounted) {
          CustomSnackBar.show(
            context,
            message:
                'Failed to download recognition model after $_maxDownloadAttempts attempts.',
            type: SnackBarType.error,
          );
        }
      });
    } catch (e) {
      _downloadAttempts++;
      if (_downloadAttempts < _maxDownloadAttempts) {
        Future.delayed(const Duration(seconds: 2)).then((_) {
          if (context.mounted) {
            _downloadStatus = 'checking';
            _downloadProgress = 0.0;
            Future.microtask(() => notifyListeners());
            Future.microtask(() {
              if (context.mounted) {
                initializeModel(context);
              }
            });
          }
        });
        return;
      }

      _downloadStatus = 'error';
      _downloadProgress = 0.0;
      Future.microtask(() {
        notifyListeners();
        if (context.mounted) {
          CustomSnackBar.show(
            context,
            message: 'Error initializing recognizer: $e',
            type: SnackBarType.error,
          );
        }
      });
    }
  }

  void addAnswer(String type, String questionId, dynamic answer) {
    _submissions[type]!.add({
      'questionId': questionId,
      'answer': answer,
    });
    notifyListeners();
  }

  Future<Map<String, dynamic>> submitAnswers(String type) async {
    if (_submissions[type]!.isEmpty) {
      _errorMessage = 'No answers provided for $type';
      notifyListeners();
      return {'success': false, 'message': _errorMessage!};
    }

    _isSubmittingAnswers = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result =
          await _assessmentRepository.submitAnswers(type, _submissions[type]!);
      _scores[type] = result.correctAnswers;
      _statuses[type] = result.status;
      _submissions[type] = [];
      _isSubmittingAnswers = false;
      notifyListeners();
      return {'success': true, 'message': 'Answers submitted successfully'};
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isSubmittingAnswers = false;
      notifyListeners();
      return {'success': false, 'message': _errorMessage!};
    }
  }

  Future<void> fetchResults(BuildContext context) async {
    // Prevent multiple fetches if already loaded or in progress
    if (_isFetchingQuestions || _resultsAreLoaded) return;

    _isFetchingQuestions = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final isConnected =
          await _connectivityService.checkInternetConnection(context);
      if (!isConnected) {
        _errorMessage = 'No internet connection';
        _isFetchingQuestions = false;
        notifyListeners();
        return;
      }

      await Provider.of<AuthProvider>(context, listen: false)
          .ensureValidToken();
      final results = await _assessmentRepository.getResults();
      for (var result in results) {
        _scores[result.type] = result.correctAnswers;
        _statuses[result.type] = result.status;
        _totalQuestions[result.type] = result.totalQuestions;
      }
      _resultsAreLoaded = true; // Mark results as loaded
      _isFetchingQuestions = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isFetchingQuestions = false;
      notifyListeners();
    }
  }

  void reset() {
    _questions = [];
    _submissions = {
      'visual': [],
      'auditory': [],
      'kinesthetic': [],
      'tactile': [],
    };
    _scores = {
      'visual': 0,
      'auditory': 0,
      'kinesthetic': 0,
      'tactile': 0,
    };
    _statuses = {
      'visual': 'not started',
      'auditory': 'not started',
      'kinesthetic': 'not started',
      'tactile': 'not started',
    };
    _totalQuestions = {
      'visual': 0,
      'auditory': 0,
      'kinesthetic': 0,
      'tactile': 0,
    };
    _isFetchingQuestions = false;
    _isSubmittingAnswers = false;
    _errorMessage = null;
    _isModelDownloaded = false;
    _downloadStatus = 'checking';
    _downloadAttempts = 0;
    _downloadProgress = 0.0;
    _resultsAreLoaded = false; // Reset the results loaded flag
    notifyListeners();
  }
}

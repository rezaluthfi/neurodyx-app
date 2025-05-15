import 'package:flutter/material.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/domain/repositories/therapy_repository_base.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/data/models/therapy_category_model.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/data/models/therapy_question_model.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/data/models/therapy_result_model.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/data/services/digital_ink_service.dart';

class TherapyProvider with ChangeNotifier {
  final TherapyRepositoryBase _repository;
  final DigitalInkService _digitalInkService;
  List<TherapyCategoryModel> _categories = [];
  List<TherapyQuestionModel> _questions = [];
  List<Map<String, dynamic>> _answers = [];
  TherapyResultModel? _result;
  bool _isLoading = false;
  String? _error;
  String _downloadStatus =
      'idle'; // 'idle', 'checking', 'downloading', 'error', 'downloaded'
  double _downloadProgress = 0.0;
  int _downloadAttempts = 0;
  final int _maxDownloadAttempts = 3;
  bool _isModelDownloaded = false;

  TherapyProvider(this._repository, this._digitalInkService);

  // Getters
  List<TherapyCategoryModel> get categories => _categories;
  List<TherapyQuestionModel> get questions => _questions;
  TherapyResultModel? get result => _result;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get downloadStatus => _downloadStatus;
  double get downloadProgress => _downloadProgress;
  int get downloadAttempts => _downloadAttempts;
  int get maxDownloadAttempts => _maxDownloadAttempts;
  bool get isModelDownloaded => _isModelDownloaded;

  Future<void> initializeModel() async {
    // Skip if already downloaded and no errors
    if (_downloadStatus == 'downloaded' && _isModelDownloaded) {
      debugPrint('Model already downloaded, skipping initialization');
      return;
    }

    _downloadStatus = 'checking';
    _downloadAttempts = 0;
    _error = null;
    notifyListeners();

    try {
      debugPrint('Checking model availability...');
      _isModelDownloaded = await _digitalInkService.checkAndDownloadModel();
      debugPrint('Model check result: $_isModelDownloaded');
      if (_isModelDownloaded) {
        _downloadStatus = 'downloaded';
        _downloadProgress = 1.0;
      } else {
        _downloadStatus = 'error';
        _error = 'Model download failed';
      }
    } catch (e, stackTrace) {
      debugPrint('Error checking model: $e\n$stackTrace');
      _downloadStatus = 'error';
      _error = e.toString();
    } finally {
      notifyListeners();
    }

    // Listen to download progress
    _digitalInkService.downloadProgress.listen(
      (progress) {
        _downloadProgress = progress;
        if (_downloadStatus != 'downloading') {
          _downloadStatus = 'downloading';
          _downloadAttempts++;
        }
        notifyListeners();
      },
      onError: (e, stackTrace) {
        debugPrint('Download progress error: $e\n$stackTrace');
        _downloadStatus = 'error';
        _error = e.toString();
        notifyListeners();
      },
      onDone: () {
        if (_downloadStatus != 'error') {
          _downloadStatus = 'downloaded';
          _isModelDownloaded = true;
          _downloadProgress = 1.0;
        }
        notifyListeners();
      },
    );
  }

  Future<void> fetchCategories(String type) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _categories = await _repository.getCategories(type);
      debugPrint(
          'Fetched categories: ${_categories.map((c) => c.category).toList()}');
    } catch (e, stackTrace) {
      _error = e.toString();
      debugPrint('Error fetching categories: $e\n$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchQuestions(String type, String category) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _questions = await _repository.getQuestions(type, category);
      debugPrint('Fetched questions: ${_questions.length} for $type/$category');
      for (var q in _questions) {
        debugPrint(
            'Question ID: ${q.id}, Content: ${q.content}, CorrectAnswer: ${q.correctAnswer}');
      }
    } catch (e, stackTrace) {
      _error = e.toString();
      debugPrint('Error fetching questions: $e\n$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addAnswer(String type, String questionId, String answer) {
    _answers.removeWhere((ans) => ans['questionId'] == questionId);
    _answers.add({
      'type': type,
      'questionId': questionId,
      'answer': answer,
    });
    debugPrint(
        'Added answer: type=$type, questionId=$questionId, answer=$answer');
    final question = _questions.firstWhere(
      (q) => q.id == questionId,
      orElse: () => throw Exception('Question not found: $questionId'),
    );
    debugPrint('Correct answer for $questionId: ${question.correctAnswer}');
    notifyListeners();
  }

  Future<void> submitAnswers(String type, String category) async {
    try {
      _isLoading = true;
      _error = null;
      debugPrint('Submitting answers: $_answers');
      notifyListeners();

      TherapyResultModel serverResult;
      try {
        debugPrint('Calling _repository.submitAnswers with answers: $_answers');
        final formattedAnswers = _answers.map((answer) {
          return {
            'type': answer['type'],
            'questionId': answer['questionId'],
            'answer': answer['answer'].split(','),
          };
        }).toList();
        serverResult =
            await _repository.submitAnswers(type, category, formattedAnswers);
        debugPrint(
            'Server submission successful: correctAnswers=${serverResult.correctAnswers}, totalQuestions=${serverResult.totalQuestions}');
      } catch (e, stackTrace) {
        debugPrint('Repository submitAnswers failed: $e\n$stackTrace');
        serverResult = TherapyResultModel(
          type: type,
          category: category,
          correctAnswers: 0,
          totalQuestions: _questions.length,
          status: 'error',
        );
      }

      int correctAnswers = 0;
      int totalAnswered = _answers.length;

      debugPrint('===== CLIENT-SIDE VALIDATION =====');
      debugPrint('Total answers submitted: $totalAnswered');

      for (var answer in _answers) {
        final questionId = answer['questionId'] as String;
        final userAnswer = answer['answer'] as String?;

        final question = _questions.firstWhere(
          (q) => q.id == questionId,
          orElse: () {
            debugPrint('WARNING: Question not found: $questionId');
            return TherapyQuestionModel(
              id: questionId,
              type: type,
              category: category,
              correctAnswer: null,
            );
          },
        );

        final correctAnswer =
            question.correctSequence?.join(',') ?? question.correctAnswer;

        debugPrint('Question ID: $questionId');
        debugPrint('User answer: "$userAnswer"');
        debugPrint('Correct answer: "$correctAnswer"');

        bool isCorrect = false;
        if (userAnswer != null && correctAnswer != null) {
          final userAnswerParts = userAnswer.split(',').toList()..sort();
          final correctAnswerParts = correctAnswer.split(',').toList()..sort();
          isCorrect = userAnswerParts.join(',') == correctAnswerParts.join(',');
          debugPrint('Normalized user answer: "${userAnswerParts.join(',')}"');
          debugPrint(
              'Normalized correct answer: "${correctAnswerParts.join(',')}"');
          debugPrint('Is correct? $isCorrect');
        } else {
          debugPrint(
              'WARNING: Null value detected - userAnswer or correctAnswer is null');
        }

        if (isCorrect) {
          correctAnswers++;
        }
      }

      debugPrint(
          'Server results - correctAnswers: ${serverResult.correctAnswers}, totalQuestions: ${serverResult.totalQuestions}');
      debugPrint(
          'Client results - correctAnswers: $correctAnswers, totalAnswered: $totalAnswered');

      _result = TherapyResultModel(
        type: type,
        category: category,
        correctAnswers: correctAnswers,
        totalQuestions: _questions.length,
        status: serverResult.status == 'error' ? 'error' : 'completed',
      );

      debugPrint(
          'Final result set to: correctAnswers=$correctAnswers, totalQuestions=${_questions.length}, status=${_result?.status}');
      debugPrint('submitAnswers completed, result: $_result');
      _answers.clear();
    } catch (e, stackTrace) {
      _error = e.toString();
      debugPrint('Critical error in submitAnswers: $e\n$stackTrace');
      _result = TherapyResultModel(
        type: type,
        category: category,
        correctAnswers: 0,
        totalQuestions: _questions.length,
        status: 'error',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchResults(String type, String category) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _result = await _repository.getResults(type, category);
      debugPrint(
          'Fetched results: correctAnswers=${_result?.correctAnswers}, totalQuestions=${_result?.totalQuestions}');
    } catch (e, stackTrace) {
      _error = e.toString();
      debugPrint('Error fetching results: $e\n$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _categories.clear();
    _questions.clear();
    _answers.clear();
    _result = null;
    _error = null;
    _isLoading = false;
    _downloadStatus = 'idle';
    _downloadProgress = 0.0;
    _downloadAttempts = 0;
    _isModelDownloaded = false;
    _digitalInkService.reset(); // Reset DigitalInkService
    debugPrint('Provider reset, including DigitalInkService');
    notifyListeners();
  }
}

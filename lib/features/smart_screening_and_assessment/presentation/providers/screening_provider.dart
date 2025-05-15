import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/screening_question_model.dart';
import '../../data/models/screening_result_model.dart';
import '../../data/repositories/screening_repository.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ScreeningProvider with ChangeNotifier {
  final ScreeningRepository _screeningRepository;
  final ConnectivityService _connectivityService;

  ScreeningProvider(this._screeningRepository, this._connectivityService);

  List<QuestionModel> _questions = [];
  List<bool?> _answers = [];
  ScreeningResultModel? _result;
  bool _isFetchingQuestions = false;
  bool _isSubmittingAnswers = false;
  String? _errorMessage;
  String? _ageGroup;

  List<QuestionModel> get questions => _questions;
  List<bool?> get answers => _answers;
  ScreeningResultModel? get result => _result;
  bool get isLoading => _isFetchingQuestions || _isSubmittingAnswers;
  bool get isFetchingQuestions => _isFetchingQuestions;
  bool get isSubmittingAnswers => _isSubmittingAnswers;
  String? get errorMessage => _errorMessage;
  String? get ageGroup => _ageGroup;

  Future<void> fetchQuestions(String ageGroup, BuildContext context) async {
    _isFetchingQuestions = true;
    _errorMessage = null;
    _ageGroup = ageGroup;
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

      _questions = await _screeningRepository.getQuestions(ageGroup);
      _answers = List.filled(_questions.length, null);
      _isFetchingQuestions = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isFetchingQuestions = false;
      notifyListeners();
    }
  }

  void answerQuestion(int index, bool answer) {
    _answers[index] = answer;
    notifyListeners();
  }

  Future<void> submitAnswers(BuildContext context) async {
    if (_answers.contains(null)) {
      _errorMessage = 'Please answer all questions';
      notifyListeners();
      return;
    }

    if (_answers.isEmpty) {
      _errorMessage = 'Answers cannot be empty';
      notifyListeners();
      return;
    }

    if (_answers.length > 50) {
      _errorMessage = 'Answers exceed maximum limit of 50';
      notifyListeners();
      return;
    }

    if (_ageGroup == null) {
      _errorMessage = 'Age group not specified';
      notifyListeners();
      return;
    }

    _isSubmittingAnswers = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final isConnected =
          await _connectivityService.checkInternetConnection(context);
      if (!isConnected) {
        _errorMessage = 'No internet connection';
        _isSubmittingAnswers = false;
        notifyListeners();
        return;
      }

      await Provider.of<AuthProvider>(context, listen: false)
          .ensureValidToken();

      _result = await _screeningRepository.submitAnswers(
        _answers.cast<bool>(),
        _ageGroup!,
      );
      _isSubmittingAnswers = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmittingAnswers = false;
      notifyListeners();
    }
  }

  void reset() {
    _questions = [];
    _answers = [];
    _result = null;
    _isFetchingQuestions = false;
    _isSubmittingAnswers = false;
    _errorMessage = null;
    _ageGroup = null;
    notifyListeners();
  }
}

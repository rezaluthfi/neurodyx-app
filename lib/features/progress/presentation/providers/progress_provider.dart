import 'package:flutter/material.dart';
import '../../domain/entities/progress_entity.dart';
import '../../domain/usecases/fetch_progress_usecase.dart';
import 'package:neurodyx/features/auth/presentation/providers/auth_provider.dart';

class ProgressProvider with ChangeNotifier {
  final FetchProgressUseCase fetchProgressUseCase;
  final AuthProvider authProvider;

  ProgressProvider({
    required this.fetchProgressUseCase,
    required this.authProvider,
  });

  List<WeeklyProgressEntity> _weeklyProgress = [];
  List<MonthlyProgressEntity> _monthlyProgress = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<WeeklyProgressEntity> get weeklyProgress => _weeklyProgress;
  List<MonthlyProgressEntity> get monthlyProgress => _monthlyProgress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProgress() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Ensure we have a valid token before making API calls
      await authProvider.ensureValidToken();

      final (weekly, monthly) = await fetchProgressUseCase.execute();
      _weeklyProgress = weekly;
      _monthlyProgress = monthly;
    } catch (e) {
      if (e.toString().contains('invalid token') ||
          e.toString().contains('token expired') ||
          e.toString().contains('Unauthorized')) {
        _errorMessage = 'Your session has expired. Please sign in again.';
        // Try to refresh token or redirect to login
        try {
          await authProvider.checkAuthStatus();
          if (authProvider.isAuthenticated) {
            // If we're still authenticated after checking status, try again
            await fetchProgress();
            return;
          }
        } catch (_) {
          // If refreshing failed, let the error message stand
        }
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

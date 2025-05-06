// Represents the current state of the TTS service
class TtsState {
  final bool isTtsPlaying;
  final bool isTtsInitializing;
  final bool isSettingSpeechRate;
  final double speechRate;
  final String? currentTtsText;
  final String detectedLanguage;

  const TtsState({
    this.isTtsPlaying = false,
    this.isTtsInitializing = false,
    this.isSettingSpeechRate = false,
    this.speechRate = 0.4,
    this.currentTtsText,
    this.detectedLanguage = 'en-US',
  });

  // Create a copy of this state with specified fields replaced
  TtsState copyWith({
    bool? isTtsPlaying,
    bool? isTtsInitializing,
    bool? isSettingSpeechRate,
    double? speechRate,
    String? currentTtsText,
    String? detectedLanguage,
  }) {
    return TtsState(
      isTtsPlaying: isTtsPlaying ?? this.isTtsPlaying,
      isTtsInitializing: isTtsInitializing ?? this.isTtsInitializing,
      isSettingSpeechRate: isSettingSpeechRate ?? this.isSettingSpeechRate,
      speechRate: speechRate ?? this.speechRate,
      currentTtsText: currentTtsText ?? this.currentTtsText,
      detectedLanguage: detectedLanguage ?? this.detectedLanguage,
    );
  }

  // Clear the current TTS text
  TtsState clearCurrentText() {
    return copyWith(currentTtsText: null);
  }
}

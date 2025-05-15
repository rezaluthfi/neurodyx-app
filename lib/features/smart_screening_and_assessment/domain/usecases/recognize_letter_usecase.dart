import 'package:scribble/scribble.dart';
import '../../data/services/digital_ink_service.dart';

class RecognizeLetterUseCase {
  final DigitalInkService _digitalInkService;

  RecognizeLetterUseCase(this._digitalInkService);

  Future<String?> execute(List<SketchLine> lines) async {
    return await _digitalInkService.recognizeLetter(lines);
  }
}

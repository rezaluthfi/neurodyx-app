import '../../data/services/digital_ink_service.dart';

class DownloadInkModelUseCase {
  final DigitalInkService _digitalInkService;

  DownloadInkModelUseCase(this._digitalInkService);

  Future<bool> execute() async {
    return await _digitalInkService.checkAndDownloadModel();
  }
}

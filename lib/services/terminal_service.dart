import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum TerminalModel {
  l300,
  l400,
  p2,
  p2Mini,
  a8Gpos700x,
  gpos720,
  gpos780,
  unknown
}

class TerminalService extends GetxService {
  static const platform = MethodChannel('br.com.sistema_vistorias/terminal_sdk');
  
  final _currentModel = TerminalModel.unknown.obs;
  final _isInitialized = false.obs;
  final _printerAvailable = false.obs;
  final _nfcAvailable = false.obs;
  
  bool get isInitialized => _isInitialized.value;
  bool get hasPrinter => _printerAvailable.value;
  bool get hasNfc => _nfcAvailable.value;
  TerminalModel get model => _currentModel.value;

  // Singleton
  static TerminalService get to => Get.find<TerminalService>();

  @override
  void onInit() {
    super.onInit();
    _detectTerminal();
  }

  Future<void> _detectTerminal() async {
    try {
      final result = await platform.invokeMethod('getTerminalInfo');
      
      _currentModel.value = _parseModel(result['model'] as String);
      _printerAvailable.value = result['hasPrinter'] as bool;
      _nfcAvailable.value = result['hasNfc'] as bool;
      _isInitialized.value = true;

      print('Terminal detectado: ${_currentModel.value}');
      print('Impressora: ${_printerAvailable.value}');
      print('NFC: ${_nfcAvailable.value}');
    } on PlatformException catch (e) {
      print('Erro ao detectar terminal: ${e.message}');
      _isInitialized.value = false;
    }
  }

  TerminalModel _parseModel(String model) {
    switch (model.toLowerCase()) {
      case 'l300':
        return TerminalModel.l300;
      case 'l400':
        return TerminalModel.l400;
      case 'p2':
        return TerminalModel.p2;
      case 'p2mini':
        return TerminalModel.p2Mini;
      case 'a8gpos700x':
        return TerminalModel.a8Gpos700x;
      case 'gpos720':
        return TerminalModel.gpos720;
      case 'gpos780':
        return TerminalModel.gpos780;
      default:
        return TerminalModel.unknown;
    }
  }

  bool get isGertec => [
    TerminalModel.gpos720,
    TerminalModel.gpos780,
  ].contains(_currentModel.value);

  bool get isElgin => [
    TerminalModel.l300,
    TerminalModel.l400,
  ].contains(_currentModel.value);

  bool get isPax => [
    TerminalModel.p2,
    TerminalModel.p2Mini,
    TerminalModel.a8Gpos700x,
  ].contains(_currentModel.value);

  Future<Map<String, dynamic>> getPrinterStatus() async {
    if (!_printerAvailable.value) {
      return {
        'available': false,
        'error': 'Terminal sem impressora',
      };
    }

    try {
      final result = await platform.invokeMethod('getPrinterStatus');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      return {
        'available': false,
        'error': e.message,
      };
    }
  }

  Future<bool> printText({
    required String text,
    bool bold = false,
    bool doubleWidth = false,
    bool doubleHeight = false,
    bool center = false,
  }) async {
    if (!_printerAvailable.value) {
      return false;
    }

    try {
      final result = await platform.invokeMethod('printText', {
        'text': text,
        'bold': bold,
        'doubleWidth': doubleWidth,
        'doubleHeight': doubleHeight,
        'center': center,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      print('Erro ao imprimir: ${e.message}');
      return false;
    }
  }

  Future<bool> printQrCode(String data) async {
    if (!_printerAvailable.value) {
      return false;
    }

    try {
      final result = await platform.invokeMethod('printQrCode', {
        'data': data,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      print('Erro ao imprimir QR Code: ${e.message}');
      return false;
    }
  }

  Future<bool> cutPaper() async {
    if (!_printerAvailable.value) {
      return false;
    }

    try {
      final result = await platform.invokeMethod('cutPaper');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Erro ao cortar papel: ${e.message}');
      return false;
    }
  }

  Future<bool> feedPaper(int lines) async {
    if (!_printerAvailable.value) {
      return false;
    }

    try {
      final result = await platform.invokeMethod('feedPaper', {
        'lines': lines,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      print('Erro ao avançar papel: ${e.message}');
      return false;
    }
  }

  Future<String?> readNfc() async {
    if (!_nfcAvailable.value) {
      return null;
    }

    try {
      final result = await platform.invokeMethod('readNfc');
      return result as String?;
    } on PlatformException catch (e) {
      print('Erro ao ler NFC: ${e.message}');
      return null;
    }
  }
}

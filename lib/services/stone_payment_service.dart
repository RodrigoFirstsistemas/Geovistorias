import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'terminal_service.dart';

enum PaymentType {
  credit,
  debit,
  pix
}

enum TransactionStatus {
  approved,
  denied,
  cancelled,
  processing,
  error
}

class StonePaymentService extends GetxService {
  static const platform = MethodChannel('br.com.sistema_vistorias/stone_sdk');
  
  final _isInitialized = false.obs;
  final _stoneCode = ''.obs;
  final _isProcessing = false.obs;
  
  bool get isInitialized => _isInitialized.value;
  String get stoneCode => _stoneCode.value;
  bool get isProcessing => _isProcessing.value;

  // Singleton
  static StonePaymentService get to => Get.find<StonePaymentService>();

  late final TerminalService _terminal;

  @override
  void onInit() {
    super.onInit();
    _terminal = Get.find<TerminalService>();
    _initializeSdk();
  }

  Future<void> _initializeSdk() async {
    try {
      if (!_terminal.isInitialized) {
        print('Terminal não inicializado');
        return;
      }

      final result = await platform.invokeMethod('initializeSdk');
      _isInitialized.value = result ?? false;
      
      if (_isInitialized.value) {
        print('Stone SDK inicializado com sucesso');
        print('Terminal: ${_terminal.model}');
      } else {
        print('Falha ao inicializar Stone SDK');
      }
    } on PlatformException catch (e) {
      print('Erro ao inicializar Stone SDK: ${e.message}');
      _isInitialized.value = false;
    }
  }

  Future<bool> activateCode(String stoneCode) async {
    try {
      if (!_terminal.isInitialized) {
        print('Terminal não inicializado');
        return false;
      }

      final result = await platform.invokeMethod('activateCode', {
        'stoneCode': stoneCode,
      });
      
      if (result == true) {
        _stoneCode.value = stoneCode;
        return true;
      }
      return false;
    } on PlatformException catch (e) {
      print('Erro ao ativar código Stone: ${e.message}');
      return false;
    }
  }

  Future<Map<String, dynamic>> makePayment({
    required double amount,
    required String orderId,
    required int installments,
    required PaymentType paymentType,
    String? customerName,
    String? customerDocument,
  }) async {
    if (!_isInitialized.value) {
      throw Exception('SDK Stone não inicializado');
    }

    if (!_terminal.isInitialized) {
      throw Exception('Terminal não inicializado');
    }

    if (_isProcessing.value) {
      throw Exception('Já existe uma transação em andamento');
    }

    try {
      _isProcessing.value = true;

      final result = await platform.invokeMethod('makePayment', {
        'amount': (amount * 100).toInt(), // Converter para centavos
        'orderId': orderId,
        'installments': installments.toString(),
        'paymentType': paymentType.toString().split('.').last,
        'customerName': customerName,
        'customerDocument': customerDocument,
        'terminalModel': _terminal.model.toString().split('.').last,
      });

      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw Exception('Erro ao processar pagamento: ${e.message}');
    } finally {
      _isProcessing.value = false;
    }
  }

  Future<Map<String, dynamic>> cancelPayment({
    required String transactionId,
    required double amount,
    String? reason,
  }) async {
    if (!_isInitialized.value) {
      throw Exception('SDK Stone não inicializado');
    }

    if (!_terminal.isInitialized) {
      throw Exception('Terminal não inicializado');
    }

    if (_isProcessing.value) {
      throw Exception('Já existe uma transação em andamento');
    }

    try {
      _isProcessing.value = true;

      final result = await platform.invokeMethod('cancelPayment', {
        'transactionId': transactionId,
        'amount': (amount * 100).toInt(), // Converter para centavos
        'reason': reason,
        'terminalModel': _terminal.model.toString().split('.').last,
      });

      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw Exception('Erro ao cancelar pagamento: ${e.message}');
    } finally {
      _isProcessing.value = false;
    }
  }

  Future<TransactionStatus> getTransactionStatus(String transactionId) async {
    if (!_isInitialized.value) {
      throw Exception('SDK Stone não inicializado');
    }

    if (!_terminal.isInitialized) {
      throw Exception('Terminal não inicializado');
    }

    try {
      final result = await platform.invokeMethod('getTransactionStatus', {
        'transactionId': transactionId,
        'terminalModel': _terminal.model.toString().split('.').last,
      });

      final status = result['status'] as String;
      switch (status.toLowerCase()) {
        case 'approved':
          return TransactionStatus.approved;
        case 'denied':
          return TransactionStatus.denied;
        case 'cancelled':
          return TransactionStatus.cancelled;
        case 'processing':
          return TransactionStatus.processing;
        default:
          return TransactionStatus.error;
      }
    } on PlatformException catch (e) {
      print('Erro ao consultar status: ${e.message}');
      return TransactionStatus.error;
    }
  }

  Future<bool> printReceipt({
    required String transactionId,
    required bool isCustomerCopy,
  }) async {
    if (!_isInitialized.value) {
      throw Exception('SDK Stone não inicializado');
    }

    if (!_terminal.isInitialized) {
      throw Exception('Terminal não inicializado');
    }

    if (!_terminal.hasPrinter) {
      throw Exception('Terminal sem impressora');
    }

    try {
      final status = await _terminal.getPrinterStatus();
      if (status['available'] != true) {
        throw Exception(status['error'] ?? 'Erro na impressora');
      }

      final result = await platform.invokeMethod('printReceipt', {
        'transactionId': transactionId,
        'isCustomerCopy': isCustomerCopy,
        'terminalModel': _terminal.model.toString().split('.').last,
      });

      return result ?? false;
    } on PlatformException catch (e) {
      print('Erro ao imprimir comprovante: ${e.message}');
      return false;
    }
  }

  Future<bool> checkPinpadConnection() async {
    if (!_isInitialized.value || !_terminal.isInitialized) {
      return false;
    }

    try {
      final result = await platform.invokeMethod('checkPinpadConnection', {
        'terminalModel': _terminal.model.toString().split('.').last,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      print('Erro ao verificar conexão com pinpad: ${e.message}');
      return false;
    }
  }
}

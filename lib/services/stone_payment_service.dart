import 'package:flutter/services.dart';
import 'package:get/get.dart';

class StonePaymentService extends GetxService {
  static const platform = MethodChannel('br.com.sistema_vistorias/stone_sdk');
  
  final _isInitialized = false.obs;
  final _stoneCode = ''.obs;
  
  bool get isInitialized => _isInitialized.value;
  String get stoneCode => _stoneCode.value;

  @override
  void onInit() {
    super.onInit();
    _initializeSdk();
  }

  Future<void> _initializeSdk() async {
    try {
      final result = await platform.invokeMethod('initializeSdk');
      _isInitialized.value = result ?? false;
    } on PlatformException catch (e) {
      print('Error initializing Stone SDK: ${e.message}');
    }
  }

  Future<void> activateCode(String stoneCode) async {
    try {
      final result = await platform.invokeMethod('activateCode', {
        'stoneCode': stoneCode,
      });
      
      if (result == true) {
        _stoneCode.value = stoneCode;
      }
    } on PlatformException catch (e) {
      throw Exception('Erro ao ativar código Stone: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> makePayment({
    required double amount,
    required String orderId,
    required String installments,
    required String paymentType,
  }) async {
    if (!_isInitialized.value) {
      throw Exception('SDK Stone não inicializado');
    }

    try {
      final result = await platform.invokeMethod('makePayment', {
        'amount': (amount * 100).toInt(), // Converter para centavos
        'orderId': orderId,
        'installments': installments,
        'paymentType': paymentType,
      });

      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw Exception('Erro ao processar pagamento: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> cancelPayment({
    required String transactionId,
    required double amount,
  }) async {
    if (!_isInitialized.value) {
      throw Exception('SDK Stone não inicializado');
    }

    try {
      final result = await platform.invokeMethod('cancelPayment', {
        'transactionId': transactionId,
        'amount': (amount * 100).toInt(), // Converter para centavos
      });

      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw Exception('Erro ao cancelar pagamento: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> getTransactionStatus(String transactionId) async {
    if (!_isInitialized.value) {
      throw Exception('SDK Stone não inicializado');
    }

    try {
      final result = await platform.invokeMethod('getTransactionStatus', {
        'transactionId': transactionId,
      });

      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw Exception('Erro ao consultar status: ${e.message}');
    }
  }

  Future<void> printReceipt(String transactionId) async {
    if (!_isInitialized.value) {
      throw Exception('SDK Stone não inicializado');
    }

    try {
      await platform.invokeMethod('printReceipt', {
        'transactionId': transactionId,
      });
    } on PlatformException catch (e) {
      throw Exception('Erro ao imprimir comprovante: ${e.message}');
    }
  }
}

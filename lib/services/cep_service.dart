import 'package:dio/dio.dart';

class CepService {
  static final CepService _instance = CepService._internal();
  final Dio _dio = Dio();

  factory CepService() {
    return _instance;
  }

  CepService._internal();

  static CepService get to => _instance;

  Future<Map<String, dynamic>> fetchAddressByCep(String cep) async {
    try {
      // Remove caracteres não numéricos do CEP
      final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
      
      if (cleanCep.length != 8) {
        throw Exception('CEP inválido');
      }

      final response = await _dio.get('https://viacep.com.br/ws/$cleanCep/json/');
      
      if (response.data['erro'] == true) {
        throw Exception('CEP não encontrado');
      }

      return {
        'cep': response.data['cep'],
        'street': response.data['logradouro'],
        'neighborhood': response.data['bairro'],
        'city': response.data['localidade'],
        'state': response.data['uf'],
        'complement': response.data['complemento'],
      };
    } catch (e) {
      if (e is DioException) {
        throw Exception('Erro ao buscar CEP: Verifique sua conexão');
      }
      rethrow;
    }
  }
}

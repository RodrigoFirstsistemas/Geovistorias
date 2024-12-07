import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cash_register_model.dart';
import '../models/cash_transaction_model.dart';
import 'auth_service.dart';

// Enum para os status do caixa
enum CashRegisterStatus {
  open,
  closed,
  blocked,
}

// Enum para os tipos de transações
enum TransactionType {
  opening,
  closing,
  sangria,
}

// Exceção personalizada para erros no caixa
class CashRegisterException implements Exception {
  final String message;
  CashRegisterException(this.message);

  @override
  String toString() => 'CashRegisterException: $message';
}

class CashRegisterService extends GetxService {
  static CashRegisterService get to => Get.find();
  final _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService.to;

  // Abrir Caixa
  Future<CashRegisterModel> openCashRegister({
    required double initialAmount,
    String? notes,
  }) async {
    try {
      final userId = _authService.currentUser.value?.id;
      final orgId = _authService.currentUser.value?.organizationId;

      if (userId == null || orgId == null) {
        throw CashRegisterException('Usuário não autenticado');
      }

      // Verificar se já existe um caixa aberto
      final openRegisters = await _supabase
          .from('cash_registers')
          .select()
          .eq('organization_id', orgId)
          .eq('status', CashRegisterStatus.open.toString())
          .execute();

      if (openRegisters.count > 0) {
        throw CashRegisterException('Já existe um caixa aberto');
      }

      // Criar novo caixa
      final cashRegister = {
        'organization_id': orgId,
        'user_id': userId,
        'opened_at': DateTime.now().toIso8601String(),
        'initial_amount': initialAmount,
        'current_amount': initialAmount,
        'status': CashRegisterStatus.open.toString(),
        'notes': notes,
      };

      final response = await _supabase
          .from('cash_registers')
          .insert(cashRegister)
          .select()
          .single();

      // Registrar transação de abertura
      await _registerTransaction(
        response['id'],
        TransactionType.opening,
        initialAmount,
        'Abertura de caixa',
      );

      return CashRegisterModel.fromJson(response);
    } catch (e) {
      throw CashRegisterException('Erro ao abrir caixa: ${e.toString()}');
    }
  }

  // Fechar Caixa
  Future<CashRegisterModel> closeCashRegister({
    required String cashRegisterId,
    required double closingAmount,
    String? notes,
  }) async {
    try {
      final userId = _authService.currentUser.value?.id;
      if (userId == null)
        throw CashRegisterException('Usuário não autenticado');

      // Verificar permissões
      if (!await _hasPermission(cashRegisterId)) {
        throw CashRegisterException('Sem permissão para fechar o caixa');
      }

      // Atualizar caixa
      final response = await _supabase
          .from('cash_registers')
          .update({
            'closed_at': DateTime.now().toIso8601String(),
            'closing_amount': closingAmount,
            'status': CashRegisterStatus.closed.toString(),
            'notes': notes,
          })
          .eq('id', cashRegisterId)
          .select()
          .single();

      // Registrar transação de fechamento
      await _registerTransaction(
        cashRegisterId,
        TransactionType.closing,
        closingAmount,
        'Fechamento de caixa',
      );

      return CashRegisterModel.fromJson(response);
    } catch (e) {
      throw CashRegisterException('Erro ao fechar caixa: ${e.toString()}');
    }
  }

  // Realizar Sangria
  Future<CashTransaction> performSangria({
    required String cashRegisterId,
    required double amount,
    String? description,
    String? approvedBy,
  }) async {
    try {
      final userId = _authService.currentUser.value?.id;
      if (userId == null)
        throw CashRegisterException('Usuário não autenticado');

      // Verificar permissões
      if (!await _hasPermission(cashRegisterId)) {
        throw CashRegisterException('Sem permissão para realizar sangria');
      }

      // Verificar se o caixa está aberto
      final register = await getCashRegister(cashRegisterId);
      if (!register.isOpen) {
        throw CashRegisterException('Caixa não está aberto');
      }

      // Verificar se há saldo suficiente
      if (amount > register.currentAmount) {
        throw CashRegisterException('Saldo insuficiente para sangria');
      }

      // Atualizar saldo do caixa
      await _supabase.from('cash_registers').update({
        'current_amount': register.currentAmount - amount,
      }).eq('id', cashRegisterId);

      // Registrar transação de sangria
      return await _registerTransaction(
        cashRegisterId,
        TransactionType.sangria,
        amount,
        description ?? 'Sangria',
        approvedBy: approvedBy,
      );
    } catch (e) {
      throw CashRegisterException('Erro ao realizar sangria: ${e.toString()}');
    }
  }

  // Bloquear/Desbloquear Caixa
  Future<CashRegisterModel> toggleCashRegisterBlock({
    required String cashRegisterId,
    required bool blocked,
    String? reason,
  }) async {
    try {
      final userId = _authService.currentUser.value?.id;
      if (userId == null)
        throw CashRegisterException('Usuário não autenticado');

      // Verificar permissões administrativas
      if (!await _hasAdminPermission()) {
        throw CashRegisterException('Sem permissão administrativa');
      }

      final response = await _supabase
          .from('cash_registers')
          .update({
            'status': blocked
                ? CashRegisterStatus.blocked.toString()
                : CashRegisterStatus.open.toString(),
            'notes': reason,
          })
          .eq('id', cashRegisterId)
          .select()
          .single();

      return CashRegisterModel.fromJson(response);
    } catch (e) {
      throw CashRegisterException(
          'Erro ao alterar status do caixa: ${e.toString()}');
    }
  }

  // Obter Caixa
  Future<CashRegisterModel> getCashRegister(String cashRegisterId) async {
    try {
      final response = await _supabase.from('cash_registers').select('''
            *,
            transactions:cash_transactions(*)
          ''').eq('id', cashRegisterId).single();

      return CashRegisterModel.fromJson(response);
    } catch (e) {
      throw CashRegisterException('Erro ao buscar caixa: ${e.toString()}');
    }
  }

  // Obter Caixas por Organização
  Future<List<CashRegisterModel>> getCashRegisters(String organizationId) async {
    try {
      final response = await _supabase
          .from('cash_registers')
          .select('''
            *,
            transactions:cash_transactions(*)
          ''')
          .eq('organization_id', organizationId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => CashRegisterModel.fromJson(json)).toList();
    } catch (e) {
      throw CashRegisterException('Erro ao buscar caixas: ${e.toString()}');
    }
  }

  // Obter Caixa Aberto
  Future<CashRegisterModel?> getOpenRegister(String organizationId) async {
    try {
      final response = await _supabase
          .from('cash_registers')
          .select('''
            *,
            transactions:cash_transactions(*)
          ''')
          .match({
            'organization_id': organizationId,
            'status': CashRegisterStatus.open.toString(),
          })
          .maybeSingle();

      return response != null ? CashRegisterModel.fromJson(response) : null;
    } catch (e) {
      throw CashRegisterException('Erro ao buscar caixa aberto: ${e.toString()}');
    }
  }

  // Registrar Transação
  Future<CashTransaction> _registerTransaction(
    String cashRegisterId,
    TransactionType type,
    double amount,
    String description, {
    String? approvedBy,
  }) async {
    try {
      final userId = _authService.currentUser.value?.id;
      if (userId == null)
        throw CashRegisterException('Usuário não autenticado');

      final transaction = {
        'cash_register_id': cashRegisterId,
        'user_id': userId,
        'type': type.toString(),
        'amount': amount,
        'timestamp': DateTime.now().toIso8601String(),
        'description': description,
        'approved_by': approvedBy,
      };

      final response = await _supabase
          .from('cash_transactions')
          .insert(transaction)
          .select()
          .single();

      return CashTransaction.fromJson(response);
    } catch (e) {
      throw CashRegisterException(
          'Erro ao registrar transação: ${e.toString()}');
    }
  }

  // Validar valor
  void _validateAmount(double amount) {
    if (amount <= 0) {
      throw CashRegisterException('O valor deve ser maior que zero');
    }
  }

  // Validar status do caixa
  void _validateRegisterStatus(CashRegisterModel register) {
    if (register.status == CashRegisterStatus.blocked) {
      throw CashRegisterException('O caixa está bloqueado');
    }
    if (register.status == CashRegisterStatus.closed) {
      throw CashRegisterException('O caixa está fechado');
    }
  }

  // Verificar Permissões
  Future<bool> _hasPermission(String cashRegisterId) async {
    try {
      final userId = _authService.currentUser.value?.id;

      if (userId == null) return false;

      final register = await getCashRegister(cashRegisterId);
      return register.userId == userId || await _hasAdminPermission();
    } catch (e) {
      return false;
    }
  }

  Future<bool> _hasAdminPermission() async {
    return _authService.hasRole(UserRole.admin);
  }
}

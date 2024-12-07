import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/cash_register_model.dart';
import '../services/cash_register_service.dart';

class CashRegisterController extends GetxController {
  final CashRegisterService _cashRegisterService = CashRegisterService.to;
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<CashRegisterModel?> currentRegister = Rx<CashRegisterModel?>(null);
  final RxList<CashTransaction> transactions = <CashTransaction>[].obs;

  // Abrir Caixa
  Future<void> openCashRegister({
    required double initialAmount,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final register = await _cashRegisterService.openCashRegister(
        initialAmount: initialAmount,
        notes: notes,
      );

      currentRegister.value = register;
      Get.back();
      Get.snackbar(
        'Sucesso',
        'Caixa aberto com sucesso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erro',
        'Erro ao abrir caixa: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fechar Caixa
  Future<void> closeCashRegister({
    required String cashRegisterId,
    required double closingAmount,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final register = await _cashRegisterService.closeCashRegister(
        cashRegisterId: cashRegisterId,
        closingAmount: closingAmount,
        notes: notes,
      );

      currentRegister.value = register;
      Get.back();
      Get.snackbar(
        'Sucesso',
        'Caixa fechado com sucesso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erro',
        'Erro ao fechar caixa: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Realizar Sangria
  Future<void> performSangria({
    required String cashRegisterId,
    required double amount,
    String? description,
    String? approvedBy,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _cashRegisterService.performSangria(
        cashRegisterId: cashRegisterId,
        amount: amount,
        description: description,
        approvedBy: approvedBy,
      );

      // Recarregar caixa atual
      await loadCashRegister(cashRegisterId);

      Get.back();
      Get.snackbar(
        'Sucesso',
        'Sangria realizada com sucesso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erro',
        'Erro ao realizar sangria: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Bloquear/Desbloquear Caixa
  Future<void> toggleCashRegisterBlock({
    required String cashRegisterId,
    required bool blocked,
    String? reason,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final register = await _cashRegisterService.toggleCashRegisterBlock(
        cashRegisterId: cashRegisterId,
        blocked: blocked,
        reason: reason,
      );

      currentRegister.value = register;
      Get.back();
      Get.snackbar(
        'Sucesso',
        blocked ? 'Caixa bloqueado com sucesso' : 'Caixa desbloqueado com sucesso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erro',
        'Erro ao alterar status do caixa: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Carregar Caixa
  Future<void> loadCashRegister(String cashRegisterId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final register = await _cashRegisterService.getCashRegister(cashRegisterId);
      currentRegister.value = register;
      transactions.value = register.transactions;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erro',
        'Erro ao carregar caixa: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Calcular Diferença
  double calculateDifference() {
    return currentRegister.value?.calculateDifference() ?? 0;
  }

  // Verificar se há diferença no caixa
  bool hasDifference() {
    return calculateDifference().abs() > 0.01;
  }

  // Obter resumo do caixa
  Map<String, double> getCashSummary() {
    if (currentRegister.value == null) return {};

    return {
      'Valor Inicial': currentRegister.value!.initialAmount,
      'Entradas': currentRegister.value!.totalDeposits,
      'Saídas': currentRegister.value!.totalWithdrawals,
      'Sangrias': currentRegister.value!.totalSangria,
      'Saldo Atual': currentRegister.value!.currentAmount,
      'Diferença': calculateDifference(),
    };
  }
}

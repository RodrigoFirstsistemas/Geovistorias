import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/sale_model.dart';
import '../services/sales_report_service.dart';
import '../services/isar_service.dart';
import '../utils/file_utils.dart';

class SalesReportController extends GetxController {
  final _reportService = SalesReportService.to;
  final _isarService = Get.find<IsarService>();
  
  final searchController = TextEditingController();
  final startDate = Rx<DateTime?>(null);
  final endDate = Rx<DateTime?>(null);
  final selectedStatus = Rx<SaleStatus?>(null);
  final foundSale = Rx<SaleModel?>(null);
  final isLoading = false.obs;

  void setDateRange(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value = end;
  }

  void setStatus(SaleStatus? status) {
    selectedStatus.value = status;
  }

  Future<void> generateSalesReport() async {
    try {
      isLoading.value = true;
      
      final report = await _reportService.generateSalesReport(
        startDate: startDate.value,
        endDate: endDate.value,
        status: selectedStatus.value,
      );

      await FileUtils.openFile(report);
      
      Get.snackbar(
        'Sucesso',
        'Relatório de vendas gerado com sucesso',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao gerar relatório: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateCancellationsReport() async {
    try {
      isLoading.value = true;
      
      final report = await _reportService.generateCancellationsReport(
        startDate: startDate.value,
        endDate: endDate.value,
      );

      await FileUtils.openFile(report);
      
      Get.snackbar(
        'Sucesso',
        'Relatório de cancelamentos gerado com sucesso',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao gerar relatório: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchSale() async {
    try {
      isLoading.value = true;
      final saleId = searchController.text.trim();
      
      if (saleId.isEmpty) {
        Get.snackbar(
          'Atenção',
          'Digite o número da venda',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final sale = await _isarService.getSaleById(saleId);
      if (sale == null) {
        Get.snackbar(
          'Atenção',
          'Venda não encontrada',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      foundSale.value = sale;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao buscar venda: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reprintSale(String saleId) async {
    try {
      isLoading.value = true;
      
      final receipt = await _reportService.reprintSale(saleId);
      await FileUtils.openFile(receipt);
      
      Get.snackbar(
        'Sucesso',
        'Comprovante reimpresso com sucesso',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao reimprimir comprovante: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/report_service.dart';
import '../models/inspection_model.dart';

class ReportController extends GetxController {
  final ReportService _reportService = ReportService.to;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Exportar PDF
  Future<void> exportToPDF(InspectionModel inspection) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final file = await _reportService.generatePDF(inspection);
      await _reportService.shareFile(
        file,
        text: 'Relatório de Vistoria - ${inspection.id}',
      );

      Get.snackbar(
        'Sucesso',
        'PDF gerado com sucesso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erro',
        'Erro ao gerar PDF: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Exportar Excel
  Future<void> exportToExcel(List<InspectionModel> inspections) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final file = await _reportService.generateExcel(inspections);
      await _reportService.shareFile(
        file,
        text: 'Relatório de Vistorias - Excel',
      );

      Get.snackbar(
        'Sucesso',
        'Excel gerado com sucesso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erro',
        'Erro ao gerar Excel: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Exportar XML
  Future<void> exportToXML(List<InspectionModel> inspections) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final file = await _reportService.generateXML(inspections);
      await _reportService.shareFile(
        file,
        text: 'Relatório de Vistorias - XML',
      );

      Get.snackbar(
        'Sucesso',
        'XML gerado com sucesso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erro',
        'Erro ao gerar XML: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Enviar por Email
  Future<void> sendByEmail({
    required String email,
    required InspectionModel inspection,
    required List<String> formats,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final attachments = <File>[];

      // Gerar arquivos solicitados
      if (formats.contains('pdf')) {
        attachments.add(await _reportService.generatePDF(inspection));
      }
      if (formats.contains('excel')) {
        attachments.add(await _reportService.generateExcel([inspection]));
      }
      if (formats.contains('xml')) {
        attachments.add(await _reportService.generateXML([inspection]));
      }

      await _reportService.sendEmail(
        to: email,
        subject: 'Relatório de Vistoria - ${inspection.id}',
        body: 'Segue em anexo o relatório da vistoria ${inspection.id}.',
        attachments: attachments,
      );

      Get.snackbar(
        'Sucesso',
        'Email enviado com sucesso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erro',
        'Erro ao enviar email: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Enviar por WhatsApp
  Future<void> sendByWhatsApp({
    required String phone,
    required InspectionModel inspection,
    String? format = 'pdf',
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      File? attachment;
      if (format == 'pdf') {
        attachment = await _reportService.generatePDF(inspection);
      } else if (format == 'excel') {
        attachment = await _reportService.generateExcel([inspection]);
      } else if (format == 'xml') {
        attachment = await _reportService.generateXML([inspection]);
      }

      await _reportService.sendWhatsApp(
        phone: phone,
        message: 'Relatório da vistoria ${inspection.id}',
        attachment: attachment,
      );

      Get.snackbar(
        'Sucesso',
        'Mensagem enviada com sucesso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erro',
        'Erro ao enviar mensagem: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

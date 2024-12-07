import 'dart:convert';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../models/document_template_model.dart';
import '../services/document_template_service.dart';

class DocumentTemplateController extends GetxController {
  final _service = DocumentTemplateService.to;
  final templates = <DocumentTemplate>[].obs;
  final isLoading = false.obs;
  final error = Rx<String?>(null);
  final RxBool isSelected = false.obs;
  final Rx<DocumentTemplate?> selectedTemplate = Rx<DocumentTemplate?>(null);
  final Rx<DocumentConfig?> documentConfig = Rx<DocumentConfig?>(null);

  @override
  void onInit() {
    super.onInit();
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    try {
      isLoading.value = true;
      error.value = null;
      templates.value = await _service.getOrganizationTemplates();
    } catch (e) {
      error.value = 'Erro ao carregar templates: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createTemplate(DocumentTemplate template) async {
    try {
      isLoading.value = true;
      error.value = null;
      final newTemplate = await _service.createTemplate(template);
      templates.add(newTemplate);
      Get.back();
      Get.snackbar(
        'Sucesso',
        'Template criado com sucesso',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Erro ao criar template: ${e.toString()}';
      Get.snackbar(
        'Erro',
        error.value!,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTemplate(DocumentTemplate template) async {
    try {
      isLoading.value = true;
      error.value = null;
      final updatedTemplate = await _service.updateTemplate(template);
      final index = templates.indexWhere((t) => t.id == template.id);
      if (index != -1) {
        templates[index] = updatedTemplate;
      }
      Get.back();
      Get.snackbar(
        'Sucesso',
        'Template atualizado com sucesso',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Erro ao atualizar template: ${e.toString()}';
      Get.snackbar(
        'Erro',
        error.value!,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTemplate(String templateId) async {
    try {
      isLoading.value = true;
      error.value = null;
      await _service.deleteTemplate(templateId);
      templates.removeWhere((t) => t.id == templateId);
      Get.back();
      Get.snackbar(
        'Sucesso',
        'Template excluído com sucesso',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Erro ao excluir template: ${e.toString()}';
      Get.snackbar(
        'Erro',
        error.value!,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateDocument({
    required DocumentTemplate template,
    required Map<String, dynamic> data,
    required DocumentConfig config,
  }) async {
    try {
      isLoading.value = true;
      error.value = null;

      final file = switch (template.type) {
        DocumentType.pdf => await _service.generatePDF(
            template: template,
            data: data,
            config: config,
          ),
        DocumentType.word => await _service.generateWord(
            template: template,
            data: data,
            config: config,
          ),
        DocumentType.receipt => await _service.generateReceipt(
            template: template,
            data: data,
            config: config,
          ),
      };

      // Compartilhar arquivo
      await Share.shareFiles(
        [file.path],
        text: 'Documento gerado',
      );

      Get.snackbar(
        'Sucesso',
        'Documento gerado com sucesso',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Erro ao gerar documento: ${e.toString()}';
      Get.snackbar(
        'Erro',
        error.value!,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> parseJsonConfig(String jsonString) {
    try {
      if (jsonString.isEmpty) return {};
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'JSON inválido: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return {};
    }
  }

  void selectTemplate(DocumentTemplate template) {
    selectedTemplate.value = template;
    isSelected.value = true;
  }

  void updateDocumentConfig(DocumentConfig config) {
    documentConfig.value = config;
  }
}

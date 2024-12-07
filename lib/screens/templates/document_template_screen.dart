import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/document_template_controller.dart';
import '../../models/document_template_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/document_template_dialog.dart';

class DocumentTemplateScreen extends StatelessWidget {
  final controller = Get.put(DocumentTemplateController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Templates de Documentos'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showTemplateDialog(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.templates.isEmpty) {
          return Center(
            child: Text('Nenhum template encontrado'),
          );
        }

        return ListView.builder(
          itemCount: controller.templates.length,
          itemBuilder: (context, index) {
            final template = controller.templates[index];
            return _buildTemplateCard(template);
          },
        );
      }),
    );
  }

  Widget _buildTemplateCard(DocumentTemplate template) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(template.name),
        subtitle: Text(_getDocumentTypeText(template.type)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _showTemplateDialog(template: template),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(template),
            ),
          ],
        ),
        onTap: () async {
          final result = await Get.dialog(
            DocumentTemplateDialog(
              template: template,
              title: template.name,
              description: template.description ?? '',
              isDefault: template.isDefault,
            ),
          );
        },
      ),
    );
  }

  String _getDocumentTypeText(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return 'PDF';
      case DocumentType.word:
        return 'Word';
      case DocumentType.receipt:
        return 'Recibo';
    }
  }

  void _showTemplateDialog({DocumentTemplate? template}) {
    final nameController = TextEditingController(text: template?.name);
    final templateController = TextEditingController(text: template?.template);
    final headerController = TextEditingController(
        text: template?.headerConfig != null ? jsonEncode(template!.headerConfig) : '{}');
    final footerController = TextEditingController(
        text: template?.footerConfig != null ? jsonEncode(template!.footerConfig) : '{}');
    final bodyController = TextEditingController(
        text: template?.bodyConfig != null ? jsonEncode(template!.bodyConfig) : '{}');

    DocumentType selectedType = template?.type ?? DocumentType.pdf;

    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.8,
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  template == null ? 'Novo Template' : 'Editar Template',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                CustomTextField(
                  controller: nameController,
                  labelText: 'Nome do Template',
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<DocumentType>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Documento',
                  ),
                  items: DocumentType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getDocumentTypeText(type)),
                    );
                  }).toList(),
                  onChanged: (value) {},
                ),
                SizedBox(height: 8),
                CustomTextField(
                  controller: templateController,
                  labelText: 'Template HTML/DOCX',
                  maxLines: 5,
                ),
                SizedBox(height: 8),
                CustomTextField(
                  controller: headerController,
                  labelText: 'Configuração do Cabeçalho (JSON)',
                  maxLines: 3,
                ),
                SizedBox(height: 8),
                CustomTextField(
                  controller: footerController,
                  labelText: 'Configuração do Rodapé (JSON)',
                  maxLines: 3,
                ),
                SizedBox(height: 8),
                CustomTextField(
                  controller: bodyController,
                  labelText: 'Configuração do Corpo (JSON)',
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancelar'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Criar ou atualizar template
                        final newTemplate = DocumentTemplate(
                          id: template?.id ?? '',
                          organizationId: template?.organizationId ?? '',
                          name: nameController.text,
                          type: selectedType,
                          template: templateController.text,
                          headerConfig: _parseJson(headerController.text),
                          footerConfig: _parseJson(footerController.text),
                          bodyConfig: _parseJson(bodyController.text),
                          isDefault: template?.isDefault ?? false,
                          createdAt: template?.createdAt ?? DateTime.now(),
                          updatedAt: DateTime.now(),
                        );

                        if (template == null) {
                          controller.createTemplate(newTemplate);
                        } else {
                          controller.updateTemplate(newTemplate);
                        }
                      },
                      child: Text(template == null ? 'Criar' : 'Atualizar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(DocumentTemplate template) {
    Get.dialog(
      AlertDialog(
        title: Text('Excluir Template'),
        content: Text('Deseja realmente excluir o template "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => controller.deleteTemplate(template.id),
            child: Text('Excluir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _showPreviewDialog(DocumentTemplate template) {
    final dataController = TextEditingController(text: '{}');

    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.8,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Visualizar Template',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: dataController,
                labelText: 'Dados para Teste (JSON)',
                maxLines: 5,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancelar'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Gerar documento de teste
                      controller.generateDocument(
                        template: template,
                        data: _parseJson(dataController.text),
                        config: DocumentConfig(
                          logoPath: '',
                          companyName: 'Empresa Teste',
                          address: 'Endereço Teste',
                          phone: '(00) 0000-0000',
                          email: 'teste@empresa.com',
                          website: 'www.empresa.com',
                          cnpj: '00.000.000/0000-00',
                          colors: {
                            'primary': '#000000',
                            'secondary': '#666666',
                          },
                          margins: {
                            'all': 20,
                          },
                          additionalInfo: {},
                        ),
                      );
                    },
                    child: Text('Gerar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _parseJson(String jsonString) {
    try {
      return Map<String, dynamic>.from(
          jsonString.isEmpty ? {} : json.decode(jsonString));
    } catch (e) {
      return {};
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../services/report_service.dart';

class ReportOptions extends StatelessWidget {
  final String title;
  final Map<String, dynamic> data;
  final String type; // 'property', 'inspection', or 'client'

  const ReportOptions({
    Key? key,
    required this.title,
    required this.data,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => [
        _buildPopupMenuItem(
          'PDF',
          Icons.picture_as_pdf,
          'pdf',
          context,
        ),
        _buildPopupMenuItem(
          'Word',
          Icons.description,
          'docx',
          context,
        ),
        _buildPopupMenuItem(
          'Excel',
          Icons.table_chart,
          'xlsx',
          context,
        ),
        const PopupMenuDivider(),
        _buildPopupMenuItem(
          'Enviar por Email',
          Icons.email,
          'email',
          context,
        ),
        _buildPopupMenuItem(
          'Enviar por WhatsApp',
          Icons.whatsapp,
          'whatsapp',
          context,
        ),
      ],
      onSelected: (value) => _handleReportAction(value, context),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
    String text,
    IconData icon,
    String value,
    BuildContext context,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: AppTheme.paddingSmall),
          Text(text),
        ],
      ),
    );
  }

  void _handleReportAction(String action, BuildContext context) async {
    try {
      switch (action) {
        case 'pdf':
          await _showReportOptionsDialog(context, 'PDF');
          break;
        case 'docx':
          await _showReportOptionsDialog(context, 'Word');
          break;
        case 'xlsx':
          await _showReportOptionsDialog(context, 'Excel');
          break;
        case 'email':
          await _showEmailDialog(context);
          break;
        case 'whatsapp':
          await _showWhatsAppDialog(context);
          break;
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível gerar o relatório: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _showReportOptionsDialog(BuildContext context, String format) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Opções do Relatório $format'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                value: true,
                onChanged: (value) {},
                title: const Text('Informações Básicas'),
              ),
              CheckboxListTile(
                value: true,
                onChanged: (value) {},
                title: const Text('Fotos'),
              ),
              CheckboxListTile(
                value: true,
                onChanged: (value) {},
                title: const Text('Histórico'),
              ),
              if (type == 'property') ...[
                CheckboxListTile(
                  value: true,
                  onChanged: (value) {},
                  title: const Text('Vistorias'),
                ),
              ],
              if (type == 'inspection') ...[
                CheckboxListTile(
                  value: true,
                  onChanged: (value) {},
                  title: const Text('Checklist'),
                ),
                CheckboxListTile(
                  value: true,
                  onChanged: (value) {},
                  title: const Text('Observações'),
                ),
              ],
              if (type == 'client') ...[
                CheckboxListTile(
                  value: true,
                  onChanged: (value) {},
                  title: const Text('Imóveis'),
                ),
                CheckboxListTile(
                  value: true,
                  onChanged: (value) {},
                  title: const Text('Vistorias'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Get.back();
              Get.dialog(
                const Center(
                  child: CircularProgressIndicator(),
                ),
                barrierDismissible: false,
              );
              
              try {
                final reportPath = await ReportService.generateReport(
                  type: type,
                  format: format.toLowerCase(),
                  data: data,
                );
                
                Get.back();
                Get.snackbar(
                  'Sucesso',
                  'Relatório gerado com sucesso!',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
                
                // Abrir o relatório
                ReportService.openFile(reportPath);
              } catch (e) {
                Get.back();
                Get.snackbar(
                  'Erro',
                  'Não foi possível gerar o relatório: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            icon: const Icon(Icons.file_download),
            label: const Text('Gerar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEmailDialog(BuildContext context) {
    final emailController = TextEditingController();
    final subjectController = TextEditingController(text: 'Relatório - $title');
    final messageController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enviar por Email'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Digite o email do destinatário',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Assunto',
                ),
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Mensagem',
                  hintText: 'Digite uma mensagem opcional',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              Row(
                children: [
                  const Text('Formato:'),
                  const SizedBox(width: AppTheme.paddingSmall),
                  ChoiceChip(
                    label: const Text('PDF'),
                    selected: true,
                    onSelected: (value) {},
                  ),
                  const SizedBox(width: AppTheme.paddingSmall),
                  ChoiceChip(
                    label: const Text('Word'),
                    selected: false,
                    onSelected: (value) {},
                  ),
                  const SizedBox(width: AppTheme.paddingSmall),
                  ChoiceChip(
                    label: const Text('Excel'),
                    selected: false,
                    onSelected: (value) {},
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (emailController.text.isEmpty) {
                Get.snackbar(
                  'Erro',
                  'Digite o email do destinatário',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              Get.back();
              Get.dialog(
                const Center(
                  child: CircularProgressIndicator(),
                ),
                barrierDismissible: false,
              );

              try {
                await ReportService.sendEmail(
                  to: emailController.text,
                  subject: subjectController.text,
                  message: messageController.text,
                  type: type,
                  data: data,
                );

                Get.back();
                Get.snackbar(
                  'Sucesso',
                  'Email enviado com sucesso!',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.back();
                Get.snackbar(
                  'Erro',
                  'Não foi possível enviar o email: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            icon: const Icon(Icons.send),
            label: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showWhatsAppDialog(BuildContext context) {
    final phoneController = TextEditingController();
    final messageController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enviar por WhatsApp'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  hintText: 'Digite o número do WhatsApp',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Mensagem',
                  hintText: 'Digite uma mensagem opcional',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              Row(
                children: [
                  const Text('Formato:'),
                  const SizedBox(width: AppTheme.paddingSmall),
                  ChoiceChip(
                    label: const Text('PDF'),
                    selected: true,
                    onSelected: (value) {},
                  ),
                  const SizedBox(width: AppTheme.paddingSmall),
                  ChoiceChip(
                    label: const Text('Word'),
                    selected: false,
                    onSelected: (value) {},
                  ),
                  const SizedBox(width: AppTheme.paddingSmall),
                  ChoiceChip(
                    label: const Text('Excel'),
                    selected: false,
                    onSelected: (value) {},
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (phoneController.text.isEmpty) {
                Get.snackbar(
                  'Erro',
                  'Digite o número do WhatsApp',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              Get.back();
              Get.dialog(
                const Center(
                  child: CircularProgressIndicator(),
                ),
                barrierDismissible: false,
              );

              try {
                await ReportService.sendWhatsApp(
                  phone: phoneController.text,
                  message: messageController.text,
                  type: type,
                  data: data,
                );

                Get.back();
                Get.snackbar(
                  'Sucesso',
                  'Mensagem enviada com sucesso!',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.back();
                Get.snackbar(
                  'Erro',
                  'Não foi possível enviar a mensagem: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            icon: const Icon(Icons.send),
            label: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}

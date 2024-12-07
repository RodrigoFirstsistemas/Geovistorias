import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/report_controller.dart';
import '../../models/inspection_model.dart';
import '../../widgets/custom_text_field.dart';

class ReportOptionsScreen extends StatelessWidget {
  final InspectionModel inspection;
  final reportController = Get.put(ReportController());

  ReportOptionsScreen({Key? key, required this.inspection}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Opções de Relatório'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildExportSection(),
            SizedBox(height: 24),
            _buildShareSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exportar Relatório',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildExportButton(
                  'PDF',
                  Icons.picture_as_pdf,
                  () => reportController.exportToPDF(inspection),
                ),
                _buildExportButton(
                  'Excel',
                  Icons.table_chart,
                  () => reportController.exportToExcel([inspection]),
                ),
                _buildExportButton(
                  'XML',
                  Icons.code,
                  () => reportController.exportToXML([inspection]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compartilhar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildEmailForm(),
            SizedBox(height: 16),
            _buildWhatsAppForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(String label, IconData icon, VoidCallback onPressed) {
    return Obx(() => ElevatedButton.icon(
          onPressed: reportController.isLoading.value ? null : onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ));
  }

  Widget _buildEmailForm() {
    final emailController = TextEditingController();
    final selectedFormats = <String>[].obs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enviar por Email',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        CustomTextField(
          controller: emailController,
          labelText: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 8),
        Text('Formatos:'),
        Wrap(
          spacing: 8,
          children: [
            _buildFormatCheckbox('PDF', 'pdf', selectedFormats),
            _buildFormatCheckbox('Excel', 'excel', selectedFormats),
            _buildFormatCheckbox('XML', 'xml', selectedFormats),
          ],
        ),
        SizedBox(height: 16),
        Obx(() => ElevatedButton.icon(
              onPressed: reportController.isLoading.value
                  ? null
                  : () {
                      if (selectedFormats.isEmpty) {
                        Get.snackbar(
                          'Erro',
                          'Selecione pelo menos um formato',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      reportController.sendByEmail(
                        email: emailController.text,
                        inspection: inspection,
                        formats: selectedFormats,
                      );
                    },
              icon: Icon(Icons.email),
              label: Text('Enviar Email'),
            )),
      ],
    );
  }

  Widget _buildWhatsAppForm() {
    final phoneController = TextEditingController();
    final selectedFormat = 'pdf'.obs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enviar por WhatsApp',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        CustomTextField(
          controller: phoneController,
          labelText: 'Telefone',
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 8),
        Text('Formato:'),
        Obx(() => Wrap(
              spacing: 8,
              children: [
                Radio<String>(
                  value: 'pdf',
                  groupValue: selectedFormat.value,
                  onChanged: (value) => selectedFormat.value = value!,
                ),
                Text('PDF'),
                Radio<String>(
                  value: 'excel',
                  groupValue: selectedFormat.value,
                  onChanged: (value) => selectedFormat.value = value!,
                ),
                Text('Excel'),
                Radio<String>(
                  value: 'xml',
                  groupValue: selectedFormat.value,
                  onChanged: (value) => selectedFormat.value = value!,
                ),
                Text('XML'),
              ],
            )),
        SizedBox(height: 16),
        Obx(() => ElevatedButton.icon(
              onPressed: reportController.isLoading.value
                  ? null
                  : () => reportController.sendByWhatsApp(
                        phone: phoneController.text,
                        inspection: inspection,
                        format: selectedFormat.value,
                      ),
              icon: Icon(Icons.share),
              label: Text('Enviar WhatsApp'),
            )),
      ],
    );
  }

  Widget _buildFormatCheckbox(
      String label, String value, RxList<String> selectedFormats) {
    return Obx(() => CheckboxListTile(
          title: Text(label),
          value: selectedFormats.contains(value),
          onChanged: (checked) {
            if (checked!) {
              selectedFormats.add(value);
            } else {
              selectedFormats.remove(value);
            }
          },
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
        ));
  }
}

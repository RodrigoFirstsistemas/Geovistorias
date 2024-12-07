import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/document_template_service.dart';

class TestConnectionScreen extends StatelessWidget {
  final DocumentTemplateService _templateService = Get.find<DocumentTemplateService>();
  final _resultText = ''.obs;
  final _isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teste de Conexão'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  try {
                    _isLoading.value = true;
                    final result = await _templateService.testConnection();
                    _resultText.value = result;
                  } catch (e) {
                    _resultText.value = 'Erro: $e';
                  } finally {
                    _isLoading.value = false;
                  }
                },
                child: Obx(() => _isLoading.value 
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Testar Conexão com Supabase')
                ),
              ),
              SizedBox(height: 20),
              Obx(() => _resultText.value.isNotEmpty
                ? Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _resultText.value,
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : SizedBox()
              ),
            ],
          ),
        ),
      ),
    );
  }
}

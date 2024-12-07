import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DocumentTemplateDialog extends StatelessWidget {
  final DocumentTemplateModel template;
  final String title;
  final String description;
  final bool isDefault;
  final _formKey = GlobalKey<FormState>();

  DocumentTemplateDialog({
    Key? key,
    required this.template,
    required this.title,
    required this.description,
    required this.isDefault,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Text(
                description,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              CheckboxListTile(
                title: Text('Modelo Padrão'),
                value: isDefault,
                onChanged: null,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Fechar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

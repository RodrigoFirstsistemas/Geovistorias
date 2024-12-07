import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../models/organization_model.dart';
import '../custom_text_field.dart';

class EditOrganizationDialog extends StatelessWidget {
  final AdminController controller;
  final OrganizationModel organization;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController;
  final TextEditingController _cnpjController;
  final TextEditingController _emailController;
  final TextEditingController _phoneController;

  EditOrganizationDialog({
    Key? key,
    required this.controller,
    required this.organization,
  })  : _nameController = TextEditingController(text: organization.name),
        _cnpjController = TextEditingController(text: organization.cnpj),
        _emailController = TextEditingController(text: organization.email),
        _phoneController = TextEditingController(text: organization.phone),
        super(key: key);

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
                'Editar Organização',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              CustomTextField(
                controller: _nameController,
                labelText: 'Nome',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _cnpjController,
                labelText: 'CNPJ',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o CNPJ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                labelText: 'Telefone',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o telefone';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancelar'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final updatedOrganization = organization.copyWith(
                          name: _nameController.text,
                          cnpj: _cnpjController.text,
                          email: _emailController.text,
                          phone: _phoneController.text,
                        );
                        controller.updateOrganization(updatedOrganization);
                        Get.back();
                      }
                    },
                    child: Text('Salvar'),
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

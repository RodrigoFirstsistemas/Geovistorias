import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../models/organization_model.dart';
import '../custom_text_field.dart';

class CreateOrganizationDialog extends StatelessWidget {
  final AdminController _adminController;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  CreateOrganizationDialog({
    Key? key,
    required AdminController adminController,
  })  : _adminController = adminController,
        super(key: key);

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final organization = OrganizationModel(
          name: _nameController.text,
          planType: 'free',
          inspectionLimit: 10,
          userLimit: 3,
          trialEndsAt: DateTime.now().add(Duration(days: 15)),
          settings: {},
          isActive: true,
        );

        await _adminController.createOrganization(organization);
        Get.back(result: true);
      } catch (e) {
        Get.snackbar(
          'Erro',
          'Não foi possível criar a organização: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

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
                'Criar Nova Organização',
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
                    onPressed: _handleSubmit,
                    child: Text('Criar'),
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

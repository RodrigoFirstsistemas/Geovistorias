import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/terminal_controller.dart';
import '../theme/app_theme.dart';

class TerminalRegistrationScreen extends StatelessWidget {
  final _controller = Get.find<TerminalController>();
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _terminalNumberController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _stoneCodeController = TextEditingController();

  TerminalRegistrationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Terminal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Bem-vindo ao Sistema de Vistorias!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              const Text(
                'Para começar, precisamos registrar seu terminal. '
                'Por favor, preencha as informações abaixo:',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              
              // Informações do Usuário
              const Text(
                'Informações do Usuário',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe seu nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe seu e-mail';
                  }
                  if (!GetUtils.isEmail(value)) {
                    return 'Por favor, informe um e-mail válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe seu telefone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              
              // Informações do Terminal
              const Text(
                'Informações do Terminal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: _terminalNumberController,
                decoration: const InputDecoration(
                  labelText: 'Número do Terminal',
                  prefixIcon: Icon(Icons.point_of_sale),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe o número do terminal';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: _serialNumberController,
                decoration: const InputDecoration(
                  labelText: 'Número de Série',
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe o número de série';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: _stoneCodeController,
                decoration: const InputDecoration(
                  labelText: 'Stone Code',
                  prefixIcon: Icon(Icons.code),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe o Stone Code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              
              ElevatedButton.icon(
                onPressed: _submitRegistration,
                icon: const Icon(Icons.send),
                label: const Text('Solicitar Registro'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                ),
              ),
              
              const SizedBox(height: AppTheme.paddingMedium),
              const Text(
                'Após o envio, aguarde a aprovação do administrador '
                'para começar a usar o sistema.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitRegistration() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _controller.registerTerminal(
          userName: _nameController.text,
          userEmail: _emailController.text,
          userPhone: _phoneController.text,
          terminalNumber: _terminalNumberController.text,
          serialNumber: _serialNumberController.text,
          stoneCode: _stoneCodeController.text,
        );

        Get.dialog(
          AlertDialog(
            title: const Text('Registro Enviado'),
            content: const Text(
              'Seu pedido de registro foi enviado com sucesso!\n\n'
              'Aguarde a aprovação do administrador para começar a usar o sistema.'
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Get.offAllNamed('/login'),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        Get.snackbar(
          'Erro',
          'Erro ao registrar terminal: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}

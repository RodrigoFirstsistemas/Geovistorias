import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/base_layout.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'Configurações',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BaseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Perfil',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: const Icon(Icons.person),
                    ),
                    title: const Text('João Silva'),
                    subtitle: const Text('Administrador'),
                    trailing: TextButton(
                      onPressed: () {
                        // TODO: Implementar edição de perfil
                      },
                      child: const Text('Editar'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            BaseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aparência',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  SwitchListTile(
                    value: true,
                    onChanged: (value) {
                      // TODO: Implementar mudança de tema
                    },
                    title: const Text('Tema Escuro'),
                    subtitle: const Text('Alterna entre tema claro e escuro'),
                  ),
                  ListTile(
                    title: const Text('Cor Principal'),
                    subtitle: const Text('Selecione a cor principal do aplicativo'),
                    trailing: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    onTap: () {
                      // TODO: Implementar seleção de cor
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            BaseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notificações',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  SwitchListTile(
                    value: true,
                    onChanged: (value) {
                      // TODO: Implementar configuração de notificação
                    },
                    title: const Text('Novas Vistorias'),
                    subtitle: const Text('Receber notificações de novas vistorias'),
                  ),
                  SwitchListTile(
                    value: true,
                    onChanged: (value) {
                      // TODO: Implementar configuração de notificação
                    },
                    title: const Text('Atualizações de Vistorias'),
                    subtitle: const Text('Receber notificações de atualizações em vistorias'),
                  ),
                  SwitchListTile(
                    value: false,
                    onChanged: (value) {
                      // TODO: Implementar configuração de notificação
                    },
                    title: const Text('Novos Clientes'),
                    subtitle: const Text('Receber notificações de novos clientes'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            BaseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Backup e Sincronização',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  ListTile(
                    leading: const Icon(Icons.backup),
                    title: const Text('Fazer Backup'),
                    subtitle: const Text('Último backup: 06/12/2024 10:30'),
                    trailing: TextButton(
                      onPressed: () {
                        // TODO: Implementar backup
                      },
                      child: const Text('Backup'),
                    ),
                  ),
                  SwitchListTile(
                    value: true,
                    onChanged: (value) {
                      // TODO: Implementar configuração de sincronização
                    },
                    title: const Text('Sincronização Automática'),
                    subtitle: const Text('Sincronizar dados automaticamente'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            BaseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sobre',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  ListTile(
                    title: const Text('Versão'),
                    subtitle: const Text('1.0.0'),
                  ),
                  ListTile(
                    title: const Text('Licença'),
                    subtitle: const Text('MIT'),
                    onTap: () {
                      // TODO: Mostrar licença
                    },
                  ),
                  ListTile(
                    title: const Text('Política de Privacidade'),
                    onTap: () {
                      // TODO: Mostrar política de privacidade
                    },
                  ),
                  ListTile(
                    title: const Text('Termos de Uso'),
                    onTap: () {
                      // TODO: Mostrar termos de uso
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            BaseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conta',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Sair',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      // TODO: Implementar logout
                      Get.offAllNamed('/login');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

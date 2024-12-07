import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/base_layout.dart';
import '../theme/app_theme.dart';

class InspectionListScreen extends StatelessWidget {
  InspectionListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'Vistorias',
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementar criação de vistoria
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BaseCard(
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar vistorias...',
              ),
              onChanged: (value) {
                // TODO: Implementar busca
              },
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Expanded(
            child: BaseCard(
              child: ListView.builder(
                itemCount: 10, // TODO: Usar dados reais
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.assignment,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    title: Text('Vistoria #${index + 1}'),
                    subtitle: Text('Imóvel: Apartamento em Copacabana'),
                    trailing: Text(
                      'Em andamento',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => Get.toNamed('/inspection/${index + 1}'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

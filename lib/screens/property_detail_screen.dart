import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../controllers/property_controller.dart';
import '../models/property_model.dart';
import '../services/cep_service.dart';
import '../theme/app_theme.dart';
import '../widgets/base_layout.dart';
import '../widgets/report_options.dart'; // Import ReportOptions widget

class PropertyDetailScreen extends StatelessWidget {
  final String propertyId = Get.parameters['id'] ?? '';
  final PropertyController _propertyController = Get.find<PropertyController>();
  final CepService _cepService = CepService.to;

  PropertyDetailScreen({Key? key}) : super(key: key);

  String _getPropertyTypeLabel(PropertyType type) {
    switch (type) {
      case PropertyType.residential:
        return 'Residencial';
      case PropertyType.commercial:
        return 'Comercial';
      case PropertyType.industrial:
        return 'Industrial';
      case PropertyType.land:
        return 'Terreno';
      case PropertyType.rural:
        return 'Rural';
      case PropertyType.apartment:
        return 'Apartamento';
      case PropertyType.other:
        return 'Outro';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final property = _propertyController.selectedProperty.value;
      if (property == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return BaseLayout(
        title: 'Detalhes do Imóvel',
        actions: [
          ReportOptions(
            title: 'Imóvel',
            type: 'property',
            data: _propertyController.property.value?.toJson() ?? {},
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeletePropertyDialog(context),
          ),
        ],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BaseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Endereço',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  Text(
                    property.address,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            BaseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tipo',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () => _showManageSubtypesDialog(
                          context,
                          property.type,
                        ),
                        tooltip: 'Gerenciar Subtipos',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  Text(
                    _getPropertyTypeLabel(property.type),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (property.subtype != null) ...[
                    const SizedBox(height: AppTheme.paddingLarge),
                    Text(
                      'Subtipo',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    Text(
                      property.subtype!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showEditDialog(BuildContext context) {
    final property = _propertyController.selectedProperty.value;
    if (property == null) return;

    PropertyType selectedType = property.type;
    String? selectedSubtype = property.subtype;
    
    final cepController = TextEditingController(text: property.cep);
    final streetController = TextEditingController(text: property.street);
    final numberController = TextEditingController(text: property.number);
    final complementController = TextEditingController(text: property.complement ?? '');
    final neighborhoodController = TextEditingController(text: property.neighborhood);
    final cityController = TextEditingController(text: property.city);
    final stateController = TextEditingController(text: property.state);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Imóvel'),
          content: SingleChildScrollView(
            child: BaseForm(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: cepController,
                        decoration: const InputDecoration(
                          labelText: 'CEP',
                          hintText: '00000-000',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _CepInputFormatter(),
                        ],
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        try {
                          final cleanCep = cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
                          if (cleanCep.length != 8) {
                            Get.snackbar(
                              'Erro',
                              'CEP inválido',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }

                          final address = await _cepService.fetchAddressByCep(cleanCep);
                          
                          setState(() {
                            streetController.text = address['street'] ?? '';
                            neighborhoodController.text = address['neighborhood'] ?? '';
                            cityController.text = address['city'] ?? '';
                            stateController.text = address['state'] ?? '';
                            if (address['complement'] != null && address['complement'].isNotEmpty) {
                              complementController.text = address['complement'];
                            }
                          });
                        } catch (e) {
                          Get.snackbar(
                            'Erro',
                            e.toString(),
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                    ),
                  ],
                ),
                TextFormField(
                  controller: streetController,
                  decoration: const InputDecoration(labelText: 'Rua'),
                ),
                TextFormField(
                  controller: numberController,
                  decoration: const InputDecoration(labelText: 'Número'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: complementController,
                  decoration: const InputDecoration(labelText: 'Complemento (opcional)'),
                ),
                TextFormField(
                  controller: neighborhoodController,
                  decoration: const InputDecoration(labelText: 'Bairro'),
                ),
                TextFormField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'Cidade'),
                ),
                TextFormField(
                  controller: stateController,
                  decoration: const InputDecoration(labelText: 'Estado'),
                ),
                DropdownButtonFormField<PropertyType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Tipo de Imóvel'),
                  items: PropertyType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getPropertyTypeLabel(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedType = value;
                        selectedSubtype = null;
                      });
                    }
                  },
                ),
                DropdownButtonFormField<String>(
                  value: selectedSubtype,
                  decoration: const InputDecoration(
                    labelText: 'Subtipo',
                    hintText: 'Selecione um subtipo',
                  ),
                  items: _propertyController
                      .getSubtypesForType(selectedType)
                      .map((subtype) {
                    return DropdownMenuItem(
                      value: subtype,
                      child: Text(subtype),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedSubtype = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: BaseActionButtons(
            children: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (cepController.text.isEmpty ||
                      streetController.text.isEmpty ||
                      numberController.text.isEmpty ||
                      neighborhoodController.text.isEmpty ||
                      cityController.text.isEmpty ||
                      stateController.text.isEmpty) {
                    Get.snackbar(
                      'Erro',
                      'Preencha todos os campos obrigatórios',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  final updatedProperty = property.copyWith(
                    cep: cepController.text,
                    street: streetController.text,
                    number: numberController.text,
                    complement: complementController.text.isEmpty ? null : complementController.text,
                    neighborhood: neighborhoodController.text,
                    city: cityController.text,
                    state: stateController.text,
                    type: selectedType,
                    subtype: selectedSubtype,
                  );
                  _propertyController.updateProperty(updatedProperty);
                  Get.back();
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeletePropertyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Imóvel'),
        content: const Text('Tem certeza que deseja excluir este imóvel?'),
        actions: BaseActionButtons(
          children: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                _propertyController.deleteProperty(propertyId);
                Get.back();
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Excluir'),
            ),
          ],
        ),
      ),
    );
  }

  void _showManageSubtypesDialog(BuildContext context, PropertyType type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Gerenciar Subtipos - ${_getPropertyTypeLabel(type)}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._propertyController.getSubtypesForType(type).map((subtype) {
                return ListTile(
                  title: Text(subtype),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _propertyController.removeCustomSubtype(type, subtype);
                      Get.back();
                    },
                  ),
                );
              }),
              const SizedBox(height: AppTheme.paddingMedium),
              ElevatedButton.icon(
                onPressed: () => _showAddSubtypeDialog(context, type),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Subtipo'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showAddSubtypeDialog(BuildContext context, PropertyType type) {
    final subtypeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Subtipo'),
        content: TextFormField(
          controller: subtypeController,
          decoration: const InputDecoration(
            labelText: 'Nome do Subtipo',
            hintText: 'Digite o nome do subtipo',
          ),
          autofocus: true,
        ),
        actions: BaseActionButtons(
          children: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (subtypeController.text.isNotEmpty) {
                  _propertyController.addCustomSubtype(
                    type,
                    subtypeController.text.trim(),
                  );
                  Get.back();
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.length > 8) {
      return oldValue;
    }

    String formatted = text;
    if (text.length > 5) {
      formatted = '${text.substring(0, 5)}-${text.substring(5)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

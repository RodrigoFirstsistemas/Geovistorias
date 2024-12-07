import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class AdvancedSearch extends StatelessWidget {
  final TextEditingController searchController;
  final Function(Map<String, dynamic>) onSearch;
  final String type; // 'property', 'inspection', ou 'client'
  final bool expanded;

  const AdvancedSearch({
    Key? key,
    required this.searchController,
    required this.onSearch,
    required this.type,
    this.expanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isExpanded = expanded.obs;
    final dateFormat = DateFormat('dd/MM/yyyy');
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    final statusController = TextEditingController();
    final typeController = TextEditingController();

    return Obx(() => Column(
      children: [
        // Campo de busca principal
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Buscar por nome, email, telefone...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: Icon(
                isExpanded.value ? Icons.expand_less : Icons.expand_more,
              ),
              onPressed: () => isExpanded.value = !isExpanded.value,
            ),
          ),
          onChanged: (value) => _performSearch(
            searchText: value,
            startDate: startDateController.text,
            endDate: endDateController.text,
            status: statusController.text,
            type: typeController.text,
          ),
        ),

        // Campos de busca avançada
        if (isExpanded.value) ...[
          const SizedBox(height: AppTheme.paddingMedium),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: startDateController,
                  decoration: const InputDecoration(
                    labelText: 'Data Inicial',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      startDateController.text = dateFormat.format(date);
                      _performSearch(
                        searchText: searchController.text,
                        startDate: startDateController.text,
                        endDate: endDateController.text,
                        status: statusController.text,
                        type: typeController.text,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: AppTheme.paddingMedium),
              Expanded(
                child: TextField(
                  controller: endDateController,
                  decoration: const InputDecoration(
                    labelText: 'Data Final',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      endDateController.text = dateFormat.format(date);
                      _performSearch(
                        searchText: searchController.text,
                        startDate: startDateController.text,
                        endDate: endDateController.text,
                        status: statusController.text,
                        type: typeController.text,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Row(
            children: [
              if (type == 'property' || type == 'inspection') ...[
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: statusController.text.isEmpty ? null : statusController.text,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                    ),
                    items: _getStatusItems(),
                    onChanged: (value) {
                      statusController.text = value ?? '';
                      _performSearch(
                        searchText: searchController.text,
                        startDate: startDateController.text,
                        endDate: endDateController.text,
                        status: statusController.text,
                        type: typeController.text,
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.paddingMedium),
              ],
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: typeController.text.isEmpty ? null : typeController.text,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                  ),
                  items: _getTypeItems(),
                  onChanged: (value) {
                    typeController.text = value ?? '';
                    _performSearch(
                      searchText: searchController.text,
                      startDate: startDateController.text,
                      endDate: endDateController.text,
                      status: statusController.text,
                      type: typeController.text,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  searchController.clear();
                  startDateController.clear();
                  endDateController.clear();
                  statusController.clear();
                  typeController.clear();
                  _performSearch(
                    searchText: '',
                    startDate: '',
                    endDate: '',
                    status: '',
                    type: '',
                  );
                },
                icon: const Icon(Icons.clear),
                label: const Text('Limpar Filtros'),
              ),
            ],
          ),
        ],
      ],
    ));
  }

  List<DropdownMenuItem<String>> _getStatusItems() {
    switch (type) {
      case 'property':
        return [
          const DropdownMenuItem(value: 'available', child: Text('Disponível')),
          const DropdownMenuItem(value: 'rented', child: Text('Alugado')),
          const DropdownMenuItem(value: 'sold', child: Text('Vendido')),
          const DropdownMenuItem(value: 'maintenance', child: Text('Em Manutenção')),
        ];
      case 'inspection':
        return [
          const DropdownMenuItem(value: 'pending', child: Text('Pendente')),
          const DropdownMenuItem(value: 'in_progress', child: Text('Em Andamento')),
          const DropdownMenuItem(value: 'completed', child: Text('Concluída')),
          const DropdownMenuItem(value: 'cancelled', child: Text('Cancelada')),
        ];
      default:
        return [];
    }
  }

  List<DropdownMenuItem<String>> _getTypeItems() {
    switch (type) {
      case 'property':
        return [
          const DropdownMenuItem(value: 'house', child: Text('Casa')),
          const DropdownMenuItem(value: 'apartment', child: Text('Apartamento')),
          const DropdownMenuItem(value: 'commercial', child: Text('Comercial')),
          const DropdownMenuItem(value: 'land', child: Text('Terreno')),
        ];
      case 'inspection':
        return [
          const DropdownMenuItem(value: 'entry', child: Text('Entrada')),
          const DropdownMenuItem(value: 'exit', child: Text('Saída')),
          const DropdownMenuItem(value: 'periodic', child: Text('Periódica')),
          const DropdownMenuItem(value: 'maintenance', child: Text('Manutenção')),
        ];
      case 'client':
        return [
          const DropdownMenuItem(value: 'owner', child: Text('Proprietário')),
          const DropdownMenuItem(value: 'tenant', child: Text('Locatário')),
          const DropdownMenuItem(value: 'buyer', child: Text('Comprador')),
          const DropdownMenuItem(value: 'seller', child: Text('Vendedor')),
        ];
      default:
        return [];
    }
  }

  void _performSearch({
    required String searchText,
    required String startDate,
    required String endDate,
    required String status,
    required String type,
  }) {
    onSearch({
      'searchText': searchText,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
      'type': type,
    });
  }
}

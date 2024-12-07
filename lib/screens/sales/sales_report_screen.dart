import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/sales_report_controller.dart';
import '../../models/sale_model.dart';
import '../../widgets/date_range_picker.dart';
import '../../widgets/loading_overlay.dart';

class SalesReportScreen extends StatelessWidget {
  final controller = Get.put(SalesReportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatórios de Vendas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilterSection(),
            _buildReportButtons(),
            _buildReprintSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            DateRangePicker(
              onDateRangeSelected: controller.setDateRange,
            ),
            SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<SaleStatus>(
              value: controller.selectedStatus.value,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: SaleStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(_getStatusText(status)),
                );
              }).toList(),
              onChanged: controller.setStatus,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildReportButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Relatórios',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.summarize),
                    label: Text('Relatório de Vendas'),
                    onPressed: () => controller.generateSalesReport(),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.cancel),
                    label: Text('Relatório de Cancelamentos'),
                    onPressed: () => controller.generateCancellationsReport(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReprintSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reimpressão',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                labelText: 'Buscar venda',
                hintText: 'Digite o número da venda',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => controller.searchSale(),
                ),
              ),
            ),
            SizedBox(height: 16),
            Obx(() => controller.foundSale.value != null
                ? _buildSaleCard(controller.foundSale.value!)
                : SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleCard(SaleModel sale) {
    return Card(
      child: ListTile(
        title: Text('Venda #${sale.id}'),
        subtitle: Text('${_getStatusText(sale.status)} - R\$ ${sale.total.toStringAsFixed(2)}'),
        trailing: ElevatedButton.icon(
          icon: Icon(Icons.print),
          label: Text('Reimprimir'),
          onPressed: () => controller.reprintSale(sale.id.toString()),
        ),
      ),
    );
  }

  String _getStatusText(SaleStatus status) {
    switch (status) {
      case SaleStatus.pending:
        return 'Pendente';
      case SaleStatus.completed:
        return 'Concluída';
      case SaleStatus.cancelled:
        return 'Cancelada';
      default:
        return '';
    }
  }
}

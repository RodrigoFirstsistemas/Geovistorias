import 'dart:io';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import '../models/sale_model.dart';
import '../services/isar_service.dart';
import '../utils/date_utils.dart';
import '../utils/format_utils.dart';

class SalesReportService extends GetxService {
  final IsarService _isarService = Get.find();

  // Singleton
  static SalesReportService get to => Get.find<SalesReportService>();

  // Relatório de Vendas em PDF
  Future<File> generateSalesReport({
    DateTime? startDate,
    DateTime? endDate,
    String? clientId,
    SaleStatus? status,
  }) async {
    final pdf = pw.Document();
    
    // Buscar vendas com filtros
    final sales = await _getSalesWithFilters(
      startDate: startDate,
      endDate: endDate,
      clientId: clientId,
      status: status,
    );

    // Calcular totais
    final totalAmount = sales.fold(0.0, (sum, sale) => sum + sale.total);
    final totalDiscount = sales.fold(0.0, (sum, sale) => sum + (sale.discount ?? 0.0));
    final totalPaid = sales.fold(0.0, (sum, sale) => sum + sale.paid);

    // Gerar PDF
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          _buildHeader(startDate, endDate),
          _buildSalesTable(sales),
          _buildTotals(totalAmount, totalDiscount, totalPaid),
        ],
      ),
    );

    // Salvar arquivo
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/relatorio_vendas_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // Relatório de Cancelamentos em PDF
  Future<File> generateCancellationsReport({
    DateTime? startDate,
    DateTime? endDate,
    String? clientId,
  }) async {
    final pdf = pw.Document();
    
    // Buscar vendas canceladas
    final cancelledSales = await _getSalesWithFilters(
      startDate: startDate,
      endDate: endDate,
      clientId: clientId,
      status: SaleStatus.cancelled,
    );

    // Calcular totais
    final totalCancelled = cancelledSales.fold(0.0, (sum, sale) => sum + sale.total);

    // Gerar PDF
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          _buildHeader(startDate, endDate, title: 'Relatório de Cancelamentos'),
          _buildCancellationsTable(cancelledSales),
          _buildCancellationsTotals(totalCancelled, cancelledSales.length),
        ],
      ),
    );

    // Salvar arquivo
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/relatorio_cancelamentos_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // Reimpressão de Comprovante
  Future<File> reprintSale(String saleId) async {
    final sale = await _isarService.getSaleById(saleId);
    if (sale == null) {
      throw Exception('Venda não encontrada');
    }

    final pdf = pw.Document();
    
    // Gerar comprovante
    pdf.addPage(
      pw.Page(
        build: (context) => [
          _buildReceiptHeader(),
          _buildSaleDetails(sale),
          _buildPaymentsDetails(sale.payments),
          _buildReceiptFooter(sale),
        ],
      ),
    );

    // Incrementar contador de impressões
    sale.incrementPrintCount();
    await _isarService.saveSale(sale);

    // Salvar arquivo
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/comprovante_${sale.id}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // Métodos auxiliares privados
  Future<List<SaleModel>> _getSalesWithFilters({
    DateTime? startDate,
    DateTime? endDate,
    String? clientId,
    SaleStatus? status,
  }) async {
    // Implementar lógica de filtros com Isar
    return await _isarService.getSales(
      startDate: startDate,
      endDate: endDate,
      clientId: clientId,
      status: status,
    );
  }

  // Builders do PDF
  pw.Widget _buildHeader(DateTime? startDate, DateTime? endDate, {String title = 'Relatório de Vendas'}) {
    // Implementar cabeçalho do relatório
    return pw.Header(
      level: 0,
      child: pw.Text(title),
    );
  }

  pw.Widget _buildSalesTable(List<SaleModel> sales) {
    // Implementar tabela de vendas
    return pw.Table();
  }

  pw.Widget _buildTotals(double total, double discount, double paid) {
    // Implementar totalizadores
    return pw.Container();
  }

  pw.Widget _buildCancellationsTable(List<SaleModel> sales) {
    // Implementar tabela de cancelamentos
    return pw.Table();
  }

  pw.Widget _buildCancellationsTotals(double total, int count) {
    // Implementar totalizadores de cancelamentos
    return pw.Container();
  }

  pw.Widget _buildReceiptHeader() {
    // Implementar cabeçalho do comprovante
    return pw.Header(
      level: 0,
      child: pw.Text('Comprovante de Venda'),
    );
  }

  pw.Widget _buildSaleDetails(SaleModel sale) {
    // Implementar detalhes da venda
    return pw.Container();
  }

  pw.Widget _buildPaymentsDetails(List<PaymentItem> payments) {
    // Implementar detalhes dos pagamentos
    return pw.Container();
  }

  pw.Widget _buildReceiptFooter(SaleModel sale) {
    // Implementar rodapé do comprovante
    return pw.Container();
  }
}

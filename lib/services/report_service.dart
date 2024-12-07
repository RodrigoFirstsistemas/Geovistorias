import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/inspection_model.dart';
import '../models/organization_model.dart';

class ReportService extends GetxService {
  final dateFormat = DateFormat('dd/MM/yyyy');
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  Future<void> generateInspectionReport(
    List<InspectionModel> inspections,
    OrganizationModel organization,
  ) async {
    final pdf = pw.Document();
    final font = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(font);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader(organization, ttf),
          pw.SizedBox(height: 20),
          _buildSummary(inspections, ttf),
          pw.SizedBox(height: 20),
          _buildInspectionTable(inspections, ttf),
        ],
        footer: (context) => _buildFooter(context, ttf),
      ),
    );

    final output = await getTemporaryDirectory();
    final fileName = 'relatorio_vistorias_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    
    final xFile = XFile(file.path);
    await Share.shareXFiles(
      [xFile],
      text: 'Relatório de Vistorias - ${organization.name}',
    );
  }

  pw.Widget _buildHeader(OrganizationModel organization, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          organization.name,
          style: pw.TextStyle(
            font: font,
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'Relatório de Vistorias',
          style: pw.TextStyle(
            font: font,
            fontSize: 18,
          ),
        ),
        pw.Text(
          'Gerado em: ${dateFormat.format(DateTime.now())}',
          style: pw.TextStyle(font: font),
        ),
      ],
    );
  }

  pw.Widget _buildSummary(List<InspectionModel> inspections, pw.Font font) {
    final total = inspections.length;
    final concluidas = inspections.where((i) => i.status == InspectionStatus.concluida).length;
    final emAndamento = inspections.where((i) => i.status == InspectionStatus.emAndamento).length;
    final agendadas = inspections.where((i) => i.status == InspectionStatus.agendada).length;
    final canceladas = inspections.where((i) => i.status == InspectionStatus.cancelada).length;

    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Resumo',
            style: pw.TextStyle(
              font: font,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildSummaryItem('Total de Vistorias', total, font),
          _buildSummaryItem('Concluídas', concluidas, font),
          _buildSummaryItem('Em Andamento', emAndamento, font),
          _buildSummaryItem('Agendadas', agendadas, font),
          _buildSummaryItem('Canceladas', canceladas, font),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryItem(String label, int value, pw.Font font) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(font: font)),
        pw.Text(value.toString(), style: pw.TextStyle(font: font)),
      ],
    );
  }

  pw.Widget _buildInspectionTable(List<InspectionModel> inspections, pw.Font font) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(
        font: font,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: pw.TextStyle(font: font),
      headers: ['ID', 'Endereço', 'Status', 'Data', 'Valor'],
      data: inspections.map((inspection) => [
        inspection.id?.toString() ?? '-',
        inspection.address,
        _formatarStatus(inspection.status),
        dateFormat.format(inspection.scheduledDate),
        currencyFormat.format(inspection.value ?? 0),
      ]).toList(),
      headerDecoration: pw.BoxDecoration(
        color: PdfColors.grey300,
      ),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _buildFooter(pw.Context context, pw.Font font) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'Página ${context.pageNumber} de ${context.pagesCount}',
        style: pw.TextStyle(font: font, fontSize: 10),
      ),
    );
  }

  String _formatarStatus(InspectionStatus status) {
    switch (status) {
      case InspectionStatus.agendada:
        return 'Agendada';
      case InspectionStatus.emAndamento:
        return 'Em Andamento';
      case InspectionStatus.concluida:
        return 'Concluída';
      case InspectionStatus.cancelada:
        return 'Cancelada';
      default:
        return 'Desconhecido';
    }
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:docx_template/docx_template.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/document_template_model.dart';
import 'auth_service.dart';
import 'package:share_plus/share_plus.dart';

class DocumentTemplateService extends GetxService {
  static DocumentTemplateService get to => Get.find<DocumentTemplateService>();
  final _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService.to;

  @override
  void onInit() {
    super.onInit();
    print('DocumentTemplateService initialized');
  }

  // Buscar templates da organização
  Future<List<DocumentTemplate>> getOrganizationTemplates() async {
    try {
      final orgId = _authService.currentUser.value?.organizationId;
      if (orgId == null) throw Exception('Usuário não está em uma organização');

      final response = await _supabase
          .from('document_templates')
          .select()
          .eq('organization_id', orgId)
          .order('created_at');

      return (response as List)
          .map((json) => DocumentTemplate.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar templates: ${e.toString()}');
    }
  }

  // Criar novo template
  Future<DocumentTemplate> createTemplate(DocumentTemplate template) async {
    try {
      final response = await _supabase
          .from('document_templates')
          .insert(template.toJson())
          .select()
          .single();

      return DocumentTemplate.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar template: ${e.toString()}');
    }
  }

  // Atualizar template
  Future<DocumentTemplate> updateTemplate(DocumentTemplate template) async {
    try {
      final response = await _supabase
          .from('document_templates')
          .update(template.toJson())
          .eq('id', template.id)
          .select()
          .single();

      return DocumentTemplate.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar template: ${e.toString()}');
    }
  }

  // Excluir template
  Future<void> deleteTemplate(String templateId) async {
    try {
      await _supabase
          .from('document_templates')
          .delete()
          .eq('id', templateId);
    } catch (e) {
      throw Exception('Erro ao excluir template: ${e.toString()}');
    }
  }

  // Gerar PDF
  Future<File> generatePDF({
    required DocumentTemplate template,
    required Map<String, dynamic> data,
    required DocumentConfig config,
  }) async {
    try {
      final pdf = pw.Document();

      // Carregar logo
      pw.ImageProvider? logoImage;
      if (config.logoPath.isNotEmpty) {
        final bytes = await _loadNetworkImage(config.logoPath);
        logoImage = pw.MemoryImage(bytes);
      }

      // Carregar marca d'água se existir
      pw.ImageProvider? watermarkImage;
      if (config.watermarkImage != null) {
        final bytes = await _loadNetworkImage(config.watermarkImage!);
        watermarkImage = pw.MemoryImage(bytes);
      }

      // Configurar tema
      final theme = pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      );

      // Adicionar páginas
      pdf.addPage(
        pw.MultiPage(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(config.margins['all'] ?? 20),
          header: (context) => _buildHeader(
            config,
            logoImage,
            template.headerConfig,
          ),
          footer: (context) => _buildFooter(
            config,
            template.footerConfig,
            context.pageNumber,
            context.pagesCount,
          ),
          build: (context) => _buildBody(
            data,
            template.bodyConfig,
            config.colors,
          ),
          watermark: watermarkImage != null
              ? pw.Center(
                  child: pw.Opacity(
                    opacity: config.watermarkOpacity ?? 0.3,
                    child: pw.Image(
                      watermarkImage,
                    ),
                  ),
                )
              : config.watermarkText != null
                  ? pw.Center(
                      child: pw.Opacity(
                        opacity: config.watermarkOpacity ?? 0.3,
                        child: pw.Text(
                          config.watermarkText!,
                          style: pw.TextStyle(
                            fontSize: 50,
                            color: PdfColor.fromHex('EEEEEE'),
                          ),
                        ),
                      ),
                    )
                  : null,
        ),
      );

      // Salvar arquivo
      final output = await getTemporaryDirectory();
      final file = File(
          '${output.path}/document_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      throw Exception('Erro ao gerar PDF: ${e.toString()}');
    }
  }

  // Gerar Word
  Future<File> generateWord({
    required DocumentTemplate template,
    required Map<String, dynamic> data,
    required DocumentConfig config,
  }) async {
    try {
      // Carregar template base
      final templateFile = await _loadTemplateFile(template.template);
      final docx = await DocxTemplate.fromBytes(await templateFile.readAsBytes());

      // Preparar dados
      final content = Content();
      
      // Adicionar dados da empresa
      content
        ..add(TextContent("companyName", config.companyName))
        ..add(TextContent("address", config.address))
        ..add(TextContent("phone", config.phone))
        ..add(TextContent("email", config.email))
        ..add(TextContent("website", config.website))
        ..add(TextContent("cnpj", config.cnpj));

      // Adicionar dados do template
      data.forEach((key, value) {
        if (value is String) {
          content.add(TextContent(key, value));
        } else if (value is List) {
          content.add(ListContent(key, value));
        }
      });

      // Gerar documento
      final bytes = await docx.generate(content);
      if (bytes == null) throw Exception('Erro ao gerar documento Word');
      
      final output = await getTemporaryDirectory();
      final file = File(
          '${output.path}/document_${DateTime.now().millisecondsSinceEpoch}.docx');
      await file.writeAsBytes(bytes);

      return file;
    } catch (e) {
      throw Exception('Erro ao gerar Word: ${e.toString()}');
    }
  }

  // Gerar recibo de impressão
  Future<File> generateReceipt({
    required DocumentTemplate template,
    required Map<String, dynamic> data,
    required DocumentConfig config,
  }) async {
    try {
      final pdf = pw.Document();

      // Configurar tamanho do papel (80mm x comprimento variável)
      final format = PdfPageFormat(
        80 * PdfPageFormat.mm,
        297 * PdfPageFormat.mm,
        marginAll: 5 * PdfPageFormat.mm,
      );

      pdf.addPage(
        pw.Page(
          pageFormat: format,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                pw.Center(
                  child: pw.Text(
                    config.companyName,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(config.address, style: const pw.TextStyle(fontSize: 8)),
                pw.Text('CNPJ: ${config.cnpj}',
                    style: const pw.TextStyle(fontSize: 8)),
                pw.Text('Tel: ${config.phone}',
                    style: const pw.TextStyle(fontSize: 8)),

                pw.Divider(),

                // Dados do recibo
                ...data.entries.map((entry) {
                  return pw.Text(
                    '${entry.key}: ${entry.value}',
                    style: const pw.TextStyle(fontSize: 10),
                  );
                }).toList(),

                pw.Divider(),

                // Rodapé
                pw.Center(
                  child: pw.Text(
                    DateTime.now().toString(),
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Salvar arquivo
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      throw Exception('Erro ao gerar recibo: ${e.toString()}');
    }
  }

  Future<void> generateDocument(DocumentConfig config, List<pw.Widget> content) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Stack(
          children: [
            pw.Column(children: content),
            if (config.showWatermark)
              pw.Center(
                child: pw.Opacity(
                  opacity: config.watermarkOpacity ?? 0.3,
                  child: pw.Transform.rotate(
                    angle: -0.5,
                    child: pw.Text(
                      config.watermarkText ?? 'RASCUNHO',
                      style: pw.TextStyle(
                        fontSize: 60,
                        color: PdfColors.grey300,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/document.pdf');
    await file.writeAsBytes(await pdf.save());
    
    final xFile = XFile(file.path);
    await Share.shareXFiles([xFile], text: config.documentTitle);
  }

  // Método para testar a conexão e criar um template de teste
  Future<String> testConnection() async {
    try {
      // 1. Verifica cliente Supabase
      if (_supabase == null) {
        return 'Erro 374: Cliente Supabase não inicializado';
      }

      // 2. Verifica autenticação
      final session = _supabase.auth.currentSession;
      if (session == null) {
        return 'Erro 374: Usuário não autenticado';
      }

      // 3. Tenta listar tabelas
      final response = await _supabase
          .rpc('get_tables')
          .select()
          .execute();

      if (response.error != null) {
        return 'Erro 374: ${response.error!.message}';
      }

      return 'Conexão OK: ${response.data}';
    } catch (e) {
      return 'Erro 374: ${e.toString()}';
    }
  }

  Future<String> testConnectionDetailed() async {
    try {
      print('Iniciando teste de conexão...');
      
      // Teste 1: Verificar se o cliente Supabase está inicializado
      if (_supabase == null) {
        return 'Erro: Cliente Supabase não inicializado';
      }
      print('Cliente Supabase OK');

      // Teste 2: Verificar autenticação
      final session = _supabase.auth.currentSession;
      if (session == null) {
        return 'Erro: Usuário não autenticado';
      }
      print('Autenticação OK');

      // Teste 3: Tentar acessar a tabela
      final response = await _supabase
          .from('document_templates')
          .select()
          .limit(1);

      print('Acesso à tabela OK');
      return 'Conexão testada com sucesso!';
      
    } catch (e) {
      print('Erro no teste: $e');
      return 'Erro no teste: $e';
    }
  }

  // Helper method to load network images
  Future<Uint8List> _loadNetworkImage(String url) async {
    final response = await HttpClient().getUrl(Uri.parse(url));
    final request = await response.close();
    final bytes = await request.fold<List<int>>(
      [],
      (previous, element) => previous..addAll(element),
    );
    return Uint8List.fromList(bytes);
  }

  // Helper method to load template file
  Future<File> _loadTemplateFile(String templatePath) async {
    final response = await HttpClient().getUrl(Uri.parse(templatePath));
    final request = await response.close();
    final bytes = await request.fold<List<int>>(
      [],
      (previous, element) => previous..addAll(element),
    );
    
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_template.docx');
    await tempFile.writeAsBytes(bytes);
    
    return tempFile;
  }

  // Helper method to build PDF header
  pw.Widget _buildHeader(
    DocumentConfig config,
    pw.ImageProvider? logoImage,
    Map<String, dynamic> headerConfig,
  ) {
    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 20),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          if (logoImage != null)
            pw.Image(logoImage, width: 60, height: 60)
          else
            pw.Container(),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                config.companyName,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex(
                      headerConfig['titleColor'] ?? config.colors['primary']!),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(config.address),
              pw.Text('${config.phone} - ${config.email}'),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build PDF footer
  pw.Widget _buildFooter(
    DocumentConfig config,
    Map<String, dynamic> footerConfig,
    int pageNumber,
    int pageCount,
  ) {
    return pw.Container(
      margin: pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        children: [
          pw.Divider(
            color: PdfColor.fromHex(
                footerConfig['lineColor'] ?? config.colors['primary']!),
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                config.website,
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfColor.fromHex(
                      footerConfig['textColor'] ?? config.colors['primary']!),
                ),
              ),
              pw.Text(
                'Página $pageNumber de $pageCount',
                style: const pw.TextStyle(fontSize: 8),
              ),
            ],
          ),
          if (footerConfig['showCNPJ'] == true) ...[
            pw.SizedBox(height: 5),
            pw.Text(
              'CNPJ: ${config.cnpj}',
              style: const pw.TextStyle(fontSize: 8),
            ),
          ],
        ],
      ),
    );
  }

  // Helper method to build PDF body content
  List<pw.Widget> _buildBody(
    Map<String, dynamic> data,
    Map<String, dynamic> bodyConfig,
    Map<String, String> colors,
  ) {
    final widgets = <pw.Widget>[];

    // Título do documento
    if (bodyConfig['title'] != null) {
      widgets.add(
        pw.Center(
          child: pw.Text(
            bodyConfig['title'],
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex(colors['primary']!),
            ),
          ),
        ),
      );
      widgets.add(pw.SizedBox(height: 20));
    }

    // Conteúdo dinâmico baseado nos dados
    data.forEach((key, value) {
      if (value is String || value is num) {
        widgets.add(
          pw.Paragraph(
            text: '$key: $value',
            style: pw.TextStyle(
              fontSize: bodyConfig['fontSize'] ?? 12,
            ),
          ),
        );
      } else if (value is List) {
        if (value.isNotEmpty) {
          final headers = value[0] is Map ? value[0].keys.toList() : ['Valor'];
          final rows = value.map((item) {
            if (item is Map) {
              return item.values.map((v) => v.toString()).toList();
            }
            return [item.toString()];
          }).toList();

          widgets.add(
            pw.TableHelper.fromTextArray(
              context: null,
              headers: headers,
              data: rows,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex(colors['primary']!),
              ),
            ),
          );
        }
      }
    });

    return widgets;
  }
}

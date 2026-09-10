import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'providers/report_providers.dart';

String _d(DateTime? d) => d == null
    ? '—'
    : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

String _dt(DateTime? d) {
  if (d == null) return '—';
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '${_d(d)} $h:$m';
}

/// Gera o PDF do relatório de tarefas executadas (respeita os filtros já
/// aplicados na lista). Embute as fotos das execuções (best-effort).
Future<Uint8List> buildSupervisorReportPdf({
  required List<ReportRow> rows,
  required String periodLabel,
  String? contractLabel,
  String? employeeLabel,
}) async {
  // Pré-carrega as imagens (fotos) uma vez cada.
  final images = <String, pw.ImageProvider>{};
  for (final r in rows) {
    for (final p in r.execution.photos) {
      final url = p.downloadUrl;
      if (url == null || url.isEmpty || images.containsKey(url)) continue;
      try {
        images[url] = await networkImage(url);
      } catch (_) {
        // ignora foto que não carregou
      }
    }
  }

  final doc = pw.Document();
  const brand = PdfColor.fromInt(0xFF1D4F91);
  const muted = PdfColor.fromInt(0xFF64748B);
  const border = PdfColor.fromInt(0xFFE2E8F0);

  final subtitleParts = <String>['Período: $periodLabel'];
  if (contractLabel != null) subtitleParts.add('Contrato: $contractLabel');
  if (employeeLabel != null) subtitleParts.add('Funcionário: $employeeLabel');

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      build: (context) => [
        pw.Text(
          'Relatório de tarefas executadas',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(subtitleParts.join('  ·  '),
            style: const pw.TextStyle(fontSize: 10, color: muted)),
        pw.Text('${rows.length} tarefa(s) executada(s)',
            style: const pw.TextStyle(fontSize: 10, color: muted)),
        pw.SizedBox(height: 12),
        ...rows.map((r) => _rowBlock(r, images, brand, muted, border)),
      ],
    ),
  );
  return doc.save();
}

pw.Widget _rowBlock(
  ReportRow r,
  Map<String, pw.ImageProvider> images,
  PdfColor brand,
  PdfColor muted,
  PdfColor border,
) {
  final photos = r.execution.photos
      .map((p) => p.downloadUrl)
      .where((u) => u != null && images.containsKey(u))
      .cast<String>()
      .toList();

  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 10),
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: border),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Text(
                '${r.checklistName}  ·  ${r.locationName}',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Text(_dt(r.execution.finishedAt),
                style: pw.TextStyle(fontSize: 9, color: muted)),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Text('${r.clientName}  ·  ${r.contractName}  ·  ${r.employeeName}',
            style: pw.TextStyle(fontSize: 10, color: muted)),
        if (r.execution.items.isNotEmpty) ...[
          pw.SizedBox(height: 6),
          ...r.execution.items.map((it) => pw.Text(
                '${it.completed ? '[x]' : '[ ]'} ${it.description}',
                style: const pw.TextStyle(fontSize: 10),
              )),
        ],
        if ((r.execution.observation ?? '').isNotEmpty) ...[
          pw.SizedBox(height: 6),
          pw.Text('Observação: ${r.execution.observation}',
              style: const pw.TextStyle(fontSize: 10)),
        ],
        if (photos.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 6,
            runSpacing: 6,
            children: photos
                .map((u) => pw.Container(
                      width: 90,
                      height: 90,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: border),
                        borderRadius: pw.BorderRadius.circular(4),
                        image: pw.DecorationImage(
                          image: images[u]!,
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
    ),
  );
}

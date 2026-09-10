import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Gera um PDF A4 com o QR Code do ambiente (para imprimir/compartilhar).
/// O [payload] é o MESMO conteúdo do QR exibido no app, então escaneia igual.
Future<Uint8List> buildLocationQrPdf({
  required String name,
  required String client,
  required String code,
  required String payload,
}) async {
  final doc = pw.Document();
  const muted = PdfColor.fromInt(0xFF64748B);
  const border = PdfColor.fromInt(0xFFCBD5E1);

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => pw.Center(
        child: pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              name,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            if (client.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(client,
                  style: const pw.TextStyle(fontSize: 13, color: muted)),
            ],
            pw.SizedBox(height: 28),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: border),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: payload,
                width: 260,
                height: 260,
                color: PdfColors.black,
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              code,
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 28),
            pw.Text(
              'Escaneie este QR Code para abrir a tarefa do ambiente.',
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 12, color: muted),
            ),
          ],
        ),
      ),
    ),
  );
  return doc.save();
}

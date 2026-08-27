import 'dart:convert';

/// Conteúdo (payload) embutido no QR Code de um ambiente (seção 19).
///
/// Nunca colocamos dados sensíveis nem o `companyId` no QR — apenas um
/// identificador opaco do ambiente ([code]). A empresa e a permissão são
/// sempre validadas no servidor a partir do usuário autenticado.
class QrPayload {
  const QrPayload({required this.code});

  /// Identificador opaco do ambiente (ex.: "QR-NVD-0001").
  final String code;

  static const _type = 'location';

  /// Serializa para a string que vira o QR Code.
  String encode() => jsonEncode({'type': _type, 'code': code});

  /// Interpreta o conteúdo lido. Aceita tanto o JSON quanto o código puro
  /// (facilita a digitação manual no fallback). Retorna `null` se inválido.
  static QrPayload? tryDecode(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;

    if (value.startsWith('{')) {
      try {
        final map = jsonDecode(value);
        if (map is Map &&
            map['type'] == _type &&
            map['code'] is String &&
            (map['code'] as String).trim().isNotEmpty) {
          return QrPayload(code: (map['code'] as String).trim());
        }
      } catch (_) {
        return null;
      }
      return null;
    }

    // Código puro digitado manualmente.
    return QrPayload(code: value);
  }
}

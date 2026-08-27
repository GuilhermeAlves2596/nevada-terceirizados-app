import 'package:flutter/widgets.dart';

/// Na web, o `XFile.path` é uma blob URL — carregada via [Image.network].
Widget localImage(String path, {BoxFit fit = BoxFit.cover}) {
  return Image.network(path, fit: fit);
}

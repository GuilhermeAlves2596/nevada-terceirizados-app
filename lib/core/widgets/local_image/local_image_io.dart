import 'dart:io';

import 'package:flutter/widgets.dart';

/// Exibe uma imagem a partir de um caminho de arquivo local (mobile/desktop).
Widget localImage(String path, {BoxFit fit = BoxFit.cover}) {
  return Image.file(File(path), fit: fit);
}

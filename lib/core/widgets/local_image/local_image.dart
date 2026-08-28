// Exporta `localImage(path)` escolhendo a implementação por plataforma:
// `Image.file` (dart:io) em mobile/desktop e `Image.network` (blob) na web.
export 'local_image_io.dart' if (dart.library.html) 'local_image_web.dart';

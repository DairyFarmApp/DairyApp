import 'dart:typed_data';

import 'export_file_saver_native.dart'
    if (dart.library.js_interop) 'export_file_saver_web.dart'
    as platform;

final class ExportFileSaver {
  const ExportFileSaver();

  Future<bool> save({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) =>
      platform.saveExport(bytes: bytes, filename: filename, mimeType: mimeType);
}

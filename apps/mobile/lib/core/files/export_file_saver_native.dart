import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart' hide XFile;

Future<bool> saveExport({
  required Uint8List bytes,
  required String filename,
  required String mimeType,
}) async {
  final desktop = switch (defaultTargetPlatform) {
    TargetPlatform.linux ||
    TargetPlatform.macOS ||
    TargetPlatform.windows => true,
    _ => false,
  };
  if (desktop) {
    final extension = filename.split('.').last;
    final location = await getSaveLocation(
      suggestedName: filename,
      acceptedTypeGroups: [
        XTypeGroup(
          label: extension.toUpperCase(),
          extensions: [extension],
          mimeTypes: [mimeType],
        ),
      ],
    );
    if (location == null) return false;
    await XFile.fromData(
      bytes,
      mimeType: mimeType,
      name: filename,
    ).saveTo(location.path);
    return true;
  }

  final result = await SharePlus.instance.share(
    ShareParams(
      title: 'DairyCare inventory export',
      subject: 'DairyCare inventory export',
      files: [XFile.fromData(bytes, mimeType: mimeType, name: filename)],
      fileNameOverrides: [filename],
    ),
  );
  return result.status != ShareResultStatus.dismissed;
}

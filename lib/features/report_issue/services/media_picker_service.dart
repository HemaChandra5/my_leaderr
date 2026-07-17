import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/report_issue_constants.dart';

enum PickedMediaType { image, video }

class PickedMedia {
  const PickedMedia({required this.file, required this.type});

  final XFile file;
  final PickedMediaType type;
}

class MediaPickerResult {
  const MediaPickerResult({required this.items, this.warning});

  final List<PickedMedia> items;
  final String? warning;
}

class MediaPickerFailure implements Exception {
  const MediaPickerFailure(this.message);

  final String message;
}

class MediaPickerService {
  MediaPickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<MediaPickerResult> pickFromCamera() async {
    try {
      final XFile? rawFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );
      if (rawFile == null) {
        return const MediaPickerResult(items: <PickedMedia>[]);
      }

      final _CompressionResult optimized = await _compressImage(rawFile);
      return MediaPickerResult(
        items: <PickedMedia>[
          PickedMedia(file: optimized.file, type: PickedMediaType.image),
        ],
        warning: optimized.warning,
      );
    } on PlatformException catch (error) {
      throw MediaPickerFailure(_mapPlatformError(error));
    } catch (_) {
      throw const MediaPickerFailure(ReportIssueText.pickerFailed);
    }
  }

  Future<MediaPickerResult> pickImagesFromGallery() async {
    try {
      final List<XFile> selected = await _picker.pickMultiImage(
        imageQuality: 100,
      );
      if (selected.isEmpty) {
        return const MediaPickerResult(items: <PickedMedia>[]);
      }

      final List<PickedMedia> items = <PickedMedia>[];
      String? warning;
      for (final XFile file in selected) {
        final _CompressionResult compressed = await _compressImage(file);
        items.add(
          PickedMedia(file: compressed.file, type: PickedMediaType.image),
        );
        warning ??= compressed.warning;
      }

      return MediaPickerResult(items: items, warning: warning);
    } on PlatformException catch (error) {
      throw MediaPickerFailure(_mapPlatformError(error));
    } catch (_) {
      throw const MediaPickerFailure(ReportIssueText.pickerFailed);
    }
  }

  Future<MediaPickerResult> pickVideoFromGallery() async {
    try {
      final XFile? selected = await _picker.pickVideo(
        source: ImageSource.gallery,
      );
      if (selected == null) {
        return const MediaPickerResult(items: <PickedMedia>[]);
      }

      return MediaPickerResult(
        items: <PickedMedia>[
          PickedMedia(file: selected, type: PickedMediaType.video),
        ],
      );
    } on PlatformException catch (error) {
      throw MediaPickerFailure(_mapPlatformError(error));
    } catch (_) {
      throw const MediaPickerFailure(ReportIssueText.pickerFailed);
    }
  }

  Future<_CompressionResult> _compressImage(XFile source) async {
    try {
      final Uint8List sourceBytes = await source.readAsBytes();
      final Uint8List compressed = await FlutterImageCompress.compressWithList(
        sourceBytes,
        quality: 82,
        minHeight: 1280,
        minWidth: 1280,
        format: CompressFormat.jpeg,
      );

      if (compressed.isEmpty) {
        return _CompressionResult(
          file: source,
          warning: ReportIssueText.compressionFailed,
        );
      }

      final String fileName =
          'my_leader_${DateTime.now().microsecondsSinceEpoch}.jpg';
      final File output = File('${Directory.systemTemp.path}/$fileName');
      await output.writeAsBytes(compressed, flush: true);
      return _CompressionResult(file: XFile(output.path));
    } catch (_) {
      return _CompressionResult(
        file: source,
        warning: ReportIssueText.compressionFailed,
      );
    }
  }

  String _mapPlatformError(PlatformException error) {
    final String code = error.code.toLowerCase();
    if (code.contains('denied') || code.contains('access')) {
      return ReportIssueText.pickerPermissionDenied;
    }
    return ReportIssueText.pickerFailed;
  }
}

class _CompressionResult {
  const _CompressionResult({required this.file, this.warning});

  final XFile file;
  final String? warning;
}

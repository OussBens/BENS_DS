import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

const int _maxUploadDimension = 1600;
const int _uploadJpegQuality = 82;

Uint8List _resizeAndEncodeJpeg(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;

  var resized = decoded;
  if (decoded.width > _maxUploadDimension || decoded.height > _maxUploadDimension) {
    resized = decoded.width >= decoded.height
        ? img.copyResize(decoded, width: _maxUploadDimension)
        : img.copyResize(decoded, height: _maxUploadDimension);
  }

  return Uint8List.fromList(img.encodeJpg(resized, quality: _uploadJpegQuality));
}

Future<Uint8List> compressImageBytes(Uint8List bytes) {
  return compute(_resizeAndEncodeJpeg, bytes);
}

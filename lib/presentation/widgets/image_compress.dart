import 'dart:typed_data';

import 'image_compress_stub.dart' if (dart.library.html) 'image_compress_web.dart' as impl;

Future<Uint8List> compressImageBytes(Uint8List bytes) => impl.compressImageBytes(bytes);

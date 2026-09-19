import 'package:image_picker/image_picker.dart';

import '../../domain/services/photo_source.dart';

final class ImagePickerPhotoSource implements PhotoSource {
  ImagePickerPhotoSource();

  static const int maxEdge = 2048;

  static const int quality = 85;

  final ImagePicker _picker = ImagePicker();

  @override
  Future<String?> take(PhotoOrigin from) async {
    try {
      final XFile? shot = await _picker.pickImage(
        source: switch (from) {
          PhotoOrigin.camera => ImageSource.camera,
          PhotoOrigin.library => ImageSource.gallery,
        },
        maxWidth: maxEdge.toDouble(),
        maxHeight: maxEdge.toDouble(),
        imageQuality: quality,
      );

      return shot?.path;
    } on Object {
      return null;
    }
  }
}

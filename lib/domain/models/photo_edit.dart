import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_edit.freezed.dart';

@freezed
sealed class PhotoEdit with _$PhotoEdit {
  const factory PhotoEdit.keep() = KeepPhoto;

  const factory PhotoEdit.remove() = RemovePhoto;

  const factory PhotoEdit.replace({required String tempPath}) = ReplacePhoto;
}

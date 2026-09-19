import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'repositories/chit_repository.dart';

part 'photo_file.g.dart';

@riverpod
Future<String> photoFile(Ref ref, String path) =>
    ref.watch(chitRepositoryProvider).photoFileOf(path);

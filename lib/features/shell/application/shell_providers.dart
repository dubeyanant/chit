import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/repositories/chit_repository.dart';

part 'shell_providers.g.dart';

@riverpod
Stream<bool> anyChitWritten(Ref ref) =>
    ref.watch(chitRepositoryProvider).watchAnyWritten();

@riverpod
Stream<bool> anyChitTagged(Ref ref) =>
    ref.watch(chitRepositoryProvider).watchAnyTagged();

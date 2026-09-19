import 'package:chitta/core/clock.dart';
import 'package:chitta/domain/find_line.dart';
import 'package:chitta/features/find/application/find_line_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

void main() {
  ProviderContainer containerOf() {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(
          FakeClock(DateTime(2026, 9, 19, 10, 30)),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('the line turns on arriving at find — ADR-093', () {
    test('it does not move while nothing arrives', () {
      final ProviderContainer container = containerOf();
      final String first = container.read(findLineProvider);

      expect(container.read(findLineProvider), first);
      expect(container.read(findLineProvider), first);
    });

    test('an arrival moves it', () {
      final ProviderContainer container = containerOf();
      final String before = container.read(findLineProvider);

      container.read(findVisitProvider.notifier).arrived();

      expect(container.read(findLineProvider), isNot(before));
    });

    test('every arrival moves it again', () {
      final ProviderContainer container = containerOf();

      final List<String> seen = <String>[container.read(findLineProvider)];
      for (int i = 0; i < 12; i++) {
        container.read(findVisitProvider.notifier).arrived();
        seen.add(container.read(findLineProvider));
      }

      for (int i = 1; i < seen.length; i++) {
        expect(seen[i], isNot(seen[i - 1]), reason: 'arrival $i repeated');
      }
    });

    test('and every line it lands on is one of the written ones', () {
      final ProviderContainer container = containerOf();

      for (int i = 0; i < 200; i++) {
        expect(FindLine.all, contains(container.read(findLineProvider)));
        container.read(findVisitProvider.notifier).arrived();
      }
    });
  });

  group('the count starts at the day, so a cold launch is not a rerun', () {
    test('two days open find on different lines', () {
      final ProviderContainer monday = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(FakeClock(DateTime(2026, 9, 21, 9))),
        ],
      );
      addTearDown(monday.dispose);

      final ProviderContainer tuesday = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(FakeClock(DateTime(2026, 9, 22, 9))),
        ],
      );
      addTearDown(tuesday.dispose);

      expect(
        monday.read(findLineProvider),
        isNot(tuesday.read(findLineProvider)),
      );
    });

    test('the visit count itself starts at nothing', () {
      expect(containerOf().read(findVisitProvider), 0);
    });
  });
}

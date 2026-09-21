import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/app.dart';
import 'package:__APP__/presentation/core/gen/i18n/strings.g.dart';

void main() {
  // Proves the wiring boots: router, slang, ProviderScope, hooks, the effect
  // stream and the loading overlay all have to be live for this to pass.
  testWidgets('boots, loads, and refresh goes through runLoad + effects',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: TranslationProvider(child: const App())),
    );
    // auto_route builds its first page asynchronously; a bare pump lands
    // before the route exists.
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuvalapp/config/theme/app_theme.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/widgets/steam_trap_input.dart';

void main() {
  testWidgets('Theme follows system changes while the form is open', (
    tester,
  ) async {
    final platform = tester.binding.platformDispatcher;
    final controller = TextEditingController();
    addTearDown(platform.clearPlatformBrightnessTestValue);
    addTearDown(controller.dispose);
    platform.platformBrightnessTestValue = Brightness.light;

    await tester.pumpWidget(
      MaterialApp(
        theme: const AppTheme().theme(),
        darkTheme: const AppTheme().theme(brightness: Brightness.dark),
        themeMode: ThemeMode.system,
        home: Scaffold(
          body: SteamTrapInput(
            label: 'Presión',
            controller: controller,
            onChanged: () {},
          ),
        ),
      ),
    );

    final field = find.byType(TextField);
    expect(Theme.of(tester.element(field)).brightness, Brightness.light);
    expect(
      tester.widget<TextField>(field).decoration!.fillColor,
      AppColors.card,
    );
    await tester.enterText(field, '125');

    platform.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    final context = tester.element(field);
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(
      tester.widget<TextField>(field).decoration!.fillColor,
      const AppPalette(Brightness.dark).card,
    );
    expect(context.appColors.text, isNot(AppColors.text));
    expect(controller.text, '125');

    platform.platformBrightnessTestValue = Brightness.light;
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(field)).brightness, Brightness.light);
    expect(
      tester.widget<TextField>(field).decoration!.fillColor,
      AppColors.card,
    );
    expect(controller.text, '125');
    expect(tester.takeException(), isNull);
  });
}

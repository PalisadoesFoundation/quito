import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talawa/constants/constants.dart';
import 'package:talawa/constants/custom_theme.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/router.dart' as router;
import 'package:talawa/services/graphql_config.dart';
import 'package:talawa/services/navigation_service.dart';
import 'package:talawa/services/size_config.dart';
import 'package:talawa/views/pre_auth_screens/select_language.dart';

Widget createSelectLanguageScreenLight(
        {ThemeMode themeMode = ThemeMode.light}) =>
    MaterialApp(
      key: const Key('Root'),
      themeMode: themeMode,
      theme: TalawaTheme.lightTheme,
      home: const SelectLanguage(
        key: Key('SelectLanguage'),
        selectedLangId: 0,
      ),
      navigatorKey: locator<NavigationService>().navigatorKey,
      onGenerateRoute: router.generateRoute,
    );

Widget createSelectLanguageScreenDark({ThemeMode themeMode = ThemeMode.dark}) =>
    MaterialApp(
      key: const Key('Root'),
      themeMode: themeMode,
      darkTheme: TalawaTheme.darkTheme,
      home: const SelectLanguage(
        key: Key('SelectLanguage'),
        selectedLangId: 0,
      ),
      navigatorKey: locator<NavigationService>().navigatorKey,
      onGenerateRoute: router.generateRoute,
    );

void main() {
  setupLocator();
  locator<GraphqlConfig>().test();
  locator<SizeConfig>().test();
  group('Select Language Screen Widget Test in light mode', () {
    testWidgets("Testing if Select Language Screen shows up", (tester) async {
      await tester.pumpWidget(createSelectLanguageScreenLight());
      final screenScaffoldWidget =
          find.byKey(const Key('SelectLanguageScreenScaffold'));
      expect(screenScaffoldWidget, findsOneWidget);
      expect(
        (tester.firstWidget(find.byKey(const Key('Root'))) as MaterialApp)
            .theme!
            .scaffoldBackgroundColor,
        TalawaTheme.lightTheme.scaffoldBackgroundColor,
      );
    });
    testWidgets("Testing if screen title shows up", (tester) async {
      await tester.pumpWidget(createSelectLanguageScreenLight());
      final findAppNameWidget = find.text('Select Language');
      expect(findAppNameWidget, findsOneWidget);
      expect((tester.firstWidget(findAppNameWidget) as Text).style!.color,
          TalawaTheme.lightTheme.textTheme.headline5!.color);
      expect((tester.firstWidget(findAppNameWidget) as Text).style!.fontFamily,
          TalawaTheme.lightTheme.textTheme.headline5!.fontFamily);
      expect((tester.firstWidget(findAppNameWidget) as Text).style!.fontSize,
          TalawaTheme.lightTheme.textTheme.headline5!.fontSize);
    });
    testWidgets("Testing if search box shows up", (tester) async {
      await tester.pumpWidget(createSelectLanguageScreenLight());
      final findAppNameWidget = find.byKey(const Key('SearchField'));
      expect(findAppNameWidget, findsOneWidget);
    });
    testWidgets("Testing if languages list shows up", (tester) async {
      await tester.pumpWidget(createSelectLanguageScreenLight());
      final findAppNameWidget = find.byKey(const Key('LanguagesList'));
      expect(findAppNameWidget, findsOneWidget);
    });
    testWidgets("Testing if all languages are shown", (tester) async {
      await tester.pumpWidget(createSelectLanguageScreenLight());
      final findAppNameWidget = find.byKey(const Key('LanguageItem'));
      expect(findAppNameWidget, findsNWidgets(languages.length));
    });
    testWidgets("Testing if only one language is selected", (tester) async {
      await tester.pumpWidget(createSelectLanguageScreenLight());
      final findAppNameWidget = find.byKey(const Key('Selected'));
      expect(findAppNameWidget, findsOneWidget);
    });
    testWidgets("Testing unselected language items", (tester) async {
      await tester.pumpWidget(createSelectLanguageScreenLight());
      final findAppNameWidget = find.byKey(const Key('NotSelected'));
      expect(findAppNameWidget, findsNWidgets(languages.length - 1));
    });
    testWidgets("Testing to change language items", (tester) async {
      final int randomNumber = Random().nextInt(languages.length);
      await tester.pumpWidget(createSelectLanguageScreenLight());
      final findAppNameWidget = find.byKey(Key('LanguageItem$randomNumber'));
      await tester.tap(findAppNameWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect((tester.firstWidget(findAppNameWidget) as Container).decoration,
          BoxDecoration(color: const Color(0xFFC4C4C4).withOpacity(0.15)));
    });
    testWidgets("Testing to navigate to url page", (tester) async {
      await tester.pumpWidget(createSelectLanguageScreenLight());
      final findAppNameWidget = find.byKey(const Key('NavigateToUrlPage'));
      await tester.tap(findAppNameWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(findAppNameWidget, findsNothing);
    });
    testWidgets("Testing to select and navigate button appears",
        (tester) async {
      await tester.pumpWidget(createSelectLanguageScreenLight());
      final findAppNameWidget = find.byKey(const Key('SelectLangTextButton'));
      expect(findAppNameWidget, findsOneWidget);
      expect(
          (tester.firstWidget(findAppNameWidget) as Text).style!.fontSize, 18);
      expect(
        (tester.firstWidget(findAppNameWidget) as Text).style!.color,
        const Color(0xFF008A37),
      );
    });
  });
  group('Select Language Screen Widget Test in dark mode', () {
    testWidgets("Testing if Select Language Screen shows up", (tester) async {
      await tester.pumpWidget(createSelectLanguageScreenDark());
      final screenScaffoldWidget =
          find.byKey(const Key('SelectLanguageScreenScaffold'));
      expect(screenScaffoldWidget, findsOneWidget);
      expect(
        (tester.firstWidget(find.byKey(const Key('Root'))) as MaterialApp)
            .darkTheme!
            .scaffoldBackgroundColor,
        TalawaTheme.darkTheme.scaffoldBackgroundColor,
      );
    });
    testWidgets("Testing if screen title shows up", (tester) async {
      await tester.pumpWidget(createSelectLanguageScreenDark());
      final findAppNameWidget = find.text('Select Language');
      expect(findAppNameWidget, findsOneWidget);
      expect((tester.firstWidget(findAppNameWidget) as Text).style!.color,
          TalawaTheme.darkTheme.textTheme.headline5!.color);
      expect((tester.firstWidget(findAppNameWidget) as Text).style!.fontFamily,
          TalawaTheme.darkTheme.textTheme.headline5!.fontFamily);
      expect((tester.firstWidget(findAppNameWidget) as Text).style!.fontSize,
          TalawaTheme.darkTheme.textTheme.headline5!.fontSize);
    });
    testWidgets("Testing if search box shows up", (tester) async {
      await tester.pumpWidget(createSelectLanguageScreenDark());
      final findAppNameWidget = find.byKey(const Key('SearchField'));
      expect(findAppNameWidget, findsOneWidget);
    });
    testWidgets("Testing if languages list shows up", (tester) async {
      await tester.pumpWidget(createSelectLanguageScreenDark());
      final findAppNameWidget = find.byKey(const Key('LanguagesList'));
      expect(findAppNameWidget, findsOneWidget);
    });
    testWidgets("Testing if all languages are shown", (tester) async {
      await tester.pumpWidget(createSelectLanguageScreenDark());
      final findAppNameWidget = find.byKey(const Key('LanguageItem'));
      expect(findAppNameWidget, findsNWidgets(languages.length));
    });
    testWidgets("Testing if only one language is selected", (tester) async {
      await tester.pumpWidget(createSelectLanguageScreenDark());
      final findAppNameWidget = find.byKey(const Key('Selected'));
      expect(findAppNameWidget, findsOneWidget);
    });
    testWidgets("Testing unselected language items", (tester) async {
      await tester.pumpWidget(createSelectLanguageScreenDark());
      final findAppNameWidget = find.byKey(const Key('NotSelected'));
      expect(findAppNameWidget, findsNWidgets(languages.length - 1));
    });
    testWidgets("Testing to change language items", (tester) async {
      final int randomNumber = Random().nextInt(languages.length);
      await tester.pumpWidget(createSelectLanguageScreenDark());
      final findAppNameWidget = find.byKey(Key('LanguageItem$randomNumber'));
      await tester.tap(findAppNameWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect((tester.firstWidget(findAppNameWidget) as Container).decoration,
          BoxDecoration(color: const Color(0xFFC4C4C4).withOpacity(0.15)));
    });
    testWidgets("Testing to select and navigate button appears",
        (tester) async {
      await tester.pumpWidget(createSelectLanguageScreenDark());
      final findAppNameWidget = find.byKey(const Key('SelectLangTextButton'));
      expect(findAppNameWidget, findsOneWidget);
      expect(
          (tester.firstWidget(findAppNameWidget) as Text).style!.fontSize, 18);
      expect(
        (tester.firstWidget(findAppNameWidget) as Text).style!.color,
        const Color(0xFF008A37),
      );
    });
    testWidgets("Testing to navigate to url page", (tester) async {
      await tester.pumpWidget(createSelectLanguageScreenDark());
      final findAppNameWidget = find.byKey(const Key('NavigateToUrlPage'));
      await tester.tap(findAppNameWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(findAppNameWidget, findsNothing);
    });
  });
}
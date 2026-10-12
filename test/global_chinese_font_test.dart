import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surgo_flutter/features/auth/auth_kit.dart';
import 'package:surgo_flutter/theme/app_theme.dart';
import 'package:surgo_flutter/theme/local_preview_fonts.dart';
import 'package:surgo_flutter/theme/tokens.dart';

void main() {
  test('all default and primary theme styles prioritize simplified PingFang', () {
    final theme = SurgoTheme.build();
    expect(SurgoFontFamily.chinese, 'PingFang SC');
    expect(SurgoFontFamily.body, SurgoFontFamily.chinese);
    expect(SurgoFontFamily.fallback.first, SurgoFontFamily.chinese);
    for (final text in [theme.textTheme, theme.primaryTextTheme]) {
      for (final style in [text.displayLarge, text.displayMedium, text.displaySmall,
        text.headlineLarge, text.headlineMedium, text.headlineSmall,
        text.titleLarge, text.titleMedium, text.titleSmall,
        text.bodyLarge, text.bodyMedium, text.bodySmall,
        text.labelLarge, text.labelMedium, text.labelSmall]) {
        expect(style!.fontFamily, SurgoFontFamily.chinese);
        expect(style.fontFamilyFallback!.first, SurgoFontFamily.chinese);
      }
    }
  });

  test('Latin title fonts are retained with Chinese fallback', () {
    for (final style in [SurgoText.h1, SurgoText.secTitle, SurgoText.cardTitle,
      SurgoText.profileTitle, SurgoText.rowLabel, SurgoText.button,
      AuthTokens.text()]) {
      expect(style.fontFamily, 'Outfit');
      expect(style.fontFamilyFallback!.first, 'PingFang SC');
    }
  });

  testWidgets('default controls inherit Chinese family and fallback', (t) async {
    await t.pumpWidget(MaterialApp(theme: SurgoTheme.build(), home: const Scaffold(
      body: Column(children: [Text('中文标题'), TextField(),
        TextButton(onPressed: null, child: Text('中文按钮'))]))));
    final input = t.widget<EditableText>(find.byType(EditableText));
    expect(input.style.fontFamily, 'PingFang SC');
    expect(input.style.fontFamilyFallback!.first, 'PingFang SC');
    expect(t.takeException(), isNull);
  });

  test('normal builds never read local proprietary font assets', () async {
    await loadLocalPreviewFonts();
  });
}

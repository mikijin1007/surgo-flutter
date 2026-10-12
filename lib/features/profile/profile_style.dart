import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_state.dart';
import '../../app/routes.dart';
import '../../theme/tokens.dart';

/// The exam-details page is the visual baseline for every profile subpage.
TextStyle profileHeading([double size = 20]) => TextStyle(
  fontFamily: SurgoFontFamily.heading, fontFamilyFallback: SurgoFontFamily.fallback,
  fontSize: size, fontWeight: FontWeight.w800, color: SurgoColors.ink,
);
const profileBody = TextStyle(fontFamily: SurgoFontFamily.body,
  fontFamilyFallback: SurgoFontFamily.fallback, fontSize: 14,
  fontWeight: FontWeight.w600, height: 1.55, color: SurgoColors.ink);

class ProfileSettingsHeader extends StatelessWidget {
  const ProfileSettingsHeader({super.key, required this.title,
    required this.backKey, this.action, this.showBackButton = true});
  final String title, backKey;
  final Widget? action;
  final bool showBackButton;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
    child: Row(children: [
      Visibility(
        visible: showBackButton,
        maintainState: true, maintainAnimation: true, maintainSize: true,
        child: ProfileSettingsBackButton(backKey: showBackButton ? backKey : null)),
      Expanded(child: Text(title, textAlign: TextAlign.center,
        style: profileHeading())),
      SizedBox(width: 48, child: action),
    ]),
  );
}

/// Shared appearance and action, also usable in the page's overlay layer.
class ProfileSettingsBackButton extends StatelessWidget {
  const ProfileSettingsBackButton({super.key, required this.backKey});
  final String? backKey;
  @override
  Widget build(BuildContext context) => IconButton(
    key: backKey == null ? null : ValueKey<String>(backKey!),
    tooltip: context.watch<AppState>().lang == UiLang.zh ? '返回' : 'Back',
    onPressed: () => Navigator.pop(context),
    icon: const Icon(Icons.arrow_back));
}

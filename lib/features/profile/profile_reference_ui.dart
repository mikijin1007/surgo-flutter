import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import 'profile_style.dart';

abstract final class ProfileReferenceColors {
  static const background = SurgoColors.warmWhite;
  static const ink = SurgoColors.ink;
  static const muted = SurgoColors.muted;
  static const line = SurgoColors.line;
}

const referenceBody = profileBody;

class ProfileReferencePage extends StatelessWidget {
  const ProfileReferencePage(
      {super.key,
      required this.title,
      required this.backKey,
      required this.children,
      this.scrollKey,
      this.footer,
      this.action,
      this.backOffsetY = 0});
  final String title, backKey;
  final String? scrollKey;
  final List<Widget> children;
  final Widget? footer, action;
  final double backOffsetY;
  @override
  Widget build(BuildContext context) => ColoredBox(
        color: ProfileReferenceColors.background,
        child: DefaultTextStyle(
            style: referenceBody,
            child: Stack(children: [
              Column(children: [
              ProfileSettingsHeader(title: title, backKey: backKey, action: action,
                showBackButton: backOffsetY == 0),
              Expanded(
                  child: ListView(
                      key: scrollKey == null ? null : ValueKey(scrollKey),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      children: children)),
              if (footer != null)
                SafeArea(
                    top: false,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        child: footer)),
              ]),
              // Overlay keeps the full moved hit target above the scroll area
              // without pushing the identity block or changing header height.
              if (backOffsetY != 0)
                Positioned(left: 14, top: 8 + backOffsetY,
                  child: ProfileSettingsBackButton(backKey: backKey)),
            ])),
      );
}

class ProfileReferenceGroup extends StatelessWidget {
  const ProfileReferenceGroup({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: SurgoColors.line.withValues(alpha: .65))),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0)
            const Divider(
                height: 1,
                thickness: 1,
                indent: 18,
                color: ProfileReferenceColors.line),
          children[i],
        ]
      ]));
}

class ProfileReferenceRow extends StatelessWidget {
  const ProfileReferenceRow(
      {super.key,
      required this.label,
      this.value,
      this.icon,
      this.onTap,
      this.rowKey,
      this.singleLineLabel = false});
  final String label;
  final String? value;
  final IconData? icon;
  final VoidCallback? onTap;
  final Key? rowKey;
  final bool singleLineLabel;
  @override
  Widget build(BuildContext context) => InkWell(
        key: rowKey,
        onTap: onTap,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
            child: Row(children: [
              if (icon != null) ...[
                Icon(icon, size: 19, color: ProfileReferenceColors.ink),
                const SizedBox(width: 10)
              ],
              Expanded(child: singleLineLabel
                  ? FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
                      child: Text(label, style: referenceBody, maxLines: 1, softWrap: false))
                  : Text(label, style: referenceBody)),
              if (value != null) ...[
                const SizedBox(width: 8),
                Flexible(
                    child: Align(alignment: Alignment.centerRight,
                      child: Text(value!,
                        textAlign: TextAlign.right,
                        style: referenceBody.copyWith(
                            color: ProfileReferenceColors.muted, fontSize: 12))))
              ],
              if (onTap != null) ...[
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right,
                    size: 20, color: ProfileReferenceColors.muted)
              ],
            ])),
      );
}

class ProfileReferenceSection extends StatelessWidget {
  const ProfileReferenceSection(this.title, {super.key});
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(2, 22, 2, 10),
      child: Text(title,
          style: profileHeading(17)));
}

class ProfileReferenceNote extends StatelessWidget {
  const ProfileReferenceNote(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(2, 10, 2, 8),
      child: Text(text,
          style: referenceBody.copyWith(
              fontSize: 12, color: ProfileReferenceColors.muted)));
}

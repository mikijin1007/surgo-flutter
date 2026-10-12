import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../widgets/phone_frame.dart';
import 'profile_exam_page.dart';
import 'profile_security_page.dart';
import 'profile_help_page.dart';
import 'profile_settings_ui.dart';
import 'profile_about_page.dart';

// One active entry per phone Navigator, including its reverse transition.
// Expando does not retain a Navigator after its phone/shell has been disposed.
final _activeDetails = Expando<_ProfileDetailRoute>('profile detail');

/// Native subroutes stay inside the phone Navigator; no global navigation bar.
Future<bool?> openProfileDetail(BuildContext context, String section) {
  final Widget page = switch (section) {
    '考试信息' => const ProfileExamPage(),
    '账号安全' => const ProfileSecurityPage(),
    '语言设置' => const ProfileLanguagePage(),
    '帮助与支持' => const ProfileHelpPage(),
    '关于 SURGO' => const ProfileAboutPage(),
    _ => throw ArgumentError.value(section, 'section'),
  };
  final navigator = Navigator.of(context);
  final active = _activeDetails[navigator];
  if (active != null) return active.popped;

  final route = _ProfileDetailRoute(
    reduceMotion: MediaQuery.disableAnimationsOf(context),
    settings: RouteSettings(name: 'profile/$section'),
    builder: (context) => Material(color: SurgoColors.warmWhite,
      textStyle: profileBody, child: Stack(children: [
        Positioned.fill(
          top: SurgoDevice.statusBarHeight - (section == '账号安全' ? 20 : 0),
          child: page),
        const Positioned(top: 0, left: 0, right: 0, child: PhoneStatusBar()),
        const Positioned(top: 0, left: 0, right: 0, child: PhoneNotch()),
      ])),
  );
  _activeDetails[navigator] = route;
  // popped completes at the START of a pop. Keep the guard until the overlay
  // is actually gone, so taps during the reverse transition cannot push again.
  route.completed.then((_) {
    if (identical(_activeDetails[navigator], route)) {
      _activeDetails[navigator] = null;
    }
  });
  try {
    return navigator.push<bool>(route);
  } catch (_) {
    _activeDetails[navigator] = null;
    rethrow;
  }
}

class _ProfileDetailRoute extends CupertinoPageRoute<bool> {
  _ProfileDetailRoute({
    required bool reduceMotion,
    required super.builder,
    required super.settings,
  }) : _reduceMotion = reduceMotion;

  bool _reduceMotion;

  @override
  Duration get transitionDuration =>
      _reduceMotion ? Duration.zero : super.transitionDuration;

  @override
  Duration get reverseTransitionDuration => transitionDuration;

  @override
  DelegatedTransitionBuilder get delegatedTransition =>
      (context, animation, secondaryAnimation, allowSnapshotting, child) {
        // The underlying shell uses MaterialPageRoute. Suppress its delegated
        // parallax too, including when the OS preference changes while open.
        if (MediaQuery.disableAnimationsOf(context)) return child;
        return CupertinoPageTransition.delegatedTransition(
            context, animation, secondaryAnimation, allowSnapshotting, child);
      };

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    controller?.duration = transitionDuration;
    controller?.reverseDuration = reverseTransitionDuration;
    // Keep Cupertino's native edge gesture recognizer even with motion reduced;
    // only freeze the visual translations, not the underlying route controller.
    return super.buildTransitions(
      context,
      _reduceMotion ? kAlwaysCompleteAnimation : animation,
      _reduceMotion ? kAlwaysDismissedAnimation : secondaryAnimation,
      child,
    );
  }
}

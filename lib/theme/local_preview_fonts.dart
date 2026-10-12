import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'tokens.dart';

/// CanvasKit cannot use macOS system fonts just by CSS family name.
/// This opt-in is used by main_visual_audit only, never production main.dart.
/// The locally installed faces are prepared under ignored build/ and served
/// from loopback. Do not publish these font files or this opt-in build.
Future<void> loadLocalPreviewFonts() async {
  const enabled = bool.fromEnvironment('SURGO_LOCAL_PINGFANG');
  if (!enabled) return;
  if (!kIsWeb || !const ['localhost', '127.0.0.1', '::1'].contains(Uri.base.host)) {
    throw StateError('Local PingFang preview is restricted to loopback.');
  }
  final loader = FontLoader(SurgoFontFamily.chinese);
  for (final face in ['Regular', 'Medium', 'Semibold']) {
    loader.addFont(rootBundle.load('_local_pingfang/PingFangSC-$face.otf'));
  }
  await loader.load();
}

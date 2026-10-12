# Chinese font policy — 2026-10-12

- All Chinese glyphs prioritize `SurgoFontFamily.chinese = 'PingFang SC'`.
- English titles keep Outfit; scoped Latin fonts (Arimo, Inter, VioletSans) remain unchanged and receive the same Chinese fallback list.
- ThemeData configures both normal and primary text themes. Explicit font styles, editable text and standalone TextPainter styles also include the shared fallback.
- This change does not change font sizes, weights, source text, questions or translation rules.

## Platform boundary

Native iOS/macOS can resolve the installed system PingFang. A device without PingFang uses the configured fallback; naming the family is not a guarantee of identical glyphs on Android or Web.

CanvasKit cannot load an installed macOS font simply from the CSS family name. The audit-only entry point therefore supports an optional **loopback-only** preview flag, `--dart-define=SURGO_LOCAL_PINGFANG=true`.

1. Run `tool/prepare_local_pingfang.py --output <absolute-project>/build/local_pingfang_cache` on a Mac with PingFang installed. It makes standalone SC Regular, Medium and Semibold faces from the installed TTC without changing the original font.
2. Build `lib/main_visual_audit.dart` with the above flag into a new directory under `build/`.
3. Copy the three generated `.otf` files into `<audit-build>/assets/_local_pingfang/`.
4. Serve the audit build only from `127.0.0.1` or `localhost`. The loader rejects non-loopback hosts.

The font files are local review material only. **Do not commit, publish, deploy or redistribute this opt-in build or its system font files.** `pubspec.yaml` does not include them; production `main.dart` does not call the local loader. Normal builds continue to use the system font/fallback policy.

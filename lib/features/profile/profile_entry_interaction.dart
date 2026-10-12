import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Feedback only: the existing row supplies all layout, text and navigation.
class ProfileEntryInteraction extends StatefulWidget {
  const ProfileEntryInteraction({
    super.key,
    required this.onTap,
    required this.child,
  });

  final VoidCallback onTap;
  final Widget child;

  @override
  State<ProfileEntryInteraction> createState() => _ProfileEntryInteractionState();
}

class _ProfileEntryInteractionState extends State<ProfileEntryInteraction> {
  bool _pressed = false;
  bool _focusHighlight = false;
  bool _cancelled = false;
  int? _pointer;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  bool _contains(Offset position) {
    final box = context.findRenderObject()! as RenderBox;
    return (Offset.zero & box.size).contains(box.globalToLocal(position));
  }

  void _cancel() {
    _cancelled = true;
    _setPressed(false);
  }

  void _activate() => widget.onTap();

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 100);
    return Semantics(
      button: true,
      onTap: _activate,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (value) =>
            setState(() => _focusHighlight = value),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            _activate();
            return null;
          }),
        },
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) {
            if (_pointer != null) return;
            _pointer = event.pointer;
            _cancelled = false;
            _setPressed(true);
          },
          onPointerMove: (event) {
            if (event.pointer == _pointer && !_contains(event.position)) {
              // Leaving the original hit area cancels permanently, even if the
              // pointer comes back before release (including sub-slop moves).
              _cancel();
            }
          },
          onPointerUp: (event) {
            if (event.pointer != _pointer) return;
            if (!_contains(event.position)) _cancel();
            _pointer = null;
            _setPressed(false);
          },
          onPointerCancel: (event) {
            if (event.pointer != _pointer) return;
            _pointer = null;
            _cancel();
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTapCancel: _cancel,
            onTap: () {
              if (!_cancelled) _activate();
            },
            child: AnimatedScale(
              scale: _pressed && !reduceMotion ? .992 : 1,
              duration: duration,
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: duration,
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                // Keyboard focus remains visible without a filled highlight.
                foregroundDecoration: BoxDecoration(
                  border: _focusHighlight
                      ? Border.all(color: Colors.black38)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

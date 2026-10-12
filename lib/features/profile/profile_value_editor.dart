import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import 'profile_settings_ui.dart';

/// Compact read-only summary. Editing is isolated in a cancellable dialog.
class ProfileValueRow extends StatelessWidget {
  const ProfileValueRow(
      {super.key,
      required this.fieldId,
      required this.label,
      required this.value,
      required this.onEdit,
      required this.editLabel,
      this.isDate = false});
  final String fieldId, label, value, editLabel;
  final VoidCallback onEdit;
  final bool isDate;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        key: ValueKey('$fieldId-row'),
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(children: [
          Expanded(
              flex: isDate ? 5 : 7,
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(label,
                          key: ValueKey('$fieldId-label'),
                          maxLines: 1,
                          style: profileBody.copyWith(height: 1.2))))),
          const SizedBox(width: 10),
          Expanded(
              flex: isDate ? 6 : 3,
              child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(value,
                          key: ValueKey('$fieldId-value'),
                          maxLines: 1,
                          style: profileHeading(isDate ? 14 : 17)
                              .copyWith(height: 1.2))))),
          SizedBox(
              width: 44,
              child: IconButton(
                  key: ValueKey('$fieldId-edit'),
                  tooltip: editLabel,
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined,
                      size: 18, color: SurgoColors.muted))),
        ]),
      );
}

Future<String?> showProfileValueEditor(
  BuildContext context, {
  required String fieldId,
  required String title,
  required String value,
  required String helper,
  required bool zh,
  required String? Function(String?) validator,
  DateTime? Function(String)? parseDate,
}) =>
    showDialog<String>(
      context: context,
      useRootNavigator: false,
      builder: (_) => _ValueEditor(
          fieldId: fieldId,
          title: title,
          value: value,
          helper: helper,
          zh: zh,
          validator: validator,
          parseDate: parseDate),
    );

class _ValueEditor extends StatefulWidget {
  const _ValueEditor(
      {required this.fieldId,
      required this.title,
      required this.value,
      required this.helper,
      required this.zh,
      required this.validator,
      this.parseDate});
  final String fieldId, title, value, helper;
  final bool zh;
  final String? Function(String?) validator;
  final DateTime? Function(String)? parseDate;
  @override
  State<_ValueEditor> createState() => _ValueEditorState();
}

class _ValueEditorState extends State<_ValueEditor> {
  final form = GlobalKey<FormState>();
  late final controller = TextEditingController(text: widget.value);
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void confirm() {
    if (form.currentState!.validate()) {
      Navigator.pop(context, controller.text.trim());
    }
  }

  Future<void> pickDate() async {
    final chosen = await showDatePicker(
        context: context,
        useRootNavigator: false,
        initialDate: widget.parseDate!(controller.text) ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100, 12, 31),
        helpText: widget.zh ? '选择考试日期' : 'Choose your exam date',
        cancelText: widget.zh ? '取消' : 'Cancel',
        confirmText: widget.zh ? '确定' : 'OK');
    if (chosen != null && mounted) {
      controller.text =
          '${chosen.year}-${chosen.month.toString().padLeft(2, '0')}-${chosen.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        key: const ValueKey('profile-value-dialog'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(widget.title, style: profileHeading(18)),
        content: SingleChildScrollView(
            child: Form(
                key: form,
                child: TextFormField(
                  key: ValueKey(widget.fieldId),
                  controller: controller,
                  autofocus: true,
                  style: profileBody,
                  keyboardType: widget.parseDate != null
                      ? TextInputType.datetime
                      : const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  validator: widget.validator,
                  onFieldSubmitted: (_) => confirm(),
                  decoration: InputDecoration(
                      labelText: widget.title,
                      helperText: widget.helper,
                      helperMaxLines: 3,
                      errorMaxLines: 3,
                      filled: true,
                      fillColor: const Color(0xfffaf7f0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: SurgoColors.line)),
                      suffixIcon: widget.parseDate == null
                          ? null
                          : IconButton(
                              key: const ValueKey('profile-exam-calendar'),
                              tooltip: widget.zh ? '选择日期' : 'Choose date',
                              onPressed: pickDate,
                              icon: const Icon(Icons.calendar_month_outlined))),
                ))),
        actions: [
          TextButton(
              key: const ValueKey('profile-value-cancel'),
              onPressed: () => Navigator.pop(context),
              child: Text(widget.zh ? '取消' : 'Cancel')),
          FilledButton(
              key: const ValueKey('profile-value-confirm'),
              style: FilledButton.styleFrom(
                  backgroundColor: SurgoColors.yellow,
                  foregroundColor: SurgoColors.onYellowStrong),
              onPressed: confirm,
              child: Text(widget.zh ? '确定' : 'Done')),
        ],
      );
}

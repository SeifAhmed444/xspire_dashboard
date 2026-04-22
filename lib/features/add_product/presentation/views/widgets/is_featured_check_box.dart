import 'package:flutter/material.dart';
import 'package:xspire_dashboard/core/utils/app_text_style.dart';
import 'package:xspire_dashboard/features/add_product/presentation/views/widgets/custom_check_box.dart';

class CheckBox extends StatefulWidget {
  // Added a required `label` parameter so callers can distinguish the two
  // checkboxes ("Is available" vs "Is open").
  const CheckBox.IsCheckBox({
    super.key,
    required this.onChanged,
    this.label = 'Is available',
  });

  final ValueChanged<bool> onChanged;
  final String label;

  @override
  State<CheckBox> createState() => _CheckBoxState();
}

class _CheckBoxState extends State<CheckBox> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: widget.label,
                style: TextStyles.semiBold13.copyWith(
                  color: const Color(0xFF949D9E),
                ),
              ),
            ],
          ),
          textAlign: TextAlign.right,
        ),
        const Spacer(flex: 25),
        CustomCheckBox(
          onChecked: (value) {
            setState(() => _isChecked = value);
            widget.onChanged(value);
          },
          isChecked: _isChecked,
        ),
        Expanded(child: const SizedBox(width: 16)),
      ],
    );
  }
}

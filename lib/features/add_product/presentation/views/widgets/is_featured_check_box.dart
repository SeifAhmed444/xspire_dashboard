import 'package:flutter/material.dart';
import 'package:xspire_dashboard/core/utils/app_text_style.dart';
import 'package:xspire_dashboard/features/add_product/presentation/views/widgets/custom_check_box.dart';

class IsFeaturedCheckBox extends StatefulWidget {
  // Added a required `label` parameter so callers can distinguish the two
  // checkboxes ("Is available" vs "Is open").
  const IsFeaturedCheckBox({
    super.key,
    required this.onChanged,
    this.label = 'Is available',
    this.value = false,
  });

  final ValueChanged<bool> onChanged;
  final String label;
  final bool value;

  @override
  State<IsFeaturedCheckBox> createState() => _IsFeaturedCheckBoxState();
}

class _IsFeaturedCheckBoxState extends State<IsFeaturedCheckBox> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.value;
  }

  @override
  void didUpdateWidget(covariant IsFeaturedCheckBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _isChecked = widget.value;
    }
  }

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

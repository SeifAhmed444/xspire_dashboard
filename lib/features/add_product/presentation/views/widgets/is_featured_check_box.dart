import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xspire_dashboard/core/utils/app_colors.dart';
import 'package:xspire_dashboard/core/utils/app_text_style.dart';
import 'package:xspire_dashboard/features/add_product/presentation/views/widgets/custom_check_box.dart';

class CheckBox extends StatefulWidget {
  const CheckBox.IsCheckBox({super.key, required this.onChanged});

  final ValueChanged<bool> onChanged;
  @override
  State<CheckBox> createState() => _CheckBoxState();
}

class _CheckBoxState extends State<CheckBox> {
  bool isTermsAccepted = false;
  

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Is available',
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
            isTermsAccepted = value;
            widget.onChanged(value);
            setState(() {});
          },
          isChecked: isTermsAccepted,
        ),
        Expanded(child: const SizedBox(width: 16)),
      ],
    );
  }
}

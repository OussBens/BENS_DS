import 'package:flutter/material.dart';

class FilterSection extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const FilterSection({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontFamily: 'Inter', 
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
// lib/presentation/widgets/custom_chip_selector.dart
import 'package:flutter/material.dart';

class CustomChipSelector extends StatelessWidget {
  final String label;
  final List<String> items;
  final List<String> selectedItems;
  final Function(List<String>) onSelectionChanged;

  const CustomChipSelector({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItems,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontFamily: 'Inter', 
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            return FilterChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onSelectionChanged([...selectedItems, item]);
                } else {
                  onSelectionChanged(selectedItems.where((i) => i != item).toList());
                }
              },
              backgroundColor: Colors.grey.shade100,
              selectedColor: Colors.black,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),
      ],
    );
  }
}
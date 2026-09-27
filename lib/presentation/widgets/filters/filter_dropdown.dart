import 'package:flutter/material.dart';

class FilterDropdown extends StatefulWidget {
  final String hint;
  final List<String> items;
  final List<String> selectedItems;
  final Function(List<String>) onSelectionChanged;

  const FilterDropdown({
    super.key,
    required this.hint,
    required this.items,
    required this.selectedItems,
    required this.onSelectionChanged,
  });

  @override
  State<FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Afficher les chips sélectionnés
        if (widget.selectedItems.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.selectedItems.map((item) {
                return Chip(
                  label: Text(item),
                  onDeleted: () {
                    final newSelected = List<String>.from(widget.selectedItems);
                    newSelected.remove(item);
                    widget.onSelectionChanged(newSelected);
                  },
                  backgroundColor: Colors.black,
                  labelStyle: const TextStyle(color: Colors.white),
                  deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                );
              }).toList(),
            ),
          ),

        // Dropdown button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(widget.hint),
              value: null,
              items: widget.items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      if (widget.selectedItems.contains(item))
                        const Icon(Icons.check, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(item),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  if (widget.selectedItems.contains(value)) {
                    // Retirer si déjà sélectionné
                    final newSelected = List<String>.from(widget.selectedItems);
                    newSelected.remove(value);
                    widget.onSelectionChanged(newSelected);
                  } else {
                    // Ajouter
                    widget.onSelectionChanged([...widget.selectedItems, value]);
                  }
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
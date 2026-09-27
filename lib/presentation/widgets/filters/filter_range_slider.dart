import 'package:flutter/material.dart';

class FilterRangeSlider extends StatelessWidget {
  final double min;
  final double max;
  final RangeValues values;
  final Function(RangeValues) onChanged;
  final String Function(double) formatLabel;
  final int? divisions; // Nouveau paramètre optionnel

  const FilterRangeSlider({
    super.key,
    required this.min,
    required this.max,
    required this.values,
    required this.onChanged,
    this.formatLabel = _defaultFormat,
    this.divisions, // Divisions optionnelles
  });

  static String _defaultFormat(double value) {
    return value.toInt().toString();
  }

  // Calculer le nombre de divisions par défaut
  int get _defaultDivisions {
    final range = max - min;
    if (range <= 10) return 10;
    if (range <= 20) return 20;
    if (range <= 50) return 25;
    if (range <= 100) return 20;
    return 20;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDivisions = divisions ?? _defaultDivisions;

    return Column(
      children: [
        RangeSlider(
          values: values,
          min: min,
          max: max,
          divisions: effectiveDivisions,
          activeColor: Colors.black,
          inactiveColor: Colors.grey.shade300,
          labels: RangeLabels(
            formatLabel(values.start),
            formatLabel(values.end),
          ),
          onChanged: onChanged,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatLabel(values.start),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                formatLabel(values.end),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
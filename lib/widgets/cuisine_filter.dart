import 'package:flutter/material.dart';

class CuisineFilter extends StatelessWidget {
  final List<String> cuisines;
  final String? selectedCuisine;
  final Function(String?) onCuisineSelected;

  const CuisineFilter({
    super.key,
    required this.cuisines,
    required this.selectedCuisine,
    required this.onCuisineSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: cuisines.length + 1, // +1 for "All" option
      itemBuilder: (context, index) {
        if (index == 0) {
          // "All" option
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: selectedCuisine == null,
              onSelected: (selected) {
                onCuisineSelected(null);
              },
              selectedColor: Colors.red.withOpacity(0.2),
              checkmarkColor: Colors.red,
            ),
          );
        }

        final cuisine = cuisines[index - 1];
        final isSelected = selectedCuisine == cuisine;

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(cuisine),
            selected: isSelected,
            onSelected: (selected) {
              onCuisineSelected(selected ? cuisine : null);
            },
            selectedColor: Colors.red.withOpacity(0.2),
            checkmarkColor: Colors.red,
          ),
        );
      },
    );
  }
}
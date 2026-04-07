import 'package:flutter/material.dart';

class CategoryIconPicker extends StatefulWidget {
  final Function(String) onIconSelected;
  const CategoryIconPicker({super.key, required this.onIconSelected});

  @override
  State<CategoryIconPicker> createState() => _CategoryIconPickerState();
}

class _CategoryIconPickerState extends State<CategoryIconPicker> {
  final List<String> icons = [
    // 'assets/icons/food.svg',
    // 'assets/icons/transport.svg',
    // 'assets/icons/shopping.svg',
    // 'assets/icons/entertainment.svg',
    // 'assets/icons/health.svg',
    // 'assets/icons/education.svg',
    // 'assets/icons/bills.svg',
    // 'assets/icons/salary.svg',
    // 'assets/icons/gift.svg',
    // 'assets/icons/other.svg',
    '💰', '💵', '💶', '💷', '💸', '💳', '💎',
    '🍔', '🍕', '🍜', '☕', '🍺', '🍷',
    '🚗', '🚕', '✈️', '🚌', '🚲', '⛽',
    '🛍️', '👕', '👗', '👠', '💄',
    '🎬', '🎮', '🎵', '🎸', '🎭',
    '🏥', '💊', '💉', '🏋️',
    '📚', '✏️', '🎓', '📖',
    '💡', '📱', '💻', '📺',
    '🏠', '🔧', '🔨', '🌿',
    '🎁', '🎉', '🎂', '💝',
    '📝', '⭐', '❤️', '👍',
  ];
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose an Icon',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: icons.length,
              itemBuilder: (context, index) {
                final iconPath = icons[index];
                return InkWell(
                  onTap: () {
                    widget.onIconSelected(iconPath);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      // child: Image.asset(
                      //   iconPath,
                      //   width: 30,
                      //   height: 30,
                      // ),
                      child: Text(
                        iconPath,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

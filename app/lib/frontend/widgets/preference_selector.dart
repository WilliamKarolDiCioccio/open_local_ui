import 'dart:math';

import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

class Preference {
  final IconData icon;
  final String title;
  final String description;

  Preference({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class PreferenceSelector extends StatefulWidget {
  final List<Preference> preferences;
  final int cardsPerRow;
  final bool allowMultipleSelection;

  const PreferenceSelector({
    super.key,
    required this.preferences,
    this.cardsPerRow = 2,
    this.allowMultipleSelection = false,
  });

  @override
  State<PreferenceSelector> createState() => _PreferenceSelectorState();
}

class _PreferenceSelectorState extends State<PreferenceSelector> {
  List<int> _selectedIndices = [];

  void _onCardTapped(int index) {
    setState(() {
      if (widget.allowMultipleSelection) {
        if (_selectedIndices.contains(index)) {
          _selectedIndices.remove(index);
        } else {
          _selectedIndices.add(index);
        }
      } else {
        if (_selectedIndices.contains(index)) {
          _selectedIndices.clear();
        } else {
          _selectedIndices = [index];
        }
      }
    });
  }

  Color _getCardContentColor(BuildContext context, bool isSelected) {
    if (AdaptiveTheme.of(context).mode.isDark) {
      return isSelected ? Colors.black : Colors.white;
    } else {
      return isSelected ? Colors.white : Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.cardsPerRow,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: widget.preferences.length,
      itemBuilder: (context, index) {
        final isSelected = _selectedIndices.contains(index);
        return GestureDetector(
          onTap: () => _onCardTapped(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isSelected
                  ? AdaptiveTheme.of(context)
                      .theme
                      .buttonTheme
                      .colorScheme!
                      .primary
                  : AdaptiveTheme.of(
                      context,
                    ).theme.cardColor,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AdaptiveTheme.of(context)
                            .theme
                            .buttonTheme
                            .colorScheme!
                            .primary
                            .withOpacity(0.5),
                        blurRadius: 10.0,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : [
                      const BoxShadow(
                        blurRadius: 5.0,
                        offset: Offset(0, 2),
                      ),
                    ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.preferences[index].icon,
                    size: 50,
                    color: _getCardContentColor(context, isSelected),
                  ),
                  const Gap(8),
                  Text(
                    widget.preferences[index].title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _getCardContentColor(context, isSelected),
                    ),
                  ),
                  const Gap(8),
                  Text(
                    widget.preferences[index].description,
                    style: TextStyle(
                      fontSize: 16,
                      color: _getCardContentColor(context, isSelected),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
              .animate(
                delay: 250.ms + ((Random().nextInt(4) + 1) * 100).ms,
              )
              .scaleXY(begin: 1.1, curve: Curves.easeOutBack)
              .fade(),
        );
      },
    );
  }
}

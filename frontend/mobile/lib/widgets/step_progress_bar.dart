import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/screening_session.dart';

class StepProgressBar extends StatelessWidget {
  final ScreeningStage currentStage;

  const StepProgressBar({
    super.key,
    required this.currentStage,
  });

  @override
  Widget build(BuildContext context) {
    const steps = [
      {'label': 'Document', 'stageIndex': 0},
      {'label': 'Scan', 'stageIndex': 1},
      {'label': 'Tilt Check', 'stageIndex': 2},
      {'label': 'Liveness', 'stageIndex': 3},
      {'label': 'AI Verdict', 'stageIndex': 4},
    ];

    final currentIndex = currentStage.stepIndex;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.9),
        border: Border(
          bottom: BorderSide(color: AppTheme.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final stepBefore = index ~/ 2;
            final isCompleted = stepBefore < currentIndex;
            return Expanded(
              child: Container(
                height: 2,
                color: isCompleted
                    ? AppTheme.primaryCyan
                    : AppTheme.border.withOpacity(0.5),
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < currentIndex;
          final isActive = stepIndex == currentIndex;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppTheme.primaryCyan
                      : (isActive
                          ? AppTheme.primaryCyan.withOpacity(0.2)
                          : AppTheme.surfaceElevated),
                  border: Border.all(
                    color: (isCompleted || isActive)
                        ? AppTheme.primaryCyan
                        : AppTheme.border,
                    width: 1.8,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryCyan.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.black)
                      : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? AppTheme.primaryCyan
                                : AppTheme.textMuted,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIndex]['label'] as String,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
                  color: isActive
                      ? AppTheme.primaryCyan
                      : (isCompleted
                          ? AppTheme.textPrimary
                          : AppTheme.textMuted),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

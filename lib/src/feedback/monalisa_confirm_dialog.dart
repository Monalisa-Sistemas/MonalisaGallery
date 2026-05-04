import 'package:flutter/material.dart';

import '../buttons/monalisa_buttons.dart';
import '../theme/monalisa_colors.dart';

class MConfirmDialog {
  const MConfirmDialog._();

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String description,
    String confirmText = 'Sim',
    String cancelText = 'Não',
    Color? confirmColor,
    IconData icon = Icons.warning_amber_rounded,
  }) async {
    final primary = Theme.of(context).colorScheme.primary;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, size: 25, color: primary),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              description,
                              softWrap: true,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: MonalisaColors.textMuted,
                                    height: 1.32,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 340;
                      final buttons = [
                        MButton.outlined(
                          label: cancelText,
                          foregroundColor: Colors.blueGrey,
                          expanded: !compact,
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        MButton(
                          label: confirmText,
                          backgroundColor:
                              confirmColor ?? MonalisaColors.success,
                          foregroundColor: Colors.white,
                          expanded: !compact,
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ];

                      if (compact) {
                        return Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.end,
                          children: buttons,
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: buttons.first),
                          const SizedBox(width: 10),
                          Expanded(child: buttons.last),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return result ?? false;
  }

  static Future<bool> confirma(
    BuildContext context,
    String titulo,
    String descricao, {
    String textoSim = 'Sim',
    String textoNao = 'Não',
  }) {
    return show(
      context,
      title: titulo,
      description: descricao,
      confirmText: textoSim,
      cancelText: textoNao,
    );
  }
}

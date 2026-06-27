import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monalisa_gallery/src/buttons/monalisa_buttons.dart';
import 'package:monalisa_gallery/src/theme/monalisa_colors.dart';

/// Dialog genérico com header de ícone/título/subtítulo e footer de ações.
/// Uso:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => MGenericDialog(
///     icon: Icons.lock_person_outlined,
///     iconColor: Colors.indigo,
///     iconBackground: Colors.indigo.withValues(alpha: 0.10),
///     title: 'Alterar Senha',
///     subtitle: 'Trocar senha de operador',
///     confirmIcon: Icons.check,
///     confirmLabel: 'CONFIRMAR',
///     confirmColor: MonalisaColors.success,
///     onClose: () => Navigator.pop(context),
///     onConfirm: _confirmar,
///     child: Padding(...),
///   ),
/// );
/// ```
class MGenericDialog extends StatelessWidget {
  const MGenericDialog({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.confirmIcon,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onClose,
    required this.onConfirm,
    this.confirmLoading = false,
    this.width = 520.0,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final Widget child;
  final IconData confirmIcon;
  final String confirmLabel;
  final Color confirmColor;
  final bool confirmLoading;
  final VoidCallback? onClose;
  final VoidCallback? onConfirm;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MDialogHeader(
              icon: icon,
              iconColor: iconColor,
              iconBackground: iconBackground,
              title: title,
              subtitle: subtitle,
              onClose: confirmLoading ? null : onClose,
            ),
            Flexible(
              child: SingleChildScrollView(child: child),
            ),
            _MDialogFooter(
              confirmIcon: confirmIcon,
              confirmLabel: confirmLabel,
              confirmLoading: confirmLoading,
              confirmColor: confirmColor,
              onClose: confirmLoading ? null : onClose,
              onConfirm: confirmLoading ? null : onConfirm,
            ),
          ],
        ),
      ),
    );
  }
}

class _MDialogHeader extends StatelessWidget {
  const _MDialogHeader({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onClose,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 14, 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded),
                color: Colors.black38,
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE6EAF0)),
      ],
    );
  }
}

class _MDialogFooter extends StatelessWidget {
  const _MDialogFooter({
    required this.confirmIcon,
    required this.confirmLabel,
    required this.confirmLoading,
    required this.confirmColor,
    required this.onClose,
    required this.onConfirm,
  });

  final IconData confirmIcon;
  final String confirmLabel;
  final bool confirmLoading;
  final Color confirmColor;
  final VoidCallback? onClose;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
        border: Border(top: BorderSide(color: Color(0xFFE6EAF0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: MButton.outlined(
              label: 'Fechar',
              foregroundColor: MonalisaColors.danger,
              onPressed: onClose,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: MButton(
              icon: confirmIcon,
              label: confirmLabel,
              loading: confirmLoading,
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              onPressed: onConfirm,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Alinha botoes ou acoes laterais com o corpo de campos que possuem label.
///
/// Use dentro de uma [Row] quando um input com `label` ficar lado a lado com
/// botoes, icones ou outras acoes.
class MFieldAction extends StatelessWidget {
  final Widget child;
  final bool hasFieldLabel;
  final double labelOffset;
  final double? width;

  const MFieldAction({
    super.key,
    required this.child,
    this.hasFieldLabel = true,
    this.labelOffset = 25,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final content = width == null ? child : SizedBox(width: width, child: child);

    return Padding(
      padding: EdgeInsets.only(top: hasFieldLabel ? labelOffset : 0),
      child: content,
    );
  }
}

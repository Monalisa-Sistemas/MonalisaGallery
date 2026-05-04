import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../theme/monalisa_colors.dart';

typedef MDateRangeChanged = void Function(
    DateTime? startDate, DateTime? endDate);

class MFieldLabel extends StatelessWidget {
  final String? label;
  final bool required;

  const MFieldLabel({super.key, this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    if (label == null || label!.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label!,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (required)
            const Text(
              ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}

class MTextInput extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final VoidCallback? onTap;
  final bool enabled;
  final bool readOnly;
  final bool required;
  final bool obscureText;
  final bool autoFocus;
  final bool nextFocusOnSubmit;
  final int? maxLength;
  final int maxLines;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextInputType? keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final Widget? suffixIcon;

  const MTextInput({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.obscureText = false,
    this.autoFocus = false,
    this.nextFocusOnSubmit = true,
    this.maxLength = 150,
    this.maxLines = 1,
    this.backgroundColor,
    this.foregroundColor,
    this.keyboardType,
    this.inputFormatters = const [],
    this.suffixIcon,
  });

  @override
  State<MTextInput> createState() => _MTextInputState();
}

class _MTextInputState extends State<MTextInput> {
  late bool _obscureText;
  int _currentLength = 0;

  bool get _showLengthIndicator =>
      !widget.obscureText && widget.maxLines > 1 && widget.maxLength != null;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _currentLength = widget.controller?.text.length ?? 0;
    widget.controller?.addListener(_syncLength);
  }

  @override
  void didUpdateWidget(covariant MTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_syncLength);
      _currentLength = widget.controller?.text.length ?? 0;
      widget.controller?.addListener(_syncLength);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_syncLength);
    super.dispose();
  }

  void _syncLength() {
    final nextLength = widget.controller?.text.length ?? _currentLength;
    if (nextLength == _currentLength || !mounted) return;
    setState(() => _currentLength = nextLength);
  }

  @override
  Widget build(BuildContext context) {
    final fillColor = widget.enabled
        ? widget.backgroundColor
        : widget.backgroundColor ?? Colors.grey.shade100;
    final textColor = widget.enabled
        ? widget.foregroundColor ?? Colors.black87
        : Colors.grey.shade700;
    final borderColor =
        widget.enabled ? MonalisaColors.border : Colors.grey.shade300;
    final maxLength = widget.maxLength;
    final remaining = maxLength == null
        ? 0
        : (maxLength - _currentLength).clamp(0, maxLength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MFieldLabel(label: widget.label, required: widget.required),
        MouseRegion(
          cursor: widget.enabled
              ? SystemMouseCursors.text
              : SystemMouseCursors.forbidden,
          child: Stack(
            children: [
              TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                autofocus: widget.autoFocus,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                mouseCursor: widget.enabled
                    ? SystemMouseCursors.text
                    : SystemMouseCursors.forbidden,
                obscureText: _obscureText,
                maxLength: widget.maxLength,
                maxLines: widget.obscureText ? 1 : widget.maxLines,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                onTap: widget.onTap,
                onChanged: (value) {
                  if (widget.controller == null &&
                      _currentLength != value.length) {
                    setState(() => _currentLength = value.length);
                  }
                  widget.onChanged?.call(value);
                },
                onEditingComplete: () {
                  if (widget.nextFocusOnSubmit) {
                    FocusScope.of(context).nextFocus();
                  }
                  widget.onSubmitted?.call();
                },
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: widget.enabled
                        ? Colors.grey.shade500
                        : Colors.grey.shade500,
                  ),
                  fillColor: fillColor,
                  filled: true,
                  counterText: '',
                  contentPadding: _showLengthIndicator
                      ? const EdgeInsets.fromLTRB(12, 14, 12, 28)
                      : null,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  suffixIconColor: widget.enabled
                      ? Colors.grey.shade700
                      : Colors.grey.shade400,
                  suffixIcon: widget.obscureText
                      ? IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 18,
                          ),
                          onPressed: widget.enabled
                              ? () => setState(
                                    () => _obscureText = !_obscureText,
                                  )
                              : null,
                        )
                      : widget.suffixIcon,
                ),
              ),
              if (_showLengthIndicator)
                Positioned(
                  right: 8,
                  bottom: 7,
                  child: _TextLengthIndicator(
                    currentLength: _currentLength,
                    maxLength: maxLength!,
                    reachedLimit: remaining == 0,
                    enabled: widget.enabled,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TextLengthIndicator extends StatelessWidget {
  final int currentLength;
  final int maxLength;
  final bool reachedLimit;
  final bool enabled;

  const _TextLengthIndicator({
    required this.currentLength,
    required this.maxLength,
    required this.reachedLimit,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final color = reachedLimit
        ? Colors.red.shade600
        : enabled
            ? Colors.grey.shade500
            : Colors.grey.shade400;
    final label =
        reachedLimit ? '$currentLength/máx.' : '$currentLength/$maxLength';

    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: reachedLimit
              ? Colors.red.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
                height: 1,
                color: color,
                fontWeight: reachedLimit ? FontWeight.w700 : FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class MMaskedTextInput extends StatelessWidget {
  final String? label;
  final String mask;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool required;
  final String? hintText;

  const MMaskedTextInput({
    super.key,
    this.label,
    required this.mask,
    this.controller,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return MTextInput(
      label: label,
      hintText: hintText,
      controller: controller,
      onChanged: onChanged,
      enabled: enabled,
      required: required,
      keyboardType: TextInputType.number,
      inputFormatters: [
        MaskTextInputFormatter(mask: mask, filter: {'#': RegExp(r'[0-9]')}),
      ],
    );
  }
}

class MNumberInput extends StatefulWidget {
  final String? label;
  final double initialValue;
  final ValueChanged<double>? onChanged;
  final bool enabled;
  final bool autoFocus;
  final int decimalPlaces;
  final double? maxValue;
  final String? suffixText;
  final String? hintText;

  const MNumberInput({
    super.key,
    this.label,
    this.initialValue = 0,
    this.onChanged,
    this.enabled = true,
    this.autoFocus = false,
    this.decimalPlaces = 2,
    this.maxValue,
    this.suffixText,
    this.hintText,
  });

  @override
  State<MNumberInput> createState() => _MNumberInputState();
}

class _MNumberInputState extends State<MNumberInput> {
  late final TextEditingController _controller;
  double _value = 0;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = TextEditingController(text: _format(widget.initialValue));
  }

  @override
  void didUpdateWidget(covariant MNumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _value = widget.initialValue;
      _controller.text = _format(widget.initialValue);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(double value) {
    if (widget.decimalPlaces == 0) return value.toInt().toString();
    return value
        .toStringAsFixed(widget.decimalPlaces)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  void _handleChanged(String rawValue) {
    final value = double.tryParse(rawValue.replaceAll(',', '.'));
    if (value == null) return;
    if (widget.maxValue != null && value > widget.maxValue!) return;
    _value = value;
    widget.onChanged?.call(value);
  }

  void _step(int amount) {
    if (!widget.enabled || widget.decimalPlaces != 0) return;

    final nextValue =
        (_value + amount).clamp(0, widget.maxValue ?? double.infinity);
    _value = nextValue.toDouble();
    _controller.value = TextEditingValue(
      text: _format(_value),
      selection: TextSelection.collapsed(offset: _format(_value).length),
    );
    widget.onChanged?.call(_value);
  }

  @override
  Widget build(BuildContext context) {
    final regex = widget.decimalPlaces == 0
        ? RegExp(r'^\d*$')
        : RegExp('^\\d*([.,]\\d{0,${widget.decimalPlaces}})?\$');

    return MTextInput(
      label: widget.label,
      hintText: widget.hintText,
      controller: _controller,
      enabled: widget.enabled,
      autoFocus: widget.autoFocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: _handleChanged,
      inputFormatters: [
        TextInputFormatter.withFunction((oldValue, newValue) {
          return regex.hasMatch(newValue.text) ? newValue : oldValue;
        }),
      ],
      suffixIcon: _NumberInputSuffix(
        suffixText: widget.suffixText,
        showStepper: widget.decimalPlaces == 0,
        enabled: widget.enabled,
        onIncrement: () => _step(1),
        onDecrement: () => _step(-1),
      ),
    );
  }
}

class _NumberInputSuffix extends StatelessWidget {
  final String? suffixText;
  final bool showStepper;
  final bool enabled;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _NumberInputSuffix({
    required this.suffixText,
    required this.showStepper,
    required this.enabled,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    if (!showStepper && suffixText == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (suffixText != null) ...[
            Text(
              suffixText!,
              style: TextStyle(
                color:
                    enabled ? MonalisaColors.textMuted : Colors.grey.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (showStepper)
            SizedBox(
              width: 28,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _NumberStepButton(
                    icon: Icons.keyboard_arrow_up_rounded,
                    enabled: enabled,
                    onPressed: onIncrement,
                  ),
                  _NumberStepButton(
                    icon: Icons.keyboard_arrow_down_rounded,
                    enabled: enabled,
                    onPressed: onDecrement,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NumberStepButton extends StatefulWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  const _NumberStepButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  State<_NumberStepButton> createState() => _NumberStepButtonState();
}

class _NumberStepButtonState extends State<_NumberStepButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return MouseRegion(
      onEnter: (_) {
        if (widget.enabled) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (_hovered) setState(() => _hovered = false);
      },
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      child: InkWell(
        onTap: widget.enabled ? widget.onPressed : null,
        borderRadius: BorderRadius.circular(5),
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          width: 24,
          height: 18,
          decoration: BoxDecoration(
            color:
                _hovered ? primary.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          child: AnimatedScale(
            scale: _hovered ? 1.14 : 1,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: Icon(
              widget.icon,
              size: 18,
              color: widget.enabled
                  ? (_hovered ? primary : Colors.grey.shade700)
                  : Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }
}

class MCurrencyInput extends StatefulWidget {
  final String? label;
  final double initialValue;
  final ValueChanged<double>? onChanged;
  final TextEditingController? controller;
  final bool enabled;
  final bool autoFocus;
  final String locale;
  final String symbol;

  const MCurrencyInput({
    super.key,
    this.label,
    this.initialValue = 0,
    this.onChanged,
    this.controller,
    this.enabled = true,
    this.autoFocus = false,
    this.locale = 'pt_BR',
    this.symbol = 'R\$',
  });

  @override
  State<MCurrencyInput> createState() => _MCurrencyInputState();
}

class _MCurrencyInputState extends State<MCurrencyInput> {
  late final TextEditingController _controller;
  late final NumberFormat _formatter;
  int _cents = 0;

  @override
  void initState() {
    super.initState();
    _formatter = NumberFormat.currency(
      locale: widget.locale,
      symbol: widget.symbol,
    );
    _cents = (widget.initialValue * 100).round();
    _controller = widget.controller ?? TextEditingController();
    _controller.text = _formatter.format(_cents / 100);
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    _cents = int.tryParse(digits.isEmpty ? '0' : digits) ?? 0;
    final value = _cents / 100;
    final text = _formatter.format(value);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return MTextInput(
      label: widget.label,
      controller: _controller,
      enabled: widget.enabled,
      autoFocus: widget.autoFocus,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: _handleChanged,
    );
  }
}

class MDateInput extends StatefulWidget {
  final String? label;
  final DateTime? initialDate;
  final ValueChanged<DateTime?>? onChanged;
  final TextEditingController? controller;
  final bool enabled;

  const MDateInput({
    super.key,
    this.label,
    this.initialDate,
    this.onChanged,
    this.controller,
    this.enabled = true,
  });

  @override
  State<MDateInput> createState() => _MDateInputState();
}

class _MDateInputState extends State<MDateInput> {
  late final TextEditingController _controller;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialDate != null) {
      _controller.text = _dateFormat.format(widget.initialDate!);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initial = widget.initialDate ?? now;
    DateTime? selectedDate;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          content: SizedBox(
            width: 320,
            height: 400,
            child: SfDateRangePicker(
              backgroundColor: Colors.white,
              initialSelectedDate: initial,
              selectionMode: DateRangePickerSelectionMode.single,
              showActionButtons: true,
              showNavigationArrow: true,
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is DateTime) {
                  selectedDate = args.value;
                }
              },
              onCancel: () => Navigator.of(context).pop(),
              onSubmit: (_) => Navigator.of(context).pop(),
              headerHeight: 80,
              headerStyle: const DateRangePickerHeaderStyle(
                backgroundColor: Colors.white,
                textStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              monthViewSettings: DateRangePickerMonthViewSettings(
                showTrailingAndLeadingDates: true,
                dayFormat: 'EEE',
                viewHeaderStyle: DateRangePickerViewHeaderStyle(
                  textStyle: TextStyle(
                    color: Colors.blueGrey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              monthCellStyle: DateRangePickerMonthCellStyle(
                textStyle: const TextStyle(color: Colors.black87),
                todayTextStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                todayCellDecoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor),
                  shape: BoxShape.circle,
                ),
                disabledDatesTextStyle: TextStyle(color: Colors.grey[400]),
              ),
              selectionColor: Theme.of(context).primaryColor,
              todayHighlightColor: Theme.of(context).primaryColor,
              selectionTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              navigationDirection: DateRangePickerNavigationDirection.vertical,
            ),
          ),
        );
      },
    );

    if (selectedDate == null) return;
    setState(() {
      _controller.text = _dateFormat.format(selectedDate!);
    });
    widget.onChanged?.call(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return MTextInput(
      label: widget.label,
      hintText: 'dd/mm/aaaa',
      controller: _controller,
      enabled: widget.enabled,
      keyboardType: TextInputType.datetime,
      inputFormatters: [
        MaskTextInputFormatter(
          mask: '##/##/####',
          filter: {'#': RegExp(r'[0-9]')},
        ),
      ],
      onChanged: (value) {
        try {
          widget.onChanged?.call(_dateFormat.parseStrict(value));
        } catch (_) {
          widget.onChanged?.call(null);
        }
      },
      onSubmitted: _selectDate,
      suffixIcon: IconButton(
        icon: const Icon(Icons.calendar_today, size: 18),
        onPressed: widget.enabled ? _selectDate : null,
      ),
    );
  }
}

class MDateRangeInput extends StatefulWidget {
  final String? label;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final MDateRangeChanged? onChanged;
  final bool enabled;

  const MDateRangeInput({
    super.key,
    this.label,
    this.initialStartDate,
    this.initialEndDate,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<MDateRangeInput> createState() => _MDateRangeInputState();
}

class _MDateRangeInputState extends State<MDateRangeInput> {
  final _controller = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _setText(widget.initialStartDate, widget.initialEndDate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setText(DateTime? start, DateTime? end) {
    if (start == null) {
      _controller.clear();
      return;
    }
    final rangeEnd = end ?? start;
    _controller.text =
        '${_dateFormat.format(start)} - ${_dateFormat.format(rangeEnd)}';
  }

  Future<void> _selectRange() async {
    PickerDateRange? range;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          content: SizedBox(
            width: 320,
            height: 400,
            child: SfDateRangePicker(
              backgroundColor: Colors.white,
              selectionMode: DateRangePickerSelectionMode.range,
              initialSelectedRange: PickerDateRange(
                widget.initialStartDate,
                widget.initialEndDate,
              ),
              showActionButtons: true,
              onSelectionChanged: (args) {
                if (args.value is PickerDateRange) range = args.value;
              },
              onCancel: () => Navigator.of(context).pop(),
              onSubmit: (_) => Navigator.of(context).pop(),
              headerHeight: 80,
              headerStyle: const DateRangePickerHeaderStyle(
                backgroundColor: Colors.white,
                textStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              monthViewSettings: DateRangePickerMonthViewSettings(
                showTrailingAndLeadingDates: true,
                dayFormat: 'EEE',
                viewHeaderStyle: DateRangePickerViewHeaderStyle(
                  textStyle: TextStyle(
                    color: Colors.blueGrey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              monthCellStyle: DateRangePickerMonthCellStyle(
                textStyle: const TextStyle(color: Colors.black87),
                todayTextStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                todayCellDecoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor),
                  shape: BoxShape.circle,
                ),
                disabledDatesTextStyle: TextStyle(color: Colors.grey[400]),
              ),
              selectionColor: Theme.of(context).primaryColor,
              startRangeSelectionColor: Theme.of(context).primaryColor,
              endRangeSelectionColor: Theme.of(context).primaryColor,
              rangeSelectionColor:
                  Theme.of(context).primaryColor.withValues(alpha: 0.16),
              todayHighlightColor: Theme.of(context).primaryColor,
              selectionTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              rangeTextStyle: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              navigationDirection: DateRangePickerNavigationDirection.vertical,
            ),
          ),
        );
      },
    );

    if (range == null) return;
    final start = range!.startDate;
    final end = range!.endDate ?? start;
    _setText(start, end);
    widget.onChanged?.call(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return MTextInput(
      label: widget.label,
      controller: _controller,
      enabled: widget.enabled,
      readOnly: true,
      onTap: widget.enabled ? _selectRange : null,
      onSubmitted: _selectRange,
      suffixIcon: IconButton(
        icon: const Icon(Icons.calendar_today, size: 18),
        onPressed: widget.enabled ? _selectRange : null,
      ),
    );
  }
}

class MDropdown<T> extends StatefulWidget {
  final String? label;
  final List<T> items;
  final T? value;
  final ValueChanged<T> onChanged;
  final String Function(T) itemLabel;
  final bool enabled;
  final String? hintText;
  final double maxHeight;
  final IconData? Function(T item)? itemIcon;

  const MDropdown({
    super.key,
    this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.itemLabel,
    this.enabled = true,
    this.hintText,
    this.maxHeight = 240,
    this.itemIcon,
  });

  @override
  State<MDropdown<T>> createState() => _MDropdownState<T>();
}

class _MDropdownState<T> extends State<MDropdown<T>>
    with SingleTickerProviderStateMixin {
  final LayerLink _link = LayerLink();
  final GlobalKey _key = GlobalKey();
  final FocusNode _focusNode = FocusNode();

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  OverlayEntry? _overlayEntry;
  bool _openUpwards = false;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      reverseDuration: const Duration(milliseconds: 90),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _scaleAnimation = Tween<double>(begin: 0.97, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _removeOverlay(immediate: true);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!widget.enabled) return;
    if (_overlayEntry == null) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _showOverlay() {
    final context = _key.currentContext;
    if (context == null) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(this.context).size.height;
    final spaceBelow = screenHeight - (position.dy + size.height);
    const itemHeight = 44.0;
    final realHeight = (widget.items.length * itemHeight).clamp(
      itemHeight,
      widget.maxHeight,
    );

    _openUpwards = spaceBelow < realHeight + 12;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _hideOverlay,
          child: Stack(
            children: [
              CompositedTransformFollower(
                link: _link,
                showWhenUnlinked: false,
                offset: _openUpwards
                    ? Offset(0, -realHeight - 18)
                    : Offset(0, size.height + 6),
                child: Focus(
                  focusNode: _focusNode,
                  autofocus: true,
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.escape) {
                      _hideOverlay();
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      alignment: _openUpwards
                          ? Alignment.bottomCenter
                          : Alignment.topCenter,
                      child: _DropdownPanel<T>(
                        width: size.width,
                        maxHeight: widget.maxHeight,
                        items: widget.items,
                        value: widget.value,
                        itemLabel: widget.itemLabel,
                        itemIcon: widget.itemIcon,
                        onSelected: (item) {
                          widget.onChanged(item);
                          _hideOverlay();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(this.context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _controller.forward(from: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  Future<void> _hideOverlay() async {
    await _removeOverlay();
  }

  Future<void> _removeOverlay({bool immediate = false}) async {
    if (_overlayEntry == null) return;
    if (!immediate && _controller.isAnimating == false) {
      await _controller.reverse();
    }
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted && _isOpen) {
      setState(() => _isOpen = false);
    } else {
      _isOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedLabel = widget.value == null
        ? widget.hintText ?? ''
        : widget.itemLabel(widget.value as T);
    final selectedIcon = widget.value == null || widget.itemIcon == null
        ? null
        : widget.itemIcon!(widget.value as T);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MFieldLabel(label: widget.label),
        CompositedTransformTarget(
          link: _link,
          child: Material(
            key: _key,
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.enabled ? _toggle : null,
              borderRadius: BorderRadius.circular(8),
              splashColor: Colors.transparent,
              hoverColor: widget.enabled
                  ? Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.05)
                  : Colors.transparent,
              mouseCursor: widget.enabled
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.forbidden,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: widget.enabled ? Colors.white : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _overlayEntry == null
                        ? MonalisaColors.border
                        : Theme.of(context).colorScheme.primary,
                    width: _overlayEntry == null ? 1 : 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    if (selectedIcon != null) ...[
                      Icon(
                        selectedIcon,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        selectedLabel,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              color: widget.value == null
                                  ? Colors.grey.shade500
                                  : MonalisaColors.text,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 130),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 24,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownPanel<T> extends StatelessWidget {
  final double width;
  final double maxHeight;
  final List<T> items;
  final T? value;
  final String Function(T) itemLabel;
  final IconData? Function(T item)? itemIcon;
  final ValueChanged<T> onSelected;

  const _DropdownPanel({
    required this.width,
    required this.maxHeight,
    required this.items,
    required this.value,
    required this.itemLabel,
    required this.itemIcon,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 6),
            shrinkWrap: true,
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 2),
            itemBuilder: (context, index) {
              final item = items[index];
              final selected = item == value;
              final icon = itemIcon?.call(item);

              return _DropdownItem<T>(
                item: item,
                selected: selected,
                icon: icon,
                label: itemLabel(item),
                onSelected: onSelected,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DropdownItem<T> extends StatefulWidget {
  final T item;
  final bool selected;
  final IconData? icon;
  final String label;
  final ValueChanged<T> onSelected;

  const _DropdownItem({
    required this.item,
    required this.selected,
    required this.icon,
    required this.label,
    required this.onSelected,
  });

  @override
  State<_DropdownItem<T>> createState() => _DropdownItemState<T>();
}

class _DropdownItemState<T> extends State<_DropdownItem<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final backgroundColor = widget.selected
        ? primary.withValues(alpha: 0.08)
        : _hovered
            ? primary.withValues(alpha: 0.045)
            : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          onTap: () => widget.onSelected(widget.item),
          borderRadius: BorderRadius.circular(6),
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            constraints: const BoxConstraints(minHeight: 42),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 18,
                    color: widget.selected ? primary : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color:
                              widget.selected ? primary : MonalisaColors.text,
                          fontWeight: widget.selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                  ),
                ),
                if (widget.selected)
                  Icon(Icons.check_rounded, size: 18, color: primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MSearchInput extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final bool autoFocus;

  const MSearchInput({
    super.key,
    this.hintText = 'Buscar...',
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return MTextInput(
      hintText: hintText,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autoFocus: autoFocus,
      suffixIcon: IconButton(
        icon: const Icon(Icons.search),
        onPressed: onSubmitted,
      ),
    );
  }
}

class MFileInput extends StatefulWidget {
  final String? label;
  final TextEditingController? controller;
  final ValueChanged<String?>? onChanged;
  final List<String> allowedExtensions;
  final bool enabled;
  final bool required;
  final String placeholder;

  const MFileInput({
    super.key,
    this.label,
    this.controller,
    this.onChanged,
    this.allowedExtensions = const [],
    this.enabled = true,
    this.required = false,
    this.placeholder = 'Selecione um arquivo...',
  });

  @override
  State<MFileInput> createState() => _MFileInputState();
}

class _MFileInputState extends State<MFileInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    if (!widget.enabled) return;
    final result = await FilePicker.platform.pickFiles(
      type: widget.allowedExtensions.isEmpty ? FileType.any : FileType.custom,
      allowedExtensions:
          widget.allowedExtensions.isEmpty ? null : widget.allowedExtensions,
    );
    final path = result?.files.single.path;
    if (path == null) return;
    setState(() => _controller.text = path);
    widget.onChanged?.call(path);
  }

  @override
  Widget build(BuildContext context) {
    return MTextInput(
      label: widget.label,
      controller: _controller,
      enabled: widget.enabled,
      readOnly: true,
      required: widget.required,
      hintText: widget.placeholder,
      onTap: widget.enabled ? _pickFile : null,
      onSubmitted: _pickFile,
      suffixIcon: IconButton(
        icon: const Icon(Icons.folder_open_rounded),
        onPressed: widget.enabled ? _pickFile : null,
      ),
    );
  }
}

class MPhotoPicker extends StatefulWidget {
  final ValueChanged<XFile?>? onChanged;
  final bool enabled;
  final double size;
  final IconData placeholderIcon;
  final Color? borderColor;
  final Color? placeholderBackgroundColor;
  final bool openOnTap;
  final bool showRemoveButton;
  final Uint8List? initialPreviewBytes;

  const MPhotoPicker({
    super.key,
    this.onChanged,
    this.enabled = true,
    this.size = 88,
    this.placeholderIcon = Icons.person,
    this.borderColor,
    this.placeholderBackgroundColor,
    this.openOnTap = true,
    this.showRemoveButton = true,
    this.initialPreviewBytes,
  });

  @override
  State<MPhotoPicker> createState() => MPhotoPickerState();
}

class MPhotoPickerState extends State<MPhotoPicker> {
  Uint8List? _previewBytes;
  bool _loading = false;

  bool get hasPhoto => _previewBytes != null;

  bool get _supportsCamera {
    if (kIsWeb) return true;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      TargetPlatform.windows ||
      TargetPlatform.linux ||
      TargetPlatform.macOS ||
      TargetPlatform.fuchsia =>
        false,
    };
  }

  bool get _usesFilePickerForGallery {
    if (kIsWeb) return true;

    return switch (defaultTargetPlatform) {
      TargetPlatform.windows ||
      TargetPlatform.linux ||
      TargetPlatform.macOS =>
        true,
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.fuchsia =>
        false,
    };
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPreviewBytes;
    if (initial != null && initial.isNotEmpty) {
      _previewBytes = Uint8List.fromList(initial);
    }
  }

  Future<void> openPicker() async {
    if (!widget.enabled || _loading) return;

    if (_usesFilePickerForGallery) {
      await _pickFileImage();
      return;
    }

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Galeria'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                if (_supportsCamera)
                  ListTile(
                    leading: const Icon(Icons.photo_camera_outlined),
                    title: const Text('Camera'),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (source != null && mounted) {
      await _pick(source, afterSheet: true);
    }
  }

  void clearPhoto() {
    if (!widget.enabled) return;
    setState(() => _previewBytes = null);
    widget.onChanged?.call(null);
  }

  Future<void> _pick(ImageSource source, {required bool afterSheet}) async {
    if (!widget.enabled || _loading) return;
    setState(() => _loading = true);

    Future<void> runPick() async {
      if (afterSheet) {
        await Future<void>.delayed(const Duration(milliseconds: 280));
        if (!mounted) return;
      }

      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 88,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        if (!mounted) return;
        setState(() => _previewBytes = bytes);
        widget.onChanged?.call(file);
      }
    }

    try {
      await runPick();
    } on PlatformException catch (error) {
      _showPickerError(
          error.message?.isNotEmpty == true ? error.message! : error.code);
    } catch (error) {
      _showPickerError(error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickFileImage() async {
    if (!widget.enabled || _loading) return;
    setState(() => _loading = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        withData: kIsWeb,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'],
      );

      final file = result?.files.single;
      if (file == null) return;

      final bytes = kIsWeb
          ? file.bytes
          : file.bytes ??
              (file.path == null
                  ? null
                  : await XFile(file.path!, name: file.name).readAsBytes());
      if (bytes == null || !mounted) return;

      setState(() => _previewBytes = bytes);
      widget.onChanged?.call(
        kIsWeb || file.path == null
            ? XFile.fromData(bytes, name: file.name)
            : XFile(file.path!, name: file.name),
      );
    } on PlatformException catch (error) {
      _showPickerError(
        error.message?.isNotEmpty == true ? error.message! : error.code,
      );
    } catch (error) {
      _showPickerError(error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showPickerError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final borderColor = widget.borderColor ??
        (widget.enabled
            ? primary.withValues(alpha: 0.34)
            : Colors.grey.shade300);
    final backgroundColor = widget.placeholderBackgroundColor ??
        (widget.enabled
            ? primary.withValues(alpha: 0.06)
            : Colors.grey.shade100);
    final canTap = widget.openOnTap && widget.enabled && !_loading;

    return SizedBox.square(
      dimension: widget.size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canTap ? openPicker : null,
                borderRadius: BorderRadius.circular(14),
                mouseCursor: widget.enabled
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.forbidden,
                child: Ink(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: _previewBytes == null
                        ? Icon(
                            widget.placeholderIcon,
                            color:
                                widget.enabled ? primary : Colors.grey.shade500,
                            size: widget.size * 0.34,
                          )
                        : Image.memory(
                            _previewBytes!,
                            fit: BoxFit.cover,
                            width: widget.size,
                            height: widget.size,
                            gaplessPlayback: true,
                          ),
                  ),
                ),
              ),
            ),
          ),
          if (_loading)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          if (widget.showRemoveButton &&
              widget.enabled &&
              _previewBytes != null)
            Positioned(
              top: -7,
              right: -7,
              child: _PhotoRemoveButton(onPressed: clearPhoto),
            ),
        ],
      ),
    );
  }
}

class _PhotoRemoveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PhotoRemoveButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const SizedBox.square(
          dimension: 22,
          child: Icon(Icons.close_rounded, size: 15),
        ),
      ),
    );
  }
}

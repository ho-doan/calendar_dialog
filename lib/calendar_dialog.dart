library calendar_dialog;

import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

extension DateUtil on DateTime {
  String get mm {
    return DateFormat('MM').format(this);
  }
}

typedef CalendarCallback = void Function(DateTime);
typedef WidgetBuilder = Widget Function(String);

class CalendarWidgetStyle {
  final Widget title;
  final Widget close;
  final Widget incrementYear;
  final Widget decrementYear;
  final Widget incrementMonth;
  final Widget decrementMonth;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final double elevation;

  const CalendarWidgetStyle({
    this.elevation = 0,
    this.padding = const EdgeInsets.symmetric(vertical: 4),
    this.backgroundColor = Colors.white,
    this.incrementMonth = const Icon(
      Icons.arrow_right_rounded,
      size: 40,
    ),
    this.incrementYear = const Icon(
      Icons.arrow_right_rounded,
      size: 40,
    ),
    this.decrementMonth = const Icon(
      Icons.arrow_left_rounded,
      size: 40,
    ),
    this.decrementYear = const Icon(
      Icons.arrow_left_rounded,
      size: 40,
    ),
    this.title = const Text(
      'Calendar',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
    this.close = const Icon(
      Icons.close,
      color: Colors.white,
      size: 20,
    ),
  });

  CalendarWidgetStyle copyWith({
    Widget? title,
    Widget? close,
    Widget? incrementYear,
    Widget? decrementYear,
    Widget? incrementMonth,
    Widget? decrementMonth,
  }) =>
      CalendarWidgetStyle(
        title: title ?? this.title,
        close: close ?? this.close,
        incrementYear: incrementYear ?? this.incrementYear,
        decrementYear: decrementYear ?? this.decrementYear,
        incrementMonth: incrementMonth ?? this.incrementMonth,
        decrementMonth: decrementMonth ?? this.decrementMonth,
      );
}

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({
    super.key,
    this.calendarStyle = const CalendarWidgetStyle(),
    this.yearWidget,
    this.monthWidget,
    this.itemStyle,
    this.callback,
    this.weekdayStyle,
    this.child,
  });
  final CalendarWidgetStyle calendarStyle;
  final WidgetBuilder? yearWidget;
  final WidgetBuilder? monthWidget;
  final CalendarItemStyle? itemStyle;
  final CalendarCallback? callback;
  final WeekdayStyle? weekdayStyle;
  final Widget? child;

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime now;
  @override
  void initState() {
    super.initState();
    now = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.calendarStyle.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Title(state: widget.calendarStyle),
              const SizedBox(height: 24),
              Card(
                clipBehavior: Clip.hardEdge,
                elevation: widget.calendarStyle.elevation,
                child: Container(
                  color: Colors.white,
                  padding: widget.calendarStyle.padding,
                  child: FormField<DateTime>(
                    initialValue: now,
                    builder: (fieldMY) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _YearWidget(
                          state: widget.calendarStyle,
                          widget: widget,
                          decrement: () => fieldMY.didChange(
                            DateTime(
                              (fieldMY.value?.year ?? now.year) - 1,
                              (fieldMY.value?.month ?? now.month),
                            ),
                          ),
                          increment: () => fieldMY.didChange(
                            DateTime(
                              (fieldMY.value?.year ?? now.year) + 1,
                              (fieldMY.value?.month ?? now.month),
                            ),
                          ),
                          year: widget.yearWidget?.call(
                                (fieldMY.value?.year ?? now.year).toString(),
                              ) ??
                              Text(
                                (fieldMY.value?.year ?? now.year).toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                        ),
                        _MonthWidget(
                          state: widget.calendarStyle,
                          decrement: () => fieldMY.didChange(
                            DateTime(
                              (fieldMY.value?.year ?? now.year),
                              (fieldMY.value?.month ?? now.month) - 1,
                            ),
                          ),
                          increment: () => fieldMY.didChange(
                            DateTime(
                              (fieldMY.value?.year ?? now.year),
                              (fieldMY.value?.month ?? now.month) + 1,
                            ),
                          ),
                          month: widget.monthWidget?.call(
                                (fieldMY.value ?? now).mm.toString(),
                              ) ??
                              Text(
                                (fieldMY.value ?? now).mm.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                        ),
                        FormField<DateTime>(
                          initialValue: now,
                          builder: (field) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              WeekDaysTitle(
                                style: widget.weekdayStyle,
                              ),
                              CalendarCore(
                                itemStyle: widget.itemStyle,
                                dateTime: DateTime(
                                  fieldMY.value?.year ?? now.year,
                                  fieldMY.value?.month ?? now.month,
                                ),
                                selected: field.value,
                                callback: (p0) {
                                  field.didChange(p0);
                                  widget.callback?.call(p0);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.child != null) widget.child!,
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthWidget extends StatelessWidget {
  const _MonthWidget({
    required this.state,
    required this.increment,
    required this.decrement,
    required this.month,
  });

  final CalendarWidgetStyle state;
  final VoidCallback increment;
  final VoidCallback decrement;
  final Widget month;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: decrement,
          child: state.decrementMonth,
        ),
        Expanded(child: Center(child: month)),
        GestureDetector(
          onTap: increment,
          child: state.incrementMonth,
        ),
      ],
    );
  }
}

class _YearWidget extends StatelessWidget {
  const _YearWidget({
    required this.state,
    required this.widget,
    required this.increment,
    required this.decrement,
    required this.year,
  });

  final CalendarWidgetStyle state;
  final CalendarWidget widget;
  final VoidCallback increment;
  final VoidCallback decrement;
  final Widget year;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: decrement,
          child: state.decrementYear,
        ),
        Expanded(
          child: Center(
            child: year,
          ),
        ),
        GestureDetector(
          onTap: increment,
          child: state.incrementYear,
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.state,
  });

  final CalendarWidgetStyle state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: state.title,
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[850],
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: state.close,
            ),
          ),
        ),
      ],
    );
  }
}

class CalendarCore extends StatelessWidget {
  CalendarCore({
    super.key,
    required this.dateTime,
    this.callback,
    this.selected,
    this.itemStyle,
  }) {
    final countDays = DateTime(
      dateTime.year,
      dateTime.month + 1,
      0,
    ).day;
    final firstDay = DateTime(dateTime.year, dateTime.month, 1);
    final lst = <DateTime?>[];
    for (int i = 1; i < firstDay.weekday; i++) {
      lst.add(null);
    }
    for (int i = 1; i <= countDays; i++) {
      lst.add(DateTime(
        dateTime.year,
        dateTime.month,
        i,
      ));
    }
    final check = lst.length % 7 == 0;
    if (!check) {
      final length = lst.length ~/ 7;
      final countInsert = ((length + 1) * 7) - lst.length;
      for (int i = 0; i < countInsert; i++) {
        lst.add(null);
      }
    }

    _children = lst.slices(7).toList();
  }

  late final List<List<DateTime?>> _children;
  final DateTime dateTime;
  final DateTime? selected;
  final CalendarCallback? callback;
  final CalendarItemStyle? itemStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final child in _children)
          Row(
            children: [
              for (final item in child)
                CalendarItem(
                  style: itemStyle,
                  date: item,
                  selected: item?.year == selected?.year &&
                      item?.month == selected?.month &&
                      item?.day == selected?.day,
                  callback: callback,
                )
            ],
          ),
      ],
    );
  }
}

class WeekdayStyle {
  final TextStyle style;
  final List<String> lsWeekDays;

  const WeekdayStyle({
    this.style = const TextStyle(fontSize: 12, color: Colors.grey),
    this.lsWeekDays = const <String>['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'],
  });
  WeekdayStyle copyWith({
    TextStyle? style,
    List<String>? lsWeekDays,
  }) =>
      WeekdayStyle(
        lsWeekDays: lsWeekDays ?? this.lsWeekDays,
        style: style ?? this.style,
      );
}

class WeekDaysTitle extends StatelessWidget {
  const WeekDaysTitle({
    super.key,
    WeekdayStyle? style,
  }) : state = style ?? const WeekdayStyle();

  final WeekdayStyle state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final s in state.lsWeekDays)
          Expanded(
            child: Text(
              s,
              textAlign: TextAlign.center,
              style: state.style,
            ),
          ),
      ],
    );
  }
}

class CalendarItemStyle {
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Decoration decoration;
  final Decoration decorationSelected;
  final TextStyle style;

  const CalendarItemStyle({
    this.padding = const EdgeInsets.all(8),
    this.margin = const EdgeInsets.symmetric(
      horizontal: 1,
      vertical: 5,
    ),
    this.decoration = const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
    this.decorationSelected = const BoxDecoration(
      color: Color(0xFF137979),
      shape: BoxShape.circle,
    ),
    this.style = const TextStyle(color: Colors.black),
  });

  CalendarItemStyle copyWith({
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Decoration? decoration,
    Decoration? decorationSelected,
    TextStyle? style,
  }) =>
      CalendarItemStyle(
        padding: padding ?? this.padding,
        margin: margin ?? this.margin,
        decoration: decoration ?? this.decoration,
        decorationSelected: decorationSelected ?? this.decorationSelected,
        style: style ?? this.style,
      );
}

class CalendarItem extends StatelessWidget {
  const CalendarItem({
    super.key,
    CalendarItemStyle? style,
    this.selected = false,
    this.date,
    this.callback,
  }) : state = style ?? const CalendarItemStyle();

  final CalendarItemStyle state;
  final bool selected;
  final DateTime? date;
  final CalendarCallback? callback;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => callback?.call(date ?? DateTime.now()),
        behavior: HitTestBehavior.translucent,
        child: Container(
          width: double.infinity,
          padding: state.padding,
          margin: state.margin,
          decoration: selected ? state.decorationSelected : state.decoration,
          child: Text(
            date?.day.toString() ?? '',
            textAlign: TextAlign.center,
            style: selected
                ? state.style.copyWith(color: Colors.white)
                : state.style,
          ),
        ),
      ),
    );
  }
}

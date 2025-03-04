// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../components/_internal_components.dart';
import '../components/event_scroll_notifier.dart';
import '../enumerations.dart';
import '../event_arrangers/event_arrangers.dart';
import '../event_controller.dart';
import '../modals.dart';
import '../painters.dart';
import '../typedefs.dart';

/// A single page for week view.
class InternalWeekViewPage<T extends Object?> extends StatelessWidget {
  /// Width of the page.
  final double width;

  /// Height of the page.
  final double height;

  /// Dates to display on page.
  final List<DateTime> dates;

  /// Builds tile for a single event.
  final EventTileBuilder<T> eventTileBuilder;

  /// A calendar controller that controls all the events and rebuilds widget
  /// if event(s) are added or removed.
  final EventController<T> controller;

  /// A builder to build time line.
  final DateWidgetBuilder timeLineBuilder;

  /// Settings for hour indicator lines.
  final HourIndicatorSettings hourIndicatorSettings;

  /// Flag to display live line.
  final bool showLiveLine;

  /// Settings for live time indicator.
  final HourIndicatorSettings liveTimeIndicatorSettings;

  ///  Height occupied by one minute time span.
  final double heightPerMinute;

  /// Width of timeline.
  final double timeLineWidth;

  /// Offset of timeline.
  final double timeLineOffset;

  /// Height occupied by one hour time span.
  final double hourHeight;

  /// Arranger to arrange events.
  final EventArranger<T> eventArranger;

  /// Flag to display vertical line or not.
  final bool showVerticalLine;

  /// Offset for vertical line offset.
  final double verticalLineOffset;

  /// Builder for week day title.
  final DateWidgetBuilder weekDayBuilder;

  /// Builder for week number.
  final WeekNumberBuilder weekNumberBuilder;

  /// Height of week title.
  final double weekTitleHeight;

  /// Width of week title.
  final double weekTitleWidth;

  final ScrollController scrollController;

  /// Called when user taps on event tile.
  final CellTapCallback<T>? onTileTap;

  /// Defines which days should be displayed in one week.
  ///
  /// By default all the days will be visible.
  /// Sequence will be monday to sunday.
  final List<WeekDays> weekDays;

  /// Called when user long press on calendar.
  final DatePressCallback? onDateLongPress;

  /// Called when user taps on day view page.
  ///
  /// This callback will have a date parameter which
  /// will provide the time span on which user has tapped.
  ///
  /// Ex, User Taps on Date page with date 11/01/2022 and time span is 1PM to 2PM.
  /// then DateTime object will be  DateTime(2022,01,11,1,0)
  final DateTapCallback? onDateTap;

  /// Defines size of the slots that provides long press callback on area
  /// where events are not there.
  final MinuteSlotSize minuteSlotSize;

  final EventScrollConfiguration scrollConfiguration;

  /// Display full day events.
  final FullDayEventBuilder<T>? fullDayEventBuilder;

  final AdvancedCustomizationSettings? advancedCustomizationSettings;

  /// A single page for week view.
  const InternalWeekViewPage({
    Key? key,
    required this.showVerticalLine,
    required this.weekTitleHeight,
    required this.weekDayBuilder,
    required this.weekNumberBuilder,
    required this.width,
    required this.dates,
    required this.eventTileBuilder,
    required this.controller,
    required this.timeLineBuilder,
    required this.hourIndicatorSettings,
    required this.showLiveLine,
    required this.liveTimeIndicatorSettings,
    required this.heightPerMinute,
    required this.timeLineWidth,
    required this.timeLineOffset,
    required this.height,
    required this.hourHeight,
    required this.eventArranger,
    required this.verticalLineOffset,
    required this.weekTitleWidth,
    required this.scrollController,
    required this.onTileTap,
    required this.onDateLongPress,
    required this.onDateTap,
    required this.weekDays,
    required this.minuteSlotSize,
    required this.scrollConfiguration,
    this.fullDayEventBuilder,
    this.advancedCustomizationSettings
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredDates = _filteredDate();

    return Container(
      height: height + weekTitleHeight,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: weekTitleHeight,
                  width: timeLineWidth + hourIndicatorSettings.offset,
                  child: weekNumberBuilder.call(filteredDates[0]),
                ),
                ...List.generate(
                  filteredDates.length,
                  (index) => SizedBox(
                    height: weekTitleHeight,
                    width: weekTitleWidth,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: advancedCustomizationSettings?.columsDistance ?? 0
                      ),
                      child: weekDayBuilder(
                        filteredDates[index],
                      ),
                    )
                  ),
                )
              ],
            ),
          ),
          Divider(
            thickness: 1,
            height: 1,
          ),
          SizedBox(
            width: width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: timeLineWidth + hourIndicatorSettings.offset),
                ...List.generate(
                  filteredDates.length,
                  (index) => SizedBox(
                    width: weekTitleWidth,
                    child: fullDayEventBuilder?.call(
                      controller.getFullDayEvent(filteredDates[index]),
                      dates[index],
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: SizedBox(
                height: height,
                width: width,
                child: Stack(
                  children: [
                    if(advancedCustomizationSettings?.columnsBackgroundColor == null)
                      CustomPaint(
                        size: Size(width, height),
                        painter: HourLinePainter(
                          lineColor: hourIndicatorSettings.color,
                          lineHeight: hourIndicatorSettings.height,
                          offset: timeLineWidth + hourIndicatorSettings.offset,
                          minuteHeight: heightPerMinute,
                          verticalLineOffset: verticalLineOffset,
                          showVerticalLine: showVerticalLine,
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: weekTitleWidth * filteredDates.length,
                        height: height,
                        child: Row(
                          children: [
                            ...List.generate(
                              filteredDates.length,
                              (index) => Padding(
                                padding: EdgeInsets.only(left: advancedCustomizationSettings?.columsDistance ?? 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: advancedCustomizationSettings?.columnsBackgroundColor,
                                    borderRadius: advancedCustomizationSettings?.columnsBorderRadius,
                                    border: (advancedCustomizationSettings?.columnsBorderRadius == null) 
                                      ? Border(
                                        right: BorderSide(
                                          color: hourIndicatorSettings.color,
                                          width: hourIndicatorSettings.height,
                                        ),
                                      )
                                      : null
                                  ),
                                  height: height,
                                  width: weekTitleWidth - (advancedCustomizationSettings?.columsDistance ?? 0),
                                  child: Stack(
                                    children: [
                                      if(advancedCustomizationSettings?.columnsBackgroundColor != null)
                                        CustomPaint(
                                          size: Size(weekTitleWidth, height),
                                          painter: HourLinePainter(
                                            lineColor: hourIndicatorSettings.color,
                                            lineHeight: hourIndicatorSettings.height,
                                            offset: 0,
                                            minuteHeight: heightPerMinute,
                                            verticalLineOffset: 0,
                                            showVerticalLine: false,
                                          ),
                                        ),
                                      PressDetector(
                                        width: weekTitleWidth - (advancedCustomizationSettings?.columsDistance ?? 0),
                                        height: height,
                                        heightPerMinute: heightPerMinute,
                                        date: dates[index],
                                        onDateTap: onDateTap,
                                        onDateLongPress: onDateLongPress,
                                        minuteSlotSize: minuteSlotSize,
                                      ),
                                      EventGenerator<T>(
                                        height: height,
                                        date: filteredDates[index],
                                        onTileTap: onTileTap,
                                        width: weekTitleWidth - (advancedCustomizationSettings?.columsDistance ?? 0),
                                        eventArranger: eventArranger,
                                        eventTileBuilder: eventTileBuilder,
                                        scrollNotifier: scrollConfiguration,
                                        events: controller.getEventsOnDay(filteredDates[index]),
                                        heightPerMinute: heightPerMinute,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    if (showLiveLine && liveTimeIndicatorSettings.height > 0)
                      IgnorePointer(
                        child: LiveTimeIndicator(
                          liveTimeIndicatorSettings: liveTimeIndicatorSettings,
                          width: width,
                          height: height,
                          heightPerMinute: heightPerMinute,
                          timeLineWidth: timeLineWidth,
                        ),
                      ),
                    TimeLine(
                      timeLineWidth: timeLineWidth,
                      hourHeight: hourHeight,
                      height: height,
                      timeLineOffset: timeLineOffset,
                      timeLineBuilder: timeLineBuilder,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DateTime> _filteredDate() {
    final output = <DateTime>[];

    final weekDays = this.weekDays.toList();

    for (final date in dates) {
      if (weekDays.any((weekDay) => weekDay.index + 1 == date.weekday)) {
        output.add(date);
      }
    }

    return output;
  }
}

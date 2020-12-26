import 'package:cabin_booking/model/item.dart';
import 'package:cabin_booking/utils/date.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Booking extends Item {
  String description;
  DateTime date;
  TimeOfDay timeStart;
  TimeOfDay timeEnd;
  bool isDisabled;
  String cabinId;

  String recurringBookingId;
  int recurringNumber;
  int recurringTotalTimes;

  Booking({
    String id,
    this.description,
    this.date,
    this.timeStart,
    this.timeEnd,
    this.isDisabled = false,
    this.cabinId,
    this.recurringBookingId,
    this.recurringNumber,
    this.recurringTotalTimes,
  }) : super(id: id);

  Booking.from(Map<String, dynamic> other)
      : description = other['description'],
        date = DateTime.tryParse(other['date']),
        timeStart = tryParseTimeOfDay(other['timeStart']),
        timeEnd = tryParseTimeOfDay(other['timeEnd']),
        isDisabled = other['isDisabled'],
        super.from(other);

  @override
  Map<String, dynamic> toMap() => {
        ...super.toMap(),
        'description': description,
        'date': date.toIso8601String().split('T')[0],
        'timeStart': formatTimeOfDay(timeStart),
        'timeEnd': formatTimeOfDay(timeEnd),
        'isDisabled': isDisabled,
      };

  DateTime get dateStart => tryParseDateTimeWithTimeOfDay(
        dateTime: date,
        timeOfDay: timeStart,
      );

  DateTime get dateEnd => tryParseDateTimeWithTimeOfDay(
        dateTime: date,
        timeOfDay: timeEnd,
      );

  Duration get duration => dateEnd.difference(dateStart);

  String get timeRange =>
      '${formatTimeOfDay(timeStart)}–${formatTimeOfDay(timeEnd)}';

  String get dateRange => '${DateFormat.yMd().format(date)} $timeRange';

  bool isOn(DateTime dateTime) => isSameDay(date, dateTime);

  bool collidesWith(Booking booking) =>
      dateStart.isBefore(booking.dateEnd) && dateEnd.isAfter(booking.dateStart);

  Booking movedTo(DateTime dateTime) => Booking(
        id: id,
        description: description,
        date: dateTime,
        timeStart: TimeOfDay.fromDateTime(dateStart),
        timeEnd: TimeOfDay.fromDateTime(dateEnd),
        isDisabled: isDisabled,
        cabinId: cabinId,
      );

  Map<TimeOfDay, Duration> get hoursSpan {
    final timeRanges = <TimeOfDay, Duration>{};

    var runningTime = timeStart;
    var runningDuration = const Duration();

    while (runningDuration < duration) {
      final nextHour = TimeOfDay(
        hour: (runningTime.hour + 1) % TimeOfDay.hoursPerDay,
        minute: 0,
      );

      final nextTime =
          durationBetweenTimesOfDay(nextHour, timeEnd) <= const Duration()
              ? timeEnd
              : nextHour;

      final currentDuration = durationBetweenTimesOfDay(runningTime, nextTime);

      runningDuration += currentDuration;

      timeRanges.addAll({
        runningTime.replacing(minute: 0): currentDuration,
      });

      runningTime = nextTime;
    }

    return timeRanges;
  }

  void replaceWith(Booking booking) {
    description = booking.description;
    date = booking.date;
    timeStart = booking.timeStart;
    timeEnd = booking.timeEnd;
    isDisabled = booking.isDisabled;

    modify();
  }

  @override
  String toString() =>
      '$description $dateRange${isDisabled ? ' (disabled)' : ''}';

  @override
  bool operator ==(other) => other is Booking && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

import 'dart:collection' show SplayTreeMap, SplayTreeSet;
import 'dart:convert' show json;

import 'package:cabin_booking/utils/time_of_day_extension.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';

import '../booking/booking.dart';
import '../booking/booking_manager.dart';
import '../booking/recurring_booking.dart';
import '../booking/single_booking.dart';
import '../date/date_ranger.dart';
import '../file/file_manager.dart';
import '../file/writable_manager.dart';
import 'cabin.dart';
import 'tokenized_cabin.dart';

Iterable<Cabin> _parseCabins(String jsonString) =>
    (json.decode(jsonString) as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(Cabin.from);

class CabinManager extends WritableManager<Set<Cabin>> with ChangeNotifier {
  late Set<Cabin> cabins;

  CabinManager({
    Set<Cabin>? cabins,
    String fileName = 'cabin_manager',
  }) : super(fileName) {
    this.cabins = cabins ?? SplayTreeSet();
  }

  List<Map<String, dynamic>> cabinsToJson() =>
      cabins.map((cabin) => cabin.toJson()).toList();

  // TODO(albertms10): use `singleWhereOrNull`.
  Cabin cabinFromId(String? id) => cabins.firstWhere((cabin) => cabin.id == id);

  Cabin? findCabinFromNumber(int number) =>
      cabins.singleWhereOrNull((cabin) => cabin.number == number);

  int get lastCabinNumber => cabins.isEmpty ? 0 : cabins.last.number;

  Set<DateTime> allCabinsDatesWithBookings([DateRanger? dateRange]) =>
      SplayTreeSet.of({
        for (final cabin in cabins) ...cabin.datesWithBookings(dateRange),
      });

  Map<DateTime, int> get allCabinsBookingsCountPerDay {
    final bookingsPerDay = <DateTime, int>{};

    for (final cabin in cabins) {
      for (final bookingsCount in cabin.allBookingsCountPerDay.entries) {
        bookingsPerDay.update(
          bookingsCount.key,
          (count) => count + bookingsCount.value,
          ifAbsent: () => bookingsCount.value,
        );
      }
    }

    return SplayTreeMap.of(
      bookingsPerDay,
      (a, b) => (bookingsPerDay[b] ?? 0) - (bookingsPerDay[a] ?? 0),
    );
  }

  MapEntry<DateTime, int>? get mostBookedDayEntry {
    final countEntries = allCabinsBookingsCountPerDay.entries;

    return countEntries.isEmpty ? null : countEntries.first;
  }

  Map<TimeOfDay, Duration> accumulatedTimeRangesOccupancy([
    DateRanger? dateRange,
  ]) {
    final timeRanges =
        SplayTreeMap<TimeOfDay, Duration>(TimeOfDayExtension.compare);

    for (final cabin in cabins) {
      final accumulatedTimeRanges =
          cabin.accumulatedTimeRangesOccupancy(dateRange);

      for (final bookingTimeRange in accumulatedTimeRanges.entries) {
        timeRanges.update(
          bookingTimeRange.key,
          (duration) => duration + bookingTimeRange.value,
          ifAbsent: () => bookingTimeRange.value,
        );
      }
    }

    return timeRanges;
  }

  Set<TimeOfDay> mostOccupiedTimeRange([DateRanger? dateRange]) =>
      BookingManager.mostOccupiedTimeRangeFromAccumulated(
        accumulatedTimeRangesOccupancy(dateRange),
      );

  int get allBookingsCount {
    var count = 0;

    for (final cabin in cabins) {
      count += cabin.allBookings.length;
    }

    return count;
  }

  int get bookingsCount {
    var count = 0;

    for (final cabin in cabins) {
      count += cabin.bookings.length;
    }

    return count;
  }

  int get recurringBookingsCount {
    var count = 0;

    for (final cabin in cabins) {
      count += cabin.generatedBookingsFromRecurring.length;
    }

    return count;
  }

  Duration totalOccupiedDuration({DateTime? dateTime, DateRanger? dateRange}) {
    var duration = Duration.zero;

    for (final cabin in cabins) {
      duration += cabin.occupiedDuration(
        dateTime: dateTime,
        dateRange: dateRange,
      );
    }

    return duration;
  }

  Map<DateTime, Duration> occupiedDurationPerWeek([DateRanger? dateRange]) {
    final bookingsPerDay = SplayTreeMap<DateTime, Duration>();

    for (final cabin in cabins) {
      final occupiedDuration = cabin.occupiedDurationPerWeek(dateRange);

      for (final durationPerWeek in occupiedDuration.entries) {
        bookingsPerDay.update(
          durationPerWeek.key,
          (duration) => duration + durationPerWeek.value,
          ifAbsent: () => durationPerWeek.value,
        );
      }
    }

    return bookingsPerDay;
  }

  double occupancyPercent({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    Set<DateTime>? dates,
  }) {
    if (cabins.isEmpty) return 0;

    final percents = [
      for (final cabin in cabins)
        cabin.occupancyPercent(
          startTime: startTime,
          endTime: endTime,
          dates: dates,
        ),
    ];

    return percents.reduce((value, element) => value + element) /
        percents.length;
  }

  int bookingsCountBetween(DateRanger dateRange) {
    var count = 0;

    for (final cabin in cabins) {
      count += cabin.bookingsBetween(dateRange).length;
    }

    return count;
  }

  int recurringBookingsCountBetween(DateRanger dateRange) {
    var count = 0;

    for (final cabin in cabins) {
      count += cabin.recurringBookingsBetween(dateRange).length;
    }

    return count;
  }

  void addCabin(
    Cabin cabin, {
    bool notify = true,
  }) {
    cabins.add(cabin);

    if (notify) notifyListeners();
  }

  void modifyCabin(
    Cabin cabin, {
    bool notify = true,
  }) {
    cabins
        .firstWhere((comparingCabin) => cabin.id == comparingCabin.id)
        .replaceWith(cabin);

    if (notify) notifyListeners();
  }

  void removeCabinById(
    String id, {
    bool notify = true,
  }) {
    cabins.removeWhere((cabin) => cabin.id == id);

    if (notify) notifyListeners();
  }

  void emptyCabinsByIds(
    List<String> ids, {
    bool notify = true,
  }) {
    cabins
        .where((cabin) => ids.contains(cabin.id))
        .forEach((cabin) => cabin.emptyAllBookings());

    if (notify) notifyListeners();
  }

  void removeCabinsByIds(
    List<String> ids, {
    bool notify = true,
  }) {
    cabins.removeWhere((cabin) => ids.contains(cabin.id));

    if (notify) notifyListeners();
  }

  void addSingleBooking(
    String? cabinId,
    SingleBooking booking, {
    bool notify = true,
  }) {
    cabinFromId(booking.cabinId ?? cabinId).addSingleBooking(booking);

    if (notify) notifyListeners();
  }

  void addRecurringBooking(
    String? cabinId,
    RecurringBooking recurringBooking, {
    bool notify = true,
  }) {
    cabinFromId(recurringBooking.cabinId ?? cabinId)
        .addRecurringBooking(recurringBooking);

    if (notify) notifyListeners();
  }

  void modifySingleBooking(
    String? cabinId,
    SingleBooking booking, {
    bool notify = true,
  }) {
    if (booking.cabinId == null || booking.cabinId == cabinId) {
      cabinFromId(cabinId).modifySingleBooking(booking);
    } else {
      cabinFromId(cabinId).removeSingleBookingById(booking.id);
      cabinFromId(booking.cabinId).addSingleBooking(booking);
    }

    if (notify) notifyListeners();
  }

  void modifyRecurringBooking(
    String? cabinId,
    RecurringBooking recurringBooking, {
    bool notify = true,
  }) {
    if (recurringBooking.cabinId == null ||
        recurringBooking.cabinId == cabinId) {
      cabinFromId(cabinId).modifyRecurringBooking(recurringBooking);
    } else {
      cabinFromId(cabinId).removeRecurringBookingById(recurringBooking.id);
      cabinFromId(recurringBooking.cabinId)
          .addRecurringBooking(recurringBooking);
    }

    if (notify) notifyListeners();
  }

  void removeSingleBookingById(
    String? cabinId,
    String? bookingId, {
    bool notify = true,
  }) {
    cabinFromId(cabinId).removeSingleBookingById(bookingId);

    if (notify) notifyListeners();
  }

  void removeRecurringBookingById(
    String? cabinId,
    String? bookingId, {
    bool notify = true,
  }) {
    cabinFromId(cabinId).removeRecurringBookingById(bookingId);

    if (notify) notifyListeners();
  }

  void changeRecurringToSingleBooking(
    String? cabinId,
    SingleBooking booking, {
    bool notify = true,
  }) {
    removeRecurringBookingById(cabinId, booking.id, notify: false);
    addSingleBooking(cabinId, booking, notify: false);

    if (notify) notifyListeners();
  }

  void changeSingleToRecurringBooking(
    String? cabinId,
    RecurringBooking recurringBooking, {
    bool notify = true,
  }) {
    removeSingleBookingById(cabinId, recurringBooking.id, notify: false);
    addRecurringBooking(cabinId, recurringBooking, notify: false);

    if (notify) notifyListeners();
  }

  Cabin? findCabinFromTokenized(TokenizedCabin tokenized) {
    final cabinNumber = int.tryParse(tokenized.cabinNumber ?? '');
    if (cabinNumber == null) return null;

    return findCabinFromNumber(cabinNumber);
  }

  Set<Booking> searchBookings(String query, {int? perCabinLimit}) =>
      SplayTreeSet.of(
        [
          for (final cabin in cabins)
            ...cabin.searchBookings(query, limit: perCabinLimit),
        ],
        // Descending.
        (a, b) => b.startDate!.compareTo(a.startDate!),
      );

  Set<Cabin> get _defaultCabins => SplayTreeSet();

  @override
  Future<Set<Cabin>> readFromFile() async {
    try {
      final file = await fileManager.localFile(fileName);
      final content = await file.readAsUncompressedString();

      final cabins = _parseCabins(content);

      return cabins.isEmpty ? _defaultCabins : SplayTreeSet.of(cabins);
    } on Exception {
      return _defaultCabins;
    }
  }

  @override
  Future<int> loadFromFile() async {
    cabins = await readFromFile();

    notifyListeners();

    return cabins.length;
  }

  @override
  Future<bool> writeToFile() async {
    try {
      final file = await fileManager.localFile(fileName);

      await file.writeAsCompressedString(
        json.encode(cabinsToJson()),
      );

      return true;
    } on Exception {
      return false;
    }
  }
}

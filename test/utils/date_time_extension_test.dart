import 'package:cabin_booking/utils/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeExtension', () {
    group('.dateOnly', () {
      test(
        'should return only the date information of this DateTime, keeping '
        'UTC information',
        () {
          expect(
            DateTime(2021, 9, 7, 21, 30, 10).dateOnly,
            DateTime(2021, 9, 7),
          );
          expect(
            DateTime.utc(2021, 9, 7, 21, 30, 10).dateOnly,
            DateTime.utc(2021, 9, 7),
          );
        },
      );
    });

    group('.addTimeOfDay()', () {
      test('should return a new DateTime adding the TimeOfDay information', () {
        expect(
          DateTime(2021, 9, 7)
              .addTimeOfDay(const TimeOfDay(hour: 21, minute: 30)),
          DateTime(2021, 9, 7, 21, 30),
        );
      });

      test(
        'should return a new DateTime replacing the TimeOfDay information',
        () {
          expect(
            DateTime(2021, 9, 7, 8, 15)
                .addTimeOfDay(const TimeOfDay(hour: 21, minute: 30)),
            DateTime(2021, 9, 7, 21, 30),
          );
        },
      );
    });

    group('.isSameDateAs()', () {
      test('should return true when the dates are the same', () {
        expect(
          DateTime(2021, 9, 7, 21, 30, 10)
              .isSameDateAs(DateTime(2021, 9, 7, 10, 45, 40)),
          isTrue,
        );
      });

      test('should return false when the dates are not the same', () {
        expect(
          DateTime(2021, 1, 10, 9, 30)
              .isSameDateAs(DateTime(2021, 2, 10, 9, 30)),
          isFalse,
        );
      });
    });

    group('.dayOfWeek()', () {
      test('should return the day of the week relative to this DateTime', () {
        expect(
          DateTime(2021, 1, 8, 9, 30).dayOfWeek(DateTime.sunday),
          DateTime(2021, 1, 10, 9, 30),
        );
        expect(
          DateTime.utc(1989, 11, 9).dayOfWeek(DateTime.saturday),
          DateTime.utc(1989, 11, 11),
        );
        expect(
          DateTime.utc(1989, 11, 9).dayOfWeek(DateTime.monday),
          DateTime.utc(1989, 11, 6),
        );
      });
    });

    group('.firstDayOfWeek', () {
      test(
        'should return the first day of the week relative to this DateTime',
        () {
          expect(
            DateTime(2021, 1, 10, 9, 30).firstDayOfWeek,
            DateTime(2021, 1, 4, 9, 30),
          );
          expect(
            DateTime.utc(1989, 11, 9).firstDayOfWeek,
            DateTime.utc(1989, 11, 6),
          );
        },
      );
    });

    group('.toDouble()', () {
      test('should return a double representation of this DateTime', () {
        expect(DateTime(2021, 1, 10, 9, 30).toDouble(), closeTo(18637.3, 0.1));
      });
    });
  });
}

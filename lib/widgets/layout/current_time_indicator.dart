import 'package:cabin_booking/constants.dart';
import 'package:cabin_booking/model.dart';
import 'package:cabin_booking/utils/date_time_extension.dart';
import 'package:cabin_booking/widgets/layout/horizontal_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timer_builder/timer_builder.dart';

class CurrentTimeIndicator extends StatelessWidget {
  final bool hideText;

  const CurrentTimeIndicator({Key? key, this.hideText = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TimerBuilder.periodic(
      const Duration(seconds: 5),
      builder: (context) {
        final dayHandler = Provider.of<DayHandler>(context);

        final viewStartDateTime =
            dayHandler.dateTime.addTimeOfDay(kTimeTableStartTime);
        final viewEndDateTime =
            dayHandler.dateTime.addTimeOfDay(kTimeTableEndTime);

        final now = DateTime.now();
        final durationFromStart = now.difference(viewStartDateTime);
        final durationFromEnd = now.difference(viewEndDateTime);

        if (durationFromStart <= Duration.zero ||
            durationFromEnd >= const Duration(minutes: 15)) {
          return const SizedBox();
        }

        return HorizontalIndicator(
          verticalOffset: durationFromStart.inMicroseconds /
              Duration.microsecondsPerMinute *
              kBookingHeightRatio,
          label: Text(
            hideText ? '' : TimeOfDay.fromDateTime(now).format(context),
            style: TextStyle(
              color: Colors.red[400],
              fontWeight: FontWeight.bold,
            ),
          ),
          indicatorColor: Colors.red[400],
        );
      },
    );
  }
}

import 'package:cabin_booking/constants.dart';
import 'package:cabin_booking/model/cabin.dart';
import 'package:cabin_booking/widgets/booking/booking_dialog.dart';
import 'package:flutter/material.dart';

class EmptyBooking extends StatelessWidget {
  final Cabin cabin;
  final DateTime startDate;
  final DateTime endDate;
  final int duration;

  EmptyBooking({
    @required this.cabin,
    @required this.startDate,
    @required this.endDate,
    this.duration = 60,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        child: Tooltip(
          message: '$duration min',
          child: InkWell(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => BookingDialog(
                  cabin: cabin,
                  startDate: startDate,
                  endDate: endDate,
                ),
              );
            },
            child: Icon(
              Icons.add,
              size: 18,
              color: Colors.black38,
            ),
          ),
        ),
      ),
      width: double.infinity,
      height: duration * bookingHeightRatio,
    );
  }
}

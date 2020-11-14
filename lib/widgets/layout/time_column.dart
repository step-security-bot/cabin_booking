import 'package:cabin_booking/constants.dart';
import 'package:flutter/material.dart';

class TimeColumn extends StatelessWidget {
  final int start;
  final int end;

  TimeColumn({@required this.start, @required this.end});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int time = start; time <= end; time++)
          Container(
            height: 60 * bookingHeightRatio,
            padding: EdgeInsets.all(16),
            child: Text(
              '$time:00',
              style: Theme.of(context)
                  .textTheme
                  .headline5
                  .copyWith(color: Colors.black45),
            ),
          ),
      ],
    );
  }
}

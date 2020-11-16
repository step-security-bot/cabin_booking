import 'package:cabin_booking/l10n/app_localizations.dart';
import 'package:cabin_booking/model/cabin_manager.dart';
import 'package:cabin_booking/widgets/booking/bookings_table.dart';
import 'package:cabin_booking/widgets/cabin/cabins_row.dart';
import 'package:cabin_booking/widgets/layout/day_navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimeTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cabinManager = Provider.of<CabinManager>(context, listen: false);

    cabinManager.addListener(() {
      cabinManager.writeCabinsToFile();
    });

    return FutureBuilder(
      future: cabinManager.loadCabinsFromFile(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(
            child: Text(
              AppLocalizations.of(context).dataCouldNotBeLoaded,
              style: Theme.of(context).textTheme.headline4,
            ),
          );
        else if (snapshot.hasData)
          return SingleChildScrollView(
            child: Column(
              children: [
                DayNavigation(),
                CabinsRow(),
                BookingsTable(),
              ],
            ),
          );
        else
          return Center(child: CircularProgressIndicator());
      },
    );
  }
}

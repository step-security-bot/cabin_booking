import 'package:cabin_booking/model.dart';
import 'package:cabin_booking/widgets/layout/save_changes_snack_bar_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class MainDataLoader extends StatefulWidget {
  final Widget child;

  const MainDataLoader({super.key, required this.child});

  @override
  State<MainDataLoader> createState() => _MainDataLoaderState();
}

class _MainDataLoaderState extends State<MainDataLoader> {
  late final CabinManager _cabinManager =
      Provider.of<CabinManager>(context, listen: false)
        ..addListener(_writeCabinsAndShowSnackBar);

  late final SchoolYearManager _schoolYearManager =
      Provider.of<DayHandler>(context, listen: false).schoolYearManager
        ..addListener(_writeSchoolYearsAndShowSnackBar);

  Future<void> _writeAndShowSnackBar(WritableManager<dynamic> manager) async {
    final changesSaved = await manager.writeToFile();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: SaveChangesSnackBarBody(changesSaved: changesSaved),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: changesSaved ? 1200 : 3000),
      ),
    );
  }

  void _writeCabinsAndShowSnackBar() => _writeAndShowSnackBar(_cabinManager);

  void _writeSchoolYearsAndShowSnackBar() =>
      _writeAndShowSnackBar(_schoolYearManager);

  @override
  void dispose() {
    _cabinManager.removeListener(_writeCabinsAndShowSnackBar);
    _schoolYearManager.removeListener(_writeSchoolYearsAndShowSnackBar);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureProvider<List<int>?>(
      create: (context) => Future.wait([
        _cabinManager.loadFromFile(),
        _schoolYearManager.loadFromFile(),
      ]),
      initialData: const [],
      catchError: (context, error) => null,
      builder: (context, child) {
        final items = Provider.of<List<int>?>(context);

        if (items == null) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.dataCouldNotBeLoaded,
              style: Theme.of(context).textTheme.headline4,
            ),
          );
        } else if (items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return child!;
      },
      child: widget.child,
    );
  }
}

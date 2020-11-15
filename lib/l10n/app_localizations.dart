import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'ca': {
      'title': 'Reserva de cabines',
      'cabin': 'Cabina',
      'booking': 'Reserva',
      'book': 'Reservar',
      'student': 'Estudiant',
      'edit': 'Editar',
      'delete': 'Eliminar',
      'previousDay': 'Dia anterior',
      'today': 'Avui',
      'nextDay': 'Dia següent',
      'start': 'Inici',
      'end': 'Final',
    },
    'en': {
      'title': 'Cabin Booking',
      'cabin': 'Cabin',
      'booking': 'Booking',
      'book': 'Book',
      'student': 'Student',
      'edit': 'Edit',
      'delete': 'Delete',
      'previousDay': 'Previous day',
      'today': 'Today',
      'nextDay': 'Next day',
      'start': 'Start',
      'end': 'End',
    },
    'es': {
      'title': 'Reserva de cabinas',
      'cabin': 'Cabina',
      'booking': 'Reserva',
      'book': 'Reservar',
      'student': 'Estudiante',
      'edit': 'Editar',
      'delete': 'Eliminar',
      'previousDay': 'Día anterior',
      'today': 'Hoy',
      'nextDay': 'Día siguiente',
      'start': 'Inicio',
      'end': 'Final',
    },
  };

  String get title {
    return _localizedValues[locale.languageCode]['title'];
  }

  String get cabin {
    return _localizedValues[locale.languageCode]['cabin'];
  }

  String get booking {
    return _localizedValues[locale.languageCode]['booking'];
  }

  String get book {
    return _localizedValues[locale.languageCode]['book'];
  }

  String get student {
    return _localizedValues[locale.languageCode]['student'];
  }

  String get edit {
    return _localizedValues[locale.languageCode]['edit'];
  }

  String get delete {
    return _localizedValues[locale.languageCode]['delete'];
  }

  String get previousDay {
    return _localizedValues[locale.languageCode]['previousDay'];
  }

  String get today {
    return _localizedValues[locale.languageCode]['today'];
  }

  String get nextDay {
    return _localizedValues[locale.languageCode]['nextDay'];
  }

  String get start {
    return _localizedValues[locale.languageCode]['start'];
  }

  String get end {
    return _localizedValues[locale.languageCode]['end'];
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const ['ca', 'en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

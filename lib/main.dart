import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rain/app/modules/home.dart';
import 'package:rain/app/modules/onboarding.dart';
import 'package:rain/theme/theme.dart';
import 'app/data/weather.dart';
import 'translation/translation.dart';
import 'theme/theme_controller.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

late Isar isar;
late Settings settings;
final ValueNotifier<Future<bool>> isDeviceConnectedNotifier =
    ValueNotifier(InternetConnectionChecker().hasConnection);

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

bool amoledTheme = false;
bool materialColor = false;
Locale locale = const Locale('en', 'US');

final List appLanguages = [
  {'name': 'English', 'locale': const Locale('en', 'US')},
  {'name': 'Русский', 'locale': const Locale('ru', 'RU')},
  {'name': 'italiano', 'locale': const Locale('it', 'IT')},
  {'name': 'Deutsch', 'locale': const Locale('de', 'DE')},
  {'name': 'Français', 'locale': const Locale('fr', 'FR')},
  {'name': 'Türkçe', 'locale': const Locale('tr', 'TR')},
  {'name': 'Brasileiro', 'locale': const Locale('pt', 'BR')},
  {'name': 'Español', 'locale': const Locale('es', 'ES')},
  {'name': 'Slovenčina', 'locale': const Locale('sk', 'SK')},
  {'name': 'Nederlands', 'locale': const Locale('nl', 'NL')},
  {'name': 'हिन्दी', 'locale': const Locale('hi', 'IN')},
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
    ),
  );
  await isarInit();
  await setOptimalDisplayMode();
  Connectivity()
      .onConnectivityChanged
      .listen((ConnectivityResult result) async {
    if (result != ConnectivityResult.none) {
      isDeviceConnectedNotifier.value =
          InternetConnectionChecker().hasConnection;
    } else {
      isDeviceConnectedNotifier.value = Future(() => false);
    }
  });
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
  runApp(const MyApp());
}

Future<void> setOptimalDisplayMode() async {
  final List<DisplayMode> supported = await FlutterDisplayMode.supported;
  final DisplayMode active = await FlutterDisplayMode.active;

  final List<DisplayMode> sameResolution = supported
      .where((DisplayMode m) =>
          m.width == active.width && m.height == active.height)
      .toList()
    ..sort((DisplayMode a, DisplayMode b) =>
        b.refreshRate.compareTo(a.refreshRate));

  final DisplayMode mostOptimalMode =
      sameResolution.isNotEmpty ? sameResolution.first : active;

  await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
}

Future<void> isarInit() async {
  isar = await Isar.open([
    SettingsSchema,
    MainWeatherCacheSchema,
    LocationCacheSchema,
    WeatherCardSchema,
  ], directory: (await getApplicationSupportDirectory()).path);
  settings = await isar.settings.where().findFirst() ?? Settings();
  if (settings.language == null) {
    settings.language = '${Get.deviceLocale}';
    isar.writeTxn(() async => isar.settings.put(settings));
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static Future<void> updateAppState(
    BuildContext context, {
    bool? newAmoledTheme,
    bool? newMaterialColor,
    Locale? newLocale,
  }) async {
    final state = context.findAncestorStateOfType<_MyAppState>()!;

    if (newAmoledTheme != null) {
      state.changeAmoledTheme(newAmoledTheme);
    }
    if (newMaterialColor != null) {
      state.changeMarerialTheme(newMaterialColor);
    }
    if (newLocale != null) {
      state.changeLocale(newLocale);
    }
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final themeController = Get.put(ThemeController());

  void changeAmoledTheme(bool newAmoledTheme) {
    setState(() {
      amoledTheme = newAmoledTheme;
    });
  }

  void changeMarerialTheme(bool newMaterialColor) {
    setState(() {
      materialColor = newMaterialColor;
    });
  }

  void changeLocale(Locale newLocale) {
    setState(() {
      locale = newLocale;
    });
  }

  @override
  void initState() {
    amoledTheme = settings.amoledTheme;
    materialColor = settings.materialColor;
    locale = Locale(
        settings.language!.substring(0, 2), settings.language!.substring(3));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return GetMaterialApp(
          themeMode: themeController.theme,
          theme: RainTheme.lightTheme,
          darkTheme: amoledTheme ? RainTheme.oledTheme : RainTheme.darkTheme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          translations: Translation(),
          locale: locale,
          fallbackLocale: const Locale('en', 'US'),
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ru', 'RU'),
            Locale('it', 'IT'),
            Locale('de', 'DE'),
            Locale('fr', 'FR'),
            Locale('tr', 'TR'),
            Locale('pt', 'BR'),
            Locale('es', 'ES'),
            Locale('sk', 'SK'),
            Locale('nl', 'NL'),
            Locale('hi', 'IN')
          ],
          debugShowCheckedModeBanner: false,
          home: settings.onboard == false
              ? const OnboardingPage()
              : const HomePage(),
        );
      },
    );
  }
}

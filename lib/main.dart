import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_ume_kit_console_plus/flutter_ume_kit_console_plus.dart';
import 'package:flutter_ume_kit_device_plus/flutter_ume_kit_device_plus.dart';
import 'package:flutter_ume_plus/flutter_ume_plus.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/services/audio_handler.dart';
import 'package:harmonymusic/services/downloader.dart';
import 'package:harmonymusic/services/music_service.dart';
import 'package:harmonymusic/services/piped_service.dart';
import 'package:harmonymusic/ui/home.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:harmonymusic/ui/screens/Home/home_screen_controller.dart';
import 'package:harmonymusic/ui/screens/Library/library_controller.dart';
import 'package:harmonymusic/ui/screens/Search/search_screen_controller.dart';
import 'package:harmonymusic/ui/screens/Settings/settings_screen_controller.dart';
import 'package:harmonymusic/ui/utils/theme_controller.dart';
import 'package:harmonymusic/utils/app_link_controller.dart';
import 'package:harmonymusic/utils/get_localization.dart';
import 'package:harmonymusic/utils/system_tray.dart';
import 'package:harmonymusic/utils/update_check_flag_file.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ume_kit_monitor/monitor/awesome_monitor.dart';
import 'package:ume_kit_monitor/monitor/monitor_action_widget.dart';
import 'package:ume_kit_monitor/monitor_plugin.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  _setAppInitPrefs();
  startApplicationServices();
  Get.put<AudioHandler>(await initAudioService(), permanent: true);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  PluginManager.instance
    ..register(const MonitorPlugin())
    ..register(const MonitorActionsPlugin())
    ..register(Console())
    ..register(const DeviceInfoPanel());
  runApp(const UMEWidget(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (!GetPlatform.isDesktop) Get.put(AppLinksController());
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == 'AppLifecycleState.resumed') {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      } else if (msg == 'AppLifecycleState.detached') {
        await Get.find<AudioHandler>().customAction('saveSession');
      }
      return null;
    });

    Monitor.init(context, actions: [
      MonitorActionWidget(
        title: 'DebugPage',
        onTap: () async {},
      ),
    ]);

    /// why cannot retrieve current-route?
    final currentRoute = Get.currentRoute;
    debugPrint('current-route: $currentRoute');
    Monitor.instance.put('page', currentRoute);
    // Monitor.instance.put('response', 'response-api');
    // Monitor.instance.put('curl', 'curl-value');
    Monitor.instance.putsConsole(['contents : $currentRoute']);
    return ScreenUtilInit(
      designSize: const Size(750, 1624),
      splitScreenMode: true,
      minTextAdapt: true,
      builder: (_, child) {
        return GetX<ThemeController>(
          builder: (controller) {
            return GetMaterialApp(
                title: 'Harmony Music',
                theme: controller.themedata.value,
                home: const Home(),
                debugShowCheckedModeBanner: false,
                translations: Languages(),
                locale: Locale(Hive.box('AppPrefs').get('currentAppLanguageCode') ?? 'en'),
                fallbackLocale: const Locale('en'),
                builder: (context, child) {
                  final scale = MediaQuery.of(context).textScaler.clamp(minScaleFactor: 1, maxScaleFactor: 1.1);
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaler: scale),
                    child: child!,
                  );
                });
          },
        );
      },
    );
  }
}

Future<void> startApplicationServices() async {
  Get.lazyPut(PipedServices.new, fenix: true);
  Get.lazyPut(MusicServices.new, fenix: true);
  Get.lazyPut(ThemeController.new, fenix: true);
  Get.lazyPut(PlayerController.new, fenix: true);
  Get.lazyPut(HomeScreenController.new, fenix: true);
  Get.lazyPut(LibrarySongsController.new, fenix: true);
  Get.lazyPut(LibraryPlaylistsController.new, fenix: true);
  Get.lazyPut(LibraryAlbumsController.new, fenix: true);
  Get.lazyPut(LibraryArtistsController.new, fenix: true);
  Get.lazyPut(SettingsScreenController.new, fenix: true);
  Get.lazyPut(Downloader.new, fenix: true);

  if (GetPlatform.isDesktop) {
    Get.lazyPut(SearchScreenController.new, fenix: true);
    Get.put(DesktopSystemTray());
  }
}

Future<void> initHive() async {
  String applicationDataDirectoryPath;
  if (GetPlatform.isDesktop) {
    applicationDataDirectoryPath = '${(await getApplicationSupportDirectory()).path}/db';
  } else {
    applicationDataDirectoryPath = (await getApplicationDocumentsDirectory()).path;
  }
  await Hive.initFlutter(applicationDataDirectoryPath);
  await Hive.openBox('SongsCache');
  await Hive.openBox('SongDownloads');
  await Hive.openBox('SongsUrlCache');
  await Hive.openBox('AppPrefs');
}

void _setAppInitPrefs() {
  final appPrefs = Hive.box('AppPrefs');
  if (appPrefs.isEmpty) {
    appPrefs.putAll({
      'themeModeType': 0,
      'cacheSongs': false,
      'skipSilenceEnabled': false,
      'streamingQuality': 1,
      'themePrimaryColor': 4278199603,
      'discoverContentType': 'QP',
      'newVersionVisibility': updateCheckFlag,
      'cacheHomeScreenData': true
    });
  }
}

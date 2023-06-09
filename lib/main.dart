import 'package:dino_run/game/dino.dart';
import 'package:dino_run/vision_detector_views/pose_detector_view.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'models/settings.dart';
import 'models/player_data.dart';

import 'package:camera/camera.dart';

import 'package:flame/game.dart';
import 'widgets/hud.dart';
import 'game/dino_run.dart';
import 'widgets/main_menu.dart';
import 'widgets/pause_menu.dart';
import 'widgets/settings_menu.dart';
import 'widgets/game_over_menu.dart';

List<CameraDescription> cameras = [];
final Changer changer = Changer();
DinoRun _dinoRun = DinoRun();

Future<void> main() async {
  // Ensures that all bindings are initialized
  // before was start calling hive and flame code
  // dealing with platform channels.
  WidgetsFlutterBinding.ensureInitialized();

  // Makes the game full screen and landscape only.
  Flame.device.fullScreen();
  Flame.device.setLandscape();
  cameras = await availableCameras();

  // Initializes hive and register the adapters.
  await initHive();
  runApp(const JustStyle());
}

// The main widget for this game.
class DinoRunApp extends StatelessWidget {
  const DinoRunApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dino Run',
      theme: ThemeData(
        fontFamily: 'Audiowide',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Settings up some default theme for elevated buttons.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            fixedSize: const Size(200, 60),
          ),
        ),
      ),
      home: Scaffold(
        body: GameWidget(
          // This will dislpay a loading bar until [DinoRun] completes
          // its onLoad method.
          loadingBuilder: (conetxt) => const Center(
            child: SizedBox(
              width: 200,
              child: LinearProgressIndicator(),
            ),
          ),
          // Register all the overlays that will be used by this game.
          overlayBuilderMap: {
            MainMenu.id: (_, DinoRun gameRef) => MainMenu(gameRef),
            PauseMenu.id: (_, DinoRun gameRef) => PauseMenu(gameRef),
            Hud.id: (_, DinoRun gameRef) => Hud(gameRef),
            GameOverMenu.id: (_, DinoRun gameRef) => GameOverMenu(gameRef),
            SettingsMenu.id: (_, DinoRun gameRef) => SettingsMenu(gameRef),
          },
          // By default MainMenu overlay will be active.
          initialActiveOverlays: const [MainMenu.id],
          game: _dinoRun,
        ),
      ),
    );
  }
}

/*class JustStyle extends StatelessWidget {
  const JustStyle({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: Row(
        children: const [
          SizedBox(
            width: 300,
            child: PoseDetectorView(),
          ),
          SizedBox(
            width: 500,
            child: DinoRunApp(),
          ),
        ],
      )),
    );
  }
} 
class JustStyle extends StatelessWidget {
  const JustStyle({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: PoseDetectorView(),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: DinoRunApp(),
          ),
        ],
      ),
    );
  }
}*/

class JustStyle extends StatelessWidget {
  const JustStyle({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          child: Row(
            children: const [
              SizedBox(
                child: PoseDetectorView(),
                width: 300,
              ),
              Expanded(child: DinoRunApp()),
            ],
          ),
        ),
      ),
    );
  }
}

// This function will initilize hive with apps documents directory.
// Additionally it will also register all the hive adapters.
Future<void> initHive() async {
  // For web hive does not need to be initialized.
  if (!kIsWeb) {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  Hive.registerAdapter<PlayerData>(PlayerDataAdapter());
  Hive.registerAdapter<Settings>(SettingsAdapter());
}

// The main widget for this game.

class Changer extends ChangeNotifier {
  int selectedOpt = 0;
  bool positionCapture = false;
  double poseStanding = 0;

  void notify() {
    notifyListeners();
  }
}

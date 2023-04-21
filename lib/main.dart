import 'package:dino_run/vision_detector_views/pose_detector_view.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'old_main.dart';
import 'models/settings.dart';
import 'models/player_data.dart';

import 'package:camera/camera.dart';

List<CameraDescription> cameras = [];
final Changer changer = Changer();

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

class JustStyle extends StatelessWidget {
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
  int btnPressed = -1;
  int selectedOpt = 0;

  void notify() {
    notifyListeners();
  }
}

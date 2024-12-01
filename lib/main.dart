import 'package:flame/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'widgets/hud.dart';
import 'game/dino_run.dart';
import 'models/settings.dart';
import 'widgets/main_menu.dart';
import 'models/player_data.dart';
import 'widgets/pause_menu.dart';
import 'widgets/settings_menu.dart';
import 'widgets/game_over_menu.dart';
import 'widgets/level_completed_menu.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initializes hive and registers adapters.
  await initHive();
  runApp(const DinoRunApp());
}

Future<void> initHive() async {
  if (!kIsWeb) {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  Hive.registerAdapter<PlayerData>(PlayerDataAdapter());
  Hive.registerAdapter<Settings>(SettingsAdapter());
}

class DinoRunApp extends StatelessWidget {
  const DinoRunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dino Run',
      theme: ThemeData(
        fontFamily: 'Audiowide',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            fixedSize: const Size(200, 60),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dino Run - Maps")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Wrapping the entire Column in a scroll view.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(5, (index) {
              return MapCard(index: index);
            }),
          ),
        ),
      ),
    );
  }
}

class MapCard extends StatefulWidget {
  final int index;

  const MapCard({Key? key, required this.index}) : super(key: key);

  @override
  _MapCardState createState() => _MapCardState();
}

class _MapCardState extends State<MapCard> {
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  // List of parallax backgrounds for each card. Each card has 6 layers now.
  final List<List<String>> parallaxBackgrounds = [
    [
      'assets/images/parallax/plx-1.png',
      'assets/images/parallax/plx-2.png',
      'assets/images/parallax/plx-3.png',
      'assets/images/parallax/plx-4.png',
      'assets/images/parallax/plx-5.png',
      'assets/images/parallax/plx-6.png'
    ],
    [
      'assets/images/parallax/plx-7.png',
      'assets/images/parallax/plx-8.png',
      'assets/images/parallax/plx-9.png',
      'assets/images/parallax/plx-10.png',
      'assets/images/parallax/plx-11.png',
      'assets/images/parallax/plx-12.png'
    ],
    [
      'assets/images/parallax/plx-13.png',
      'assets/images/parallax/plx-14.png',
      'assets/images/parallax/plx-15.png',
      'assets/images/parallax/plx-16.png',
      'assets/images/parallax/plx-17.png',
      'assets/images/parallax/plx-18.png'
    ],
    [
      'assets/images/parallax/plx-19.png',
      'assets/images/parallax/plx-20.png',
      'assets/images/parallax/plx-21.png',
      'assets/images/parallax/plx-22.png',
      'assets/images/parallax/plx-23.png',
      'assets/images/parallax/plx-24.png'
    ],
    [
      'assets/images/parallax/plx-25.png',
      'assets/images/parallax/plx-26.png',
      'assets/images/parallax/plx-27.png',
      'assets/images/parallax/plx-28.png',
      'assets/images/parallax/plx-29.png',
      'assets/images/parallax/plx-30.png'
    ],
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the 6 parallax layers for the current card
    List<String> currentBackgrounds = parallaxBackgrounds[widget.index];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      child: InkWell(
        onTap: () {
          // Navigate to DinoRun when the map is clicked
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameWidget<DinoRun>.controlled(
                loadingBuilder: (context) => const Center(
                  child: SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(),
                  ),
                ),
                overlayBuilderMap: {
                  MainMenu.id: (_, game) => MainMenu(game),
                  PauseMenu.id: (_, game) => PauseMenu(game),
                  Hud.id: (_, game) => Hud(game),
                  GameOverMenu.id: (_, game) => GameOverMenu(game),
                  SettingsMenu.id: (_, game) => SettingsMenu(game),
                  LevelCompletedMenu.id: (_, game) => LevelCompletedMenu(game),
                },
                initialActiveOverlays: const [MainMenu.id],
                gameFactory: () => DinoRun(
                  camera: CameraComponent.withFixedResolution(
                    width: 360,
                    height: 180,
                  ),
                ),
              ),
            ),
          );
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            // Ensure the child is constrained within screen width.
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context)
                  .size
                  .width, // Don't exceed screen width
            ),
            child: SizedBox(
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Use 6 parallax layers for each card
                  for (int layer = 0;
                      layer < currentBackgrounds.length;
                      layer++)
                    Positioned(
                      left: -_scrollOffset *
                          (0.05 * (layer + 1)), // Varying scroll speeds
                      right: 0,
                      child: Image.asset(
                        currentBackgrounds[
                            layer], // Use the respective background for the layer
                        fit: BoxFit.cover,
                      ),
                    ),

                  // Text overlay
                  Center(
                    child: Text(
                      'Map ${widget.index + 1}',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

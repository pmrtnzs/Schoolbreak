import 'package:base_app/main.dart';
import 'package:base_app/widgets/on_hover_options.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class GameOverPage extends StatefulWidget {

  final String outcome;
  const GameOverPage({super.key, required this.outcome});

  @override
  GameOverPageState createState() => GameOverPageState();
}

class GameOverPageState extends State<GameOverPage> {
  late VideoPlayerController _outroController;
  late Duration outroDuration;
  String lastFrame = 'assets/images/placeholder2.png';
  bool isButtonVisible = false;

  @override
  initState(){
    super.initState();
    startOutro();
  }

  Future<void> startOutro() async {
    //Outro
    _outroController = VideoPlayerController.asset('assets/videos/out${widget.outcome}.mp4');
    try {
      await _outroController.initialize();
    } catch (e) {
      debugPrint("Error initializing outro player: $e");
    }
    outroDuration = _outroController.value.duration;
    if (_outroController.value.isInitialized) {
      try {
        setState(() {});
        _outroController.setVolume(0);
        await _outroController.play();
        await Future.delayed(outroDuration);
      } catch (e) {
        debugPrint("Error playing video: $e");
      }
    } else {
      debugPrint("Video player is not initialized");
    }
    setState(() {
      isButtonVisible = true;
    }); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          const videoAspectRatio = 1920 / 1080;

          // Calculate the size of the video player to maintain aspect ratio
          double videoWidth, videoHeight;
          if (screenWidth / screenHeight > videoAspectRatio) {
            videoHeight = screenHeight;
            videoWidth = videoHeight * videoAspectRatio;
          } else {
            videoWidth = screenWidth;
            videoHeight = videoWidth / videoAspectRatio;
          }

          // Center the video player
          final videoLeft = (screenWidth - videoWidth) / 2;
          final videoTop = (screenHeight - videoHeight) / 2;

          // Button size and position relative to the video
          final buttonWidth = videoWidth * 0.155;
          final buttonHeight = buttonWidth;
          final buttonBottomOffset = videoTop + videoHeight * 0.45;
          final buttonRightOffset = videoLeft + videoWidth * 0.67;

          return Stack(
            children: [
              Positioned(
                left: videoLeft,
                top: videoTop,
                width: videoWidth,
                height: videoHeight,
                child: _outroController.value.isInitialized
                  ? VideoPlayer(_outroController)
                  : Container(
                      width: videoWidth,
                      height: videoHeight,
                      color: Colors.black
                  ),
              ),

              // Play again button
              if (isButtonVisible)
              Positioned(
                bottom: screenHeight - buttonBottomOffset,
                right: screenWidth - buttonRightOffset,
                child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      isButtonVisible = false;
                    });
                    await resetDatabases();
                    RestartWidget.restartApp(context);
                  },
                  child: OnHoverOptions(
                    // ignore: sort_child_properties_last
                    child: Image.asset(
                      'assets/images/out${widget.outcome}.png',
                      width: buttonWidth,
                      height: buttonHeight,
                    ),
                    overlayChild: Center(
                      child: Text(
                        'Play again',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.schoolbell(
                          fontSize: buttonWidth * 0.2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:base_app/pages/game_page.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../widgets/on_hover_button.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  IntroPageState createState() => IntroPageState();
}

class IntroPageState extends State<IntroPage> {
  late VideoPlayerController _introController;
  late Duration introDuration;
  String lastFrame = 'assets/images/placeholder.png';
  bool isButtonVisible = false;

  @override
  initState(){
    super.initState();
    startIntro();
  }

  Future<void> startIntro() async {
    // Opening video
    _introController = VideoPlayerController.asset('assets/videos/intro1.mp4');
    try {
      await _introController.initialize();
    } catch (e) {
      debugPrint("Error initializing video player: $e");
    }
    introDuration = _introController.value.duration;
    await playIntro();
    
    //Loop intro
    await _introController.dispose();
    _introController = VideoPlayerController.asset('assets/videos/intro2.mp4');
    try {
      await _introController.initialize();
      _introController.setVolume(0);
      _introController.setLooping(true);
      _introController.play();
      setState(() {
        isButtonVisible = true;
      });
    } catch (e) {
      debugPrint("Error initializing video player: $e");
    }
    // Wait for user input
  }

  Future<void> playHandler() async{
    //Closing video
    await _introController.dispose();
    _introController = VideoPlayerController.asset('assets/videos/intro3.mp4');
    try {
      await _introController.initialize();
      setState(() {
        lastFrame = 'assets/images/placeholder2.png';
      });
    } catch (e) {
      debugPrint("Error initializing video player: $e");
    }
    introDuration = _introController.value.duration;
    try {
      _introController.setVolume(0);
      await _introController.play();
      await Future.delayed(introDuration - const Duration(milliseconds: 500));
      _introController.pause();
    } catch (e) {
      debugPrint("Error playing video: $e");
    }
    playIntro();
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => const GamePage()),
    );
  }

  Future<void> playIntro() async {
    try {
      setState(() {
      });
      _introController.setVolume(0);
      await _introController.play();
      await Future.delayed(introDuration);
      _introController.pause();
    } catch (e) {
      debugPrint("Error playing video: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
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

          // Button position relative to the video player
          final buttonWidth = videoWidth * 0.2585;
          final buttonHeight = videoHeight * 0.2585;
          final buttonBottomOffset = videoTop + videoHeight * 0.695;
          final buttonRightOffset = videoLeft + videoWidth * 0.6125;

          return Stack(
            children: [
              Positioned(
                left: videoLeft,
                top: videoTop,
                width: videoWidth,
                height: videoHeight,
                child: _introController.value.isInitialized
                    ? VideoPlayer(_introController)
                    : Image.asset(
                        lastFrame,
                        width: videoWidth,
                        height: videoHeight,
                        fit: BoxFit.cover,
                      ),
              ),

              // Play button
              if (isButtonVisible)
              Positioned(
                bottom: screenHeight - buttonBottomOffset,
                right: screenWidth - buttonRightOffset,
                child: OnHoverButton(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isButtonVisible = false;
                      });
                      playHandler();
                    },
                    child: Image.asset(
                      'assets/images/play_button.png',
                      width: buttonWidth,
                      height: buttonHeight,
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
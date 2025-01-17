import 'dart:async';
import 'package:base_app/widgets/on_hover_button.dart';
import 'package:base_app/widgets/on_hover_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:base_app/pages/game_over_page.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../main.dart';
import '../nodes/node.dart';
import 'quiz_page.dart';


class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
  State<StatefulWidget> createState() {
    return GamePageState();
  }
}

class GamePageState extends State <GamePage> with SingleTickerProviderStateMixin {
  late int iD;
  late int op1;
  late int op2;
  late int op3;
  String situation = "";
  String decision = "";
  String op1Text = "";
  String op2Text = "";
  String op3Text = "";
  String sitID = 'cls1';
  String vidPath = 'assets/videos/cls1.mp4';
  bool hasRope = false;
  bool hasMug = false;
  List<String> decisionlessNodes = ['cls3', 'tlt2', 'caf7',
                                    'tlt3', 'caf3', 'caf5',
                                    'caf6', 'lib3', 'lib5',
                                    'rft3', 'rft4', 'rft5', 
                                    'pof2', 'pof4', 'pof5'];

  bool showTextAndButtons = false;
  bool showSkip = false;

  late VideoPlayerController _videoController;
  late Duration vidDuration;
  late Completer<void> _delayCompleter;

  late AnimationController _opacityController;
  late Animation<double> opacityDecreaser;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeVideoPlayer();

    WidgetsBinding.instance.addPostFrameCallback((_){
      setState((){
        Node? current = decisionBox.get(1);        
        if(current != null){
          iD = current.iD;
          op1 = current.op1;
          op2 = current.op2;
          op3 = current.op3;
          situation = current.situation;
          decision = current.decision;
          op1Text = current.op1Text;
          op2Text = current.op2Text;
          op3Text = current.op3Text;
          sitID = current.vidPath;
          vidPath = 'assets/videos/${current.vidPath}.mp4';
        }
      });
    });
    startNodeCycle();
  }

  void startNodeCycle() async {
    if (_videoController.value.isInitialized) {
      await _videoController.pause();
      await _videoController.dispose();
    }
    await _initializeVideoPlayer();
    setState(() {
      showTextAndButtons = false;
      showSkip = true;
    });
    await _playVideo(); //Situation video starts playing
    await _opacityController.forward(); //Opacity is reduced to 0.3
    // _videoController.pause();
    setState(() {
      showTextAndButtons = true; //Prompt and options are shown
      showSkip = false;
    });
    // Wait for user input
  }

  Future<void> onOptionSelected(int option) async {
    setState(() {
      showTextAndButtons = false; //Prompt and options are hidden
      showSkip = true;
    });
    String opVidPath = '${vidPath.substring(0, vidPath.length - 4)}_$option${vidPath.substring(vidPath.length - 4)}';
    vidPath = opVidPath;
    _opacityController.reverse(); // Opacity animated back to 1.0
    await playOptionVideo();
  }

  Future<void> _playVideo() async {
    try {
      setState(() {});
      _videoController.setVolume(0);
      await _videoController.play(); // Play
      _delayCompleter = Completer<void>();
      bool isHandled = false;
      await Future.any([
        Future.delayed(vidDuration - const Duration(milliseconds: 200)).then((_) { // Video completes normally
          if (!isHandled) {
            isHandled = true;
          }
        }),
        _delayCompleter.future.then((_) { // Video is skipped
          if (!isHandled) {
            isHandled = true;
            _videoController.seekTo(vidDuration);
          }
        }),
      ]);

    } catch (e) {
      debugPrint("Error playing video: $e");
    }
  }

  void _skipVideo() {
    if (!_delayCompleter.isCompleted) {
      _delayCompleter.complete(); // Wait ended early
    }
  }

  Future<void> _initializeAnimations() async {
    _opacityController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    opacityDecreaser = Tween<double>(begin: 1.0, end: 0.3).animate(_opacityController);
    opacityDecreaser.addListener(() {setState((){});});
  }

  Future<void> _initializeVideoPlayer() async {
    _videoController = VideoPlayerController.asset(vidPath);
    try {
      await _videoController.initialize();
      _videoController.setLooping(false);
      _videoController.addListener(() {
        if (_videoController.value.position >= _videoController.value.duration) {
          _videoController.pause(); // Pause the video on the last frame
        }
      });
    } catch (e) {
      debugPrint("Error initializing video player: $e");
    }
    vidDuration = _videoController.value.duration;
  }
  
  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  Future<void> playOptionVideo() async {
    if (_videoController.value.isInitialized) {
      await _videoController.pause();
      await _videoController.dispose();
    }
    await _initializeVideoPlayer();
    await _playVideo();
    _videoController.pause();
  }

  void nodeUpdater(Node node) async {
    setState(() {
      iD = node.iD;
      op1 = node.op1;
      op2 = node.op2;
      op3 = node.op3;
      situation = node.situation;
      decision = node.decision;
      op1Text = node.op1Text;
      op2Text = node.op2Text;
      op3Text = node.op3Text;
      sitID = node.vidPath;
      vidPath = 'assets/videos/${node.vidPath}.mp4';
    });
  }

  Node situationChecker(int? prevID, Node node, int buttonID) {
    if (node.iD == 15 && hasMug){
      node.op3Text = "Hand the mug";
    }
    if (node.iD == 12 && hasMug){
      node.op2Text = "Hand the mug";
    }
    if (node.iD == 24 && hasRope){
      node.op3Text = "Go down with rope";
    }
    if (prevID == 9 && node.iD == 8){
      if (buttonID == 2){
        hasMug = true;
      } if (buttonID == 3){
        hasRope = true;
      }
      node.situation = "You're back at the hallway";
      node.op1Text = "-";
    }
    if ([34,35,36,37].contains(node.iD)){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GameOverPage(outcome: sitID)),
      );
    }
    return node;
  }

  Future<void> quizHandler() async {
    String outcome = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QuizPage()),
    );
    iD = 19;
    Node? nextNode = decisionBox.get(op1);
    nodeUpdater(nextNode!);
    if (outcome == 'failure'){
      opHandler(1);
    } else if (outcome == 'success'){
      opHandler(2);
    }
  }

  Future<void> opHandler(int op) async {
    List options = [op1, op2, op3];
    await onOptionSelected(op);
    if (iD == 18 && op == 1) {
      quizHandler();
      return;
    }
    setState((){
      int? prevID = decisionBox.get(iD)?.iD;
      Node? nextNode = decisionBox.get(options[op-1]);
      if (nextNode != null){
        nextNode = situationChecker(prevID, nextNode, op);
        nodeUpdater(nextNode);
        startNodeCycle();
      }
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

          // Text and button scaling factors
          final textFontSize = videoWidth * 0.034;
          final buttonSize = videoWidth * 0.15;
          final buttonSpacing = videoWidth * 0.012;

          return Center(
            child: Container(
              alignment: Alignment.center,
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: videoLeft,
                    top: videoTop,
                    width: videoWidth,
                    height: videoHeight,
                    child: Opacity(
                      opacity: opacityDecreaser.value,
                      child: _videoController.value.isInitialized
                        ? VideoPlayer(_videoController)
                        : Container(
                            color: Colors.black,
                        ),
                    ),
                  ),
                  if (showTextAndButtons)
                  Positioned(
                    left: videoLeft,
                    top: videoTop + videoHeight * 0.25,
                    width: videoWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        // Situation Text
                        Text(
                          situation,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.clip,
                          style: GoogleFonts.youngSerif(
                            textStyle: TextStyle(
                              fontSize: textFontSize,
                              letterSpacing: -2,
                              color: const Color(0xffffffff),
                            ),
                          ),
                        ),

                        // Spacing
                        SizedBox(height: videoHeight * 0.02), 

                        // Prompt Text
                        if (decision != "-")
                        Text(
                          decision,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontFamily: 'scrapbook',
                            fontSize: textFontSize * 1.5,
                            color: const Color(0xffffffff),
                          ),
                        ),

                        // Spacing
                        SizedBox(height: videoHeight * 0.01),

                        // Buttons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (op1Text != "-")
                            buildOptionButton(
                              sitID,
                              1,
                              op1Text,
                              buttonSize,
                              buttonSpacing,
                              () => opHandler(1),
                            ),
                            if (op2Text != "-")
                            buildOptionButton(
                              sitID,
                              2,
                              op2Text,
                              buttonSize,
                              buttonSpacing,
                              () => opHandler(2),
                            ),
                            if (op3Text != "-")
                            buildOptionButton(
                              sitID,
                              3,
                              op3Text,
                              buttonSize,
                              buttonSpacing,
                              () => opHandler(3),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Skip Button
                  if (showSkip)
                  Positioned(
                    right: videoLeft * 2,
                    top: videoTop + videoHeight*0.85,
                    child: OnHoverButton(
                      child: SizedBox(
                        width: buttonSize * 0.5,
                        height: buttonSize * 0.5,
                        child: GestureDetector(
                          onTap: _skipVideo,
                          child: Image.asset(
                            'assets/images/skip.png',
                            width: buttonSize * 0.4,
                            height: buttonSize * 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildOptionButton(
    String sitID,
    int optionIndex,
    String optionText,
    double buttonSize,
    double buttonSpacing,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: buttonSpacing),
        child: SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: OnHoverOptions(
            // ignore: sort_child_properties_last
            child: Image.asset(
                decisionlessNodes.contains(sitID) 
                ? 'assets/images/next.png'
                : 'assets/images/${sitID}_$optionIndex.png',
                fit: BoxFit.contain,
              ),
            overlayChild: Center(
              child: Text(
                optionText,
                textAlign: TextAlign.center,
                style: GoogleFonts.schoolbell(
                  fontSize: buttonSize * 0.1,
                  color: Colors.white,
                ),
              ),
            )
          ),
        ),
      ),
    );
  }
}
import 'dart:async';
import 'dart:math';
import 'package:base_app/main.dart';
import 'package:base_app/nodes/question.dart';
import 'package:base_app/widgets/on_hover_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return QuizPageState();
  }
}

class QuizPageState extends State<QuizPage> with SingleTickerProviderStateMixin {
  late int qIndex;
  String question = "";
  late int correct;
  late int opA;
  late int opB;
  late int opC;
  late int opD;
  List options = [];
  Set<int> indices = {};
  Random random = Random();
  int correctAnswers = 0;
  int timeLeft = 30;
  Timer? timer;
  List<int> paperOrder = [1, 2, 3, 4];
  List<int> prevOrder = [];

  bool showTextAndButtons = false;
  late VideoPlayerController _videoController;
  late Duration vidDuration;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      setState((){
        Question? current = quizBox.get(generateRandomIndex());        
        if(current != null){
          qIndex = current.iD;
          question = current.question;
          correct = current.correct;
          opA = current.opA;
          opB = current.opB;
          opC = current.opC;
          opD = current.opD;
          options = [opA, opB, opC, opD];
        }
        startQuiz();
      });
    });
  }

  Future<void> startQuiz() async {
    //Opening video
    _videoController = VideoPlayerController.asset('assets/videos/quiz1.mp4');
    try {
      await _videoController.initialize();
    } catch (e) {
      debugPrint("Error initializing video player: $e");
    }
    vidDuration = _videoController.value.duration;
    await playVideo();

    //Loop quiz
    await _videoController.dispose();
    _videoController = VideoPlayerController.asset('assets/videos/quiz2.mp4');
    try {
      await _videoController.initialize();
      _videoController.setVolume(0);
      _videoController.setLooping(true);
      _videoController.play();
      setState(() {
        startTimer();
        showTextAndButtons = true;
      });
    } catch (e) {
      debugPrint("Error initializing video player: $e");
    }
  }

  Future<void> playVideo() async {
    try {
      setState(() {});
      _videoController.setVolume(0);
      await _videoController.play();
      await Future.delayed(vidDuration + const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint("Error playing video: $e");
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          timer.cancel();
          endQuiz();
        }
      });
    });
  }

  void questionUpdater(Question quest){
    qIndex = quest.iD;
    question = quest.question;
    correct = quest.correct;
    opA = quest.opA;
    opB = quest.opB;
    opC = quest.opC;
    opD = quest.opD;
    options = [opA, opB, opC, opD];
    prevOrder = List.from(paperOrder);
    while (listEquals(prevOrder, paperOrder)){
      paperOrder.shuffle();
    }
  }

  int generateRandomIndex(){
    int curr = -1;
    while (!indices.contains(curr)){
      int randomIndex = random.nextInt(10) + 1;
      curr = randomIndex;
      if (!indices.contains(curr)){
        indices.add(randomIndex);
      } else if (indices.length == 10){
        return 11;
      } else {
        curr  = -1;
      }
    }
    return curr;
  }

  void checkAnswer(int selectedOption) {
    if (selectedOption == correct) {
      correctAnswers++;
      if (correctAnswers >= 5) {
        endQuiz();
        return;
      }
    }
    setState(() {
      Question? nextQuestion = quizBox.get(generateRandomIndex());
      if (nextQuestion != null){
        questionUpdater(nextQuestion);
      } else {
        endQuiz();
      }
    });
  }

  Future<void> endQuiz() async {
    timer?.cancel();
    String outcome = correctAnswers >= 5 ? 'success' : 'failure';
    //Closing video
    await _videoController.dispose();
    setState(() {
      showTextAndButtons = false;     
    });
    if (outcome == 'success'){
      _videoController = VideoPlayerController.asset('assets/videos/success.mp4');
    } else {
      _videoController = VideoPlayerController.asset('assets/videos/failure.mp4');
    }
    try {
      await _videoController.initialize();
    } catch (e) {
      debugPrint("Error initializing video player: $e");
    }
    vidDuration = _videoController.value.duration;
    if (_videoController.value.isInitialized) {
      setState(() {});
      _videoController.setVolume(0);
      await _videoController.play();
      await Future.delayed(vidDuration - const Duration(milliseconds: 500));
    } else {
      debugPrint("Video player is not initialized");
    }
    // ignore: use_build_context_synchronously
    Navigator.pop(context, outcome);
  }
  
  void disposeTimer() {
    timer?.cancel();
    super.dispose();
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
          final questionFontSize = videoHeight * 0.1;
          final buttonTextFontSize = videoHeight * 0.04;
          final timeLeftFontSize = videoHeight * 0.25;
          final buttonWidth = videoWidth * 0.18;
          final buttonHeight = buttonWidth * (17 / 31);

          return Stack(
            children: [
              Positioned(
                left: videoLeft,
                top: videoTop,
                width: videoWidth,
                height: videoHeight,
                child: _videoController.value.isInitialized
                  ? VideoPlayer(_videoController)
                  : Container(
                      color: Colors.black,
                ),
              ),

              // Prompt, timer and options
              if (showTextAndButtons)
              Positioned(
                left: videoLeft,
                top: videoTop,
                width: videoWidth,
                height: videoHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Question
                    Text(
                      question,
                      style: GoogleFonts.youngSerif(
                        textStyle: TextStyle(
                          fontSize: questionFontSize,
                          letterSpacing: -2,
                          color: const Color(0xffffffff),
                          shadows: const [
                            Shadow(
                              offset: Offset(15.0, 10.0),
                              blurRadius: 5.0,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),
                    
                    // Options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ...List.generate(4, (index) {
                          return OnHoverButton(
                            child: GestureDetector(
                              onTap: () => checkAnswer(index),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/ans${paperOrder[index]}.png',
                                    width: buttonWidth,
                                    height: buttonHeight,
                                    fit: BoxFit.cover,
                                  ),
                                  Center(
                                    child: Text(
                                      options[index].toString(),
                                      style: GoogleFonts.schoolbell(
                                        fontSize: buttonTextFontSize,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        })
                      ],
                    ),
                    
                    // Timer
                    Text(
                      timeLeft.toString(),
                      style: TextStyle(
                        fontFamily: 'scrapbook',
                        fontStyle: FontStyle.normal,
                        fontSize: timeLeftFontSize,
                        color: const Color(0xffffffff),
                        shadows: const [
                          Shadow(
                            offset: Offset(15.0, 15.0),
                            blurRadius: 4.0,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
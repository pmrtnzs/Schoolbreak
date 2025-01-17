import 'dart:core';
import 'package:base_app/pages/intro_page.dart';
import 'nodes/question.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'nodes/node.dart';
import 'package:hive_flutter/adapters.dart';

late Box<Node> decisionBox;
late Box<Question> quizBox;

Future<void> initializeDatabases() async {
  await decisionBox.clear();
  await quizBox.clear();

  // Decision map
  String decisionCsv = "assets/maps/decision_map.csv";
  String decisionFileData = await rootBundle.loadString(decisionCsv);
  List<String> decisionRows = decisionFileData.split("\n");

  for (int i = 0; i < decisionRows.length; i++) {
    String row = decisionRows[i];
    List<String> itemInRow = row.split(",");
    Node node = Node(
      int.parse(itemInRow[0]),
      int.parse(itemInRow[1]),
      int.parse(itemInRow[2]),
      int.parse(itemInRow[3]),
      itemInRow[4],
      itemInRow[5],
      itemInRow[6],
      itemInRow[7],
      itemInRow[8],
      itemInRow[9],
    );
    int key = int.parse(itemInRow[0]);
    decisionBox.put(key, node);
  }

  // Quiz questions
  String quizCsv = "assets/maps/math_questions.csv";
  String quizFileData = await rootBundle.loadString(quizCsv);
  List<String> quizRows = quizFileData.split("\n");

  for (int i = 0; i < quizRows.length; i++) {
    String row = quizRows[i];
    List<String> itemInRow = row.split(",");
    Question question = Question(
      int.parse(itemInRow[0]),
      itemInRow[1],
      int.parse(itemInRow[2]),
      int.parse(itemInRow[3]),
      int.parse(itemInRow[4]),
      int.parse(itemInRow[5]),
      int.parse(itemInRow[6]),
    );
    int key = int.parse(itemInRow[0]);
    quizBox.put(key, question);
  }
}

Future<void> resetDatabases() async {
  await initializeDatabases();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(NodeAdapter());
  Hive.registerAdapter(QuestionAdapter());
  decisionBox = await Hive.openBox<Node>('decisionMap');
  quizBox = await Hive.openBox<Question>('mathQuestions');
  await initializeDatabases();

  runApp(const RestartWidget(child: MyApp()));
}

class RestartWidget extends StatefulWidget {
  final Widget child;
  const RestartWidget({super.key, required this.child});
  static void restartApp(BuildContext context) {
    final _RestartWidgetState? state =
        context.findAncestorStateOfType<_RestartWidgetState>();
    state?.restartApp();
  }
  @override
  // ignore: library_private_types_in_public_api
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key _key = UniqueKey();

  void restartApp() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: IntroPage(), // Start the app in the intro page
    );
  }
}
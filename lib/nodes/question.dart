import 'package:hive/hive.dart';
part 'question.g.dart';

@HiveType(typeId: 1)
class Question {
  @HiveField(0)
  int iD;

  @HiveField(1)
  String question;

  @HiveField(2)
  int correct;

  @HiveField(3)
  int opA;
  
  @HiveField(4)
  int opB;

  @HiveField(5)
  int opC;

  @HiveField(6)
  int opD;

  Question(this.iD, this.question, this.correct, this.opA,
  this.opB, this.opC, this.opD);
}
import 'package:hive/hive.dart';
part 'node.g.dart';

@HiveType(typeId: 0)
class Node {
  @HiveField(0)
  int iD;

  @HiveField(1)
  int op1;

  @HiveField(2)
  int op2;

  @HiveField(3)
  int op3;
  
  @HiveField(4)
  String situation;

  @HiveField(5)
  String decision;

  @HiveField(6)
  String op1Text;

  @HiveField(7)
  String op2Text;

  @HiveField(8)
  String op3Text;

  @HiveField(9)
  String vidPath;

  Node(this.iD, this.op1, this.op2, this.op3,
  this.situation, this.decision, this.op1Text,
  this.op2Text, this.op3Text, this.vidPath);
}
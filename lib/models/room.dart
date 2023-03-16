import 'package:scribble/models/message.dart';

class Room {
  String roomId;
  String roomName;
  dynamic roomPlayers;
  List<dynamic> roomMessages;
  int currentTurn;
  String currentTurnPID;
  String currentChosenWord;
  bool gameStarted;
  dynamic createdBy;

  Room(
      {required this.roomId,
      required this.roomName,
      required this.roomPlayers,
      required this.roomMessages,
      required this.currentTurnPID,
      required this.currentTurn,
      required this.currentChosenWord,
      required this.gameStarted,
      required this.createdBy});
}

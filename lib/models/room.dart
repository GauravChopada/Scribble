class Room {
  String roomId;
  String roomName;
  dynamic roomPlayers;
  dynamic roomMessages;
  int currentTurn;
  String currentChosenWord;
  bool gameStarted;
  dynamic createdBy;

  Room(
      {required this.roomId,
      required this.roomName,
      required this.roomPlayers,
      required this.roomMessages,
      required this.currentTurn,
      required this.currentChosenWord,
      required this.gameStarted,
      required this.createdBy});
}

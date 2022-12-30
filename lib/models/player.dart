class Player {
  final String playerName;
  final String socketId;
  final String room;

  Player({
    required this.playerName,
    required this.room,
    required this.socketId,
  });

  // factory Player.fromJson(Map<String, dynamic> player) {
  //   return Player(
  //       // playerName: player['playerName'],
  //       room: player['roomId']
  //       // socketId: player['socketId']
  //       );
  // }
}

import 'package:flutter/foundation.dart';
import '../models/player.dart';

class roomProvider extends ChangeNotifier {
  final List<Player> _players = [];

  List<Player> get players => _players;

  addNewPlayer(String player) {
    final dataList = player.split(":");
    print("---- " + dataList.toString());
    print("triggered");

    _players.add(Player(
        playerName: dataList[2], room: dataList[1], socketId: dataList[0]));
    // _players.add(Player(
    //     // playerName: player['playerName'],
    //     room: player['roomId']
    //     // socketId: player['socketId']
    //     ));
    print(players);
    notifyListeners();
  }

  refreshPlayersData(String playersData) {
    final dataList = playersData.split(":");
    print("---- " + dataList.toString());
    var i = 0;
    _players.clear();
    print(dataList.length);
    while (i < dataList.length - 1)
      _players.add(Player(
          playerName: dataList[i++],
          room: dataList[i++],
          socketId: dataList[i++]));
    print(players);
    notifyListeners();
  }
}

// class roomProvider extends ChangeNotifier {
//   String _msg = '';

//   String get msg => _msg;

//   setMsg(String message) {
//     _msg = message;
//     notifyListeners();
//   }
// }

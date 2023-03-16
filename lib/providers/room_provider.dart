import 'package:flutter/foundation.dart';
import 'package:scribble/models/message.dart';
import 'package:scribble/models/whiteBoardCredentials.dart';
import '../models/player.dart';
import '../models/room.dart';
import 'dart:convert';

class roomProvider extends ChangeNotifier {
  Room? _currentRoom = null;
  Room? get currentRoom => _currentRoom;

  roomCreated(payload) {
    _currentRoom = Room(
        roomId: payload["roomId"],
        roomName: payload["roomName"],
        createdBy: payload["createdBy"],
        currentChosenWord: payload["currentChosenWord"],
        currentTurnPID: payload["currentTurnPID"],
        currentTurn: payload["currentTurn"],
        gameStarted: payload["gameStarted"],
        roomMessages: payload["roomMessages"],
        roomPlayers: payload["roomPlayers"]);
    notifyListeners();
  }

  roomJoined(payload) {
    _currentRoom = Room(
        roomId: payload["roomId"],
        roomName: payload["roomName"],
        currentTurnPID: payload["currentTurnPID"],
        createdBy: payload["createdBy"],
        currentChosenWord: payload["currentChosenWord"],
        currentTurn: payload["currentTurn"],
        gameStarted: payload["gameStarted"],
        roomMessages: payload["roomMessages"],
        roomPlayers: payload["roomPlayers"]);
    // print(_currentRoom.roomId);
    notifyListeners();
  }

  refreshPlayersData(payload) {
    currentRoom!.roomPlayers = payload;
    notifyListeners();
  }

  clearRoomData() {
    _currentRoom = null;
    notifyListeners();
  }

  setCurrentTurn(payload) {
    currentRoom!.currentTurn = payload["currentTurnIndex"];
    currentRoom!.currentTurnPID = payload["currentTurnPID"];
    // print("curentTurn" + currentRoom!.currentTurnPID.toString());
    notifyListeners();
  }

  setChosenWord(payload) {
    currentRoom!.currentChosenWord = payload;
    notifyListeners();
  }

  addMessage(payload) {
    currentRoom!.roomMessages.add(Message(
      playerName: payload["playerName"],
      message: payload["message"],
    ));
    notifyListeners();
  }

  whiteBoardCredentials? _whiteboardCredentials = null;

  whiteBoardCredentials? get whiteboardCredentials => _whiteboardCredentials;

  setWhiteboardCredentials(payload) {
    _whiteboardCredentials = whiteBoardCredentials(
        sdkToken: payload["sdkToken"],
        roomUUID: payload["roomUUID"],
        roomToken: payload["roomToken"]);
    notifyListeners();
  }
  // final List<Player> _players = [];

  // List<Player> get players => _players;

  // addNewPlayer(String player) {
  //   final dataList = player.split(":");
  //   print("---- " + dataList.toString());
  //   print("triggered");

  //   _players.add(Player(
  //       playerName: dataList[2], room: dataList[1], socketId: dataList[0]));
  //   // _players.add(Player(
  //   //     // playerName: player['playerName'],
  //   //     room: player['roomId']
  //   //     // socketId: player['socketId']
  //   //     ));
  //   print(players);
  //   notifyListeners();
  // }
}

// class roomProvider extends ChangeNotifier {
//   String _msg = '';

//   String get msg => _msg;

//   setMsg(String message) {
//     _msg = message;
//     notifyListeners();
//   }
// }

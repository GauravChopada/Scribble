import 'package:flutter/material.dart';
import 'package:scribble/models/message.dart';

class gameProvider extends ChangeNotifier {
  String _msg = '';
  String _sdkToken = '';
  String _roomToken = '';
  String currentTurn = '';
  String selectedWord = '';
  bool yourTurn = false;

  List<Message> _messages = [];

  String get msg => _msg;
  String get sdkToken => _sdkToken;
  String get roomToken => _roomToken;
  List<Message> get messages => _messages;

  addNewMessage(String message) {
    final dataList = message.split(":");
    print("addNewMessage triggered");
    print("---- " + dataList.toString());

    _messages.add(Message(msg: dataList[1], sender: dataList[0]));
    notifyListeners();
  }

  emptyMessages() {
    _messages = [];
  }

  setMsg(String message) {
    _msg = message;
    notifyListeners();
  }

  getSdkToken() {
    return _sdkToken;
  }

  getCurrentTurn() {
    return currentTurn;
  }

  isYourTurn() {
    return yourTurn;
  }

  getRoomToken() {
    return _roomToken;
  }

  getselectedWord() {
    return selectedWord;
  }

  setSdkToken(String token) {
    _sdkToken = token;
    print(_sdkToken);
    notifyListeners();
  }

  setRoomToken(String token) {
    _roomToken = token;
    print(_roomToken);
    notifyListeners();
  }

  setselectedWord(String word) {
    selectedWord = word;
    notifyListeners();
  }

  setCurrentTurn(String data, String socketId) {
    final datas = data.split(":");
    String pName = datas[0];
    String sId = datas[1];
    if (sId == socketId) {
      yourTurn = true;
      currentTurn = pName;
    } else {
      currentTurn = pName;
      yourTurn = false;
    }
    notifyListeners();
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:fastboard_flutter/fastboard_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import '../providers/game_provider.dart';

class gameScreen extends StatefulWidget {
  final IO.Socket socket;
  final String roomId;
  gameScreen({Key? key, required this.socket, required this.roomId})
      : super(key: key);

  @override
  State<gameScreen> createState() => _gameScreenState();
}

class _gameScreenState extends State<gameScreen> {
  var appId = "JlxeUIFeEe2GMacFOTzEqQ/3CFWFaY_cU4zxw";
  var roomUUID = "";
  var roomToken = "";
  var selectedWord = '';
  var SDKTOKEN =
      "NETLESSSDK_YWs9RzhDNWRCR0RPUDhsZFVWbyZub25jZT1kZjFhOWI2MC04NWFlLTExZWQtYTZiNi1kMWMxNDFkZWRiMjYmcm9sZT0wJnNpZz03ZTk1MTVhNjk2MDcyYzFjNGNhNjllZjAyMTgzMzBkMmUxMGQ2ZWM0MDgxZTNkN2UwMzNmY2Q5YmY0ZjQ4YjRk";
  var _isLoading2 = true;
  var _isLoading1 = true;
  var _isFastRoomCompleted = false;

  int seconds = 20;
  Timer? timer;
  Completer<FastRoomController> controllerCompleter = Completer();
  final textFieldController = TextEditingController();
  late FastRoomController fastRoomController;
  GlobalKey _fastRoomKey = new GlobalKey();

  startTimer() {
    seconds = 20;
    Provider.of<gameProvider>(context, listen: false).emptyMessages();
    Provider.of<gameProvider>(context, listen: false)
        .addNewMessage(":New game started");

    if (_isFastRoomCompleted) {
      if (Provider.of<gameProvider>(context, listen: false).yourTurn) {
        fastRoomController.cleanScene();
        fastRoomController.setWritable(true);
      } else
        fastRoomController.setWritable(false);
    }

    timer = Timer.periodic(Duration(seconds: 1), (_t) {
      setState(() {
        if (seconds == 0) {
          widget.socket.emit("nextTurn");
          timer?.cancel();
          selectedWord = '';
        } else {
          seconds--;
        }
      });
    });
  }

  Future<String> showWordChooseDialog() async {
    return await showDialog(
      context: context,
      builder: (context) {
        return new AlertDialog(
          title: Text("Choose one Word"),
          actions: [
            Column(
              children: [
                TextButton(
                    onPressed: () {
                      selectedWord = "Horse";
                      widget.socket.emit(
                          "choseWord", selectedWord + ":" + widget.roomId);

                      Navigator.of(context).pop();
                    },
                    child: Text("Horse")),
                TextButton(
                    onPressed: () {
                      selectedWord = "Horse";
                      widget.socket.emit("choseWord", selectedWord);
                      Navigator.of(context).pop();
                    },
                    child: Text("Horse")),
                TextButton(
                    onPressed: () {
                      selectedWord = "Horse";
                      widget.socket.emit("choseWord", selectedWord);
                      Navigator.of(context).pop();
                    },
                    child: Text("Horse")),
                TextButton(
                    onPressed: () {
                      selectedWord = "Horse";
                      widget.socket.emit("choseWord", selectedWord);
                      Navigator.of(context).pop();
                    },
                    child: Text("Horse")),
              ],
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.socket.emit("getSdkToken");

    widget.socket.on("getSdkTokenResponse",
        (data) => {
              print("...................getSdkTokenResponse : " + data),
              Provider.of<gameProvider>(context, listen: false)
                  .setSdkToken(data.toString()),
              print("gameProvider().sdkToken : " +
                  Provider.of<gameProvider>(context, listen: false)
                      .getSdkToken()),
              getRooomUUID(SDKTOKEN)
            });

    widget.socket.on("getRoomTokenResponse",
        (data) => {
              print("...................getRoomTokenResponse : " + data),
              Provider.of<gameProvider>(context, listen: false)
                  .setRoomToken(data.toString()),
              widget.socket.emit("startGame", widget.roomId),
              setState(() {
                roomToken = Provider.of<gameProvider>(context, listen: false)
                    .getRoomToken();
                print("room Token ++++++++++++++++++++++" + roomToken);
              }),
              _isLoading1 = false
            });

    widget.socket.on("startGameResponse",
        (data) => {
              print("got startGameResponse... + " + data.toString()),
              Provider.of<gameProvider>(context, listen: false)
                  .setCurrentTurn(data, widget.socket.id.toString()),
            });

    widget.socket.on("nextTurnResponse",
        (data) => {
              print("got nextTurnResponse...+ " + data.toString()),
              Provider.of<gameProvider>(context, listen: false)
                  .setCurrentTurn(data, widget.socket.id.toString()),
              startTimer(),
            });

    widget.socket.on("choseWordResponse",
        (data) => {
              print("got choseWordResponse...+ " + data.toString()),
              Provider.of<gameProvider>(context, listen: false)
                  .setselectedWord(data),
            });

    widget.socket.on("receiveMessage",
        (data) => {
              Provider.of<gameProvider>(context, listen: false)
                  .addNewMessage(data),
            });
  }

  void getRooomUUID(String sdkToken) async {
    print("getRooomUUID : " + sdkToken);

    var response = await http.post(Uri.https('api.netless.link', 'v5/rooms'),
        headers: {'token': sdkToken.toString(), 'region': 'in-mum'});
    var jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
    print('Response referencestatus: ${response.statusCode}');
    print('Response body: ${response.body}');
    print("UUID: " + jsonResponse['uuid']);
    roomUUID = jsonResponse['uuid'];
    widget.socket.emit("getRoomToken", roomUUID);
  }

  Future<void> onFastRoomCreated(FastRoomController controller) async {
    _isLoading2 = false;
    startTimer();
    controllerCompleter.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading1
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Stack(children: [
                Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      width: MediaQuery.of(context).size.width,
                      child: FastRoomView(
                        fastRoomOptions: FastRoomOptions(
                          appId: appId,
                          uuid: roomUUID,
                          token: roomToken,
                          uid: widget.socket.id.toString(),
                          writable: true,
                          fastRegion: FastRegion.in_mum,
                        ),
                        onFastRoomCreated: onFastRoomCreated,
                        useDarkTheme: false,
                      ),
                    ),
                    Spacer()
                  ],
                ),
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: FutureBuilder<FastRoomController>(
                      future: controllerCompleter.future,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          _isFastRoomCompleted = true;
                          fastRoomController = snapshot.data!;

                          return Column(
                            children: [
                              Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10))),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Consumer<gameProvider>(
                                      builder: (context, provider, child) {
                                        if (provider.yourTurn == true) {
                                          return selectedWord == ''
                                              ? Row(
                                                  children: [
                                                    Icon(
                                                      Icons.arrow_right_rounded,
                                                      size: 50,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      "Your turn",
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    TextButton(
                                                        onPressed:
                                                            showWordChooseDialog,
                                                        child: Text(
                                                          "Choose word",
                                                        )),
                                                  ],
                                                )
                                              : Row(
                                                  children: [
                                                    Icon(
                                                      Icons.arrow_right_rounded,
                                                      size: 50,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      "Your turn          ",
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      selectedWord,
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                );
                                        } else
                                          return Row(
                                            children: [
                                              Icon(
                                                Icons.arrow_right_rounded,
                                                size: 50,
                                                color: Colors.white,
                                              ),
                                              Text(
                                                Provider.of<gameProvider>(
                                                            context,
                                                            listen: false)
                                                        .getCurrentTurn() +
                                                    "'s turn",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          );
                                      },
                                    ),
                                    Spacer(),
                                    Container(
                                      child: Text(
                                        "Timer: " + seconds.toString(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                color: Colors.black,
                                child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 5),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10))),
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
                                    child: Consumer<gameProvider>(
                                        builder: (context, provider, child) {
                                      return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              alignment: Alignment.topLeft,
                                              padding: EdgeInsets.only(
                                                  top: 5, left: 5),
                                              child: Text("Chat",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            Container(
                                              height: provider.yourTurn == true
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.3 *
                                                      0.8
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.3 *
                                                      0.45,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8),
                                              alignment: Alignment.topLeft,
                                              child: Consumer<gameProvider>(
                                                  builder: (_, provider, __) {
                                                print(provider.messages);
                                                return ListView.separated(
                                                  separatorBuilder:
                                                      (context, index) =>
                                                          SizedBox(
                                                    height: 3,
                                                  ),
                                                  itemCount:
                                                      provider.messages.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final player = provider
                                                        .messages[index];
                                                    return player.msg.contains(
                                                                "guessed correct word") ||
                                                            player.msg ==
                                                                "New game started"
                                                        ? Center(
                                                            child: Text(
                                                              player.msg,
                                                              style: TextStyle(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          2,
                                                                          198,
                                                                          24)),
                                                            ),
                                                          )
                                                        : Container(
                                                            child: Row(
                                                            children: [
                                                              Text(
                                                                player.sender +
                                                                    " :  ",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Text(player.msg)
                                                            ],
                                                          ));
                                                  },
                                                );
                                              }),
                                            ),

                                            if (provider.yourTurn != true)
                                              Container(
                                                child: TextField(
                                                  controller:
                                                      textFieldController,
                                                  decoration: InputDecoration(
                                                      hintText: 'Enter message',
                                                      focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Colors
                                                                  .deepPurple,
                                                              width: 2.0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                      border: OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .black,
                                                                  width: 2.0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                      suffixIcon: IconButton(
                                                        icon: Icon(
                                                          Icons.send_rounded,
                                                          color:
                                                              Colors.deepPurple,
                                                        ),
                                                        onPressed: () {
                                                          widget.socket.emit(
                                                              "sendMessage", {
                                                            "roomId":
                                                                widget.roomId,
                                                            "message":
                                                                textFieldController
                                                                    .text
                                                                    .trim()
                                                          });
                                                          textFieldController
                                                              .clear();
                                                        },
                                                      )),
                                                ),
                                              )

                                            // })
                                          ]);
                                    })),
                              ),
                            ],
                          );
                        } else {
                          return Container(
                            child: Text("Wait...."),
                          );
                        }
                      }),
                ),
                if (_isLoading2)
                  Container(
                    color: Colors.white,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Center(child: CircularProgressIndicator()),
                  )
              ]),
            ),
    );
  }
}

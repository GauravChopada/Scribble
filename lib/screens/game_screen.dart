import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:scribble/models/whiteBoardCredentials.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:fastboard_flutter/fastboard_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import '../providers/game_provider.dart';
import 'dart:math';
import 'package:scribble/providers/room_provider.dart';
import 'dart:convert';

class gameScreen extends StatefulWidget {
  static const Routename = '/gameScreen';
  final IO.Socket socket;
  // String roomId = "";
  gameScreen({
    Key? key,
    required this.socket,
  }) : super(key: key);

  @override
  State<gameScreen> createState() => _gameScreenState();
}

class _gameScreenState extends State<gameScreen> {
  var selectedWord = '';
  var _isLoading1 = true;
  var response;
  int seconds = 10;
  Timer? timer;
  final textFieldController = TextEditingController();
  bool isAdmin = false;
  late String roomId;

  final words = [
    "book",
    "chair",
    "table",
    "lamp",
    "clock",
    "vase",
    "picture",
    "rug",
    "cabinet",
    "mirror",
    "sofa",
    "stool",
    "drawer",
    "frame",
    "shelves",
    "ottoman",
    "painting",
    "basket",
    "statue",
    "carpet",
    "tray",
    "curtain",
    "cushion",
    "plant",
    "teapot",
    "glass",
    "dish",
    "sculpture",
    "pot",
    "bowl",
    "jug",
    "box",
    "cup",
    "fork",
    "spoon",
    "knife",
    "plate",
    "saucer",
    "pan",
    "skillet",
    "griddle",
    "blender",
    "mixer",
    "food processor",
    "toaster",
    "microwave",
    "oven",
    "refrigerator",
    "freezer",
    "dishwasher",
    "washing machine",
    "dryer",
    "iron",
    "vacuum cleaner",
    "mop",
    "broom",
    "dustpan",
    "bucket",
    "scrubber",
    "sponge",
    "cloth",
    "towel",
    "trash can",
    "garbage disposal",
    "sink",
    "faucet",
    "toilet",
    "shower",
    "bathtub",
    "towel rack",
    "soap dish",
    "toilet paper holder",
    "medicine cabinet",
    "tissue box",
    "toothbrush holder",
    "razor holder",
    "hair dryer",
    "hairbrush",
    "comb",
    "mirror",
    "scale",
    "candle",
    "incense burner",
    "potpourri jar",
    "oil diffuser",
    "room spray",
    "air freshener",
    "dehumidifier",
    "humidifier",
    "fan",
    "heater",
    "air conditioner"
  ];

  List<String> getFourRandomWords() {
    List<String> randomWords = [];

    for (int i = 0; i < 4; i++) {
      int randomIndex = Random().nextInt(words.length);
      String randomWord = words[randomIndex];
      randomWords.add(randomWord);
      words.removeAt(randomIndex);
    }

    return randomWords;
  }

  showSnackBar(String message, Color color) {
    return SnackBar(
      backgroundColor: color,
      closeIconColor: Colors.white,
      showCloseIcon: true,
      content: Text(message),
    );
  }

  startTimer() {
    seconds = 20;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (seconds == 0) {
          if (isAdmin) {
            widget.socket.emit("/nextTurn", {"roomId": roomId});
          }
          timer.cancel();
          selectedWord = '';
        } else {
          seconds--;
        }
      });
    });
  }

  Future<String> showWordChooseDialog() async {
    final randomWords = getFourRandomWords();
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Choose one Word"),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      selectedWord = randomWords[0];
                      widget.socket.emit("/chooseWord",
                          {"roomId": roomId, "chosenWord": randomWords[0]});

                      Navigator.of(context).pop();
                    },
                    child: Text(randomWords[0])),
                TextButton(
                    onPressed: () {
                      selectedWord = randomWords[1];
                      widget.socket.emit("/chooseWord",
                          {"roomId": roomId, "chosenWord": randomWords[1]});

                      Navigator.of(context).pop();
                    },
                    child: Text(randomWords[1])),
                TextButton(
                    onPressed: () {
                      selectedWord = randomWords[2];
                      widget.socket.emit("/chooseWord",
                          {"roomId": roomId, "chosenWord": randomWords[2]});

                      Navigator.of(context).pop();
                    },
                    child: Text(randomWords[2])),
                TextButton(
                    onPressed: () {
                      selectedWord = randomWords[3];
                      widget.socket.emit("/chooseWord",
                          {"roomId": roomId, "chosenWord": randomWords[3]});

                      Navigator.of(context).pop();
                    },
                    child: Text(randomWords[3])),
              ],
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    widget.socket.on(
        "/getWhiteboardCredentialsResponse",
        (payload) => {
              response = json.decode(payload),
              if (response["status"] == 200)
                {
                  Provider.of<roomProvider>(context, listen: false)
                      .setWhiteboardCredentials(
                          response["whiteboardCredentials"]),
                  isAdmin = Provider.of<roomProvider>(context, listen: false)
                          .currentRoom!
                          .createdBy["playerSocketId"] ==
                      widget.socket.id,
                  roomId = Provider.of<roomProvider>(context, listen: false)
                      .currentRoom!
                      .roomId,

                  if (isAdmin)
                    {
                      widget.socket.emit("/nextTurn", {"roomId": roomId}),
                    },
                  setState(() {
                    _isLoading1 = false;
                  }),
                  // startTimer(),
                }
              else
                {
                  ScaffoldMessenger.of(context).showSnackBar(showSnackBar(
                      "Error.. Could not get whiteboard credentials",
                      Colors.red))
                }
            });

    widget.socket.on(
        "/nextTurnResponse",
        (payload) => {
              response = json.decode(payload),
              if (response["status"] == 200)
                {
                  Provider.of<roomProvider>(context, listen: false)
                      .setCurrentTurn(response["nextTurnDetails"]),
                  startTimer()
                }
              else
                {
                  ScaffoldMessenger.of(context).showSnackBar(showSnackBar(
                      "Error.. Could not get next turn data.", Colors.red))
                }
            });

    widget.socket.on(
        "/wordChoseResponse",
        (payload) => {
              response = json.decode(payload),
              if (response["status"] == 200)
                {
                  // print(response["playerTurn"]),
                  Provider.of<roomProvider>(context, listen: false)
                      .setChosenWord(response["chosenWord"]),
                }
              else
                {
                  ScaffoldMessenger.of(context).showSnackBar(showSnackBar(
                      "Error.. Could not get choosen word.", Colors.red))
                }
            });

    widget.socket.on(
        "/sendMessageResponse",
        (payload) => {
              response = json.decode(payload),
              if (response["status"] == 200)
                {
                  Provider.of<roomProvider>(context, listen: false)
                      .addMessage(response["message"]),
                }
              else
                {
                  ScaffoldMessenger.of(context).showSnackBar(showSnackBar(
                      "Error.. Could not get message.", Colors.red))
                }
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading1
          ? Center(
              child: const CircularProgressIndicator(),
            )
          : Container(
              child: Stack(children: [
                Column(
                  children: [
                    Selector<roomProvider, whiteBoardCredentials?>(
                        builder: (context, credentials, __) {
                          return credentials == null
                              ? Container()
                              : Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
                                  width: MediaQuery.of(context).size.width,
                                  child: Text("whiteboard"),
                                  color: Colors.red,
                                );
                        },
                        selector: (_, provider) =>
                            provider.whiteboardCredentials),
                    Spacer()
                  ],
                ),
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: [
                      Spacer(),
                      Container(
                        decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10))),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Consumer<roomProvider>(
                              builder: (context, provider, child) {
                                var currentTurn =
                                    provider.currentRoom!.roomPlayers[provider
                                        .currentRoom!
                                        .currentTurn]["playerName"];

                                if (provider.currentRoom!.currentTurnPID ==
                                    widget.socket.id) {
                                  return selectedWord == ''
                                      ? Row(
                                          children: [
                                            const Icon(
                                              Icons.arrow_right_rounded,
                                              size: 50,
                                              color: Colors.white,
                                            ),
                                            const Text(
                                              "Your turn",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            TextButton(
                                                onPressed: showWordChooseDialog,
                                                child: const Text(
                                                  "Choose word",
                                                )),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            const Icon(
                                              Icons.arrow_right_rounded,
                                              size: 50,
                                              color: Colors.white,
                                            ),
                                            const Text(
                                              "Your turn          ",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              selectedWord,
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        );
                                } else {
                                  return Row(
                                    children: [
                                      const Icon(
                                        Icons.arrow_right_rounded,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        currentTurn + "'s turn",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                            Spacer(),
                            Container(
                              child: Text(
                                "Timer: $seconds",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            )
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.black,
                        child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10))),
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: Consumer<roomProvider>(
                                builder: (context, provider, child) {
                              final roomMessages =
                                  provider.currentRoom!.roomMessages;
                              return Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      alignment: Alignment.topLeft,
                                      padding: EdgeInsets.only(top: 5, left: 5),
                                      child: const Text("Chat",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    Container(
                                        height: provider.currentRoom!
                                                    .currentTurnPID ==
                                                widget.socket.id
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
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        alignment: Alignment.topLeft,
                                        child: ListView.separated(
                                          separatorBuilder: (context, index) =>
                                              const SizedBox(
                                            height: 3,
                                          ),
                                          itemCount: roomMessages.length,
                                          itemBuilder: (context, index) {
                                            final player = roomMessages[index];
                                            return player.message ==
                                                    "New game started"
                                                ? Center(
                                                    child: Text(
                                                      player.message,
                                                      style: const TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 2, 198, 24)),
                                                    ),
                                                  )
                                                : player.message.contains(
                                                        "guessed correct word")
                                                    ? Center(
                                                        child: Text(
                                                          player.playerName +
                                                              " " +
                                                              player.message,
                                                          style:
                                                              const TextStyle(
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
                                                            player.playerName +
                                                                " :  ",
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text(player.message)
                                                        ],
                                                      ));
                                          },
                                        )),
                                    if (provider.currentRoom!.currentTurnPID !=
                                        widget.socket.id)
                                      Container(
                                        child: TextField(
                                          controller: textFieldController,
                                          onSubmitted: (_) => {
                                            widget.socket.emit("/sendMessage", {
                                              "roomId": roomId,
                                              "message": textFieldController
                                                  .text
                                                  .trim()
                                            }),
                                            textFieldController.clear(),
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Enter message',
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.deepPurple,
                                                    width: 2.0),
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            border: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 2.0),
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            suffixIcon: IconButton(
                                              icon: const Icon(
                                                Icons.send_rounded,
                                                color: Colors.deepPurple,
                                              ),
                                              onPressed: () {
                                                widget.socket.emit(
                                                    "/sendMessage", {
                                                  "roomId": roomId,
                                                  "message": textFieldController
                                                      .text
                                                      .trim()
                                                });
                                                textFieldController.clear();
                                              },
                                            ),
                                          ),
                                        ),
                                      )
                                  ]);
                            })),
                      ),
                    ],
                  ),
                ),
                // if (_isLoading2)
                //   Container(
                //     color: Colors.white,
                //     height: MediaQuery.of(context).size.height,
                //     width: MediaQuery.of(context).size.width,
                //     child: Center(child: Text("Loading Whiteboard..")),
                //   )
              ]),
            ),
    );
  }
}

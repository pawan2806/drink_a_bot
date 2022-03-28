// ignore: file_names
// ignore_for_file: file_names

import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';

import 'package:drink_a_bot/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({required this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  static final clientID = 0;
  BluetoothConnection? connection;

  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';

  final TextEditingController textEditingController =
  new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                    (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: TextStyle(color: Colors.white)),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                _message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();

    final serverName = widget.server.name ?? "Unknown";
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: redShade,
      //     title: (isConnecting
      //         ? Text('Connecting chat to ' + serverName + '...')
      //         : isConnected
      //         ? Text('Live chat with ' + serverName)
      //         : Text('Chat log with ' + serverName))),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: greyShade,
                            size: 25,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                    Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              isConnecting?
                              'Connecting chat to ' +'\n'+ serverName + '...' : isConnected ? 'Live chat with ' +'\n'+ serverName : 'Chat log with '+'\n'+ serverName,
                              style: TextStyle(
                                fontSize: 25,
                                color: greyShade,

                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 4,
                            ),
                          ),
                  ],
                ),
              ],
            ),
            Divider(),
            SizedBox(height:20),
            Padding(
               padding: const EdgeInsets.only(right: 5.0, left: 5.0),
              child: Container(
                    decoration: BoxDecoration(
                      //border: Border.all(width: 3.0),
                      color: Color(0xffEEEEEE),
                      borderRadius: BorderRadius.all(Radius.circular(
                              20.0) //                 <--- border radius here
                          ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 20, bottom: 20.0),
                      child: Text(
                          "Drink-a-Bot Controls",
                          style: TextStyle(
                            fontSize: 18,
                            color: greyShade,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ),
                  ),
            ),
            //Text("Remote Control Car Controls"),
            SizedBox(height:30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: IconButton(
                      icon: const Icon(Icons.arrow_circle_up,
                      size: 35.0,),
                      onPressed: isConnected
                          ? () => _sendMessage('F')
                          : null),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: IconButton(
                      icon: const Icon(Icons.arrow_back,size: 35.0,),
                      onPressed: isConnected
                          ? () => _sendMessage('L')
                          : null),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: IconButton(
                      icon: const Icon(Icons.arrow_forward, size: 35.0,),
                      onPressed: isConnected
                          ? () => _sendMessage('R')
                          : null),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment:MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: IconButton(
                      icon: const Icon(Icons.arrow_circle_down, size: 35.0,),
                      onPressed: isConnected
                          ? () => _sendMessage('B')
                          : null),
                ),
              ],
            ),
            Divider(),
            SizedBox(height:100),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment:MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: IconButton(
                      icon: const Icon(Icons.compress),
                      onPressed: isConnected
                          ? () => _sendMessage('V')
                          : null),
                ),
              ],
            ),

            Flexible(
              child: ListView(
                  padding: const EdgeInsets.all(12.0),
                  controller: listScrollController,
                  children: list),
                  //commit test
            ),

          ],
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    print(data);
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);

    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    print(dataString);
    int mini = 1;
    int maxi = 300;
    int dataInt = int.parse(dataString)>300?min(300,int.parse(dataString)):int.parse(dataString);
    print(dataInt);
    double percent = ((dataInt-mini)/max(1,(maxi-mini)));
    print(percent*100);
    setState(() {
      messages.add(
        _Message(
          1,
          "The Volume left is " + (percent*100).toStringAsFixed(1) + "%",
        ),
      );
    });
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();
    print(text);
    if (text.length > 0) {
      try {
        print(utf8.encode(text));
        connection!.output.add(Uint8List.fromList(utf8.encode(text)));

        await connection!.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
        });

        Future.delayed(Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 333),
              curve: Curves.easeOut);
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
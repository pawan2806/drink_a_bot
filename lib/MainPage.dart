// ignore_for_file: file_names

import 'dart:async';

import 'package:drink_a_bot/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';
import 'helpers/constants.dart';
import './BackgroundCollectedPage.dart';
import './BackgroundCollectingTask.dart';
import './ChatPage.dart';
import './DiscoveryPage.dart';
import './SelectBondedDevicePage.dart';

// import './helpers/LineChart.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  BackgroundCollectingTask? _collectingTask;

  bool _autoAcceptPairingRequests = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _collectingTask?.dispose();
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   title: const Text('Flutter Bluetooth Serial'),
        //   backgroundColor: Colors.red,
        // ),
        body: Container(
          child: ListView(
            children: <Widget>[
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
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
                            "Drink-a-Bot Console",
                            style: TextStyle(
                              fontSize: 25,
                              color: greyShade,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.only(right: 30.0, left: 30.0),
                child: Container(
                  decoration: BoxDecoration(
                    //border: Border.all(width: 3.0),
                    color: Color(0xffEEEEEE),
                    borderRadius: BorderRadius.all(Radius.circular(
                            20.0) //                 <--- border radius here
                        ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SwitchListTile(
                      tileColor: greyShade,
                      title: const Text(
                        'Enable Bluetooth',
                        style: TextStyle(
                          fontSize: 18,
                          //color: greyShade,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      activeColor: Color(0xFFFC4F4F),
                      value: _bluetoothState.isEnabled,
                      onChanged: (bool value) {
                        // Do the request and update with the true value then
                        future() async {
                          // async lambda seems to not working
                          if (value)
                            await FlutterBluetoothSerial.instance
                                .requestEnable();
                          else
                            await FlutterBluetoothSerial.instance
                                .requestDisable();
                        }

                        future().then((_) {
                          setState(() {});
                        });
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(

                      height: 250,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(0xff7b4397),
                          Color(0xff33001b),
                        ],
                      )),
                      child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final BluetoothDevice? selectedDevice =
                                      await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return DiscoveryPage();
                                      },
                                    ),
                                  );

                                  if (selectedDevice != null) {
                                    print('Discovery -> selected ' +
                                        selectedDevice.address);
                                  } else {
                                    print('Discovery -> no device selected');
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    'Search' +
                                        '\n' +
                                        'for new' +
                                        '\n' +
                                        'Devices',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(0xff3a6186),
                          Color(0xff89253e),
                        ],
                      )),
                      child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final BluetoothDevice? selectedDevice =
                                      await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return SelectBondedDevicePage(
                                            checkAvailability: false);
                                      },
                                    ),
                                  );

                                  if (selectedDevice != null) {
                                    print('Connect -> selected ' +
                                        selectedDevice.address);
                                    _startChat(context, selectedDevice);
                                  } else {
                                    print('Connect -> no device selected');
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    'Select ' +
                                        '\n' +
                                        'Paired' +
                                        '\n' +
                                        'Devices',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Expanded(
              //   child: Container(
              //     alignment: Alignment.center,
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       children: [
              //         Padding(
              //           padding: const EdgeInsets.only(
              //               top: 10.0, left: 15.0, right: 15.0),
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             crossAxisAlignment: CrossAxisAlignment.center,
              //             children: [
              //               ElevatedButton(
              //                 style: ElevatedButton.styleFrom(
              //                   primary: Colors.white,
              //                   onPrimary:   Color(0xFFFC4F4F),
              //                   side: BorderSide(
              //                     width: 3,
              //                      color: Color(0xFFFC4F4F),
              //                   ),
              //                   shape: RoundedRectangleBorder(
              //                     borderRadius: BorderRadius.circular(10),
              //                   ),
              //                 ),
              //                 onPressed: () async {
              //                   final BluetoothDevice? selectedDevice =
              //                       await Navigator.of(context).push(
              //                     MaterialPageRoute(
              //                       builder: (context) {
              //                         return DiscoveryPage();
              //                       },
              //                     ),
              //                   );

              //                   if (selectedDevice != null) {
              //                     print('Discovery -> selected ' +
              //                         selectedDevice.address);
              //                   } else {
              //                     print('Discovery -> no device selected');
              //                   }
              //                 },
              //                 child: Padding(
              //                   padding: const EdgeInsets.all(8.0),
              //                   child: Text(
              //                     'Search for devices to pair',
              //                     style: TextStyle( color: Color(0xFFFC4F4F),
              //                     fontSize: 16.0,),
              //                     textAlign: TextAlign.center,
              //                   ),
              //                 ),
              //               )
              //             ],
              //           ),
              //         ),
              //         Padding(
              //           padding: const EdgeInsets.only(
              //               top: 10.0, left: 15.0, right: 15.0),
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             crossAxisAlignment: CrossAxisAlignment.center,
              //             children: [
              //               ElevatedButton(
              //                 style: ElevatedButton.styleFrom(
              //                   primary: Colors.white,
              //                   onPrimary: Color(0xFFFC4F4F),
              //                   side: BorderSide(
              //                     width: 3,
              //                     color: Color(0xFFFC4F4F),
              //                   ),
              //                   shape: RoundedRectangleBorder(
              //                     borderRadius: BorderRadius.circular(10),
              //                   ),
              //                 ),
              //                 onPressed: () async {
              //                   final BluetoothDevice? selectedDevice =
              //                       await Navigator.of(context).push(
              //                     MaterialPageRoute(
              //                       builder: (context) {
              //                         return SelectBondedDevicePage(
              //                             checkAvailability: false);
              //                       },
              //                     ),
              //                   );

              //                   if (selectedDevice != null) {
              //                     print('Connect -> selected ' +
              //                         selectedDevice.address);
              //                     _startChat(context, selectedDevice);
              //                   } else {
              //                     print('Connect -> no device selected');
              //                   }
              //                 },
              //                 child: Padding(
              //                   padding: const EdgeInsets.all(8.0),
              //                   child: Text(
              //                     'Select Paired Device to send data',
              //                     style: TextStyle(
              //                       fontSize: 16.0,
              //                        color: Color(0xFFFC4F4F),
              //                     ),
              //                     textAlign: TextAlign.center,
              //                   ),
              //                 ),
              //               )
              //             ],
              //           ),
              //         ),
              //         //     ListTile(
              //         //   title: FlatButton(
              //         //       color: Colors.red,
              //         //       child: const Text(
              //         //         'Search for devices to pair',
              //         //         style: TextStyle(color: Colors.white),
              //         //       ),
              //         //       onPressed: () async {
              //         //         final BluetoothDevice? selectedDevice =
              //         //             await Navigator.of(context).push(
              //         //           MaterialPageRoute(
              //         //             builder: (context) {
              //         //               return DiscoveryPage();
              //         //             },
              //         //           ),
              //         //         );

              //         //         if (selectedDevice != null) {
              //         //           print(
              //         //               'Discovery -> selected ' + selectedDevice.address);
              //         //         } else {
              //         //           print('Discovery -> no device selected');
              //         //         }
              //         //       }),
              //         // ),
              //         // ListTile(
              //         //   title: FlatButton(
              //         //     color: Colors.red,
              //         //     child: const Text(
              //         //       'Select Paired Device to send data',
              //         //       style: TextStyle(color: Colors.white),
              //         //     ),
              //         //     onPressed: () async {
              //         //       final BluetoothDevice? selectedDevice =
              //         //           await Navigator.of(context).push(
              //         //         MaterialPageRoute(
              //         //           builder: (context) {
              //         //             return SelectBondedDevicePage(
              //         //                 checkAvailability: false);
              //         //           },
              //         //         ),
              //         //       );

              //         //       if (selectedDevice != null) {
              //         //         print('Connect -> selected ' + selectedDevice.address);
              //         //         _startChat(context, selectedDevice);
              //         //       } else {
              //         //         print('Connect -> no device selected');
              //         //       }
              //         //     },
              //         //   ),
              //         // ),
              //       ],
              //     ),
              //   ),
              // ),

              Divider(),
              //            ListTile(title: const Text('Multiple connections example')),
              //            ListTile(
              //              title: ElevatedButton(
              //                child: ((_collectingTask?.inProgress ?? false)
              //                    ? const Text('Disconnect and stop background collecting')
              //                    : const Text('Connect to start background collecting')),
              //                onPressed: () async {
              //                  if (_collectingTask?.inProgress ?? false) {
              //                    await _collectingTask!.cancel();
              //                    setState(() {
              //                      /* Update for `_collectingTask.inProgress` */
              //                    });
              //                  } else {
              //                    final BluetoothDevice? selectedDevice =
              //                    await Navigator.of(context).push(
              //                      MaterialPageRoute(
              //                        builder: (context) {
              //                          return SelectBondedDevicePage(
              //                              checkAvailability: false);
              //                        },
              //                      ),
              //                    );
              //
              //                    if (selectedDevice != null) {
              //                      await _startBackgroundTask(context, selectedDevice);
              //                      setState(() {
              //                        /* Update for `_collectingTask.inProgress` */
              //                      });
              //                    }
              //                  }
              //                },
              //              ),
              //            ),
              //            ListTile(
              //              title: ElevatedButton(
              //                child: const Text('View background collected data'),
              //                onPressed: (_collectingTask != null)
              //                    ? () {
              //                  Navigator.of(context).push(
              //                    MaterialPageRoute(
              //                      builder: (context) {
              //                        return ScopedModel<BackgroundCollectingTask>(
              //                          model: _collectingTask!,
              //                          child: BackgroundCollectedPage(),
              //                        );
              //                      },
              //                    ),
              //                  );
              //                }
              //                    : null,
              //              ),
              //            ),
            ],
          ),
        ),
      ),
    );
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChatPage(server: server);
        },
      ),
    );
  }

  Future<void> _startBackgroundTask(
    BuildContext context,
    BluetoothDevice server,
  ) async {
    try {
      _collectingTask = await BackgroundCollectingTask.connect(server);
      await _collectingTask!.start();
    } catch (ex) {
      _collectingTask?.cancel();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error occured while connecting'),
            content: Text("${ex.toString()}"),
            actions: <Widget>[
              new TextButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}

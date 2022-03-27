// ignore_for_file: file_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'helpers/constants.dart';
import './BluetoothDeviceListEntry.dart';

class DiscoveryPage extends StatefulWidget {
  /// If true, discovery starts on page start, otherwise user must press action button.
  final bool start;

  const DiscoveryPage({this.start = true});

  @override
  _DiscoveryPage createState() => new _DiscoveryPage();
}

class _DiscoveryPage extends State<DiscoveryPage> {
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results =
  List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isDiscovering = false;

  _DiscoveryPage();

  @override
  void initState() {
    super.initState();

    isDiscovering = widget.start;
    if (isDiscovering) {
      _startDiscovery();
    }
  }

  void _restartDiscovery() {
    setState(() {
      results.clear();
      isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
          setState(() {
            final existingIndex = results.indexWhere(
                    (element) => element.device.address == r.device.address);
            if (existingIndex >= 0)
              results[existingIndex] = r;
            else
              results.add(r);
          });
        });

    _streamSubscription!.onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });
  }

  // @TODO . One day there should be `_pairDevice` on long tap on something... ;)

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _streamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.red,
        //   title: isDiscovering
        //       ? Text('Discovering devices')
        //       : Text('Discovered devices'),
        //   actions: <Widget>[
        //     isDiscovering
        //         ? FittedBox(
        //       child: Container(
        //         margin: new EdgeInsets.all(16.0),
        //         child: CircularProgressIndicator(
        //           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        //         ),
        //       ),
        //     )
        //         : IconButton(
        //       icon: Icon(Icons.replay),
        //       onPressed: _restartDiscovery,
        //     )
        //   ],
        // ),
        body: Column(
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
                          isDiscovering?'Discovering devices' :'Discovered devices',
                          style: TextStyle(
                            fontSize: 25,
                            color: greyShade,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      isDiscovering
                          ? Expanded(
                            child: Row(
                               mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20.0, ),
                                    child: Container(
                                    alignment: Alignment.centerRight,
                                    
                                    //margin: new EdgeInsets.all(12.0),
                                    child: CircularProgressIndicator(
                                      
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        greyShade,
                                      ),
                                    ),
                                ),
                                  ),
                                ],
                              ),
                          )
                          : Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                   padding: const EdgeInsets.only(right: 20.0, ),
                                  child: IconButton(
                                      icon: Icon(
                                        Icons.replay,
                                        size: 25,
                                        color: greyShade,
                                      ),
                                      onPressed: _restartDiscovery,
                                    ),
                                ),
                              ],
                            ),
                          )
                    ],
                  ),
                ),
            Divider(),
            Expanded(child:  
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (BuildContext context, index) {
              BluetoothDiscoveryResult result = results[index];
              final device = result.device;
              final address = device.address;
              return BluetoothDeviceListEntry(
                device: device,
                rssi: result.rssi,
                onTap: () {
                  Navigator.of(context).pop(result.device);
                },
                onLongPress: () async {
                  try {
                    bool bonded = false;
                    if (device.isBonded) {
                      print('Unbonding from ${device.address}...');
                      await FlutterBluetoothSerial.instance
                          .removeDeviceBondWithAddress(address);
                      print('Unbonding from ${device.address} has succed');
                    } else {
                      print('Bonding with ${device.address}...');
                      bonded = (await FlutterBluetoothSerial.instance
                          .bondDeviceAtAddress(address))!;
                      print(
                          'Bonding with ${device.address} has ${bonded ? 'succed' : 'failed'}.');
                    }
                    setState(() {
                      results[results.indexOf(result)] = BluetoothDiscoveryResult(
                          device: BluetoothDevice(
                            name: device.name ?? '',
                            address: address,
                            type: device.type,
                            bondState: bonded
                                ? BluetoothBondState.bonded
                                : BluetoothBondState.none,
                          ),
                          rssi: result.rssi);
                    });
                  } catch (ex) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error occured while bonding'),
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
                },
              );
            },
          ),
        ),
            ),
          ],
        ),
       
      ),
    );
  }
}
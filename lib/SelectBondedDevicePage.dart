// ignore_for_file: file_names

import 'dart:async';

import 'package:drink_a_bot/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import './BluetoothDeviceListEntry.dart';

class SelectBondedDevicePage extends StatefulWidget {
  /// If true, on page start there is performed discovery upon the bonded devices.
  /// Then, if they are not avaliable, they would be disabled from the selection.
  final bool checkAvailability;

  const SelectBondedDevicePage({this.checkAvailability = true});

  @override
  _SelectBondedDevicePage createState() => new _SelectBondedDevicePage();
}

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class _DeviceWithAvailability {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int? rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi]);
}

class _SelectBondedDevicePage extends State<SelectBondedDevicePage> {
  List<_DeviceWithAvailability> devices =
      List<_DeviceWithAvailability>.empty(growable: true);

  // Availability
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
  bool _isDiscovering = false;

  _SelectBondedDevicePage();

  @override
  void initState() {
    super.initState();

    _isDiscovering = widget.checkAvailability;

    if (_isDiscovering) {
      _startDiscovery();
    }

    // Setup a list of the bonded devices
    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices
            .map(
              (device) => _DeviceWithAvailability(
                device,
                widget.checkAvailability
                    ? _DeviceAvailability.maybe
                    : _DeviceAvailability.yes,
              ),
            )
            .toList();
      });
    });
  }

  void _restartDiscovery() {
    setState(() {
      _isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    _discoveryStreamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        Iterator i = devices.iterator;
        while (i.moveNext()) {
          var _device = i.current;
          if (_device.device == r.device) {
            _device.availability = _DeviceAvailability.yes;
            _device.rssi = r.rssi;
          }
        }
      });
    });

    _discoveryStreamSubscription?.onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _discoveryStreamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<BluetoothDeviceListEntry> list = devices
        .map((_device) => BluetoothDeviceListEntry(
              device: _device.device,
              rssi: _device.rssi,
              enabled: _device.availability == _DeviceAvailability.yes,
              onTap: () {
                Navigator.of(context).pop(_device.device);
              },
            ))
        .toList();
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.red,
        //   title: Text('Select device'),
        //   actions: <Widget>[
        //     _isDiscovering
        //         ? FittedBox(
        //             child: Container(
        //               margin: new EdgeInsets.all(16.0),
        //               child: CircularProgressIndicator(
        //                 valueColor: AlwaysStoppedAnimation<Color>(
        //                   Colors.white,
        //                 ),
        //               ),
        //             ),
        //           )
        //         : IconButton(
        //             icon: Icon(Icons.replay),
        //             onPressed: _restartDiscovery,
        //           )
        //   ],
        // ),
        body: Column(
          children: [
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
                          "Select Device",
                          style: TextStyle(
                            fontSize: 25,
                            color: greyShade,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _isDiscovering
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
              ],
            ),
            Divider(),
            Expanded(child: Container(
              decoration: BoxDecoration(
                    //border: Border.all(width: 3.0),
                    color: Color(0xffEEEEEE),
                    borderRadius: BorderRadius.all(Radius.circular(
                            20.0) //                 <--- border radius here
                        ),
                  ),
              child: ListView(children: list))
              ),
          ],
        ),
      ),
    );
  }
}

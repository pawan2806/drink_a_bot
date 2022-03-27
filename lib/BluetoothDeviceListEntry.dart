// ignore_for_file: file_names

import 'package:drink_a_bot/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'helpers/constants.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothDeviceListEntry extends ListTile {
  BluetoothDeviceListEntry({
    required BluetoothDevice device,
    int? rssi,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
    bool enabled = true,
  }) : super(
    onTap: onTap,
    onLongPress: onLongPress,
    enabled: enabled,
    leading:
    Icon(Icons.devices), // @TODO . !BluetoothClass! class aware icon
    title: Text(device.name ?? ""),
    subtitle: Text(device.address.toString()),
    trailing: FlatButton(
      
      child: Text('Connect',style: TextStyle(color:Colors.white,),),
      onPressed: onTap,
      color:redShade,
    ),
  );
}
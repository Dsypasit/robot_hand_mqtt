import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:robot_hand/MQTTManager.dart';
import 'package:robot_hand/MQTTAppState.dart';


class Demo extends StatefulWidget {
  @override
  State<StatefulWidget> createState(){
    return _DemoState();
  }
}

class _DemoState extends State<Demo>{
  final TextEditingController _xAxisController = TextEditingController();
  final TextEditingController _yAxisController = TextEditingController();
  final TextEditingController _zAxisController = TextEditingController();

  late MQTTAppState currentState;
  late MQTTManager manager;

  String? get _xErrorValue{
    final text = _xAxisController.value.text;
    if (text.isEmpty){
      return 'Cant\'t be empty';
    }
    int value = int.parse(text);
    if (value<0 || value>180){
      return 'please input between 0-180';
    }
    return null;
  }

  String? get _yErrorValue{
    final text = _yAxisController.value.text;
    if (text.isEmpty){
      return 'Cant\'t be empty';
    }
    int value = int.parse(text);
    if (value<0 || value>180){
      return 'please input between 0-180';
    }
    return null;
  }

  String? get _zErrorValue{
    final text = _zAxisController.value.text;
    if (text.isEmpty){
      return 'Cant\'t be empty';
    }
    int value = int.parse(text);
    if (value<0 || value>180){
      return 'please input between 0-180';
    }
    return null;
  }

  @override
  void initSate(){
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _xAxisController.dispose();
    _yAxisController.dispose();
    _zAxisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    currentState = appState;
    return Scaffold(
      appBar: AppBar(
        title: Text('Robot hand Controller'),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: <Widget>[
            _buildConnectionStateText(_prepareStateMessageFrom(currentState.getAppConnectionState)),
            TextField(
              controller: _xAxisController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'X axis',
                icon: Icon(Icons.list_outlined),
                errorText: _xErrorValue,
              ),
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 20,),
            TextField(
              controller: _yAxisController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Y axis',
                icon: Icon(Icons.list_outlined),
                errorText: _yErrorValue,
              ),
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 20,),
            TextField(
              controller: _zAxisController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Z axis',
                icon: Icon(Icons.list_outlined),
                errorText: _zErrorValue,
              ),
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 20,),
            _buildConnecteButtonFrom(currentState.getAppConnectionState),
            SizedBox(height: 20,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  color: Colors.pinkAccent,
                  child: Text(
                    "Calculate",
                    style: TextStyle(color: Colors.white)
                  ),
                  onPressed: (currentState.getAppConnectionState == MQTTAppConnectionState.connected)
                  && checkEmpty()
                   ? calculateRobot
                   : null,
                ),
              ],
            ),
            SizedBox(height:30),
            Text(
              currentState.getReceivedText
            )
          ],
        )
      )
    );
  }

  bool checkEmpty(){
    return _xAxisController.value.text.isNotEmpty && _yAxisController.value.text.isNotEmpty && _zAxisController.value.text.isNotEmpty;
  }

  Widget _buildConnectionStateText(String state){
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
              color: currentState.getAppConnectionState != MQTTAppConnectionState.connected ? 
              Colors.deepOrangeAccent
              : Colors.greenAccent,
              child: Text(state, textAlign: TextAlign.center)),
        ),
      ],
    );
  }

  Widget _buildConnecteButtonFrom(MQTTAppConnectionState state) {
    return Row(
      children: <Widget>[
        Expanded(
          // ignore: deprecated_member_use
          child: RaisedButton(
            color: Colors.lightBlueAccent,
            child: const Text('Connect'),
            onPressed: state == MQTTAppConnectionState.disconnected
                ? connect
                : null, //
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          // ignore: deprecated_member_use
          child: RaisedButton(
            color: Colors.redAccent,
            child: const Text('Disconnect'),
            onPressed: state == MQTTAppConnectionState.connected
                ? disconnect
                : null, //
          ),
        ),
      ],
    );
  }

  void calculateRobot (){
    final String message = "F"+_xAxisController.text + "," + _yAxisController.text + "," + _zAxisController.text;
    print(message);
    manager.publishMessage(message);
  }

  void disconnect (){
    manager.disconnect();
  }

  String _prepareStateMessageFrom(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return 'Connected';
      case MQTTAppConnectionState.connecting:
        return 'Connecting';
      case MQTTAppConnectionState.disconnected:
        return 'Disconnected';
    }
  }

  void connect(){
    manager = MQTTManager(state: currentState);
    manager.prepareMqttClient();
  }

}
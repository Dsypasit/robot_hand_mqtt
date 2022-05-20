import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:robot_hand/MQTTAppState.dart';

class MQTTManager{
  late MqttServerClient client;

  final MQTTAppState  _currentState;

  MQTTManager({
    required MQTTAppState state
  }): _currentState = state;

  // using async tasks, so the connection won't hinder the code flow
  void prepareMqttClient() async {
    _setupMqttClient();
    await _connectClient();
    _subscribeToTopic('Dart/Mqtt_client/testtopic');
    publishMessage('Hello');
  }

  // waiting for the connection, if an error occurs, print it and disconnect
  Future<void> _connectClient() async {
    try {
      print('client connecting....');
      _currentState.setAppConnectionState(MQTTAppConnectionState.connecting);
      await client.connect();
      _currentState.setAppConnectionState(MQTTAppConnectionState.connected);
      print('connecting success');
    } on Exception catch (e) {
      print('client exception - $e');
      _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
      client.disconnect();
    }

    // when connected, print a confirmation, else print an error
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      _currentState.setAppConnectionState(MQTTAppConnectionState.connected);
      print('client connected');
    } else {
      print(
          'ERROR client connection failed - disconnecting, status is ${client.connectionStatus}');
      _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
      client.disconnect();
    }
  }

  void _setupMqttClient() {
    client = MqttServerClient('public.mqtthq.com', 'Robotkub');
    // the next 2 lines are necessary to connect with tls, which is used by HiveMQ Cloud
    // client.secure = true;
    // client.securityContext = SecurityContext.defaultContext;
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
  }

  void _subscribeToTopic(String topicName) {
    print('Subscribing to the $topicName topic');
    client.subscribe(topicName, MqttQos.atMostOnce);

    // print the message when it is received
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      var message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      print('YOU GOT A NEW MESSAGE:');
      print(message);
    });
  }

  void publishMessage(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);

    print('Publishing message "$message" to topic ${'Dart/Mqtt_client/testtopic'}');
    client.publishMessage('Dart/Mqtt_client/testtopic', MqttQos.exactlyOnce, builder.payload!);
  }

  void disconnect(){
    _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
    print('OnDisconnected client callback - Client disconnection');
    client.disconnect();
  }

  // callbacks for different events
  void _onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  void _onDisconnected() {
    print('OnDisconnected client callback - Client disconnection');
    _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
  }

  void _onConnected() {
    _currentState.setAppConnectionState(MQTTAppConnectionState.connected);
    print('OnConnected client callback - Client connection was sucessful');
  }

}
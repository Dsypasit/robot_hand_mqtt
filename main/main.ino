#include <WiFi.h>
#include <PubSubClient.h>
const char* ssid     = "Arthit";
const char* password = "0925296675";

// Config MQTT Server
#define mqtt_server "public.mqtthq.com"
#define mqtt_port "1883"
#define mqtt_topic "Dart/Mqtt_client/testtopic"

WiFiClient espClient;
PubSubClient client(espClient);

void setup() {
  pinMode(2, OUTPUT);

  Serial.begin(115200);
  delay(10);

  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());

  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);
  while(!client.connected()){
    Serial.print("Attempting MQTT connection...");
    if (client.connect("ESP32Client")) {
      Serial.println("connected");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }    
  }
  client.subscribe(mqtt_topic);
}

void loop() {
  client.loop();
}

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  String msg = "";
  int i=0;
  Serial.print(msg);
  Serial.print("\n");
  while (i<length) msg += (char)payload[i++];
  if (msg[0] == 'F'){
    String number = "";
    int j=1;
    while(j<length) number += (char)payload[j++];
    controll_hand(number);
    
    client.publish(mqtt_topic, "OK kub");
  }
}

void controll_hand(String numberStr){
  char numSplit[3][3];
  int numAxis[3];
  int ptr=0, j=0;
  for(int i=0; i<numberStr.length(); i++){
    if(numberStr[i]==','||numberStr[i]=='\0'){
      ptr++;
      j=0;
    }else
    {
      numSplit[ptr][j]=numberStr[i];
      j++;
    }
  }
  for(int i=0; i<3; i++){
    char* n = numSplit[i];
    numAxis[i] = atoi(n);
  }
  for(int i=0; i<3; i++){
    Serial.print("xyz=");
    Serial.println(numAxis[i]);
  }
}

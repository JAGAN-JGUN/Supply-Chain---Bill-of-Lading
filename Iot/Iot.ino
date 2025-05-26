#include <Arduino.h>
#include <WiFi.h>
#include <WiFiClient.h>
#include <ESP32QRCodeReader.h>
#include <cstring>
#include <ArduinoJson.h>
#include <queue>

#define WIFI_SSID "Your WiFi Name"
#define WIFI_PASSWORD "Wifi Password"
#define CONNIP "Your IP address"
#define PORT "Your Port Number"

WiFiClient client;

ESP32QRCodeReader reader(CAMERA_MODEL_AI_THINKER);
struct QRCodeData qrCodeData;

bool SendMsg(String S) {
  // char Sstr[100];
  String S1;
  StaticJsonDocument<512> doc;
  int MaxWait = 10;
  deserializeJson(doc, S);
  doc["Carrier"] = "AIS1249B86";
  serializeJson(doc, S1);
  client.println(S1);
  Serial.println("Sent message: " + S1);
  Serial.print("Message Sent Successfully.");
  return true;
}

void setup() {
  Serial.begin(115200);
  Serial.println();
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.print("WiFi connected with IP: ");
  Serial.println(WiFi.localIP());

  reader.setup();
  //reader.setDebug(true);
  Serial.println("Setup QRCode Reader");
  reader.begin();
  Serial.println("Begin QRCode Reader");
  delay(1000);
}

void loop() {
  while (!client.connect(CONNIP, PORT)) {
    Serial.println("Connection failed. Retrying...");
    delay(1000);
  }
  Serial.println("Server Connected.");
  String S;
  xQueueReset(reader.qrCodeQueue);

  while (client.connected()) {
    if (reader.receiveQrCode(&qrCodeData, 100)) {
      Serial.println("Found QRCode");
      if (qrCodeData.valid) {
        Serial.print("Payload: ");
        S = String((const char *)qrCodeData.payload);
        Serial.println((const char *)qrCodeData.payload);
        if (!SendMsg(S))
          Serial.print("Failed to connect to Server. Restarting process...");
        client.stop();
        delay(10000);
      } else {
        Serial.print("Invalid: ");
        Serial.println((const char *)qrCodeData.payload);
      }
    }
  }
  delay(1000);
}
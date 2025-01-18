#include <WiFi.h>
#include <WebSocketsServer.h>

// WiFi Credentials
const char* ssid = "NIKHIL 1639";
const char* password = "nik12345";
long randNumber;

// Motion Sensor Pin
#define PIR_PIN 26

WebSocketsServer webSocket = WebSocketsServer(81);

void setup() {
  Serial.begin(115200);
  pinMode(PIR_PIN, INPUT);

  // Connect to WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");
  Serial.println(WiFi.localIP());

  // Start WebSocket server
  webSocket.begin();
  webSocket.onEvent(webSocketEvent);
  Serial.println("WebSocket server started on port 81");
}

void loop() {
  webSocket.loop();

  // Check for motion
  if (digitalRead(PIR_PIN) == HIGH) {
    Serial.println("Motion detected!");
    randNumber = random(300);
      Serial.println(randNumber);
    sendMotionEvent();
    delay(10000); // Avoid multiple triggers for the same motion
  }
}

void sendMotionEvent() {
  webSocket.broadcastTXT("motion_detected");
}

void webSocketEvent(uint8_t num, WStype_t type, uint8_t *payload, size_t length) {
  if (type == WStype_TEXT) {
    Serial.printf("[%u] Received text: %s\n", num, payload);
    // Handle messages received from connected devices
  }
}

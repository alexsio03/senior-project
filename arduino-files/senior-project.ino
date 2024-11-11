#include <ArduinoBLE.h>

BLEService newService("180A");
BLEIntCharacteristic readSignal("2A57", BLERead | BLENotify | BLEWrite);

const int PWM_PIN1 = 4; // Use PWM-capable pins
const int PWM_PIN2 = 5;

void setup() {
  Serial.begin(9600);
  while (!Serial);
  
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(10, INPUT);
  pinMode(11, INPUT);
  pinMode(PWM_PIN1, OUTPUT);
  pinMode(PWM_PIN2, OUTPUT);
  
  if (!BLE.begin()) {
    Serial.println("Starting BLE failed!");
    while (1);
  }
  
  BLE.setLocalName("MKR WiFi 1010");
  BLE.setAdvertisedService(newService);
  newService.addCharacteristic(readSignal);
  BLE.addService(newService);
  readSignal.writeValue(0);
  BLE.advertise();
  
  Serial.println("BLE device active, waiting for connections...");
}

void loop() {
  BLEDevice central = BLE.central();
  
  if (central) {
    Serial.print("Connected to central: ");
    Serial.println(central.address());
    digitalWrite(LED_BUILTIN, HIGH);
    
    while (central.connected()) {
      if ((digitalRead(10) == HIGH) || (digitalRead(11) == HIGH)) {
        analogWrite(PWM_PIN1, 255);
        Serial.println('!');
      } else {
        analogWrite(PWM_PIN2, 255);
        int analogValue = analogRead(A0);
        if (readSignal.subscribed()) {
          readSignal.writeValue(analogValue);
        }
        Serial.println(analogValue);
      }
      delay(50);
    }
    
    digitalWrite(LED_BUILTIN, LOW);
    Serial.print("Disconnected from central: ");
    Serial.println(central.address());
  }
}

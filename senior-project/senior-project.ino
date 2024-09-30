#include <ArduinoBLE.h>
#include <WiFiNINA.h>
#include <utility/wifi_drv.h>
BLEService newService("180A");
BLEIntCharacteristic readSignal("2A57", BLERead | BLENotify | BLEWrite);

long previousMillis = 0;
int counter = 1;
bool up = true;

void setup() {
  Serial.begin(9600);    // initialize serial communication
  while (!Serial);       //starts the program if we open the serial monitor.
  
  pinMode(LED_BUILTIN, OUTPUT);
  
  if (!BLE.begin()) {
    Serial.println("starting Bluetooth® Low Energy failed!");
    while (1);
  }

  BLE.setLocalName("MKR WiFi 1010"); //Setting a name that will appear when scanning for Bluetooth® devices
  BLE.setAdvertisedService(newService);

  newService.addCharacteristic(readSignal);

  BLE.addService(newService);

  readSignal.writeValue(0);

  BLE.advertise(); //start advertising the service
  Serial.println(" Bluetooth® device active, waiting for connections..."); 
  // put your setup code here, to run once:
  //  Serial.begin(9600);
  //  pinMode(10, INPUT);
  //  pinMode(11, INPUT);
  //  WiFiDrv::pinMode(25, OUTPUT);
  //  WiFiDrv::pinMode(26, OUTPUT); 
  //  WiFiDrv::pinMode(27, OUTPUT);
}

void loop() {
  BLEDevice central = BLE.central();
  if (central) {  // if a central is connected to the peripheral
    Serial.print("Connected to central: ");
    Serial.println(central.address());
    digitalWrite(LED_BUILTIN, HIGH);

    while (central.connected()) {
      long currentMillis = millis();
      if (currentMillis - previousMillis >= 100) { // if 200ms have passed, we check the battery level
        previousMillis = currentMillis;
        if (counter == 250 || counter == 0) {
          up = !up;
        }
        if (up) {
          counter++;
        } else {
          counter--;
        }
        readSignal.writeValue(counter);
      }
    }
    
    digitalWrite(LED_BUILTIN, LOW); // when the central disconnects, turn off the LED
    Serial.print("Disconnected from central: ");
    Serial.println(central.address());
  }
  // put your main code here, to run repeatedly:
  //  if((digitalRead(10) == 1) || (digitalRead(11) == 1)) {
  //    WiFiDrv::analogWrite(25, 255);
  //    Serial.println('!');
  //  } else {
  //    WiFiDrv::analogWrite(26, 255);
  //    Serial.println(analogRead(A0));
  //  }
  //  delay(400);
}

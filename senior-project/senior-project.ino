#include <WiFiNINA.h>
#include <utility/wifi_drv.h>

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(10, INPUT);
  pinMode(11, INPUT);
  WiFiDrv::pinMode(25, OUTPUT);
  WiFiDrv::pinMode(26, OUTPUT); 
  WiFiDrv::pinMode(27, OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  if((digitalRead(10) == 1) || (digitalRead(11) == 1)) {
    WiFiDrv::analogWrite(25, 255);
    Serial.println('!');
  } else {
    WiFiDrv::analogWrite(26, 255);
    Serial.println(analogRead(A0));
  }
  delay(400);
}

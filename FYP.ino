/*
 This example connects to an unencrypted WiFi network.
 Then it prints the MAC address of the WiFi module,
 the IP address obtained, and other network details.

 created 13 July 2010
 by dlf (Metodo2 srl)
 modified 31 May 2012
 by Tom Igoe
 Rest of the code is  created by Shaun David Jerome
 */
#include <SPI.h>
#include <WiFiNINA.h>
#define AOUT_PIN A0 // Arduino pin that connects to AOUT pin of moisture sensor
#define AOUT_PIN1 A1 // Arduino pin that connects to AOUT pin of pH sensor
//#include <FirebaseArduino.h>
#include <Arduino_LSM6DS3.h>
#include <Firebase_Arduino_WiFiNINA.h>
#define  FIREBASE_HOST "trial-3b3e9-default-rtdb.asia-southeast1.firebasedatabase.app"
//"trial-3b3e9-default-rtdb.asia-southeast1.firebasedatabase.app"
//"trial-3b3e9.firebaseio.com"
#define FIREBASE_AUTH "TssanFOHHgynBHcM51IoTHbxqilroyNkJOdh8rYn"
#include "arduino_secrets.h" 
#include <Servo.h>
Servo myservo;  // create servo object to control a servo
///////please enter your sensitive data in the Secret tab/arduino_secrets.h
char ssid[] = SECRET_SSID;        // your network SSID (name)
char pass[] = SECRET_PASS;    // your network password (use for WPA, or use as key for WEP)
int status = WL_IDLE_STATUS;     // the WiFi radio's status

FirebaseData firebaseData;

String path = "/Arduino";
//int pos = 0;
//String jsonStr;
//https://trial-3b3e9-default-rtdb.asia-southeast1.firebasedatabase.app

void setup() {
  //Initialize serial and wait for port to open:
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }

  // check for the WiFi module:
  if (WiFi.status() == WL_NO_MODULE) {
    Serial.println("Communication with WiFi module failed!");
    // don't continue
    while (true);
  }

  String fv = WiFi.firmwareVersion();
  if (fv < WIFI_FIRMWARE_LATEST_VERSION) {
    Serial.println("Please upgrade the firmware");
  }

  // attempt to connect to WiFi network:
  while (status != WL_CONNECTED) {
    Serial.print("Attempting to connect to WPA SSID: ");
    Serial.println(ssid);
    // Connect to WPA/WPA2 network:
    status = WiFi.begin(ssid, pass);
    Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH, "*******", "*******");
    Firebase.reconnectWiFi(true);


    // wait 10 seconds for connection:
    delay(10000);
  }

  // you're connected now, so print out the data:
  Serial.print("You're connected to the network");
  printCurrentNet();
  printWifiData();
  
}

void loop() {
  // check the network connection once every 10 seconds:
  delay(5000);
  //printCurrentNet();
  SensorReading();
}

void printWifiData() {
  // print your board's IP address:
  IPAddress ip = WiFi.localIP();
  Serial.print("IP Address: ");
  Serial.println(ip);
  Serial.println(ip);

  // print your MAC address:
  byte mac[6];
  WiFi.macAddress(mac);
  Serial.print("MAC address: ");
  printMacAddress(mac);
}

void printCurrentNet() {
  // print the SSID of the network you're attached to:
  Serial.print("SSID: ");
  Serial.println(WiFi.SSID());

  // print the MAC address of the router you're attached to:
  byte bssid[6];
  WiFi.BSSID(bssid);
  Serial.print("BSSID: ");
  printMacAddress(bssid);

  // print the received signal strength:
  long rssi = WiFi.RSSI();
  Serial.print("signal strength (RSSI):");
  Serial.println(rssi);

  // print the encryption type:
  byte encryption = WiFi.encryptionType();
  Serial.print("Encryption Type:");
  Serial.println(encryption, HEX);
  Serial.println();

}

void printMacAddress(byte mac[]) {
  for (int i = 5; i >= 0; i--) {
    if (mac[i] < 16) {
      Serial.print("0");
    }
    Serial.print(mac[i], HEX);
    if (i > 0) {
      Serial.print(":");
    }
  }
  Serial.println();
}

void SensorReading() {
  //int pos = 0;
  myservo.attach(4);
  const int RELAY_PIN = A5;///pump water into tank
  pinMode(RELAY_PIN, OUTPUT);
  const int RELAY_PIN2 = A4;/// from tank pumpout water
  pinMode(RELAY_PIN2, OUTPUT);
  const int maxSensorValue = 1023;  
  const int minSensorValue = 0;     

  const int max = 100;      // Maximum target range
  const int min = 0;        // Minimum target range
  int moisture = analogRead(AOUT_PIN); // read the analog value from moisture sensor
  int value = map(moisture, minSensorValue, maxSensorValue, min, max);
  value = abs(value-100);


  int RawpH = 0;
  for(int i=0;i<5;i++){
    RawpH += analogRead(AOUT_PIN1); // read the analog value from pH sensor
  }
  float pH=(float)RawpH*5.0/1024/5; //convert the analog into volt and average(V)
  pH=abs(((pH*18.267)-31.123)); //convert the volt into pH value using calibrated value
  //pH=abs((14-(3.5*pH))); 
  //Ultrasonic sensor 
  pinMode(9, OUTPUT); // Sets the trigPin as an Output
  pinMode(10, INPUT); // Sets the echoPin as an Input
  long duration;
  int distance;
  digitalWrite(9, LOW); // Clears the trigPin
  delayMicroseconds(2);
  digitalWrite(9, HIGH); // Sets the trigPin on HIGH state for 10 micro seconds
  delayMicroseconds(10);
  digitalWrite(9, LOW);
  duration = pulseIn(10, HIGH); // Reads the echoPin, returns the sound wave travel time in microseconds
  distance = (10-floor((duration * 0.034 / 2)/1.2))*10; // Calculating the distance
  //

  Serial.print("Moisture: ");
  Serial.println(value);
  Serial.print("pH: ");
  Serial.println(pH);
  Serial.print("Distance: ");
  Serial.println(distance);
  ///Firebase upload data
  //Firebase.setFloat(firebaseData, path, value); 
  //Update value mositure
  if (Firebase.setFloat(firebaseData, path + "/Moisture", value)) {
      Serial.println(firebaseData.dataPath() + " = " + value);
    }
  else {
      Serial.println("Error: " + firebaseData.errorReason());
    }

  //Update value pH
  if (Firebase.setFloat(firebaseData, path + "/pH", pH)) {
      Serial.println(firebaseData.dataPath() + " = " + pH);
    }
  else {
      Serial.println("Error: " + firebaseData.errorReason());
    }
  
  //Update value waterlevel
  if (Firebase.setFloat(firebaseData, path + "/WaterLevel", distance)) {
      Serial.println(firebaseData.dataPath() + " = " + distance);
    }
  else {
      Serial.println("Error: " + firebaseData.errorReason());
    }



//Retrive value pump
  if (Firebase.getString(firebaseData, path + "/Pump")) {
      //char Pump[3];
      String Pump = firebaseData.stringData();
      //Firebase.getString(firebaseData, path + "/Pump");    
      Serial.print("Pump Status: ");    
      Serial.println(Pump);
      if (Pump == "ON"){
        digitalWrite(RELAY_PIN, HIGH);
      }

      else{
        digitalWrite(RELAY_PIN, LOW);
      }
    }
  else {
      Serial.println("Error: " + firebaseData.errorReason());
    }
    ///Retrive value pump2
  if (Firebase.getString(firebaseData, path + "/Pump2")) {
      //char Pump[3];
      String Pump2 = firebaseData.stringData();
      //Firebase.getString(firebaseData, path + "/Pump");    
      Serial.print("Pump Status: ");    
      Serial.println(Pump2);
      if (Pump2 == "ON"){
        digitalWrite(RELAY_PIN2, HIGH);
      }

      else{
        digitalWrite(RELAY_PIN2, LOW);
      }
    }
  else {
      Serial.println("Error: " + firebaseData.errorReason());
    }
    ///Retrive value pump2
  //String Pump = Firebase.getString(firebaseData, path + "/Pump");
  
  // handle error 
  //if (Firebase.failed()) { 
    //  Serial.print("setting /message failed:"); 
      //Serial.println(Firebase.error());   
      //return; 
 // }
  ///
  //Retrive value servo
  if (Firebase.getString(firebaseData, path + "/Servo")) {
      //char Pump[3];
      String Servo = firebaseData.stringData();
      //Firebase.getString(firebaseData, path + "/Pump");    
      Serial.print("Servo Status: ");    
      Serial.println(Servo);
      if (Servo == "A"){
      
        ///pos += 180; // goes from 0 degrees to 180 degrees
        // in steps of 1 degree//
       // myservo.write(pos);              // tell servo to go to position in variable 'pos'
        //delay(15);
        //pos += 360;
        //myservo.write(pos); 
        ///     added here   

        for (int pos =90; pos <= 180; pos += 1) { 
             myservo.write(pos);              // tell servo to go to position in variable 'pos'
             delay(15);                       // waits 15ms for the servo to reach the position
                                                }
        delay(1000); // Wait for a second at 45 degrees

  // Move from 45 degrees back to 90 degrees (center) end here
        for (int pos = 180; pos >= 90; pos -= 1) { 
             myservo.write(pos);
             delay(15);
                                               }
        delay(1000); // Wait for a second at the center                                       
      }
//next here
      else if (Servo == "B"){
      
        ///pos += 180; // goes from 0 degrees to 180 degrees
        // in steps of 1 degree//
       // myservo.write(pos);              // tell servo to go to position in variable 'pos'
        //delay(15);
        //pos += 360;
        //myservo.write(pos); 
        ///     added here   

        for (int pos = 90; pos >= 0; pos -= 1) { 
             myservo.write(pos);              // tell servo to go to position in variable 'pos'
             delay(15);                       // waits 15ms for the servo to reach the position
                                                }
        delay(1000); // Wait for a second at 45 degrees

  // Move from 45 degrees back to 90 degrees (center) end here
        for (int pos = 0; pos <= 90; pos += 1) { 
             myservo.write(pos);
             delay(15);
                                               }
      }
//between here                                      
        delay(1000); // Wait for a second at the center
        if (Firebase.setString(firebaseData, path + "/Servo", "OFF")) {
            Serial.println(firebaseData.dataPath() + " = " + "OFF");
        } else {
            Serial.println("Error: " + firebaseData.errorReason());
        }
        //  if (Firebase.setString(firebaseData, path + "/Servo", "OFF")) {
          //  Serial.println(firebaseData.dataPath() + " = " + "OFF");
               //  }
          //else {
            //Serial.println("Error: " + firebaseData.errorReason());
              //   } 
                //}           
      }

    
  else {
      Serial.println("Error: " + firebaseData.errorReason());
    }

  delay(10);
}


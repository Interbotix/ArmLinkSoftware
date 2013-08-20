// Need G4P library
import g4p_controls.*;
import processing.serial.*; //import serial library to communicate with the ArbotiX

Serial sPort;            //serial object 

int numSerialPorts = Serial.list().length;
String[] serialPortString = new String[numSerialPorts];


public void setup(){
  size(250, 550, JAVA2D);
  
  for (int i=0;i<numSerialPorts;i++) 
  {
    serialPortString[i] = Serial.list()[i];
  }
  
  
  
  createGUI();
  customGUI();
  // Place your setup code here
  
}

public void draw(){
  background(230);
  
}

// Use this method to add additional statements
// to customise the GUI controls
public void customGUI(){

}

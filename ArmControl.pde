// Need G4P library
import g4p_controls.*;
import processing.serial.*; //import serial library to communicate with the ArbotiX

import java.awt.Font;


Serial sPort;            //serial object 

int numSerialPorts = Serial.list().length;
String[] serialPortString = new String[numSerialPorts+1];


public void setup(){
  size(250, 600, JAVA2D);

  
  
  createGUI();
  customGUI();
  // Place your setup code here

  serialPortString[0] = "Serial Port";
    
  for (int i=0;i<numSerialPorts;i++) 
  {
    serialPortString[i+1] = Serial.list()[i];
  }
  
    
  serialList.setItems(serialPortString, 0);
  
  
  
  
  
  wristAngleLabel.setFont(new Font("Dialog", Font.PLAIN, 10));
  
  wristRotateLabel.setFont(new Font("Dialog", Font.PLAIN, 10));
  //dropList1.setText("Peter");
  
  serialList.setFont(new Font("Dialog", Font.PLAIN, 9));
  
  
}

public void draw(){
  background(128);
  
  image(logoImg, 5, 5, 230, 78);
  
}

// Use this methologod additional statements
// to customise the GUI controls
public void customGUI(){

}

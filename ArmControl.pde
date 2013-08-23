// Need G4P library
import g4p_controls.*;
import processing.serial.*; //import serial library to communicate with the ArbotiX

import java.awt.Font;


Serial sPort;            //serial object 

int numSerialPorts = Serial.list().length;                //Number of serial ports available at startup
String[] serialPortString = new String[numSerialPorts+1];  //string array to the name of each serial port - used for populating the drop down menu
int selectedSerialPort;             //currently selected port from serialList drop down

boolean debugConsole = true; //change to 'false' to disable debuging messages to the console, 'true' to enable 
boolean debugFile = false;    //change to 'false' to disable debuging messages to a file, 'true' to enable
boolean debugGuiEvent = true;     //change to 'false' to disable GUI debuging messages, 'true' to enable
int lf = 10;    // Linefeed in ASCII

boolean updateFlag = false; //trip flag, true when the program needs to send a serial packet at the next interval
boolean autoUpdateFlag = false; //trip flag, true when the program needs to send a serial packet at the next interval
int updatePeriod = 33; //period between packet in Milliseconds , 33ms = 30Hz

long prevCommandTime = 0;    //timestamp for the last time that the program sent a serial packet
long heartbeatTime = 0;      //timestamp for the last time that the program received a serial packet from the Arm
long currentTime = 0;        //timestamp for currrent time

int connectedArmId =0;
int arbotixTimeout = 5000;  //time to wait for a response from the ArbotiX Robocontroller / Arm Control Protocol


//defualt values for pincher in normal mode 

int[] xParameters = {0,-200,200};
int xCurrent = xParameters[0]; //current x value in text field/slider
int xCurrentCommander = xParameters[0]; //current x value to be send to Commander

int[] yParameters = {200,50,240};
int yCurrent = yParameters[0]; //current y value in text field/slider
int yCurrentCommander = yParameters[0]; //current y value to be send to Commander

int[] zParameters = {200,20,250};
int zCurrent = zParameters[0]; //current z value in text field/slider
int zCurrentCommander = zParameters[0]; //current z value to be send to Commander

int[] wristAngleParameters = {0,-90,90};
int wristAngleCurrent = wristAngleParameters[0]; //current Wrist Angle value in text field/slider
int wristAngleCurrentCommander = wristAngleParameters[0]; //current Wrist Angle value to be send to Commander

int[] wristRotateParameters = {0,-512,511};
int wristRotateCurrent = wristRotateParameters[0]; //current  Wrist Rotate value in text field/slider
int wristRotateCurrentCommander = wristRotateParameters[0]; //current  Wrist Rotate value to be send to Commander

int[] gripperParameters = {256,0,512};
int gripperCurrent = gripperParameters[0]; //current Gripper value in text field/slider
int gripperCurrentCommander = gripperParameters[0]; //current Gripper value to be send to Commander

int[] deltaParameters = {125,0,256};
int deltaCurrent = deltaParameters[0]; //current delta value in text field/slider};
int deltaCurrentCommander = deltaParameters[0]; //current delta value to be send to Commander

int currentArm = 1;
int currentMode = 1;
int currentOrientation = 1;




public void setup(){
  size(250, 786, JAVA2D);

  
  
  createGUI();
  customGUI();
  // Place your setup code here

  numSerialPorts = Serial.list().length;

  serialPortString[0] = "Serial Port";
    
  for (int i=0;i<numSerialPorts;i++) 
  {
    serialPortString[i+1] = Serial.list()[i];
  }
  
    
  serialList.setItems(serialPortString, 0);
  
  
  
  
  
  wristAngleLabel.setFont(new Font("Dialog", Font.PLAIN, 10));
  
  wristRotateLabel.setFont(new Font("Dialog", Font.PLAIN, 10));
  updateButton.setFont(new Font("Dialog", Font.PLAIN, 20));
  //dropList1.setText("Peter");
  
  serialList.setFont(new Font("Dialog", Font.PLAIN, 9));
  
  arm90Button.setAlpha(128);
  
}

public void draw(){
  background(128);
  
  image(logoImg, 5, 5, 230, 78);
  image(footerImg, 15, 740);
  
  currentTime = millis();
  
  if(autoUpdateFlag == true)
  {
    switch(currentMode)
    {
       case 1:  
       
       
         xCurrentCommander = xCurrent + 512;
         yCurrentCommander = yCurrent;
         zCurrentCommander = zCurrent;
         wristAngleCurrentCommander =  wristAngleCurrent + 90;
         wristRotateCurrentCommander = wristRotateCurrent + 512;
         gripperCurrentCommander = gripperCurrent;
         deltaCurrentCommander = deltaCurrent;
         break;
        
       case 2:
       
         xCurrentCommander = xCurrent;
         yCurrentCommander = yCurrent;
         zCurrentCommander = zCurrent;
         wristAngleCurrentCommander =  wristAngleCurrent + 90;
         wristRotateCurrentCommander = wristRotateCurrent + 512;
         gripperCurrentCommander = gripperCurrent;
         deltaCurrentCommander = deltaCurrent;
         break;
        
       case 3:
       
         xCurrentCommander = xCurrent;
         yCurrentCommander = yCurrent;
         zCurrentCommander = zCurrent;
         wristAngleCurrentCommander =  wristAngleCurrent;
         wristRotateCurrentCommander = wristRotateCurrent;
         gripperCurrentCommander = gripperCurrent;
         deltaCurrentCommander = deltaCurrent;
        break; 
    }
  }
  if(currentTime - prevCommandTime > 33 & (updateFlag ==true | autoUpdateFlag ==true))
  {
    prevCommandTime = currentTime;
    updateFlag = false;
    if(sPort != null)
    {
      
      sendCommanderPacket(xCurrentCommander, yCurrentCommander, zCurrentCommander, wristAngleCurrentCommander, wristRotateCurrentCommander, gripperCurrentCommander, deltaCurrentCommander, 0, 0);  

    }
    
  }
  
  
}

// Use this methologod additional statements
// to customise the GUI controls
public void customGUI(){

}



//debugg printing. 
//type 0 = normal
//type 1 = GUI event
void printlnDebug(String message, int type)
{
   if(debugConsole == true)
   {
      if((type == 1 & debugGuiEvent == true) | type == 0)
      {
        println(message); 
      }
 
   }
   
   //if()
  
}

//wrapper for debug printing, defualt behavior = 0
void printlnDebug(String message)
{
  printlnDebug(message, 0);
  
}

//debugg printing. 
//type 0 = normal
//type 1 = GUI event
void printDebug(String message, int type)
{
   if(debugConsole == true)
   {
      if((type == 1 & debugGuiEvent == true) | type == 0)
      {
        print(message); 
      }
 
   }
   
   //if()
  
}

//wrapper for debug printing, defualt behavior = 0
void printDebug(String message)
{
  printDebug(message, 0);
  
}


//this version of readFromArm does not wait for a response - used form arm startup
byte[] readFromArmFast(int bytesExpected)
{
  return(readFromArmBase(bytesExpected,false));
}


//read a packet from the arm
byte[] readFromArm(int bytesExpected)
{
  return(readFromArmBase(bytesExpected,true));
}

//private
//read from arm code - will wait for 5 seconds or a serial data 
byte[] readFromArmBase(int bytesExpected, boolean wait)
{
  byte[] responseBytes = new byte[bytesExpected];  
  delayMs(100);//wait a period to ensure that the controller has responded 
  
  byte inByte = 0;
  long startReadingTime = millis();//time that the program started looking for data
  long last = millis();
  printDebug("Incoming Raw Packet from readDynaPacket():"); //debug
  
  //this loop will wait until the serial port has data OR it has waited more than arbotixTimeout milliseconds.
  //arbotixTimeout is a global variable
  while(wait == true & sPort.available() < bytesExpected  & millis()-startReadingTime < arbotixTimeout)
  {
  }

  

  
  
  for(int i =0; i < bytesExpected;i++)    // If data is available in the serial port, continute
  {
    if(sPort.available() > 0)
    {
      inByte = byte(sPort.readChar());
      responseBytes[i] = inByte;
      printDebug(hex(inByte) + "-"); //debug 
    }
    else
    {
      printDebug("NO BYTE-");
    }
  }//end looking for bytes from packet
  printlnDebug(" "); //debug  
  
  sPort.clear();
  
  return(responseBytes);  
  


}




boolean getArmInfo()
{
  byte[] returnPacket = new byte[5];//return id packet is 5 bytes long
  returnPacket = readFromArm(5);//read raw data from arm
  if(verifyPacket(returnPacket) == true)
  {
    connectedArmId = returnPacket[1];
    return(true) ;
  }
  else
  {
    return(false); 
  }
  
}

boolean verifyPacket(byte[] returnPacket)
{
  int packetLength = returnPacket.length;
  int tempChecksum = 0; //int for temporary checlsum calculation
  byte localChecksum; //local checksum calculated by processing
  //check header
  if(returnPacket[0] == byte(255))
  {
      for(int i = 1; i<packetLength-1;i++)
      {
        tempChecksum = int(returnPacket[i]) + tempChecksum;
      }
  
      localChecksum = byte(~(tempChecksum % 256)); //calculate checksum locally
      
      //check if calculated checksum matches the one in the packet
      if(localChecksum == returnPacket[packetLength-1])
      {
        //if the error packet is empty return a '1' for a successful packet send
        if(returnPacket[3] == 0)
        {
          //check that the arm id packet is a valid arm
          if(returnPacket[1] == 1 | returnPacket[1] == 2 |returnPacket[1] == 3)
          {
            printlnDebug("verifyPacket Success!");
            return(true);
          }
          else {printlnDebug("verifyPacket Error: Invalid Arm Detected! Arm ID:"+returnPacket[1]);}
        }
        else {printlnDebug("verifyPacket Error: Error Packet Reports:"+returnPacket[3]);}
      }
      else {printlnDebug("verifyPacket Error: Checksum does not match: Returned:"+ returnPacket[packetLength-1] +" Calculated:"+localChecksum );}
  }
  else {printlnDebug("verifyPacket Error: No Header!");}

  return(false);

}

//special function to check for the arm on startup - uses the first three bytes of the greeting message instead od the ID packer
boolean checkArmStartup()
{
  byte[] returnPacket = new byte[5];//return id packet is 5 bytes long

  printlnDebug("Sending ID Request"); 
  sendCommanderPacket(0, 200, 200, 0, 512, 256, 128, 0, 112);  
  delayMs(60);
  returnPacket = readFromArmFast(5);//read raw data from arm
  if(verifyPacket(returnPacket) == true)
  {
    currentArm = returnPacket[1];
    setPositionParameters();
    return(true) ;
  }
  else
  {
    return(false); 
  }
}

boolean isArmConnected()
{  
  byte[] returnPacket = new byte[5];//return id packet is 5 bytes long
 
 sendCommanderPacket(0, 200, 200, 0, 512, 256, 128, 0, 112);  
  returnPacket = readFromArm(5);//read raw data from arm
  if(verifyPacket(returnPacket) == true)
  {
    return(true) ;
  }
  else
  {
    return(false); 
  }
  
  
}

boolean putArmToSleep()
{
  sendCommanderPacket(0,0,0,0,0,0,0,0,96);
  
  byte[] returnPacket = new byte[5];//return id packet is 5 bytes long
  returnPacket = readFromArm(5);//read raw data from arm
  if(verifyPacket(returnPacket) == true)
  {
    return(true) ;
  }
  else
  {
    return(false); 
  }
  
  //return(true);
}


boolean changeArmMode()
{
 switch(currentMode)
  {
    case 1:
      switch(currentOrientation)
      {
        case 1:
          sendCommanderPacket(0,0,0,0,0,0,0,0,32);
          break;
        case 2:
          sendCommanderPacket(0,0,0,0,0,0,0,0,40);
          break;
      }
      break;
    case 2:
      switch(currentOrientation)
      {
        case 1:
          sendCommanderPacket(0,0,0,0,0,0,0,0,48);
          break;
        case 2:
          sendCommanderPacket(0,0,0,0,0,0,0,0,56);
          break;
      }
      break;

    case 3:
      sendCommanderPacket(0,0,0,0,0,0,0,0,64);
      break;
  } 
  
  byte[] returnPacket = new byte[5];//return id packet is 5 bytes long
  returnPacket = readFromArm(5);//read raw data from arm
  if(verifyPacket(returnPacket) == true)
  {
    return(true) ;
  }
  else
  {
    return(false); 
  }
  
}







void delayMs(int ms)
{
  int time = millis();
  while(millis()-time < ms);
}



void sendCommanderPacket(int x, int y, int z, int wristAngle, int wristRotate, int gripper, int delta, int button, int extended)
{
   sPort.clear();//clear the serial port for the next round of communications
  
  
  //retreiving the field value from each field, casting it to an int, then converting it into 2 bytes
  byte[] xValBytes = intToBytes(x);
  byte[] yValBytes = intToBytes(y);
  byte[] zValBytes =  intToBytes(z);
  byte[] wristRotValBytes =  intToBytes(wristRotate);
  byte[] wristAngleValBytes =  intToBytes(wristAngle);
  byte[] gripperValBytes = intToBytes(gripper);
  //byte[] deltaValBytes =  intToBytes(delta);
  //byte[] extValBytes =  intToBytes(x);
  byte buttonByte = byte(button);
  byte extValByte = byte(extended);

  byte deltaValByte = byte(delta);

  byte checksum = (byte)(255 - (xValBytes[1]+xValBytes[0]+yValBytes[1]+yValBytes[0]+zValBytes[1]+zValBytes[0]+wristAngleValBytes[1]+wristAngleValBytes[0]+wristRotValBytes[1]+wristRotValBytes[0]+gripperValBytes[1]+gripperValBytes[0]+deltaValByte + buttonByte+extValByte)%256);


  sPort.write(0xff);          //header
   
  sPort.write(xValBytes[1]); //X Coord High Byte
  sPort.write(xValBytes[0]); //X Coord Low Byte
  
  sPort.write(yValBytes[1]); //Y Coord High Byte
  sPort.write(yValBytes[0]); //Y Coord Low Byte
  
  sPort.write(zValBytes[1]); //Z Coord High Byte
  sPort.write(zValBytes[0]); //Z Coord Low Byte
  
  sPort.write(wristAngleValBytes[1]); //Wrist Angle High Byte
  sPort.write(wristAngleValBytes[0]); //Wrist Angle Low Byte
  
  sPort.write(wristRotValBytes[1]); //Wrist Rotate High Byte
  sPort.write(wristRotValBytes[0]); //Wrist Rotate Low Byte
  
  sPort.write(gripperValBytes[1]); //Gripper High Byte
  sPort.write(gripperValBytes[0]); //Gripper Low Byte
  
  
  
  sPort.write(deltaValByte); //Delta Low Byte
  
  sPort.write(buttonByte); //Button byte
  
  sPort.write(extValByte); //Extended instruction
  
 // sPort.write(extValBytes[0]); //Extended instruction
  
  
  sPort.write(checksum);  //checksum
   
  printlnDebug("Packet Sent: 0xFF 0x" +hex(xValBytes[1]) +" 0x" +hex(xValBytes[0]) +" 0x" +hex(yValBytes[1]) +" 0x" +hex(yValBytes[0])+" 0x" +hex(zValBytes[1])+" 0x" +hex(zValBytes[0]) +" 0x" +hex(wristAngleValBytes[1]) +" 0x" +hex(wristAngleValBytes[0]) +" 0x" + hex(wristRotValBytes[1])+" 0x" +hex(wristRotValBytes[0]) +" 0x" + hex(gripperValBytes[1])+" 0x" + hex(gripperValBytes[0])+" 0x" + hex(deltaValByte)+" 0x" +hex(buttonByte) +" 0x" +hex(extValByte) +" 0x"+hex(checksum) +""); 
         
}

byte[] intToBytes(int convertInt)
{
  byte[] returnBytes = new byte[2]; // array that holds the returned data from the registers only 
  byte mask = byte(0xff);
  returnBytes[0] =byte(convertInt & mask);//low byte
  returnBytes[1] =byte((convertInt>>8) & mask);//high byte
  return(returnBytes);
  
}

//0 -> low byte 1 -> high byte
int bytesToInt(byte[] convertBytes)
{
  return((int(convertBytes[1]<<8))+int(convertBytes[0]));//cast to int to ensureprper signed/unsigned behavior
}


// Arm
// Pincher - 1
// Reactor - 2
// WidowX -3
//
// Mode
// 1 - straight
// 2 - 90 degrees 
// 3 - cyl straight
// 4 - cyl 90
// 5 - backhoe
void setPositionParameters()
{
  //pincher, normal orinetation
  
  switch(currentArm)
  {
    case 1:
      switch(currentMode)
      {
        case 1:
          switch(currentOrientation)
          {
            case 1:        
            xSlider.setLimits( pincherNormalX[0],pincherNormalX[1],pincherNormalX[2]);    
            xTextField.setText(Integer.toString(pincherNormalX[0]));
            xLabel.setText("X Coord");
            arrayCopy(pincherNormalX,xParameters);
            
            ySlider.setLimits( pincherNormalY[0],pincherNormalY[1],pincherNormalY[2]) ; 
            yTextField.setText(Integer.toString(pincherNormalY[0]));
            xLabel.setText("Y Coord");
            arrayCopy(pincherNormalY,yParameters);
            
            zSlider.setLimits( pincherNormalZ[0],pincherNormalZ[1],pincherNormalZ[2]) ;   
            zTextField.setText(Integer.toString(pincherNormalZ[0]));
            zLabel.setText("Z Coord");
            arrayCopy(pincherNormalZ,zParameters);
            
            wristAngleSlider.setLimits(pincherNormalWristAngle[0],pincherNormalWristAngle[1],pincherNormalWristAngle[2]); 
            wristAngleTextField.setText(Integer.toString(pincherNormalWristAngle[0]));
            wristAngleLabel.setText("Wrist Angle");
            arrayCopy(pincherNormalWristAngle,wristAngleParameters);
            
            wristRotateSlider.setLimits(pincherWristRotate[0],pincherWristRotate[1],pincherWristRotate[2]) ;   
            wristRotateTextField.setText(Integer.toString(pincherWristRotate[0]));
            wristRotateLabel.setText("Wrist Rotate");
            arrayCopy(pincherWristRotate,wristRotateParameters);
            wristRotateSlider.setVisible(false);
            wristRotateTextField.setVisible(false);
            wristRotateLabel.setVisible(false);
            
            gripperSlider.setLimits( pincherGripper[0],pincherGripper[1],pincherGripper[2]);    
            gripperTextField.setText(Integer.toString(pincherGripper[0]));
            gripperLabel.setText("Gripper");
            arrayCopy(pincherGripper,gripperParameters);
            break;
            
            case 2:
            xSlider.setLimits( pincher90X[0],pincher90X[1],pincher90X[2]);    
            xTextField.setText(Integer.toString(pincher90X[0]));
            xLabel.setText("X Coord");
            arrayCopy(pincher90X,xParameters);
            
            ySlider.setLimits( pincher90Y[0],pincher90Y[1],pincher90Y[2]) ; 
            yTextField.setText(Integer.toString(pincher90Y[0]));
            yLabel.setText("Y Coord");
            arrayCopy(pincher90Y,yParameters);
            
            zSlider.setLimits( pincher90Z[0],pincher90Z[1],pincher90Z[2]) ;   
            zTextField.setText(Integer.toString(pincher90Z[0]));
            zLabel.setText("Z Coord");
            arrayCopy(pincher90Z,zParameters);
            
            wristAngleSlider.setLimits(pincher90WristAngle[0],pincher90WristAngle[1],pincher90WristAngle[2]); 
            wristAngleTextField.setText(Integer.toString(pincher90WristAngle[0]));
            wristAngleLabel.setText("Wrist Angle");
            arrayCopy(pincher90WristAngle,wristAngleParameters);
            
            wristRotateSlider.setLimits(pincherWristRotate[0],pincherWristRotate[1],pincherWristRotate[2]) ;   
            wristRotateTextField.setText(Integer.toString(pincherWristRotate[0]));
            wristRotateLabel.setText("Wrist Rotate");
            arrayCopy(pincherWristRotate,wristRotateParameters);
            wristRotateSlider.setVisible(false);
            wristRotateTextField.setVisible(false);
            wristRotateLabel.setVisible(false);
            
            gripperSlider.setLimits( pincherGripper[0],pincherGripper[1],pincherGripper[2]);    
            gripperTextField.setText(Integer.toString(pincherGripper[0]));
            gripperLabel.setText("Gripper");
            arrayCopy(pincherGripper,gripperParameters);
        
            break;
            
          }
          break;
          
        case 2:
          switch(currentOrientation)
          {
            case 1: 
              xSlider.setLimits( pincherBase[0],pincherBase[1],pincherBase[2]);    
              xTextField.setText(Integer.toString(pincherBase[0]));
              xLabel.setText("Base");
              arrayCopy(pincherBase,xParameters);
              
              ySlider.setLimits( pincherNormalY[0],pincherNormalY[1],pincherNormalY[2]) ; 
              yTextField.setText(Integer.toString(pincherNormalY[0]));
              yLabel.setText("Y Coord");
              arrayCopy(pincherNormalY,yParameters);
              
              zSlider.setLimits( pincherNormalZ[0],pincherNormalZ[1],pincherNormalZ[2]) ;   
              zTextField.setText(Integer.toString(pincherNormalZ[0]));
              zLabel.setText("Z Coord");
              arrayCopy(pincherNormalZ,zParameters);
              
              wristAngleSlider.setLimits(pincherNormalWristAngle[0],pincherNormalWristAngle[1],pincherNormalWristAngle[2]); 
              wristAngleTextField.setText(Integer.toString(pincherNormalWristAngle[0]));
              wristAngleLabel.setText("Wrist Angle");
              arrayCopy(pincherNormalWristAngle,wristAngleParameters);
              
              wristRotateSlider.setLimits(pincherWristRotate[0],pincherWristRotate[1],pincherWristRotate[2]) ;   
              wristRotateTextField.setText(Integer.toString(pincherWristRotate[0]));
              wristRotateLabel.setText("Wrist Rotate");
              arrayCopy(pincherWristRotate,wristRotateParameters);
              wristRotateSlider.setVisible(false);
              wristRotateTextField.setVisible(false);
              wristRotateLabel.setVisible(false);
              
              
              gripperSlider.setLimits( pincherGripper[0],pincherGripper[1],pincherGripper[2]);    
              gripperTextField.setText(Integer.toString(pincherGripper[0]));
              gripperLabel.setText("Gripper");
              arrayCopy(pincherGripper,gripperParameters);
           
              break;
              
            case 2:  
              xSlider.setLimits( pincherBase[0],pincherBase[1],pincherBase[2]);    
              xTextField.setText(Integer.toString(pincherBase[0]));
              xLabel.setText("Base");
              arrayCopy(pincherBase,xParameters);
              
              ySlider.setLimits( pincher90Y[0],pincher90Y[1],pincher90Y[2]) ; 
              yTextField.setText(Integer.toString(pincher90Y[0]));
              yLabel.setText("Y Coord");
              arrayCopy(pincher90Y,yParameters);
              
              zSlider.setLimits( pincher90Z[0],pincher90Z[1],pincher90Z[2]) ;   
              zTextField.setText(Integer.toString(pincher90Z[0]));
              zLabel.setText("Z Coord");
              arrayCopy(pincher90Z,zParameters);
              
              wristAngleSlider.setLimits(pincher90WristAngle[0],pincher90WristAngle[1],pincher90WristAngle[2]); 
              wristAngleTextField.setText(Integer.toString(pincher90WristAngle[0]));
              wristAngleLabel.setText("Wrist Angle");
              arrayCopy(pincher90WristAngle,wristAngleParameters);
              
              wristRotateSlider.setLimits(pincherWristRotate[0],pincherWristRotate[1],pincherWristRotate[2]) ;   
              wristRotateTextField.setText(Integer.toString(pincherWristRotate[0]));
              wristRotateLabel.setText("Wrist Rotate");
              arrayCopy(pincherWristRotate,wristRotateParameters);
              wristRotateSlider.setVisible(false);
              wristRotateTextField.setVisible(false);
              wristRotateLabel.setVisible(false);
              
              
              gripperSlider.setLimits( pincherGripper[0],pincherGripper[1],pincherGripper[2]);    
              gripperTextField.setText(Integer.toString(pincherGripper[0]));
              gripperLabel.setText("Gripper");
              arrayCopy(pincherGripper,gripperParameters);
          
           
              break; 
          }

          break;

        case 3: 
        
        
          xSlider.setLimits( pincherBase[0],pincherBase[1],pincherBase[2]);    
          xTextField.setText(Integer.toString(pincherBase[0]));
          xLabel.setText("Base");
          arrayCopy(pincherBase,xParameters);
          
          ySlider.setLimits( pincherBHShoulder[0],pincherBHShoulder[1],pincherBHShoulder[2]) ; 
          yTextField.setText(Integer.toString(pincherBHShoulder[0]));
          yLabel.setText("Shoulder");
          arrayCopy(pincherBHShoulder,yParameters);
          
          zSlider.setLimits( pincherBHElbow[0],pincherBHElbow[1],pincherBHElbow[2]) ;   
          zTextField.setText(Integer.toString(pincherBHElbow[0]));
          zLabel.setText("Elbow");
          arrayCopy(pincherBHElbow,zParameters);
          
          wristAngleSlider.setLimits(pincherBHWristAngle[0],pincherBHWristAngle[1],pincherBHWristAngle[2]); 
          wristAngleTextField.setText(Integer.toString(pincherBHWristAngle[0]));
          wristAngleLabel.setText("Wrist Angle");
          arrayCopy(pincherBHWristAngle,wristAngleParameters);
          
          wristRotateSlider.setLimits(pincherBHWristRot[0],pincherBHWristRot[1],pincherBHWristRot[2]) ;   
          wristRotateTextField.setText(Integer.toString(pincherBHWristRot[0]));
          wristRotateLabel.setText("Wrist Rotate");
          arrayCopy(pincherBHWristRot,wristRotateParameters);
          wristRotateSlider.setVisible(false);
          wristRotateTextField.setVisible(false);
          wristRotateLabel.setVisible(false);
          
          
          gripperSlider.setLimits( pincherGripper[0],pincherGripper[1],pincherGripper[2]);    
          gripperTextField.setText(Integer.toString(pincherGripper[0]));
          gripperLabel.setText("Gripper");
          arrayCopy(pincherGripper,gripperParameters);
      
        break;
     }
    break;//end pincher arm 

        
    //reactor arm 
    case 2:
      switch(currentMode)
      {
        //cartesian mode reactor arm
        case 1:
          switch(currentOrientation)
          {
            //normal orientation reactor arm arm cartesian
            case 1:        
      
        xSlider.setLimits( reactorNormalX[0],reactorNormalX[1],reactorNormalX[2]);    
        xTextField.setText(Integer.toString(reactorNormalX[0]));
        xLabel.setText("X Coord");
        arrayCopy(reactorNormalX,xParameters);
        
        ySlider.setLimits( reactorNormalY[0],reactorNormalY[1],reactorNormalY[2]) ; 
        yTextField.setText(Integer.toString(reactorNormalY[0]));
        yLabel.setText("Y Coord");
        arrayCopy(reactorNormalY,yParameters);
        
        zSlider.setLimits( reactorNormalZ[0],reactorNormalZ[1],reactorNormalZ[2]) ;   
        zTextField.setText(Integer.toString(reactorNormalZ[0]));
        zLabel.setText("Z Coord");
        arrayCopy(reactorNormalZ,zParameters);
        
        wristAngleSlider.setLimits(reactorNormalWristAngle[0],reactorNormalWristAngle[1],reactorNormalWristAngle[2]); 
        wristAngleTextField.setText(Integer.toString(reactorNormalWristAngle[0]));
        wristAngleLabel.setText("Wrist Angle");
        arrayCopy(reactorNormalWristAngle,wristAngleParameters);
        
        wristRotateSlider.setLimits(reactorWristRotate[0],reactorWristRotate[1],reactorWristRotate[2]) ;   
        wristRotateTextField.setText(Integer.toString(reactorWristRotate[0]));
        wristRotateLabel.setText("Wrist Rotate");
        arrayCopy(reactorWristRotate,wristRotateParameters);
        wristRotateSlider.setVisible(true);
        wristRotateTextField.setVisible(true);
        wristRotateLabel.setVisible(true);
        
        
        gripperSlider.setLimits( reactorGripper[0],reactorGripper[1],reactorGripper[2]);    
        gripperTextField.setText(Integer.toString(reactorGripper[0]));
        gripperLabel.setText("Gripper");
        arrayCopy(reactorGripper,gripperParameters);
              break;//end  normal orientation reactor arm arm cartesian
            
            //90 degree mode reactor arm cartesian
      case 2:
        xSlider.setLimits( reactor90X[0],reactor90X[1],reactor90X[2]);    
        xTextField.setText(Integer.toString(reactor90X[0]));
        xLabel.setText("X Coord");
        arrayCopy(reactor90X,xParameters);
        
        ySlider.setLimits( reactor90Y[0],reactor90Y[1],reactor90Y[2]) ; 
        yTextField.setText(Integer.toString(reactor90Y[0]));
        yLabel.setText("Y Coord");
        arrayCopy(reactor90Y,yParameters);
        
        zSlider.setLimits( reactor90Z[0],reactor90Z[1],reactor90Z[2]) ;   
        zTextField.setText(Integer.toString(reactor90Z[0]));
        zLabel.setText("Z Coord");
        arrayCopy(reactor90Z,zParameters);
        
        wristAngleSlider.setLimits(reactor90WristAngle[0],reactor90WristAngle[1],reactor90WristAngle[2]); 
        wristAngleTextField.setText(Integer.toString(reactor90WristAngle[0]));
        wristAngleLabel.setText("Wrist Angle");
        arrayCopy(reactor90WristAngle,wristAngleParameters);
        
        wristRotateSlider.setLimits(reactorWristRotate[0],reactorWristRotate[1],reactorWristRotate[2]) ;   
        wristRotateTextField.setText(Integer.toString(reactorWristRotate[0]));
        wristRotateLabel.setText("Wrist Rotate");
        arrayCopy(reactorWristRotate,wristRotateParameters);
        wristRotateSlider.setVisible(true);
        wristRotateTextField.setVisible(true);
        wristRotateLabel.setVisible(true);
        
        
        gripperSlider.setLimits( reactorGripper[0],reactorGripper[1],reactorGripper[2]);    
        gripperTextField.setText(Integer.toString(reactorGripper[0]));
        gripperLabel.setText("Gripper");
        arrayCopy(reactorGripper,gripperParameters);
        break;//end 90 degree mode reactor arm cartesian
            
          }
          break;//end  reactor arm
          
        //cylcindrical reactor arm  
        case 2:
          switch(currentOrientation)
          {
            //normal orientation reactor arm cylcindrical
            case 1: 
        xSlider.setLimits( reactorBase[0],reactorBase[1],reactorBase[2]);    
        xTextField.setText(Integer.toString(reactorBase[0]));
        xLabel.setText("Base");
        arrayCopy(reactorBase,xParameters);
        
        ySlider.setLimits( reactorNormalY[0],reactorNormalY[1],reactorNormalY[2]) ; 
        yTextField.setText(Integer.toString(reactorNormalY[0]));
        yLabel.setText("Y Coord");
        arrayCopy(reactorNormalY,yParameters);
        
        zSlider.setLimits( reactorNormalZ[0],reactorNormalZ[1],reactorNormalZ[2]) ;   
        zTextField.setText(Integer.toString(reactorNormalZ[0]));
        zLabel.setText("Z Coord");
        arrayCopy(reactorNormalZ,zParameters);
        
        wristAngleSlider.setLimits(reactorNormalWristAngle[0],reactorNormalWristAngle[1],reactorNormalWristAngle[2]); 
        wristAngleTextField.setText(Integer.toString(reactorNormalWristAngle[0]));
        wristAngleLabel.setText("Wrist Angle");
        arrayCopy(reactorNormalWristAngle,wristAngleParameters);
        
        wristRotateSlider.setLimits(reactorWristRotate[0],reactorWristRotate[1],reactorWristRotate[2]) ;   
        wristRotateTextField.setText(Integer.toString(reactorWristRotate[0]));
        wristRotateLabel.setText("Wrist Rotate");
        arrayCopy(reactorWristRotate,wristRotateParameters);
        wristRotateSlider.setVisible(true);
        wristRotateTextField.setVisible(true);
        wristRotateLabel.setVisible(true);
        
        
        gripperSlider.setLimits( reactorGripper[0],reactorGripper[1],reactorGripper[2]);    
        gripperTextField.setText(Integer.toString(reactorGripper[0]));
        gripperLabel.setText("Gripper");
        arrayCopy(reactorGripper,gripperParameters);
        break;//end  reactor arm
              
            //90 degree orientation reactor arm cylcindrical
            case 2:  
        xSlider.setLimits( reactorBase[0],reactorBase[1],reactorBase[2]);    
        xTextField.setText(Integer.toString(reactorBase[0]));
        xLabel.setText("Base");
        arrayCopy(reactorBase,xParameters);
        
        ySlider.setLimits( reactor90Y[0],reactor90Y[1],reactor90Y[2]) ; 
        yTextField.setText(Integer.toString(reactor90Y[0]));
        yLabel.setText("Y Coord");
        arrayCopy(reactor90Y,yParameters);
        
        zSlider.setLimits( reactor90Z[0],reactor90Z[1],reactor90Z[2]) ;   
        zTextField.setText(Integer.toString(reactor90Z[0]));
        zLabel.setText("Z Coord");
        arrayCopy(reactor90Z,zParameters);
        
        wristAngleSlider.setLimits(reactor90WristAngle[0],reactor90WristAngle[1],reactor90WristAngle[2]); 
        wristAngleTextField.setText(Integer.toString(reactor90WristAngle[0]));
        wristAngleLabel.setText("Wrist Angle");
        arrayCopy(reactor90WristAngle,wristAngleParameters);
        
        wristRotateSlider.setLimits(reactorWristRotate[0],reactorWristRotate[1],reactorWristRotate[2]) ;   
        wristRotateTextField.setText(Integer.toString(reactorWristRotate[0]));
        wristRotateLabel.setText("Wrist Rotate");
        arrayCopy(reactorWristRotate,wristRotateParameters);
        wristRotateSlider.setVisible(true);
        wristRotateTextField.setVisible(true);
        wristRotateLabel.setVisible(true);
        
        
        gripperSlider.setLimits( reactorGripper[0],reactorGripper[1],reactorGripper[2]);    
        gripperTextField.setText(Integer.toString(reactorGripper[0]));
        gripperLabel.setText("Gripper");
        arrayCopy(reactorGripper,gripperParameters);
        break;//end  90 degree orientation reactor arm cylcindrical
          
          }

          break;//end  cylcindrical reactor arm  

          
    //backhoe mode reactor arm
        case 3: 
        
          xSlider.setLimits( reactorBase[0],reactorBase[1],reactorBase[2]);    
          xTextField.setText(Integer.toString(reactorBase[0]));
          xLabel.setText("Base");
          arrayCopy(reactorBase,xParameters);
          
          ySlider.setLimits( reactorBHShoulder[0],reactorBHShoulder[1],reactorBHShoulder[2]) ; 
          yTextField.setText(Integer.toString(reactorBHShoulder[0]));
          yLabel.setText("Shoulder");
          arrayCopy(reactorBHShoulder,yParameters);
          
          zSlider.setLimits( reactorBHElbow[0],reactorBHElbow[1],reactorBHElbow[2]) ;   
          zTextField.setText(Integer.toString(reactorBHElbow[0]));
          zLabel.setText("Elbow");
          arrayCopy(reactorBHElbow,zParameters);
          
          wristAngleSlider.setLimits(reactorBHWristAngle[0],reactorBHWristAngle[1],reactorBHWristAngle[2]); 
          wristAngleTextField.setText(Integer.toString(reactorBHWristAngle[0]));
          wristAngleLabel.setText("Wrist Angle");
          arrayCopy(reactorBHWristAngle,wristAngleParameters);
          
          wristRotateSlider.setLimits(reactorBHWristRot[0],reactorBHWristRot[1],reactorBHWristRot[2]) ;   
          wristRotateTextField.setText(Integer.toString(reactorBHWristRot[0]));
          wristRotateLabel.setText("Wrist Rotate");
          arrayCopy(reactorBHWristRot,wristRotateParameters);
          wristRotateSlider.setVisible(true);
          wristRotateTextField.setVisible(true);
          wristRotateLabel.setVisible(true);
          
          
          gripperSlider.setLimits( reactorGripper[0],reactorGripper[1],reactorGripper[2]);    
          gripperTextField.setText(Integer.toString(reactorGripper[0]));
          gripperLabel.setText("Gripper");
          arrayCopy(reactorGripper,gripperParameters);
          break;//end backhoe mode reactor arm
     }
    break;//end reactor arm 
    
      
      
      
        
    //widow arm 
    case 3:
      switch(currentMode)
      {
        //cartesian mode widow arm
        case 1:
          switch(currentOrientation)
          {
            //normal orientation widow arm arm cartesian
            case 1:        
      
        xSlider.setLimits( widowNormalX[0],widowNormalX[1],widowNormalX[2]);    
        xTextField.setText(Integer.toString(widowNormalX[0]));
        xLabel.setText("X Coord");
        arrayCopy(widowNormalX,xParameters);
        
        ySlider.setLimits( widowNormalY[0],widowNormalY[1],widowNormalY[2]) ; 
        yTextField.setText(Integer.toString(widowNormalY[0]));
        yLabel.setText("Y Coord");
        arrayCopy(widowNormalY,yParameters);
        
        zSlider.setLimits( widowNormalZ[0],widowNormalZ[1],widowNormalZ[2]) ;   
        zTextField.setText(Integer.toString(widowNormalZ[0]));
        zLabel.setText("Z Coord");
        arrayCopy(widowNormalZ,zParameters);
        
        wristAngleSlider.setLimits(widowNormalWristAngle[0],widowNormalWristAngle[1],widowNormalWristAngle[2]); 
        wristAngleTextField.setText(Integer.toString(widowNormalWristAngle[0]));
        wristAngleLabel.setText("Wrist Angle");
        arrayCopy(widowNormalWristAngle,wristAngleParameters);
        
        wristRotateSlider.setLimits(widowWristRotate[0],widowWristRotate[1],widowWristRotate[2]) ;   
        wristRotateTextField.setText(Integer.toString(widowWristRotate[0]));
        wristRotateLabel.setText("Wrist Rotate");
        arrayCopy(widowWristRotate,wristRotateParameters);
        wristRotateSlider.setVisible(true);
        wristRotateTextField.setVisible(true);
        wristRotateLabel.setVisible(true);
        
        
        gripperSlider.setLimits( widowGripper[0],widowGripper[1],widowGripper[2]);    
        gripperTextField.setText(Integer.toString(widowGripper[0]));
        gripperLabel.setText("Gripper");
        arrayCopy(widowGripper,gripperParameters);
        break;
        
            
            //90 degree mode widow arm cartesian
      case 2:
      
        xSlider.setLimits( widow90X[0],widow90X[1],widow90X[2]);    
        xTextField.setText(Integer.toString(widow90X[0]));
        xLabel.setText("X Coord");
        arrayCopy(widow90X,xParameters);
        
        ySlider.setLimits( widow90Y[0],widow90Y[1],widow90Y[2]) ; 
        yTextField.setText(Integer.toString(widow90Y[0]));
        yLabel.setText("Y Coord");
        arrayCopy(widow90Y,yParameters);
        
        zSlider.setLimits( widow90Z[0],widow90Z[1],widow90Z[2]) ;   
        zTextField.setText(Integer.toString(widow90Z[0]));
        zLabel.setText("Z Coord");
        arrayCopy(widow90Z,zParameters);
        
        wristAngleSlider.setLimits(widow90WristAngle[0],widow90WristAngle[1],widow90WristAngle[2]); 
        wristAngleTextField.setText(Integer.toString(widow90WristAngle[0]));
        wristAngleLabel.setText("Wrist Angle");
        arrayCopy(widow90WristAngle,wristAngleParameters);
        
        wristRotateSlider.setLimits(widowWristRotate[0],widowWristRotate[1],widowWristRotate[2]) ;   
        wristRotateTextField.setText(Integer.toString(widowWristRotate[0]));
        wristRotateLabel.setText("Wrist Rotate");
        arrayCopy(widowWristRotate,wristRotateParameters);
        wristRotateSlider.setVisible(true);
        wristRotateTextField.setVisible(true);
        wristRotateLabel.setVisible(true);
        
        
        gripperSlider.setLimits( widowGripper[0],widowGripper[1],widowGripper[2]);    
        gripperTextField.setText(Integer.toString(widowGripper[0]));
        gripperLabel.setText("Gripper");
        arrayCopy(widowGripper,gripperParameters);
        break;
        
          }
          break;//end  widow arm
          
        //cylcindrical widow arm  
        case 2:
          switch(currentOrientation)
          {
            //normal orientation widow arm cylcindrical
            case 1: 
        
      
        xSlider.setLimits( widowBase[0],widowBase[1],widowBase[2]);    
        xTextField.setText(Integer.toString(widowBase[0]));
        xLabel.setText("Base");
        arrayCopy(widowBase,xParameters);
        
        ySlider.setLimits( widowNormalY[0],widowNormalY[1],widowNormalY[2]) ; 
        yTextField.setText(Integer.toString(widowNormalY[0]));
        yLabel.setText("Y Coord");
        arrayCopy(widowNormalY,yParameters);
        
        zSlider.setLimits( widowNormalZ[0],widowNormalZ[1],widowNormalZ[2]) ;   
        zTextField.setText(Integer.toString(widowNormalZ[0]));
        zLabel.setText("Z Coord");
        arrayCopy(widowNormalZ,zParameters);
        
        wristAngleSlider.setLimits(widowNormalWristAngle[0],widowNormalWristAngle[1],widowNormalWristAngle[2]); 
        wristAngleTextField.setText(Integer.toString(widowNormalWristAngle[0]));
        wristAngleLabel.setText("Wrist Angle");
        arrayCopy(widowNormalWristAngle,wristAngleParameters);
        
        wristRotateSlider.setLimits(widowWristRotate[0],widowWristRotate[1],widowWristRotate[2]) ;   
        wristRotateTextField.setText(Integer.toString(widowWristRotate[0]));
        wristRotateLabel.setText("Wrist Rotate");
        arrayCopy(widowWristRotate,wristRotateParameters);
        wristRotateSlider.setVisible(true);
        wristRotateTextField.setVisible(true);
        wristRotateLabel.setVisible(true);
        
        
        gripperSlider.setLimits( widowGripper[0],widowGripper[1],widowGripper[2]);    
        gripperTextField.setText(Integer.toString(widowGripper[0]));
        gripperLabel.setText("Gripper");
        arrayCopy(widowGripper,gripperParameters);
        break;
        //90 degree orientation widow arm cylcindrical

            case 2:  
      
        xSlider.setLimits( widowBase[0],widowBase[1],widowBase[2]);    
        xTextField.setText(Integer.toString(widowBase[0]));
        xLabel.setText("Base");
        arrayCopy(widowBase,xParameters);
        
        ySlider.setLimits( widow90Y[0],widow90Y[1],widow90Y[2]) ; 
        yTextField.setText(Integer.toString(widow90Y[0]));
        yLabel.setText("Y Coord");
        arrayCopy(widow90Y,yParameters);
        
        zSlider.setLimits( widow90Z[0],widow90Z[1],widow90Z[2]) ;   
        zTextField.setText(Integer.toString(widow90Z[0]));
        zLabel.setText("Z Coord");
        arrayCopy(widow90Z,zParameters);
        
        wristAngleSlider.setLimits(widow90WristAngle[0],widow90WristAngle[1],widow90WristAngle[2]); 
        wristAngleTextField.setText(Integer.toString(widow90WristAngle[0]));
        wristAngleLabel.setText("Wrist Angle");
        arrayCopy(widow90WristAngle,wristAngleParameters);
        
        wristRotateSlider.setLimits(widowWristRotate[0],widowWristRotate[1],widowWristRotate[2]) ;   
        wristRotateTextField.setText(Integer.toString(widowWristRotate[0]));
        wristRotateLabel.setText("Wrist Rotate");
        arrayCopy(widowWristRotate,wristRotateParameters);
        wristRotateSlider.setVisible(true);
        wristRotateTextField.setVisible(true);
        wristRotateLabel.setVisible(true);
        
        
        gripperSlider.setLimits( widowGripper[0],widowGripper[1],widowGripper[2]);    
        gripperTextField.setText(Integer.toString(widowGripper[0]));
        gripperLabel.setText("Gripper");
        arrayCopy(widowGripper,gripperParameters);
        break;
          
          }

          break;//end  cylcindrical widow arm  

          
    //backhoe mode widow arm
        case 3: 
          xSlider.setLimits( widowBase[0],widowBase[1],widowBase[2]);    
          xTextField.setText(Integer.toString(widowBase[0]));
          xLabel.setText("Base");
          arrayCopy(widowBase,xParameters);
          
          ySlider.setLimits( widowBHShoulder[0],widowBHShoulder[1],widowBHShoulder[2]) ; 
          yTextField.setText(Integer.toString(widowBHShoulder[0]));
          yLabel.setText("Shoulder");
          arrayCopy(widowBHShoulder,yParameters);
          
          zSlider.setLimits( widowBHElbow[0],widowBHElbow[1],widowBHElbow[2]) ;   
          zTextField.setText(Integer.toString(widowBHElbow[0]));
          zLabel.setText("Elbow");
          arrayCopy(widowBHElbow,zParameters);
          
          wristAngleSlider.setLimits(widowBHWristAngle[0],widowBHWristAngle[1],widowBHWristAngle[2]); 
          wristAngleTextField.setText(Integer.toString(widowBHWristAngle[0]));
          wristAngleLabel.setText("Wrist Angle");
          arrayCopy(widowBHWristAngle,wristAngleParameters);
          
          wristRotateSlider.setLimits(widowBHWristRot[0],widowBHWristRot[1],widowBHWristRot[2]) ;   
          wristRotateTextField.setText(Integer.toString(widowBHWristRot[0]));
          wristRotateLabel.setText("Wrist Rotate");
          arrayCopy(widowBHWristRot,wristRotateParameters);
          wristRotateSlider.setVisible(true);
          wristRotateTextField.setVisible(true);
          wristRotateLabel.setVisible(true);
          
          
          gripperSlider.setLimits( widowGripper[0],widowGripper[1],widowGripper[2]);    
          gripperTextField.setText(Integer.toString(widowGripper[0]));
          gripperLabel.setText("Gripper");
          arrayCopy(widowGripper,gripperParameters);
          break;
     }
    break;//end widow arm 
    
 
 
  }
  
  
  xCurrent = xParameters[0]; //current x value in text field/slider
  
  
  yCurrent = yParameters[0]; //current y value in text field/slider
  
  
  zCurrent = zParameters[0]; //current z value in text field/slider
  
  wristAngleCurrent = wristAngleParameters[0]; //current Wrist Angle value in text field/slider
  
  wristRotateCurrent = wristRotateParameters[0]; //current  Wrist Rotate value in text field/slider
  
  gripperCurrent = gripperParameters[0]; //current Gripper value in text field/slider
  
  deltaCurrent = deltaParameters[0]; //current delta value in text field/slider};
  
  
}

void stop()
{
 putArmToSleep(); 
}



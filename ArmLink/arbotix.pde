/***********************************************************************************
 *  }--\     InterbotiX     /--{
 *      |    Arm Link      |
 *   __/                    \__
 *  |__|                    |__|
 *
 *  arbotix.pde
 *	
 *	This file has several functions for interfacing with the ArbotiX robocontroller
 *	using the ArmLink protocol. 
 *	See 'ArmLnk.pde' for building this application.
 *
 ***********************************************************************************/


/******************************************************
 *  readFromArm(int, boolean)
 *
 *  reads data back from the ArbotiX/Arm
 *
 *  Normally this is called from readFromArm(int) - 
 *  this will block the program and make it wait 
 * 'packetRepsonseTimeout' ms. Most of the time the program
 *  will need to wait, as the arm is moving to a position
 *  and will not send a response packet until it has 
 *  finished moving to that position.
 *  
 *  However this will add a lot of time to the 'autoSearch' 
 *  functionality. When the arm starts up it will immediatley send a
 *  ID packet to identify itself so a non-waiting version is   
 *  avaialble -  readFromArmFast(int) which is equivalent to
 *  readFromArm(int, false)
 *
 *  Parameters:
 *    int bytesExpected
 *      # of bytes expected in the response packet
 *    boolean wait
 *        Whether or not to wait 'packetRepsonseTimeout' ms for a response
 *         true = wait
 *         false = do not wait
 *  Globals Used:
 *      Serial sPort
 *      long packetRepsonseTimeout
 *
 *  Returns: 
 *    byte[]  responseBytes
 *      byte array with response data from ArbotiX/Arm
 ******************************************************/ 
byte[] readFromArm(int bytesExpected, boolean wait)
{
  byte[] responseBytes = new byte[bytesExpected];    //byte array to hold response data
  delayMs(100);//wait a minimum 100ms to ensure that the controller has responded - this applies to both wait==true and wait==false conditions
  
  byte bufferByte = 0;  //current byte that is being read
  long startReadingTime = millis();//time that the program started looking for data
  
  printDebug("Incoming Raw Packet from readFromArm():",2); //debug
  
  //if the 'wait' flag is TRUE this loop will wait until the serial port has data OR it has waited more than packetRepsonseTimeout milliseconds.
  //packetRepsonseTimeout is a global variable
  
  while(wait == true & sPorts[armPortIndex].available() < bytesExpected  & millis()-startReadingTime < packetRepsonseTimeout)
  {
     //do nothing, just waiting for a response or timeout
  }
  
  for(int i =0; i < bytesExpected;i++)    
  {
    // If data is available in the serial port, continute
    if(sPorts[armPortIndex].available() > 0)
    {
      bufferByte = byte(sPorts[armPortIndex].readChar());
      responseBytes[i] = bufferByte;
      printDebug(hex(bufferByte) + "-",2); //debug 
    }
    else
    {
      printDebug("NO BYTE-");//debug
    }
  }//end looking for bytes from packet
  printlnDebug(" ",2); //debug  finish line
  
  sPorts[armPortIndex].clear();  //clear serial port for the next read
  
  return(responseBytes);  //return serial data
}


//wrapper for readFromArm(int, boolean)
//assume normal behavior, wait = true
byte[] readFromArm(int bytesExpected)
{
  return(readFromArm(bytesExpected,true));
}


//wrapper for readFromArm(int, boolean)
//wait = false. Used for autosearch/startup
byte[] readFromArmFast(int bytesExpected)
{
  return(readFromArm(bytesExpected,false));
}




/******************************************************
 *  verifyPacket(int, boolean)
 *
 *  verifies a packet received from the ArbotiX/Arm
 *
 *  This function will do the following to verify a packet
 *  -calculate a local checksum and compare it to the
 *    transmitted checksum 
 *  -check the error byte for any data 
 *  -check that the armID is supported by this program
 *
 *  Parameters:
 *    byte[]  returnPacket
 *      byte array with response data from ArbotiX/Arm
 *
 *
 *  Returns: 
 *    boolean verifyPacket
 *      true = packet is OK
 *      false = problem with the packet
 *
 *  TODO: -Modify to return specific error messages
 *        -Make the arm ID check modular to facilitate 
 *         adding new arms.
 ******************************************************/ 
boolean verifyPacket(byte[] returnPacket)
{
  int packetLength = returnPacket.length;  //length of the packet
  int tempChecksum = 0; //int for temporary checksum calculation
  byte localChecksum; //local checksum calculated by processing
  
  printDebug("Begin Packet Verification of :");
  for(int i = 0; i < packetLength;i++)
  {
    printDebug(returnPacket[i]+":");
  }
  //check header, which should always be 255/0xff
  if(returnPacket[0] == byte(255))
  {  
      //iterate through bytes # 1 through packetLength-1 (do not include header(0) or checksum(packetLength)
      for(int i = 1; i<packetLength-1;i++)
      {
        tempChecksum = int(returnPacket[i]) + tempChecksum;//add byte value to checksum
      }
  
      localChecksum = byte(~(tempChecksum % 256)); //calculate checksum locally - modulus 256 to islotate bottom byte, then invert(~)
      
      //check if calculated checksum matches the one in the packet
      if(localChecksum == returnPacket[packetLength-1])
      {
        //check is the error packet is 0, which indicates no error
        if(returnPacket[3] == 0)
        {
          //check that the arm id packet is a valid arm
          if(returnPacket[1] == 1 || returnPacket[1] == 2 || returnPacket[1] == 3 || returnPacket[1] == 5)
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

/******************************************************
 *  checkArmStartup()
 *
 *  function used to check for the presense of a 
 *  ArbotiX/Arm on a serial port. 
 
 *  This function also sets the initial Global 'currentArm'
 *
 *  Parameters:
 *    None
 *
 *  Globals used:
 *    int currentArm
 *
 *  Returns: 
 *    boolean 
 *      true = arm has been detected on current serial port
 *      false = no arm detected on current serial port
 *
 ******************************************************/ 
boolean checkArmStartup()
{
  byte[] returnPacket = new byte[5];  //byte array to hold return packet, which is 5 bytes long
  long startTime = millis();
  long currentTime = startTime;
  printlnDebug("Checking for arm on startup "); 
  while(currentTime - startTime < startupWaitTime )
  {
    delayMs(100);  //The ArbotiX has a delay of 50ms between starting the serial continueing the program, include an extra 10ms for other ArbotiX startup tasks
    for(int i = 0; i< sPorts.length;i++)
    {  
      if(sPorts[i] != null)
      {
        armPortIndex = i;
        
        printlnDebug("Checking for arm on startup - index# " + i); 
        sendCommanderPacket(0, 200, 200, 0, 512, 256, 128, 0, 112);    //send a commander style packet - the first 8 bytes are inconsequntial, only the last byte matters. '112' is the extended byte that will request an ID packet
        returnPacket = readFromArmFast(5);//read raw data from arm, complete with wait time
        
        if(verifyPacket(returnPacket) == true)
        {
          currentArm = returnPacket[1]; //set the current arm based on the return packet
          printlnDebug("Startup Arm #" +currentArm+ " Found"); 
          setPositionParameters();      //set the GUI default/min/maxes and field lables
          
          return(true) ;                //Return a true signal to signal that an arm has been found
        }
      }
    }

    currentTime = millis();
  }  
  armPortIndex = -1;
  return(false);
 

}


/******************************************************
 *  isArmConnected()
 *
 *  generic function to check for the presence of an arm
 *  during normal operation.
 *
 *  Parameters:
 *    None
 *
 *  Globals used:
 *    int currentArm
 *
 *  Returns: 
 *    boolean 
 *      true = arm has been detected on current serial port
 *      false = no arm detected on current serial port
 *
 ******************************************************/ 
boolean isArmConnected()
{  
  byte[] returnPacket = new byte[5];//return id packet is 5 bytes long
 
  printlnDebug("Checking for arm -  sending packet"); 
  sendCommanderPacket(0, 200, 200, 0, 512, 256, 128, 0, 112);    //send a commander style packet - the first 8 bytes are inconsequntial, only the last byte matters. '112' is the extended byte that will request an ID packet
  
  returnPacket = readFromArm(5);//read raw data from arm, complete with wait time

  if(verifyPacket(returnPacket) == true)
  {
    printlnDebug("Arm Found"); 
    return(true) ;
  }
  else
  {
    printlnDebug("No Arm Found"); 
    return(false); 
  }
}

/******************************************************
 *  putArmToSleep()
 *
 *  function to put the arm to sleep. This will move 
 *  the arm to a 'rest' position and then turn the 
 * torque off for the servos
 *
 *  Parameters:
 *    None
 *
 *
 *  Returns: 
 *    boolean 
 *      true = arm has been put to sleep
 *      false = no return packet was detected from the arm.
 *
 ******************************************************/ 
boolean putArmToSleep()
{
  printDebug("Attempting to put arm in sleep mode - "); 
  sendCommanderPacket(0,0,0,0,0,0,0,0,96);//only the last/extended byte matters - 96 signals the arm to go to sleep
  
  byte[] returnPacket = new byte[5];//return id packet is 5 bytes long
  returnPacket = readFromArm(5);//read raw data from arm
  if(verifyPacket(returnPacket) == true)
  {
    printlnDebug("Sleep mode success!"); 
    return(true) ;
  }
  else
  {
    printlnDebug("Sleep mode-No return packet detected"); 
    //displayError("There was a problem putting the arm in sleep mode","");
    
    genericMessageDialog("Arm Error", "There was a problem putting the arm in sleep mode.", G4P.WARNING);
    
    return(false); 
  }
}


/******************************************************
 *  changeArmMode()
 *
 *  sends a packet to set the arms mode and orientation
 *  based on the global mode and orientation values
 *  This function will send a packet with the extended 
 *  byte coresponding to the correct IK mode and wrist 
 *  orientation. The arm will move from its current 
 *  position to the 'home' position for the current 
 *  mode.
 *  Backhoe mode does not have different straight/
 *  90 degree modes.
 *  
 *  Extended byte - Mode 
 *  32 - cartesian, straight mode
 *  40 - cartesian, 90 degree mode
 *  48 - cylindrical, straight mode
 *  56 - cylindrical, 90 degree mode
 *  64 - backhoe
 *  
 *  Parameters:
 *    None
 *
 *  Globals used:
 *    currentMode
 *    currentOrientation
 *
 *  Returns: 
 *    boolean 
 *      true = arm has been put in the mode correctly
 *      false = no return packet was detected from the arm.
 *
 ******************************************************/ 
boolean changeArmMode()
{
  
  byte[] returnPacket = new byte[5];//return id packet is 5 bytes long
  
 //switch based on the current mode
 switch(currentMode)
  {
    //cartesian mode case
    case 1:
      //switch based on the current orientation
      switch(currentOrientation)
      {
        case 1:
          sendCommanderPacket(0,0,0,0,0,0,0,0,32);//only the last/extended byte matters, 32 = cartesian, straight mode
          printDebug("Setting Arm to Cartesian IK mode, Gripper Angle Straight - "); 
          break;
        case 2:
          sendCommanderPacket(0,0,0,0,0,0,0,0,40);//only the last/extended byte matters, 40 = cartesian, 90 degree mode
          printDebug("Setting Arm to Cartesian IK mode, Gripper Angle 90 degree - "); 
          break;
      }//end orientation switch
      break;//end cartesian mode case
      
    //cylindrical mode case
    case 2:
      //switch based on the current orientation
      switch(currentOrientation)
      {
        case 1:
          sendCommanderPacket(0,0,0,0,0,0,0,0,48);//only the last/extended byte matters, 48 = cylindrical, straight mode
          printDebug("Setting Arm to Cylindrical IK mode, Gripper Angle Straight - "); 
          break;
        case 2:
          sendCommanderPacket(0,0,0,0,0,0,0,0,56);//only the last/extended byte matters, 56 = cylindrical, 90 degree mode
          printDebug("Setting Arm to Cylindrical IK mode, Gripper Angle 90 degree - "); 
          break;
      }//end orientation switch
      break;//end cylindrical mode case

    //backhoe mode case
    case 3:
      sendCommanderPacket(0,0,0,0,0,0,0,0,64);//only the last/extended byte matters, 64 = backhoe
          printDebug("Setting Arm to Backhoe IK mode - "); 
      break;//end backhoe mode case
  } 
  
  returnPacket = readFromArm(5);//read raw data from arm
  if(verifyPacket(returnPacket) == true)
  {
    printlnDebug("Response succesful! Arm mode changed"); 
    return(true) ;
  }
  else
  {
    printlnDebug("No Response - Failure?"); 
    
    //displayError("There was a problem setting the arm mode","");
    
    genericMessageDialog("Arm Error", "There was a problem setting the arm mode.", G4P.WARNING);
    
    return(false); 
  }
  
}

/******************************************************
 *  delayMs(int)
 *
 *  function waits/blocks the program for 'ms' milliseconds
 *  Used for very short delays where the program only needs
 *  to wait and does not need to execute code
 *  
 *  Parameters:
 *    int ms
 *      time, in milliseconds to wait
 *  Returns: 
 *    void
 ******************************************************/ 
void delayMs(int ms)
{
  
  int time = millis();  //time that the program starts the loop
  while(millis()-time < ms)
  {
     //loop/do nothing until the different between the current time and 'time'
  }
}


/******************************************************
 *  sendCommanderPacket(int, int, int, int, int, int, int, int, int)
 *
 *  This function will send a commander style packet 
 *  the ArbotiX/Arm. This packet has 9 bytes and includes
 *  positional data, button data, and extended instructions.
 *  This function is often used with the function
 *  readFromArm()    
 *  to verify the packet was received correctly
 *   
 *  Parameters:
 *    int x
 *      offset X value (cartesian mode), or base value(Cylindrical and backhoe mode) - will be converted into 2 bytes
 *    int y
 *        Y Value (cartesian and cylindrical mode) or shoulder value(backhoe mode) - will be converted into 2 bytes
 *    int z
 *        Z Value (cartesian and cylindrical mode) or elbow value(backhoe mode) - will be converted into 2 bytes
 *    int wristAngle
 *      offset wristAngle value(cartesian and cylindrical mode) or wristAngle value (backhoe mode) - will be converted into 2 bytes
 *    int wristRotate
 *      offset wristRotate value(cartesian and cylindrical mode) or wristRotate value (backhoe mode) - will be converted into 2 bytes
 *    int gripper
 *      Gripper Value(All modes) - will be converted into 2 bytes
 *    int delta
 *      delta(speed) value (All modes) - will be converted into 1 byte
 *    int button
 *      digital button values (All modes) - will be converted into 1 byte
 *    int extended
 *       value for extended instruction / special instruction - will be converted into 1 byte
 *
 *  Global used: sPort
 *
 *  Return: 
 *    Void
 *
 ******************************************************/ 
void sendCommanderPacket(int x, int y, int z, int wristAngle, int wristRotate, int gripper, int delta, int button, int extended)
{
  
  
      try
    {
       sPorts[armPortIndex].clear();//clear the serial port for the next round of communications  
    }
    //catch an exception in case of serial port problems
    catch(Exception e)
    {
       printlnDebug("Error: serial port problem");
       return;
    }   
    
  //convert each positional integer into 2 bytes using intToBytes()
  byte[] xValBytes = intToBytes(x);
  byte[] yValBytes = intToBytes(y);
  byte[] zValBytes =  intToBytes(z);
  byte[] wristRotValBytes = intToBytes(wristRotate);
  byte[] wristAngleValBytes = intToBytes(wristAngle);
  byte[] gripperValBytes = intToBytes(gripper);
  //cast int to bytes
  byte buttonByte = byte(button);
  byte extValByte = byte(extended);
  byte deltaValByte = byte(delta);
  boolean flag = true;

 
  //calculate checksum - add all values, take lower byte (%256) and invert result (~). you can also invert results by (255-sum)
  byte checksum = (byte)(~(xValBytes[1]+xValBytes[0]+yValBytes[1]+yValBytes[0]+zValBytes[1]+zValBytes[0]+wristAngleValBytes[1]+wristAngleValBytes[0]+wristRotValBytes[1]+wristRotValBytes[0]+gripperValBytes[1]+gripperValBytes[0]+deltaValByte + buttonByte+extValByte)%256);

  //send commander style packet. Following labels are for cartesian mode, see function comments for clyindrical/backhoe mode
    //try to write the first header byte
    try
    {
      sPorts[armPortIndex].write(0xff);//header        
    }
    //catch an exception in case of serial port problems
    catch(Exception e)
    {
       printlnDebug("Error: packet not sent: " + e + ": 0xFF 0x" +hex(xValBytes[1]) +" 0x" +hex(xValBytes[0]) +" 0x" +hex(yValBytes[1]) +" 0x" +hex(yValBytes[0])+" 0x" +hex(zValBytes[1])+" 0x" +hex(zValBytes[0]) +" 0x" +hex(wristAngleValBytes[1]) +" 0x" +hex(wristAngleValBytes[0]) +" 0x" + hex(wristRotValBytes[1])+" 0x" +hex(wristRotValBytes[0]) +" 0x" + hex(gripperValBytes[1])+" 0x" + hex(gripperValBytes[0])+" 0x" + hex(deltaValByte)+" 0x" +hex(buttonByte) +" 0x" +hex(extValByte) +" 0x"+hex(checksum) +"",2); 
       flag = false;
    }   
    if(flag == true)
    {
      sPorts[armPortIndex].write(xValBytes[1]); //X Coord High Byte
      sPorts[armPortIndex].write(xValBytes[0]); //X Coord Low Byte
      sPorts[armPortIndex].write(yValBytes[1]); //Y Coord High Byte
      sPorts[armPortIndex].write(yValBytes[0]); //Y Coord Low Byte
      sPorts[armPortIndex].write(zValBytes[1]); //Z Coord High Byte
      sPorts[armPortIndex].write(zValBytes[0]); //Z Coord Low Byte
      sPorts[armPortIndex].write(wristAngleValBytes[1]); //Wrist Angle High Byte
      sPorts[armPortIndex].write(wristAngleValBytes[0]); //Wrist Angle Low Byte
      sPorts[armPortIndex].write(wristRotValBytes[1]); //Wrist Rotate High Byte
      sPorts[armPortIndex].write(wristRotValBytes[0]); //Wrist Rotate Low Byte
      sPorts[armPortIndex].write(gripperValBytes[1]); //Gripper High Byte
      sPorts[armPortIndex].write(gripperValBytes[0]); //Gripper Low Byte
      sPorts[armPortIndex].write(deltaValByte); //Delta Low Byte  
      sPorts[armPortIndex].write(buttonByte); //Button byte  
      sPorts[armPortIndex].write(extValByte); //Extended instruction  
      sPorts[armPortIndex].write(checksum);  //checksum
      printlnDebug("Packet Sent: 0xFF 0x" +hex(xValBytes[1]) +" 0x" +hex(xValBytes[0]) +" 0x" +hex(yValBytes[1]) +" 0x" +hex(yValBytes[0])+" 0x" +hex(zValBytes[1])+" 0x" +hex(zValBytes[0]) +" 0x" +hex(wristAngleValBytes[1]) +" 0x" +hex(wristAngleValBytes[0]) +" 0x" + hex(wristRotValBytes[1])+" 0x" +hex(wristRotValBytes[0]) +" 0x" + hex(gripperValBytes[1])+" 0x" + hex(gripperValBytes[0])+" 0x" + hex(deltaValByte)+" 0x" +hex(buttonByte) +" 0x" +hex(extValByte) +" 0x"+hex(checksum) +"",2); 
    }
  
    
  
  
  
  
         
}


//sends the commander packet if an only if the packet is different from the last one sent with this function. This stops duplicate packets from being sent multile times in a row
void sendCommanderPacketWithCheck(int x, int y, int z, int wristAngle, int wristRotate, int gripper, int delta, int button, int extended)
{



   
   
    //check for changes - if there are no changes then don't send the packet to avoid sending multiple identical packets unnesscarsily

  if(  lastX != x || lastY != y || lastZ != z || lastWristangle != wristAngle || lastWristRotate != wristRotate || lastGripper != gripper || lastButton != button || lastExtended != extended || lastDelta != delta)
  {
    sendCommanderPacket(x,y, z, wristAngle,  wristRotate,  gripper,  delta,  button,  extended);
  }
    
    
 
     //holds the data from the last packet sent
  lastX = x;
  lastY = y;
  lastZ = z;
  lastWristangle = wristAngle;
  lastWristRotate = wristRotate;
  lastGripper = gripper;
  lastButton = button;
  lastExtended = extended;
  lastDelta = delta;
   
  

}

/******************************************************
 *  intToBytes(int)
 *
 *  This function will take an interger and convert it
 *  into two bytes. These bytes can then be easily 
 *  transmitted to the ArbotiX/Arm. Byte[0] is the low byte
 *  and Byte[1] is the high byte
 *   
 *  Parameters:
 *    int convertInt
 *      integer to be converted to bytes
 *  Return: 
 *    byte[]
 *      byte array with two bytes Byte[0] is the low byte and Byte[1] 
 *      is the high byte
 ******************************************************/ 
byte[] intToBytes(int convertInt)
{
  byte[] returnBytes = new byte[2]; // array that holds the two bytes to return
  byte mask = byte(255);          //mask for the low byte (255/0xff)
  returnBytes[0] =byte(convertInt & mask);//low byte - perform an '&' operation with the byte mask to remove the high byte
  returnBytes[1] =byte((convertInt>>8) & mask);//high byte - shift the byte to the right 8 bits. perform an '&' operation with the byte mask to remove any additional data
  return(returnBytes);  //return byte array
  
}

/******************************************************
 *  bytesToInt(byte[])
 *
 *  Take two bytes and convert them into an integer
 *   
 *  Parameters:
 *    byte[] convertBytes
 *      bytes to be converted to integer
 *  Return: 
 *    int
 *      integer value from 2 butes
 ******************************************************/ 
int bytesToInt(byte[] convertBytes)
{
  return((int(convertBytes[1]<<8))+int(convertBytes[0]));//shift high byte up 8 bytes, and add it to the low byte. cast to int to ensure proper signed/unsigned behavior
}

/****************
 *  updateOffsetCoordinates()
 *
 *  modifies the current global coordinate
 *  with an appropriate offset
 *
 *  As the Arm Link software communicates in
 *  unsigned bytes, any value that has negative
 *  values in the GUI must be offset. This function
 *  will add the approprate offsets based on the 
 *  current mode of operation( global variable 'currentMode')
 *
 *  Parameters:
 *    None:
 *  Globals used:
 *    'Current' position vars
 *    'CurrentOffset' position vars
 *  Return: 
 *    void
 ***************/

void  updateOffsetCoordinates()
{
  //offsets are applied based on current mode
  switch(currentMode)
    {
       case 1:        
         //x, wrist angle, and wrist rotate must be offset, all others are normal
         xCurrentOffset = xCurrent + 512;
         yCurrentOffset = yCurrent;
         zCurrentOffset = zCurrent;
         wristAngleCurrentOffset =  wristAngleCurrent + 90;
         //wristRotateCurrentOffset = wristRotateCurrent + 512;
         wristRotateCurrentOffset = wristRotateCurrent;
         gripperCurrentOffset = gripperCurrent;
         deltaCurrentOffset = deltaCurrent;
         break;
        
       case 2:
       
         //wrist angle, and wrist rotate must be offset, all others are normal
         xCurrentOffset = xCurrent;
         yCurrentOffset = yCurrent;
         zCurrentOffset = zCurrent;
         wristAngleCurrentOffset =  wristAngleCurrent + 90;
         //wristRotateCurrentOffset = wristRotateCurrent + 512;
         wristRotateCurrentOffset = wristRotateCurrent;
         gripperCurrentOffset = gripperCurrent;
         deltaCurrentOffset = deltaCurrent;
         break;
        
       case 3:
       
         //no offsets needed
         xCurrentOffset = xCurrent;
         yCurrentOffset = yCurrent;
         zCurrentOffset = zCurrent;
         wristAngleCurrentOffset =  wristAngleCurrent;
         wristRotateCurrentOffset = wristRotateCurrent;
         gripperCurrentOffset = gripperCurrent;
         deltaCurrentOffset = deltaCurrent;
        break; 
    }  
}

/****************
 *  updateButtonByte()
 *
 *  
 *
 *  Parameters:
 *    None:
 *  Globals used:
 *    int[] digitalButtons
 *    int digitalButtonByte
 *  Return: 
 *    void
 ***************/

void updateButtonByte()
{
  digitalButtonByte = 0;
   for(int i=0;i<8;i++)
  {
    if(digitalButtons[i] == true)
    {
      digitalButtonByte += pow(2,i);
    }
  }
}


//TODO//
boolean getArmInfo()
{
  return(true);
  
}




int analogRead(int analogPort)
{
  byte[] returnPacket = new byte[5];  //byte array to hold return packet, which is 5 bytes long
  int analog = 0;
  printlnDebug("sending request for anlaog 1"); 
  int analogExtentded = 200 + analogPort;
  sendCommanderPacket(xCurrentOffset, yCurrentOffset, zCurrentOffset, wristAngleCurrentOffset, wristRotateCurrentOffset, gripperCurrentOffset, deltaCurrentOffset, digitalButtonByte, analogExtentded);    //send a commander style packet - the first 8 bytes are inconsequntial, only the last byte matters. '112' is the extended byte that will request an ID packet
  returnPacket = readFromArmFast(5);//read raw data from arm, complete with wait time
  byte[] analogBytes = {returnPacket[3],returnPacket[2]};
  analog = bytesToInt(analogBytes);
  
  printlnDebug("Return Packet" + int(returnPacket[0]) + "-" +  int(returnPacket[1]) + "-"  + int(returnPacket[2]) + "-"  + int(returnPacket[3]) + "-"  + int(returnPacket[4]));
  printlnDebug("analog value: " + analog);
  
  return(analog);
        
}
int registerRead()
{

 byte[] returnPacket = new byte[5];  //byte array to hold return packet, which is 5 bytes long
  int registerVal = 0;
  printlnDebug("sending request for anlaog 1"); 
  int getRegExtentded = 0x81;
  sendCommanderPacket (regIdCurrent,regNumCurrent,regLengthCurrent, 0, 0, 0, 0, 0, getRegExtentded);
  returnPacket = readFromArmFast(5);//read raw data from arm, complete with wait time
  byte[] registerBytes = {returnPacket[3],returnPacket[2]};
  registerVal   = bytesToInt(registerBytes);
  
  printlnDebug("Return Packet" + int(returnPacket[0]) + "-" +  int(returnPacket[1]) + "-"  + int(returnPacket[2]) + "-"  + int(returnPacket[3]) + "-"  + int(returnPacket[4]));
  printlnDebug("analog value: " + registerVal);
  
  return(registerVal);
  

}
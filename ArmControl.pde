/***********************************************************************************
 *  }--\     InterbotiX     /--{
 *      |    ArmControl    |
 *   __/                    \__
 *  |__|                    |__|
 *
 *  The following software will allow you to control InterbotiX Robot Arms.
 *  ArmControl will send serial packets to the ArbotiX Robocontroller that
 *  specify coordinates for that arm to move to. TheArbotiX robocontroller
 *  will then do the Inverse Kinematic calculations and send commands to the
 *  DYNAMIXEL servos to move in such a way that the end effector ends up at
 *  the specified coordinate.
 *
 *  Robot Arm Compatibilty:
 *    The ArmControl Software is desiged to work with InterbotiX Robot Arms
 *    running the ArmControl firmware. Currently supported arms are:
 *      1)PhantomX Pincher Robot Arm
 *      2)PhantomX Reactor Robot Arm
 *      3)WidowX Robot Arm
 *
 *  Computer Compatibility:
 *    ArmControl can be used on any system that supports
 *      1)Java
 *      2)Processing 2.0
 *      3)Java serial library (Included for Mac/Windows/Linux with processing 2.0)
 *    ArmControl has been tested on the following systems
 *      1)Windows XP, Vista, 7, 8
 *      2)Mac 10.6+
 *      3)Linux?
 *     Binaries for these systems are available
 *
 *  Building:
 *    Once Java and Processing 2.0 have been installed, you will also need to download/install
 *    the G4p GUI library for processing.
 *    http://sourceforge.net/projects/g4p/files/?source=navbar
 *    
 *    (More information on G4P can be found at http://www.lagers.org.uk/g4p/download.html )
 *    
 *     Notice for Mac users:
 *       To get the Serial library to work properly you will need to issue the following commands
 *        sudo mkdir -p /var/lock
 *        sudo chmod 777 /var/lock
 *
 *
 *  External Resources
 *  Arm Control Setup & Documentation
 *    http://learn.trossenrobotics.com/arbotix/arbotix-communication-controllers/31-arm-control
 *
 *  PhantomX Pincher Robot Arm
 *    http://learn.trossenrobotics.com/interbotix/robot-arms/pincher-arm
 *  PhantomX Reactor Robot Arm
 *    http://learn.trossenrobotics.com/interbotix/robot-arms/reactor-arm
 *  WidowX Robot Arm
 *    http://learn.trossenrobotics.com/interbotix/robot-arms/widowx-arm
 *
 **********************************/

import g4p_controls.*;      //import g4p library for GUI elements
import processing.serial.*; //import serial library to communicate with the ArbotiX
import java.awt.Font;       //import font

Serial sPort;               //serial port object, used to connect to a serial port and send data to the ArbotiX



int numSerialPorts = Serial.list().length;                 //Number of serial ports available at startup
String[] serialPortString = new String[numSerialPorts+1];  //string array to the name of each serial port - used for populating the drop down menu
int selectedSerialPort;                                    //currently selected port from serialList drop down

boolean debugConsole = true;      //change to 'false' to disable debuging messages to the console, 'true' to enable 
boolean debugFile = false;        //change to 'false' to disable debuging messages to a file, 'true' to enable
boolean debugGuiEvent = true;     //change to 'false' to disable GUI debuging messages, 'true' to enable
//int lf = 10;    // Linefeed in ASCII

boolean updateFlag = false;     //trip flag, true when the program needs to send a serial packet at the next interval, used by both 'update' and 'autoUpdate' controls
int updatePeriod = 33;          //minimum period between packet in Milliseconds , 33ms = 30Hz which is the standard for the commander/arm control protocol

long prevCommandTime = 0;       //timestamp for the last time that the program sent a serial packet
long heartbeatTime = 0;         //timestamp for the last time that the program received a serial packet from the Arm
long currentTime = 0;           //timestamp for currrent time

int packetRepsonseTimeout = 5000;      //time to wait for a response from the ArbotiX Robocontroller / Arm Control Protocol

int currentArm = 0;          //ID of current arm. 1 = pincher, 2 = reactor, 3 = widowX
int currentMode = 0;         //Current IK mode, 1=Cartesian, 2 = cylindrical, 3= backhoe
int currentOrientation = 0;  //Current wrist oritnation 1 = straight/normal, 2=90 degrees

public void setup(){
  size(250, 786, JAVA2D);  //draw initial screen
  
  createGUI();   //draw GUI components defined in gui.pde
  //customGUI();

  //Build Serial Port List
  serialPortString[0] = "Serial Port";   //first item in the list will be "Serial Port" to act as a label
  //iterate through each avaialable serial port  
  for (int i=0;i<numSerialPorts;i++) 
  {
    serialPortString[i+1] = Serial.list()[i];  //add the current serial port to the list, add one to the index to account for the first item/label "Serial Port"
  }
  serialList.setItems(serialPortString, 0);
  
  
  
  
  //MOVE TO GUI
  wristAngleLabel.setFont(new Font("Dialog", Font.PLAIN, 10));
  wristRotateLabel.setFont(new Font("Dialog", Font.PLAIN, 10));
  extendedLabel.setFont(new Font("Dialog", Font.PLAIN, 10));
  updateButton.setFont(new Font("Dialog", Font.PLAIN, 20));  
  serialList.setFont(new Font("Dialog", Font.PLAIN, 9));  
  arm90Button.setAlpha(128);
  
  
  
  
}

public void draw()
{
  background(128);//draw background color
  image(logoImg, 5, 5, 230, 78);  //draw logo image
  image(footerImg, 15, 740);      //draw footer image

  currentTime = millis();  //get current timestamp
  
  //check if
  //  -update flag is true, and a packet needs to be sent
  //  --it has been more than 'updatePeriod' ms since the last packet was sent
  if(updateFlag == true & currentTime - prevCommandTime > updatePeriod )
  {
    updateOffsetCoordinates();     //prepare the currentOffset coordinates for the program to send
    updateButtonByte();  //conver the current 'digital button' checkboxes into a value to be sent to the arbotix/arm
    prevCommandTime = currentTime; //update the prevCommandTime timestamp , used to calulcate the time the program can next send a command

    
    //check that the serial port is active
    if(sPort != null)
    {
      //send commander packet with the current global currentOffset coordinatges
      sendCommanderPacket(xCurrentOffset, yCurrentOffset, zCurrentOffset, wristAngleCurrentOffset, wristRotateCurrentOffset, gripperCurrentOffset, deltaCurrentOffset, digitalButtonByte, extendedByte);  
   
    /*  byte[] responseBytes = new byte[5];    //byte array to hold response data
      responseBytes = readFromArm(5);//read raw data from arm, complete with wait time

      if(verifyPacket(responseBytes) == true)
      {
        printlnDebug("Moved!"); 
      }
      else
      {
        printlnDebug("No Arm Found"); 
      }*/
        
    }
    //in normal update mode, pressing the update button signals the program to send a packet. In this
    //case the program must set the update flag to false in order to stop new packets from being sent
    //until the update button is pressed again. 
    //However in autoUpdate mode, the program should not change this flag (only unchecking the auto update flag should set the flag to false)
    if(autoUpdateCheckbox.isSelected() == false)
    {
      updateFlag = false;//only set the updateFlag to false if the autoUpdate flag is false
    }
    //use this oppurtunity to set the extended byte to 0 if autoupdate is enabled - this way the extended packet only gets sent once
    else
    {
      if(extendedByte != 0)
      {
        extendedByte = 0;
        extendedTextField.setText("0");
      }
    }
    
  }
}

/******************************************************
 *  stop()
 *
 *  Tasks to perform on end of program
 ******************************************************/ 
void stop()
{
 putArmToSleep(); 
}


// Use this methologod additional statements
// to customise the GUI controls
public void customGUI(){

}


/******************************************************
 *  printlnDebug()
 *
 *  function used to easily enable/disable degbugging
 *  enables/disables debugging to the console
 *  prints a line to the output
 *  TODO: Enable file debugging
 *
 *  Parameters:
 *    String message
 *      string to be sent to the debugging method
 *    int type
 *        Type of event
 *         type 0 = normal program message
 *         type 1 = GUI event
 *         type 2 = serial packet 
 *  Globals Used:
 *      boolean debugGuiEvent
 *      boolean debugConsole
 *  Returns: 
 *    void
 ******************************************************/ 
void printlnDebug(String message, int type)
{
   if(debugConsole == true)
   {
      if((type == 1 & debugGuiEvent == true) | type == 0)
      {
        println(message); 
      }
   }
}

//wrapper for printlnDebug(String, int)
//assume normal behavior, message type = 0
void printlnDebug(String message)
{
  printlnDebug(message, 0);
}

/******************************************************
 *  printlnDebug()
 *
 *  function used to easily enable/disable degbugging
 *  enables/disables debugging to the console
 *  prints normally to the output
 *  TODO: Enable file debugging
 *
 *  Parameters:
 *    String message
 *      string to be sent to the debugging method
 *    int type
 *        Type of event
 *         type 0 = normal program message
 *         type 1 = GUI event
 *         type 2 = serial packet 
 *  Globals Used:
 *      boolean debugGuiEvent
 *      boolean debugConsole
 *  Returns: 
 *    void
 ******************************************************/ 
void printDebug(String message, int type)
{
   if(debugConsole == true)
   {
      if((type == 1 & debugGuiEvent == true) | type == 0)
      {
        print(message); 
      }
   }
}

//wrapper for printlnDebug(String, int)
//assume normal behavior, message type = 0
void printDebug(String message)
{
  printDebug(message, 0);
  
}


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
  
  printDebug("Incoming Raw Packet from readFromArm():"); //debug
  
  //if the 'wait' flag is TRUE this loop will wait until the serial port has data OR it has waited more than packetRepsonseTimeout milliseconds.
  //packetRepsonseTimeout is a global variable
  
  while(wait == true & sPort.available() < bytesExpected  & millis()-startReadingTime < packetRepsonseTimeout)
  {
     //do nothing, just waiting for a response or timeout
  }
  
  for(int i =0; i < bytesExpected;i++)    
  {
    // If data is available in the serial port, continute
    if(sPort.available() > 0)
    {
      bufferByte = byte(sPort.readChar());
      responseBytes[i] = bufferByte;
      printDebug(hex(bufferByte) + "-"); //debug 
    }
    else
    {
      printDebug("NO BYTE-");//debug
    }
  }//end looking for bytes from packet
  printlnDebug(" "); //debug  finish line
  
  sPort.clear();  //clear serial port for the next read
  
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


/******************************************************
 *  checkArmStartup()
 *
 *  function used to check for the presense of a 
 *  ArbotiX/Arm on a serial port. This function should
 *  be called directly after a serial port has opened -
 *  opening a serial port over a USB-FTDI device will
 *  reset the ArbotiX, and the first thing the ArbotiX
 *  will do is send a standard Arm ID packet. This function
 *  looks specifically for that packet
 *  This function also sets the initial Global 'currenArm'
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

  printDebug("Checking for arm on startup - "); 
  
  delayMs(60);  //The ArbotiX has a delay of 50ms between starting the serial port and sending the ID packet, include an extra 10ms for other ArbotiX startup tasks
  
  returnPacket = readFromArmFast(5);//read raw data from arm. Do not wait for a response packet (to facilitate fast auto search)
  //check if the return packet is a valid arm ID packet
  if(verifyPacket(returnPacket) == true)
  {
    currentArm = returnPacket[1]; //set the current arm based on the return packet
    printlnDebug("Startup Arm #" +currentArm+ "Found"); 
    setPositionParameters();      //set the GUI default/min/maxes and field lables
    return(true) ;                //Return a true signal to signal that an arm has been found
  }
  else
  {
    printlnDebug("Startup No Arm Found"); 
    return(false); //no arm found
  }
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
 
  printDebug("Checking for arm - "); 
  
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
    printlnDebug("Response succesful!"); 
    return(true) ;
  }
  else
  {
    printlnDebug("No Response - Failure?"); 
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
   
  
//  ;//loop/do nothing until the different between the current time and 'time'
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
   sPort.clear();//clear the serial port for the next round of communications
   
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

  //calculate checksum - add all values, take lower byte (%256) and invert result (~). you can also invert results by (255-sum)
  byte checksum = (byte)(~(xValBytes[1]+xValBytes[0]+yValBytes[1]+yValBytes[0]+zValBytes[1]+zValBytes[0]+wristAngleValBytes[1]+wristAngleValBytes[0]+wristRotValBytes[1]+wristRotValBytes[0]+gripperValBytes[1]+gripperValBytes[0]+deltaValByte + buttonByte+extValByte)%256);

  //send commander style packet. Following labels are for cartesian mode, see function comments for clyindrical/backhoe mode
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
  sPort.write(checksum);  //checksum
  
  printlnDebug("Packet Sent: 0xFF 0x" +hex(xValBytes[1]) +" 0x" +hex(xValBytes[0]) +" 0x" +hex(yValBytes[1]) +" 0x" +hex(yValBytes[0])+" 0x" +hex(zValBytes[1])+" 0x" +hex(zValBytes[0]) +" 0x" +hex(wristAngleValBytes[1]) +" 0x" +hex(wristAngleValBytes[0]) +" 0x" + hex(wristRotValBytes[1])+" 0x" +hex(wristRotValBytes[0]) +" 0x" + hex(gripperValBytes[1])+" 0x" + hex(gripperValBytes[0])+" 0x" + hex(deltaValByte)+" 0x" +hex(buttonByte) +" 0x" +hex(extValByte) +" 0x"+hex(checksum) +""); 
         
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
 *  As the armControl software communicates in
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
         wristRotateCurrentOffset = wristRotateCurrent + 512;
         gripperCurrentOffset = gripperCurrent;
         deltaCurrentOffset = deltaCurrent;
         break;
        
       case 2:
       
         //wrist angle, and wrist rotate must be offset, all others are normal
         xCurrentOffset = xCurrent;
         yCurrentOffset = yCurrent;
         zCurrentOffset = zCurrent;
         wristAngleCurrentOffset =  wristAngleCurrent + 90;
         wristRotateCurrentOffset = wristRotateCurrent + 512;
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



boolean keyup = false;
boolean keydown = false;
boolean xkey = false;
boolean ykey = false;
boolean zkey = false;
boolean wangkey = false;
boolean wrotkey = false;
boolean gkey = false;


void keyPressed()
{
  if(key =='1')
  {
   xkey=true; 
  }
  if(key =='2')
  {
   ykey=true; 
  }
  if(key =='3')
  {
   zkey=true; 
  }
  if(key =='4')
  {
   wangkey=true; 
  }
  if(key =='5')
  {
   wrotkey=true; 
  }
  if(key =='6')
  {
   gkey=true; 
  }
  
  if(key ==ENTER)
  {
  updateFlag = true;
updateOffsetCoordinates();
  }
  
  if (key==CODED)
  {
   if (keyCode == UP)
   {
     if(xkey==true)
     {
       xCurrent = xCurrent + 1;
       xTextField.setText(Integer.toString(xCurrent));
       xSlider.setValue(xCurrent);
     }
     if(ykey==true)
     {
       yCurrent = yCurrent + 1;
       yTextField.setText(Integer.toString(yCurrent));
       ySlider.setValue(yCurrent);
     }
     if(zkey==true)
     {
       zCurrent = zCurrent + 1;
       zTextField.setText(Integer.toString(zCurrent));
       zSlider.setValue(zCurrent);
     }
     if(wangkey==true)
     {
       wristAngleCurrent = wristAngleCurrent + 1;
       wristAngleTextField.setText(Integer.toString(wristAngleCurrent));
       wristAngleSlider.setValue(wristAngleCurrent);
     }
     if(wrotkey==true)
     {
       wristRotateCurrent = wristRotateCurrent + 1;
       wristRotateTextField.setText(Integer.toString(wristRotateCurrent));
       wristRotateSlider.setValue(wristRotateCurrent);
     }
     if(gkey==true)
     {
       gripperCurrent = gripperCurrent + 1;
       gripperTextField.setText(Integer.toString(gripperCurrent));
        gripperSlider.setValue(gripperCurrent);
     }
   }
     
   if (keyCode == DOWN)
   {
     if(xkey==true)
     {
       xCurrent = xCurrent - 1;
       xTextField.setText(Integer.toString(xCurrent));
       xSlider.setValue(xCurrent);
     }
     if(ykey==true)
     {
       yCurrent = yCurrent - 1;
       yTextField.setText(Integer.toString(yCurrent));
       ySlider.setValue(yCurrent);
     }
     if(zkey==true)
     {
       zCurrent = zCurrent - 1;
       zTextField.setText(Integer.toString(zCurrent));
       zSlider.setValue(zCurrent);
     }
     if(wangkey==true)
     {
       wristAngleCurrent = wristAngleCurrent - 1;
       wristAngleTextField.setText(Integer.toString(wristAngleCurrent));
       wristAngleSlider.setValue(wristAngleCurrent);
     }
     if(wrotkey==true)
     {
       wristRotateCurrent = wristRotateCurrent - 1;
       wristRotateTextField.setText(Integer.toString(wristRotateCurrent));
       wristRotateSlider.setValue(wristRotateCurrent);
     }
     if(gkey==true)
     {
       gripperCurrent = gripperCurrent - 1;
       gripperTextField.setText(Integer.toString(gripperCurrent));
        gripperSlider.setValue(gripperCurrent);
     }
   }
   
     
  } 
}
void keyReleased()
{
  if(key =='1')
  {
   xkey=false; 
  }
  if(key =='2')
  {
   ykey=false; 
  }
  if(key =='3')
  {
   zkey=false; 
  }
  if(key =='4')
  {
   wangkey=false; 
  }
  if(key =='5')
  {
   wrotkey=false; 
  }
  if(key =='6')
  {
   gkey=false; 
  }
  
  
}

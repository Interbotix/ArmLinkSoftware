/***********************************************************************************
 *  }--\     InterbotiX     /--{
 *      |    Arm Link      |
 *   __/                    \__
 *  |__|                    |__|
 *
 *  The following software will allow you to control InterbotiX Robot Arms.
 *  Arm Link will send serial packets to the ArbotiX Robocontroller that
 *  specify coordinates for that arm to move to. TheArbotiX robocontroller
 *  will then do the Inverse Kinematic calculations and send commands to the
 *  DYNAMIXEL servos to move in such a way that the end effector ends up at
 *  the specified coordinate.
 *
 *  Robot Arm Compatibilty:
 *    The Arm Link Software is desiged to work with InterbotiX Robot Arms
 *    running the Arm Link firmware. Currently supported arms are:
 *      1)PhantomX Pincher Robot Arm
 *      2)PhantomX Reactor Robot Arm
 *      3)WidowX Robot Arm
 *      4)RobotGeek Snapper
 *
 *  Computer Compatibility:
 *    Arm Link can be used on any system that supports
 *      1)Java
 *      2)Processing 2.0
 *      3)Java serial library (Included for Mac/Windows/Linux with processing 2.0)
 *    Arm Link has been tested on the following systems
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
 *  Arm Link Setup & Documentation
 *    http://learn.trossenrobotics.com/arbotix/arbotix-communication-controllers/31-arm-control
 *
 *  PhantomX Pincher Robot Arm
 *    http://learn.trossenrobotics.com/interbotix/robot-arms/pincher-arm
 *  PhantomX Reactor Robot Arm
 *    http://learn.trossenrobotics.com/interbotix/robot-arms/reactor-arm
 *  WidowX Robot Arm
 *    http://learn.trossenrobotics.com/interbotix/robot-arms/widowx-arm
 *
 ***********************************************************************************/

import g4p_controls.*;      //import g4p library for GUI elements
import processing.serial.*; //import serial library to communicate with the ArbotiX
import java.awt.Font;       //import font

Serial sPort;               //serial port object, used to connect to a serial port and send data to the ArbotiX

PrintWriter debugOutput;        //output object to write to a file

int numSerialPorts = Serial.list().length;                 //Number of serial ports available at startup
String[] serialPortString = new String[numSerialPorts+1];  //string array to the name of each serial port - used for populating the drop down menu
int selectedSerialPort;                                    //currently selected port from serialList drop down

boolean debugConsole = true;      //change to 'false' to disable debuging messages to the console, 'true' to enable 
boolean debugFile = false;        //change to 'false' to disable debuging messages to a file, 'true' to enable

boolean debugGuiEvent = true;     //change to 'false' to disable GUI debuging messages, 'true' to enable
boolean debugSerialEvent = false;     //change to 'false' to disable GUI debuging messages, 'true' to enable
//int lf = 10;    // Linefeed in ASCII

boolean debugFileCreated  = false;  //flag to see if the debug file has been created yet or not

boolean enableAnalog = false; //flag to enable reading analog inputs from the Arbotix

boolean updateFlag = false;     //trip flag, true when the program needs to send a serial packet at the next interval, used by both 'update' and 'autoUpdate' controls
int updatePeriod = 33;          //minimum period between packet in Milliseconds , 33ms = 30Hz which is the standard for the commander/arm link protocol

long prevCommandTime = 0;       //timestamp for the last time that the program sent a serial packet
long heartbeatTime = 0;         //timestamp for the last time that the program received a serial packet from the Arm
long currentTime = 0;           //timestamp for currrent time

int packetRepsonseTimeout = 5000;      //time to wait for a response from the ArbotiX Robocontroller / Arm Link Protocol

int currentArm = 0;          //ID of current arm. 1 = pincher, 2 = reactor, 3 = widowX, 5 = snapper
int currentMode = 0;         //Current IK mode, 1=Cartesian, 2 = cylindrical, 3= backhoe
int currentOrientation = 0;  //Current wrist oritnation 1 = straight/normal, 2=90 degrees

String helpLink = "http://learn.trossenrobotics.com";  //link for error panel to display


PImage logoImg;
PImage footerImg;

//booleans for key tracking
boolean xkey = false;
boolean ykey = false;
boolean zkey = false;
boolean wangkey = false;
boolean wrotkey = false;
boolean gkey = false;
boolean dkey = false;

int startupWaitTime = 10000;    //time in ms for the program to wait for a response from the ArbotiX
Serial[] sPorts = new Serial[numSerialPorts];  //array of serial ports, one for each avaialable serial port.

int armPortIndex = -1; //the index of the serial port that an arm is currently connected to(relative to the list of avaialble serial ports). -1 = no arm connected


int analogSampleTime = 33;//time between analog samples
long lastAnalogSample = millis();//
int nextAnalog = 0;
int[]analogValues = new int[8];


/********DRAG AND DROP VARS*/
int numPanels =0;
int currentTopPanel = 0;
int dragFlag = -1;
int panelsX = 100;  //x coordinate for all panels
int panelsYStart = 25;//distance between top of parent and first panel
int panelYOffset = 25;//distance between panels
int panelHeight = 18;//height of the panel
int lastDraggedOverId = -1;
int lastDraggedOverColor = -1;
int numberPanelsDisplay = 17;
int draggingPosition = -1;
float draggingY = 0;

GPanel tempPanel0;
GPanel tempPanel1;

GPanel tempPanel;

int currentPose = 0;  //current pose that has been selected. 


ArrayList<int[]> poseData;
int[] blankPose = new int[8]; //blank pose : x, y, z, wristangle, wristRotate, Gripper, Delta, digitals


int[] defaultPose = {
  0, 200, 200, 0, 0, 256, 125, 0
}; //blank pose : x, y, z, wristangle, wristRotate, Gripper, Delta, digitals





boolean playSequence = false;
//boolean waitForResponse = false;
int lastTime;
int lastPose;



int connectFlag = 0;
int disconnectFlag = 0;
int autoConnectFlag = 0;
int cameraFlag = 2;
import processing.video.*;

Capture cam;


int pauseTime = 1000;

/***********/

public void setup() {
  size(475, 733, JAVA2D);  //draw initial screen //475
  poseData = new ArrayList<int[]>();

  createGUI();   //draw GUI components defined in gui.pde

  //Build Serial Port List
  serialPortString[0] = "Serial Port";   //first item in the list will be "Serial Port" to act as a label
  //iterate through each avaialable serial port  
  for (int i=0; i<numSerialPorts; i++) 
  {
    serialPortString[i+1] = Serial.list()[i];  //add the current serial port to the list, add one to the index to account for the first item/label "Serial Port"
  }
  serialList.setItems(serialPortString, 0);  //add contents of srialPortString[] to the serialList GUI    

  prepareExitHandler();//exit handler for clearing/stopping file handler
}

//Main Loop
public void draw()
{

  background(128);//draw background color
  image(logoImg, 5, 0, 280, 50);  //draw logo image
  image(footerImg, 15, 770);      //draw footer image

  currentTime = millis();  //get current timestamp

  if (connectFlag ==1)
  {


    //check to make sure serialPortSelected is not -1, -1 means no serial port was selected. Valid port indexes are 0+
    if (selectedSerialPort > -1)
    {    

      //try to connect to the port at 38400bps, otherwise show an error message
      try
      {
        sPorts[selectedSerialPort] =  new Serial(this, Serial.list()[selectedSerialPort], 38400);
      }
      catch(Exception e)
      {
        printlnDebug("Error Opening Serial Port"+serialList.getSelectedText());
        sPorts[selectedSerialPort] = null;
        displayError("Unable to open selected serial port" + serialList.getSelectedText() +". See link for possible solutions.", "http://learn.trossenrobotics.com/arbotix/8-advanced-used-of-the-tr-dynamixel-servo-tool");
      }
    }

    //check to see if the serial port connection has been made
    if (sPorts[selectedSerialPort] != null)
    {

      //try to communicate with arm
      if (checkArmStartup() == true)
      {       
        //disable connect button and serial list
        connectButton.setEnabled(false);
        connectButton.setAlpha(128);
        serialList.setEnabled(false);
        serialList.setAlpha(128);
        autoConnectButton.setEnabled(false);
        autoConnectButton.setAlpha(128);
        //enable disconnect button
        disconnectButton.setEnabled(true);
        disconnectButton.setAlpha(255);

        //enable & set visible control and mode panel
        modePanel.setVisible(true);
        modePanel.setEnabled(true);
        controlPanel.setVisible(true);
        controlPanel.setEnabled(true);
        sequencePanel.setVisible(true);
        sequencePanel.setEnabled(true);
        ioPanel.setVisible(true);
        ioPanel.setEnabled(true);
        delayMs(100);//short delay 
        setCartesian();
        statusLabel.setText("Connected");
      }

      //if arm is not found return an error
      else  
      {
        sPorts[selectedSerialPort].stop();
        //      sPorts.get(selectedSerialPort) = null;
        sPorts[selectedSerialPort] = null;
        printlnDebug("No Arm Found on port "+serialList.getSelectedText()) ;

        displayError("No Arm found on serial port" + serialList.getSelectedText() +". Make sure power is on and the arm is connected to the computer.", "http://learn.trossenrobotics.com/arbotix/8-advanced-used-of-the-tr-dynamixel-servo-tool");

        statusLabel.setText("Not Connected");
      }
    }

    connectFlag = 0;
  }


  if (disconnectFlag == 1)
  {
    putArmToSleep();
    //TODO: call response & check

    ///stop/disconnect the serial port and set sPort to null for future checks
    sPorts[armPortIndex].stop();   
    sPorts[armPortIndex] = null;

    //enable connect button and serial port 
    connectButton.setEnabled(true);
    connectButton.setAlpha(255);
    serialList.setEnabled(true);
    serialList.setAlpha(255); 
    autoConnectButton.setEnabled(true);
    autoConnectButton.setAlpha(255);

    //disable disconnect button
    disconnectButton.setEnabled(false);
    disconnectButton.setAlpha(128);
    //disable & set invisible control and mode panel
    controlPanel.setVisible(false);
    controlPanel.setEnabled(false); 
    sequencePanel.setVisible(false);
    sequencePanel.setEnabled(false);    
    modePanel.setVisible(false);
    modePanel.setEnabled(false);
    ioPanel.setVisible(false);
    ioPanel.setEnabled(false);
    wristPanel.setVisible(false);
    wristPanel.setEnabled(false);

    //uncheck all checkboxes to reset
    autoUpdateCheckbox.setSelected(false);
    //digitalCheckbox0.setSelected(false);
    digitalCheckbox1.setSelected(false);
    digitalCheckbox2.setSelected(false);
    digitalCheckbox3.setSelected(false);
    digitalCheckbox4.setSelected(false);
    digitalCheckbox5.setSelected(false);
    digitalCheckbox6.setSelected(false);
    digitalCheckbox7.setSelected(false);

    analogCheckbox.setSelected(false);

    //set arm/mode/orientation to default
    currentMode = 0;
    currentArm = 0;
    currentOrientation = 0;

    //reset button color mode
    cartesianModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);
    cylindricalModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);
    backhoeModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);

    //reset alpha trapsnparency on orientation buttons
    //DEPRECATED armStraightButton.setAlpha(128);
    //DEPRECATEDarm90Button.setAlpha(128);


    disconnectFlag = 0;
    statusLabel.setText("Not Connected");
  }



  if (autoConnectFlag == 1)
  {


    //disable connect button and serial list
    connectButton.setEnabled(false);
    connectButton.setAlpha(128);
    serialList.setEnabled(false);
    serialList.setAlpha(128);
    autoConnectButton.setEnabled(false);
    autoConnectButton.setAlpha(128);
    //enable disconnect button
    disconnectButton.setEnabled(true);
    disconnectButton.setAlpha(255);

    //for (int i=0;i<Serial.list().length;i++) //scan from bottom to top
    //scan from the top of the list to the bottom, for most users the ArbotiX will be the most recently added ftdi device
    for (int i=Serial.list ().length-1; i>=0; i--) 
    {
      println("port"+i);
      //try to connect to the port at 38400bps, otherwise show an error message
      try
      {
        sPorts[i] = new Serial(this, Serial.list()[i], 38400);
      }
      catch(Exception e)
      {
        printlnDebug("Error Opening Serial Port "+Serial.list()[i] + " for auto search");
        sPorts[i] = null;
      }
    }//end interating through serial list

    //try to communicate with arm
    if (checkArmStartup() == true)
    {
      printlnDebug("Arm Found from auto search on port "+Serial.list()[armPortIndex]) ;

      //enable & set visible control and mode panel, enable disconnect button
      modePanel.setVisible(true);
      modePanel.setEnabled(true);
      controlPanel.setVisible(true);
      controlPanel.setEnabled(true);
      sequencePanel.setVisible(true);
      sequencePanel.setEnabled(true);
      ioPanel.setVisible(true);
      ioPanel.setEnabled(true);
      disconnectButton.setEnabled(true);
      delayMs(200);//shot delay 
      setCartesian();

      statusLabel.setText("Connected");

      //break;
    }

    //if arm is not found return an error
    else  
    {
      //enable connect button and serial port 
      connectButton.setEnabled(true);
      connectButton.setAlpha(255);
      serialList.setEnabled(true);
      serialList.setAlpha(255); 
      autoConnectButton.setEnabled(true);
      autoConnectButton.setAlpha(255);

      //disable disconnect button
      disconnectButton.setEnabled(false);
      disconnectButton.setAlpha(128);
      //disable & set invisible control and mode panel

      displayError("No Arm found using auto seach. Please check power and connections", "");
      statusLabel.setText("Not Connected");
    }
    //stop all serial ports without an arm connected 
    for (int i=0; i<numSerialPorts; i++) 
    {      
      //if the index being scanned is not the index of an port with an arm connected, stop/null the port
      //if the port is already null, then it was never opened
      if (armPortIndex != i & sPorts[i] != null)
      {
        printlnDebug("Stopping port "+Serial.list()[i]) ;
        sPorts[i].stop();
        sPorts[i] = null;
      }
    }


    autoConnectFlag = 0;
  }




  //check if
  //  -update flag is true, and a packet needs to be sent
  //  --it has been more than 'updatePeriod' ms since the last packet was sent
  if (currentTime - prevCommandTime > updatePeriod )
  {



    //check if
    //--analog retrieval is enabled
    //it has been long enough since the last sample
    if (currentTime - lastAnalogSample > analogSampleTime && (true == enableAnalog))
    {
      if ( currentArm != 0)
      {
        println("analog");

        analogValues[nextAnalog] = analogRead(nextAnalog);
        analogLabel[nextAnalog].setText(
        Integer.toString(nextAnalog) + ":" + Integer.toString(analogValues[nextAnalog]));

        nextAnalog = nextAnalog+1;
        if (nextAnalog > 7)
        {
          nextAnalog = 0;
          lastAnalogSample = millis();
        }
      }
    }






    //check if
    //  -update flag is true, and a packet needs to be sent
    else if (updateFlag == true)
    {
      updateOffsetCoordinates();     //prepare the currentOffset coordinates for the program to send
      updateButtonByte();  //conver the current 'digital button' checkboxes into a value to be sent to the arbotix/arm
      prevCommandTime = currentTime; //update the prevCommandTime timestamp , used to calulcate the time the program can next send a command


      //check that the serial port is active - if the 'armPortIndex' variable is not -1, then a port has been connected and has an arm attached
      if (armPortIndex > -1)
      {
        //send commander packet with the current global currentOffset coordinatges
        sendCommanderPacket(xCurrentOffset, yCurrentOffset, zCurrentOffset, wristAngleCurrentOffset, wristRotateCurrentOffset, gripperCurrentOffset, deltaCurrentOffset, digitalButtonByte, extendedByte);  

        //if a sequence is playing, wait for the arm response before moving on
        //        if(playSequence ==true)
        //        {
        //          //use this code to enable return packet checking for positional commands
        //          byte[] responseBytes = new byte[5];    //byte array to hold response data
        //          //responseBytes = readFromArm(5);//read raw data from arm, complete with wait time
        //          responseBytes = readFromArmFast(5);
        //        }
        //        if(verifyPacket(responseBytes) == true)
        //        {
        //          printlnDebug("Moved!"); 
        //        }
        //        else
        //        {
        //          printlnDebug("No Arm Found"); 
        //        }
      }

      //in normal update mode, pressing the update button signals the program to send a packet. In this
      //case the program must set the update flag to false in order to stop new packets from being sent
      //until the update button is pressed again. 
      //However in autoUpdate mode, the program should not change this flag (only unchecking the auto update flag should set the flag to false)
      if (autoUpdateCheckbox.isSelected() == false)
      {
        updateFlag = false;//only set the updateFlag to false if the autoUpdate flag is false
      }
      //use this oppurtunity to set the extended byte to 0 if autoupdate is enabled - this way the extended packet only gets sent once
      else
      {
        if (extendedByte != 0)
        {
          extendedByte = 0;
          extendedTextField.setText("0");
        }
      }
    }//end command code
  }



  //DRAG AND DROP CODE
  //check if the 'dragFlag' is set
  if (dragFlag > -1)
  {

    int dragPanelNumber = dragFlag - currentTopPanel;  //dragPanelNumber now has the panel # (of the panel that was just dragged) relative to the panels that are currently being displayed.

    float dragPanelY = poses.get(dragFlag).getY();  //the final y coordinate of the panel that was last dragged

    int newPanelPlacement = floor((dragPanelY - panelsYStart)/25);//determine the panel #(relative to panels being shown) that the dragged panel should displace

    //set bounds for dragging panels too high/low
    newPanelPlacement = max(0, newPanelPlacement);//for negative numbers (i.e. dragged above first panel) set new panel to '0'
    newPanelPlacement = min(min(numberPanelsDisplay-1, poses.size())-1, newPanelPlacement);//for numbers that are too high (i.e. dragged below the last panel) set to the # of panels to display, or the size of the array list, whichever is smaller
    println(newPanelPlacement);


    if (lastDraggedOverId == -1)
    { 

      lastDraggedOverId = newPanelPlacement + currentTopPanel;
      lastDraggedOverColor =   poses.get(newPanelPlacement + currentTopPanel).getLocalColorScheme();
      poses.get(newPanelPlacement + currentTopPanel).setLocalColorScheme(15);

      println("First");
    } else if ((lastDraggedOverId != (newPanelPlacement + currentTopPanel)))
    {

      poses.get(lastDraggedOverId).setLocalColorScheme(lastDraggedOverColor);
      println("change! " +" " + lastDraggedOverColor+ " " + currentTopPanel);

      lastDraggedOverId = newPanelPlacement + currentTopPanel;
      lastDraggedOverColor =   poses.get(newPanelPlacement + currentTopPanel).getLocalColorScheme();
      poses.get(newPanelPlacement + currentTopPanel).setLocalColorScheme(15);
    } else
    {

      //lastDraggedOverId = newPanelPlacement + currentTopPanel;
      //poses.get(newPanelPlacement + currentTopPanel).setLocalColorScheme(0);
    }



    //check is the panel that set the 'dragFlag' has stopped being dragged.
    if (poses.get(dragFlag).isDragging() == false)
    {

      poses.get(lastDraggedOverId).setLocalColorScheme(lastDraggedOverColor);//set color for the displaced panel
      lastDraggedOverId = -1;//reset lastDragged vars for next iteration

      //dragFlag now contains a value corresponding to the the panel that was just being dragged
      //


      int lowestPanel = min(dragPanelNumber, newPanelPlacement); //figure out which panel number is lower 



      println("you dragged panel #" + dragPanelNumber+ "to position "+ dragPanelY  +" Which puts it at panel #"+newPanelPlacement);


      //array list management
      tempPanel0 = poses.get(dragPanelNumber);//copy the panel that was being dragged to a temporary object
      poses.remove(dragPanelNumber);//remove the panel from the array list
      poses.add(newPanelPlacement, tempPanel0);//add the panel into the array list at the position of the displaced panel

      int[] tempPoseData0 = poseData.get(dragPanelNumber);//copy the panel that was being dragged to a temporary object
      poseData.remove(dragPanelNumber);
      poseData.add(newPanelPlacement, tempPoseData0);//add the panel into the array list at the position of the displaced panel


      //rebuild all of the list placement based on its correct array placement
      for (int i = lowestPanel; i < poses.size ()-currentTopPanel; i++)
      {
        println("i " + i);
        poses.get(currentTopPanel+i).moveTo(panelsX, panelsYStart + (panelYOffset*i));//move the panel that was being dragged to its new position
        poses.get(currentTopPanel+i).setText(Integer.toString(currentTopPanel+i));//set the text displayed to the same as the new placement
        //whenever the program displaces a panel down, one panel will need to go from being visible to not being visible this will always be the 'numberPanelsDisplay'th panel
        if (i == numberPanelsDisplay)
        {
          poses.get(currentTopPanel+i).setVisible(false);//set the panel that has 'dropped off' the visual plane to not visible
        }
      }       




      tempPanel0 = null;
      dragFlag = -1;   
      println("reset Flag");
    }//end dragging check.
  }//end dragFlag check






  if (playSequence == true)
  {
    pauseTime = int(pauseTextField.getText());

    if (millis() - lastTime > (20 * deltaCurrent + pauseTime))
    {
      //println("50 millis");
      for (int i = 0; i < poses.size (); i++)
      {
        if (i == lastPose)
        {
          poses.get(i).setCollapsed(false);
          poseToWorkspaceInternal(lastPose);
          updateFlag = true;//set update flag to signal sending an update on the next cycle
          updateOffsetCoordinates();//update the coordinates to offset based on the current mode



          println("play"+i);
        } else
        {
          poses.get(i).setCollapsed(true);
        }
      }
      lastPose = lastPose + 1;

      lastTime = millis();

      if (lastPose  >= poses.size())
      {
        //playSequence = false;
        lastPose = 0;
        println("play ending");
      }
    }
  }



  if (cameraFlag == 1)
  {


    try {  
      cam = new Capture(this, 320, 240, 30);
      cam.start();
      frame.setResizable(true);
    }
    catch(Exception e)
    {
    }
    frame.setSize(850, 750);
    cameraFlag = 2;
  }

  if (cameraFlag == 0)
  {

    frame.setSize(475, 750);
    cameraFlag = 2;
  }

  try {
    if (cam.available()) 
    {
      cam.read();
    }
    image(cam, 500, 0);
  }
  catch(Exception e)
  {
  }
}//end draw()


/******************************************************
 *  stop()
 *
 *  Tasks to perform on end of program
 ******************************************************/
void stop()
{

  debugOutput.flush(); // Writes the remaining data to the file
  debugOutput.close(); // Finishes the file
}


/******************************************************
 *  prepareExitHandler()
 *
 *  Tasks to perform on end of program
 * https://forum.processing.org/topic/run-code-on-exit
 ******************************************************/
private void prepareExitHandler () {
  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
    public void run () 
    {
      if (debugFileCreated == true)
      {
        debugOutput.flush(); // Writes the remaining data to the file
        debugOutput.close(); // Finishes the file
      }
    }
  }
  ));
}

/******************************************************
 *  printlnDebug()
 *
 *  function used to easily enable/disable degbugging
 *  enables/disables debugging to the console
 *  prints a line to the output
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
 *      boolean debugFile
 *      PrintWriter debugOutput
 *      boolean debugFileCreated
 *  Returns: 
 *    void
 ******************************************************/
void printlnDebug(String message, int type)
{
  if (debugConsole == true)
  {
    if ((type == 1 & debugGuiEvent == true) || type == 0 || type == 2)
    {
      println(message);
    }
  }

  if (debugFile == true)
  {

    if ((type == 1 & debugGuiEvent == true) || type == 0 || type == 2)
    {

      if (debugFileCreated == false)
      {
        debugOutput = createWriter("debugArmLink.txt");
        debugOutput.println("Started at "+ day() +"-"+ month() +"-"+ year() +" "+ hour() +":"+ minute() +"-"+ second() +"-"); 
        debugFileCreated = true;
      }


      debugOutput.println(message);
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
 *      boolean debugFile
 *      PrintWriter debugOutput
 *      boolean debugFileCreated
 *  Returns: 
 *    void
 ******************************************************/
void printDebug(String message, int type)
{
  if (debugConsole == true)
  {
    if ((type == 1 & debugGuiEvent == true)  || type == 2)
    {
      print(message);
    }
  }

  if (debugFile == true)
  {

    if ((type == 1 & debugGuiEvent == true) || type == 0 || type == 2)
    {

      if (debugFileCreated == false)
      {
        debugOutput = createWriter("debugArmLink.txt");

        debugOutput.println("Started at "+ day() +"-"+ month() +"-"+ year() +" "+ hour() +":"+ minute() +"-"+ second() ); 

        debugFileCreated = true;
      }


      debugOutput.print(message);
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
 * Key combinations
 * holding a number ket and pressing up/down will
 * increment/decrement the corresponding field
 *
 * The program will use keyPressed() to log whenever a
 * number key is being held. If later 'Up' or 'Down'
 * is also logged, they value will be changed
 *  keyReleased() will be used to un-log the number values
 *  once they are released.
 *
 * 1-x/base
 * 2-y/shoulder
 * 3-z/elbow
 * 4-wrist angle
 * 5-wrist rotate
 * 6-gripper
 ******************************************************/
void keyPressed()
{

  if (currentArm != 0)
  {
    //change 'updageFlag' variable if 'enter' is pressed
    if (key ==ENTER)
    {
      updateFlag = true;
      updateOffsetCoordinates();
    }

    //if any of the numbers 1-6 are currently being pressed, change the state of the variable
    if (key =='1')
    {
      xkey=true;
    }
    if (key =='2')
    {
      ykey=true;
    }
    if (key =='3')
    {
      zkey=true;
    }
    if (key =='5')
    {
      wangkey=true;
    }
    if (key =='6')
    {
      wrotkey=true;
    }
    if (key =='4')
    {
      gkey=true;
    }
    if (key =='7')
    {
      dkey=true;
    }




    if (key == ' ')
    {

      sendCommanderPacket(0, 0, 0, 0, 0, 0, 0, 0, 17);    //send a commander style packet - the first 8 bytes are inconsequntial, only the last byte matters. '17' is the extended byte that will stop the arm
      updateFlag = false;
      autoUpdateCheckbox.setSelected(false);
    }  

    if (key == 'p')
    {

      playSequence = !playSequence;
    }





    if (key == ',')
    {

      poseToWorkspaceInternal(currentPose);
    }
    if (key == '.')
    {
      workspaceToPoseInternal();
    }


    //check for up/down keys
    if (key == CODED)
    {










      //if up AND a number 1-6 are being pressed, increment the appropriate field
      if (keyCode == UP)
      {
        if (xkey == true)
        {
          println(xCurrent);
          xCurrent = xCurrent + 1;
        }
        if (ykey == true)
        {
          yCurrent = yCurrent + 1;
        }
        if (zkey == true)
        {
          zCurrent = zCurrent + 1;
        }
        if (wangkey == true)
        {
          wristAngleCurrent = wristAngleCurrent + 1;
        }
        if (wrotkey == true)
        {
          wristRotateCurrent = wristRotateCurrent + 1;
        }
        if (gkey == true)
        {
          gripperCurrent = gripperCurrent + 1;
        }
        if (dkey == true)
        {
          deltaCurrent = deltaCurrent + 1;
        }
      }

      //if down AND a number 1-6 are being pressed, increment the appropriate field
      if (keyCode == DOWN)
      {
        if (xkey == true)
        {
          xCurrent = xCurrent - 1;
        }
        if (ykey == true)
        {
          yCurrent = yCurrent - 1;
        }
        if (zkey == true)
        {
          zCurrent = zCurrent - 1;
        }
        if (wangkey == true)
        {
          wristAngleCurrent = wristAngleCurrent - 1;
        }
        if (wrotkey == true)
        {
          wristRotateCurrent = wristRotateCurrent - 1;
        }
        if (gkey == true)
        {
          gripperCurrent = gripperCurrent - 1;
        }
        if (dkey == true)
        {
          deltaCurrent = deltaCurrent - 1;
        }
      }



      xTextField.setText(Integer.toString(xCurrent));
      yTextField.setText(Integer.toString(yCurrent));
      zTextField.setText(Integer.toString(zCurrent));
      wristAngleTextField.setText(Integer.toString(wristAngleCurrent));
      wristRotateTextField.setText(Integer.toString(wristRotateCurrent));
      gripperTextField.setText(Integer.toString(gripperCurrent));

      if (currentMode == 1)
      {  
        xSlider.setValue(xCurrent);
        ySlider.setValue(yCurrent);
        zSlider.setValue(zCurrent);
        wristRotateKnob.setValue(wristRotateCurrent);
        wristAngleKnob.setValue(wristAngleCurrent);
        gripperLeftSlider.setValue(gripperCurrent);
        gripperRightSlider.setValue(gripperCurrent);
        deltaSlider.setValue(deltaCurrent);
      } else if (currentMode == 2 )
      {
        baseKnob.setValue(xCurrent);
        ySlider.setValue(yCurrent);
        zSlider.setValue(zCurrent);
        wristRotateKnob.setValue(wristRotateCurrent);
        wristAngleKnob.setValue(wristAngleCurrent);
        gripperLeftSlider.setValue(gripperCurrent);
        gripperRightSlider.setValue(gripperCurrent);
        deltaSlider.setValue(deltaCurrent);
      } else if (currentMode == 3)
      {
        baseKnob.setValue(xCurrent);
        shoulderKnob.setValue(yCurrent);
        elbowKnob.setValue(zCurrent);
        wristRotateKnob.setValue(wristRotateCurrent);
        wristAngleKnob.setValue(wristAngleCurrent);
        gripperLeftSlider.setValue(gripperCurrent);
        gripperRightSlider.setValue(gripperCurrent);
        deltaSlider.setValue(deltaCurrent);
      }
    }
  }
}
void keyReleased()
{

  //change variable state when number1-6 is released

    if (key =='1')
  {
    xkey=false;
  }
  if (key =='2')
  {
    ykey=false;
  }
  if (key =='3')
  {
    zkey=false;
  }
  if (key =='5')
  {
    wangkey=false;
  }
  if (key =='6')
  {
    wrotkey=false;
  }
  if (key =='4')
  {
    gkey=false;
  }
  if (key =='7')
  {
    dkey = false;
  }
}


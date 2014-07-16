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
int updatePeriod = 33;          //minimum period between packet in Milliseconds , 33ms = 30Hz which is the standard for the commander/arm control protocol

long prevCommandTime = 0;       //timestamp for the last time that the program sent a serial packet
long heartbeatTime = 0;         //timestamp for the last time that the program received a serial packet from the Arm
long currentTime = 0;           //timestamp for currrent time

int packetRepsonseTimeout = 5000;      //time to wait for a response from the ArbotiX Robocontroller / Arm Control Protocol

int currentArm = 0;          //ID of current arm. 1 = pincher, 2 = reactor, 3 = widowX
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

int startupWaitTime = 10000;    //time in ms for the program to wait for a response from the ArbotiX
Serial[] sPorts = new Serial[numSerialPorts];  //array of serial ports, one for each avaialable serial port.

int armPortIndex = -1; //the index of the serial port that an arm is currently connected to(relative to the list of avaialble serial ports). -1 = no arm connected


int analogSampleTime = 333;//time between analog samples
long lastAnalogSample = millis();//
int nextAnalog = 0;
int[]analogValues = new int[8];


/********DRAG AND DROP VARS*/
int numPanels =0;
int currentTopPanel = 0;
int dragFlag = -1;
int panelsX = 550;  //x coordinate for all panels
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

int currentPose = -1;  //current pose that has been selected. 


ArrayList<int[]> poseData;
int[] blankPose = new int[8]; //blank pose : x, y, z, wristangle, wristRotate, Gripper, Delta, digitals

/***********/

public void setup(){
  size(900, 700, JAVA2D);  //draw initial screen
  poseData = new ArrayList<int[]>();
   
  createGUI();   //draw GUI components defined in gui.pde

  //Build Serial Port List
  serialPortString[0] = "Serial Port";   //first item in the list will be "Serial Port" to act as a label
  //iterate through each avaialable serial port  
  for (int i=0;i<numSerialPorts;i++) 
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
  image(logoImg, 505, 5, 230, 78);  //draw logo image
  image(footerImg, 15, 770);      //draw footer image

  currentTime = millis();  //get current timestamp
  
  //check if
  //  -update flag is true, and a packet needs to be sent
  //  --it has been more than 'updatePeriod' ms since the last packet was sent
  if(currentTime - prevCommandTime > updatePeriod )
  {
    
    //check if
    //  -update flag is true, and a packet needs to be sent
    if(updateFlag == true)
    {
      updateOffsetCoordinates();     //prepare the currentOffset coordinates for the program to send
      updateButtonByte();  //conver the current 'digital button' checkboxes into a value to be sent to the arbotix/arm
      prevCommandTime = currentTime; //update the prevCommandTime timestamp , used to calulcate the time the program can next send a command
  
      
      //check that the serial port is active - if the 'armPortIndex' variable is not -1, then a port has been connected and has an arm attached
      if(armPortIndex > -1)
      {
        //send commander packet with the current global currentOffset coordinatges
        sendCommanderPacket(xCurrentOffset, yCurrentOffset, zCurrentOffset, wristAngleCurrentOffset, wristRotateCurrentOffset, gripperCurrentOffset, deltaCurrentOffset, digitalButtonByte, extendedByte);  
     

      /*//use this code to enable return packet checking for positional commands
        byte[] responseBytes = new byte[5];    //byte array to hold response data
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
    }//end command code
    

    //check if
    //--analog retrieval is enabled
    //it has been long enough since the last sample
    else if(currentTime - lastAnalogSample > analogSampleTime && (true == enableAnalog))
    {
      if( currentArm != 0)
      {
        println("analog");
        
        analogValues[nextAnalog] = analogRead(nextAnalog);
        analogLabel[nextAnalog].setText(Integer.toString(analogValues[nextAnalog]));

        nextAnalog = nextAnalog+1;
        if(nextAnalog > 7)
        {
          nextAnalog = 0;
          lastAnalogSample = millis();
        }
        
      }
        
        
      
    }

  }
  
  
  
  //DRAG AND DROP CODE
     //check if the 'dragFlag' is set
  if(dragFlag > -1)
  {
    
      int dragPanelNumber = dragFlag - currentTopPanel;  //dragPanelNumber now has the panel # (of the panel that was just dragged) relative to the panels that are currently being displayed.
         
      float dragPanelY = poses.get(dragFlag).getY();  //the final y coordinate of the panel that was last dragged
      
      int newPanelPlacement = floor((dragPanelY - panelsYStart)/25);//determine the panel #(relative to panels being shown) that the dragged panel should displace
   
      //set bounds for dradding panels too high/low
      newPanelPlacement = max(0,newPanelPlacement);//for negative numbers (i.e. dragged above first panel) set new panel to '0'
      newPanelPlacement = min(min(numberPanelsDisplay-1,poses.size())-1,newPanelPlacement);//for numbers that are too high (i.e. dragged below the last panel) set to the # of panels to display, or the size of the array list, whichever is smaller
      println(newPanelPlacement);
       
       
      if(lastDraggedOverId == -1)
      { 
        
        lastDraggedOverId = newPanelPlacement + currentTopPanel;
        lastDraggedOverColor =   poses.get(newPanelPlacement + currentTopPanel).getLocalColorScheme();
        poses.get(newPanelPlacement + currentTopPanel).setLocalColorScheme(15);
        
        println("First");
      } 
      else if((lastDraggedOverId != (newPanelPlacement + currentTopPanel)))
      {
        
        poses.get(lastDraggedOverId).setLocalColorScheme(lastDraggedOverColor);
        println("change!" + lastDraggedOverColor+ currentTopPanel);
        
        lastDraggedOverId = newPanelPlacement + currentTopPanel;
        lastDraggedOverColor =   poses.get(newPanelPlacement + currentTopPanel).getLocalColorScheme();
        poses.get(newPanelPlacement + currentTopPanel).setLocalColorScheme(15);
      }
      else
      {
      
       //lastDraggedOverId = newPanelPlacement + currentTopPanel;
       //poses.get(newPanelPlacement + currentTopPanel).setLocalColorScheme(0);
        
      }
      
        
      
    //check is the panel that set the 'dragFlag' has stopped being dragged.
    if(poses.get(dragFlag).isDragging() == false)
    {
      
      poses.get(lastDraggedOverId).setLocalColorScheme(lastDraggedOverColor);//set color for the displaced panel
      lastDraggedOverId = -1;//reset lastDragged vars for next iteration
      
      //dragFlag now contains a value corresponding to the the panel that was just being dragged
      //


      int lowestPanel = min(dragPanelNumber, newPanelPlacement); //figure out which panel number is lower 
      
      
      
      println("you dragged panel #" + dragPanelNumber+ "to position "+ dragPanelY  +" Which puts it at panel #"+newPanelPlacement);
      
      
      //array list management
      tempPanel0 = poses.get(dragFlag);//copy the panel that was being dragged to a temporary object
      poses.remove(dragFlag);//remove the panel from the array list
      poses.add(newPanelPlacement,tempPanel0);//add the panel into the array list at the position of the displaced panel
      
      //rebuild all of the list placement based on its correct array placement
      for(int i = lowestPanel; i < poses.size()-currentTopPanel;i++)
        {
           println("i " + i);
          poses.get(currentTopPanel+i).moveTo(panelsX, panelsYStart + (panelYOffset*i));//move the panel that was being dragged to its new position
          poses.get(currentTopPanel+i).setText(Integer.toString(currentTopPanel+i));//set the text displayed to the same as the new placement
          //whenever the program displaces a panel down, one panel will need to go from being visible to not being visible this will always be the 'numberPanelsDisplay'th panel
          if(i == numberPanelsDisplay)
          {
            poses.get(currentTopPanel+i).setVisible(false);//set the panel that has 'dropped off' the visual plane to not visible      
  
          }
        
        }       
 
      
      

    tempPanel0 = null;
    dragFlag = -1;   
    println("reset Flag");

    }//end dragging check.          
  }//end dragFlag check
  
  
  
  
  
  
  
  
  
  
  
  
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
      if(debugFileCreated == true)
      {
        debugOutput.flush(); // Writes the remaining data to the file
        debugOutput.close(); // Finishes the file         
      }  
  }
  }));
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
   if(debugConsole == true)
   {
      if((type == 1 & debugGuiEvent == true) | type == 0 | type == 2)
      {
        println(message); 
      }
   }

  if(debugFile == true)
  {
    
      if((type == 1 & debugGuiEvent == true) | type == 0 | type == 2)
      {
        
        if(debugFileCreated == false)
        {
          debugOutput = createWriter("debugArmControl.txt");
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
   if(debugConsole == true)
   {
      if((type == 1 & debugGuiEvent == true)  | type == 2)
      {
        print(message); 
      }
   }
   
  if(debugFile == true)
  {
    
      if((type == 1 & debugGuiEvent == true) | type == 0 | type == 2)
      {
        
        if(debugFileCreated == false)
        {
          debugOutput = createWriter("debugArmControl.txt");
          
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
  //change 'updageFlag' variable if 'enter' is pressed
  if(key ==ENTER)
  {
    updateFlag = true;
    updateOffsetCoordinates();
  }
  
  //if any of the numbers 1-6 are currently being pressed, change the state of the variable
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
  
  //check for up/down keys
  if (key==CODED)
  {
   //if up AND a number 1-6 are being pressed, increment the appropriate field
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
     
   //if down AND a number 1-6 are being pressed, increment the appropriate field
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
  
  //change variable state when number1-6 is released
  
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

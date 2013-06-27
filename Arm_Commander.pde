/****************************************************
* Trossen Robotics DYNAMIXEL Servo ID Program 
*
*
*
* This progam offers an interface to easily set and test the ID and Baud of various
* DYNAMIXEL Robot Servos using the ArbotiX Robocontroller.
*
* With this program you can
* -open a serial port comunication line with an ArbotiX running the ROS sketch
* -scan for a DYNAMIXEL ID 0-252 on bauds 57600 or 1000000
* -set the ID of a servo
* -baud will always be set to 1000000
* -send a value to the "Goal Position" register of the DYNAMIXEL, moving it
*
* Currently supported DYNAMIXELS include
* AX-12+
* AX-12A
* AX-12W
* AX-18A
* MX-28T
* MX-64T
* MX-106T
*
* The Following servos should work, using an RX bridge, but have not been tested
*  RX-24F
*  RX-28
*  RX-64
*  EX-106
*  MX-28R
*  MX-64R
*  MX-106R
*  
*
*
*
*Protocol and DYNAMIXEL reference
*  http://support.robotis.com/en/product/dynamixel/ax_series/dxl_ax_actuator.htm#Actuator_Address_18
*  http://support.robotis.com/en/product/dynamixel/communication/dxl_instruction.htm
*  http://support.robotis.com/en/product/dynamixel/dxl_communication.htm
*  http://support.robotis.com/en/product/dynamixel/communication/dxl_packet.htm
*/

import controlP5.*; //Import the P5 Library for GUI interface elements (drop list, button)
import processing.serial.*; //import serial library to communicate with the ArbotiX


Serial sPort;            //serial object 
ControlP5 cp5;           // p5 control object
DropdownList serialList;    //inintiate drop down boxes for com port list
Group controGroup;         //group for DYNAMIXEL scanning widgets

Group startupGroup;      //group for startup message
Group errorGroup;        //group for error messages

//text fields for users
Textfield xField, yField, zField, wristRotField, wristAngleField, gripperField, extField, detlaField;  


Textarea startupText;         //startup text that tells user to connect to the arbotix - also shows up after a disconnect
Textarea errorText;           //error text for error group
Textarea successSet;          //text that displays info on a successful set after setDyna has been pressed


//Button scanDynaButton;
Button connectButton;
Button disconnectButton;
Button autoSearchButton;
Button update;

CheckBox autoUpdate;

CheckBox buttonBox;



Slider xSlider, ySlider, zSlider, wristRotSlider, wristAngleSlider, gripperSlider;


int cnt = 0;                  //count for listbox items
int selectedPort;             //currently selected port from serialList drop down

int debug = 0;                //change to '0' to disable bedbugginf messages from the console, '1' to enable TODO:log debugging to a file, add option to enable debugging
int running = 0;              //enabled on draw(), used to avoid controlp5 from running functions immidealty on startup

int updateFlag = 1;

int time = 0;                 //holds the time of the last time the servo and arbotix connections were checked.

PImage img;                   //image object for TR logo

long prevMillis = 0;
long currentMillis = 0;
void setup() 
{
  size(220, 443);//size of application working area
 // img = loadImage("TRheaderLogo.png");  // Load the TR logo
  cp5 = new ControlP5(this);//intiaite controlp5 object   
  ControlFont cf1 = new ControlFont(createFont("Arial",15));//intitiate new font for buttons
 
//Instantiate groups to hold our various control items. Groups will make it easy to organize and hide/show control items 
  controGroup = cp5.addGroup("controGroup")
                .setPosition(10,60)
                .setBackgroundColor(color(0, 255))
                .setWidth(200)
                .setBackgroundHeight(350)
                .disableCollapse()
                .bringToFront()
                .setCaptionLabel("Control Options")
                .setVisible(true)
                //.hideBar()
                ;  
   
/*********************CONTROL GROUP******************/
  //scan button
  update = cp5.addButton("updateButton")
   .setValue(1)
   .setPosition(10,350)
   .setSize(70,45)
   .setCaptionLabel("Update")  
   .moveTo(controGroup)   
   ;
 // set font for the scan button                
  
  cp5.getController("updateButton")
     .getCaptionLabel()
     .setFont(cf1)     
     ;    
    

  autoUpdate = cp5.addCheckBox("autoUpdate")
                .setPosition(100, 350)
                .setColorForeground(color(120))
                .setColorActive(color(255))
                .setColorLabel(color(255))
                .setSize(10, 10)
                .setItemsPerRow(3)
                .setSpacingColumn(30)
                .setSpacingRow(20)
                .addItem("Auto Update", 0)
   .moveTo(controGroup)   
                
                ;


  buttonBox = cp5.addCheckBox("buttonBox")
                .setPosition(10, 300)
                .setColorForeground(color(120))
                .setColorActive(color(255))
                .setColorLabel(color(255))
                .setSize(10, 10)
                .setItemsPerRow(3)
                .setSpacingColumn(30)
                .setSpacingRow(20)
                .addItem("1", 0)
                .addItem("2", 1)
                .addItem("3", 2)
                .addItem("4", 3)
                .addItem("5", 4)
                .addItem("6", 5)
                .addItem("7", 6)
                .addItem("8", 7)
   .moveTo(controGroup)   
                
                ;

  //text field that will hold the current servo's ID (when nothing is connected or during scanning, this field will show a message)
  xField = cp5.addTextfield("xField")
                  .setPosition(10,10)
                  .setAutoClear(false)

                  .setCaptionLabel("X Coord:[-512:511]") 
                  .setWidth(30)
                  .setValue("0")
                  .moveTo(controGroup)   
                  ;   

  xSlider =   cp5.addSlider("xSlider")
                 .setPosition(50,10)
                 .setRange(-512,512)
                 .setSize(100,20)
                  .moveTo(controGroup)
                  .setCaptionLabel("") 
                 ;
  
 
  yField = cp5.addTextfield("yField")
                  .setPosition(10,50)
                  .setAutoClear(false)

                  .setCaptionLabel("Y Coord: [0:1023]") 
                  .setWidth(30)
                  .setValue("512")
                  .moveTo(controGroup)   
                  ;

  ySlider =   cp5.addSlider("ySlider")
                 .setPosition(50,50)
                 .setRange(0,1023)
                 .setSize(100,20)
                  .moveTo(controGroup)
                  .setCaptionLabel("") 
                 ;   
                  
  zField = cp5.addTextfield("zField")
                  .setPosition(10,90)
                  .setAutoClear(false)

                  .setCaptionLabel("Z Coord: [0:1023]") 
                  .setWidth(30)
                  .setValue("512")
                  .moveTo(controGroup)   
                  ;  

  zSlider =   cp5.addSlider("zSlider")
                 .setPosition(50,90)
                 .setRange(0,1023)
                 .setSize(100,20)
                  .moveTo(controGroup)
                  .setCaptionLabel("") 
                 ;    

                  
  wristAngleField = cp5.addTextfield("wristAngleField")
                  .setPosition(10,130)
                  .setAutoClear(false)

                  .setCaptionLabel("Wrist Angle: [0:1023]") 
                  .setWidth(30)
                  .setValue("512")
                  .moveTo(controGroup)   
                  ;   


  wristAngleSlider =   cp5.addSlider("wristAngleSlider")
                 .setPosition(50,130)
                 .setRange(0,1023)
                 .setSize(100,20)
                  .moveTo(controGroup)
                  .setCaptionLabel("") 
                 ;   
                  
  wristRotField = cp5.addTextfield("wristRotField")
                  .setPosition(10,170)
                  .setAutoClear(false)

                  .setCaptionLabel("Wrist Rotate: [0:1024]") 
                  .setWidth(30)
                  .setValue("512")
                  .moveTo(controGroup)   
                  ;   


  wristRotSlider =   cp5.addSlider("wristRotSlider")
                 .setPosition(50,170)
                 .setRange(0,1023)
                 .setSize(100,20)
                  .moveTo(controGroup)
                  .setCaptionLabel("") 
                 ;   
                  
  gripperField = cp5.addTextfield("gripperField")
                  .setPosition(10,210)
                  .setAutoClear(false)

                  .setCaptionLabel("Gripper: [0:1024]") 
                  .setWidth(30)
                  .setValue("512")
                  .moveTo(controGroup)   
                  ;   



  gripperSlider =   cp5.addSlider("gripperSlider")
                 .setPosition(50,210)
                 .setRange(0,1023)
                 .setSize(100,20)
                  .moveTo(controGroup)
                  .setCaptionLabel("") 
                 ;                     
  detlaField = cp5.addTextfield("detlaField")
                  .setPosition(10,250)
                  .setAutoClear(false)

                  .setCaptionLabel("Delta: [0:1024]") 
                  .setWidth(30)
                  .setValue("512")
                  .moveTo(controGroup)   
                  ;   





 /******************ALERTS*******************/
  //initialize group that will be shown on startup with instructions
  startupGroup = cp5.addGroup("startupGroup")
                .setPosition(10,170)
                .setBackgroundColor(color(0, 255))
                .setWidth(200)
                .setBackgroundHeight(100)
                .disableCollapse()
                .bringToFront()
                .setCaptionLabel("Not Connected")
                .setVisible(false)
                ;
  //initialize text area instruction text for startup text              
  startupText = cp5.addTextarea("startupText")
                  .setPosition(10,10)
                  .setSize(180,70)
                  .setFont(createFont("arial",15))
                  .setLineHeight(15)
                  .setColor(color(128))
                  .setColorBackground(color(255,100))
                  .setColorForeground(color(255,100))   
                  .moveTo(startupGroup)   
                  .setVisible(true)
                  ;
  //set startupText text
  startupText.setText("Not connected. Choose a serial  port and connect");    
    

  //initialize group to hold errors       
  errorGroup = cp5.addGroup("errorWindow")
                .setPosition(10,170)
                .setBackgroundColor(color(0, 255))
                .setWidth(200)
                .setBackgroundHeight(100)
                .disableCollapse()
                .bringToFront()
                .setCaptionLabel("Error")
                .setVisible(false)
                ;
                
  //initialize button to dismiss errors              
  cp5.addButton("errorButton")
     .setValue(1)
     .setPosition(75,75)
     .setSize(50,20)
     .setCaptionLabel("      OK")     
     .moveTo(errorGroup)   
     ;


  //initialize out of bounds error text - show when the ID set by the user is lower than 0 or exceeds 252       
  errorText = cp5.addTextarea("errorText")
                 .setPosition(10,10)
                  .setSize(150,50)
                  .setFont(createFont("arial",12))
                  .setLineHeight(12)
                  .setColor(color(128))
                  .setColorBackground(color(255,100))
                  .setColorForeground(color(255,100))   
                  .moveTo(errorGroup)    
                  .setVisible(true)
                  .hideScrollbar()
                  ;
  errorText.setText("Error");    


  //initalize text to be shown when servos is sucesfully set  
  successSet = cp5.addTextarea("successSet")
                  .setPosition(10,50)
                  .setSize(180,45)
                  .setFont(createFont("arial",12))
                  .setLineHeight(12)
                  .setColor(color(128))
                  .setColorBackground(color(255,100))
                  .setColorForeground(color(255,100))   
                  .moveTo(controGroup)    
                  .hideScrollbar()
                  .setVisible(false)
                  ;
    
/*********************SERIAL PORTS/BUTTONS******************/ 

  //initialize button for connecting to selected serial port 
  connectButton = cp5.addButton("connectSerial")
                     .setValue(1)
                     .setPosition(10,25)
                     .setSize(55,15)
                     .setCaptionLabel("Connect")
     ;
     
  //initialize button for disconnecting from current serial port 
  disconnectButton =  cp5.addButton("disconnectSerial")
                         .setValue(1)
                         .setPosition(75,25)
                         .setSize(60,15)
                         .setCaptionLabel("Disconnect")                       
                         .lock()
                         .setColorBackground(color(200))
                         ;
     
  //initialize button to search all available serial ports for an ArbotiX     
  autoSearchButton =  cp5.addButton("autoSearch")
                         .setValue(1)
                         .setPosition(150,25)
                         .setSize(60,15)
                         .setCaptionLabel("Auto Search")
                         ;
     
  //initlaize help button   
  cp5.addButton("helpButton")
     .setValue(1)
     .setPosition(180,5)
     .setSize(30,15)
     .setCaptionLabel("Help")
     ;      
  //initialize serialList dropdown properties
  serialList = cp5.addDropdownList("serialPort")
                  .setPosition(10, 21)
                  .setSize(150,200)
                  .setCaptionLabel("Serial Port")
                  ;
  customize(serialList); // customize the com port list
    
  //iterate through all the items in the serial list (all available serial ports) and add them to the 'serialList' dropdown
  for (int i=0;i<Serial.list().length;i++) 
  {
    //if((Serial.list()[i]).startsWith("/dev/tty.usbserial"))//remove extra UNIX ports to ease confusion
    //{  
    ListBoxItem lbi = serialList.addItem(Serial.list()[i], i);
    lbi.setColorBackground(0xffff0000);
    //}
  }
  

}//END SETUP

/*****************************************************START P5 CONTROLLER FUNCTIONS****************************/



void controlEvent(ControlEvent theEvent) 
{
  if (theEvent.isFrom(autoUpdate)) 
  { 
    if((int)update.getArrayValue()[0] ==1)
    {
     updateFlag = 1; 
    }
    else
    {
      updateFlag = 0; 
    }
  } 
/*
  if (theEvent.isFrom(buttonBox)) {
    myColorBackground = 0;
    print("got an event from "+checkbox.getName()+"\t\n");
    // checkbox uses arrayValue to store the state of 
    // individual checkbox-items. usage:
    println(checkbox.getArrayValue());
    int col = 0;
    for (int i=0;i<checkbox.getArrayValue().length;i++) {
      int n = (int)checkbox.getArrayValue()[i];
      print(n);
      if(n==1) {
        myColorBackground += checkbox.getItem(i).internalValue();
      }
    }
    println();    
  }   
  */ 
   
   
}








/************************************
 * errorButton
 *
 * errorButton will receive changes from  controller(button) with name errorButton
 * errorButton will hide the errortext and group. 
 ************************************/
public void errorButton(int theValue) 
{
  if(running == 1)
  {
    errorGroup.setVisible(false);
  }
}  //end error button




/************************************
 * errorButton
 *
 * updateButton will update the serial packet with the new numbers
 ************************************/
public void updateButton(int theValue) 
{
 updateFlag =1; 
}


/************************************
 * connectSerial
 *
 * connectSerial will receive changes from  controller(button) with name connectSerial
 * connectSerial will take the currently selected serial port and attempt to connect to it
 * connectSerial will also check that serial port to make sure that an arbotix is connected
 *
 ************************************/  
public void connectSerial(int theValue) 
{
  if(running  == 1)//check to make sure we're in run mode
  {
    int serialPortIndex = (int)serialList.value();//get the serial port selected from the serlialList
    
    //try to connect to the port at 115200bps, otherwise show an error message
    try
    {
      sPort = new Serial(this, Serial.list()[serialPortIndex], 115200);
    }
    catch(Exception e)
    {
      if(debug ==1){println("Error Opening Serial Port");}
      errorGroup.setVisible(true);
      errorText.setVisible(true);        
      errorText.setText("Error Connecting to Port - try a different port or try closing other applications using the current port");    
    }
    
    delayMs(100);//add delay for some systems
    
    //send a command to see if the ArbotiX is connected. 
 /*   if(pingArbotix()== 1)
    {
      //show scan and test group
      scanGroup.setVisible(true);
      testGroup.setVisible(true);
      
      //hide error groups
      startupGroup.setVisible(false);
      errorGroup.setVisible(false);
      
      //lock connect button and change apperance, unlock disconnect button and change apperance
      connectButton.lock();
      connectButton.setColorBackground(color(200));
      autoSearchButton.lock();
      autoSearchButton.setColorBackground(color(200));
      disconnectButton.unlock();
      disconnectButton.setColorBackground(color(2,52,77));
    }
    else
    {
      if(debug ==1){println("ArbotiX Not detected");}
      errorGroup.setVisible(true);
      errorText.setVisible(true);
      errorText.setText("No ArbotiX detected on this port. Make sure your ArbotiX is powered on and try again, or try a different port.");    
      sPort.stop();  //disconnect from serial port
      sPort = null;  //set serial port to null, so other functions can easily know we're not connected
    }*/
  }     
}// end connectSerial


/************************************
 * disconnectSerial
 *
 * disconnectSerial will receive changes from  controller(button) with name disconnectSerial
 * disconnectSerial will disconnect from the current serial port and hide GUI elements that should only
 * be available when connected to an arbotix
 ************************************/  
public void disconnectSerial(int theValue) 
{
  //check to make sure we're in run mode and that the serial port is connected
  if(running ==1 && sPort != null)
  {
    sPort.stop();//stop/disconnect the serial port   
    sPort = null;//set the serial port to null, incase another function checks for connectivity
    //curIdField.setValue("No Servo Connected");//change current id field to a prompt
    //curIdField.valueLabel().style().marginLeft = 0;
    //dynaModelNameField.setValue("");//change model name field to nothing
    //servoScanned = 0; //disconnecting the serial port also disconnects any currently connected sercos
    //hide the scan set and test group
    controGroup.setVisible(false);
   // setGroup.setVisible(false);
   // testGroup.setVisible(false);
    //make visible the statup prompt
    startupGroup.setVisible(true);

    //unlock connect button and change apperance, lock disconnect button and change apperance
    connectButton.unlock();
    connectButton.setColorBackground(color(2,52,77));
    autoSearchButton.unlock();
    autoSearchButton.setColorBackground(color(2,52,77));
    disconnectButton.lock();
    disconnectButton.setColorBackground(color(200));
  
  }
}//end disconnectSerial



/************************************
 * helpButton
 *
 * helpButton will receive changes from  controller(button) with name helpButton
 * helpButton will link to the servo setter's documentation
 * TODO: make the help a full group panel, to include options
 *  -debug
 *  -full scan
 *  -version info
 ************************************/  
public void helpButton(int theValue) 
{
  if(running ==1)
  {
   link("http://www.trossenrobotics.com/dynamanager");
  }
}//end helpButton



/************************************
 * autoSearch
 *
 * autoSearch will receive changes from  controller(button) with name autoSearch
 * autoSearch will scan/connect to each available serial port and
 *  check if an ArbotiX is connected. If there is not, it will move to the next
 *  port.
 *  
 ************************************/  
public void autoSearch(int theValue) 
{
  //check that we're in run mode  
  if(running ==1)
  {
    //for (int i=0;i<Serial.list().length;i++) //scan from bottom to top
    //scan from the top of the list to the bottom, for most users the ArbotiX will be the most recently added ftdi device
    for (int i=Serial.list().length;i>=0;i--) 
    {
      //try to connect to the current serial port
      try
      {
        sPort = new Serial(this, Serial.list()[i], 115200);
      }
      catch(Exception e)
      {
        if(debug ==1){println("Error Opening Serial Port for Auto Search");}
        //errorGroup.setVisible(true);
        sPort = null;
      }
      delayMs(100);//delay for some systems
        
      if(sPort !=null)
      {
         /* if(pingArbotix() == 1)
          {
            scanGroup.setVisible(true);
            errorGroup.setVisible(false);
            startupGroup.setVisible(false);
            serialList.setValue(i);
            
            //lock connect button and change apperance, unlock disconnect button and change apperance
            connectButton.lock();
            connectButton.setColorBackground(color(200));
            autoSearchButton.lock();
            autoSearchButton.setColorBackground(color(200));
            disconnectButton.unlock();
            disconnectButton.setColorBackground(color(2,52,77));
      
            break;
          }
          else
          {
            if(debug ==1){println("No Arbotix Found On Port" + Serial.list()[i]);}
            sPort.stop();
            sPort = null;
    
          }*/
      }
    }
    
    if(sPort == null)
    {
      //if(debug ==1){println("AutoSearch Could not detect an ArbotiX ");}
      //errorGroup.setVisible(true);
      //errorText.setVisible(true);
      //errorText.setText("No ArbotiX detected on any port. Check that the ArbotiX is powered on and connected through a serial port.");    
    }
  }
}//end autoSearch




void customize(DropdownList ddl) 
{
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  
  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 2;
  ddl.valueLabel().style().marginTop = 3;


  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}
/*****************************************************END P5 CONTROLLER FUNCTIONS****************************/

/************************************
 * draw
 *
 * the draw()loop runs continously. Most of this program's 
 * functionality is taken care of by P5 control events, but
 * the draw loop will check on the heatbeat signals -
 * persistend connections to the arbotix and connected servos
 *  
 ************************************/  
void draw() 
{
  int curServoId = 0;//id of the current servo
  running = 1;//set to run mode, so that P5 control functions can begein working
  background(128);    //set the background color
  /*
  int xValInt = (int)xField.value() + 512;//the x value can be from -512 to 511, add 512 to offset it to 0 to 1023 for
  int yValInt = (int)yField.value();
  int zValInt = (int)zField.value();
  int wristRotValInt= (int)wristRotField.value();
  int wristAngleValInt = (int)wristAngleField.value();
  int gripperValIn = (int)gripperField.value();
  //int extValIn = (int)extField.value();
  int detlaValInt = (int)detlaField.value();
  */
  //retreiving the field value from each field, casting it to an int, then converting it into 2 bytes
  byte[] xValBytes = {0,0};
  byte[] yValBytes = {0,0};
  byte[] zValBytes = {0,0};
  byte[] wristRotValBytes = {0,0};
  byte[] wristAngleValBytes = {0,0};
  byte[] gripperValBytes = {0,0};
  
  
  //byte[] extValBytes = {0,0};
  
  

  byte[] deltaValBytes = intToBytes( (int)detlaField.value());
  byte buttonByte = 0;
  byte extValByte = 0;
  //xValInt = xValInt + 512; 

  
  if(xField.isActive())
  {
     xSlider.setValue(int(xField.getText()));
  }
  else
  {
    xField.setValue(""+(int(xSlider.value())));//cast to int then to string what maddness is this
  }
    
  if(yField.isActive())
  {
     ySlider.setValue(int(yField.getText()));
  }
  else
  {
    yField.setValue(""+(int(ySlider.value())));//cast to int then to string what maddness is this
  }
    
  if(zField.isActive())
  {
     zSlider.setValue(int(zField.getText()));
  }
  else
  {
    zField.setValue(""+(int(zSlider.value())));//cast to int then to string what maddness is this
  }
    
  if(wristAngleField.isActive())
  {
     wristAngleSlider.setValue(int(wristAngleField.getText()));
  }
  else
  {
    wristAngleField.setValue(""+(int(wristAngleSlider.value())));//cast to int then to string what maddness is this
  }
    
  if(wristRotField.isActive())
  {
     wristRotSlider.setValue(int(wristRotField.getText()));
  }
  else
  {
    wristRotField.setValue(""+(int(wristRotSlider.value())));//cast to int then to string what maddness is this
  }
    
  if(gripperField.isActive())
  {
     gripperSlider.setValue(int(gripperField.getText()));
  }
  else
  {
    gripperField.setValue(""+(int(gripperSlider.value())));//cast to int then to string what maddness is this
  }
  
  
  if(updateFlag ==1)
  {
    xValBytes = intToBytes((int)xField.value() + 512);//the x value can be from -512 to 511, add 512 to offset it to 0 to 1023 for
    yValBytes = intToBytes((int)yField.value());
    zValBytes = intToBytes((int)zField.value());
    wristRotValBytes = intToBytes((int)wristRotField.value());
    wristAngleValBytes = intToBytes((int)wristAngleField.value());
    gripperValBytes = intToBytes((int)gripperField.value()); 
    updateFlag =0 ; 
  }
  
  

  currentMillis = millis();
  
  
  
  
  if(currentMillis - prevMillis > 33)
  {
    prevMillis = currentMillis;
      //if the serial port is connected, then send 
    if(sPort != null)
    {
      sPort.write(0xff);          //header
 
      sPort.write(xValBytes[1]); //X Coord High Byte
      sPort.write(xValBytes[0]); //X Coord Low Byte

      sPort.write(yValBytes[1]); //Y Coord High Byte
      sPort.write(yValBytes[0]); //Y Coord Low Byte

      sPort.write(zValBytes[1]); //Z Coord High Byte
      sPort.write(zValBytes[0]); //Z Coord Low Byte
      
      sPort.write(wristAngleValBytes[1]); //Write Angle High Byte
      sPort.write(wristAngleValBytes[0]); //Writs Angle Low Byte
      
      sPort.write(wristRotValBytes[1]); //Write Rotate High Byte
      sPort.write(wristRotValBytes[0]); //Wrist Rotate Low Byte
      
      sPort.write(gripperValBytes[1]); //Gripper High Byte
      sPort.write(gripperValBytes[0]); //Gripper Low Byte
      
      sPort.write(buttonByte); //Button byte
      
      sPort.write(extValByte); //Extended instruction

      
      sPort.write((char)(255 - (xValBytes[1]+xValBytes[0]+yValBytes[1]+yValBytes[0]+zValBytes[1]+zValBytes[0]+wristAngleValBytes[1]+wristAngleValBytes[0]+wristRotValBytes[1]+wristRotValBytes[0]+gripperValBytes[1]+gripperValBytes[0]+buttonByte+extValByte)%256));  //checksum
      
    }
  }
  
  
  //image(, 0, 400, 220,43);//place the TR logo
   
  //check for hearbeat signal every 100ms. If it's been more than 100ms and the serial port is active, proceed
  /*if((millis()- time > 100) && sPort != null)
  {
    if(servoScanned != 0)//if a servoscanne is nonzero, then a servo has been connected. 
    {
      try
      {
        curServoId = Integer.parseInt(curIdField.getText());
      }
      catch(Exception e)
      {
        if(debug ==1){println("Error converting string to int");}
      }
     
      servoHeartbeat(curServoId);   //run a heartbea check to see id the servo is still connected        
    }
   //arbotixHeartbeat();  //run a heartbeat check to see if the arbotix is still connected
   time = millis(); //update the time
  }
  
  //if an outside event or servoHeartbeat has set servoscanned to zero, remove the applicable GUI groups
  if(servoScanned ==0)
  {
     testGroup.setVisible(false);
     setGroup.setVisible(false);
  }
  //otherwise make sure the groups are visible
  else
  {
     testGroup.setVisible(true);
     setGroup.setVisible(true);

  }

*/



  // scroll the scroll List according to the mouseX position
  // when holding down SPACE.
  if (keyPressed && key==' ') {
    //l.scroll(mouseX/((float)width)); // scroll taks values between 0 and 1
  }
  if (keyPressed && key==' ') {
    //l.setWidth(mouseX);
  }
}//end draw()

/************************************
 * stop
 * called when ending the program,
 * make sure to close the serial port
 ***********************************/
void stop()
{
 sPort.stop(); 
}




void keyPressed() 
{
}



/************************************
 * mouseClicked
 *
 * open the Trossen Robotics website if the logo is pressed
 ************************************/  
void mouseClicked()
{
  if((mouseX >= 0) && (mouseX <= 220) && (mouseY >= 400) && (mouseY <= 443) == true)
  {
    link("http://www.trossenrobotics.com/");
  }
  
}

/*
  cp5.addButton("scanDynaButton")
   .setValue(1)
   .setPosition(10,10)
   .setSize(70,70)
   .setCaptionLabel("  Scan")  
   .moveTo(scanGroup)   
   ;*/

/************************************
 * mousePressed
 *
 * A bit of a hack here - if you call an update to a controllerp5 object,
 * like a Textfield from a function called by another control object,
 * like a button, the Textfield will not update until the end of the 
 * button's function. 
 * By calling this on a mouse press, we can change the message to 
 * 'Scanning' 
 *
 *We will also use this function to see if the knob are has been clicked
 *
 **************************************/  
void mousePressed()
{


}



void mouseReleased()
{
  //knobClickState = 0; //if the mouse is released, we've stopped clicking the kbnob
}

/************************************
 * knobCanvas
 *
 * A canvas item that holds the knob element
 *
 **************************************/  

  











    


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


 void delayMs(int ms){
  int time = millis();
  while(millis()-time < ms);
}





/*
void arbotixHeartbeat()
{
  
  if(pingArbotix() == 1)
  {
   scanGroup.setVisible(true);
    setGroup.setVisible(true);
    testGroup.setVisible(true);
    startupGroup.setVisible(false);  
    //connected = 1;
  }
  else
  {
    scanGroup.setVisible(false);
    setGroup.setVisible(false);
    testGroup.setVisible(false);
    startupGroup.setVisible(true);
    //connected = 0;
  }
  
}
*/





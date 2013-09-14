/***********************************************************************************
 *  }--\     InterbotiX     /--{
 *      |    ArmControl    |
 *   __/                    \__
 *  |__|                    |__|
 *
 *  gui.pde
 *  
 *  This file has all of the variables and functions regarding the gui.
 *  See 'ArmControl.pde' for building this application.
 *
 *
 * The following variables are named for Cartesian mode -
 * however the data that will be held/sent will vary based on the current IK mode
 ****************************************************************************
 * Variable name | Cartesian Mode | Cylindrcal Mode | Backhoe Mode          |
 *_______________|________________|_________________|_______________________|
 *   x           |   x            |   base          |   base joint          |
 *   y           |   y            |   y             |   shoulder joint      |
 *   z           |   z            |   z             |   elbow joint         |
 *   wristAngle  |  wristAngle    |  wristAngle     |   wrist angle joint   |
 *   wristRotate |  wristeRotate  |  wristeRotate   |   wrist rotate jount  |
 *   gripper     |  gripper       |  gripper        |   gripper joint       |
 *   delta       |  delta         |  delta          |   n/a                 |
********************************************************************************/


GButton helpButton; 

//setup panel
GPanel setupPanel; //panel to hold setup data
GDropList serialList; //drop down to hold list of serial ports
GButton connectButton,disconnectButton,autoConnectButton; //buttons for connecting/disconnecting and auto seeach

//mode panel
GPanel modePanel; //panel to hold current mode buttons

GButton cartesianModeButton, cylindricalModeButton, backhoeModeButton; //buttons to chage IK mode
GImageButton armStraightButton,arm90Button;//image buttons to hold wrist angle orientation mode

//control panel
GPanel controlPanel; 
//text fields for positional data/delta/extended
GTextField xTextField, yTextField, zTextField, wristAngleTextField, wristRotateTextField, gripperTextField, deltaTextField, extendedTextField;
//sliders for positional data/delta
GSlider xSlider, ySlider, zSlider, wristAngleSlider, wristRotateSlider, gripperSlider, deltaSlider; 
//text labels for positional data/delta/extended
GLabel xLabel, yLabel, zLabel, wristAngleLabel, wristRotateLabel, gripperLabel, deltaLabel, extendedLabel,digitalsLabel;
//checkboxes for digital output values
GCheckbox digitalCheckbox0, digitalCheckbox1, digitalCheckbox2, digitalCheckbox3, digitalCheckbox4, digitalCheckbox5, digitalCheckbox6, digitalCheckbox7; 
GCheckbox autoUpdateCheckbox;   //checkbox to enable auto-update mode
GButton updateButton;           //button to manually update
GImageButton waitingButton;    //waiting button, unused
GKnob baseKnob, shoulderKnob,elbowKnob ,wristAngleKnob ,wristRotateKnob; //knob to turn the base
GCustomSlider gripperLeftSlider, gripperRightSlider;

//error panel
GPanel errorPanel;//panel to warn users of errros
GButton errorOkButton;   //button to dismiss error panel
GButton errorLinkButton; //help link button
GLabel errorLabel;       //error text

//settings panel
GPanel settingsPanel;//various settings for the program
GButton settingsDismissButton;//dismiss the settings panel
GCheckbox fileDebugCheckbox; //checkbox to enable debugging to file
GCheckbox debugFileCheckbox0; //???

//**********************Setup GUI functions

public void setupPanel_click(GPanel source, GEvent event) { 
  printlnDebug("setupPanel - GPanel event occured " + System.currentTimeMillis()%10000000, 1 );
} 

//Called when a new serial port is selected
public void serialList_click(GDropList source, GEvent event) 
{
  printlnDebug("serialList - GDropList event occured: item #" + serialList.getSelectedIndex() + " " + System.currentTimeMillis()%10000000, 1 );
  
  
  selectedSerialPort = serialList.getSelectedIndex()-1; //set the current selectSerialPort corresponding to the serial port selected in the menu. Subtract 1 to offset for the fact that the first item in the list is a placeholder text/title 'Select Serial Port'
  printlnDebug("Serial port at position " +selectedSerialPort+ " chosen");
} 

//called when the connect button is pressed
public void connectButton_click(GButton source, GEvent event) 
{
  printlnDebug("connectButton - GButton event occured " + System.currentTimeMillis()%10000000, 1);
  
  //check to make sure serialPortSelected is not -1, -1 means no serial port was selected. Valid port indexes are 0+
  if (selectedSerialPort > -1)
  {    
  
    //try to connect to the port at 38400bps, otherwise show an error message
    try
    {
      sPort = new Serial(this, Serial.list()[selectedSerialPort], 38400);
    }
    catch(Exception e)
    {
      printlnDebug("Error Opening Serial Port"+serialList.getSelectedText());
      sPort = null;
    
      displayError("Unable to open selected serial port" + serialList.getSelectedText() +". See link for possible solutions.", "http://learn.trossenrobotics.com/arbotix/8-advanced-used-of-the-tr-dynamixel-servo-tool");
    }
  }
    
  //check to see if the serial port connection has been made
  if (sPort != null)
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
    }
    
    //if arm is not found return an error
    else  
    {
      sPort.stop();
      sPort = null;
      printlnDebug("No Arm Found on port "+serialList.getSelectedText()) ;
    
      displayError("No Arm found on serial port" + serialList.getSelectedText() +". Make sure power is on and the arm is connected to the computer.", "http://learn.trossenrobotics.com/arbotix/8-advanced-used-of-the-tr-dynamixel-servo-tool");
    }
  }
} 

//disconnect from current serial port and set GUI element states appropriatley
public void disconnectButton_click(GButton source, GEvent event) 
{
  printlnDebug("disconnectButton - GButton event occured " + System.currentTimeMillis()%10000000, 1);
  
  
  putArmToSleep();
  //TODO: call response & check
  
  ///stop/disconnect the serial port and set sPort to null for future checks
  sPort.stop();   
  sPort = null;
  
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
  modePanel.setVisible(false);
  modePanel.setEnabled(false);
  
  //uncheck all checkboxes to reset
  autoUpdateCheckbox.setSelected(false);
  digitalCheckbox0.setSelected(false);
  digitalCheckbox1.setSelected(false);
  digitalCheckbox2.setSelected(false);
  digitalCheckbox3.setSelected(false);
  digitalCheckbox4.setSelected(false);
  digitalCheckbox5.setSelected(false);
  digitalCheckbox6.setSelected(false);
  digitalCheckbox7.setSelected(false);
  
  //set arm/mode/orientation to default
  currentMode = 0;
  currentArm = 0;
  currentOrientation = 0;
  
  //reset button color mode
  cartesianModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  cylindricalModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  backhoeModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  
  //reset alpha trapsnparency on orientation buttons
  armStraightButton.setAlpha(128);
  arm90Button.setAlpha(128);
} 



//scan each serial port and querythe port for an active arm. Iterate through each port until a 
//port is found or the list is exhausted
public void autoConnectButton_click(GButton source, GEvent event) 
{
  printlnDebug("autoConnectButton - GButton event occured " + System.currentTimeMillis()%10000000, 1 );


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
  for (int i=Serial.list().length-1;i>=0;i--) 
  {
    serialList.setSelected(i+1);
    selectedSerialPort = i;
    //try to connect to the current serial port
    try
    {
      sPort = new Serial(this, Serial.list()[i], 38400);
    }
    catch(Exception e)
    {
      printlnDebug("Error Opening Serial Port for Auto Search");
      sPort = null;
      //no GUI error
    }

    //delayMs(100);//delay for some systems


    //check to see if the serial port connection has been made       
    if (sPort !=null)
    {


      //try to communicate with arm
      if (checkArmStartup() == true)
      {
        printlnDebug("Arm Found from auto search on port "+Serial.list()[i]) ;

        //enable & set visible control and mode panel, enable disconnect button
        modePanel.setVisible(true);
        modePanel.setEnabled(true);
        controlPanel.setVisible(true);
        controlPanel.setEnabled(true);
        disconnectButton.setEnabled(true);
        break;
      }

      //if arm is not found return an error
      else  
      {
        printlnDebug("No Arm Found from auto search on port "+serialList.getSelectedText()) ;

        sPort.stop();
        sPort = null;
      }
    }
  }//end interating through serial list

  //id sPort is null, not port was found. Set GUI elements appropriatley.
  if (sPort == null)
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
  }
}



//**********************Mode GUI functions

public void modePanel_click(GPanel source, GEvent event) 
{ 
  printlnDebug("modePanel - GPanel event occured " + System.currentTimeMillis()%10000000 );
} 

//change mode data when button to straigten gripper angle is pressed
public void armStraightButton_click(GImageButton source, GEvent event) 
{ 
  printlnDebug("armstraught - GCheckbox event occured " + System.currentTimeMillis()%10000000, 1 );
  
  
  if (currentMode == 0)
  {
  currentMode =1;
  cartesianModeButton.setLocalColorScheme(GCScheme.GOLD_SCHEME);
  }
  
  armStraightButton.setAlpha(255);
  arm90Button.setAlpha(128);
  
  currentOrientation = 1;
  setPositionParameters();
  changeArmMode();
} 


//change mode data when button to move  gripper angle to 90 degrees is pressed
public void arm90Button_click(GImageButton source, GEvent event) 
{
  printlnDebug("arm90 - GCheckbox event occured " + System.currentTimeMillis()%10000000, 1 );
  
  if (currentMode == 0)
  {
  currentMode =1;
  cartesianModeButton.setLocalColorScheme(GCScheme.GOLD_SCHEME);
  }
  
  armStraightButton.setAlpha(128);
  arm90Button.setAlpha(255);
  
  currentOrientation = 2;
  setPositionParameters();
  changeArmMode();
} 


//change ik mode to cartesian
public void cartesianModeButton_click(GButton source, GEvent event) 
{ 
  printlnDebug("cartesianModeButton - GButton event occured " + System.currentTimeMillis()%10000000, 1 );
  
  //set ik mode buttons to correct colors
  source.setLocalColorScheme(GCScheme.GOLD_SCHEME);
  cylindricalModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  backhoeModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  
  //set wrist angle orientation if not defined
  if (currentOrientation == 0)
  {
    currentOrientation =1;
  }
  
  if (currentOrientation == 1)
  {
    armStraightButton.setAlpha(255);
    arm90Button.setAlpha(128);
  }
  else  
  {
    armStraightButton.setAlpha(128);
    arm90Button.setAlpha(255);
  }

  currentMode = 1;//set mode data
  setPositionParameters();//set parameters in gui and working vars
  changeArmMode();//change arm mode
} 


//change ik mode to cylindrical
public void cylindricalModeButton_click(GButton source, GEvent event) 
{ 
  printlnDebug("cylindricalModeButton - GButton event occured " + System.currentTimeMillis()%10000000, 1 );
  
  //set ik mode buttons to correct colors
  source.setLocalColorScheme(GCScheme.GOLD_SCHEME);
  cartesianModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  backhoeModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  
  
  //set wrist angle orientation if not defined
  if (currentOrientation == 0)
  {
    currentOrientation =1;
  }
  
  if (currentOrientation == 1)
  {
    armStraightButton.setAlpha(255);
    arm90Button.setAlpha(128);
  }
  else  
  {
    armStraightButton.setAlpha(128);
    arm90Button.setAlpha(255);
  }
  
  currentMode = 2;//set mode data
  setPositionParameters();//set parameters in gui and working vars
  changeArmMode();//change arm mode
} 

//change ik mode to backhoe
public void backhoeModeButton_click(GButton source, GEvent event) 
{ 
  printlnDebug("backhoeModeButton - GButton event occured " + System.currentTimeMillis()%10000000, 1 );

  //set ik mode buttons to correct colors
  source.setLocalColorScheme(GCScheme.GOLD_SCHEME);
  cylindricalModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  cartesianModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  
  //set wrist angle alphas to 128(gey out)
  armStraightButton.setAlpha(128);
  arm90Button.setAlpha(128);
  
  currentMode = 3;//set mode data
  
  setPositionParameters();//set parameters in gui and working vars
  changeArmMode();//change arm mode
}
//process when manual update button is pressed
public void updateButton_click(GButton source, GEvent event) 
{
  printlnDebug("backhoeModeButton - GButton event occured " + System.currentTimeMillis()%10000000, 1 );
  
  updateFlag = true;//set update flag to signal sending an update on the next cycle
  updateOffsetCoordinates();//update the coordinates to offset based on the current mode

  printlnDebug("X:"+xCurrentOffset+" Y:"+yCurrentOffset+" Z:"+zCurrentOffset+" Wrist Angle:"+wristAngleCurrentOffset+" Wrist Rotate:"+wristRotateCurrentOffset+" Gripper:"+gripperCurrentOffset+" Delta:"+deltaCurrentOffset);
}



//**********************Control GUI functions
public void controlPanel_click(GPanel source, GEvent event) { //_CODE_:controlPanel:613752:
  printlnDebug("controlPanel - GPanel event occured " + System.currentTimeMillis()%10000000, 1 );
} //_CODE_:controlPanel:613752:



//generic function that  will handle text field changes. This function will
//-check the text field for non numeric characters
//-check for values out of the current range
//-write the value to the slider upon an 'enter' or when the fiels loses focus
//-
public int armTextFieldChange(GTextField source, GEvent event, GSlider targetSlider, int minVal, int maxVal, int currentVal )
{
  String textFieldString = source.getText();//string value from textField
  int textFieldValue;//converted integer from textField

  //parse through each character in the string to make sure that it is a digit
  for (int i = 0; i < textFieldString.length(); i++)
  {
    //get single character and check if it is not a digit
    //in non digit character is found, return text field to previous value
    //otherwise continue
    printDebug(textFieldString.charAt(i) + " ", 1 );
    if (!Character.isDigit(textFieldString.charAt(i)))
    {
      //'-' character is used for negative numbers, so check that the current character is not '-'
      //otherwise continue 
      if (textFieldString.charAt(i) != '-')
      {
        printlnDebug("Non Numeric Character in Textfield, reverting value", 1 );
        source.setText(Integer.toString(currentVal));//set string to global xCurrent Value, last known good value  
        return(currentVal); 
        //TODO: alternativeley the program could remove the offending character and write the string back
      }
    }
  }
  printlnDebug("", 1 );

  //only write value to slider/global if the enter key is pressed or focus is lost on the text field
  if (event == GEvent.ENTERED | event == GEvent.LOST_FOCUS)
  {
    textFieldValue = int(textFieldString);//take String from text field and conver it to an int

    //check if the value is over the global max for this field - if so, set the textField value to the maximum value
    if (textFieldValue > maxVal)
    {
      source.setText(Integer.toString(maxVal));//append a "" for easy string conversion 
      textFieldValue = maxVal;
    }

    //check if the value is under the global min for this field - if so, set the textField value to the minimum value
    if (textFieldValue < minVal)
    {
      source.setText(Integer.toString(minVal));//append a "" for easy string conversion      
      textFieldValue = minVal;
    }

    targetSlider.setValue(textFieldValue);
    return(textFieldValue);
  }

  return(currentVal);
}

public void xTextField_change(GTextField source, GEvent event) 
{
  printlnDebug("xTextField_change - GTextField event occured " + System.currentTimeMillis()%10000000, 1 );
  xCurrent = armTextFieldChange(source, event, xSlider, xParameters[1], xParameters[2], xCurrent);
}

public void yTextField_change(GTextField source, GEvent event) 
{
  printlnDebug("yTextField_change - GTextField event occured " + System.currentTimeMillis()%10000000, 1 );
  yCurrent = armTextFieldChange(source, event, ySlider, yParameters[1], yParameters[2], yCurrent);
}

public void zTextField_change(GTextField source, GEvent event) 
{
  printlnDebug("zTextField_change - GTextField event occured " + System.currentTimeMillis()%10000000, 1 );
  zCurrent = armTextFieldChange(source, event, zSlider, zParameters[1], zParameters[2], zCurrent);
}

public void wristAngleTextField_change(GTextField source, GEvent event) 
{
  printlnDebug("wristAngleTextField_change - GTextField event occured " + System.currentTimeMillis()%10000000, 1 );
  wristAngleCurrent = armTextFieldChange(source, event, wristAngleSlider, wristAngleParameters[1], wristAngleParameters[2], wristAngleCurrent);
}

public void wristRotateTextField_change(GTextField source, GEvent event) 
{
  printlnDebug("wristRotateTextField_change - GTextField event occured " + System.currentTimeMillis()%10000000, 1 );
  wristRotateCurrent = armTextFieldChange(source, event, wristRotateSlider, wristRotateParameters[1], wristRotateParameters[2], wristRotateCurrent);
}

public void gripperTextField_change(GTextField source, GEvent event) 
{
  printlnDebug("gripperTextField_change - GTextField event occured " + System.currentTimeMillis()%10000000, 1 );
  gripperCurrent = armTextFieldChange(source, event, gripperSlider, gripperParameters[1], gripperParameters[2], gripperCurrent);
}


public void deltaTextField_change(GTextField source, GEvent event) 
{
  printlnDebug("gripperTextField_change - GTextField event occured " + System.currentTimeMillis()%10000000, 1 );
  gripperCurrent = armTextFieldChange(source, event, deltaSlider, deltaParameters[1], deltaParameters[2], deltaCurrent);
}



//special case for extended mode text field
public void extendedTextField_change(GTextField source, GEvent event) 
{
  printlnDebug("extendedTextField_change - GDropList event occured " + System.currentTimeMillis()%10000000, 1 );
  String textFieldString = source.getText();//string value from textField
  int textFieldValue = 0;//converted integer from textField

  //parse through each character in the string to make sure that it is a digit
  for (int i = 0; i < textFieldString.length(); i++)
  {
    //get single character and check if it is not a digit
    //in non digit character is found, return text field to previous value
    //otherwise continue
    //printlnDebug(textFieldString.charAt(i));
    if (!Character.isDigit(textFieldString.charAt(i)))
    {
      //'-' character is used for negative numbers, so check that the current character is not '-'
      //otherwise continue 
      if (textFieldString.charAt(i) != '-')
      {
        source.setText(Integer.toString(extendedByte));//set string to global xCurrent Value, last known good value  
        //TODO: alternativeley the program could remove the offending character and write the string back
      }
    }
  }

  //only write value to global if enter key is pressed or lose focus on fieles
  if (event == GEvent.ENTERED | event == GEvent.LOST_FOCUS)
  {
    printlnDebug("Change Extended Byte");
    extendedByte = int(textFieldString);//take String from text field and conver it to an int

    //check if the value is over the global max for this field - if so, set the textField value to the maximum value
    if (extendedByte > 255)
    {
      source.setText(Integer.toString(255));//append a "" for easy string conversion 
      extendedByte = 255;
    }

    //check if the value is under the global min for this field - if so, set the textField value to the minimum value
    if (extendedByte < 0)
    {
      source.setText(Integer.toString(0));//append a "" for easy string conversion      
      extendedByte = 0;
    }
  }
}

public void baseKnob_change(GKnob source, GEvent event) 
{
  printlnDebug("baseKnob_change - GSlider event occured " + System.currentTimeMillis()%10000000, 1 );
  if (event == GEvent.VALUE_STEADY)
  {
    xTextField.setText(Integer.toString(source.getValueI()));//append a "" for easy string conversion
    xCurrent = source.getValueI();
  }
}

public void shoulderKnob_change(GKnob source, GEvent event) 
{
  printlnDebug("shoulderKnob_change - GSlider event occured " + System.currentTimeMillis()%10000000, 1 );
  if (event == GEvent.VALUE_STEADY)
  {
    yTextField.setText(Integer.toString(source.getValueI()));//append a "" for easy string conversion
    yCurrent = source.getValueI();
  }
}

public void elbowKnob_change(GKnob source, GEvent event) 
{
  printlnDebug("elbowKnob_change - GSlider event occured " + System.currentTimeMillis()%10000000, 1 );
  if (event == GEvent.VALUE_STEADY)
  {
    zTextField.setText(Integer.toString(source.getValueI()));//append a "" for easy string conversion
    zCurrent = source.getValueI();
  }
}

public void wristAngleKnob_change(GKnob source, GEvent event) 
{
  printlnDebug("xSlider_change - GSlider event occured " + System.currentTimeMillis()%10000000, 1 );
  if (event == GEvent.VALUE_STEADY)
  {
    wristAngleTextField.setText(Integer.toString(source.getValueI()));//append a "" for easy string conversion 
    wristAngleCurrent = source.getValueI();
  }
}

public void wristRotateKnob_change(GKnob source, GEvent event) 
{
  printlnDebug("xSlider_change - GSlider event occured " + System.currentTimeMillis()%10000000, 1 );
  if (event == GEvent.VALUE_STEADY)
  {
    wristRotateTextField.setText(Integer.toString(source.getValueI()));//append a "" for easy string conversion 
    wristRotateCurrent = source.getValueI();
  }
}







//update text field and working var based on slider change 
public void xSlider_change(GSlider source, GEvent event) 
{
  printlnDebug("xSlider_change - GSlider event occured " + System.currentTimeMillis()%10000000, 1 );
  if (event == GEvent.VALUE_STEADY)
  {
    xTextField.setText(Integer.toString(source.getValueI()));//append a "" for easy string conversion
    xCurrent = source.getValueI();
  }
}

//update text field and working var based on slider change 
public void ySlider_change(GSlider source, GEvent event) 
{
  printlnDebug("ySlider_change - GSlider event occured " + System.currentTimeMillis()%10000000, 1 );
  if (event == GEvent.VALUE_STEADY)
  {
    yTextField.setText(Integer.toString(source.getValueI()));//append a "" for easy string conversion 
    yCurrent = source.getValueI();
  }
}

//update text field and working var based on slider change 
public void zSlider_change(GSlider source, GEvent event) 
{
  printlnDebug("zSlider_change - GSlider event occured " + System.currentTimeMillis()%10000000, 1 );
  if (event == GEvent.VALUE_STEADY)
  {
    zTextField.setText(Integer.toString(source.getValueI()));//append a "" for easy string conversion 
    zCurrent = source.getValueI();
  }
}

//update text field and working var based on slider change 
public void wristAngleSlider_change(GSlider source, GEvent event) 
{
  printlnDebug("wristAngleSlider_change - GSlider event occured " + System.currentTimeMillis()%10000000, 1 );
  if (event == GEvent.VALUE_STEADY)
  {
    wristAngleTextField.setText(Integer.toString(source.getValueI()));//append a "" for easy string conversion 
    wristAngleCurrent = source.getValueI();
  }
}

//update text field and working var based on slider change 
public void wristRotateSlider_change(GSlider source, GEvent event) 
{
  printlnDebug("wristRotateSlider_change - GSlider event occured " + System.currentTimeMillis()%10000000, 1 );
  if (event == GEvent.VALUE_STEADY)
  {
    wristRotateTextField.setText(Integer.toString(source.getValueI()));//append a "" for easy string conversion 
    wristRotateCurrent = source.getValueI();
  }
}

//update text field and working var based on slider change 
public void gripperSlider_change(GSlider source, GEvent event) 
{
  printlnDebug("gripperSlider_change - GSlider event occured " + System.currentTimeMillis()%10000000, 1 );
  if (event == GEvent.VALUE_STEADY)
  {
    gripperTextField.setText(Integer.toString(source.getValueI()));//append a "" for easy string conversion 
    gripperCurrent = source.getValueI();
  }
}




//update text field and working var based on slider change 
public void gripperLeftSlider_change(GCustomSlider source, GEvent event) 
{
  printlnDebug("gripperSlider_change - GSlider event occured " + System.currentTimeMillis()%10000000, 1 );
  if (event == GEvent.VALUE_STEADY)
  {
    gripperTextField.setText(Integer.toString(source.getValueI()));//append a "" for easy string conversion 
    gripperCurrent = source.getValueI();
    gripperRightSlider.setValue(source.getValueI());
  }
}

//update text field and working var based on slider change 
public void gripperRightSlider_change(GCustomSlider source, GEvent event) 
{
  printlnDebug("gripperSlider_change - GSlider event occured " + System.currentTimeMillis()%10000000, 1 );
  if (event == GEvent.VALUE_STEADY)
  {
    gripperTextField.setText(Integer.toString(source.getValueI()));//append a "" for easy string conversion 
    gripperCurrent = source.getValueI();
    gripperLeftSlider.setValue(source.getValueI());
  }
}




//update text field and working var based on slider change 
//update text field and working var based on slider change 
public void deltaSlider_change(GSlider source, GEvent event) 
{
  printlnDebug("deltaSliderChange - GSlider event occured " + System.currentTimeMillis()%10000000, 1 );
  if (event == GEvent.VALUE_STEADY)
  {
    deltaTextField.setText(Integer.toString(source.getValueI())); 
    deltaCurrent = source.getValueI();
  }
}

//change to auto-update mode when box is checked
public void autoUpdateCheckbox_change(GCheckbox source, GEvent event)
{ 

  printlnDebug("autoUpdateCheckbox_change - GCheckbox event occured " + System.currentTimeMillis()%10000000, 1 );

  updateFlag = source.isSelected();//set the updateFlag to the current state of the autoUpdate checkbox
} 


//digital output 0 checkbox
public void digitalCheckbox0_change(GCheckbox source, GEvent event) 
{
  printlnDebug("digitalCheckbox0 - GCheckbox event occured " + System.currentTimeMillis()%10000000, 1 );

  digitalButtons[0] = source.isSelected();//set the current array item for the corresponding digital output to the current state of the checkbox
} 


public void digitalCheckbox1_change(GCheckbox source, GEvent event) 
{ 
  printlnDebug("digitalCheckbox1 - GCheckbox event occured " + System.currentTimeMillis()%10000000, 1 );
  digitalButtons[1] = source.isSelected();//set the current array item for the corresponding digital output to the current state of the checkbox
} 
public void digitalCheckbox2_change(GCheckbox source, GEvent event) 
{
  printlnDebug("digitalCheckbox2 - GCheckbox event occured " + System.currentTimeMillis()%10000000, 1 );
  digitalButtons[2] = source.isSelected();//set the current array item for the corresponding digital output to the current state of the checkbox
} 


public void digitalCheckbox3_change(GCheckbox source, GEvent event) 
{ 
  printlnDebug("digitalCheckbox3 - GCheckbox event occured " + System.currentTimeMillis()%10000000, 1 );
  digitalButtons[3] = source.isSelected();//set the current array item for the corresponding digital output to the current state of the checkbox
}


public void digitalCheckbox4_change(GCheckbox source, GEvent event) 
{ 
  printlnDebug("digitalCheckbox4 - GCheckbox event occured " + System.currentTimeMillis()%10000000, 1 );
  digitalButtons[4] = source.isSelected();//set the current array item for the corresponding digital output to the current state of the checkbox
} 


public void digitalCheckbox5_change(GCheckbox source, GEvent event) 
{ 
  printlnDebug("digitalCheckbox5 - GCheckbox event occured " + System.currentTimeMillis()%10000000, 1 );
  digitalButtons[5] = source.isSelected();//set the current array item for the corresponding digital output to the current state of the checkbox
} 


public void digitalCheckbox6_change(GCheckbox source, GEvent event) 
{
  printlnDebug("digitalCheckbox6 - GCheckbox event occured " + System.currentTimeMillis()%10000000, 1 );
  digitalButtons[6] = source.isSelected();//set the current array item for the corresponding digital output to the current state of the checkbox
} 


public void digitalCheckbox7_change(GCheckbox source, GEvent event) 
{
  printlnDebug("digitalCheckbox7 - GCheckbox event occured " + System.currentTimeMillis()%10000000, 1 );
  digitalButtons[7] = source.isSelected();//set the current array item for the corresponding digital output to the current state of the checkbox
} 


//**********************Error GUI functions
public void errorPanel_Click(GPanel source, GEvent event) 
{ 
  printlnDebug("errorPanel_Click - GPanel event occured " + System.currentTimeMillis()%10000000, 1 );
} 


//display error and link of supplied strings
void displayError(String message, String link)
{
  //grey out other panels
  setupPanel.setAlpha(128);
  controlPanel.setAlpha(128);
  modePanel.setAlpha(128);
  setupPanel.setEnabled(false);
  controlPanel.setEnabled(false);
  modePanel.setEnabled(false);

  //show error panel
  errorPanel.setVisible(true); 

  //set text
  errorLabel.setText(message);

  //set help link and show it if the string is not empty, otherwise hide the button
  if (helpLink != "")
  {
    helpLink = link;
    errorLinkButton.setVisible(true);
    errorLinkButton.setEnabled(true);
  }
  else
  {
    errorLinkButton.setVisible(false);
    errorLinkButton.setEnabled(false);
  }
}

//hide error panel and other panels to their normal state
void hideError()
{
  //grey out other panels
  setupPanel.setAlpha(255);
  controlPanel.setAlpha(255);
  modePanel.setAlpha(255);
  setupPanel.setEnabled(true);
  controlPanel.setEnabled(true);
  modePanel.setEnabled(true);

  //show error panel
  errorPanel.setVisible(false);
}


//go to help link when button pressed
public void errorLinkButton_click(GButton source, GEvent event) { 

  printlnDebug("errorLinkButton_click - GButton event occured " + System.currentTimeMillis()%10000000, 1 );

  link(helpLink);
}

//dismiss error panel
public void errorOkButton_click(GButton source, GEvent event) { 

  printlnDebug("errorOkButton_click - GButton event occured " + System.currentTimeMillis()%10000000, 1);
  hideError();
}


//**********************Settings GUI functions

public void settingsPanel_Click(GPanel source, GEvent event) { 
  printlnDebug("settingsPanel_Click - GPanel event occured " + System.currentTimeMillis()%10000000, 1 );
} 

//dismiss settings panel
public void settingsDismissButton_click(GButton source, GEvent event) 
{
  printlnDebug("settingsDismissButton_click - GButton event occured " + System.currentTimeMillis()%10000000, 1);
  settingsPanel.setVisible(false);
}

//checkbox to enable debug-to-file
public void fileDebugCheckbox_change(GCheckbox source, GEvent event)
{ 

  printlnDebug("autoUpdateCheckbox_change - GCheckbox event occured " + System.currentTimeMillis()%10000000, 1 );

  debugFile = source.isSelected();//set the updateFlag to the current state of the autoUpdate checkbox
} 







//**********************Other GUI functions


//now used to enable settings panel
public void helpButton_click(GButton source, GEvent event) 
{ 
  settingsPanel.setVisible(true);
  //link("http://learn.trossenrobotics.com/");
}

// Create all the GUI controls. 
public void createGUI() {
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(8);
  G4P.setCursor(ARROW);


  if (frame != null)
    frame.setTitle("InterbotiX Arm Control");


  helpButton = new GButton(this, 10, 775, 40, 20);
  helpButton.setText("More");
  helpButton.setLocalColorScheme(GCScheme.GOLD_SCHEME);
  helpButton.addEventHandler(this, "helpButton_click");




//Setup

  setupPanel = new GPanel(this, 5, 83, 240, 75, "Setup Panel");
  setupPanel.setText("Setup Panel");
  setupPanel.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  setupPanel.setOpaque(true);
  setupPanel.addEventHandler(this, "setupPanel_click");
  //setupPanel.setDraggable(false);
  setupPanel.setCollapsible(false);


  serialList = new GDropList(this, 5, 24, 160, 132, 6);
  //serialList.setItems(loadStrings("list_700876"), 0);
  serialList.addEventHandler(this, "serialList_click");
  serialList.setFont(new Font("Dialog", Font.PLAIN, 9));  
  serialList.setLocalColorScheme(GCScheme.CYAN_SCHEME);

  connectButton = new GButton(this, 5, 47, 75, 20);
  connectButton.setText("Connect");
  connectButton.addEventHandler(this, "connectButton_click");

  disconnectButton = new GButton(this, 90, 47, 75, 20);
  disconnectButton.setText("Disconnect");
  disconnectButton.addEventHandler(this, "disconnectButton_click");

  disconnectButton.setEnabled(false);
  disconnectButton.setAlpha(128);

  autoConnectButton = new GButton(this, 170, 24, 55, 43);
  autoConnectButton.setText("Auto Search");
  autoConnectButton.addEventHandler(this, "autoConnectButton_click");


  setupPanel.addControl(serialList);
  setupPanel.addControl(connectButton);
  setupPanel.addControl(disconnectButton);
  setupPanel.addControl(autoConnectButton);


//mode
  modePanel = new GPanel(this, 300, 50, 240, 110, "Mode Panel");
  modePanel.setText("Mode Panel");
  modePanel.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  modePanel.setOpaque(true);
  modePanel.addEventHandler(this, "modePanel_click");
  //modePanel.setDraggable(false);
  modePanel.setCollapsible(false);

  //modePanel.setVisible(false);
  //modePanel.setEnabled(false);

  
  cartesianModeButton = new GButton(this, 0, 18, 80, 20);
  cartesianModeButton.setText("Cartesian");
  cartesianModeButton.addEventHandler(this, "cartesianModeButton_click");
  cartesianModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);

  cylindricalModeButton = new GButton(this, 80, 18, 80, 20);
  cylindricalModeButton.setText("Cylindrical");
  cylindricalModeButton.addEventHandler(this, "cylindricalModeButton_click");
  cylindricalModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);

  backhoeModeButton = new GButton(this, 160, 18, 80, 20);
  backhoeModeButton.setText("Backkhoe");
  backhoeModeButton.addEventHandler(this, "backhoeModeButton_click");
  backhoeModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);

  armStraightButton = new GImageButton(this, 5, 40, 100, 65, new String[] { 
    "armStraightm.png", "armStraightm.png", "armStraightm.png"
  } 
  );
  armStraightButton.addEventHandler(this, "armStraightButton_click");
  armStraightButton.setAlpha(128);

  arm90Button = new GImageButton(this, 130, 40, 100, 65, new String[] { 
    "arm90m.png", "arm90m.png", "arm90m.png"
  } 
  );
  arm90Button.addEventHandler(this, "arm90Button_click");
  arm90Button.setAlpha(128);


  modePanel.addControl(cartesianModeButton);
  modePanel.addControl(cylindricalModeButton);
  modePanel.addControl(backhoeModeButton);
  modePanel.addControl(arm90Button);
  modePanel.addControl(armStraightButton);



//control
  controlPanel = new GPanel(this, 5, 200, 680, 480, "Control Panel");
  controlPanel.setText("Control Panel");
  controlPanel.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  controlPanel.setOpaque(true);
  controlPanel.addEventHandler(this, "controlPanel_click");
  //controlPanel.setDraggable(false);
  controlPanel.setCollapsible(false);
  
  //controlPanel.setVisible(false);
  //controlPanel.setEnabled(false);



  baseKnob = new GKnob(this, 100, 30, 50, 50, 1); 
  baseKnob.setTurnRange(120.0, 60.0); //set angle limits start/finish
  baseKnob.setLimits(512.0, 0, 1023.0);//set value limits
  baseKnob.setShowArcOnly(true);   //show arc, hide par of circle you cannot interct with
  baseKnob.setStickToTicks(false);   //no need to stick to ticks
  baseKnob.setTurnMode(1281); //???
  baseKnob.addEventHandler(this, "baseKnob_change");//set event listener
  baseKnob.setLocalColorScheme(9);//set color scheme just for knobs, custom color in /data
  //baseKnob.setVisible(false); //???

  shoulderKnob = new GKnob(this, 13, 161, 50, 50, 1); 
  shoulderKnob.setTurnRange(120.0, 60.0); //set angle limits start/finish
  shoulderKnob.setLimits(512.0, 0, 1023.0);//set value limits
  shoulderKnob.setShowArcOnly(true);   //show arc, hide par of circle you cannot interct with
  shoulderKnob.setStickToTicks(false);   //no need to stick to ticks
  shoulderKnob.setTurnMode(1281); //???
  shoulderKnob.addEventHandler(this, "shoulderKnob_change");//set event listener
  shoulderKnob.setLocalColorScheme(9);//set color scheme just for knobs, custom color in /data

  elbowKnob = new GKnob(this, 113, 161, 50, 50, 1); 
  elbowKnob.setTurnRange(120.0, 60.0); //set angle limits start/finish
  elbowKnob.setLimits(512.0, 0, 1023.0);//set value limits
  elbowKnob.setShowArcOnly(true);   //show arc, hide par of circle you cannot interct with
  elbowKnob.setStickToTicks(false);   //no need to stick to ticks
  elbowKnob.setTurnMode(1281); //???
  elbowKnob.addEventHandler(this, "elbowKnob_change");//set event listener
  elbowKnob.setLocalColorScheme(9);//set color scheme just for knobs, custom color in /data

  wristAngleKnob = new GKnob(this, 25, 30, 50, 50, 1); 
  wristAngleKnob.setTurnRange(270.0, 90.0); //set angle limits start/finish
  wristAngleKnob.setLimits(512.0, 0, 1023.0);//set value limits
  wristAngleKnob.setShowArcOnly(true);   //show arc, hide par of circle you cannot interct with
  wristAngleKnob.setStickToTicks(false);   //no need to stick to ticks
  wristAngleKnob.setTurnMode(1281); //???
  wristAngleKnob.addEventHandler(this, "wristAngleKnob_change");//set event listener
  wristAngleKnob.setLocalColorScheme(9);//set color scheme just for knobs, custom color in /data

  wristRotateKnob = new GKnob(this, 350, 30, 50, 50, 1); 
  wristRotateKnob.setTurnRange(120.0, 60.0); //set angle limits start/finish
  wristRotateKnob.setLimits(512.0, 0, 1023.0);//set value limits
  wristRotateKnob.setShowArcOnly(true);   //show arc, hide par of circle you cannot interct with
  wristRotateKnob.setStickToTicks(false);   //no need to stick to ticks
  wristRotateKnob.setTurnMode(1281); //???
  wristRotateKnob.addEventHandler(this, "wristRotateKnob_change");//set event listener
  wristRotateKnob.setLocalColorScheme(10);//set color scheme just for knobs, custom color in /data


  xTextField = new GTextField(this, 5, 40, 60, 20, G4P.SCROLLBARS_NONE);
  //xTextField.setText("0");
  xTextField.setText(Integer.toString(xParameters[0]));
  xTextField.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  xTextField.setOpaque(true);
  xTextField.addEventHandler(this, "xTextField_change");
  
  xLabel = new GLabel(this, 5, 60, 60, 14);
  xLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  xLabel.setText("X Coord");
  xLabel.setOpaque(false);

  xSlider = new GSlider(this, 75, 30, 100, 40, 10.0);
  xSlider.setShowLimits(true);
  xSlider.setLimits(0.0, -200.0, 200.0);
  xSlider.setNbrTicks(50);
  xSlider.setEasing(0.0);
  xSlider.setNumberFormat(G4P.INTEGER, 0);
  xSlider.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  xSlider.setOpaque(false);
  xSlider.addEventHandler(this, "xSlider_change");
  xSlider.setShowValue(true);



  yTextField = new GTextField(this, 5, 80, 65, 20, G4P.SCROLLBARS_NONE);
  yTextField.setText(Integer.toString(yParameters[0]));
  yTextField.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  yTextField.setOpaque(true);
  yTextField.addEventHandler(this, "yTextField_change");

  yLabel = new GLabel(this, 5, 100, 65, 14);
  yLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  yLabel.setText("Y Coord");
  yLabel.setOpaque(false);



  ySlider = new GSlider(this, -35, 155, 145, 65, 10.0);
  ySlider.setShowLimits(true);
  ySlider.setLimits(200.0, 50.0, 240.0);
  ySlider.setEasing(0.0);
  ySlider.setNumberFormat(G4P.INTEGER, 0);
  ySlider.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  ySlider.setOpaque(false);
  ySlider.addEventHandler(this, "ySlider_change");
  ySlider.setShowValue(true);
  ySlider.setTextOrientation(G4P.ORIENT_RIGHT);
  
  
  ySlider.setRotation(3.1415927*1.5, GControlMode.CENTER); 


  zTextField = new GTextField(this, 105, 80, 65, 20, G4P.SCROLLBARS_NONE);
  zTextField.setText(Integer.toString(zParameters[0]));
  zTextField.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  zTextField.setOpaque(true);
  zTextField.addEventHandler(this, "zTextField_change");

  zLabel = new GLabel(this, 105, 100, 65, 14);
  zLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  zLabel.setText("Z Coord");
  zLabel.setOpaque(false);


  zSlider = new GSlider(this, 65, 155, 145, 65, 10.0);
  zSlider.setShowLimits(true);
  zSlider.setLimits(200.0, 20.0, 250.0);
  zSlider.setEasing(0.0);
  zSlider.setNumberFormat(G4P.INTEGER, 0);
  zSlider.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  zSlider.setOpaque(false);
  zSlider.addEventHandler(this, "zSlider_change"); 
  zSlider.setShowValue(true); 
  zSlider.setRotation(3.1415927*1.5, GControlMode.CENTER); 
  zSlider.setTextOrientation(G4P.ORIENT_RIGHT);
  



  wristAngleTextField = new GTextField(this, 185, 40, 60, 20, G4P.SCROLLBARS_NONE);
  wristAngleTextField.setText(Integer.toString(wristAngleParameters[0]));
  wristAngleTextField.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  wristAngleTextField.setOpaque(true);
  wristAngleTextField.addEventHandler(this, "wristAngleTextField_change");

  wristAngleLabel = new GLabel(this, 185, 65, 70, 14);
  wristAngleLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  wristAngleLabel.setText("Wrist Angle");
  wristAngleLabel.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  wristAngleLabel.setOpaque(false);
  wristAngleLabel.setFont(new Font("Dialog", Font.PLAIN, 10));

  wristAngleSlider = new GSlider(this, 75, 155, 145, 40, 10.0);
  wristAngleSlider.setShowLimits(true);
  wristAngleSlider.setLimits(0.0, -90.0, 90.0);
  wristAngleSlider.setEasing(0.0);
  wristAngleSlider.setNumberFormat(G4P.INTEGER, 0);
  wristAngleSlider.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  wristAngleSlider.setOpaque(false);
  wristAngleSlider.addEventHandler(this, "wristAngleSlider_change");
  wristAngleSlider.setShowValue(true);
  wristAngleSlider.setVisible(false);






  wristRotateTextField = new GTextField(this, 300, 40, 60, 20, G4P.SCROLLBARS_NONE);
  wristRotateTextField.setText(Integer.toString( wristRotateParameters[0]));
  wristRotateTextField.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  wristRotateTextField.setOpaque(true);
  wristRotateTextField.addEventHandler(this, "wristRotateTextField_change");
  
  wristRotateLabel = new GLabel(this, 300, 65, 70, 14);
  wristRotateLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  wristRotateLabel.setText("Wrist Rotate");
  wristRotateLabel.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  wristRotateLabel.setOpaque(false);
  wristRotateLabel.setFont(new Font("Dialog", Font.PLAIN, 10));

  wristRotateSlider = new GSlider(this, 75, 200, 145, 40, 10.0);
  wristRotateSlider.setShowLimits(true);
  wristRotateSlider.setLimits(0.0, -512.0, 512.0);
  wristRotateSlider.setEasing(0.0);
  wristRotateSlider.setNumberFormat(G4P.INTEGER, 0);
  wristRotateSlider.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  wristRotateSlider.setOpaque(false);
  wristRotateSlider.addEventHandler(this, "wristRotateSlider_change");
  wristRotateSlider.setShowValue(true);
  wristRotateSlider.setVisible(false);





  gripperTextField = new GTextField(this, 190, 110, 60, 20, G4P.SCROLLBARS_NONE);
  gripperTextField.setText(Integer.toString(gripperParameters[0]));
  gripperTextField.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  gripperTextField.setOpaque(true);
  gripperTextField.addEventHandler(this, "gripperTextField_change");
  
  gripperLabel = new GLabel(this, 190, 135, 60, 14);
  gripperLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  gripperLabel.setText("Gripper");
  gripperLabel.setOpaque(false);
  

  gripperSlider = new GSlider(this, 75, 245, 145, 40, 10.0);
  gripperSlider.setShowLimits(true);
  gripperSlider.setLimits(256.0, 0.0, 512.0);
  gripperSlider.setEasing(0.0);
  gripperSlider.setNumberFormat(G4P.INTEGER, 0);
  gripperSlider.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  gripperSlider.setOpaque(false);
  gripperSlider.addEventHandler(this, "gripperSlider_change");
  gripperSlider.setShowValue(true);
  gripperSlider.setVisible(false);





  deltaTextField = new GTextField(this, 5, 300, 60, 20, G4P.SCROLLBARS_NONE);
  deltaTextField.setText("125");
  deltaTextField.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  deltaTextField.setOpaque(true);
  deltaTextField.addEventHandler(this, "deltaTextField_change");


  deltaSlider = new GSlider(this, 75, 290, 145, 40, 10.0);
  deltaSlider.setShowValue(true);
  deltaSlider.setShowLimits(true);
  deltaSlider.setLimits(125.0, 0.0, 255.0);
  deltaSlider.setEasing(0.0);
  deltaSlider.setNumberFormat(G4P.INTEGER, 0);
  deltaSlider.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  deltaSlider.setOpaque(false);
  deltaSlider.addEventHandler(this, "deltaSlider_change");


  deltaLabel = new GLabel(this, 5, 320, 60, 14);
  deltaLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  deltaLabel.setText("Delta");
  deltaLabel.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  deltaLabel.setOpaque(false);



  extendedTextField = new GTextField(this, 5, 345, 60, 20, G4P.SCROLLBARS_NONE);
  extendedTextField.setText("0");
  extendedTextField.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  extendedTextField.setOpaque(true);
  extendedTextField.addEventHandler(this, "extendedTextField_change");

  extendedLabel = new GLabel(this, 5, 365, 100, 14);
  extendedLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  extendedLabel.setText("Extended Byte");
  extendedLabel.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  extendedLabel.setOpaque(false);
  extendedLabel.setFont(new Font("Dialog", Font.PLAIN, 10));


  digitalCheckbox0 = new GCheckbox(this, 5, 385, 28, 20);
  digitalCheckbox0.setOpaque(false);
  digitalCheckbox0.addEventHandler(this, "digitalCheckbox0_change");
  digitalCheckbox0.setText("0");

  digitalCheckbox1 = new GCheckbox(this, 32, 385, 28, 20);
  digitalCheckbox1.setOpaque(false);
  digitalCheckbox1.addEventHandler(this, "digitalCheckbox1_change");
  digitalCheckbox1.setText("1");

  digitalCheckbox2 = new GCheckbox(this, 60, 385, 28, 20);
  digitalCheckbox2.setOpaque(false);
  digitalCheckbox2.addEventHandler(this, "digitalCheckbox2_change");
  digitalCheckbox2.setText("2");

  digitalCheckbox3 = new GCheckbox(this, 88, 385, 28, 20);
  digitalCheckbox3.setOpaque(false);
  digitalCheckbox3.addEventHandler(this, "digitalCheckbox3_change");
  digitalCheckbox3.setText("3");

  digitalCheckbox4 = new GCheckbox(this, 116, 385, 28, 20);
  digitalCheckbox4.setOpaque(false);
  digitalCheckbox4.addEventHandler(this, "digitalCheckbox4_change");
  digitalCheckbox4.setText("4");

  digitalCheckbox5 = new GCheckbox(this, 144, 385, 28, 20);
  digitalCheckbox5.setOpaque(false);
  digitalCheckbox5.addEventHandler(this, "digitalCheckbox5_change");
  digitalCheckbox5.setText("5");

  digitalCheckbox6 = new GCheckbox(this, 172, 385, 28, 20);
  digitalCheckbox6.setOpaque(false);
  digitalCheckbox6.addEventHandler(this, "digitalCheckbox6_change");
  digitalCheckbox6.setText("6");

  digitalCheckbox7 = new GCheckbox(this, 200, 385, 28, 20);
  digitalCheckbox7.setOpaque(false);
  digitalCheckbox7.addEventHandler(this, "digitalCheckbox7_change");
  digitalCheckbox7.setText("7");




  digitalsLabel = new GLabel(this, 5, 400, 100, 14);
  digitalsLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  digitalsLabel.setText("Digital Values");
  digitalsLabel.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  digitalsLabel.setOpaque(false);


  updateButton = new GButton(this, 5, 425, 100, 50);
  updateButton.setText("Update");
  updateButton.addEventHandler(this, "updateButton_click");
  updateButton.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  updateButton.setFont(new Font("Dialog", Font.PLAIN, 20));  

 

  autoUpdateCheckbox = new GCheckbox(this, 105, 459, 100, 20);
  autoUpdateCheckbox.setOpaque(false);
  autoUpdateCheckbox.addEventHandler(this, "autoUpdateCheckbox_change");
  autoUpdateCheckbox.setText("Auto Update");
 
 
  
  gripperLeftSlider = new GCustomSlider(this, 180, 100, 150, 200, "gripperL");
  gripperLeftSlider.setLimits(256.0, 512.0, 0.0);
  gripperLeftSlider.setShowDecor(false, true, false, false);
  gripperLeftSlider.setShowLimits(true);
  gripperLeftSlider.setEasing(0.0);
  gripperLeftSlider.setNumberFormat(G4P.INTEGER, 0);
  gripperLeftSlider.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  gripperLeftSlider.setShowValue(true);
  gripperLeftSlider.addEventHandler(this, "gripperLeftSlider_change");
  
  
  gripperRightSlider = new GCustomSlider(this, 324, 100, 150, 200, "gripperR");
  gripperRightSlider.setShowDecor(false, true, false, false);
  gripperRightSlider.setLimits(256.0, 0.0, 512.0);
  gripperRightSlider.setShowDecor(false, true, false, false);
 // gripperRightSlider.setShowLimits(true);
  gripperRightSlider.setEasing(0.0);
  gripperRightSlider.setNumberFormat(G4P.INTEGER, 0);
  gripperRightSlider.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  gripperRightSlider.setValue(256);
 // gripperRightSlider.setShowValue(true);
  gripperRightSlider.addEventHandler(this, "gripperRightSlider_change");
  
  


  controlPanel.addControl(xTextField);
  controlPanel.addControl(xSlider);
  controlPanel.addControl(yTextField);
  controlPanel.addControl(ySlider);
  controlPanel.addControl(yLabel);
  controlPanel.addControl(xLabel);
  controlPanel.addControl(zTextField);
  controlPanel.addControl(zSlider);
  controlPanel.addControl(zLabel);
  controlPanel.addControl(wristAngleTextField);
  controlPanel.addControl(wristAngleSlider);
  controlPanel.addControl(wristAngleLabel);
  controlPanel.addControl(wristRotateTextField);
  controlPanel.addControl(wristRotateSlider);
  controlPanel.addControl(wristRotateLabel);
  controlPanel.addControl(gripperTextField);
  controlPanel.addControl(gripperSlider);
  controlPanel.addControl(gripperLabel);
  controlPanel.addControl(deltaTextField);
  controlPanel.addControl(deltaSlider);
  controlPanel.addControl(deltaLabel);
  controlPanel.addControl(extendedTextField);
  controlPanel.addControl(extendedLabel);
  controlPanel.addControl(digitalsLabel);
  controlPanel.addControl(digitalCheckbox0);
  controlPanel.addControl(digitalCheckbox1);
  controlPanel.addControl(digitalCheckbox2);
  controlPanel.addControl(digitalCheckbox3);
  controlPanel.addControl(digitalCheckbox4);
  controlPanel.addControl(digitalCheckbox5);
  controlPanel.addControl(digitalCheckbox6);
  controlPanel.addControl(digitalCheckbox7);
  controlPanel.addControl(autoUpdateCheckbox);
  controlPanel.addControl(updateButton);
  controlPanel.addControl(baseKnob);
  controlPanel.addControl(shoulderKnob);
  controlPanel.addControl(elbowKnob);
  controlPanel.addControl(wristAngleKnob);
  controlPanel.addControl(wristRotateKnob);
  controlPanel.addControl(gripperLeftSlider);
  controlPanel.addControl(gripperRightSlider);
  //controlPanel.addControl(waitingButton);

  waitingButton = new GImageButton(this, 115, 408, 100, 30, new String[] { 
    "moving.jpg", "moving.jpg", "moving.jpg"
  } 
  );
  waitingButton.setAlpha(0);
  
//error
  errorPanel = new GPanel(this, 50, 280, 150, 150, "Error Panel");
  errorPanel.setText("Error Panel");
  errorPanel.setLocalColorScheme(GCScheme.RED_SCHEME);
  errorPanel.setOpaque(true);
  errorPanel.setVisible(false);
  errorPanel.addEventHandler(this, "errorPanel_Click");
  //errorPanel.setDraggable(false);
  errorPanel.setCollapsible(false);
  
  errorLinkButton = new GButton(this, 15, 120, 50, 20);
  errorLinkButton.setText("Link");
  errorLinkButton.addEventHandler(this, "errorLinkButton_click");
  errorLinkButton.setLocalColorScheme(GCScheme.RED_SCHEME);

  errorOkButton = new GButton(this, 80, 120, 50, 20);
  errorOkButton.setText("OK");
  errorOkButton.addEventHandler(this, "errorOkButton_click");
  errorOkButton.setLocalColorScheme(GCScheme.RED_SCHEME);

  errorLabel = new GLabel(this, 10, 25, 130, 80);
  errorLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  errorLabel.setText("Error: Error: Error: Error: Error: Error: Error: Error: Error: Error: Error: Error: Error: Error: Error: Error: ");
  errorLabel.setOpaque(false);
  errorLabel.setFont(new Font("Dialog", Font.PLAIN, 10)); 



  errorPanel.addControl(errorLinkButton);
  errorPanel.addControl(errorOkButton);
  errorPanel.addControl(errorLabel);



//settings
  settingsPanel = new GPanel(this, 10, 280, 230, 230, "Settings Panel");
  settingsPanel.setText("Error Panel");
  settingsPanel.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  settingsPanel.setOpaque(true);
  settingsPanel.setVisible(false);
  settingsPanel.addEventHandler(this, "settingsPanel_Click");
  //settingsPanel.setDraggable(false);
  settingsPanel.setCollapsible(false);


  fileDebugCheckbox = new GCheckbox(this, 5, 20, 200, 20);
  fileDebugCheckbox.setOpaque(false);
  fileDebugCheckbox.addEventHandler(this, "fileDebugCheckbox_change");
  fileDebugCheckbox.setText("Debug to File");

  settingsDismissButton = new GButton(this, 15, 120, 50, 20);
  settingsDismissButton.setText("Done");
  settingsDismissButton.addEventHandler(this, "settingsDismissButton_click");
  settingsDismissButton.setLocalColorScheme(GCScheme.RED_SCHEME);

  settingsPanel.addControl(settingsDismissButton);
  settingsPanel.addControl(fileDebugCheckbox);







  logoImg = loadImage("logo.png");  // Load the image into the program  
  footerImg = loadImage("footer.png");  // Load the image into the program  




  //MOVE TO GUI
  
  
}



/******************************************************
 *  setPositionParameters()
 *  This function will load the approriate position 
 *  defaults, minimums, and maximums into the GUI
 *  text fields and sliders, as well as the limit check
 *  logic. In addition, label elements will be changed
 *  to reflect the current controls. Finally, the current
 *  defaults will be written back to the internal variables
 *
 *
 *  Tasks to perform on end of program
 *  Arm
 *  1 - Pincher
 *  2 - Reactor
 *  3 - WidowX 
 *  
 *  Mode
 *   1 - Cartesian
 *   2 - Cylindrical
 *   3 - backhoe
 *
 *  Wrist Orientaiton
 *    1- Straight
 *    2 - 90 degrees
 ******************************************************/ 

void setPositionParameters()
{

  //switch to look foe aech arm
switch(currentArm)
{
  //pincher
  case 1:
   //pincher, normal orinetation
    switch(currentMode)
    {
    
    //cartesian
    case 1:
      switch(currentOrientation)
      {
      //straight
      case 1:        
      xSlider.setLimits( pincherNormalX[0], pincherNormalX[1], pincherNormalX[2]);    
      xTextField.setText(Integer.toString(pincherNormalX[0]));
      xLabel.setText("X Coord");
      arrayCopy(pincherNormalX, xParameters);
  
      ySlider.setLimits( pincherNormalY[0], pincherNormalY[1], pincherNormalY[2]) ; 
      yTextField.setText(Integer.toString(pincherNormalY[0]));
      xLabel.setText("Y Coord");
      arrayCopy(pincherNormalY, yParameters);
  
      zSlider.setLimits( pincherNormalZ[0], pincherNormalZ[1], pincherNormalZ[2]) ;   
      zTextField.setText(Integer.toString(pincherNormalZ[0]));
      zLabel.setText("Z Coord");
      arrayCopy(pincherNormalZ, zParameters);
  
      wristAngleSlider.setLimits(pincherNormalWristAngle[0], pincherNormalWristAngle[1], pincherNormalWristAngle[2]); 
      wristAngleTextField.setText(Integer.toString(pincherNormalWristAngle[0]));
      wristAngleLabel.setText("Wrist Angle");
      arrayCopy(pincherNormalWristAngle, wristAngleParameters);
  
      wristRotateSlider.setLimits(pincherWristRotate[0], pincherWristRotate[1], pincherWristRotate[2]) ;   
      wristRotateTextField.setText(Integer.toString(pincherWristRotate[0]));
      wristRotateLabel.setText("Wrist Rotate");
      arrayCopy(pincherWristRotate, wristRotateParameters);
      wristRotateSlider.setVisible(false);
      wristRotateTextField.setVisible(false);
      wristRotateLabel.setVisible(false);
  
      gripperSlider.setLimits( pincherGripper[0], pincherGripper[1], pincherGripper[2]);    
      gripperTextField.setText(Integer.toString(pincherGripper[0]));
      gripperLabel.setText("Gripper");
      arrayCopy(pincherGripper, gripperParameters);
      break;
    //90 degrees
      case 2:
      xSlider.setLimits( pincher90X[0], pincher90X[1], pincher90X[2]);    
      xTextField.setText(Integer.toString(pincher90X[0]));
      xLabel.setText("X Coord");
      arrayCopy(pincher90X, xParameters);
  
      ySlider.setLimits( pincher90Y[0], pincher90Y[1], pincher90Y[2]) ; 
      yTextField.setText(Integer.toString(pincher90Y[0]));
      yLabel.setText("Y Coord");
      arrayCopy(pincher90Y, yParameters);
  
      zSlider.setLimits( pincher90Z[0], pincher90Z[1], pincher90Z[2]) ;   
      zTextField.setText(Integer.toString(pincher90Z[0]));
      zLabel.setText("Z Coord");
      arrayCopy(pincher90Z, zParameters);
  
      wristAngleSlider.setLimits(pincher90WristAngle[0], pincher90WristAngle[1], pincher90WristAngle[2]); 
      wristAngleTextField.setText(Integer.toString(pincher90WristAngle[0]));
      wristAngleLabel.setText("Wrist Angle");
      arrayCopy(pincher90WristAngle, wristAngleParameters);
  
      wristRotateSlider.setLimits(pincherWristRotate[0], pincherWristRotate[1], pincherWristRotate[2]) ;   
      wristRotateTextField.setText(Integer.toString(pincherWristRotate[0]));
      wristRotateLabel.setText("Wrist Rotate");
      arrayCopy(pincherWristRotate, wristRotateParameters);
      wristRotateSlider.setVisible(false);
      wristRotateTextField.setVisible(false);
      wristRotateLabel.setVisible(false);
  
      gripperSlider.setLimits( pincherGripper[0], pincherGripper[1], pincherGripper[2]);    
      gripperTextField.setText(Integer.toString(pincherGripper[0]));
      gripperLabel.setText("Gripper");
      arrayCopy(pincherGripper, gripperParameters);
  
      break;
      }
      break;
  
    //cylindrical
    case 2:
      switch(currentOrientation)
      {
      //straight
      case 1: 
      xSlider.setLimits( pincherBase[0], pincherBase[1], pincherBase[2]);    
      xTextField.setText(Integer.toString(pincherBase[0]));
      xLabel.setText("Base");
      arrayCopy(pincherBase, xParameters);
  
      ySlider.setLimits( pincherNormalY[0], pincherNormalY[1], pincherNormalY[2]) ; 
      yTextField.setText(Integer.toString(pincherNormalY[0]));
      yLabel.setText("Y Coord");
      arrayCopy(pincherNormalY, yParameters);
  
      zSlider.setLimits( pincherNormalZ[0], pincherNormalZ[1], pincherNormalZ[2]) ;   
      zTextField.setText(Integer.toString(pincherNormalZ[0]));
      zLabel.setText("Z Coord");
      arrayCopy(pincherNormalZ, zParameters);
  
      wristAngleSlider.setLimits(pincherNormalWristAngle[0], pincherNormalWristAngle[1], pincherNormalWristAngle[2]); 
      wristAngleTextField.setText(Integer.toString(pincherNormalWristAngle[0]));
      wristAngleLabel.setText("Wrist Angle");
      arrayCopy(pincherNormalWristAngle, wristAngleParameters);
  
      wristRotateSlider.setLimits(pincherWristRotate[0], pincherWristRotate[1], pincherWristRotate[2]) ;   
      wristRotateTextField.setText(Integer.toString(pincherWristRotate[0]));
      wristRotateLabel.setText("Wrist Rotate");
      arrayCopy(pincherWristRotate, wristRotateParameters);
      wristRotateSlider.setVisible(false);
      wristRotateTextField.setVisible(false);
      wristRotateLabel.setVisible(false);
  
  
      gripperSlider.setLimits( pincherGripper[0], pincherGripper[1], pincherGripper[2]);    
      gripperTextField.setText(Integer.toString(pincherGripper[0]));
      gripperLabel.setText("Gripper");
      arrayCopy(pincherGripper, gripperParameters);
  
      break;
  
    //90 degrees
      case 2:  
      xSlider.setLimits( pincherBase[0], pincherBase[1], pincherBase[2]);    
      xTextField.setText(Integer.toString(pincherBase[0]));
      xLabel.setText("Base");
      arrayCopy(pincherBase, xParameters);
  
      ySlider.setLimits( pincher90Y[0], pincher90Y[1], pincher90Y[2]) ; 
      yTextField.setText(Integer.toString(pincher90Y[0]));
      yLabel.setText("Y Coord");
      arrayCopy(pincher90Y, yParameters);
  
      zSlider.setLimits( pincher90Z[0], pincher90Z[1], pincher90Z[2]) ;   
      zTextField.setText(Integer.toString(pincher90Z[0]));
      zLabel.setText("Z Coord");
      arrayCopy(pincher90Z, zParameters);
  
      wristAngleSlider.setLimits(pincher90WristAngle[0], pincher90WristAngle[1], pincher90WristAngle[2]); 
      wristAngleTextField.setText(Integer.toString(pincher90WristAngle[0]));
      wristAngleLabel.setText("Wrist Angle");
      arrayCopy(pincher90WristAngle, wristAngleParameters);
  
      wristRotateSlider.setLimits(pincherWristRotate[0], pincherWristRotate[1], pincherWristRotate[2]) ;   
      wristRotateTextField.setText(Integer.toString(pincherWristRotate[0]));
      wristRotateLabel.setText("Wrist Rotate");
      arrayCopy(pincherWristRotate, wristRotateParameters);
      wristRotateSlider.setVisible(false);
      wristRotateTextField.setVisible(false);
      wristRotateLabel.setVisible(false);
  
  
      gripperSlider.setLimits( pincherGripper[0], pincherGripper[1], pincherGripper[2]);    
      gripperTextField.setText(Integer.toString(pincherGripper[0]));
      gripperLabel.setText("Gripper");
      arrayCopy(pincherGripper, gripperParameters);
  
  
      break;
      }
  
      break;
    //backhoe
    case 3: 
  
  
      xSlider.setLimits( pincherBase[0], pincherBase[1], pincherBase[2]);    
      xTextField.setText(Integer.toString(pincherBase[0]));
      xLabel.setText("Base");
      arrayCopy(pincherBase, xParameters);
  
      ySlider.setLimits( pincherBHShoulder[0], pincherBHShoulder[1], pincherBHShoulder[2]) ; 
      yTextField.setText(Integer.toString(pincherBHShoulder[0]));
      yLabel.setText("Shoulder");
      arrayCopy(pincherBHShoulder, yParameters);
  
      zSlider.setLimits( pincherBHElbow[0], pincherBHElbow[1], pincherBHElbow[2]) ;   
      zTextField.setText(Integer.toString(pincherBHElbow[0]));
      zLabel.setText("Elbow");
      arrayCopy(pincherBHElbow, zParameters);
  
      wristAngleSlider.setLimits(pincherBHWristAngle[0], pincherBHWristAngle[1], pincherBHWristAngle[2]); 
      wristAngleTextField.setText(Integer.toString(pincherBHWristAngle[0]));
      wristAngleLabel.setText("Wrist Angle");
      arrayCopy(pincherBHWristAngle, wristAngleParameters);
  
      wristRotateSlider.setLimits(pincherBHWristRot[0], pincherBHWristRot[1], pincherBHWristRot[2]) ;   
      wristRotateTextField.setText(Integer.toString(pincherBHWristRot[0]));
      wristRotateLabel.setText("Wrist Rotate");
      arrayCopy(pincherBHWristRot, wristRotateParameters);
      wristRotateSlider.setVisible(false);
      wristRotateTextField.setVisible(false);
      wristRotateLabel.setVisible(false);
  
  
      gripperSlider.setLimits( pincherGripper[0], pincherGripper[1], pincherGripper[2]);    
      gripperTextField.setText(Integer.toString(pincherGripper[0]));
      gripperLabel.setText("Gripper");
      arrayCopy(pincherGripper, gripperParameters);
  
      break;
    }
    break;//end pincher arm 


    //reactor arm 
  case 2:
    switch(currentMode)
    {
      //cartesian mode reactor arm      
      case 1:
    
        //hide/show appropriate GUI elements
        baseKnob.setVisible(false);
        shoulderKnob.setVisible(false);
        elbowKnob.setVisible(false);
        xSlider.setVisible(true);
        ySlider.setVisible(true);
        zSlider.setVisible(true);
        wristRotateKnob.setVisible(true);
        
        switch(currentOrientation)
        {
          //normal orientation reactor arm arm cartesian
          case 1:        
      
          wristAngleKnob.setTurnRange(reactorWristAngleNormalKnob[0], reactorWristAngleNormalKnob[1]); //set angle limits start/finish
          wristAngleKnob.setLimits(reactorNormalWristAngle[0], reactorNormalWristAngle[1], reactorNormalWristAngle[2]);//set value limits
      
          xSlider.setLimits( reactorNormalX[0], reactorNormalX[1], reactorNormalX[2]);    
          xTextField.setText(Integer.toString(reactorNormalX[0]));
          xLabel.setText("X Coord");
          arrayCopy(reactorNormalX, xParameters);
      
          ySlider.setLimits( reactorNormalY[0], reactorNormalY[1], reactorNormalY[2]) ; 
          yTextField.setText(Integer.toString(reactorNormalY[0]));
          yLabel.setText("Y Coord");
          arrayCopy(reactorNormalY, yParameters);
      
          zSlider.setLimits( reactorNormalZ[0], reactorNormalZ[1], reactorNormalZ[2]) ;   
          zTextField.setText(Integer.toString(reactorNormalZ[0]));
          zLabel.setText("Z Coord");
          arrayCopy(reactorNormalZ, zParameters);
      
          wristAngleSlider.setLimits(reactorNormalWristAngle[0], reactorNormalWristAngle[1], reactorNormalWristAngle[2]); 
          wristAngleTextField.setText(Integer.toString(reactorNormalWristAngle[0]));
          wristAngleLabel.setText("Wrist Angle");
          arrayCopy(reactorNormalWristAngle, wristAngleParameters);
      
          wristRotateSlider.setLimits(reactorWristRotate[0], reactorWristRotate[1], reactorWristRotate[2]) ;   
          wristRotateTextField.setText(Integer.toString(reactorWristRotate[0]));
          wristRotateLabel.setText("Wrist Rotate");
          arrayCopy(reactorWristRotate, wristRotateParameters);
          wristRotateSlider.setVisible(false);
          wristRotateTextField.setVisible(true);
          wristRotateLabel.setVisible(true);
      
      
          gripperSlider.setLimits( reactorGripper[0], reactorGripper[1], reactorGripper[2]);    
          gripperTextField.setText(Integer.toString(reactorGripper[0]));
          gripperLabel.setText("Gripper");
          arrayCopy(reactorGripper, gripperParameters);
          
          gripperLeftSlider.setLimits( reactorGripper[0], reactorGripper[2], reactorGripper[1]);    
          gripperRightSlider.setLimits( reactorGripper[0], reactorGripper[1], reactorGripper[2]); 
          arrayCopy(reactorGripper, gripperParameters);
          
          
          break;//end  normal orientation reactor arm arm cartesian
      
          //90 degree mode reactor arm cartesian
          case 2:
      
          wristAngleKnob.setTurnRange(reactorWristAngle90Knob[0], reactorWristAngle90Knob[1]); //set angle limits start/finish
          wristAngleKnob.setLimits(reactor90WristAngle[0], reactor90WristAngle[1], reactor90WristAngle[2]);//set value limits
        
          xSlider.setLimits( reactor90X[0], reactor90X[1], reactor90X[2]);    
          xTextField.setText(Integer.toString(reactor90X[0]));
          xLabel.setText("X Coord");
          arrayCopy(reactor90X, xParameters);
          
          ySlider.setLimits( reactor90Y[0], reactor90Y[1], reactor90Y[2]) ; 
          yTextField.setText(Integer.toString(reactor90Y[0]));
          yLabel.setText("Y Coord");
          arrayCopy(reactor90Y, yParameters);
          
          zSlider.setLimits( reactor90Z[0], reactor90Z[1], reactor90Z[2]) ;   
          zTextField.setText(Integer.toString(reactor90Z[0]));
          zLabel.setText("Z Coord");
          arrayCopy(reactor90Z, zParameters);
          
          wristAngleSlider.setLimits(reactor90WristAngle[0], reactor90WristAngle[1], reactor90WristAngle[2]); 
          wristAngleTextField.setText(Integer.toString(reactor90WristAngle[0]));
          wristAngleLabel.setText("Wrist Angle");
          arrayCopy(reactor90WristAngle, wristAngleParameters);
          
          wristRotateSlider.setLimits(reactorWristRotate[0], reactorWristRotate[1], reactorWristRotate[2]) ;   
          wristRotateTextField.setText(Integer.toString(reactorWristRotate[0]));
          wristRotateLabel.setText("Wrist Rotate");
          arrayCopy(reactorWristRotate, wristRotateParameters);
          wristRotateSlider.setVisible(false);
          wristRotateTextField.setVisible(true);
          wristRotateLabel.setVisible(true);
          
          
          gripperSlider.setLimits( reactorGripper[0], reactorGripper[1], reactorGripper[2]);    
          gripperTextField.setText(Integer.toString(reactorGripper[0]));
          gripperLabel.setText("Gripper");
          arrayCopy(reactorGripper, gripperParameters);
          
          break;//end 90 degree mode reactor arm cartesian
        }
      break;//end  reactor arm
  
      //cylcindrical reactor arm  
      case 2:
  
        baseKnob.setVisible(true);
        shoulderKnob.setVisible(false);
        elbowKnob.setVisible(false);
        xSlider.setVisible(false);
        ySlider.setVisible(true);
        zSlider.setVisible(true);
        wristRotateKnob.setVisible(true);
        
        gripperLeftSlider.setLimits( reactorGripper[0], reactorGripper[2], reactorGripper[1]);    
        gripperRightSlider.setLimits( reactorGripper[0], reactorGripper[1], reactorGripper[2]); 
        arrayCopy(reactorGripper, gripperParameters);
          
          
          
          switch(currentOrientation)
          {
          //normal orientation reactor arm cylcindrical
          case 1: 
            
            
            wristAngleKnob.setTurnRange(reactorWristAngleNormalKnob[0], reactorWristAngleNormalKnob[1]); //set angle limits start/finish
            wristAngleKnob.setLimits(reactorNormalWristAngle[0], reactorNormalWristAngle[1], reactorNormalWristAngle[2]);//set value limits
            
            
            xSlider.setLimits( reactorBase[0], reactorBase[1], reactorBase[2]);    
            xTextField.setText(Integer.toString(reactorBase[0]));
            xLabel.setText("Base");
            arrayCopy(reactorBase, xParameters);
        
            ySlider.setLimits( reactorNormalY[0], reactorNormalY[1], reactorNormalY[2]) ; 
            yTextField.setText(Integer.toString(reactorNormalY[0]));
            yLabel.setText("Y Coord");
            arrayCopy(reactorNormalY, yParameters);
        
            zSlider.setLimits( reactorNormalZ[0], reactorNormalZ[1], reactorNormalZ[2]) ;   
            zTextField.setText(Integer.toString(reactorNormalZ[0]));
            zLabel.setText("Z Coord");
            arrayCopy(reactorNormalZ, zParameters);
        
            wristAngleSlider.setLimits(reactorNormalWristAngle[0], reactorNormalWristAngle[1], reactorNormalWristAngle[2]); 
            wristAngleTextField.setText(Integer.toString(reactorNormalWristAngle[0]));
            wristAngleLabel.setText("Wrist Angle");
            arrayCopy(reactorNormalWristAngle, wristAngleParameters);
        
            wristRotateSlider.setLimits(reactorWristRotate[0], reactorWristRotate[1], reactorWristRotate[2]) ;   
            wristRotateTextField.setText(Integer.toString(reactorWristRotate[0]));
            wristRotateLabel.setText("Wrist Rotate");
            arrayCopy(reactorWristRotate, wristRotateParameters);
            wristRotateSlider.setVisible(false);
            wristRotateTextField.setVisible(true);
            wristRotateLabel.setVisible(true);
        
        
        
            gripperSlider.setLimits( reactorGripper[0], reactorGripper[1], reactorGripper[2]);    
            gripperTextField.setText(Integer.toString(reactorGripper[0]));
            gripperLabel.setText("Gripper");
            arrayCopy(reactorGripper, gripperParameters);
          break;//end  reactor arm
      
          //90 degree orientation reactor arm cylcindrical
            case 2:            
            wristAngleKnob.setTurnRange(reactorWristAngle90Knob[0], reactorWristAngle90Knob[1]); //set angle limits start/finish
            wristAngleKnob.setLimits(reactor90WristAngle[0], reactor90WristAngle[1], reactor90WristAngle[2]);//set value limits
            
            
            
            xSlider.setLimits( reactorBase[0], reactorBase[1], reactorBase[2]);    
            xTextField.setText(Integer.toString(reactorBase[0]));
            xLabel.setText("Base");
            arrayCopy(reactorBase, xParameters);
        
            ySlider.setLimits( reactor90Y[0], reactor90Y[1], reactor90Y[2]) ; 
            yTextField.setText(Integer.toString(reactor90Y[0]));
            yLabel.setText("Y Coord");
            arrayCopy(reactor90Y, yParameters);
        
            zSlider.setLimits( reactor90Z[0], reactor90Z[1], reactor90Z[2]) ;   
            zTextField.setText(Integer.toString(reactor90Z[0]));
            zLabel.setText("Z Coord");
            arrayCopy(reactor90Z, zParameters);
        
            wristAngleSlider.setLimits(reactor90WristAngle[0], reactor90WristAngle[1], reactor90WristAngle[2]); 
            wristAngleTextField.setText(Integer.toString(reactor90WristAngle[0]));
            wristAngleLabel.setText("Wrist Angle");
            arrayCopy(reactor90WristAngle, wristAngleParameters);
        
            wristRotateSlider.setLimits(reactorWristRotate[0], reactorWristRotate[1], reactorWristRotate[2]) ;   
            wristRotateTextField.setText(Integer.toString(reactorWristRotate[0]));
            wristRotateLabel.setText("Wrist Rotate");
            arrayCopy(reactorWristRotate, wristRotateParameters);
            wristRotateSlider.setVisible(false);
            wristRotateTextField.setVisible(true);
            wristRotateLabel.setVisible(true);
        
        
            gripperSlider.setLimits( reactorGripper[0], reactorGripper[1], reactorGripper[2]);    
            gripperTextField.setText(Integer.toString(reactorGripper[0]));
            gripperLabel.setText("Gripper");
            arrayCopy(reactorGripper, gripperParameters);
          break;//end  90 degree orientation reactor arm cylcindrical
        }
      
      break;//end  cylcindrical reactor arm  
  
  
        //backhoe mode reactor arm
      case 3: 
          
        baseKnob.setVisible(true);
        shoulderKnob.setVisible(true);
        elbowKnob.setVisible(true);
        xSlider.setVisible(false);
        ySlider.setVisible(false);
        zSlider.setVisible(false);
        wristRotateKnob.setVisible(true);
          
        gripperLeftSlider.setLimits( reactorGripper[0], reactorGripper[2], reactorGripper[1]);    
        gripperRightSlider.setLimits( reactorGripper[0], reactorGripper[1], reactorGripper[2]); 
        arrayCopy(reactorGripper, gripperParameters);
        
          
        wristAngleKnob.setTurnRange(reactorWristAngleBHKnob[0], reactorWristAngleBHKnob[1]); //set angle limits start/finish
        wristAngleKnob.setLimits(reactorBHWristAngle[0], reactorBHWristAngle[1], reactorBHWristAngle[2]);//set value limits
        arrayCopy(reactorBHWristAngle, wristAngleParameters);
        
                  
        wristRotateKnob.setTurnRange(reactorWristRotKnob[0], reactorWristRotKnob[1]); //set angle limits start/finish
        wristRotateKnob.setLimits(reactorBHWristRot[0], reactorBHWristRot[1], reactorBHWristRot[2]);//set value limits
        
        
        wristRotateTextField.setText(Integer.toString(reactorBHWristRot[0]));
        wristRotateLabel.setText("Wrist Rotate");
        arrayCopy(reactorBHWristRot, wristRotateParameters);
        
        wristRotateSlider.setVisible(false);
        wristRotateTextField.setVisible(true);
        wristRotateLabel.setVisible(true);
        
        
        gripperSlider.setLimits( reactorGripper[0], reactorGripper[1], reactorGripper[2]);    
        gripperTextField.setText(Integer.toString(reactorGripper[0]));
        gripperLabel.setText("Gripper");
          arrayCopy(reactorGripper, gripperParameters);
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
  
      xSlider.setLimits( widowNormalX[0], widowNormalX[1], widowNormalX[2]);    
      xTextField.setText(Integer.toString(widowNormalX[0]));
      xLabel.setText("X Coord");
      arrayCopy(widowNormalX, xParameters);
  
      ySlider.setLimits( widowNormalY[0], widowNormalY[1], widowNormalY[2]) ; 
      yTextField.setText(Integer.toString(widowNormalY[0]));
      yLabel.setText("Y Coord");
      arrayCopy(widowNormalY, yParameters);
  
      zSlider.setLimits( widowNormalZ[0], widowNormalZ[1], widowNormalZ[2]) ;   
      zTextField.setText(Integer.toString(widowNormalZ[0]));
      zLabel.setText("Z Coord");
      arrayCopy(widowNormalZ, zParameters);
  
      wristAngleSlider.setLimits(widowNormalWristAngle[0], widowNormalWristAngle[1], widowNormalWristAngle[2]); 
      wristAngleTextField.setText(Integer.toString(widowNormalWristAngle[0]));
      wristAngleLabel.setText("Wrist Angle");
      arrayCopy(widowNormalWristAngle, wristAngleParameters);
  
      wristRotateSlider.setLimits(widowWristRotate[0], widowWristRotate[1], widowWristRotate[2]) ;   
      wristRotateTextField.setText(Integer.toString(widowWristRotate[0]));
      wristRotateLabel.setText("Wrist Rotate");
      arrayCopy(widowWristRotate, wristRotateParameters);
      wristRotateSlider.setVisible(false);
      wristRotateTextField.setVisible(true);
      wristRotateLabel.setVisible(true);
  
  
      gripperSlider.setLimits( widowGripper[0], widowGripper[1], widowGripper[2]);    
      gripperTextField.setText(Integer.toString(widowGripper[0]));
      gripperLabel.setText("Gripper");
      arrayCopy(widowGripper, gripperParameters);
      break;
  
  
      //90 degree mode widow arm cartesian
      case 2:
  
      xSlider.setLimits( widow90X[0], widow90X[1], widow90X[2]);    
      xTextField.setText(Integer.toString(widow90X[0]));
      xLabel.setText("X Coord");
      arrayCopy(widow90X, xParameters);
  
      ySlider.setLimits( widow90Y[0], widow90Y[1], widow90Y[2]) ; 
      yTextField.setText(Integer.toString(widow90Y[0]));
      yLabel.setText("Y Coord");
      arrayCopy(widow90Y, yParameters);
  
      zSlider.setLimits( widow90Z[0], widow90Z[1], widow90Z[2]) ;   
      zTextField.setText(Integer.toString(widow90Z[0]));
      zLabel.setText("Z Coord");
      arrayCopy(widow90Z, zParameters);
  
      wristAngleSlider.setLimits(widow90WristAngle[0], widow90WristAngle[1], widow90WristAngle[2]); 
      wristAngleTextField.setText(Integer.toString(widow90WristAngle[0]));
      wristAngleLabel.setText("Wrist Angle");
      arrayCopy(widow90WristAngle, wristAngleParameters);
  
      wristRotateSlider.setLimits(widowWristRotate[0], widowWristRotate[1], widowWristRotate[2]) ;   
      wristRotateTextField.setText(Integer.toString(widowWristRotate[0]));
      wristRotateLabel.setText("Wrist Rotate");
      arrayCopy(widowWristRotate, wristRotateParameters);
      wristRotateSlider.setVisible(false);
      wristRotateTextField.setVisible(true);
      wristRotateLabel.setVisible(true);
  
  
      gripperSlider.setLimits( widowGripper[0], widowGripper[1], widowGripper[2]);    
      gripperTextField.setText(Integer.toString(widowGripper[0]));
      gripperLabel.setText("Gripper");
      arrayCopy(widowGripper, gripperParameters);
      break;
      }
      break;//end  widow arm
  
      //cylcindrical widow arm  
    case 2:
      switch(currentOrientation)
      {
      //normal orientation widow arm cylcindrical
      case 1: 
  
  
      xSlider.setLimits( widowBase[0], widowBase[1], widowBase[2]);    
      xTextField.setText(Integer.toString(widowBase[0]));
      xLabel.setText("Base");
      arrayCopy(widowBase, xParameters);
  
      ySlider.setLimits( widowNormalY[0], widowNormalY[1], widowNormalY[2]) ; 
      yTextField.setText(Integer.toString(widowNormalY[0]));
      yLabel.setText("Y Coord");
      arrayCopy(widowNormalY, yParameters);
  
      zSlider.setLimits( widowNormalZ[0], widowNormalZ[1], widowNormalZ[2]) ;   
      zTextField.setText(Integer.toString(widowNormalZ[0]));
      zLabel.setText("Z Coord");
      arrayCopy(widowNormalZ, zParameters);
  
      wristAngleSlider.setLimits(widowNormalWristAngle[0], widowNormalWristAngle[1], widowNormalWristAngle[2]); 
      wristAngleTextField.setText(Integer.toString(widowNormalWristAngle[0]));
      wristAngleLabel.setText("Wrist Angle");
      arrayCopy(widowNormalWristAngle, wristAngleParameters);
  
      wristRotateSlider.setLimits(widowWristRotate[0], widowWristRotate[1], widowWristRotate[2]) ;   
      wristRotateTextField.setText(Integer.toString(widowWristRotate[0]));
      wristRotateLabel.setText("Wrist Rotate");
      arrayCopy(widowWristRotate, wristRotateParameters);
      wristRotateSlider.setVisible(false);
      wristRotateTextField.setVisible(true);
      wristRotateLabel.setVisible(true);
  
  
      gripperSlider.setLimits( widowGripper[0], widowGripper[1], widowGripper[2]);    
      gripperTextField.setText(Integer.toString(widowGripper[0]));
      gripperLabel.setText("Gripper");
      arrayCopy(widowGripper, gripperParameters);
      break;
      //90 degree orientation widow arm cylcindrical
  
      case 2:  
  
      xSlider.setLimits( widowBase[0], widowBase[1], widowBase[2]);    
      xTextField.setText(Integer.toString(widowBase[0]));
      xLabel.setText("Base");
      arrayCopy(widowBase, xParameters);
  
      ySlider.setLimits( widow90Y[0], widow90Y[1], widow90Y[2]) ; 
      yTextField.setText(Integer.toString(widow90Y[0]));
      yLabel.setText("Y Coord");
      arrayCopy(widow90Y, yParameters);
  
      zSlider.setLimits( widow90Z[0], widow90Z[1], widow90Z[2]) ;   
      zTextField.setText(Integer.toString(widow90Z[0]));
      zLabel.setText("Z Coord");
      arrayCopy(widow90Z, zParameters);
  
      wristAngleSlider.setLimits(widow90WristAngle[0], widow90WristAngle[1], widow90WristAngle[2]); 
      wristAngleTextField.setText(Integer.toString(widow90WristAngle[0]));
      wristAngleLabel.setText("Wrist Angle");
      arrayCopy(widow90WristAngle, wristAngleParameters);
  
      wristRotateSlider.setLimits(widowWristRotate[0], widowWristRotate[1], widowWristRotate[2]) ;   
      wristRotateTextField.setText(Integer.toString(widowWristRotate[0]));
      wristRotateLabel.setText("Wrist Rotate");
      arrayCopy(widowWristRotate, wristRotateParameters);
      wristRotateSlider.setVisible(false);
      wristRotateTextField.setVisible(true);
      wristRotateLabel.setVisible(true);
  
  
      gripperSlider.setLimits( widowGripper[0], widowGripper[1], widowGripper[2]);    
      gripperTextField.setText(Integer.toString(widowGripper[0]));
      gripperLabel.setText("Gripper");
      arrayCopy(widowGripper, gripperParameters);
      break;
      }
  
      break;//end  cylcindrical widow arm  
  
  
      //backhoe mode widow arm
    case 3: 
      xSlider.setLimits( widowBase[0], widowBase[1], widowBase[2]);    
      xTextField.setText(Integer.toString(widowBase[0]));
      xLabel.setText("Base");
      arrayCopy(widowBase, xParameters);
  
      ySlider.setLimits( widowBHShoulder[0], widowBHShoulder[1], widowBHShoulder[2]) ; 
      yTextField.setText(Integer.toString(widowBHShoulder[0]));
      yLabel.setText("Shoulder");
      arrayCopy(widowBHShoulder, yParameters);
  
      zSlider.setLimits( widowBHElbow[0], widowBHElbow[1], widowBHElbow[2]) ;   
      zTextField.setText(Integer.toString(widowBHElbow[0]));
      zLabel.setText("Elbow");
      arrayCopy(widowBHElbow, zParameters);
  
      wristAngleSlider.setLimits(widowBHWristAngle[0], widowBHWristAngle[1], widowBHWristAngle[2]); 
      wristAngleTextField.setText(Integer.toString(widowBHWristAngle[0]));
      wristAngleLabel.setText("Wrist Angle");
      arrayCopy(widowBHWristAngle, wristAngleParameters);
  
      wristRotateSlider.setLimits(widowBHWristRot[0], widowBHWristRot[1], widowBHWristRot[2]) ;   
      wristRotateTextField.setText(Integer.toString(widowBHWristRot[0]));
      wristRotateLabel.setText("Wrist Rotate");
      arrayCopy(widowBHWristRot, wristRotateParameters);
      wristRotateSlider.setVisible(false);
      wristRotateTextField.setVisible(true);
      wristRotateLabel.setVisible(true);
  
  
      gripperSlider.setLimits( widowGripper[0], widowGripper[1], widowGripper[2]);    
      gripperTextField.setText(Integer.toString(widowGripper[0]));
      gripperLabel.setText("Gripper");
      arrayCopy(widowGripper, gripperParameters);
      break;
    }
  break;//end widow arm
}

  //write defualt parameters back to internal values
  xCurrent = xParameters[0]; 
  yCurrent = yParameters[0]; 
  zCurrent = zParameters[0]; 
  wristAngleCurrent = wristAngleParameters[0];
  wristRotateCurrent = wristRotateParameters[0]; 
  gripperCurrent = gripperParameters[0]; 
  deltaCurrent = deltaParameters[0]; 
  extendedTextField.setText("0");

}//end set postiion parameters



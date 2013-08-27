// Variable declarations 
GDropList serialList; 
GButton connectButton; 
GButton helpButton; 
GButton disconnectButton; 
GButton autoConnectButton; 
GPanel setupPanel; 
GPanel controlPanel; 
GPanel modePanel; 
GTextField xTextField; 
GSlider xSlider; 
GTextField wristRotateTextField; 
GTextField wristAngleTextField; 
GTextField zTextField; 
GTextField gripperTextField; 
GTextField yTextField; 
GTextField deltaTextField; 
GTextField extendedTextField; 
GLabel xLabel; 
//GDropList extendedList; 
GLabel deltaLabel; 
GLabel gripperLabel; 
GLabel wristRotateLabel; 
GLabel wristAngleLabel; 
GLabel zLabel; 
GLabel yLabel; 
GLabel extendedLabel; 
GSlider ySlider; 
GSlider wristRotateSlider; 
GSlider deltaSlider; 
GSlider gripperSlider; 
GSlider wristAngleSlider; 
GSlider zSlider; 
GButton cartesianModeButton; 
GButton cylindricalModeButton; 
GButton backhoeModeButton; 
GButton updateButton; 
PImage logoImg;
PImage footerImg;
GLabel digitalsLabel;
GCheckbox digitalCheckbox0; 
GCheckbox digitalCheckbox1; 
GCheckbox digitalCheckbox2; 
GCheckbox digitalCheckbox3; 
GCheckbox digitalCheckbox4; 
GCheckbox digitalCheckbox5; 
GCheckbox digitalCheckbox6; 
GCheckbox digitalCheckbox7; 
GCheckbox autoUpdateCheckbox; 
GImageButton armStraightButton;
GImageButton arm90Button;
GImageButton waitingButton;



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
  printlnDebug("connectButton - GButton event occured " + System.currentTimeMillis()%10000000,1);
  
  //check to make sure serialPortSelected is not -1, -1 means no serial port was selected. Valid port indexes are 0+
  if(selectedSerialPort > -1)
  {    
    println("test");
    //try to connect to the port at 38400bps, otherwise show an error message
    try
    {
      sPort = new Serial(this, Serial.list()[selectedSerialPort], 38400);
    }
    catch(Exception e)
    {
      printlnDebug("Error Opening Serial Port"+serialList.getSelectedText());
      sPort = null;
      /*******************
       *ERROR PANEL
       * Please see webpage here for info 
       *
      errorText.setText("Error Connecting to Port - try a different port or try closing other applications using the current port");    
       ***********************/  
    }     
  }
  
  //check to see if the serial port connection has been made
  if (sPort != null)
  {
    
    //try to communicate with arm
    if(checkArmStartup() == true)
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
      /*******************
       *ERROR PANEL
       *
       *
      errorText.setText("Error Connecting to Port - try a different port or try closing other applications using the current port");    
       ***********************/  
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
   
   currentMode = 0;
   currentArm = 0;
   currentOrientation = 0;
   
   
  cartesianModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  cylindricalModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  backhoeModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  
  armStraightButton.setAlpha(128);
  arm90Button.setAlpha(128);
   
   
} 



//scan each serial port and querythe port for an active arm. Iterate through each port until a 
//port is found or the list is exhausted
public void autoConnectButton_click(GButton source, GEvent event) 
{
    printlnDebug("autoConnectButton - GButton event occured " + System.currentTimeMillis()%10000000,1 );
  

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
           
        /*******************
         *ERROR PANEL
         *
         *
        errorText.setText("Error Connecting to Port - try a different port or try closing other applications using the current port");    
         ***********************/  
      }
      
      //delayMs(100);//delay for some systems
 
  
      //check to see if the serial port connection has been made       
      if(sPort !=null)
      {
       
        
        //try to communicate with arm
        if(checkArmStartup() == true)
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
            
          /*******************
           *ERROR PANEL
           *
           *
          errorText.setText("Error Connecting to Port - try a different port or try closing other applications using the current port");    
           ***********************/  
        }


      }
    }//end interating through serial list
    
    //id sPort is null, not port was found. Set GUI elements appropriatley.
    if(sPort == null)
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
      
    }
 
  
  
  
}



//send user to documentation
//TODO: Help panel with links and debug option
public void helpButton_click(GButton source, GEvent event) 
{ 
  link("http://learn.trossenrobotics.com/");
}

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
  for(int i = 0; i < textFieldString.length(); i++)
    {
      //get single character and check if it is not a digit
      //in non digit character is found, return text field to previous value
      //otherwise continue
      printDebug(textFieldString.charAt(i) + " ",1 );
      if (!Character.isDigit(textFieldString.charAt(i)))
      {
        //'-' character is used for negative numbers, so check that the current character is not '-'
        //otherwise continue 
        if(textFieldString.charAt(i) != '-')
        {
           printlnDebug("Non Numeric Character in Textfield, reverting value",1 );
          source.setText(Integer.toString(currentVal));//set string to global xCurrent Value, last known good value  
           return(currentVal); 
          //TODO: alternativeley the program could remove the offending character and write the string back
        }
        
      }
    }
   printlnDebug("",1 );
    
  //only write value to slider/global if the enter key is pressed or focus is lost on the text field
  if(event == GEvent.ENTERED | event == GEvent.LOST_FOCUS)
  {
    textFieldValue = int(textFieldString);//take String from text field and conver it to an int
    
    //check if the value is over the global max for this field - if so, set the textField value to the maximum value
    if(textFieldValue > maxVal)
    {
       source.setText(Integer.toString(maxVal));//append a "" for easy string conversion 
       textFieldValue = maxVal;    
    }
    
    //check if the value is under the global min for this field - if so, set the textField value to the minimum value
    if(textFieldValue < minVal)
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
  printlnDebug("xTextField_change - GTextField event occured " + System.currentTimeMillis()%10000000,1 );
  xCurrent = armTextFieldChange(source, event, xSlider, xParameters[1], xParameters[2], xCurrent);
}

public void yTextField_change(GTextField source, GEvent event) 
{
  printlnDebug("yTextField_change - GTextField event occured " + System.currentTimeMillis()%10000000,1 );
  yCurrent = armTextFieldChange(source, event, ySlider, yParameters[1], yParameters[2], yCurrent);
}

public void zTextField_change(GTextField source, GEvent event) 
{
  printlnDebug("zTextField_change - GTextField event occured " + System.currentTimeMillis()%10000000,1 );
  zCurrent = armTextFieldChange(source, event, zSlider, zParameters[1], zParameters[2], zCurrent);
}

public void wristAngleTextField_change(GTextField source, GEvent event) 
{
  printlnDebug("wristAngleTextField_change - GTextField event occured " + System.currentTimeMillis()%10000000,1 );
  wristAngleCurrent = armTextFieldChange(source, event, wristAngleSlider, wristAngleParameters[1], wristAngleParameters[2], wristAngleCurrent);
}

public void wristRotateTextField_change(GTextField source, GEvent event) 
{
  printlnDebug("wristRotateTextField_change - GTextField event occured " + System.currentTimeMillis()%10000000,1 );
  wristRotateCurrent = armTextFieldChange(source, event,  wristRotateSlider,  wristRotateParameters[1],  wristRotateParameters[2],  wristRotateCurrent);
}

public void gripperTextField_change(GTextField source, GEvent event) 
{
  printlnDebug("gripperTextField_change - GTextField event occured " + System.currentTimeMillis()%10000000,1 );
  gripperCurrent = armTextFieldChange(source, event, gripperSlider, gripperParameters[1], gripperParameters[2], gripperCurrent);
}


public void deltaTextField_change(GTextField source, GEvent event) 
{
  printlnDebug("gripperTextField_change - GTextField event occured " + System.currentTimeMillis()%10000000,1 );
  gripperCurrent = armTextFieldChange(source, event, deltaSlider, deltaParameters[1], deltaParameters[2],deltaCurrent);
}




public void extendedTextField_change(GTextField source, GEvent event) 
{
  printlnDebug("extendedTextField_change - GDropList event occured " + System.currentTimeMillis()%10000000,1 );
  String textFieldString = source.getText();//string value from textField
  int textFieldValue = 0;//converted integer from textField

  //parse through each character in the string to make sure that it is a digit
  for(int i = 0; i < textFieldString.length(); i++)
    {
      //get single character and check if it is not a digit
      //in non digit character is found, return text field to previous value
      //otherwise continue
      //printlnDebug(textFieldString.charAt(i));
      if (!Character.isDigit(textFieldString.charAt(i)))
      {
        //'-' character is used for negative numbers, so check that the current character is not '-'
        //otherwise continue 
        if(textFieldString.charAt(i) != '-')
        {
          source.setText(Integer.toString(extendedByte));//set string to global xCurrent Value, last known good value  
          //TODO: alternativeley the program could remove the offending character and write the string back
        }
      }
    }
    
  //only write value to global if enter key is pressed or lose focus on fieles
  if(event == GEvent.ENTERED | event == GEvent.LOST_FOCUS)
  {
    printlnDebug("Change Extended Byte");
    extendedByte = int(textFieldString);//take String from text field and conver it to an int
    
    //check if the value is over the global max for this field - if so, set the textField value to the maximum value
    if(extendedByte > 255)
    {
       source.setText(Integer.toString(255));//append a "" for easy string conversion 
       extendedByte = 255;    
    }
    
    //check if the value is under the global min for this field - if so, set the textField value to the minimum value
    if(extendedByte < 0)
    {
       source.setText(Integer.toString(0));//append a "" for easy string conversion      
       extendedByte = 0;    
    }
    
    
  }
  
  
  
    
}



public void xSlider_change(GSlider source, GEvent event) 
{
  printlnDebug("xSlider_change - GSlider event occured " + System.currentTimeMillis()%10000000,1 );
  if(event == GEvent.VALUE_STEADY)
  {
    xTextField.setText(Integer.toString(source.getValueI()));//append a "" for easy string conversion
    xCurrent = source.getValueI();
  }
  
}

public void ySlider_change(GSlider source, GEvent event) 
{
  printlnDebug("ySlider_change - GSlider event occured " + System.currentTimeMillis()%10000000,1 );
  if(event == GEvent.VALUE_STEADY)
  {
    yTextField.setText(Integer.toString(source.getValueI()));//append a "" for easy string conversion 
    yCurrent = source.getValueI();
  }
  
}

public void zSlider_change(GSlider source, GEvent event) 
{
  printlnDebug("zSlider_change - GSlider event occured " + System.currentTimeMillis()%10000000,1 );
  if(event == GEvent.VALUE_STEADY)
  {
    zTextField.setText(Integer.toString(source.getValueI()));//append a "" for easy string conversion 
    zCurrent = source.getValueI();
  }
  
}

public void wristAngleSlider_change(GSlider source, GEvent event) 
{
  printlnDebug("wristAngleSlider_change - GSlider event occured " + System.currentTimeMillis()%10000000,1 );
  if(event == GEvent.VALUE_STEADY)
  {
    wristAngleTextField.setText(Integer.toString(source.getValueI()));//append a "" for easy string conversion 
     wristAngleCurrent = source.getValueI();
  }
  
}

public void wristRotateSlider_change(GSlider source, GEvent event) 
{
  printlnDebug("wristRotateSlider_change - GSlider event occured " + System.currentTimeMillis()%10000000,1 );
  if(event == GEvent.VALUE_STEADY)
  {
    wristRotateTextField.setText(Integer.toString(source.getValueI()));//append a "" for easy string conversion 
    wristRotateCurrent = source.getValueI();
  }
  
}

public void gripperSlider_change(GSlider source, GEvent event) 
{
  printlnDebug("gripperSlider_change - GSlider event occured " + System.currentTimeMillis()%10000000,1 );
  if(event == GEvent.VALUE_STEADY)
  {
    gripperTextField.setText(Integer.toString(source.getValueI()));//append a "" for easy string conversion 
    gripperCurrent = source.getValueI();
  }
  
}

public void deltaSlider_change(GSlider source, GEvent event) 
{
  printlnDebug("deltaSliderChange - GSlider event occured " + System.currentTimeMillis()%10000000,1 );
  if(event == GEvent.VALUE_STEADY)
  {
    deltaTextField.setText(Integer.toString(source.getValueI())); 
    deltaCurrent = source.getValueI();
  }
  
}




public void cartesianModeButton_click(GButton source, GEvent event) { //_CODE_:cartesianModeButton:383064:
  println("cartesianModeButton - GButton event occured " + System.currentTimeMillis()%10000000 );
  
  source.setLocalColorScheme(GCScheme.GOLD_SCHEME);
  cylindricalModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  backhoeModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  
  if(currentOrientation == 0)
  {
    currentOrientation =1;
  }
  
  if(currentOrientation == 1)
  {
  armStraightButton.setAlpha(255);
  arm90Button.setAlpha(128);
  }
  else  
  {
  armStraightButton.setAlpha(128);
  arm90Button.setAlpha(255);
  }
  
   
  currentMode = 1;
  setPositionParameters();
  changeArmMode();
} //_CODE_:cartesianModeButton:383064:

public void cylindricalModeButton_click(GButton source, GEvent event) { //_CODE_:cylindricalModeButton:547200:
  println("cylindricalModeButton - GButton event occured " + System.currentTimeMillis()%10000000 );
  
  source.setLocalColorScheme(GCScheme.GOLD_SCHEME);
  cartesianModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  backhoeModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  
  if(currentOrientation == 0)
  {
    currentOrientation =1;
  }
  
  if(currentOrientation == 1)
  {
  armStraightButton.setAlpha(255);
  arm90Button.setAlpha(128);
  }
  else  
  {
  armStraightButton.setAlpha(128);
  arm90Button.setAlpha(255);
  }
  
  
  
  currentMode = 2;
  setPositionParameters();
  changeArmMode();
} //_CODE_:cylindricalModeButton:547200:

public void backhoeModeButton_click(GButton source, GEvent event) { //_CODE_:backhoeModeButton:347353:
  println("backhoeModeButton - GButton event occured " + System.currentTimeMillis()%10000000 );
  
  source.setLocalColorScheme(GCScheme.GOLD_SCHEME);
  cylindricalModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  cartesianModeButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  
  
  armStraightButton.setAlpha(128);
  arm90Button.setAlpha(128);
  
  currentMode = 3;
  setPositionParameters();
  changeArmMode();
} //_CODE_:backhoeModeButton:347353:

public void updateButton_click(GButton source, GEvent event) 
{
  printlnDebug("backhoeModeButton - GButton event occured " + System.currentTimeMillis()%10000000,1 );
  updateFlag = true;
updateOffsetCoordinates();
  
        printlnDebug("X:"+xCurrentOffset+" Y:"+yCurrentOffset+" Z:"+zCurrentOffset+" Wrist Angle:"+wristAngleCurrentOffset+" Wrist Rotate:"+wristRotateCurrentOffset+" Gripper:"+gripperCurrentOffset+" Delta:"+deltaCurrentOffset);

}


public void autoUpdateCheckbox_change(GCheckbox source, GEvent event)
{ 

  printlnDebug("autoUpdateCheckbox_change - GCheckbox event occured " + System.currentTimeMillis()%10000000,1 );
  
  updateFlag = source.isSelected();//set the updateFlag to the current state of the autoUpdate checkbox
} 



public void digitalCheckbox0_change(GCheckbox source, GEvent event) 
{
  printlnDebug("digitalCheckbox0 - GCheckbox event occured " + System.currentTimeMillis()%10000000,1 );
  
  digitalButtons[0] = source.isSelected();//set the current array item for the corresponding digital output to the current state of the checkbox

} 


public void digitalCheckbox1_change(GCheckbox source, GEvent event) 
{ 
  printlnDebug("digitalCheckbox1 - GCheckbox event occured " + System.currentTimeMillis()%10000000,1 );
  digitalButtons[1] = source.isSelected();//set the current array item for the corresponding digital output to the current state of the checkbox

} 
public void digitalCheckbox2_change(GCheckbox source, GEvent event) 
{
  printlnDebug("digitalCheckbox2 - GCheckbox event occured " + System.currentTimeMillis()%10000000,1 );
  digitalButtons[2] = source.isSelected();//set the current array item for the corresponding digital output to the current state of the checkbox

} 


public void digitalCheckbox3_change(GCheckbox source, GEvent event) 
{ 
  printlnDebug("digitalCheckbox3 - GCheckbox event occured " + System.currentTimeMillis()%10000000,1 );
  digitalButtons[3] = source.isSelected();//set the current array item for the corresponding digital output to the current state of the checkbox

}


public void digitalCheckbox4_change(GCheckbox source, GEvent event) 
{ 
  printlnDebug("digitalCheckbox4 - GCheckbox event occured " + System.currentTimeMillis()%10000000,1 );
  digitalButtons[4] = source.isSelected();//set the current array item for the corresponding digital output to the current state of the checkbox

} 


public void digitalCheckbox5_change(GCheckbox source, GEvent event) 
{ 
  printlnDebug("digitalCheckbox5 - GCheckbox event occured " + System.currentTimeMillis()%10000000,1 );
  digitalButtons[5] = source.isSelected();//set the current array item for the corresponding digital output to the current state of the checkbox

} 


public void digitalCheckbox6_change(GCheckbox source, GEvent event) 
{
  printlnDebug("digitalCheckbox6 - GCheckbox event occured " + System.currentTimeMillis()%10000000,1 );
  digitalButtons[6] = source.isSelected();//set the current array item for the corresponding digital output to the current state of the checkbox

} 


public void digitalCheckbox7_change(GCheckbox source, GEvent event) 
{
  printlnDebug("digitalCheckbox7 - GCheckbox event occured " + System.currentTimeMillis()%10000000,1 );
  digitalButtons[7] = source.isSelected();//set the current array item for the corresponding digital output to the current state of the checkbox

} 



public void armStraightButton_click(GImageButton source, GEvent event) { //_CODE_:digitalCheckbox1:676831:
  println("armstraught - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
  
  
  if(currentMode == 0)
  {
    currentMode =1;
    cartesianModeButton.setLocalColorScheme(GCScheme.GOLD_SCHEME);
   
  }
  
  armStraightButton.setAlpha(255);
   arm90Button.setAlpha(128);
  
  currentOrientation = 1;
  setPositionParameters();
  changeArmMode();
} //_CODE_:digitalCheckbox1:676831:

public void arm90Button_click(GImageButton source, GEvent event) { //_CODE_:digitalCheckbox1:676831:
  println("arm90 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
  
  if(currentMode == 0)
  {
    currentMode =1;
    cartesianModeButton.setLocalColorScheme(GCScheme.GOLD_SCHEME);
  }
  
  armStraightButton.setAlpha(128);
   arm90Button.setAlpha(255);
  
  currentOrientation = 2;
  setPositionParameters();
  changeArmMode();
} //_CODE_:digitalCheckbox1:676831:



public void controlPanel_click(GPanel source, GEvent event) { //_CODE_:controlPanel:613752:
  println("controlPanel - GPanel event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:controlPanel:613752:


public void setupPanel_click(GPanel source, GEvent event) { 
  println("setupPanel - GPanel event occured " + System.currentTimeMillis()%10000000 );
} 

public void modePanel_click(GPanel source, GEvent event) { 
  println("modePanel - GPanel event occured " + System.currentTimeMillis()%10000000 );
} 

// Create all the GUI controls. 
// autogenerated do not edit
public void createGUI(){
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setCursor(ARROW);
  
  
  if(frame != null)
    frame.setTitle("InterbotiX Arm Control");
    
    
  serialList = new GDropList(this, 5, 24, 160, 132, 6);
  serialList.setItems(loadStrings("list_700876"), 0);
  serialList.addEventHandler(this, "serialList_click");
  
  serialList.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  
  connectButton = new GButton(this, 5, 47, 75, 20);
  connectButton.setText("Connect");
  connectButton.addEventHandler(this, "connectButton_click");
  
  disconnectButton = new GButton(this, 90, 47, 75, 20);
  disconnectButton.setText("Disconnect");
  disconnectButton.addEventHandler(this, "disconnectButton_click");
  
  helpButton = new GButton(this, 10, 750, 40, 20);
  helpButton.setText("Help");
  helpButton.setLocalColorScheme(GCScheme.GOLD_SCHEME);
  helpButton.addEventHandler(this, "helpButton_click");
  
  
  autoConnectButton = new GButton(this, 170, 24, 55, 43);
  autoConnectButton.setText("Auto Search");
  autoConnectButton.addEventHandler(this, "autoConnectButton_click");
  
  setupPanel = new GPanel(this, 5, 83, 240, 75, "Setup Panel");
  setupPanel.setText("Setup Panel");
  setupPanel.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  setupPanel.setOpaque(true);
  setupPanel.addEventHandler(this, "setupPanel_click");
  
  
  modePanel = new GPanel(this, 5, 163, 240, 110, "Mode Panel");
  modePanel.setText("Mode Panel");
  modePanel.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  modePanel.setOpaque(true);
  modePanel.addEventHandler(this, "modePanel_click");
  
  
  controlPanel = new GPanel(this, 5, 280, 240, 480, "Control Panel");
  controlPanel.setText("Control Panel");
  controlPanel.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  controlPanel.setOpaque(true);
  controlPanel.addEventHandler(this, "controlPanel_click");
  
  
  
  
  
  
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
  
  
  
  xTextField = new GTextField(this, 5, 30, 60, 20, G4P.SCROLLBARS_NONE);
  //xTextField.setText("0");
  xTextField.setText(Integer.toString(xParameters[0]));
  xTextField.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  xTextField.setOpaque(true);
  xTextField.addEventHandler(this, "xTextField_change");
  
  xSlider = new GSlider(this, 75, 20, 145, 40, 10.0);
  xSlider.setShowLimits(true);
  xSlider.setLimits(0.0, -200.0, 200.0);
  xSlider.setNbrTicks(50);
  xSlider.setEasing(0.0);
  xSlider.setNumberFormat(G4P.INTEGER, 0);
  xSlider.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  xSlider.setOpaque(false);
  xSlider.addEventHandler(this, "xSlider_change");
  xSlider.setShowValue(true);
  
  
  xLabel = new GLabel(this, 5, 50, 60, 14);
  xLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  xLabel.setText("X Coord");
  xLabel.setOpaque(false);
  
  
  yTextField = new GTextField(this, 5, 75, 60, 20, G4P.SCROLLBARS_NONE);
  yTextField.setText(Integer.toString(yParameters[0]));
  yTextField.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  yTextField.setOpaque(true);
  yTextField.addEventHandler(this, "yTextField_change");
  
  
  ySlider = new GSlider(this, 75, 65, 145, 40, 10.0);
  ySlider.setShowLimits(true);
  ySlider.setLimits(200.0, 50.0, 240.0);
  ySlider.setEasing(0.0);
  ySlider.setNumberFormat(G4P.INTEGER, 0);
  ySlider.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  ySlider.setOpaque(false);
  ySlider.addEventHandler(this, "ySlider_change");
  ySlider.setShowValue(true);
    
  yLabel = new GLabel(this, 5, 95, 60, 14);
  yLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  yLabel.setText("Y Coord");
  yLabel.setOpaque(false);
  
  
  
  zTextField = new GTextField(this, 5, 120, 60, 20, G4P.SCROLLBARS_NONE);
  zTextField.setText(Integer.toString(zParameters[0]));
  zTextField.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  zTextField.setOpaque(true);
  zTextField.addEventHandler(this, "zTextField_change");
  
 
  zSlider = new GSlider(this, 75, 110, 145, 40, 10.0);
  zSlider.setShowLimits(true);
  zSlider.setLimits(200.0, 20.0, 250.0);
  zSlider.setEasing(0.0);
  zSlider.setNumberFormat(G4P.INTEGER, 0);
  zSlider.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  zSlider.setOpaque(false);
  zSlider.addEventHandler(this, "zSlider_change"); 
  zSlider.setShowValue(true);
    
  
  zLabel = new GLabel(this, 5, 140, 60, 14);
  zLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  zLabel.setText("Z Coord");
  zLabel.setOpaque(false);
  
 
  wristAngleTextField = new GTextField(this, 5, 165, 60, 20, G4P.SCROLLBARS_NONE);
  wristAngleTextField.setText(Integer.toString(wristAngleParameters[0]));
  wristAngleTextField.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  wristAngleTextField.setOpaque(true);
  wristAngleTextField.addEventHandler(this, "wristAngleTextField_change");
  
  
  wristAngleSlider = new GSlider(this, 75, 155, 145, 40, 10.0);
  wristAngleSlider.setShowLimits(true);
  wristAngleSlider.setLimits(0.0, -90.0, 90.0);
  wristAngleSlider.setEasing(0.0);
  wristAngleSlider.setNumberFormat(G4P.INTEGER, 0);
  wristAngleSlider.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  wristAngleSlider.setOpaque(false);
  wristAngleSlider.addEventHandler(this, "wristAngleSlider_change");
  wristAngleSlider.setShowValue(true);
  
  wristAngleLabel = new GLabel(this, 5, 185, 70, 14);
  wristAngleLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  wristAngleLabel.setText("Wrist Angle");
  wristAngleLabel.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  wristAngleLabel.setOpaque(false);
  
  
  
  
  
  wristRotateTextField = new GTextField(this, 5, 210, 60, 20, G4P.SCROLLBARS_NONE);
  wristRotateTextField.setText(Integer.toString( wristRotateParameters[0]));
  wristRotateTextField.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  wristRotateTextField.setOpaque(true);
  wristRotateTextField.addEventHandler(this, "wristRotateTextField_change");
  
  wristRotateSlider = new GSlider(this, 75, 200, 145, 40, 10.0);
  wristRotateSlider.setShowLimits(true);
  wristRotateSlider.setLimits(0.0, -512.0, 512.0);
  wristRotateSlider.setEasing(0.0);
  wristRotateSlider.setNumberFormat(G4P.INTEGER, 0);
  wristRotateSlider.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  wristRotateSlider.setOpaque(false);
  wristRotateSlider.addEventHandler(this, "wristRotateSlider_change");
  wristRotateSlider.setShowValue(true);
  
  
  wristRotateLabel = new GLabel(this, 5, 230, 70, 14);
  wristRotateLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  wristRotateLabel.setText("Wrist Rotate");
  wristRotateLabel.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  wristRotateLabel.setOpaque(false);
  
  gripperTextField = new GTextField(this, 5, 255, 60, 20, G4P.SCROLLBARS_NONE);
  gripperTextField.setText(Integer.toString(gripperParameters[0]));
  gripperTextField.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  gripperTextField.setOpaque(true);
  gripperTextField.addEventHandler(this, "gripperTextField_change");
  
  gripperSlider = new GSlider(this, 75, 245, 145, 40, 10.0);
  gripperSlider.setShowLimits(true);
  gripperSlider.setLimits(256.0, 0.0, 512.0);
  gripperSlider.setEasing(0.0);
  gripperSlider.setNumberFormat(G4P.INTEGER, 0);
  gripperSlider.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  gripperSlider.setOpaque(false);
  gripperSlider.addEventHandler(this, "gripperSlider_change");
  gripperSlider.setShowValue(true);
  
  
  gripperLabel = new GLabel(this, 5, 275, 60, 14);
  gripperLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  gripperLabel.setText("Gripper");
  gripperLabel.setOpaque(false);
  
  
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
  
  

   
  digitalsLabel = new GLabel(this,5, 400, 100, 14);
  digitalsLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  digitalsLabel.setText("Digital Values");
  digitalsLabel.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  digitalsLabel.setOpaque(false);
  
  
  updateButton = new GButton(this, 5, 425, 100, 50);
  updateButton.setText("Update");
  updateButton.addEventHandler(this, "updateButton_click");
  updateButton.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  
  
  autoUpdateCheckbox = new GCheckbox(this, 105, 459, 100, 20);
  autoUpdateCheckbox.setOpaque(false);
  autoUpdateCheckbox.addEventHandler(this, "autoUpdateCheckbox_change");
  autoUpdateCheckbox.setText("Auto Update");
  
  
  armStraightButton = new GImageButton(this, 5, 40, 100, 65, new String[] { "armStraightm.png", "armStraightm.png", "armStraightm.png" } );
  armStraightButton.addEventHandler(this, "armStraightButton_click");
  armStraightButton.setAlpha(128);
  
  
  
  
  arm90Button = new GImageButton(this, 130, 40, 100, 65, new String[] { "arm90m.png", "arm90m.png", "arm90m.png" } );
  arm90Button.addEventHandler(this, "arm90Button_click");
  arm90Button.setAlpha(128);
  
  
  waitingButton = new GImageButton(this, 115, 408, 100, 30, new String[] { "moving.jpg", "moving.jpg", "moving.jpg" } );
  waitingButton.setAlpha(0);
  
  
  setupPanel.addControl(serialList);
  setupPanel.addControl(connectButton);
  setupPanel.addControl(disconnectButton);
  setupPanel.addControl(autoConnectButton);
  
  
  
  modePanel.addControl(cartesianModeButton);
  modePanel.addControl(cylindricalModeButton);
  modePanel.addControl(backhoeModeButton);
  modePanel.addControl(arm90Button);
  modePanel.addControl(armStraightButton);
  
  
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
  controlPanel.addControl(waitingButton);
  
  
  
 
  logoImg = loadImage("logo.png");  // Load the image into the program  
  footerImg = loadImage("footer.png");  // Load the image into the program  
  
  
  controlPanel.setVisible(false);
  controlPanel.setEnabled(false);
  
  modePanel.setVisible(false);
  modePanel.setEnabled(false);
  
  disconnectButton.setEnabled(false);
  disconnectButton.setAlpha(128);
  
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
  
  extendedTextField.setText("0");
  
  
}//end set postiion parameters




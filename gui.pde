/* =========================================================
 * ====                   WARNING                        ===
 * =========================================================
 * The code in this tab has been generated from the GUI form
 * designer and care should be taken when editing this file.
 * Only add/edit code inside the event handlers i.e. only
 * use lines between the matching comment tags. e.g.

 void myBtnEvents(GButton button) { //_CODE_:cartesianModeButton:12356:
     // It is safe to enter your event code here  
 } //_CODE_:cartesianModeButton:12356:
 
 * Do not rename this tab!
 * =========================================================
 */


//Called when a new serial port is selected
public void serialList_click(GDropList source, GEvent event) 
{
  printlnDebug("serialList - GDropList event occured: item #" + serialList.getSelectedIndex() + " " + System.currentTimeMillis()%10000000, 1 );
 
 
  selectedSerialPort = serialList.getSelectedIndex()-1; //set the current selectSerialPort corresponding to the serial port selected in the menu. Subtract 1 to offset for the fact that the first item in the list is a placeholder text/title 'Select Serial Port'
    
} 

public void connectButton_click(GButton source, GEvent event) 
{
  printlnDebug("connectButton - GButton event occured " + System.currentTimeMillis()%10000000,1);
  
  //check to make sure serialPortSelected is not -1, -1 means no serial port was selected. Valid port indexes are 0+
  if(selectedSerialPort > 0)
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
      /*******************
       *ERROR PANEL
       *
       *
      errorText.setText("Error Connecting to Port - try a different port or try closing other applications using the current port");    
       ***********************/  
    }     
  }
  
  //check to see if the serial port connection has been made
  if (sPort != null)
  {
    //disable connect button and serial list
     connectButton.setEnabled(false);
     serialList.setEnabled(false);
     //enable disconnect button
     disconnectButton.setEnabled(true);
    
    //try to communicate with arm
    if(checkArmStartup() == true)
    {
      //enable & set visible control and mode panel
      modePanel.setVisible(true);
      modePanel.setEnabled(true);
      controlPanel.setVisible(true);
      controlPanel.setEnabled(true);
      
    }
    
    //if arm is not found return an error
    else  
    {
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
   serialList.setEnabled(true);
   
   //disable disconnect button
   disconnectButton.setEnabled(false);
   
   //disable & set invisible control and mode panel
   controlPanel.setVisible(false);
   controlPanel.setEnabled(false);    
   modePanel.setVisible(false);
   modePanel.setEnabled(false);
} 



//scan each serial port and querythe port for an active arm. Iterate through each port until a 
//port is found or the list is exhausted
public void autoConnectButton_click(GButton source, GEvent event) 
{
    printlnDebug("autoConnectButton - GButton event occured " + System.currentTimeMillis()%10000000,1 );
  
   //disable connect/disconnect buttons and serial list
   connectButton.setEnabled(false);
   serialList.setEnabled(false);
   disconnectButton.setEnabled(false);

    //for (int i=0;i<Serial.list().length;i++) //scan from bottom to top
    //scan from the top of the list to the bottom, for most users the ArbotiX will be the most recently added ftdi device
    for (int i=Serial.list().length-1;i>=0;i--) 
    {
      serialList.setSelected(i+1);
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
      printlnDebug("END AUTO SEARCH No Arm Found from auto search");
      //enable connect button and serial port 
      connectButton.setEnabled(true);
      serialList.setEnabled(true);
       
      //disable disconnect button
      disconnectButton.setEnabled(false);
      
    }
 
  
  
  
}



//send user to documentation
//TODO: Help panel with links and debug option
public void helpButton_click(GButton source, GEvent event) 
{ 
 
  setPositionParameters();
  
  setPositionParameters();
  sendCommanderPacket(512, 200, 200, 90, 512, 256, 128, 0, 0);
  
  // printlnDebug("helpButton - GButton event occured " + System.currentTimeMillis()%10000000, 1 );
 
// sendCommanderPacket(0, 200, 200, 0, 512, 256, 128, 0, 128);

// sendCommanderPacket(0, 200, 200, 0, 512, 256, 128, 0, 80);

// sendCommanderPacket(0, 200, 200, 0, 512, 256, 128, 0, 128);


  
  //link("http://learn.trossenrobotics.com/");
}




public void controlPanel_click(GPanel source, GEvent event) { //_CODE_:controlPanel:613752:
  println("controlPanel - GPanel event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:controlPanel:613752:


public void setupPanel_click(GPanel source, GEvent event) { 
  println("setupPanel - GPanel event occured " + System.currentTimeMillis()%10000000 );
} 

public void modePanel_click(GPanel source, GEvent event) { 
  println("modePanel - GPanel event occured " + System.currentTimeMillis()%10000000 );
} 

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
      println(textFieldString.charAt(i));
      if (!Character.isDigit(textFieldString.charAt(i)))
      {
        //'-' character is used for negative numbers, so check that the current character is not '-'
        //otherwise continue 
        if(textFieldString.charAt(i) != '-')
        {
          source.setText(Integer.toString(currentVal));//set string to global xCurrent Value, last known good value  
          //TODO: alternativeley the program could remove the offending character and write the string back
        }
      }
    }
    
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
  else
  {
   printlnDebug("Non Numeric Character in Textfield ",1 );
   return(currentVal); 
  }
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

public void deltaSliderChange(GSlider source, GEvent event) 
{
  printlnDebug("deltaSliderChange - GSlider event occured " + System.currentTimeMillis()%10000000,1 );
  if(event == GEvent.VALUE_STEADY)
  {
    deltaTextField.setText(Integer.toString(source.getValueI()));//append a "" for easy string conversion 
    deltaCurrent = source.getValueI();
  }
  
}




public void extendedList_click(GDropList source, GEvent event) { //_CODE_:extendedList:893307:
  println("dropList2 - GDropList event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:extendedList:893307:



public void cartesianModeButton_click(GButton source, GEvent event) { //_CODE_:cartesianModeButton:383064:
  println("cartesianModeButton - GButton event occured " + System.currentTimeMillis()%10000000 );
  currentMode = 1;
  setPositionParameters();
  changeArmMode();
} //_CODE_:cartesianModeButton:383064:

public void cylindricalModeButton_click(GButton source, GEvent event) { //_CODE_:cylindricalModeButton:547200:
  println("cylindricalModeButton - GButton event occured " + System.currentTimeMillis()%10000000 );
  currentMode = 2;
  setPositionParameters();
  changeArmMode();
} //_CODE_:cylindricalModeButton:547200:

public void backhoeModeButton_click(GButton source, GEvent event) { //_CODE_:backhoeModeButton:347353:
  println("backhoeModeButton - GButton event occured " + System.currentTimeMillis()%10000000 );
  currentMode = 3;
  setPositionParameters();
  changeArmMode();
} //_CODE_:backhoeModeButton:347353:

public void updateButton_click(GButton source, GEvent event) 
{
  printlnDebug("backhoeModeButton - GButton event occured " + System.currentTimeMillis()%10000000,1 );
  updateFlag = true;
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
  
        printlnDebug("X:"+xCurrentCommander+" Y:"+yCurrentCommander+" Z:"+zCurrentCommander+" Wrist Angle:"+wristAngleCurrentCommander+" Wrist Rotate:"+wristRotateCurrentCommander+" Gripper:"+gripperCurrentCommander+" Delta:"+deltaCurrentCommander);

}


public void autoUpdateCheckbox_change(GCheckbox source, GEvent event)
{ 

  printlnDebug("digitalCheckbox7 - GCheckbox event occured " + System.currentTimeMillis()%10000000,3 );
  
  autoUpdateFlag = source.isSelected();
  println(autoUpdateFlag);
} 



public void digitalCheckbox0_change(GCheckbox source, GEvent event) { //_CODE_:digitalCheckbox1:676831:
  println("digitalCheckbox0 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:digitalCheckbox1:676831:

public void digitalCheckbox1_change(GCheckbox source, GEvent event) { //_CODE_:digitalCheckbox1:676831:
  println("digitalCheckbox1 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:digitalCheckbox1:676831:

public void digitalCheckbox2_change(GCheckbox source, GEvent event) { //_CODE_:digitalCheckbox1:676831:
  println("digitalCheckbox2 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:digitalCheckbox1:676831:


public void digitalCheckbox3_change(GCheckbox source, GEvent event) { //_CODE_:digitalCheckbox1:676831:
  println("digitalCheckbox3 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:digitalCheckbox1:676831:


public void digitalCheckbox4_change(GCheckbox source, GEvent event) { //_CODE_:digitalCheckbox1:676831:
  println("digitalCheckbox4 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:digitalCheckbox1:676831:


public void digitalCheckbox5_change(GCheckbox source, GEvent event) { //_CODE_:digitalCheckbox1:676831:
  println("digitalCheckbox5 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:digitalCheckbox1:676831:


public void digitalCheckbox6_change(GCheckbox source, GEvent event) { //_CODE_:digitalCheckbox1:676831:
  println("digitalCheckbox6 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:digitalCheckbox1:676831:


public void digitalCheckbox7_change(GCheckbox source, GEvent event) { //_CODE_:digitalCheckbox1:676831:
  println("digitalCheckbox7 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:digitalCheckbox1:676831:



public void armStraightButton_click(GImageButton source, GEvent event) { //_CODE_:digitalCheckbox1:676831:
  println("armstraught - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
  
  currentOrientation = 1;
  setPositionParameters();
  changeArmMode();
} //_CODE_:digitalCheckbox1:676831:

public void arm90Button_click(GImageButton source, GEvent event) { //_CODE_:digitalCheckbox1:676831:
  println("arm90 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
  currentOrientation = 2;
  setPositionParameters();
  changeArmMode();
} //_CODE_:digitalCheckbox1:676831:



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
  
  
  controlPanel = new GPanel(this, 5, 280, 240, 450, "Control Panel");
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
  
  
  
  xTextField = new GTextField(this, 5, 48, 60, 20, G4P.SCROLLBARS_NONE);
  //xTextField.setText("0");
  xTextField.setText(Integer.toString(xParameters[0]));
  xTextField.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  xTextField.setOpaque(true);
  xTextField.addEventHandler(this, "xTextField_change");
  
  xSlider = new GSlider(this, 75, 38, 145, 40, 10.0);
  xSlider.setShowLimits(true);
  xSlider.setLimits(0.0, -200.0, 200.0);
  xSlider.setNbrTicks(50);
  xSlider.setEasing(0.0);
  xSlider.setNumberFormat(G4P.INTEGER, 0);
  xSlider.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  xSlider.setOpaque(false);
  xSlider.addEventHandler(this, "xSlider_change");
  
  
  xLabel = new GLabel(this, 5, 68, 60, 14);
  xLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  xLabel.setText("X Coord");
  xLabel.setOpaque(false);
  
  
  yTextField = new GTextField(this, 5, 88, 60, 20, G4P.SCROLLBARS_NONE);
  yTextField.setText(Integer.toString(yParameters[0]));
  yTextField.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  yTextField.setOpaque(true);
  yTextField.addEventHandler(this, "yTextField_change");
  
  
  ySlider = new GSlider(this, 75, 78, 145, 40, 10.0);
  ySlider.setShowLimits(true);
  ySlider.setLimits(200.0, 50.0, 240.0);
  ySlider.setEasing(0.0);
  ySlider.setNumberFormat(G4P.INTEGER, 0);
  ySlider.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  ySlider.setOpaque(false);
  ySlider.addEventHandler(this, "ySlider_change");
    
  yLabel = new GLabel(this, 5, 108, 60, 14);
  yLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  yLabel.setText("Y Coord");
  yLabel.setOpaque(false);
  
  
  
  zTextField = new GTextField(this, 5, 128, 60, 20, G4P.SCROLLBARS_NONE);
  zTextField.setText(Integer.toString(zParameters[0]));
  zTextField.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  zTextField.setOpaque(true);
  zTextField.addEventHandler(this, "zTextField_change");
  
 
  zSlider = new GSlider(this, 75, 118, 145, 40, 10.0);
  zSlider.setShowLimits(true);
  zSlider.setLimits(200.0, 20.0, 250.0);
  zSlider.setEasing(0.0);
  zSlider.setNumberFormat(G4P.INTEGER, 0);
  zSlider.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  zSlider.setOpaque(false);
  zSlider.addEventHandler(this, "zSlider_change"); 
  
  zLabel = new GLabel(this, 5, 148, 60, 14);
  zLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  zLabel.setText("Z Coord");
  zLabel.setOpaque(false);
  
 
  wristAngleTextField = new GTextField(this, 5, 168, 60, 20, G4P.SCROLLBARS_NONE);
  wristAngleTextField.setText(Integer.toString(wristAngleParameters[0]));
  wristAngleTextField.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  wristAngleTextField.setOpaque(true);
  wristAngleTextField.addEventHandler(this, "wristAngleTextField_change");
  
  
  wristAngleSlider = new GSlider(this, 75, 158, 145, 40, 10.0);
  wristAngleSlider.setShowLimits(true);
  wristAngleSlider.setLimits(0.0, -90.0, 90.0);
  wristAngleSlider.setEasing(0.0);
  wristAngleSlider.setNumberFormat(G4P.INTEGER, 0);
  wristAngleSlider.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  wristAngleSlider.setOpaque(false);
  wristAngleSlider.addEventHandler(this, "wristAngleSlider_change");
  
  wristAngleLabel = new GLabel(this, 5, 188, 70, 14);
  wristAngleLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  wristAngleLabel.setText("Wrist Angle");
  wristAngleLabel.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  wristAngleLabel.setOpaque(false);
  
  
  
  
  
  wristRotateTextField = new GTextField(this, 5, 208, 60, 20, G4P.SCROLLBARS_NONE);
   wristRotateTextField.setText(Integer.toString( wristRotateParameters[0]));
  wristRotateTextField.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  wristRotateTextField.setOpaque(true);
  wristRotateTextField.addEventHandler(this, "wristRotateTextField_change");
  
  wristRotateSlider = new GSlider(this, 75, 198, 145, 40, 10.0);
  wristRotateSlider.setShowLimits(true);
  wristRotateSlider.setLimits(0.0, -512.0, 512.0);
  wristRotateSlider.setEasing(0.0);
  wristRotateSlider.setNumberFormat(G4P.INTEGER, 0);
  wristRotateSlider.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  wristRotateSlider.setOpaque(false);
  wristRotateSlider.addEventHandler(this, "wristRotateSlider_change");
  
  wristRotateLabel = new GLabel(this, 5, 228, 70, 14);
  wristRotateLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  wristRotateLabel.setText("Wrist Rotate");
  wristRotateLabel.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  wristRotateLabel.setOpaque(false);
  
  gripperTextField = new GTextField(this, 5, 248, 60, 20, G4P.SCROLLBARS_NONE);
  gripperTextField.setText(Integer.toString(gripperParameters[0]));
  gripperTextField.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  gripperTextField.setOpaque(true);
  gripperTextField.addEventHandler(this, "gripperTextField_change");
  
  gripperSlider = new GSlider(this, 75, 238, 145, 40, 10.0);
  gripperSlider.setShowLimits(true);
  gripperSlider.setLimits(256.0, 0.0, 512.0);
  gripperSlider.setEasing(0.0);
  gripperSlider.setNumberFormat(G4P.INTEGER, 0);
  gripperSlider.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  gripperSlider.setOpaque(false);
  gripperSlider.addEventHandler(this, "gripperSlider_change");
  
  gripperLabel = new GLabel(this, 5, 268, 60, 14);
  gripperLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  gripperLabel.setText("Gripper");
  gripperLabel.setOpaque(false);
  
  
  deltaTextField = new GTextField(this, 5, 288, 60, 20, G4P.SCROLLBARS_NONE);
  deltaTextField.setText("125");
  deltaTextField.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  deltaTextField.setOpaque(true);
  deltaTextField.addEventHandler(this, "deltaTextField_change");
  
  
  deltaSlider = new GSlider(this, 75, 278, 145, 40, 10.0);
  deltaSlider.setShowValue(true);
  deltaSlider.setShowLimits(true);
  deltaSlider.setLimits(125.0, 0.0, 255.0);
  deltaSlider.setEasing(0.0);
  deltaSlider.setNumberFormat(G4P.INTEGER, 0);
  deltaSlider.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  deltaSlider.setOpaque(false);
  deltaSlider.addEventHandler(this, "deltaSliderChange");
  
  
  deltaLabel = new GLabel(this, 5, 308, 60, 14);
  deltaLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  deltaLabel.setText("Delta");
  deltaLabel.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  deltaLabel.setOpaque(false);
  
  extendedList = new GDropList(this, 5, 333, 221, 100, 5);
  extendedList.setItems(loadStrings("list_893307"), 0);
  extendedList.addEventHandler(this, "extendedList_click");
  extendedList.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  
  
  
  
  

   
  digitalsLabel = new GLabel(this, 5, 355, 100, 14);
  digitalsLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  digitalsLabel.setText("Digital Values");
  digitalsLabel.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  digitalsLabel.setOpaque(false);
  
  
  digitalCheckbox0 = new GCheckbox(this, 5, 370, 28, 20);
  digitalCheckbox0.setOpaque(false);
  digitalCheckbox0.addEventHandler(this, "digitalCheckbox0_change");
  digitalCheckbox0.setText("0");
  
  digitalCheckbox1 = new GCheckbox(this, 32, 370, 28, 20);
  digitalCheckbox1.setOpaque(false);
  digitalCheckbox1.addEventHandler(this, "digitalCheckbox1_change");
  digitalCheckbox1.setText("1");
  
  digitalCheckbox2 = new GCheckbox(this, 60, 370, 28, 20);
  digitalCheckbox2.setOpaque(false);
  digitalCheckbox2.addEventHandler(this, "digitalCheckbox2_change");
  digitalCheckbox2.setText("2");
  
  digitalCheckbox3 = new GCheckbox(this, 88, 370, 28, 20);
  digitalCheckbox3.setOpaque(false);
  digitalCheckbox3.addEventHandler(this, "digitalCheckbox3_change");
  digitalCheckbox3.setText("3");
  
  digitalCheckbox4 = new GCheckbox(this, 116, 370, 28, 20);
  digitalCheckbox4.setOpaque(false);
  digitalCheckbox4.addEventHandler(this, "digitalCheckbox4_change");
  digitalCheckbox4.setText("4");
  
  digitalCheckbox5 = new GCheckbox(this, 144, 370, 28, 20);
  digitalCheckbox5.setOpaque(false);
  digitalCheckbox5.addEventHandler(this, "digitalCheckbox5_change");
  digitalCheckbox5.setText("5");
  
  digitalCheckbox6 = new GCheckbox(this, 172, 370, 28, 20);
  digitalCheckbox6.setOpaque(false);
  digitalCheckbox6.addEventHandler(this, "digitalCheckbox6_change");
  digitalCheckbox6.setText("6");
  
  digitalCheckbox7 = new GCheckbox(this, 200, 370, 28, 20);
  digitalCheckbox7.setOpaque(false);
  digitalCheckbox7.addEventHandler(this, "digitalCheckbox7_change");
  digitalCheckbox7.setText("7");
  
  
  updateButton = new GButton(this, 5, 395, 100, 50);
  updateButton.setText("Update");
  updateButton.addEventHandler(this, "updateButton_click");
  updateButton.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  
  
  autoUpdateCheckbox = new GCheckbox(this, 105, 429, 100, 20);
  autoUpdateCheckbox.setOpaque(false);
  autoUpdateCheckbox.addEventHandler(this, "autoUpdateCheckbox_change");
  autoUpdateCheckbox.setText("Auto Update");
  
  
  armStraightButton = new GImageButton(this, 5, 40, 100, 65, new String[] { "armStraightm.png", "armStraightm.png", "armStraightm.png" } );
  armStraightButton.addEventHandler(this, "armStraightButton_click");
  
  
  arm90Button = new GImageButton(this, 130, 40, 100, 65, new String[] { "arm90m.png", "arm90m.png", "arm90m.png" } );
  arm90Button.addEventHandler(this, "arm90Button_click");
  
  
  
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
  controlPanel.addControl(extendedList);
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
  
  
  
 
  logoImg = loadImage("logo.png");  // Load the image into the program  
  footerImg = loadImage("footer.png");  // Load the image into the program  
  
  
  controlPanel.setVisible(false);
  controlPanel.setEnabled(false);
  
  modePanel.setVisible(false);
  modePanel.setEnabled(false);
  
  disconnectButton.setEnabled(false);
  
}

// Variable declarations 
// autogenerated do not edit
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
GLabel xLabel; 
GDropList extendedList; 
GLabel deltaLabel; 
GLabel gripperLabel; 
GLabel wristRotateLabel; 
GLabel wristAngleLabel; 
GLabel zLabel; 
GLabel yLabel; 
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



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

public void serialList_click(GDropList source, GEvent event) { //_CODE_:serialList:700876:
  println("serialList - GDropList event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:serialList:700876:

public void connectButton_click(GButton source, GEvent event) { //_CODE_:connectButton:675124:
  println("connectButton - GButton event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:connectButton:675124:

public void helpButton_click(GButton source, GEvent event) { //_CODE_:helpButton:878117:
  println("helpButton - GButton event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:helpButton:878117:

public void disconnectButton_click(GButton source, GEvent event) { //_CODE_:disconnectButton:927334:
  println("disconnectButton - GButton event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:disconnectButton:927334:

public void autoButton_Click(GButton source, GEvent event) { //_CODE_:autoButton:200520:
  println("autoButton - GButton event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:autoButton:200520:

public void controlPanel_Click(GPanel source, GEvent event) { //_CODE_:controlPanel:613752:
  println("controlPanel - GPanel event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:controlPanel:613752:


public void setupPanel_Click(GPanel source, GEvent event) { 
  println("setupPanel - GPanel event occured " + System.currentTimeMillis()%10000000 );
} 


public void textfield1_change1(GTextField source, GEvent event) { //_CODE_:xTextField:715271:
  println("textfield1 - GTextField event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:xTextField:715271:

public void xSlider_change(GSlider source, GEvent event) { //_CODE_:xSlider:333213:
  println("slider1 - GSlider event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:xSlider:333213:

public void wristRotateTextField_change(GTextField source, GEvent event) { //_CODE_:wristRotateTextField:960310:
  println("textfield1 - GTextField event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:wristRotateTextField:960310:

public void wristAngleTextField_change(GTextField source, GEvent event) { //_CODE_:wristAngleTextField:820941:
  println("textfield2 - GTextField event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:wristAngleTextField:820941:

public void zTextField_change(GTextField source, GEvent event) { //_CODE_:zTextField:979032:
  println("textfield3 - GTextField event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:zTextField:979032:

public void textfield4_change1(GTextField source, GEvent event) { //_CODE_:gripperTextField:793836:
  println("textfield4 - GTextField event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:gripperTextField:793836:

public void yTextField_change(GTextField source, GEvent event) { //_CODE_:yTextField:680644:
  println("textfield6 - GTextField event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:yTextField:680644:

public void deltaTextField_change(GTextField source, GEvent event) { //_CODE_:deltaTextField:680797:
  println("textfield7 - GTextField event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:deltaTextField:680797:

public void extendedList_click(GDropList source, GEvent event) { //_CODE_:extendedList:893307:
  println("dropList2 - GDropList event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:extendedList:893307:

public void ySlider_change(GSlider source, GEvent event) { //_CODE_:ySlider:823070:
  println("ySlider - GSlider event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:ySlider:823070:

public void wristRotateSlider_change(GSlider source, GEvent event) { //_CODE_:wristRotateSlider:672963:
  println("wristRotateSlider - GSlider event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:wristRotateSlider:672963:

public void deltaSliderChange(GSlider source, GEvent event) { //_CODE_:deltaSlider:991895:
  println("deltaSlider - GSlider event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:deltaSlider:991895:

public void gripperSlider_change(GSlider source, GEvent event) { //_CODE_:gripperSlider:870292:
  println("gripperSlider - GSlider event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:gripperSlider:870292:

public void wristAngleSlider_change(GSlider source, GEvent event) { //_CODE_:wristAngleSlider:915010:
  println("wristAngleSlider - GSlider event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:wristAngleSlider:915010:

public void zSlider_change(GSlider source, GEvent event) { //_CODE_:zSlider:396893:
  println("zSlider - GSlider event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:zSlider:396893:

public void cartesianModeButton_click(GButton source, GEvent event) { //_CODE_:cartesianModeButton:383064:
  println("cartesianModeButton - GButton event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:cartesianModeButton:383064:

public void cylindricalModeButton_click(GButton source, GEvent event) { //_CODE_:cylindricalModeButton:547200:
  println("cylindricalModeButton - GButton event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:cylindricalModeButton:547200:

public void backhoeModeButton_click(GButton source, GEvent event) { //_CODE_:backhoeModeButton:347353:
  println("backhoeModeButton - GButton event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:backhoeModeButton:347353:



// Create all the GUI controls. 
// autogenerated do not edit
public void createGUI(){
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setCursor(ARROW);
  
  
  serialList = new GDropList(this, 5, 24, 160, 132, 6);
  serialList.setItems(loadStrings("list_700876"), 0);
  serialList.addEventHandler(this, "serialList_click");
  
  
  connectButton = new GButton(this, 5, 47, 75, 20);
  connectButton.setText("Connect");
  connectButton.addEventHandler(this, "connectButton_click");
  
  disconnectButton = new GButton(this, 90, 47, 75, 20);
  disconnectButton.setText("Disconnect");
  disconnectButton.addEventHandler(this, "disconnectButton_click");
  
  helpButton = new GButton(this, 10, 550, 40, 20);
  helpButton.setText("Help");
  helpButton.setLocalColorScheme(GCScheme.GOLD_SCHEME);
  helpButton.addEventHandler(this, "helpButton_click");
  
  
  autoButton = new GButton(this, 170, 24, 55, 43);
  autoButton.setText("Auto Search");
  autoButton.addEventHandler(this, "autoButton_Click");
  
  setupPanel = new GPanel(this, 5, 83, 240, 75, "Setup Panel");
  setupPanel.setText("Setup Panel");
  setupPanel.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  setupPanel.setOpaque(true);
  setupPanel.addEventHandler(this, "setupPanel_Click");
  
  controlPanel = new GPanel(this, 5, 158, 240, 354, "Control Panel");
  controlPanel.setText("Control Panel");
  controlPanel.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  controlPanel.setOpaque(true);
  controlPanel.addEventHandler(this, "controlPanel_Click");
  
  xTextField = new GTextField(this, 5, 48, 60, 20, G4P.SCROLLBARS_NONE);
  xTextField.setText("test");
  xTextField.setDefaultText("0");
  xTextField.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  xTextField.setOpaque(true);
  xTextField.addEventHandler(this, "textfield1_change1");
  
  xSlider = new GSlider(this, 75, 38, 145, 40, 10.0);
  xSlider.setShowLimits(true);
  xSlider.setLimits(0.0, -200.0, 200.0);
  xSlider.setNbrTicks(50);
  xSlider.setEasing(15.0);
  xSlider.setNumberFormat(G4P.INTEGER, 0);
  xSlider.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  xSlider.setOpaque(false);
  xSlider.addEventHandler(this, "xSlider_change");
  
  
  xLabel = new GLabel(this, 5, 68, 60, 14);
  xLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  xLabel.setText("X Coord");
  xLabel.setOpaque(false);
  
  
  yTextField = new GTextField(this, 5, 88, 60, 20, G4P.SCROLLBARS_NONE);
  yTextField.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  yTextField.setOpaque(true);
  yTextField.addEventHandler(this, "yTextField_change");
  
  
  ySlider = new GSlider(this, 75, 78, 145, 40, 10.0);
  ySlider.setShowLimits(true);
  ySlider.setLimits(200.0, 50.0, 240.0);
  ySlider.setEasing(15.0);
  ySlider.setNumberFormat(G4P.INTEGER, 0);
  ySlider.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  ySlider.setOpaque(false);
  ySlider.addEventHandler(this, "ySlider_change");
    
  yLabel = new GLabel(this, 5, 108, 60, 14);
  yLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  yLabel.setText("Y Coord");
  yLabel.setOpaque(false);
  
  
  
  zTextField = new GTextField(this, 5, 128, 60, 20, G4P.SCROLLBARS_NONE);
  zTextField.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  zTextField.setOpaque(true);
  zTextField.addEventHandler(this, "zTextField_change");
  
 
  zSlider = new GSlider(this, 75, 118, 145, 40, 10.0);
  zSlider.setShowLimits(true);
  zSlider.setLimits(200.0, 20.0, 250.0);
  zSlider.setEasing(15.0);
  zSlider.setNumberFormat(G4P.INTEGER, 0);
  zSlider.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  zSlider.setOpaque(false);
  zSlider.addEventHandler(this, "zSlider_change"); 
  
  zLabel = new GLabel(this, 5, 148, 60, 14);
  zLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  zLabel.setText("Z Coord");
  zLabel.setOpaque(false);
  
 
  wristAngleTextField = new GTextField(this, 5, 168, 60, 20, G4P.SCROLLBARS_NONE);
  wristAngleTextField.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  wristAngleTextField.setOpaque(true);
  wristAngleTextField.addEventHandler(this, "wristAngleTextField_change");
  
  
  wristAngleSlider = new GSlider(this, 75, 158, 145, 40, 10.0);
  wristAngleSlider.setShowLimits(true);
  wristAngleSlider.setLimits(0.0, -90.0, 90.0);
  wristAngleSlider.setEasing(15.0);
  wristAngleSlider.setNumberFormat(G4P.INTEGER, 0);
  wristAngleSlider.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  wristAngleSlider.setOpaque(false);
  wristAngleSlider.addEventHandler(this, "wristAngleSlider_change");
  
  wristAngleLabel = new GLabel(this, 5, 188, 70, 14);
  wristAngleLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  wristAngleLabel.setText("Wrist Angle");
  wristAngleLabel.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  wristAngleLabel.setOpaque(false);
  
  
  
  
  
  wristRotateTextField = new GTextField(this, 5, 208, 60, 20, G4P.SCROLLBARS_NONE);
  wristRotateTextField.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  wristRotateTextField.setOpaque(true);
  wristRotateTextField.addEventHandler(this, "wristRotateTextField_change");
  
  wristRotateSlider = new GSlider(this, 75, 198, 145, 40, 10.0);
  wristRotateSlider.setShowLimits(true);
  wristRotateSlider.setLimits(0.0, -512.0, 512.0);
  wristRotateSlider.setEasing(15.0);
  wristRotateSlider.setNumberFormat(G4P.INTEGER, 0);
  wristRotateSlider.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  wristRotateSlider.setOpaque(false);
  wristRotateSlider.addEventHandler(this, "wristRotateSlider_change");
  
  wristRotateLabel = new GLabel(this, 5, 228, 70, 14);
  wristRotateLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  wristRotateLabel.setText("Wrist Rotate");
  wristRotateLabel.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  wristRotateLabel.setOpaque(false);
  
  gripperTextField = new GTextField(this, 5, 248, 60, 20, G4P.SCROLLBARS_NONE);
  gripperTextField.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  gripperTextField.setOpaque(true);
  gripperTextField.addEventHandler(this, "textfield4_change1");
  
  gripperSlider = new GSlider(this, 75, 238, 145, 40, 10.0);
  gripperSlider.setShowLimits(true);
  gripperSlider.setLimits(256.0, 0.0, 512.0);
  gripperSlider.setEasing(15.0);
  gripperSlider.setNumberFormat(G4P.INTEGER, 0);
  gripperSlider.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  gripperSlider.setOpaque(false);
  gripperSlider.addEventHandler(this, "gripperSlider_change");
  
  gripperLabel = new GLabel(this, 5, 368, 60, 14);
  gripperLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  gripperLabel.setText("Gripper");
  gripperLabel.setOpaque(false);
  
  
  deltaTextField = new GTextField(this, 5, 288, 60, 20, G4P.SCROLLBARS_NONE);
  deltaTextField.setText("yTextField");
  deltaTextField.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  deltaTextField.setOpaque(true);
  deltaTextField.addEventHandler(this, "deltaTextField_change");
  
  
  deltaSlider = new GSlider(this, 75, 278, 145, 40, 10.0);
  deltaSlider.setShowValue(true);
  deltaSlider.setShowLimits(true);
  deltaSlider.setLimits(125.0, 0.0, 255.0);
  deltaSlider.setEasing(15.0);
  deltaSlider.setNumberFormat(G4P.INTEGER, 0);
  deltaSlider.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  deltaSlider.setOpaque(false);
  deltaSlider.addEventHandler(this, "deltaSliderChange");
  
  
  deltaLabel = new GLabel(this, 5, 308, 60, 14);
  deltaLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  deltaLabel.setText("Delta");
  deltaLabel.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  deltaLabel.setOpaque(false);
  
  extendedList = new GDropList(this, 5, 333, 221, 100, 5);
  extendedList.setItems(loadStrings("list_893307"), 0);
  extendedList.addEventHandler(this, "extendedList_click");
  
  

  cartesianModeButton = new GButton(this, 0, 18, 80, 20);
  cartesianModeButton.setText("Cartesian");
  cartesianModeButton.addEventHandler(this, "cartesianModeButton_click");
  
  cylindricalModeButton = new GButton(this, 80, 18, 80, 20);
  cylindricalModeButton.setText("Cylindrical");
  cylindricalModeButton.addEventHandler(this, "cylindricalModeButton_click");
  
  backhoeModeButton = new GButton(this, 160, 18, 80, 20);
  backhoeModeButton.setText("Backkhoe");
  backhoeModeButton.addEventHandler(this, "backhoeModeButton_click");
  
   
  setupPanel.addControl(serialList);
  setupPanel.addControl(connectButton);
  setupPanel.addControl(disconnectButton);
  setupPanel.addControl(autoButton);
  
  
  
  controlPanel.addControl(xTextField);
  controlPanel.addControl(xSlider);
  controlPanel.addControl(wristRotateTextField);
  controlPanel.addControl(wristAngleTextField);
  controlPanel.addControl(zTextField);
  controlPanel.addControl(gripperTextField);
  controlPanel.addControl(yTextField);
  controlPanel.addControl(deltaTextField);
  controlPanel.addControl(xLabel);
  controlPanel.addControl(extendedList);
  controlPanel.addControl(deltaLabel);
  controlPanel.addControl(gripperLabel);
  controlPanel.addControl(wristRotateLabel);
  controlPanel.addControl(wristAngleLabel);
  controlPanel.addControl(zLabel);
  controlPanel.addControl(yLabel);
  controlPanel.addControl(ySlider);
  controlPanel.addControl(wristRotateSlider);
  controlPanel.addControl(deltaSlider);
  controlPanel.addControl(gripperSlider);
  controlPanel.addControl(wristAngleSlider);
  controlPanel.addControl(zSlider);
  controlPanel.addControl(cartesianModeButton);
  controlPanel.addControl(cylindricalModeButton);
  controlPanel.addControl(backhoeModeButton);
  
  
 
  logoImg = loadImage("logo.png");  // Load the image into the program  
  
  
}

// Variable declarations 
// autogenerated do not edit
GDropList serialList; 
GButton connectButton; 
GButton helpButton; 
GButton disconnectButton; 
GButton autoButton; 
GPanel setupPanel; 
GPanel controlPanel; 
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
PImage logoImg;
PImage footerImg;




/***********************************************************************************
 *  }--\     InterbotiX     /--{
 *      |    Arm Link      |
 *   __/                    \__
 *  |__|                    |__|
 *
 *  importParse.pde
 *  
 *  Test importing  functionality 
 *
********************************************************************************/

BufferedReader reader;
String line;
 

 
public void readArmFile(File selection)
{
  //noLoop();
  String[] txtFile;

  if (selection == null) 
  {

    loop();
    displayError("No File Selected.","");
    return;
  }



  String filepath = selection.getAbsolutePath();
  println("User selected " + filepath);
  






        try 
      {
        txtFile = loadStrings(filepath);
      } 
      catch (Exception e) 
      {
        txtFile = null;
        loop();
        displayError("Problem With File.","");
        return;
      }


// load file here



 

  String armNumberString;
  int armNumberInt;
  String sequenceNumberString;
  int sequenceNumberInt;
  String armModeString;
  int armModeInt;
  String armOrientationString;
  int armOrientationInt;
  String tempLine ;
  String[] splitPose = {"","","","","","","",""};
  int[] tempPoseData = {0, 0, 0, 0,0 ,0 ,0 ,0};
  int[] tempPoseData2 = {0, 0, 0, 0,0 ,0 ,0 ,0};
  int[] tempPoseData5=  {0, 0, 0, 0,0 ,0 ,0 ,0};




    if(txtFile[0].length() >= 6)
    {
      armNumberString = txtFile[0].substring(6, txtFile[0].length());
      armNumberInt = Integer.parseInt(armNumberString);

    }
    else  
    {

      loop();
      displayError("Problem With File.","");
      return;
      
    }
    //println(armNumberInt);

    //check if this file works for the arm currently connected
    if(armNumberInt != currentArm)
    {
      loop();
      printlnDebug("Wrong Arm"); 
      displayError("Incorrect File - File for the wrong Arm or the wrong type of file","");
      return;
    }


   clearPoses();


    sequenceNumberString = txtFile[1].substring(11, txtFile[1].length());
    sequenceNumberInt = Integer.parseInt(sequenceNumberString);



    armModeString = txtFile[2].substring(7, txtFile[2].length());
    armModeInt = Integer.parseInt(armModeString);
   
   

    if(armModeInt == 1)
    {

      setCartesian();
    }
    else if(armModeInt == 2)
    {
      setCylindrical();
    }
    else if(armModeInt == 3)
    {
      setBackhoe();
    }


   


    armOrientationString = txtFile[3].substring(14, txtFile[3].length());
    armOrientationInt = Integer.parseInt(armOrientationString);
    //println(armOrientationString);


    if (armOrientationInt == 1)
    {
      setOrientStraight();

    }
    else if(armOrientationInt == 2)
    {
      setOrient90();
    }


    //read the posotion data from the file.
    for(int j = 0; j < sequenceNumberInt ;j++)
    {



      tempLine = txtFile[22+(j*6)].replace("    IKSequencingControl(", "");
      tempLine = tempLine.replace(", playState);", "");


      splitPose = tempLine.split(",");


     for(int i = 0;i < splitPose.length;i++)
      {





        splitPose[i] = splitPose[i].replaceAll("\\s","") ;
        tempPoseData[i] = Integer.parseInt(splitPose[i]);

      }


   switch(armModeInt)
    {
       case 1:        
         //x, wrist angle, and wrist rotate must be offset, all others are normal
         tempPoseData2[0] = tempPoseData[0] - 512;
         tempPoseData2[1] = tempPoseData[1];
         tempPoseData2[2] = tempPoseData[2];
         tempPoseData2[3] = tempPoseData[3];
         tempPoseData2[4] = tempPoseData[4];
         tempPoseData2[5] = tempPoseData[5];
         tempPoseData2[6] = tempPoseData[6]/16;
         tempPoseData2[7] = 0;


         break;
        
       case 2:
       
         //wrist angle, and wrist rotate must be offset, all others are normal


         tempPoseData2[0] = tempPoseData[0];




         tempPoseData2[1] = tempPoseData[1];
         tempPoseData2[2] = tempPoseData[2];
         tempPoseData2[3] = tempPoseData[3];
         tempPoseData2[4] = tempPoseData[4];
         tempPoseData2[5] = tempPoseData[5];
         tempPoseData2[6] = tempPoseData[6]/16;
         tempPoseData2[7] = 0;         



         break;
        
       case 3:
       
         //no offsets needed
         tempPoseData2[0] = tempPoseData[0];
         tempPoseData2[1] = tempPoseData[1];
         tempPoseData2[2] = tempPoseData[2];
         tempPoseData2[3] = tempPoseData[3];
         tempPoseData2[4] = tempPoseData[4];
         tempPoseData2[5] = tempPoseData[5];
         tempPoseData2[6] = tempPoseData[6];
         tempPoseData2[7] = 0;
        break; 
    }  
    
     pauseTextField.setText(tempPoseData[7] + "");




          addNewPose(tempPoseData2);    
    
    

    
  
      printDebug("Added Pose ");
      printlnDebug(j + " ");



    }



  // for(int i = 0; i < poses.size(); i++)
  // {
  
  //   sequencePanel.addControl(poses.get(i));
  // }
  
   loop();
    return;

}

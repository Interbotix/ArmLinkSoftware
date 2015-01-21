
/***********************************************************************************
 *  }--\     InterbotiX     /--{
 *      |    Arm Link      |
 *   __/                    \__
 *  |__|                    |__|
 *
 *  global.pde
 *  
 *  This file has several global variables relating to the positional data for the arms.
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


//WORKING POSITION VARIABLES

//default values and min/max , {default, min, max}
//initially set to values for pincher in normal mode which should be safe for most arms (this shouldn't matter, as these values will get changed when an arm is connected)
//these parameters will be loaded based on the 1)Arm type 2)IK mode 3)Wrist Angle Orientation
int[] xParameters = {0,-200,200};//
int[] yParameters = {200,50,240};
int[] zParameters = {200,20,250};
int[] wristAngleParameters = {0,-90,90};
int[] wristRotateParameters = {0,-512,511};
int[] gripperParameters = {256,0,512};
int[] deltaParameters = {125,0,256};
int[] pauseParameters = {1000,0,10000};

//values for the current value directly from the GUI element. These are updated by the slider/text boxes
int xCurrent = xParameters[0]; //current x value in text field/slider
int yCurrent = yParameters[0]; //current y value in text field/slider
int zCurrent = zParameters[0]; //current z value in text field/slider
int wristAngleCurrent = wristAngleParameters[0]; //current Wrist Angle value in text field/slider
int wristRotateCurrent = wristRotateParameters[0]; //current  Wrist Rotate value in text field/slider
int gripperCurrent = gripperParameters[0]; //current Gripper value in text field/slider
int deltaCurrent = deltaParameters[0]; //current delta value in text field/slider};
int pauseCurrent = 1000;

//offset values to be send to the ArbotiX/Arm. whether or not these values get offsets depends on the current mode
//it will be possible for the 'Current' value to be the same as the 'currentOffset' value.
// see updateOffsetCoordinates()
int xCurrentOffset = xParameters[0]; //current x value to be send to ArbotiX/Arm
int yCurrentOffset = yParameters[0]; //current y value to be send to ArbotiX/Arm
int zCurrentOffset = zParameters[0]; //current z value to be send to ArbotiX/Arm
int wristAngleCurrentOffset = wristAngleParameters[0]; //current Wrist Angle value to be send to ArbotiX/Arm
int wristRotateCurrentOffset = wristRotateParameters[0]; //current  Wrist Rotate value to be send to ArbotiX/Arm
int gripperCurrentOffset = gripperParameters[0]; //current Gripper value to be send to ArbotiX/Arm
int deltaCurrentOffset = deltaParameters[0]; //current delta value to be send to ArbotiX/Arm

boolean[] digitalButtons = {false,false,false,false,false,false,false,false};  //array of 8 boolean to hold the current states of the checkboxes that correspond to the digital i/o
int digitalButtonByte;//int will hold the button byte (will be cast to byte later)

int extendedByte = 0;  //extended byte for special instructions


//END WORKING POSITION VARIABLES

//DEFAULT ARM PARAMETERS 

int numberOfArms = 5;

 //XYZ 
int[][] armParam0X = new int[numberOfArms][3];
int[][] armParam0Y = new int[numberOfArms][3];
int[][] armParam0Z = new int[numberOfArms][3];
int[][] armParam0WristAngle = new int[numberOfArms][3];
int[][] armParam0WristRotate = new int[numberOfArms][3];

int[][] armParam90X = new int[numberOfArms][3];
int[][] armParam90Y = new int[numberOfArms][3];
int[][] armParam90Z = new int[numberOfArms][3];
int[][] armParam90WristAngle = new int[numberOfArms][3];
int[][] armParam90WristRotate = new int[numberOfArms][3];



int[][] armParamBase = new int[numberOfArms][3];
int[][] armParamBHShoulder = new int[numberOfArms][3];
int[][] armParamBHElbow = new int[numberOfArms][3];
int[][] armParamBHWristAngle = new int[numberOfArms][3];
int[][] armParamBHWristRot = new int[numberOfArms][3];


int[][] armParamGripper = new int[numberOfArms][3];


int[][] armParamWristAngle0Knob = new int[numberOfArms][2];
int[][] armParamWristAngle90Knob = new int[numberOfArms][2];
int[][] armParamWristAngleBHKnob = new int[numberOfArms][2];
int[][] armParamWristRotKnob= new int[numberOfArms][2];

int[][] armParamBaseKnob = new int[numberOfArms][2];
int[][] armParamElbowKnob = new int[numberOfArms][2];
int[][] armParamShoulderKnob = new int[numberOfArms][2];
float[] armParamElbowKnobRotation = new float[numberOfArms];


//default values for the phantomX pincher. These will be loaded into the working position variables 
//when the pincher is connected, and when modes are changed.
int[] pincherNormalX = {0,-200,200};
int[] pincherNormalY = {170,50,240};
int[] pincherNormalZ = {210,20,250};
int[] pincherNormalWristAngle = {0,-30,30};
int[] pincherWristRotate = {0,0,0};//not implemented in hardware
int[] pincherGripper = {256,0,512};
int[] pincher90X = {0,-200,200};
int[] pincher90Y = {140,20,150};
int[] pincher90Z = {30,10,150};
int[] pincher90WristAngle = {-90,-90,-45};
int[] pincherBase = {512,1023,0};
int[] pincherBHShoulder = {512,815,205};
int[] pincherBHElbow = {512,1023,205};
int[] pincherBHWristAngle = {512,815,205};
int[] pincherBHWristRot = {512,0,1023};

int[] pincherBHWristAngleNormalKnob = {150,210};//angle data for knob limits
int[] pincherBHWristAngle90Knob = {90,45};//angle data for knob limits

int[] pincherWristAngleBHKnob = {90,270};//angle data for knob limits
int[] pincherWristRotKnob = {120,60};

int[] pincherBaseKnob = {120,60};
int[] pincherShoulderKnob = {180,0};
int[] pincherElbowKnob = {180,60};
float pincherElbowKnobRotation = -PI*1/3;



//default values for the phantomX reactor. These will be loaded into the working position variables 
//when the reactor is connected, and when modes are changed.
int[] reactorNormalX = {0,-300,300};
int[] reactorNormalY = {235,50,350};
int[] reactorNormalZ = {210,20,250};
int[] reactorNormalWristAngle = {0,-30,30};
//int[] reactorWristRotate = {0,511,-512};
int[] reactorWristRotate = {512,0,1023};
int[] reactorGripper = {256,0,512};
int[] reactor90X = {0,-300,300};
int[] reactor90Y = {140,20,150};
int[] reactor90Z = {30,10,150};
int[] reactor90WristAngle = {-90,-90,-45};
int[] reactorBase = {512,1023,0};
int[] reactorBHShoulder = {512,810,205};
int[] reactorBHElbow = {512,210,900};
int[] reactorBHWristAngle = {512,200,830};
int[] reactorBHWristRot = {512,1023,0};

int[] reactorWristAngleNormalKnob = {150,210};//angle data for knob limits
int[] reactorWristAngle90Knob = {90,135};//angle data for knob limits
int[] reactorWristAngleBHKnob = {90,270};//angle data for knob limits
int[] reactorWristRotKnob = {120,60};
int[] reactorBaseKnob = {120,60};
int[] reactorShoulderKnob = {180,0};
int[] reactorElbowKnob = {180,30};
float reactorElbowKnobRotation = 0;



//default values for the widowx. These will be loaded into the working position variables 
//when the widowx is connected, and when modes are changed.
int[] widowNormalX = {0,-300,300};
int[] widowNormalY = {250,50,400};
int[] widowNormalZ = {225,20,350};
int[] widowNormalWristAngle = {0,-30,30};
int[] widowWristRotate = {512,0,1023};
int[] widowGripper = {256,0,512};
int[] widow90X = {0,-300,300};
int[] widow90Y = {150,20,250};
int[] widow90Z = {30,10,200};
int[] widow90WristAngle = {-90,-90,-45};
int[] widowBase = {2048,4095,0};
int[] widowBHShoulder = {2048,3072,1024};
int[] widowBHElbow = {2048,1024,3072};
int[] widowBHWristAngle = {2048,1024,3072};
int[] widowBHWristRot = {512,1023,0};

int[] widowBHWristAngleNormalKnob = {150,210};//angle data for knob limits
int[] widowBHWristAngle90Knob = {90,135};//angle data for knob limits

int[] widowWristAngleBHKnob = {90,270};//angle data for knob limits
int[] widowWristRotKnob = {120,60};

int[] widowBaseKnob = {90,90};
int[] widowShoulderKnob = {180,0};
int[] widowElbowKnob =  {180,0};
float widowElbowKnobRotation = 0;//-PI*1/3;



//default values for the RobotGeek Snapper. These will be loaded into the working position variables 
//when the snapper is connected, and when modes are changed.
int[] snapperNormalX = {0,-150,150};
int[] snapperNormalY = {150,55,200}; //the limits are really 50-200, but 50-54 cause a problem when height Z is maximum
int[] snapperNormalZ = {150,20,225};
int[] snapperNormalWristAngle = {0,-30,30};


int[] snapperWristRotate = {0,0,0};  //Not Implemented in Snapper hardware
int[] snapperGripper = {256,0,512};
int[] snapper90X = {0,-200,200};          //Not Implemented in Snapper firmware
int[] snapper90Y = {140,20,150};          //Not Implemented in Snapper firmware
int[] snapper90Z = {30,10,150};          //Not Implemented in Snapper firmware
int[] snapper90WristAngle = {-90,-90,-45};          //Not Implemented in Snapper firmware
int[] snapperBase = {512,0,1023};          //Not Implemented in Snapper firmware
int[] snapperBHShoulder = {512,205,815};          //Not Implemented in Snapper firmware
int[] snapperBHElbow = {512,205,1023};          //Not Implemented in Snapper firmware
int[] snapperBHWristAngle = {512,205,815};          //Not Implemented in Snapper firmware
int[] snapperBHWristRot = {512,0,1023};          //Not Implemented in Snapper firmware

int[] snapperBHWristAngleNormalKnob = {150,210};//angle data for knob limits
int[] snapperBHWristAngle90Knob = {90,45};//angle data for knob limits

int[] snapperWristAngleBHKnob = {270,90};//angle data for knob limits
int[] snapperWristRotKnob = {120,60};

int[] snapperBaseKnob = {120,60};
int[] snapperShoulderKnob = {120,60};
int[] snapperElbowKnob = {120,60};
float snapperElbowKnobRotation = -PI*1/3;




//END DEFAULT ARM PARAMETERS 



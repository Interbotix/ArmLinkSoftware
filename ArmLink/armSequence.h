//Arm 2
//Sequence 5
//Mode 1
//Orientation 1
//DIO 1
#include "Kinematics.h"
#include "GlobalArm.h"
extern void IKSequencingControl(float X, float Y, float Z, float GA, float WR, int grip, int interpolate, int pause, int enable);
// We need to declare the data exchange
// variable to be volatile - the value is
// read from memory.
volatile int playState = 0; // 0 = stopped 1 = playing

void playSequence()
{
  delay(500);
  Serial.println("Sequencing Mode Active."); 
  Serial.println("Press Pushbutton  to stop");
  playState = 1;  //set playState to 1 as the sequence is now playing
    g_bIKMode = IKM_IK3D_CARTESIAN;
    //###########################################################//
    // SEQUENCE 1
    //###########################################################// 
    IKSequencingControl(0 , 235 , 210 , 0 , 512 , 256 , 2000 , 1000, playState);
    //DIO0
    pinMode(7, OUTPUT);
    digitalWrite(7, LOW);
    pinMode(6, OUTPUT);
    digitalWrite(6, LOW);
    pinMode(5, OUTPUT);
    digitalWrite(5, LOW);
    pinMode(4, OUTPUT);
    digitalWrite(4, LOW);
    pinMode(3, OUTPUT);
    digitalWrite(3, LOW);
    pinMode(2, OUTPUT);
    digitalWrite(2, LOW);
    pinMode(1, OUTPUT);
    digitalWrite(1, LOW);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 2
    //###########################################################// 
    IKSequencingControl(0 , 235 , 210 , 0 , 512 , 256 , 2000 , 1000, playState);
    //DIO1
    pinMode(7, OUTPUT);
    digitalWrite(7, LOW);
    pinMode(6, OUTPUT);
    digitalWrite(6, LOW);
    pinMode(5, OUTPUT);
    digitalWrite(5, LOW);
    pinMode(4, OUTPUT);
    digitalWrite(4, LOW);
    pinMode(3, OUTPUT);
    digitalWrite(3, LOW);
    pinMode(2, OUTPUT);
    digitalWrite(2, LOW);
    pinMode(1, OUTPUT);
    digitalWrite(1, HIGH);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 3
    //###########################################################// 
    IKSequencingControl(0 , 235 , 210 , 0 , 512 , 256 , 2000 , 1000, playState);
    //DIO3
    pinMode(7, OUTPUT);
    digitalWrite(7, LOW);
    pinMode(6, OUTPUT);
    digitalWrite(6, LOW);
    pinMode(5, OUTPUT);
    digitalWrite(5, LOW);
    pinMode(4, OUTPUT);
    digitalWrite(4, LOW);
    pinMode(3, OUTPUT);
    digitalWrite(3, LOW);
    pinMode(2, OUTPUT);
    digitalWrite(2, HIGH);
    pinMode(1, OUTPUT);
    digitalWrite(1, HIGH);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 4
    //###########################################################// 
    IKSequencingControl(0 , 235 , 210 , 0 , 512 , 256 , 2000 , 1000, playState);
    //DIO7
    pinMode(7, OUTPUT);
    digitalWrite(7, LOW);
    pinMode(6, OUTPUT);
    digitalWrite(6, LOW);
    pinMode(5, OUTPUT);
    digitalWrite(5, LOW);
    pinMode(4, OUTPUT);
    digitalWrite(4, LOW);
    pinMode(3, OUTPUT);
    digitalWrite(3, HIGH);
    pinMode(2, OUTPUT);
    digitalWrite(2, HIGH);
    pinMode(1, OUTPUT);
    digitalWrite(1, HIGH);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 5
    //###########################################################// 
    IKSequencingControl(0 , 235 , 210 , 0 , 512 , 256 , 2000 , 1000, playState);
    //DIO15
    pinMode(7, OUTPUT);
    digitalWrite(7, LOW);
    pinMode(6, OUTPUT);
    digitalWrite(6, LOW);
    pinMode(5, OUTPUT);
    digitalWrite(5, LOW);
    pinMode(4, OUTPUT);
    digitalWrite(4, HIGH);
    pinMode(3, OUTPUT);
    digitalWrite(3, HIGH);
    pinMode(2, OUTPUT);
    digitalWrite(2, HIGH);
    pinMode(1, OUTPUT);
    digitalWrite(1, HIGH);
    //###########################################################// 

 delay(100);
 Serial.println("Pausing Sequencing Mode."); 
 delay(500);
 //uncomment this to  put the arm in sleep position after a sequence
 //PutArmToSleep();
}

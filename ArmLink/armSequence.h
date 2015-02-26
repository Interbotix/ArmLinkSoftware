//Arm 3
//Sequence 3
//Mode 2
//Orientation 1
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
    g_bIKMode = IKM_CYLINDRICAL;
    //###########################################################//
    // SEQUENCE 1
    //###########################################################// 
    IKSequencingControl(2048 , 250 , 225 , 0 , 512 , 256 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 2
    //###########################################################// 
    IKSequencingControl(2048 , 250 , 225 , 0 , 512 , 512 , 0 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 3
    //###########################################################// 
    IKSequencingControl(2048 , 175 , 139 , 0 , 512 , 512 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 4
    //###########################################################// 
    IKSequencingControl(1928 , 248 , 150 , 0 , 512 , 512 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 5
    //###########################################################// 
    IKSequencingControl(1941 , 286 , 131 , 0 , 512 , 512 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 6
    //###########################################################// 
    IKSequencingControl(1941 , 286 , 131 , 0 , 512 , 251 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 7
    //###########################################################// 
    IKSequencingControl(1939 , 286 , 161 , 0 , 512 , 260 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 8
    //###########################################################// 
    IKSequencingControl(1939 , 286 , 194 , 0 , 512 , 260 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 9
    //###########################################################// 
    IKSequencingControl(1939 , 286 , 244 , 0 , 512 , 260 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 10
    //###########################################################// 
    IKSequencingControl(1939 , 163 , 184 , 0 , 512 , 260 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 11
    //###########################################################// 
    IKSequencingControl(2424 , 163 , 184 , 0 , 512 , 260 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 12
    //###########################################################// 
    IKSequencingControl(2481 , 299 , 184 , 0 , 512 , 260 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 13
    //###########################################################// 
    IKSequencingControl(2481 , 299 , 184 , 0 , 160 , 260 , 2032 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 14
    //###########################################################// 
    IKSequencingControl(2481 , 299 , 184 , 0 , 512 , 260 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 15
    //###########################################################// 
    IKSequencingControl(2424 , 163 , 184 , 0 , 512 , 260 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 16
    //###########################################################// 
    IKSequencingControl(1939 , 286 , 244 , 0 , 512 , 260 , 512 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 17
    //###########################################################// 
    IKSequencingControl(1939 , 286 , 221 , 0 , 512 , 260 , 512 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 18
    //###########################################################// 
    IKSequencingControl(1939 , 286 , 194 , 0 , 512 , 260 , 512 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 19
    //###########################################################// 
    IKSequencingControl(1939 , 286 , 161 , 0 , 512 , 260 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 20
    //###########################################################// 
    IKSequencingControl(1941 , 286 , 131 , 0 , 512 , 251 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 21
    //###########################################################// 
    IKSequencingControl(1941 , 286 , 131 , 0 , 512 , 512 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 22
    //###########################################################// 
    IKSequencingControl(2048 , 175 , 139 , 0 , 512 , 512 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 23
    //###########################################################// 
    IKSequencingControl(2072 , 247 , 124 , 0 , 512 , 512 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 24
    //###########################################################// 
    IKSequencingControl(2072 , 280 , 124 , 0 , 512 , 512 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 25
    //###########################################################// 
    IKSequencingControl(2072 , 280 , 124 , 0 , 512 , 251 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 26
    //###########################################################// 
    IKSequencingControl(2072 , 280 , 152 , 0 , 512 , 251 , 512 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 27
    //###########################################################// 
    IKSequencingControl(2072 , 280 , 169 , 0 , 512 , 251 , 512 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 28
    //###########################################################// 
    IKSequencingControl(2072 , 280 , 235 , 0 , 512 , 251 , 640 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 29
    //###########################################################// 
    IKSequencingControl(2525 , 280 , 235 , 0 , 515 , 254 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 30
    //###########################################################// 
    IKSequencingControl(2525 , 280 , 235 , 0 , 10 , 254 , 4064 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 31
    //###########################################################// 
    IKSequencingControl(2525 , 280 , 235 , 0 , 512 , 251 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 32
    //###########################################################// 
    IKSequencingControl(2072 , 280 , 235 , 0 , 512 , 251 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 33
    //###########################################################// 
    IKSequencingControl(2072 , 280 , 169 , 0 , 512 , 251 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 34
    //###########################################################// 
    IKSequencingControl(2072 , 280 , 152 , 0 , 512 , 251 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 35
    //###########################################################// 
    IKSequencingControl(2072 , 280 , 124 , 0 , 512 , 251 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 36
    //###########################################################// 
    IKSequencingControl(2072 , 280 , 124 , 0 , 512 , 512 , 1024 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 37
    //###########################################################// 
    IKSequencingControl(2072 , 247 , 124 , 0 , 512 , 512 , 512 , 10, playState);
    //###########################################################// 

    //###########################################################//
    // SEQUENCE 38
    //###########################################################// 
    IKSequencingControl(2048 , 175 , 139 , 0 , 512 , 512 , 1024 , 10, playState);
    //###########################################################// 

 delay(100);
 Serial.println("Pausing Sequencing Mode."); 
 delay(500);
 //uncomment this to  put the arm in sleep position after a sequence
 //PutArmToSleep();
}

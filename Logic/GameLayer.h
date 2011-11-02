//
//  GameLayer.h
//  Logic
//
//  Created by Pavel Krusek on 10/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//#import "ProgressTimer.h"
#import "ProgTimer.h"
#import "RowStaticScore.h"
#import "RowScore.h"
#import "ScoreNumber.h"
#import "Thunderbolt.h"
#import "RandomThunderbolt.h"
#import "ThunderboltVO.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface GameLayer : CCLayerColor <UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate> {
    UIViewController *mailController;
    
    BOOL cheat;
    GameDifficulty currentDifficulty;//obtiznost hry
    float difficultyPadding;//rozestup figur podle obtiznosti
    int gameTime;//celkovy cas hry
    int activeRow;//aktivni rada
    BOOL isEndRow;//je plny radek?
    BOOL isEndOfGame;
    BOOL isCareer;
    float trans;//NOTE NESTACI JUMP?
    int places;//spravne mista
    int colors;//spravne barvy
    int score;//skore
    int lastTime;//time between rows
    BOOL isRetina;
    BOOL isMovable;//after predefined row
    float jump;
    BOOL isWinner;//level success?
    int maxScore;//present max score for final animations - level end
    int fid;
    
    CGPoint tramwayLocation;
    
    //tutorial
    int tutorStep;
    BOOL isTutor;
    BOOL tutorWillContinue;
    BOOL tutorJoin;    
    CCLayer *tutorLayer;
    CCLayerColor *tutorBlackout;
    CCSprite *tutorFinger;
    CCSprite *screenSprite;
    CCSprite *pincl1;
    CCSprite *pincl2;
    CCLabelBMFont *tutorTxt;
    
    ScoreCalc *scoreCalc;//score object
    RandomThunderbolt *randomThunderbolt;//lightning object
    
    Figure *selSprite;//vybrany sprite
    CCSprite *targetSprite;//je zamereny target? (umistit nebo zpet na zakladnu)
    
    ALuint tutorSound;
    ALuint ciselnik;
    
    UIPanGestureRecognizer *panRecognizer;
    UILongPressGestureRecognizer *longPress;
    
    //arrays
    CCArray *greenLights;
    CCArray *orangeLights;
    NSMutableArray *morphingSphereFrames;
    CCArray *movableFigures;//figury ve hre
    CCArray *targets;//cile na rade pro figury
    NSMutableArray *currentCode;
    NSMutableArray *userCode;
    CCArray *placeNumbers;
    CCArray *colorNumbers;
    CCArray *scoreLabelArray;
    
    //timer
    //ProgressTimer *timer;
    ProgTimer *timer;
    Mask *timerMask;
    
    //layers
    CCSpriteBatchNode *sphereNode;
    CCLayer *movableNode;
    CCLayer *figuresNode;
    CCLayer *deadFiguresNode;
    CCLayer *clippingNode;
    CCLayer *scoreTime;
    CCLayer *scoreLayer;
    CCLayerColor *blackout;
    CCLayerColor *blackout2;
    
    //menus
    CCMenu *pauseMenu;
    CCMenu *endGameMenu;    
    CCMenu *finalMenu;
    
    //sprites
    CCSprite *highlightSprite;//upozorneni, ze target je zameren - modre kolecko
    CCSprite *codeBase;//baze pro kod nahore
    //rotors
    CCSprite *rotorLeftLayer;
    CCSprite *rotorRightLayer;
    CCSprite *rotorLeft;
    CCSprite *rotorRight;
    CCSprite *rotorLeftInside;
    CCSprite *rotorRightInside;
    CCSprite *rotorLeftLight;
    CCSprite *rotorRightLight;
    
    CCSprite *mantle;//krytka pod rotorem
    CCSprite *base;//base pro 8 pinclu dole
    CCSprite *sphereLight;//svetlo pod kouli
    //SPHERE
    CCSprite *sphere;//sphere
    CCAnimation *sphereAnim;
    CCSequence *sphereSeq;
    
    //panels    
    CCSprite *scorePanel;
    CCSprite *replayPanel;//only single
    CCSprite *continuePanel;//only career
    CCSprite *gameMenuPanel;//for both
    
    //copy
    CCLabelBMFont *failLabelSmall;
    CCLabelBMFont *failLabelBig;
    CCLabelBMFont *wdBig;
    CCLabelBMFont *superBig;
    CCLabelBMFont *superSmall;
    CCLabelBMFont *movesLabelBig;
    CCLabelBMFont *timeLabelBig;
    CCLabelBMFont *infoTxt;
    
    //particles
    CCParticleSystem *dustSystem;
    CCParticleSystem *smokeSystem1;
    CCParticleSystem *smokeSystem2;
//    CCParticleSystem *sparkleSystem;
    CCParticleSystem *confirmSystem;
    
    //end game - moving labels
    CCLayer *finalTimeLayer;
    CCLayer *finalScoreLayer;
    CCLayer *final2ScoreLayer;
    CCLayer *final2TimeLayer;
    CCLayer *final3TimeLayer;
    CCLayer *finalScoreLabel;
    CCArray *finalScoreArray;
    CCArray *final1TimeArray;
    CCArray *final2TimeArray;
    
    CCArray *movingTime;
    CCArray *movingScore;
    
}

@end

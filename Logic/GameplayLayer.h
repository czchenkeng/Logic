//
//  GameplayLayer.h
//  Logic
//
//  Created by Pavel Krusek on 5/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Figure.h"
#import "RowScore.h"
#import "RowStaticScore.h"
#import "Constants.h"
#import "GameManager.h"
#import "Utils.h"
#import "ProgressTimer.h"
#import "Mask.h"
#import "FacebookViewController.h"
#import "ScoreNumber.h"
#import "Blackout.h"
#import "ScoreCalc.h"

@interface GameplayLayer : CCLayerColor <UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate> {
    UIViewController *mailController;
    
    UIPanGestureRecognizer *panRecognizer;
    UILongPressGestureRecognizer *longPress;
    UITapGestureRecognizer *singleTap;
    
    GameDifficulty currentDifficulty;//obtiznost hry
    float difficultyPadding;//rozestup figur podle obtiznosti
    int activeRow;//aktivni rada
    BOOL isEndRow;//je plny radek?
    int places;//spravne mista
    int colors;//spravne barvy
    int score;//skore
    int lastTime;//time between rows
    int gameTime;
    BOOL isMovable;//after predefined row
    float trans;
    float spriteEndPosition;
    BOOL isWinner;//level success?
    int maxScore;//present max score for final animations - level end 
    float jump;
    int fid;
    
    int tutorStep;
    BOOL isTutor;
    BOOL tutorWillContinue;
    BOOL tutorJoin;
    
    ScoreCalc *scoreCalc;
    
    BOOL isCareer;
    BOOL isRetina;
    BOOL isEndOfGame;
    
    Figure *selSprite;//vybrany sprite
    CCSprite *targetSprite;//je zamereny target? (umistit nebo zpet na zakladnu)
    
    //timer
    ProgressTimer *timer;
    Mask *timerMask;
    
    //batches
    CCSpriteBatchNode *sphereNode;
    
    //lightning
    CCSpriteBatchNode *lightningNode;
    NSMutableArray *lightningSphereFrames;
    CCAnimation *lightningAnim;
    
    //layers
    CCLayer *movableNode;
    CCLayer *figuresNode;
    CCLayer *deadFiguresNode;
    CCLayer *clippingNode;
    CCLayer *scoreTime;
    CCLayer *scoreLayer;
    CCLayerColor *blackout;
    CCLayerColor *blackout2;
    CCLayer *tutorLayer;
    CCLayerColor *tutorBlackout;
    CCSprite *tutorFinger;
    CCSprite *screenSprite;
    CCSprite *pincl1;
    CCSprite *pincl2;
    CCLabelBMFont *tutorTxt;
    
    CCSprite *rotorLeftLayer;
    CCSprite *rotorRightLayer;
    
    
    //arrays
    NSMutableArray *morphingSphereFrames;
    CCArray *greenLights;
    CCArray *orangeLights;
    CCArray *movableFigures;//figury ve hre
    CCArray *targets;//cile na rade pro figury
    NSMutableArray *currentCode;
    NSMutableArray *userCode;
    CCArray *placeNumbers;
    CCArray *colorNumbers;
    CCArray *scoreLabelArray;
    
    //sprites
    CCSprite *highlightSprite;//upozorneni, ze target je zameren - modre kolecko
    CCSprite *codeBase;//baze pro kod nahore
    //rotors
    CCSprite *rotorLeft;
    CCSprite *rotorRight;
    CCSprite *rotorLeftInside;
    CCSprite *rotorRightInside;
    CCSprite *rotorLeftLight;
    CCSprite *rotorRightLight;
    
    CCMenu *pauseMenu;
    CCMenu *endGameMenu;
    
    CCMenu *finalMenu;
    
    CCSprite *mantle;//krytka pod rotorem
    CCSprite *sphereLight;//svetlo pod kouli
    //SPHERE
    CCSprite *sphere;//sphere
    CCAnimation *sphereAnim;
    CCSequence *sphereSeq;
    
    CCSprite *base;//base pro 8 pinclu dole
    
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
    CCParticleSystem *sparkleSystem;
    CCParticleSystem *confirmSystem;
    CCParticleSystem *swipeSystem;
    
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
    
    ALuint tutorSound;
    ALuint ciselnik;
    
    
}


@end

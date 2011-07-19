//
//  GameplayLayer.h
//  Logic
//
//  Created by Pavel Krusek on 5/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
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


@interface GameplayLayer : CCLayerColor <UIGestureRecognizerDelegate> {    
    UIPanGestureRecognizer *panRecognizer;
    UITapGestureRecognizer *singleTapRecognizer;
    UISwipeGestureRecognizer *swipeRightRecognizer;
    UISwipeGestureRecognizer *swipeUpRecognizer;
    UISwipeGestureRecognizer *swipeDownRecognizer;
    
    GameDifficulty currentDifficulty;//obtiznost hry
    float difficultyPadding;//rozestup figur podle obtiznosti
    int activeRow;//aktivni rada
    BOOL isEndRow;//je plny radek?
    int places;//spravne mista
    int colors;//spravne barvy
    int score;//skore
    int lastTime;
    
    Figure *selSprite;//vybrany sprite
    CCSprite *targetSprite;//je zamereny target? (umistit nebo zpet na zakladnu)
    
    //timer
    ProgressTimer *timer;
    
    //batches
    CCSpriteBatchNode *sphereNode;
    
    //layers
    CCLayer *movableNode;
    CCLayer *figuresNode;
    CCLayer *deadFiguresNode;
    CCLayer *clippingNode;
    CCLayer *scoreTime;
    CCLayer *scoreLayer;
    
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
    
    CCSprite *mantle;//krytka pod rotorem
    CCSprite *sphereLight;//svetlo pod kouli
    //SPHERE
    CCSprite *sphere;//sphere
    CCAnimation *sphereAnim;
    CCSequence *sphereSeq;
    
    CCSprite *base;//base pro 8 pinclu dole
    
    //particles
    CCParticleSystem *dustSystem;
    CCParticleSystem *smokeSystem;
    
        
}


@end

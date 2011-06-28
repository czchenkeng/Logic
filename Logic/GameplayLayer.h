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
#import "Constants.h"
#import "GameManager.h"
#import "Utils.h"
#import "ProgressTimer.h"
#import "Mask.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"


@interface GameplayLayer : CCLayerColor <CCStandardTouchDelegate> {
    FMDatabase *db;
    
    CCLayer *clippingNode;
    CCLayer *movableNode;
    CCLayer *figuresNode;
    
    CCArray *deadFigures;
    
    CCSprite *codeBase;
    CCSprite *rotorLeftMain;
    CCSprite *rotorRightMain;
    CCSprite *rotorLeft;
    CCSprite *rotorRight;
    CCSprite *rotorLeftInside;
    CCSprite *rotorRightInside;
    CCSprite *rotorLeftLight;
    CCSprite *rotorRightLight;
    CCSprite *krytka;
    CCSprite *base;
    CCSprite *cheat;
    
    CCSpriteBatchNode *sphereNode;
    
    NSMutableArray *morphingSphereFrames;
    CCSprite *sphere;
    CCSprite *sphereLight;
    
    CCAnimation *sphereAnim;
    CCSequence *sphereSeq;
    
    CCArray *greenLights;
    CCArray *orangeLights;
    
    CCArray *placeNumbers;
    CCArray *colorNumbers;
    
    CCSpriteBatchNode *assetsLevelBgNode;
    CCSpriteBatchNode *assetsLevelNode;
    Figure *selSprite;
    CCSprite *targetSprite;
    CCSprite *highlightSprite;
    //CCSpriteBatchNode *spritesBgNode;
    CCArray *movableFigures;
    NSMutableArray *currentCode;
    CCArray *targets;
    NSMutableArray *userCode;
    GameDifficulty currentDifficulty;
    int activeRow;
    //int currentPlace;
    BOOL isEndRow;
    BOOL isMovable;
    BOOL movableFlag;
    
    CGPoint touchOrigin;
    CGPoint touchStop;
    
    float dislocation;
    
    int places;
    int colors;
    
    NSMutableArray *touchArray;
    
    float difficultyPadding;
    
    int lastPlace;//asi vyhodit?
    int dir;
}

//@property GameDifficulty currentDifficulty;

- (void) addFigures;
- (void) constructRowWithIndex:(int)row;
- (void) sphereAnimEnded;
//- (void) generateCode;

@end

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


@interface GameplayLayer : CCLayerColor <CCStandardTouchDelegate> {
    CCLayer *movableNode;
    CCLayer *figuresNode;
    
    CCSprite *codeBase;
    CCSprite *rotor;
    CCSpriteBatchNode *sphereNode;
    
    NSMutableArray *morphingSphereFrames;
    CCSprite *sphere;
    
    CCAnimation *sphereAnim;
    CCSequence *sphereSeq;
    
    CCArray *greenLights;
    CCArray *orangeLights;
    
    CCSpriteBatchNode *assetsLevelBgNode;
    CCSpriteBatchNode *assetsLevelNode;
    Figure *selSprite;
    CCSprite *targetSprite;
    CCSprite *highlightSprite;
    //CCSpriteBatchNode *spritesBgNode;
    CCArray *movableFigures;
    CCArray *currentCode;
    CCArray *targets;
    NSMutableArray *userCode;
    GameDifficulty currentDifficulty;
    int activeRow;
    //int currentPlace;
    BOOL isEndRow;
    
    CGPoint touchOrigin;
    CGPoint touchStop;
    
    float dislocation;
    
    int places;
    int colors;
}

//@property GameDifficulty currentDifficulty;

- (void) addFigures;
- (void) constructRowWithIndex:(int)row;
- (void) sphereAnimEnded;
//- (void) generateCode;

@end

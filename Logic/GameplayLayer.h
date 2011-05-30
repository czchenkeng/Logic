//
//  GameplayLayer.h
//  Logic
//
//  Created by Pavel Krusek on 5/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Figure.h"
#import "Constants.h"


@interface GameplayLayer : CCLayer {
    //NSMutableArray *movableFigures;
    //CCSprite * selSprite;
    Figure *selSprite;
    CCSpriteBatchNode *spritesBgNode;
    CCArray *movableFigures;
    GameDifficulty currentDifficulty;
    CCArray *currentCode;
}

@property GameDifficulty currentDifficulty;

- (void) addFigures;
- (void) generateCode;

@end

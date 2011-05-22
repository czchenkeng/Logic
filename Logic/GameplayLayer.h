//
//  GameplayLayer.h
//  Logic
//
//  Created by Pavel Krusek on 5/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameplayLayer.h"


@interface GameplayLayer : CCLayer {
    NSMutableArray *movableFigures;
    CCSprite * selSprite;
    CCSpriteBatchNode *spritesBgNode;
    //CCArray *movableFigures;
}

- (void) addFigures;

@end

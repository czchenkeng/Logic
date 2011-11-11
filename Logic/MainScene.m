//
//  MainScene.m
//  Logic
//
//  Created by Pavel Krusek on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainScene.h"


@implementation MainScene
- (id) init {
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    self = [super init];
    if (self != nil) {
        mainLayer = [MainGameLayer node];
        [self addChild:mainLayer];
    }
    return self;
}

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    [[GameManager sharedGameManager] clearTextures];
    [super dealloc];    
}

@end
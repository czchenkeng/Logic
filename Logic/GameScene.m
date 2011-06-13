//
//  GameScene.m
//  Logic
//
//  Created by Pavel Krusek on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "GameManager.h"

@implementation GameScene

- (id) init {
    self = [super init];
    if (self != nil) {
        GameplayLayer* gameLayer = [GameplayLayer node];
        [self addChild:gameLayer z:1 tag:1];
    }
    return self;
}

@end

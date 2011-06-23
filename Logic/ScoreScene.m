//
//  Score.m
//  Logic
//
//  Created by Pavel Krusek on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScoreScene.h"


@implementation ScoreScene

- (id) init {
    self = [super init];
    if (self != nil) {
        scoreLayer = [ScoreLayer node];
        [self addChild:scoreLayer z:1];
    }
    return self;
}

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    
    [super dealloc];
}

@end

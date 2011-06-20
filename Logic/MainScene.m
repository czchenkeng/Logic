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
    self = [super init];
    if (self != nil) {
        mainLayer = [MainLayer node];
        [self addChild:mainLayer];
    }
    return self;
}

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
//    [mainLayer release];
//    mainLayer = nil;
    [super dealloc];    
}

@end
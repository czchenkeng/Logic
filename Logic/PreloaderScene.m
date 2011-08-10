//
//  PreloaderScene.m
//  Logic
//
//  Created by Pavel Krusek on 8/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PreloaderScene.h"


@implementation PreloaderScene

- (id) init {
    self = [super init];
    if (self != nil) {
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
        PreloaderLayer *preloaderLayer = [PreloaderLayer node];
        [self addChild:preloaderLayer z:1];
    }
    return self;
}

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    
    [super dealloc];
}

@end

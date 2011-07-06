//
//  CareerScene.m
//  Logic
//
//  Created by Pavel Krusek on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CareerScene.h"


@implementation CareerScene

- (id) init {
    self = [super init];
    if (self != nil) {
        careerLayer = [CareerLayer node];
        [self addChild:careerLayer z:0];
        
        controlLayer = [ControlsLayer node];
        [self addChild:controlLayer z:1];
    }
    return self;
}

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    
    [super dealloc];
}

@end
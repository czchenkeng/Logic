//
//  CareerLayer.m
//  Logic
//
//  Created by Pavel Krusek on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CareerLayer.h"


@implementation CareerLayer

- (id) init {
    self = [super init];
    if (self != nil) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Career.plist"];
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"logik_levels.png"];
        background.position = ccp(96.00, 282.00);
        [self addChild:background z:1];
        
        CCSprite *sprite;
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"shadow.png"];
        sprite.anchorPoint = ccp(0.00, 0.00);
        [self addChild:sprite z:2];
    }
    return self;
}

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    
    [super dealloc];
}

@end

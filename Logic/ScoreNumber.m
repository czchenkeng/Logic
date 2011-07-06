//
//  ScoreNumber.m
//  Logic
//
//  Created by Pavel Krusek on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScoreNumber.h"


@implementation ScoreNumber

- (id) init {
    self = [super init];
    if (self != nil) {
        numbers = [CCSprite spriteWithSpriteFrameName:@"logik_number_score18x36.png"];
        numbers.anchorPoint = CGPointMake(0, 1);
        numbers.position = ccp(0, 18);
        [self addChild:numbers z:1];
    }
    return self;
}

- (void) endAnimation {
//    [numbers removeFromParentAndCleanup:YES];
//    [_mask removeFromParentAndCleanup:YES];
}

- (void) moveToPosition:(int)position {
    //_mask = mask;
    CCSequence *moveNumbers = [CCSequence actions:
                               [CCDelayTime actionWithDuration: 0.4f],
                               [CCMoveTo actionWithDuration:.5 position:CGPointMake(numbers.position.x, 18*(position+2))],
                               [CCCallFunc actionWithTarget:self selector:@selector(endAnimation)],
                               nil];
    [numbers runAction:moveNumbers];
}


- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    [super dealloc];
}

@end
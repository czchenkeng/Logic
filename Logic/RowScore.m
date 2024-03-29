//
//  RowScore.m
//  Logic
//
//  Created by Pavel Krusek on 6/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RowScore.h"


@implementation RowScore

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
    [numbers removeFromParentAndCleanup:YES];
    [_mask removeFromParentAndCleanup:YES];
}

- (void) moveToPosition:(int)position andMask:(Mask *)mask {
    _mask = mask;
    //CCMoveTo *moveNumbers = [CCMoveTo actionWithDuration:.3 position:CGPointMake(numbers.position.x, 18*(position+2))];
    CCSequence *moveNumbers = [CCSequence actions:
                               [CCMoveTo actionWithDuration:.3 position:CGPointMake(numbers.position.x, 18*(position+2))],
                               [CCCallFunc actionWithTarget:self selector:@selector(endAnimation)],
                               nil];
    [numbers runAction:moveNumbers];
    //[moveNumbers release];
    //CCLOG(@"moveNumbers retain count %i", [moveNumbers retainCount]);
    //CCLOG(@"numbers retain count %i", [numbers retainCount]);
}

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    [super dealloc];
}

@end
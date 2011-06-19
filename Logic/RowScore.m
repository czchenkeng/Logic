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
        [self addChild:numbers];
    }
    return self;
}

- (void) moveToPosition:(int)position {
    CCMoveTo *moveNumbers = [CCMoveTo actionWithDuration:.3 position:CGPointMake(numbers.position.x, 18*(position+1))];
    [numbers runAction:moveNumbers];
    //[moveNumbers release];
    //CCLOG(@"moveNumbers retain count %i", [moveNumbers retainCount]);
    //CCLOG(@"numbers retain count %i", [numbers retainCount]);
}

@end
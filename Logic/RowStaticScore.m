//
//  RowStaticScore.m
//  Logic
//
//  Created by Pavel Krusek on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RowStaticScore.h"


@implementation RowStaticScore

- (id) init {
    self = [super init];
    if (self != nil) {
        empty = [CCSprite spriteWithSpriteFrameName:@"empty.png"];
        empty.anchorPoint = CGPointMake(0, 0);
        [self addChild:empty];
    }
    return self;
}

- (void) showNumber:(int)position {
    [empty removeFromParentAndCleanup:YES];
    number = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%i.png", position]];
    number.anchorPoint = CGPointMake(0, 0);
    [self addChild:number];
}

- (void) dealloc {
    [super dealloc];
}

@end

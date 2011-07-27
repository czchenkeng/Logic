//
//  City.m
//  Logic
//
//  Created by Pavel Krusek on 7/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "City.h"


@implementation City

@synthesize buttonX, buttonY, idCity, isActive, belongs, difficulty;

- (id) init {
    self = [super init];
    if (self != nil) {
        CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
        isActive = NO;
        self.visible = NO;
    }
    return self;
}

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    [belongs release];
    belongs = nil;
    [difficulty release];
    difficulty = nil;
    [super dealloc];
}

@end

//
//  Wire.m
//  Logic
//
//  Created by Pavel Krusek on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Wire.h"


@implementation Wire

@synthesize lights;

- (id) init {
    self = [super init];
    if (self != nil) {
        CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
        self.visible = NO;
    }
    return self;
}

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    [lights release];
    lights = nil;
    [super dealloc];
}

@end

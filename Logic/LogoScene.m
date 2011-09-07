//
//  LogoScene.m
//  Logic
//
//  Created by Apple on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LogoScene.h"


@implementation LogoScene

- (id) init {
    self = [super init];
    if (self != nil) {
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
        LogoLayer *logoLayer = [LogoLayer node];
        [self addChild:logoLayer z:1];
    }
    return self;
}

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    
    [super dealloc];
}
@end

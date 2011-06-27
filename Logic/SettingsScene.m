//
//  SettingsScene.m
//  Logic
//
//  Created by Pavel Krusek on 6/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsScene.h"


@implementation SettingsScene

- (id) init {
    self = [super init];
    if (self != nil) {
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
        SettingsLayer *settingsLayer = [SettingsLayer node];
        [self addChild:settingsLayer];
    }
    return self;
}

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    
    [super dealloc];
}

@end

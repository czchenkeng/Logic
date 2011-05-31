//
//  MainScene.m
//  Logic
//
//  Created by Pavel Krusek on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainScene.h"


@implementation MainScene
- (id) init {
    self = [super init];
    if (self != nil) {
        MainLayer *mainLayer = [MainLayer node];
        [self addChild:mainLayer];
    }
    return self;
}
@end
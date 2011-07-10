//
//  HowToLayer.m
//  Logic
//
//  Created by Pavel Krusek on 7/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HowToLayer.h"


@implementation HowToLayer

- (id) init {
    self = [super init];
    if (self != nil) {
        CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Howto.plist"];
        
        float leftAlign = -80;
        CCSprite *sprite;
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"howto_bg.png"];
        [sprite setPosition:ccp(screenSize.width/2 + 10, screenSize.height/2 - 51)];
        [self addChild:sprite z:1];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"howto.png"];
        [sprite setPosition:ccp(160.00, 323.50)];
        [self addChild:sprite z:2];
        
        howTo = [CCLayer node];
        [howTo setPosition:ccp(screenSize.width/2, screenSize.height/2 + 40)];
        [self addChild:howTo z:3];
        
        CCLabelBMFont *goalLabel = [CCLabelBMFont labelWithString:@"GOAL" fntFile:@"GloucesterHt.fnt"];
        [howTo addChild:goalLabel];
        
        CCLabelBMFont *goalText = [CCLabelBMFont labelWithString:@"Break the secret code! \nRemember the colors may occur \nmore than once." fntFile:@"BellGothicBoldHt.fnt"];
        goalText.anchorPoint = ccp(0, 0.5);
        [goalText setPosition:ccp(leftAlign, -40)];
        [howTo addChild:goalText];
        
        CCSprite *screen = [CCSprite spriteWithSpriteFrameName:@"screen.png"];
        [screen setPosition:ccp(0.00, -140)];
        [howTo addChild:screen];
        
    }
    return self;
}

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    
    [super dealloc];
}

@end

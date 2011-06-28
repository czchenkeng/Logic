//
//  CareerLayer.m
//  Logic
//
//  Created by Pavel Krusek on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CareerLayer.h"


@implementation CareerLayer

- (void) buttonTapped:(CCMenuItem *)sender { 
    switch (sender.tag) {
        case kButtonBack:
            CCLOG(@"TAP ON BACK");
            [[GameManager sharedGameManager] runSceneWithID:kSettingsScene andTransition:kSlideInL];
            break;
        default:
            CCLOG(@"Logic debug: Unknown ID, cannot tap button");
            return;
            break;
    }
}


- (id) init {
    self = [super init];
    if (self != nil) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Career.plist"];
        
        Mask *mask = [Mask maskWithRect:CGRectMake(0, 0, 960, 640)];
        [self addChild:mask z:1];
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"logik_levels.png"];
        background.position = ccp(96.00, 282.00);
        [mask addChild:background z:1];
        
        CCSprite *sprite;
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"shadow.png"];
        sprite.anchorPoint = ccp(0.00, 0.00);
        [mask addChild:sprite z:2];
        
        CCSprite *buttonBackOff = [CCSprite spriteWithSpriteFrameName:@"back_off.png"];
        CCSprite *buttonBackOn = [CCSprite spriteWithSpriteFrameName:@"back_on.png"];
        
        CCMenuItem *backItem = [CCMenuItemSprite itemFromNormalSprite:buttonBackOff selectedSprite:buttonBackOn target:self selector:@selector(buttonTapped:)];
        backItem.tag = kButtonBack;
        backItem.position = ccp(29.50, 453.50);
        
        CCMenu *topMenu = [CCMenu menuWithItems:backItem, nil];
        topMenu.position = CGPointZero;
        [self addChild:topMenu z:3];
    }
    return self;
}

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    
    [super dealloc];
}

@end

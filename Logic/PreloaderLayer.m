//
//  PreloaderLayer.m
//  Logic
//
//  Created by Pavel Krusek on 8/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PreloaderLayer.h"

@interface PreloaderLayer (PrivateMethods)
- (CCSprite *) maskedSpriteWithSprite:(CCSprite *)textureSprite maskSprite:(CCSprite *)maskSprite;
@end


@implementation PreloaderLayer

- (void) buttonTapped:(id)sender {
    if ([[GameManager sharedGameManager] gameInProgress]) {
        CCLOG(@"co je?");
        [[GameManager sharedGameManager] runSceneWithID:kGameScene andTransition:kSlideInR];
    } else {
        [[GameManager sharedGameManager] runSceneWithID:kMainScene andTransition:kSlideInR];
        //[[GameManager sharedGameManager] runSceneWithID:kCareerScene andTransition:kNoTransition];
        //[[GameManager sharedGameManager] runSceneWithID:kScoreScene andTransition:kNoTransition];
    }
    //[[GameManager sharedGameManager] runSceneWithID:kGameScene andTransition:kNoTransition];
    //[[GameManager sharedGameManager] runSceneWithID:kCareerScene andTransition:kNoTransition];
    //[[GameManager sharedGameManager] runSceneWithID:kMainScene andTransition:kNoTransition];
    //[[GameManager sharedGameManager] runSceneWithID:kScoreScene];
}

- (id) init {
    self = [super init];
    if (self != nil) {
        NSString *hw = @"";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            hw = @"Pad";
        }
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"LevelBg%@.plist", hw]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"Level%@.plist", hw]];    
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"Animations%@.plist", hw]];        
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Main.plist"];
        
        CCLOG(@"DESC %@", [[CCSpriteFrameCache sharedSpriteFrameCache] description]); 
        
        CCSprite *buttonInfoOff = [CCSprite spriteWithSpriteFrameName:@"i_off.png"];
        CCSprite *buttonInfoOn = [CCSprite spriteWithSpriteFrameName:@"i_on.png"];
        
        CCMenuItem *infoItem = [CCMenuItemSprite itemFromNormalSprite:buttonInfoOff selectedSprite:buttonInfoOn target:self selector:@selector(buttonTapped:)];
        infoItem.tag = kButtonInfo;
        infoItem.anchorPoint = CGPointMake(0.5, 1);
        infoItem.position = ccp(RIGHT_BUTTON_TOP_X, RIGHT_BUTTON_TOP_Y);
        
        CCMenu *topMenu = [CCMenu menuWithItems:infoItem, nil];
        topMenu.position = CGPointZero;
        [self addChild:topMenu z:30];
        
        CCSprite *first = [CCSprite spriteWithSpriteFrameName:@"doors.png"];
        CCSprite *second = [CCSprite spriteWithSpriteFrameName:@"logo.png"];
        
        [first setBlendFunc:(ccBlendFunc){GL_DST_ALPHA, GL_ZERO}];
        [second setBlendFunc:(ccBlendFunc){GL_ONE, GL_ZERO}];
        
        //[first begin];
        [first visit];        
        [second visit];    
        //[first end];

        
        first.position = ccp(222, 222);
        second.position = ccp(200, 230);
        
        [self addChild:first z:1];
        [self addChild:second z:2];
        
        //CCSprite *final = [self maskedSpriteWithSprite:first maskSprite:second];
        
        //[self addChild:final];
        //final.position = ccp(300, 200);
        
        //id move = [CCMoveTo actionWithDuration:5 position:ccp(final.position.x, final.position.y - 150)];
        //[final runAction:move];
    }
    return self;
}

- (CCSprite *)maskedSpriteWithSprite:(CCSprite *)textureSprite maskSprite:(CCSprite *)maskSprite { 
    
    // 1
    CCRenderTexture * rt = [CCRenderTexture renderTextureWithWidth:maskSprite.contentSizeInPixels.width height:maskSprite.contentSizeInPixels.height];
    
    // 2
    maskSprite.position = ccp(maskSprite.contentSize.width/2, maskSprite.contentSize.height/2);
    textureSprite.position = ccp(textureSprite.contentSize.width/2, textureSprite.contentSize.height/2);
    
    // 3
    [maskSprite setBlendFunc:(ccBlendFunc){GL_ONE, GL_ZERO}];
    [textureSprite setBlendFunc:(ccBlendFunc){GL_DST_ALPHA, GL_ZERO}];
    
    // 4
    [rt begin];
    [maskSprite visit];        
    [textureSprite visit];    
    [rt end];
    
    // 5
    CCSprite *retval = [CCSprite spriteWithTexture:rt.sprite.texture];
    retval.flipY = YES;
    return retval;
    
}

@end

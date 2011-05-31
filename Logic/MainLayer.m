//
//  MainLayer.m
//  Logic
//
//  Created by Pavel Krusek on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainLayer.h"


@implementation MainLayer

- (void) runParticle {
    //[self removeChildByTag:1 cleanup:YES];
    CCParticleSystem *system; 
    system = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"Main_rain.plist"];
    
    //CGSize winSize = [[CCDirector sharedDirector] winSize];
    //system.position = CGPointMake(winSize.width/2, 480);
    [self addChild:system z:100 tag:1];
}


- (id) init {
    self = [super initWithColor:ccc4(0,0,0,0)];
    if (self != nil) {
        //[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Main.plist"];

        CCSprite *doors = [CCSprite spriteWithSpriteFrameName:@"doors.png"];
        [doors setPosition:ccp(screenSize.width/2 + 5, screenSize.height/2 - 67)];
        [self addChild:doors z:1];
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background.png"];
        background.anchorPoint = ccp(0,0);
        [self addChild:background z:2];
        
        CCSprite *logoShadow = [CCSprite spriteWithSpriteFrameName:@"logo_shadow.png"];
        [logoShadow setPosition:ccp(screenSize.width/2, screenSize.height/2 + 146)];
        [self addChild:logoShadow z:3];
        
        CCSprite *logo = [CCSprite spriteWithSpriteFrameName:@"logo.png"];
        [logo setPosition:ccp(screenSize.width/2, screenSize.height/2 + 148)];
        [self addChild:logo z:4];
        
        CCSprite *grass = [CCSprite spriteWithSpriteFrameName:@"grass.png"];
        [grass setPosition:ccp(160, 16)];
        [self addChild:grass z:20];
        
        
        //HD sprites
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Hq.plist"];
        
        CCSprite *light = [CCSprite spriteWithSpriteFrameName:@"light.png"];
        light.anchorPoint = ccp(0.5,1);
        [light setPosition:ccp(screenSize.width/2, 496)];
        [self addChild:light z:10];
        light.rotation = -4.0;
        
        
        //Animations
        CCRotateTo *rotRight = [CCRotateBy actionWithDuration:1.1 angle:-8.0];
        CCRotateTo *rotLeft = [CCRotateBy actionWithDuration:1.1 angle:8.0];
        
        CCEaseInOut *easeRight = [CCEaseInOut actionWithAction:rotRight rate:3];
        CCEaseInOut *easeLeft = [CCEaseInOut actionWithAction:rotLeft rate:3];
        
        //CCSequence *rotSeq = [CCSequence actions:rotLeft, rotRight, nil];
        CCSequence *rotSeq = [CCSequence actions:easeLeft, easeRight, nil];
        [light runAction:[CCRepeatForever actionWithAction:rotSeq]];
        
        CCMoveTo *moveLeft = [CCMoveTo actionWithDuration:1.1 position:ccp(screenSize.width/2 - 5, screenSize.height/2 + 146)];
        CCMoveTo *moveRight = [CCMoveTo actionWithDuration:1.1 position:ccp(screenSize.width/2 + 5, screenSize.height/2 + 146)];
        
        CCEaseInOut *easeMoveLeft = [CCEaseInOut actionWithAction:moveLeft rate:3];
        CCEaseInOut *easeMoveRight = [CCEaseInOut actionWithAction:moveRight rate:3];
        
        //CCSequence *moveSeq = [CCSequence actions:moveLeft, moveRight, nil];
        CCSequence *moveSeq = [CCSequence actions:easeMoveLeft, easeMoveRight, nil];
        [logoShadow runAction:[CCRepeatForever actionWithAction:moveSeq]];
        
        //[[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_MAIN];
        [self runParticle];
    }
    return self;
}



@end
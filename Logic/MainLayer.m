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
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        flag = 30;
        flag2 = 0;
        lightOn = YES;
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
        
        lightOff = [CCSprite spriteWithSpriteFrameName:@"lightOff.png"];
        lightOff.anchorPoint = ccp(0.5,1);
        [lightOff setPosition:ccp(screenSize.width/2, 496)];
        lightOff.rotation = -4.0;
        [self addChild:lightOff z:11];
        lightOff.visible = NO;
        
        //HD sprites
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Hq.plist"];

        light = [CCSprite spriteWithSpriteFrameName:@"light.png"];
        light.anchorPoint = ccp(0.5,1);
        [light setPosition:ccp(screenSize.width/2, 496)];
        light.rotation = -4.0;
        [self addChild:light z:10];

        
        //Animations
        CCRotateTo *rotRight = [CCRotateBy actionWithDuration:1.1 angle:-8.0];
        CCRotateTo *rotLeft = [CCRotateBy actionWithDuration:1.1 angle:8.0];
        
        CCEaseInOut *easeRight = [CCEaseInOut actionWithAction:rotRight rate:3];
        CCEaseInOut *easeLeft = [CCEaseInOut actionWithAction:rotLeft rate:3];
        
        //CCSequence *rotSeq = [CCSequence actions:rotLeft, rotRight, nil];
        CCSequence *rotSeq = [CCSequence actions:easeLeft, easeRight, nil];
        [light runAction:[CCRepeatForever actionWithAction:rotSeq]];
        
        
        CCRotateTo *rotRight1 = [CCRotateBy actionWithDuration:1.1 angle:-8.0];
        CCRotateTo *rotLeft1 = [CCRotateBy actionWithDuration:1.1 angle:8.0];
        
        CCEaseInOut *easeRight1 = [CCEaseInOut actionWithAction:rotRight1 rate:3];
        CCEaseInOut *easeLeft1 = [CCEaseInOut actionWithAction:rotLeft1 rate:3];
        
        //CCSequence *rotSeq1 = [CCSequence actions:rotLeft1, rotRight1, nil];
        CCSequence *rotSeq1 = [CCSequence actions:easeLeft1, easeRight1, nil];
        [lightOff runAction:[CCRepeatForever actionWithAction:rotSeq1]];
        
        CCMoveTo *moveLeft = [CCMoveTo actionWithDuration:1.1 position:ccp(screenSize.width/2 - 5, screenSize.height/2 + 146)];
        CCMoveTo *moveRight = [CCMoveTo actionWithDuration:1.1 position:ccp(screenSize.width/2 + 5, screenSize.height/2 + 146)];
        
        CCEaseInOut *easeMoveLeft = [CCEaseInOut actionWithAction:moveRight rate:3];
        CCEaseInOut *easeMoveRight = [CCEaseInOut actionWithAction:moveLeft rate:3];
        
        //CCSequence *moveSeq = [CCSequence actions:moveLeft, moveRight, nil];
        CCSequence *moveSeq = [CCSequence actions:easeMoveLeft, easeMoveRight, nil];
        [logoShadow runAction:[CCRepeatForever actionWithAction:moveSeq]];
        
        //[[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_MAIN];
        [self runParticle];
        [self scheduleUpdate];
    }
    return self;
}

- (void) update:(ccTime)deltaTime
{
    counter++;
    if (counter == flag) {
        counter = 0;
        if (flag2 == 7) {
            CCLOG(@"LONG INTERVAL");
            flag2 = 0;
            flag = [Utils randomNumberBetween:140 andMax:240];
            lightOff.visible = NO;
            light.visible = YES;
        }else{
            CCLOG(@"SHORT INTERVAL");
            flag = [Utils randomNumberBetween:1 andMax:4];
            lightOff.visible = lightOn;
            light.visible = !lightOn;
            lightOn = !lightOn;
        }
        flag2++;
    }
    //CCLOG(@"counter %i", counter);
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
    //[[GameManager sharedGameManager] runSceneWithID:kGameScene];
    return YES;
}


@end
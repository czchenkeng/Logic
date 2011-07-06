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
    CCSprite *sysSprite = [[CCSprite alloc] init];
    [self addChild:sysSprite z:21 tag:1];
    
    CCParticleSystem *system;
    system = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"Dest1.plist"];
    system.rotation = -5;
    
    CCFadeTo *fadeRain = [CCFadeTo actionWithDuration:2.5f opacity:0];
    CCSequence *rainSeq = [CCSequence actions:[CCDelayTime actionWithDuration: 5.0f], fadeRain, nil];
    
    [sysSprite runAction:rainSeq];

    [sysSprite addChild:system z:21 tag:1];
}


- (void) endAnimation {
    CCLOG(@"transition here %i", nextScene);
    //[[GameManager sharedGameManager] runSceneWithID:nextScene];
}

- (void) animationOut {
    float debugSlow = -0.60;
    
    CCMoveTo *rightGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:ccp(1000.00, 367.00)];
    CCScaleTo *rightGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:5 scaleY:22];
    CCRotateTo *rightGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:0];        
    CCSpawn *moveRightGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], rightGibMoveIn, rightGibScaleInX, rightGibRotationIn, nil];
    
    CCMoveTo *leftGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:ccp(-700.00, 0.00)];
    CCScaleTo *leftGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:5 scaleY:22];
    CCRotateTo *leftGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:0];
    CCSpawn *moveLeftGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], leftGibMoveIn, leftGibScaleInX, leftGibRotationIn, nil];
    
    CCSequence *rightGibCallback = [CCSequence actions:moveRightGibSeq, [CCCallFunc actionWithTarget:self selector:@selector(endAnimation)], nil];
    [rightGib runAction:rightGibCallback];
    [leftGib runAction:moveLeftGibSeq];
}

- (void) buttonTapped:(CCMenuItem *)sender { 
    switch (sender.tag) {
        case kButtonInfo: 
            [self animationOut];
            break;
        case kButtonSettings: 
            [[GameManager sharedGameManager] runSceneWithID:kSettingsScene andTransition:kSlideInR];
            nextScene = kSettingsScene;
            break;
        case kButtonSinglePlay:
            [[GameManager sharedGameManager] runSceneWithID:kGameScene andTransition:kLogicTrans];
            nextScene = kGameScene;
            break;
        case kButtonCareerPlay:
            CCLOG(@"TAP ON CAREER");
            break;
        default:
            CCLOG(@"Logic debug: Unknown ID, cannot tap button");
            return;
            break;
    }
    //[self animationOut];
}

- (void) animationIn {
    float debugSlow = -0.40;
    
    CCMoveTo *rightGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:ccp(225.50, 235.00)];
    CCScaleTo *rightGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:1.0 scaleY:1.0];
    CCRotateTo *rightGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:1];        
    CCSpawn *moveRightGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], rightGibMoveIn, rightGibScaleInX, rightGibRotationIn, nil];
    
    CCMoveTo *leftGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:ccp(100.00, 161.00)];
    CCScaleTo *leftGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:1.0 scaleY:1.0];
    CCRotateTo *leftGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:-2];
    CCSpawn *moveLeftGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], leftGibMoveIn, leftGibScaleInX, leftGibRotationIn, nil];
    
    [rightGib runAction:moveRightGibSeq];
    [leftGib runAction:moveLeftGibSeq];
}

- (void) onEnter {
    CCLOG(@"ON ENTER");
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

- (void) onExit {
    CCLOG(@"ON EXIT");
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}

- (id) init {
    self = [super initWithColor:ccc4(0,0,0,0)];
    if (self != nil) {
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
        flag = 30;
        flag2 = 0;
        lightOn = YES;
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Main.plist"];

        CCSprite *doors = [CCSprite spriteWithSpriteFrameName:@"doors.png"];
        [doors setPosition:ccp(screenSize.width/2 + 5, screenSize.height/2 - 51)];
        [self addChild:doors z:1];
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background.png"];
        background.anchorPoint = ccp(0,0);
        [self addChild:background z:2];
        
        CCSprite *logoShadow = [CCSprite spriteWithSpriteFrameName:@"logo_shadow.png"];
        [logoShadow setPosition:ccp(screenSize.width/2, screenSize.height/2 + 162)];
        [self addChild:logoShadow z:3];
        
        CCSprite *logo = [CCSprite spriteWithSpriteFrameName:@"logo.png"];
        [logo setPosition:ccp(screenSize.width/2, screenSize.height/2 + 164)];
        [self addChild:logo z:4];
        
        CCSprite *grass = [CCSprite spriteWithSpriteFrameName:@"grass.png"];
        [grass setPosition:ccp(160, 16)];
        [self addChild:grass z:20];
        
        
        rightGib = [CCSprite spriteWithSpriteFrameName:@"rameno_right.png"];
        rightGib.scaleY = 22;
        rightGib.scaleX = 5;
        //[rightGib setPosition:ccp(1000.00, 267.00)];
        [rightGib setPosition:ccp(1000.00, 367.00)];
        [self addChild:rightGib z:10];
        
        leftGib = [CCSprite spriteWithSpriteFrameName:@"rameno_left.png"];
        leftGib.scaleY = 22;
        leftGib.scaleX = 5;
        //[leftGib setPosition:ccp(-700.00, 100.00)];
        [leftGib setPosition:ccp(-700.00, 0.00)];
        [self addChild:leftGib z:11];
        
        CCSprite *buttonSingleOff = [CCSprite spriteWithSpriteFrameName:@"logik_single1.png"];
        CCSprite *buttonSingleOn = [CCSprite spriteWithSpriteFrameName:@"logik_single2.png"];
        
        CCSprite *buttonCareerOff = [CCSprite spriteWithSpriteFrameName:@"logik_career1.png"];
        CCSprite *buttonCareerOn = [CCSprite spriteWithSpriteFrameName:@"logik_career2.png"];
        
        CCMenuItem *singlePlayItem = [CCMenuItemSprite itemFromNormalSprite:buttonSingleOff selectedSprite:buttonSingleOn target:self selector:@selector(buttonTapped:)];
        singlePlayItem.tag = kButtonSinglePlay;
        CCMenu *singleMenu = [CCMenu menuWithItems:singlePlayItem, nil];
        singleMenu.position = ccp(66.00, 31.50);;
        [rightGib addChild:singleMenu];
        
        CCMenuItem *careerPlayItem = [CCMenuItemSprite itemFromNormalSprite:buttonCareerOff selectedSprite:buttonCareerOn target:self selector:@selector(buttonTapped:)];
        careerPlayItem.tag = kButtonCareerPlay;
        CCMenu *careerMenu = [CCMenu menuWithItems:careerPlayItem, nil];
        careerMenu.position = ccp(195.50, 35.50);
        [leftGib addChild:careerMenu];
        
        CCSprite *buttonInfoOff = [CCSprite spriteWithSpriteFrameName:@"i_off.png"];
        CCSprite *buttonInfoOn = [CCSprite spriteWithSpriteFrameName:@"i_on.png"];
        CCSprite *buttonSettingsOff = [CCSprite spriteWithSpriteFrameName:@"settings_off.png"];
        CCSprite *buttonSettingsOn = [CCSprite spriteWithSpriteFrameName:@"settings_on.png"];

        CCMenuItem *infoItem = [CCMenuItemSprite itemFromNormalSprite:buttonInfoOff selectedSprite:buttonInfoOn target:self selector:@selector(buttonTapped:)];
        infoItem.tag = kButtonInfo;
        infoItem.anchorPoint = CGPointMake(0.5, 1);
        infoItem.position = ccp(RIGHT_BUTTON_TOP_X, RIGHT_BUTTON_TOP_Y);
        CCMenuItem *settingsItem = [CCMenuItemSprite itemFromNormalSprite:buttonSettingsOff selectedSprite:buttonSettingsOn target:self selector:@selector(buttonTapped:)];
        settingsItem.tag = kButtonSettings;
        settingsItem.anchorPoint = CGPointMake(0.5, 1);
        settingsItem.position = ccp(LEFT_BUTTON_TOP_X, LEFT_BUTTON_TOP_Y);
        
        CCMenu *topMenu = [CCMenu menuWithItems:infoItem, settingsItem, nil];
        topMenu.position = CGPointZero;
        [self addChild:topMenu z:30];
        
        lightOff = [CCSprite spriteWithSpriteFrameName:@"lightOff.png"];
        lightOff.anchorPoint = ccp(0.5,1);
        [lightOff setPosition:ccp(screenSize.width/2, 487)];
        lightOff.rotation = -4.0;
        [self addChild:lightOff z:11];
        lightOff.visible = NO;
        
        //HD sprites
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Hq.plist"];

        light = [CCSprite spriteWithSpriteFrameName:@"light.png"];
        light.anchorPoint = ccp(0.5,1);
        [light setPosition:ccp(screenSize.width/2, 487)];
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
        
        CCMoveTo *moveLeft = [CCMoveTo actionWithDuration:1.1 position:ccp(screenSize.width/2 - 5, screenSize.height/2 + 162)];
        CCMoveTo *moveRight = [CCMoveTo actionWithDuration:1.1 position:ccp(screenSize.width/2 + 5, screenSize.height/2 + 162)];
        
        CCEaseInOut *easeMoveLeft = [CCEaseInOut actionWithAction:moveRight rate:3];
        CCEaseInOut *easeMoveRight = [CCEaseInOut actionWithAction:moveLeft rate:3];
        
        //CCSequence *moveSeq = [CCSequence actions:moveLeft, moveRight, nil];
        CCSequence *moveSeq = [CCSequence actions:easeMoveLeft, easeMoveRight, nil];
        [logoShadow runAction:[CCRepeatForever actionWithAction:moveSeq]];
        
        [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_MAIN];
        [self runParticle];
        [self scheduleUpdate];
        [self animationIn];
    }
    return self;
}

- (void) update:(ccTime)deltaTime
{
    counter++;
    if (counter == flag) {
        counter = 0;
        if (flag2 == 7) {
            //CCLOG(@"LONG INTERVAL");
            flag2 = 0;
            flag = [Utils randomNumberBetween:140 andMax:240];
            lightOff.visible = NO;
            light.visible = YES;
        }else{
            //CCLOG(@"SHORT INTERVAL");
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
    return YES;
}

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    
    [super dealloc];
}


@end